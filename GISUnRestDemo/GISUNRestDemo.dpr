program GISUNRestDemo;

uses
  ExceptionLog,
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  fPIN4Av in 'fPIN4Av.pas' {fPINGet},
  uUNDTO in '..\..\Lais7\OAIS\uUNDTO.pas',
  uUNRegIntX in '..\..\Lais7\OAIS\uUNRegIntX.pas',
  uUNRestClient in '..\..\Lais7\OAIS\uUNRestClient.pas',
  uUNSecure in '..\..\Lais7\OAIS\uUNSecure.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfPINGet, fPINGet);
  Application.Run;
end.
