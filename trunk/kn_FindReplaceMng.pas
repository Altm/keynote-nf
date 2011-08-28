unit kn_FindReplaceMng;

interface
uses
    TreeNT, RxRichEd,
    kn_LocationObj, kn_Info, FrmFindReplace, kn_NoteObj;

var
    Text_To_Find : WideString;

    Form_FindReplace : TForm_FindReplace;  // GLOBAL FORM!

    Is_Replacing : boolean;     // Find and Replace functions share some procedures; this is how we tell the difference where necessary
    SearchInProgress : boolean; // TRUE while searching or replacing
    UserBreak : boolean;

    SearchNode_Text, SearchNode_TextPrev : wideString;
    StartNote: TTabNote;
    StartNode: TTreeNTNode;

    _Executing_History_Jump : boolean;
    _LastMoveWasHistory : boolean;
    LastGoTo : string; // last line number for the "Go to line" command

procedure RunFinder;
function RunFindNext (Is_ReplacingAll: Boolean= False): boolean;
procedure RunFindAllEx;
procedure RunReplace;
procedure RunReplaceNext;
procedure FindEventProc( sender : TObject );
procedure ReplaceEventProc( ReplaceAll : boolean );
procedure Form_FindReplaceClosed( sender : TObject );
procedure FindResultsToEditor( const SelectedOnly : boolean );


implementation
uses Classes, Dialogs, Forms, SysUtils, Controls, Windows,
     RichEdit,
     gf_miscvcl, gf_strings,
     kn_Global, Kn_const,
     kn_NoteMng, kn_Main, kn_NodeList, kn_Cmd, kn_VCLControlsMng,
     kn_TreeNoteMng, kn_MacroMng, kn_LinksMng, kn_NoteFileMng;

var
   NumberFoundItems: integer;
   RTFAux : TRxRichEdit;


resourcestring
  STR_01 = 'Replace this occurrence?';
  STR_02 = 'Pattern not found: "%s"';
  STR_03 = 'Note "%s" does not exist in this file.';
  STR_04 = 'Tree node "%s" does not exist in note "%s".';
  STR_05 = 'Search results are not available.';
  STR_06 = 'Options';
  STR_07 = ' Searching - press ESC to abort.';
  STR_08 = 'An error occurred during search:';
  STR_09 = ' Pattern found at pos %d (%d occurrence(s))';
  STR_10 = ' Pattern not found.';
  STR_11 = ' Replaced %d occurrence(s)';
  STR_12 = 'Information';


procedure RunFindReplace (modeReplace: boolean);
begin
  if ( not Form_Main.HaveNotes( true, true )) then exit;
  if ( not assigned( ActiveNote )) then exit;
  if ( FileIsBusy or SearchInProgress ) then exit;

  if ( ActiveNote.Editor.SelLength > 0 ) then
     FindOptions.Pattern := trim( ActiveNote.Editor.SelTextW )
  else
     if FindOptions.WordAtCursor then
        FindOptions.Pattern := ActiveNote.Editor.GetWordAtCursorNew( true );

  FindOptions.FindAllMatches := false; // only TRUE when invoked from resource panel

  if ( Form_FindReplace = nil ) then
  begin
    Form_FindReplace := TForm_FindReplace.Create( Form_Main );
    FindOptions.FindNew := true;
    with Form_FindReplace do
    begin
      myNotifyProc := Form_Main.FindNotify;
      MyFindOptions := FindOptions;
      ShowHint := KeyOptions.ShowTooltips;
      FindEvent := FindEventProc;
      ReplaceEvent := ReplaceEventProc;
      FormCloseEvent := Form_FindReplaceClosed;
    end;
  end;

  try
    Form_FindReplace.Combo_Text.Text := FindOptions.Pattern;
    Form_FindReplace.ModeReplace:= modeReplace;
    Form_FindReplace.Show;

  except
     on E : Exception do
        messagedlg( E.Message, mtError, [mbOK], 0 );
  end;

end; // RunFindReplace


procedure RunFinder;
begin
  RunFindReplace (false);
end;

procedure RunReplace;
begin
  RunFindReplace (true);
end;


procedure CreateAuxiliarEditorControl;
begin
   if not assigned(RTFAux) then begin
      RTFAux := TRxRichEdit.Create( ActiveNote.TabSheet);
      RTFAux.Visible:= False;
      RTFAux.Parent:= Form_Main;
   end;
end;


procedure RunReplaceNext;
begin
  if Form_Main.NoteIsReadOnly( ActiveNote, true ) then exit;

  ReplaceEventProc(false);
end; // RunReplaceNext


procedure FindResultsToEditor( const SelectedOnly : boolean );
var
  i, cnt : integer;
  aLocation: TLocation;
begin
  if ( not Form_Main.Pages_Res.Visible ) then exit;
  if ( not assigned( ActiveNote )) then exit;
  if Form_Main.NoteIsReadOnly( ActiveNote, true ) then exit;

  cnt := Location_List.Count;
  if ( cnt = 0 ) then
  begin
    showmessage( STR_05 );
    exit;
  end;

  if SelectedOnly then
  begin
    i := Form_Main.List_ResFind.ItemIndex;
    aLocation:= TLocation( Form_Main.List_ResFind.Items.Objects[i]);
    InsertOrMarkKNTLink(aLocation, true, '');
  end
  else
  begin
    for i := 1 to cnt do
    begin
      aLocation:= TLocation( TLocation( Location_List.Objects[pred( i )] ));
      ActiveNote.Editor.SelTextW := #13 + Format( '%d. ', [i] );
      ActiveNote.Editor.SelStart:= ActiveNote.Editor.SelStart + ActiveNote.Editor.SelLength;
      InsertOrMarkKNTLink(aLocation, true, '');
    end;
  end;
  ActiveNote.Editor.SelLength := 0;

end; // FindResultsToEditor


procedure RunFindAllEx;
var
  oldAllNodes, oldEntireScope, oldWrap : boolean;
  FindDone : boolean;
  Location : TLocation; // object, kn_LocationObj.pas
  SearchOpts : TRichSearchTypes;
  noteidx, i, MatchCount, Counter, PatternPos, PatternLen, SearchOrigin : integer;
  myNote : TTabNote;
  myTreeNode : TTreeNTNode;
  myTNote: TTreeNote;         // [dpv]
  myNoteNode : TNoteNode;
  lastNoteID, lastNodeID : integer;
  lastTag : integer;
  numNodosNoLimpiables: integer;
  thisWord : WideString;
  wordList : TStringList;
  wordidx, wordcnt : integer;
  MultiMatchOK : boolean;
  ApplyFilter: boolean;         // [dpv]
  nodeToFilter: boolean;        // [dpv]
  nodesSelected: boolean;       // [dpv]
  oldActiveNote: TTabNote;

        procedure AddLocation; // INLINE
        var
          path : wideString;
        begin
          if assigned( myTreeNode ) then
          begin
            if ApplyFilter and (not nodesSelected) then      // [dpv] Only once per note
               MarkAllFiltered(myTNote);           // There will be at least one node in the selection
            nodeToFilter:= false;      // [dpv]
            nodesSelected:= true;      // [dpv]
          end;
          path := WideFormat( '%d. %s', [Counter, PathOfKNTLink(myTreeNode, myNote, location.CaretPos)] );

          Location_List.AddObject(
            path,
            Location
          );
        end; // AddLocation
begin

  if ( not Form_Main.HaveNotes( true, true )) then exit;
  if ( not assigned( ActiveNote )) then exit;
  if ( FileIsBusy or SearchInProgress ) then exit;

  if ( Form_Main.Combo_ResFind.Text = '' ) then exit;

  oldActiveNote:= ActiveNote; // [dpv] For use if ApplyFilter=true

  Form_Main.CloseNonModalDialogs;

  with Form_Main do
  begin
    // add search pattern to history
    if ( Combo_ResFind.Items.IndexOf( Combo_ResFind.Text ) < 0 ) then
      Combo_ResFind.Items.Insert( 0, Combo_ResFind.Text );

    // transfer FindAll options to FindOptions
    FindOptions.MatchCase := CB_ResFind_CaseSens.Checked;
    FindOptions.WholeWordsOnly := CB_ResFind_WholeWords.Checked;
    FindOptions.AllTabs := CB_ResFind_AllNotes.Checked;
    FindOptions.SearchNodeNames := CB_ResFind_NodeNames.Checked;
    FindOptions.SearchMode := TSearchMode( RG_ResFind_Type.ItemIndex );
    FindOptions.HiddenNodes:= CB_ResFind_HiddenNodes.Checked;   // [dpv]

    ApplyFilter:= CB_ResFind_Filter.Checked;   // [dpv]
  end;


  // these FindOptions will be preserved and restored
  oldAllNodes := FindOptions.AllNodes;
  FindOptions.AllNodes := true;
  oldEntireScope := FindOptions.EntireScope;
  FindOptions.EntireScope := true;
  oldWrap := FindOptions.Wrap;
  FindOptions.Wrap := false;

  FindOptions.FindNew := true;
  FindOptions.Pattern := trim( Form_Main.Combo_ResFind.Text ); // leading and trailing blanks need to be stripped

  myTreeNode := nil;
  myNoteNode := nil;

  FindOptions.FindAllMatches := true;

  if FindOptions.WholeWordsOnly then
    SearchOpts := [stWholeWord]
  else
    SearchOpts := [];
  if FindOptions.MatchCase then
    SearchOpts := SearchOpts + [stMatchCase];

  PatternPos := 0;
  PatternLen := length( FindOptions.Pattern );
  MatchCount := 0;
  FindDone := false;
  noteidx := 0;
  Counter := 0;

  CreateAuxiliarEditorControl;                  // Si no lo est� a�n.. (lazy load)

  SearchInProgress := true;
  screen.Cursor := crHourGlass;
  Form_Main.List_ResFind.Items.BeginUpdate;

  wordList := TStringList.Create;


  try
    try
      ClearLocationList( Location_List );
      Form_Main.List_ResFind.Items.Clear;

      CSVTextToStrs( wordList, FindOptions.Pattern, #32 );
      wordcnt := wordList.count;


      repeat

        SearchOrigin := 0; // starting a new note
        nodesSelected:= false; // [dpv] in this note, at the moment

        if FindOptions.AllTabs then
          myNote := TTabNote( Form_Main.Pages.Pages[noteidx].PrimaryObject ) // initially 0
        else
          myNote := ActiveNote; // will exit after one loop

        case myNote.Kind of
          ntRTF : begin

            myTreeNode := nil;
            myNoteNode := nil;

            case FindOptions.SearchMode of
              smPhrase : begin

                repeat

                  PatternPos := myNote.Editor.FindText(
                    FindOptions.Pattern,
                    SearchOrigin, myNote.Editor.GetTextLen - SearchOrigin,
                    SearchOpts
                  );
                  if ( PatternPos >= 0 ) then
                  begin
                    SearchOrigin := PatternPos + PatternLen; // move forward in text
                    inc( Counter );
                    Location := TLocation.Create;
                    Location.FileName := Notefile.FileName;
                    Location.NoteName := myNote.Name;
                    Location.CaretPos := PatternPos;
                    Location.SelLength := PatternLen;
                    Location.NoteID := myNote.ID;
                    AddLocation;
                  end;

                  Application.ProcessMessages;
                  if UserBreak then
                  begin
                    FindDone := true;
                  end;

                until ( FindDone or ( PatternPos < 0 )); // repeat

              end; // smPhrase

              smAny, smAll : begin
                MultiMatchOK := false;
                for wordidx := 1 to wordcnt do
                begin
                  thisWord := wordList[pred( wordidx )];

                  PatternPos := myNote.Editor.FindText(
                    thisWord,
                    0, myNote.Editor.GetTextLen,
                    SearchOpts
                  );

                  case FindOptions.SearchMode of
                    smAll : begin
                      if ( PatternPos >= 0 ) then
                      begin
                        MultiMatchOK := true; // assume success
                      end
                      else
                      begin
                        MultiMatchOK := false;
                        break; // note must have ALL words
                      end;
                    end; // smAll

                    smAny : begin
                      if ( PatternPos >= 0 ) then
                      begin
                        MultiMatchOK := true;
                        break; // enough to find just 1 word
                      end;
                    end; // smAny

                  end; // case FindOptions.SearchMode of

                  Application.ProcessMessages;
                  if UserBreak then
                  begin
                    FindDone := true;
                    break;
                  end;

                end; // for wordidx

                if MultiMatchOK then
                begin
                  inc( Counter );
                  Location := TLocation.Create;
                  Location.FileName := Notefile.FileName;
                  Location.NoteName := myNote.Name;
                  Location.CaretPos := 0;
                  Location.SelLength := 0;
                  Location.NoteID := myNote.ID;
                  AddLocation;
                end;

              end; // smAny, smAll

            end; // case FindOptions.SearchMode

          end; // ntRTF

          ntTree : begin
            myTNote:= TTreeNote( myNote);
            //ActiveNote.EditorToDataStream; // update node's datastream    [dpv]
            myTNote.EditorToDataStream; // update node's datastream

            myTreeNode := myTNote.TV.Items.GetFirstNode;
            if assigned( myTreeNode ) and myTreeNode.Hidden and (not FindOptions.HiddenNodes) then     // [dpv]
               myTreeNode := myTreeNode.GetNextNotHidden;

            while assigned( myTreeNode ) do // go through all nodes
            begin
              nodeToFilter:= true;      // [dpv]
              // get this node's object and transfer
              // its RTF data to temp editor
              myNoteNode := TNoteNode( myTreeNode.Data );
              myNoteNode.Stream.Position := 0;
              RTFAux.Lines.LoadFromStream( myNoteNode.Stream );           // [dpv]  (002)
              SearchOrigin := 0;

              case FindOptions.SearchMode of

                smPhrase : begin

                  // look for match in node name first
                  if FindOptions.SearchNodeNames then
                  begin
                    if FindOptions.MatchCase then
                      PatternPos := pos( FindOptions.Pattern, myNoteNode.Name )
                    else
                      PatternPos := pos( ansilowercase( FindOptions.Pattern ), ansilowercase( myNoteNode.Name ));
                    if ( PatternPos > 0 ) then
                    begin
                      inc( Counter );
                      Location := TLocation.Create;
                      Location.FileName := notefile.FileName;
                      Location.NoteName := myNote.Name;
                      Location.NodeName := myNoteNode.Name;
                      Location.CaretPos := -1; // means: text found in node name
                      Location.SelLength := 0;
                      Location.NoteID := myNote.ID;
                      Location.NodeID := myNoteNode.ID;
                      AddLocation;
                    end;
                  end;

                  repeat // find all matches in current node

                    // search in the temp editor
                    PatternPos := RTFAux.FindText(
                      FindOptions.Pattern,
                      SearchOrigin, RTFAux.GetTextLen - SearchOrigin,
                      SearchOpts
                    );

                    if ( PatternPos >= 0 ) then
                    begin
                      SearchOrigin := PatternPos + PatternLen; // move forward in text
                      inc( Counter );
                      Location := TLocation.Create;
                      Location.FileName := notefile.FileName;
                      Location.NoteName := myNote.Name;
                      Location.NodeName := myNoteNode.Name;
                      Location.CaretPos := PatternPos;
                      Location.SelLength := PatternLen;
                      Location.NoteID := myNote.ID;
                      Location.NodeID := myNoteNode.ID;
                      AddLocation;
                    end;

                    Application.ProcessMessages;
                    if UserBreak then
                    begin
                      FindDone := true;
                    end;

                  until ( FindDone or ( PatternPos < 0 )); // repeat

                end; // smPhrase

                smAny, smAll : begin

                  MultiMatchOK := false;
                  for wordidx := 1 to wordcnt do
                  begin
                    thisWord := wordList[pred( wordidx )];

                    PatternPos := RTFAux.FindText(
                      thisWord,
                      0, RTFAux.GetTextLen,
                      SearchOpts
                    );

                    case FindOptions.SearchMode of
                      smAll : begin
                        if ( PatternPos >= 0 ) then
                        begin
                          MultiMatchOK := true; // assume success
                        end
                        else
                        begin
                          MultiMatchOK := false;
                          break; // note must have ALL words
                        end;
                      end; // smAll

                      smAny : begin
                        if ( PatternPos >= 0 ) then
                        begin
                          MultiMatchOK := true;
                          break; // enough to find just 1 word
                        end;
                      end; // smAny

                    end; // case FindOptions.SearchMode of

                    Application.ProcessMessages;
                    if UserBreak then
                    begin
                      FindDone := true;
                      break;
                    end;

                  end; // for wordidx

                  if MultiMatchOK then
                  begin
                    inc( Counter );
                    Location := TLocation.Create;
                    Location.FileName := notefile.FileName;
                    Location.NoteName := myNote.Name;
                    Location.NodeName := myNoteNode.Name;
                    Location.CaretPos := 0;
                    Location.SelLength := 0;
                    Location.NoteID := myNote.ID;
                    Location.NodeID := myNoteNode.ID;
                    AddLocation;
                  end;

                end; // smAny, smAll

              end; // case FindOptions.SearchMode


              if ApplyFilter and (not nodeToFilter) then    // [dpv]
                 TNoteNode(myTreeNode.Data).Filtered := false;

              if FindOptions.HiddenNodes then     // [dpv]
                 myTreeNode := myTreeNode.GetNext
              else
                 myTreeNode := myTreeNode.GetNextNotHidden;

            end; // while assigned( myTreeNode ) do
          end; // ntTree

        end;

        if ApplyFilter and nodesSelected then begin   // [dpv]
           Form_Main.FilterApplied(myTNote);
           ActiveNote:= nil;      // -> TreeNodeSelected will exit doing nothing
           HideFilteredNodes (myTNote);
           if myTNote.HideCheckedNodes then
              HideCheckedNodes (myTNote);

           ActiveNote:= myNote;
           myTreeNode := myTNote.TV.Items.GetFirstNode;
           if myTreeNode.Hidden then myTreeNode := myTreeNode.GetNextNotHidden;
           myTNote.TV.Selected:= nil;
           myTNote.TV.Selected:= myTreeNode;   // force to select -> TreeNodeSelected
           ActiveNote:= oldActiveNote;

           NoteFile.Modified := true;
           UpdateNoteFileState( [fscModified] );
        end;


        if FindOptions.AllTabs then
        begin
          inc( noteidx );
          if ( noteidx >= NoteFile.NoteCount ) then
            FindDone := true;
        end
        else
        begin
          FindDone := true;
        end;

      until FindDone;


      MatchCount := Location_List.Count;
      if ( MatchCount > 0 ) then
      begin
        lastNoteID := 0;
        lastNodeID := 0;
        lastTag := 0;
        for i := 1 to MatchCount do
        begin
          Location := TLocation( Location_List.Objects[pred( i )] );
          if ( i > 1 ) then
          begin
            if (( lastNoteID <> Location.NoteID ) or ( lastNodeID <> Location.NodeID )) then
            begin
              case lastTag of
                0 : Location.Tag := 1;
                else
                  Location.Tag := 0;
              end;
            end
            else
            begin
              Location.Tag := lastTag;
            end;
          end;
          lastNoteID := Location.NoteID;
          lastNodeID := Location.NodeID;
          lastTag := Location.Tag;
          Form_Main.List_ResFind.Items.AddObject(
            Location_List[pred( i )],
            Location
          );
        end;
        with Form_Main do
        begin
          List_ResFind.ItemIndex := 0;
          try
            Btn_ResFlip.Caption := STR_06;
            Ntbk_ResFind.PageIndex := 0;
            List_ResFind.SetFocus;
          except
          end;
        end;
      end
      else
      begin
        DoMessageBox(WideFormat( STR_02, [FindOptions.Pattern] ), STR_12, 0);
      end;

    except
      on E : Exception do
      begin
        messagedlg( E.Message, mtError, [mbOK], 0 );
      end;
    end;
  finally
    ActiveNote:= oldActiveNote;   // [dpv]
    UpdateNoteDisplay;  // [dpv]

    // restore previous FindOptions settings
    Form_Main.List_ResFind.Items.EndUpdate;
    FindOptions.AllNodes := oldAllNodes;
    FindOptions.EntireScope := oldEntireScope;
    FindOptions.Wrap := oldWrap;
    FindOptions.FindAllMatches := false;
    SearchInProgress := false;
    screen.Cursor := crDefault;
    wordList.Free;
    FreeAndNil(RTFAux);
  end;

end; // RunFindAllEx


function RunFindNext (Is_ReplacingAll: Boolean= False): boolean;
var
  myNote : TTabNote;
  myTreeNode : TTreeNTNode;
  EditControl: TRxRichEdit;
  FindDone, Found : boolean;
  PatternPos : integer;
  SearchOrigin : integer;
  SearchOpts : TRichSearchTypes;
  handle: HWND;


  function LoopCompleted(Wrap: boolean): Boolean;
  begin
      Result:= True;

      if not assigned(myNote) then exit;

      if not (
         (myNote = StartNote)
          and ((myNote.Kind <> ntTree) or (myTreeNode = StartNode))    ) then
         Result:= False
      else
          if Wrap and (NumberFoundItems > 0) then begin    // Wrap ser� siempre false si Is_ReplacingAll = True
             Result:= False;
             NumberFoundItems:= 0;
             end;
  end;


  procedure GetFirstNode();
  begin
      myTreeNode := TTreeNote( myNote ).TV.Items.GetFirstNode;
      if assigned( myTreeNode ) and myTreeNode.Hidden and (not FindOptions.HiddenNodes) then
         myTreeNode := myTreeNode.GetNextNotHidden;
  end;


  // Actualiza el siguiente nodo a utilizar, que podr� ser nil si no se puede avanzar hacia
  // ning�n nodo de la nota actual.
  // Tambi�n puede establecer FindDone a True indicando que la b�squeda ha finalizado.
  // Si FindDone = False y el nodo = nil implicar� que debe continuarse con la siguiente nota.
  //
  procedure GetNextNode();
  var
     Wrap: boolean;
  begin
     FindDone:= (myNote.Kind = ntTree);   // Si es una nota de tipo �rbol supondremos inicialmente que no se podr� avanzar m�s

     if not assigned(myTreeNode) or FindOptions.SelectedText then exit;

     Wrap:= FindOptions.Wrap and not Is_ReplacingAll;
     if not (FindOptions.AllTabs or FindOptions.AllNodes or Wrap) then exit;

     if FindOptions.AllTabs or FindOptions.AllNodes then begin
         if FindOptions.HiddenNodes then
            myTreeNode := myTreeNode.GetNext
         else
            myTreeNode := myTreeNode.GetNextNotHidden;

         if not assigned( myTreeNode) then
            if (Wrap or Is_ReplacingAll) and (not FindOptions.AllTabs) then  // Si AllTabs -> pasaremos a otra nota
               GetFirstNode;
     end;

     if not LoopCompleted(Wrap) then begin
        FindDone:= False;
        SearchOrigin := 0;
     end;


  end;

  procedure GetNextNote();
  var
     tabidx : integer;
     wrap: boolean;
  begin
      FindDone:= True;   // Supondremos inicialmente que no se podr� avanzar m�s

      Wrap:= FindOptions.Wrap and not Is_ReplacingAll;

      if (FindOptions.AllTabs) and (not FindOptions.SelectedText) and (Form_Main.Pages.PageCount > 1) then begin
          tabidx := myNote.TabSheet.PageIndex;
          if tabidx < pred(Form_Main.Pages.PageCount) then
             inc(tabidx)
          else
             tabidx := 0;

          myNote := TTabNote(Form_Main.Pages.Pages[tabidx].PrimaryObject);

          if myNote.Kind = ntTree then
             GetFirstNode;

          if not LoopCompleted(Wrap) then begin
             SearchOrigin := 0;
             FindDone:= False;
          end;
      end
      else
          if (myNote.Kind <> ntTree) and (not LoopCompleted(Wrap)) then begin
             SearchOrigin := 0;
             FindDone:= False;
          end;

   end;


  procedure SelectPatternFound();
  begin
      if (myNote <> ActiveNote) then
      begin
        with Form_Main do begin
          Pages.ActivePage := myNote.TabSheet;
          PagesChange( Pages );
        end;
      end;

      if ( ActiveNote.Kind = ntTree ) then
         if TTreeNote( ActiveNote ).TV.Selected <> myTreeNode then begin
            myTreeNode.MakeVisible;  // Could be hidden
            TTreeNote( ActiveNote ).TV.Selected := myTreeNode;
         end;

      with myNote.Editor do
      begin
        SelStart := PatternPos;
        SelLength := length( Text_To_Find);
      end;
  end;


  // Preparar el editor (TTabRichEdit) al que preguntaremos por el texto buscado, con FindText
  //
  procedure PrepareEditControl;
  var
      myNoteNode : TNoteNode;
  begin
      if (myNote.Kind <> ntTree)  or ((myNote = ActiveNote) and (TTreeNote(ActiveNote).TV.Selected = myTreeNode)) then begin
          if (myNote.Kind = ntTree) and myNote.Editor.Modified then begin
              myNote.EditorToDataStream;
              myNote.Editor.Modified := false;
              myNote.Modified := true;
          end;
          EditControl:= myNote.Editor
      end
      else begin
         // Get the actual node's object and transfer its RTF data to temp editor
          CreateAuxiliarEditorControl;                  // Si no lo est� a�n.. (lazy load)
          myNoteNode := TNoteNode( myTreeNode.Data );
          myNoteNode.Stream.Position := 0;
          RTFAux.Lines.LoadFromStream( myNoteNode.Stream );
          EditControl:= RTFAux;
      end;
  end;



begin
  result := false;
  if ( not ( Form_Main.HaveNotes( true, true ) and assigned( ActiveNote ))) then exit;
  if ( SearchInProgress or FileIsBusy or ( Text_To_Find = '' )) then exit;


  if assigned( Form_FindReplace ) then
      handle:= Form_FindReplace.Handle
  else
      handle:= 0;

  FindOptions.FindAllMatches := false; // only TRUE when invoked from resource panel
  FindDone := false;
  Found := false;

  PatternPos := -1;
  UserBreak := false;
  myTreeNode := nil;

  if FindOptions.WholeWordsOnly then
     SearchOpts := [stWholeWord]
  else
     SearchOpts := [];
  if FindOptions.MatchCase then
     SearchOpts := SearchOpts + [stMatchCase];

  Form_Main.StatusBar.Panels[PANEL_HINT].text := STR_07;


  SearchInProgress := true;
  try
    try

      // Identificaci�n de la posici�n de inicio de la b�squeda ---------------------------
      if ( FindOptions.FindNew and FindOptions.EntireScope ) then
          SearchOrigin := 0
      else begin
          SearchOrigin := ActiveNote.Editor.SelStart;
          if ActiveNote.Editor.SelLength = length( Text_To_Find) then
             inc(SearchOrigin);
      end;

      myNote := ActiveNote;
      if myNote.Kind = ntTree then
         myTreeNode := TTreeNote( myNote ).TV.Selected;

      if FindOptions.FindNew then begin
         StartNote:= myNote;
         StartNode:= myTreeNode;
         NumberFoundItems:= 0;
         FindOptions.FindNew := False;
      end;


      // B�squeda del patr�n iterando sobre los nodos / notas hasta encontrar uno -------------
      // Seg�n las opciones establecidas as� podr�n recorrerse o no todos los nodos de una nota, todas las notas
      // o incluso continuar buscando desde el punto de partida, de manera c�clica.

      repeat
            PrepareEditControl;

            PatternPos := EditControl.FindText(
              Text_To_Find,
              SearchOrigin, EditControl.GetTextLen - SearchOrigin,
              SearchOpts
            );

            if PatternPos < 0 then begin
               GetNextNode;                 // Podr� actualizar FindDone
               if (not FindDone) and (not assigned(myTreeNode)) then
                  GetNextNote()
            end;
            Application.ProcessMessages;    // Para permitir que el usuario cancele (UserBreak)

      until FindDone or (PatternPos >= 0) or UserBreak;


      if ( PatternPos >= 0 ) then begin
          // pattern found, display note (select tree node if necessary) and position caret at pattern
          Found := true;
          FindOptions.FindNew := false;
          FindDone := true;
          inc(NumberFoundItems);
          SelectPatternFound();
      end;


    except
      on E: Exception do begin
          PopupMessage( STR_08 +#13+ E.Message, mtError, [mbOK], 0 );
          exit;
      end;
    end;

  finally
      if Found then begin
          Form_Main.StatusBar.Panels[PANEL_HINT].text := WideFormat(STR_09, [PatternPos, NumberFoundItems]);
          if IsRecordingMacro then
             AddMacroEditCommand( ecFindText );
      end
      else begin
          Form_Main.StatusBar.Panels[PANEL_HINT].Text := STR_10;
          if not (UserBreak or Is_Replacing) then
             DoMessageBox(WideFormat( STR_02, [Text_To_Find] ), STR_12, 0, handle);
      end;

      result := Found;
      SearchInProgress := false;
      UserBreak := false;
  end;

end; // RunFindNext;


procedure FindEventProc( sender : TObject );
var
   autoClose: boolean;
begin
  if assigned( Form_FindReplace ) then
  begin
      FindOptions := Form_FindReplace.MyFindOptions;
      Text_To_Find := FindOptions.Pattern;
      autoClose:= FindOptions.AutoClose and not Form_FindReplace.ModeReplace;
      if RunFindNext then
      begin
          Form_FindReplace.MyFindOptions := FindOptions; // must preserve .FindNew field
          if autoClose then
            Form_FindReplace.Close
          else
            Form_FindReplace.SetFocus;
      end
      else begin
        if autoClose then
           Form_FindReplace.Close;
      end;
  end;
end; // FindEventProc


procedure ReplaceEventProc( ReplaceAll : boolean );
var
  ReplaceCnt : integer;
  Original_Confirm : boolean;
  Original_EntireScope : boolean;
  SelectedTextToReplace: boolean;
  DoReplace: Boolean;
  txtMessage: WideString;
  handle: HWND;
  AppliedBeginUpdate: Boolean;


  function GetReplacementConfirmation: Boolean;
  begin
      Result := false;
      if ReplaceAll and FindOptions.ReplaceConfirm then
          // Note: With DoMessageBox I can't show All button
          case messagedlg( STR_01,
             mtConfirmation, [mbYes,mbNo,mbAll,mbCancel], 0 ) of
             mrYes:  Result := true;
             mrNo:   Result := false;
             mrAll:  begin
                     Result := true;
                     FindOptions.ReplaceConfirm := false;
                     end;
             mrCancel: begin
                     Result := false;
                     ReplaceAll := false; // will break out of loop
                     end;
          end

      else
          Result := true;
  end;

  function IdentifySelectedTextToReplace: Boolean;
  var
    WordAtCursor: WideString;
    SelectedTextLength: integer;
  begin
      SelectedTextLength:= ActiveNote.Editor.SelLength;

      Result:= (SelectedTextLength > 0);
      if Result then begin
         if FindOptions.WholeWordsOnly then begin
             WordAtCursor:= ActiveNote.Editor.GetWordAtCursorNew( false, true );
             if length(WordAtCursor) <> SelectedTextLength then
                Result:= False;
         end;
         if Result then
            if FindOptions.MatchCase then
               Result:= (ActiveNote.Editor.SelTextW = Text_To_Find)
            else
               Result:= WideSameText(ActiveNote.Editor.SelTextW, Text_To_Find);
         end;
  end;

  procedure BeginUpdateOnNotes;
  var
     i: integer;
     note: TTabNote;
  begin
     AppliedBeginUpdate:= True;
     for i := 0 to Form_Main.Pages.PageCount - 1 do
     begin
          note:= TTabNote(Form_Main.Pages.Pages[i].PrimaryObject);
          note.Editor.EndUpdate;
     end;
  end;

  procedure EndUpdateOnNotes;
  var
     i: integer;
     note: TTabNote;
  begin
     if not AppliedBeginUpdate then exit;
     
     for i := 0 to Form_Main.Pages.PageCount - 1 do
     begin
        note:= TTabNote(Form_Main.Pages.Pages[i].PrimaryObject);
        note.Editor.EndUpdate;
     end;
     AppliedBeginUpdate:= False;
  end;

begin
  if assigned( Form_FindReplace ) then begin
     FindOptions := Form_FindReplace.MyFindOptions;
     handle:= Form_FindReplace.Handle;
  end
  else
     handle:= 0;

  ReplaceCnt := 0;
  Text_To_Find := FindOptions.Pattern;
  Original_Confirm := FindOptions.ReplaceConfirm;
  Original_EntireScope := FindOptions.EntireScope;

  Is_Replacing := true;
  AppliedBeginUpdate:= False;

  try
    DoReplace:= True;

    // Verificamos si hay que restringir la b�squeda a la selecci�n actual
    if FindOptions.FindNew then begin
        if ReplaceAll and FindOptions.SelectedText then begin
           FindOptions.SelectionStart:= ActiveNote.Editor.SelStart;
           FindOptions.SelectionEnd:= FindOptions.SelectionStart + ActiveNote.Editor.SelLength;
           FindOptions.EntireScope := False;
        end;
    end;

    // Comprobamos (si no se ha pulsado ReplaceAll) en primer lugar si el texto que se encuentra
    // seleccionado es el que hay que buscar y reemplazar. Si es as�, haremos el reemplazo con �ste,
    // directamente.
    SelectedTextToReplace:= False;
    if not ReplaceAll then
       SelectedTextToReplace:= IdentifySelectedTextToReplace;

    if not SelectedTextToReplace then begin
       SelectedTextToReplace:= RunFindNext(ReplaceAll);
       if not ReplaceAll then
          DoReplace:= False;   // Lo dejaremos seleccionado pero no lo reemplazaremos. El usuario no ha llegado
                               //a ver ese texto y debe confirmarlo pulsando conscientemente en Replace (el
                               // checkbox 'confirm replace' s�lo se aplica a ReplaceAll)
    end;


    if DoReplace then begin
        if ReplaceAll and not FindOptions.ReplaceConfirm then
           BeginUpdateOnNotes;

        while SelectedTextToReplace do
        begin
            try
                // �Hay que restringirse al texto inicialmente seleccionado?
                if ReplaceAll and FindOptions.SelectedText then
                   if (ActiveNote.Editor.SelStart < FindOptions.SelectionStart) or
                     ((ActiveNote.Editor.SelStart + ActiveNote.Editor.SelLength) > FindOptions.SelectionEnd) then
                       break;

                if GetReplacementConfirmation then begin
                   inc(ReplaceCnt);
                   ActiveNote.Editor.SelTextW := FindOptions.ReplaceWith;
                   ActiveNote.Editor.SelStart := ActiveNote.Editor.SelStart + length( ActiveNote.Editor.SelTextW );
                end;

                Application.ProcessMessages;
                if UserBreak then break;

                SelectedTextToReplace:= RunFindNext(ReplaceAll);     // Localizamos el siguiente patr�n a remplazar

                if (not ReplaceAll) then break;          // Dejamos simplemente localizado el texto si no ReplaceAll

            except
               On E : Exception do begin
                  showmessage( E.Message );
                  break;
               end;
            end;
        end; // while

    end;

  finally
    EndUpdateOnNotes;
    Is_Replacing := false;
    UserBreak := false;
    FindOptions.ReplaceConfirm := Original_Confirm;
    FindOptions.EntireScope := Original_EntireScope;
  end;

  txtMessage:= WideFormat( STR_11, [ReplaceCnt] );
  Form_Main.StatusBar.Panels[PANEL_HINT].Text := txtMessage;
  if ( ReplaceCnt > 0 ) then begin
     if ReplaceAll then DoMessageBox(txtMessage, STR_12, 0, handle);
     NoteFile.Modified := true;
     UpdateNoteFileState( [fscModified] );
     end
  else
      if not SelectedTextToReplace then begin
         DoMessageBox(WideFormat( STR_02, [Text_To_Find] ), STR_12, 0, handle);
      end;

end; // ReplaceEventProc


procedure Form_FindReplaceClosed( sender : TObject );
begin
  try
    try
      if SearchInProgress then
      begin
        UserBreak := true;
        SearchInProgress := false;
      end;
      FindOptions := Form_FindReplace.MyFindOptions;
      Form_FindReplace.Release;
      if assigned(RTFAux) then
         FreeAndNil(RTFAux);

    except
    end;
  finally
    Form_FindReplace := nil;
    Form_Main.FindNotify( true );
  end;
end; // Form_ReplaceClosed


Initialization
    Text_To_Find := '';
    Is_Replacing := false;
    Form_FindReplace := nil;
    SearchInProgress := false;
    UserBreak := false;
    _Executing_History_Jump := false;
    _LastMoveWasHistory := false;

end.
