{ GF ver 1.0 }
unit GFTipDlgForm;
interface
{$I gf_base.inc}

uses
  Windows, Messages, SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, gf_misc, gf_miscvcl;

type
  TGFTipForm = class(TForm)
    TipPanel: TPanel;
    ShowChk: TCheckBox;
    Button_OK: TButton;
    Button_Next: TButton;
    Button_Prev: TButton;
    TipLbl: TLabel;
    Image_Hint: TImage;
    TipTitleLbl: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button_NextClick(Sender: TObject);
    procedure Button_PrevClick(Sender: TObject);
    procedure Button_OKClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    Tips : TStrings;
    CurrentTip : integer;
    CRLF : string;
    IsRandom : boolean;
    OriginalCaptionText : string;
  end;

var
  GFTipForm: TGFTipForm;

implementation

{$R *.DFM}

procedure TGFTipForm.FormCreate(Sender: TObject);
begin
  if _TahomaFontInstalled then
    Font.Name := 'Tahoma';
  Tips := TStringList.Create;
end;

procedure TGFTipForm.FormDestroy(Sender: TObject);
begin
  Tips.Free;
end;

procedure TGFTipForm.Button_NextClick(Sender: TObject);
var
  i : integer;
begin
  if IsRandom then
  begin
    Randomize;
    i := Round(Random(Tips.Count-1));
    if (i = CurrentTip) and (Tips.Count > 1) then Inc(i);
      CurrentTip := i;
  end
  else
  begin
    if CurrentTip < Tips.Count-1 then
      Inc(CurrentTip)
    else
      CurrentTip := 0;
  end;
  TipLbl.Caption := Tips[CurrentTip];

  Caption := Format( '%s - %d of %d', [OriginalCaptionText,CurrentTip+1,Tips.Count] );
end;

procedure TGFTipForm.Button_PrevClick(Sender: TObject);
begin
  if CurrentTip = 0 then
    CurrentTip := Tips.Count-1
  else
    Dec(CurrentTip);
  TipLbl.Caption := Tips[CurrentTip];
  Caption := Format( '%s - %d of %d', [OriginalCaptionText,CurrentTip+1,Tips.Count] );
end;

procedure TGFTipForm.Button_OKClick(Sender: TObject);
begin
  Close;
end;

procedure TGFTipForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ( key = 27 ) and ( shift = [] ) then
  begin
    key := 0;
    Close;
  end;
end;

end.
