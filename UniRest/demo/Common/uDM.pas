unit uDM;

interface

uses
  SysUtils, Classes, RestClient;

const
  CONTEXT_PATH = 'http://localhost:3000/';
  RESRC_PATH   = 'person/';
    
type
  TDM = class(TDataModule)
    RestClient: TRestClient;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

end.
