unit fPIN4Av;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Mask, DBCtrlsEh, IniFiles;

type
  TfPINGet = class(TForm)
    Parol: TDBEditEh;
    Label2: TLabel;
    btnReady: TBitBtn;
    btnCancel: TBitBtn;
    ChB: TCheckBox;
    procedure btnReadyClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure ParolChange(Sender: TObject);
    procedure ChBClick(Sender: TObject);
    procedure InitPars(ParolPin: string);
    procedure SetResult(var UP: string);
    procedure ParolKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;

var
  fPINGet: TfPINGet;

implementation

{$R *.dfm}

procedure TfPINGet.InitPars(ParolPin: string);
begin
  Parol.Text := ParolPin;
end;

procedure TfPINGet.SetResult(var UP: string);
begin
  UP := Parol.Text;
end;

procedure TfPINGet.btnReadyClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfPINGet.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfPINGet.ParolChange(Sender: TObject);
begin
  if ChB.Checked then
    Parol.PasswordChar := #0
  else
    Parol.PasswordChar := '*';
end;

procedure TfPINGet.ChBClick(Sender: TObject);
begin
  if ChB.Checked then
    Parol.PasswordChar := #0
  else
    Parol.PasswordChar := '*';
  Parol.SetFocus;
end;

procedure TfPINGet.ParolKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) then
    btnReady.Click;
end;

end.

