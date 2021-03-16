
program AppROC;

uses
  ExceptionLog,
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  uROCService in '..\uROCService.pas',
  uROCDTO in '..\uROCDTO.pas',
  uROCNSI in '..\uROCNSI.pas',
  fPIN4Av in 'fPIN4Av.pas' {fPINGet},
  uROCExchg in '..\uROCExchg.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfPINGet, fPINGet);
  Application.Run;
end.
