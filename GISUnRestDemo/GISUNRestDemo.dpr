program GISUNRestDemo;

uses
  ExceptionLog,
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  fPIN4Av in 'fPIN4Av.pas' {fPINGet},
  uUNDTO in '..\uUNDTO.pas',
  uUNRegIntX in '..\uUNRegIntX.pas',
  uUNRestClient in '..\uUNRestClient.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfPINGet, fPINGet);
  Application.Run;
end.
