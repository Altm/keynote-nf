unit kn_Hyperlink;
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
 <marekjed@users.sourceforge.net>

************************************************************ *)

interface

uses
  Windows, Messages, SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, gf_misc, kn_Info,
  kn_Const, Mask, ToolEdit, BrowseDr,
  kn_LocationObj, FileCtrl;

type
  TForm_Hyperlink = class(TForm)
    Button_OK: TButton;
    Button_Cancel: TButton;
    RG_LinkType: TRadioGroup;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    LB_Text: TLabel;
    Edit_Text: TEdit;
    Edit_URL: TEdit;
    Btn_File: TButton;
    Btn_Dir: TButton;
    OpenDlg: TOpenDialog;
    DirDlg: TdfsBrowseDirectoryDlg;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure RG_LinkTypeClick(Sender: TObject);
    procedure Btn_FileClick(Sender: TObject);
    procedure Btn_DirClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    LinkText : string;
    LinkTarget : string;
    LinkType : TLinkType;

  end;


function GuessLinkType( const s : string ) : TLinkType;

implementation

{$R *.DFM}

function GuessLinkType( const s : string ) : TLinkType;
begin
  result := lnkFile;
  // try most common URL types, but don't auto-paste
  // if the string doesn't appear to contain any.
  if ( pos( 'http', s ) = 1 ) or
     ( pos( 'www', s ) = 1 ) or
     ( pos( 'telnet', s ) = 1 ) or
     ( pos( 'news', s ) = 1 ) or
     ( pos( 'ftp', s ) = 1 ) then
  begin
    result := lnkURL;
  end
  else
  if (( pos( '@', s ) > 0 ) or ( pos( 'mailto', s ) = 1 )) then
  begin
    result := lnkEmail;
  end
  else
  if ( pos( 'file', s ) = 1 ) or
     ( pos( ':\', s ) = 2 ) then
  begin
    result := lnkFile;
  end;
end; // GuessLinkType

procedure TForm_Hyperlink.FormCreate(Sender: TObject);
var
  lt : TLinkType;
begin

  LinkText := '';
  LinkTarget := '';
  LinkType := low( TLinkType );

  OpenDlg.Filter := FILTER_FILELINK;

  DirDlg.Selection := extractfilepath( application.exename );
  OpenDlg.InitialDir := extractfilepath( application.exename );

  if ( _KNTLocation.FileName = '' ) then
  begin
    // KNTLocation is not available (has not been marked)
    // so do not include it among options
    for lt := low( lt ) to pred( high( lt )) do
    begin
      RG_LinkType.Items.Add( LINK_TYPES[lt] );
    end;
  end
  else
  begin
    // KNTLocation is available, so include it
    for lt := low( lt ) to high( lt ) do
    begin
      RG_LinkType.Items.Add( LINK_TYPES[lt] );
    end;
  end;

end; // Create

procedure TForm_Hyperlink.FormActivate(Sender: TObject);
var
  FromClip : boolean;
begin
  OnActivate := nil;

  FromClip := false;
  if ( LinkTarget = '' ) then
  begin
    LinkTarget := trim( ClipboardAsString );
    FromClip := true;
  end;

  LinkType := GuessLinkType( LinkTarget );
  if ( LinkType = lnkFile ) then
  begin
    if (( pos( KNTLOCATION_MARK_OLD, LinkTarget ) > 0 ) or ( pos( KNTLOCATION_MARK_NEW, LinkTarget ) > 0 )) then
    begin
      LinkType := lnkKNT;
    end
    else
    begin
      if ( FromClip and ( not ( fileexists( LinkTarget ) or directoryexists( LinkTarget )))) then
        LinkTarget := '';
    end;
  end;

  Edit_URL.Text := LinkTarget;
  Edit_Text.Text := LinkText;

  if ord( LinkType ) >= RG_LinkType.Items.Count then
    LinkType := low( LinkType );

  RG_LinkType.ItemIndex := ord( LinkType );

  RG_LinkTypeClick( RG_LinkType );
  RG_LinkType.OnClick := RG_LinkTypeClick;

  try
    Edit_URL.SetFocus;
  except
  end;

end; // ACTIVATE

procedure TForm_Hyperlink.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ( ModalResult = mrOK ) then
  begin
    LinkType := TLinkType( RG_LinkType.ItemIndex );
    LinkText := trim( Edit_Text.Text );
    LinkTarget := Edit_URL.Text;
  end;
end; // CloseQuery


procedure TForm_Hyperlink.RG_LinkTypeClick(Sender: TObject);
begin
  case TLinkType( RG_LinkType.ItemIndex ) of
    lnkURL : begin
      Btn_File.Enabled := false;
      Btn_Dir.Enabled := false;
      Edit_URL.ReadOnly := false;
      Edit_URL.Color := clWindow;
    end;
    lnkEmail : begin
      Btn_File.Enabled := false;
      Btn_Dir.Enabled := false;
      Edit_URL.ReadOnly := false;
      Edit_URL.Color := clWindow;
    end;
    lnkFile : begin
      Btn_File.Enabled := true;
      Btn_Dir.Enabled := true;
      Edit_URL.ReadOnly := false;
      Edit_URL.Color := clWindow;
    end;
    lnkKNT : begin
      Btn_File.Enabled := false;
      Btn_Dir.Enabled := false;
      Edit_URL.Color := clBtnFace;
      Edit_URL.ReadOnly := true; // cannot edit KeyNote locations directly
      Edit_URL.Text := _KNTLocation.DisplayTextLong;
    end;
  end;
end; // RG_LinkTypeClick

procedure TForm_Hyperlink.Btn_FileClick(Sender: TObject);
begin
  if fileexists( Edit_URL.Text ) then
    OpenDlg.Filename := Edit_URL.Text;
  if OpenDlg.Execute then
  begin
    Edit_URL.Text := OpenDlg.Filename;
  end;
end;

procedure TForm_Hyperlink.Btn_DirClick(Sender: TObject);
begin
  if ( directoryexists( Edit_URL.Text ) or fileexists( Edit_URL.Text )) then
    DirDlg.Selection := extractfilepath( Edit_URL.Text );
  if DirDlg.Execute then
  begin
    Edit_URL.Text := DirDlg.Selection;
  end;
end;

end.
