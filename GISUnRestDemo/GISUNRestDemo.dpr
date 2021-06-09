program GISUNRestDemo;

uses
  ExceptionLog,
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  fPIN4Av in 'fPIN4Av.pas' {fPINGet},
  uRegIntX in '..\uRegIntX.pas',
  uRestClient in '..\RestClient\uRestClient.pas',
  uUNDTO in '..\uUNDTO.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfPINGet, fPINGet);
  Application.Run;
end.
