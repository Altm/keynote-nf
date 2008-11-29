
(* ************************************************************
 KEYNOTE: MOZILLA PUBLIC LICENSE STATEMENT.
 -----------------------------------------------------------
 The contents of this file are subject to the Mozilla Public
 License Version 1.1 (the "License"); you may not use this file
 except in compliance with the License. You may obtain a copy of
 the License at http://www.mozilla.org/MPL/

 Software distributed under the License is distributed on an "AS
 IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 implied. See the License for the specific language governing
 rights and limitations under the License.

 The Original Code is KeyNote 1.0.

 The Initial Developer of the Original Code is Marek Jedlinski
 <eristic@lodz.pdi.net> (Poland).
 Portions created by Marek Jedlinski are
 Copyright (C) 2000, 2001. All Rights Reserved.
 -----------------------------------------------------------
 Contributor(s):
 -----------------------------------------------------------
 History:
 -----------------------------------------------------------
 Released: 30 June 2001
 -----------------------------------------------------------
 URLs:

 - for OpenSource development:
 http://keynote.sourceforge.net

 - original author's software site:
 http://www.lodz.pdi.net/~eristic/free/index.html
 http://go.to/generalfrenetics

 Email addresses (at least one should be valid)
 <eristic@lodz.pdi.net>
 <cicho@polbox.com>
 <cicho@tenbit.pl>

************************************************************ *)

unit kn_SendMail;

// - log only when MJ_DEBUG is set
// - if sending "all" or "file", and the file is encrypted, WARN.
//   (actually: disable "file" when file is encrypted!)

interface

uses
  Windows, Messages, SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs,
  StdCtrls, SmtpProt, ComCtrls,
  kn_Info, kn_Const, IniFiles,
  gf_misc, gf_strings, wsocket,
  kn_FileObj, kn_NoteObj, ExtCtrls,
  RxRichEd, TreeNT, kn_NodeList,
  gf_files, kn_INI, GFLog;

type
  TForm_Mail = class(TForm)
    Button_OK: TButton;
    Button_Cancel: TButton;
    Pages: TPageControl;
    Tab_Send: TTabSheet;
    Tab_SMTP: TTabSheet;
    GroupBox_Source: TGroupBox;
    RB_Current: TRadioButton;
    RB_All: TRadioButton;
    RB_File: TRadioButton;
    GroupBox1: TGroupBox;
    RB_PlainText: TRadioButton;
    RB_RTF: TRadioButton;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Combo_TO: TComboBox;
    Label2: TLabel;
    Edit_Subject: TEdit;
    Label3: TLabel;
    Combo_CC: TComboBox;
    GroupBox3: TGroupBox;
    SmtpCli: TSmtpCli;
    Label4: TLabel;
    Edit_SMTPServer: TEdit;
    Label5: TLabel;
    Edit_Port: TEdit;
    Label6: TLabel;
    Edit_From: TEdit;
    Label7: TLabel;
    Combo_Charset: TComboBox;
    Label_Status: TLabel;
    GFLog: TGFLog;
    CheckBox_Log: TCheckBox;
    Label8: TLabel;
    Edit_FirstLine: TEdit;
    Button_Help: TButton;
    CheckBox_ExcludeHiddenNodes: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button_OKClick(Sender: TObject);
    procedure Button_CancelClick(Sender: TObject);
    procedure RB_CurrentClick(Sender: TObject);
    procedure SmtpCliHeaderLine(Sender: TObject; Msg: PChar;
      Size: Integer);
    procedure SmtpCliRequestDone(Sender: TObject; RqType: TSmtpRequest;
      Error: Word);
    procedure TimerTimer(Sender: TObject);
    procedure SmtpCliDisplay(Sender: TObject; Msg: String);
    procedure RB_FileClick(Sender: TObject);
    procedure Button_HelpClick(Sender: TObject);
  private
    { Private declarations }
    procedure ShowException( Sender : TObject; E : Exception );
  public
    { Public declarations }
    OK_Click : boolean;
    myINI_FN : string;
    myADR_FN : string;
    mySIG_FN : string;

    MailOptions : TMailOptions;
    IsBusy : boolean;
    myNotes : TNoteFile;
    myActiveNote : TTabNote;
    myCurNoteName : string;
    UserFieldsAdded : boolean;
    HadError : boolean;
    TimerTick : integer;
    Padding : string;
    InHeader : boolean;

    procedure SendEmail;
    procedure BeforeMail;
    procedure AfterMail;

    function Verify : boolean;
    function ExpandTokenLine( aLine : string ) : string;
    procedure AddNoteToMailMessage( const aNote : TTabNote );

  end;

function SMTPErrorDesc( Error : integer ) : string;

implementation

{$R *.DFM}

function SMTPErrorDesc( Error : integer ) : string;
begin
  case Error of
    421 : result := 'Service not available';
    450 : result := 'Requested mail action not taken: mailbox unavailable';
    451 : result := 'Requested action aborted: local error in processing';
    452 : result := 'Requested action not taken: insufficient system storage';
    500 : result := 'Syntax error, command unrecognized';
    502 : result := 'Command not implemented';
    503 : result := 'Bad sequence of commands';
    504 : result := 'Command parameter not implemented';
    550 : result := 'Requested action not taken: mailbox unavailable';
    551 : result := 'User not local';
    552 : result := 'Requested mail action aborted: exceeded storage allocation';
    553 : result := 'Requested action not taken: mailbox name not allowed';
    554 : result := 'Transaction failed';
    else
      result := 'Unknown error or no error condition';
  end;
end; // SMTPErrorDesc


procedure TForm_Mail.FormCreate(Sender: TObject);
begin

  OK_Click := false;
  IsBusy := false;
  myActiveNote := nil;
  myNotes := nil;
  myCurNoteName := '';
  UserFieldsAdded := false;
  Application.OnException := ShowException;
  HadError := false;
  TimerTick := 0;
  // Timer.Enabled := false;
  Padding := '-----------';
  InHeader := true;

  Pages.ActivePage := Tab_Send;

  myINI_FN := normalFN( extractfilepath( Application.exename ) + 'keymail.ini' );

  InitializeMailOptions( MailOptions );
  Combo_Charset.ItemIndex := 0;

end; // CREATE

procedure TForm_Mail.FormActivate(Sender: TObject);
begin
  OnActivate := nil;

  myADR_FN := changefileext( myINI_FN, ext_ADR );
  mySIG_FN := changefileext( myINI_FN, ext_SIG );

  GFLog.FileName := changefileext( myINI_FN, ext_LOG );
  if fileexists( myADR_FN ) then
  begin
    Combo_TO.items.LoadFromFile( myADR_FN );
    Combo_CC.items.LoadFromFile( myADR_FN );
  end;

  LoadMailOptions( myINI_FN, MailOptions );

  CheckBox_Log.Checked := MailOptions.KeepLog;
  Edit_FirstLine.Text := MailOptions.FirstLine;

  if MailOptions.TextCharSet <> '' then
    Combo_Charset.Text := MailOptions.TextCharSet;

  if MailOptions.AsPlainText then
    RB_PlainText.Checked := true
  else
    RB_RTF.Checked := true;

  Edit_SMTPServer.Text := MailOptions.SMTPServer;
  Edit_From.Text := MailOptions.FromAddr;

  if MailOptions.SMTPPort <> '' then
    Edit_Port.Text := MailOptions.SMTPPort
  else
    Edit_Port.Text := 'smtp';

  if assigned( myActiveNote ) then
    myCurNoteName := RemoveAccelChar( myActiveNote.Name );
  if ( myCurNoteName <> '' ) then
  begin
    RB_Current.Caption := RB_Current.Caption + ': "' + myCurNoteName + '"';
    Edit_Subject.Text := MailOptions.SubjectPrefix + myCurNoteName;
  end
  else
  begin
    RB_Current.Enabled := false;
    RB_All.Checked := true;
  end;

  CheckBox_ExcludeHiddenNodes.Checked:= True;    // [dpv]

  RB_CurrentClick( self );

  RB_Current.OnClick := RB_CurrentClick;
  RB_All.OnClick := RB_CurrentClick;
  RB_File.OnClick := RB_CurrentClick;

  Combo_TO.SetFocus;

end; // ACTIVATE

procedure TForm_Mail.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ( IsBusy and ( not( SmtpCli.State in [smtpReady,smtpAbort] ))) then
  begin
    SMTPCli.Abort;
    AfterMail;
    Label_Status.Caption := 'Transaction aborted by user';
    CanClose := false;
  end
  else
  begin
    CanClose := true;
  end;
end;

procedure TForm_Mail.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
    27 : if (( shift = [] ) and ( not ( Combo_TO.DroppedDown or Combo_CC.DroppedDown or Combo_Charset.DroppedDown )))
      then begin
      OK_Click := false;
      ModalResult := mrCancel;
    end;
  end;
end;


procedure TForm_Mail.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if MailOptions.KeepLog then
    GFLog.Save( '' );
end;

procedure TForm_Mail.Button_OKClick(Sender: TObject);
begin

  SendEmail;

end;

procedure TForm_Mail.Button_CancelClick(Sender: TObject);
begin
  // CANCEL click
  OK_Click := false;
  MOdalResult := mrCancel;
end;

function TForm_Mail.Verify : boolean;
var
  s : string;
begin
  result := false;
  s := '';

  if Edit_SMTPServer.text = '' then
    s := 'SMTP server must be specified'
  else
  if Edit_Port.text = '' then
    s := 'SMTP port must be specified'
  else
  if Edit_From.text = '' then
    s := '"From" address (your email address) must be specified'
  else
  if Combo_To.text = '' then
    s := '"To" address (recipient) must be specified';

  if s <> ''  then
  begin
    case messagedlg( 'Cannot send email message: ' + #13 + s, mtError, [mbOK, mbCancel], 0 ) of
      mrOK : begin end;
      else
        OK_Click := false;
        ModalResult := mrCancel; // close form
    end;
  exit;
  end;

  if Edit_Subject.Text = '' then
  begin
    case messagedlg( 'The Subject line is empty. Send anyway?', mtConfirmation, [mbYes,mbNo], 0 ) of
      mrOK : begin end;
      else
      begin
        Pages.ActivePage := Tab_Send;
        Edit_Subject.SetFocus;
        OK_Click := false;
        exit;
      end;
    end;
  end;


  result := ( s = '' );

end; // Verify

procedure TForm_Mail.RB_CurrentClick(Sender: TObject);
begin
  if RB_Current.Checked then
  begin
    RB_RTF.Enabled := ( myActiveNote.Kind = ntRTF );
    RB_PlainText.Enabled := true;
  end
  else
  if RB_All.Checked then
  begin
    RB_PlainText.Checked := true;
    RB_RTF.Enabled := false;
    RB_PlainText.Enabled := true;
  end
  else
  begin
    RB_RTF.Checked := true;
    RB_PlainText.Enabled := false;
  end;
end;

function TForm_Mail.ExpandTokenLine( aLine : string ) : string;
var
  p : integer;
begin
  result := aLine;

  p := pos( MAILFILENAME, result );
  if ( p > 0 ) then
  begin
    delete( result, p, 2 );
    insert( myNotes.FileName, result, p )
  end;

  p := pos( MAILNOTENAME, result );
  if ( p > 0 ) then
  begin
    delete( result, p, 2 );
    insert( MyCurNoteName, result, p );
  end;

  p := pos( MAILKEYNOTEVERSION, result );
  if ( p > 0 ) then
  begin
    delete( result, p, 2 );
    insert( Program_Name + #32 + Program_Version, result, p );
  end;

  p := pos( MAILNOTECOUNT, result );
  if ( p > 0 ) then
  begin
    delete( result, p, 2 );
    if RB_Current.Checked then
      insert( '1', result, p )
    else
      insert( inttostr( myNotes.Notes.Count ), result, p );
  end;

end; // ExpandTokenLine

procedure TForm_Mail.AddNoteToMailMessage( const aNote : TTabNote );
var
  tNote : TTreeNote;
  myTreeNode : TTreeNTNode;
  myNoteNode : TNoteNode;
  RichEdit : TRxRichEdit;
begin

  // SMTPCli.MailMessage.Add( Padding + ' Note: ' + aNote.Name + ' ' + Padding );
  SMTPCli.MailMessage.Add( '' );

  case aNote.Kind of

    ntRTF : begin
      SMTPCli.MailMessage.AddStrings( aNote.Editor.Lines );
    end;

    ntTree : begin
      tNote := TTreeNote( aNote );
      // List := TStringList.Create;
      RichEdit := TRxRichEdit.Create( self );
      with RichEdit do
      begin
        parent := self;
        Visible := false;
        WordWrap := false;
      end;

      try
        myTreeNode := tNote.TV.Items.GetFirstNode;
        if myTreeNode.Hidden and CheckBox_ExcludeHiddenNodes.Checked then  // [dpv]
           myTreeNode := myTreeNode.GetNextNotHidden;
        while assigned( myTreeNode ) do
        begin
          myNoteNode := TNoteNode( myTreeNode.Data );
          if assigned( myNoteNode ) then
          begin
            SMTPCli.MailMessage.Add( '' );
            SMTPCli.MailMessage.Add( '+ Node ' + myNoteNode.Name + '  Level ' + inttostr( myTreeNode.Level ));

            myNoteNode.Stream.Position := 0;
            RichEdit.Lines.LoadFromStream( myNoteNode.Stream );
            SMTPCli.MailMessage.AddStrings( RichEdit.Lines );

          end;
          if CheckBox_ExcludeHiddenNodes.Checked then  // [dpv]
             myTreeNode := myTreeNode.GetNextNotHidden
          else
             myTreeNode := myTreeNode.GetNext;
        end;
      finally
        RichEdit.Free;
      end;

    end;

  end;

  SMTPCli.MailMessage.Add( '' );

end; // AddNoteToMailMessage

procedure TForm_Mail.SendEmail;
var
  s, buf : string;
  i, cnt : Integer;
  Lines : TStringList;
begin
  if ( not Verify ) then exit;

  OK_Click := true;

  MailOptions.AsPlainText := RB_PlainText.checked or ( not RB_RTF.ENabled );
  MailOptions.CCAddr := Combo_CC.Text;
  MailOptions.FromAddr := Edit_From.Text;
  MailOptions.SMTPPort := trim( Edit_Port.Text );
  MailOptions.SMTPServer := trim( Edit_SMTPServer.Text );
  MailOptions.Subject := trim( Edit_Subject.Text );
  MailOptions.TextCharSet := Combo_Charset.Text;
  MailOptions.ToAddr := Combo_To.Text;
  MailOptions.CCAddr := Combo_CC.Text;
  MailOptions.KeepLog := CheckBox_Log.Checked;
  MailOptions.FirstLine := trim( Edit_FirstLine.Text );

  SaveMailOptions( myINI_FN, MailOptions );

  GFLog.Active := MailOptions.KeepLog;

  BeforeMail;
  Lines := TStringList.Create;

  try
    try
      SMTPCli.Host := MailOptions.SMTPServer;
      SMTPCli.Port := MailOptions.SMTPPort;
      SMTPCli.SignOn := LocalHostName;
      SMTPCli.FromName := MailOptions.FromAddr;
      SMTPCli.HdrFrom := MailOptions.FromAddr;
      SMTPCli.Charset := MailOptions.TextCharSet;
      SMTPCli.HdrSubject := ExpandTokenLine( MailOptions.Subject );
      SMTPCli.HdrTo := MailOptions.ToAddr;

      SmtpCli.RcptName.Clear;

      buf := MailOptions.ToAddr;
      while TRUE do
      begin
        i := pos( ',', buf );
        if ( i = 0 ) then
        begin
          s := trim( buf );
          if ( s <> '' ) then
            SMTPCli.RcptName.Add( s );
          break;
        end
        else
        begin
          s := trim( copy( buf, 1, i-1 ));
          if ( s <> '' ) then
            SMTPCli.RcptName.Add( s );
          delete( buf, 1, i );
        end;
      end;

      for i := 0 to pred( SMTPCli.RcptName.Count ) do
        GFLog.Add( 'To ' + inttostr( succ( i )) + ' = ' + SMTPCli.RcptName[i] );

      buf := MailOptions.CCAddr;
      while TRUE do
      begin
        i := pos( ',', buf );
        if ( i = 0 ) then
        begin
          s := trim( buf );
          if ( s <> '' ) then
            SMTPCli.RcptName.Add( s );
          break;
        end
        else
        begin
          s := trim( copy( buf, 1, i-1 ));
          if ( s <> '' ) then
            SMTPCli.RcptName.Add( s );
          delete( buf, 1, i );
        end;
      end;

      SMTPCli.MailMessage.Clear;
      if MailOptions.AsPlainText then  // plain text in body of email
      begin
        if RB_Current.Checked then
        begin
          SMTPCli.MailMessage.Add( ExpandTokenLine( MailOptions.FirstLine ));
          AddNoteToMailMessage( myActiveNote );
        end
        else
        if RB_All.Checked then
        begin
          SMTPCli.MailMessage.Add( ExpandTokenLine( MailOptions.FirstLine ));
          if ( myNotes.Notes.Count > 0 ) then
          begin
            for cnt := 0 to pred( myNotes.Notes.Count ) do
            begin
              AddNoteToMailMessage( myNotes.Notes[cnt] );
              SMTPCli.MailMessage.Add( '' );
            end;
          end;
        end
        else
        begin
          // nothing
        end;

      end
      else // RTF file as attachment (body empty apart from itro line and sig)
      begin
        if RB_Current.Checked then
        begin
          s := extractfilepath( myINI_FN ) + MakeValidFileName( myCurNoteName, [], MAX_FILENAME_LENGTH ) + ext_RTF;
          GFLog.Add( 'Attaching: ' + s );
          myActiveNote.Editor.Lines.SaveToFile( s );
          SMTPCli.MailMessage.Add( ExpandTokenLine( MailOptions.FirstLine ));
          // SMTPCli.MailMessage.Add( Padding + ' Note: ' + myCurNoteName + ' ' + Padding );
          SMTPCli.EmailFiles.Add( s );
        end
        else
        if RB_File.Checked then
        begin
          SMTPCli.MailMessage.Add( ExpandTokenLine( MailOptions.FirstLine ));
          // SMTPCli.MailMessage.Add( Padding + ' Note: ' + myCurNoteName + ' ' + Padding );
          SMTPCli.EmailFiles.Add( myNotes.FileName );
          GFLog.Add( 'Attaching: ' + myNotes.FileName );
        end
        else
        begin
          ShowMessage( 'File format and note selection conflict. Bug?' );
        end;
      end;

      // see if we can attach a sig to the message
      if fileexists( mySIG_FN ) then
      begin
        Lines.Clear;
        Lines.LoadFromFile( mySIG_FN );
        SMTPCli.MailMessage.AddStrings( Lines );
      end;
      SMTPCli.MailMessage.Add( '' );

    except
        on E : Exception do
        begin
          messagedlg( E.Message, mtError, [mbOK], 0 );
          AfterMail;
          exit;
        end;
    end;
  finally
    Lines.Free;
  end;

  Label_Status.Caption := 'Connecting...';
  // Timer.Enabled := true;

  SMTPCli.Open;

end; // SendEmail

procedure TForm_Mail.SmtpCliHeaderLine(Sender: TObject; Msg: PChar;
  Size: Integer);
begin
  if UserFieldsAdded then exit;
  if StrLIComp(Msg, 'Subject:', 8) = 0 then
  begin
    StrCat(Msg, PChar( #13#10 + 'X-Mailer: ' +  MailOptions.XMailer ));
    if ( MailOptions.CCAddr <> '' ) then
      StrCat(Msg, PChar( #13#10 + 'CC: ' +  MailOptions.CCAddr ));
    UserFieldsAdded := true;
  end;

end;

procedure TForm_Mail.BeforeMail;
begin
  IsBusy := true;
  Button_OK.Enabled := false;
  Pages.Enabled := false;
  Button_Cancel.Caption := '&Abort';
  Button_Cancel.SetFocus;
  TimerTick := 0;

end; // BeforeMail

procedure TForm_Mail.AfterMail;
begin
  // Timer.Enabled := false;
  IsBusy := false;
  Button_OK.Enabled := true;
  Pages.Enabled := true;
  Button_Cancel.Caption := 'Close';
  UserFieldsAdded := false;
  HadError := false;
  TimerTick := 0;
  InHeader := true;

end; // AfterMail

procedure TForm_Mail.ShowException( Sender : TObject; E : Exception );
begin
  Label_Status.Caption := 'Error: ' + E.Message;
  if ( IsBusy and ( not( SmtpCli.State in [smtpReady,smtpAbort] ))) then
    SMTPCli.Abort;
  HadError := true;
end; // ShowException


procedure TForm_Mail.SmtpCliRequestDone(Sender: TObject;
  RqType: TSmtpRequest; Error: Word);
begin
  if ( Error <> 0 ) then
  begin
    if ( Error >= 1000 ) then
      Label_Status.Caption := 'Error ' + inttostr( Error ) +
        ' (' + WSocketErrorDesc( Error ) + ')'
    else
    if ( Error >= 400 ) then
      Label_Status.Caption := 'Error ' + inttostr( Error ) +
        ' (' + SMTPErrorDesc( Error ) + ')'
    else
      Label_Status.Caption := 'Error: code ' + inttostr( Error );
    AfterMail;
    exit;
  end;

  case RqType of
    smtpOpen : begin
      Label_Status.Caption := 'Sending...';
      SmtpCli.Mail;
    end;
    smtpMail : begin
      Label_Status.Caption := 'Closing connection...';
      SMTPCli.Quit;
    end;
    smtpQuit : begin
      Label_Status.Caption := 'Mail sent.';
      Aftermail;
    end;

  end;

end;

procedure TForm_Mail.TimerTimer(Sender: TObject);
begin
  if ( not IsBusy ) then exit;
  inc( TimerTick );
  if TimerTick >= MailOptions.TimeOut then
  begin
    if ( IsBusy and ( not( SmtpCli.State in [smtpReady,smtpAbort] ))) then
      SMTPCli.Abort;
    Label_Status.Caption := 'Connection timed out';
    AfterMail;
  end;
end;

procedure TForm_Mail.SmtpCliDisplay(Sender: TObject; Msg: String);
begin
  if ( not InHeader ) then exit;
  GFLog.Add( Msg );
  if ( length( Msg ) <= 2 ) then
    InHeader := false;
end;

procedure TForm_Mail.RB_FileClick(Sender: TObject);
begin
  if ( RB_all.Checked and RB_RTF.Checked ) then
  begin
    if ( assigned( myNotes ) and myNotes.HasExtendedNotes ) then
    begin
      Label_Status.Caption := 'Tree-type notes cannot be sent as RTF files and will be skipped.';
    end
    else
    begin
      Label_Status.Caption := 'Ready.'
    end;
  end
  else
  begin
    Label_Status.Caption := 'Ready.'
  end;
end;



procedure TForm_Mail.Button_HelpClick(Sender: TObject);
begin
  Application.HelpCommand( HELP_CONTEXT, self.HelpContext );
end;

end.
