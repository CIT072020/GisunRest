unit uRestClient;

interface

uses
  Classes,
  SysUtils,
  {$IFDEF SYNA} httpsend,  {$ENDIF}
  uUNDTO
  ;

type

  // ������������ ����� ���������� ������� � ���������� HTTP-��������
  TAktTypes2Meth = class
  private
  public
    Method : string;
    ResPath : string;
  end;

  // ������ � REST-�������
  TRestRequest = class
  private
    FMethod : string;
    // Summary:
    //     The Resource URL to make the request against. Tokens are substituted with UrlSegment parameters and match by name.
    //     Should not include the scheme or domain. Do not include leading slash. Combined with RestClient.BaseUrl to assemble final URL:
    //     {BaseUrl}/{Resource} (BaseUrl is scheme + domain, e.g. http://example.com)
    FResource : string;
    FParams : TStringList;
    FHeader : TStringList;
    FBody   : string;
    // Summary:
    //     Timeout in milliseconds to be used for the request. This timeout value overrides
    //     a timeout set on the RestClient.
    FTimeout : Integer;
    // Summary:
    //     The number of milliseconds before the writing or reading times out. This timeout
    //     value overrides a timeout set on the RestClient.
    FReadWriteTimeout : Integer;
    // Summary:
    //     How many attempts were made to send this Request?
    // Remarks:
    //     This number is incremented each time the RestClient sends the request.
    FAttempts : integer;
    FPersDataDTO : TPersDataDTO;
  public
    property Params : TStringList read FParams write FParams;
    property Header : TStringList read FHeader write FHeader;
    property Body : string read FBody write FBody;

    function MakeReqLine(Meth : string; Pars : TStringList) : string;

    constructor Create(DefHeader : TStringList);
    destructor Destroy;
  end;

  // ����� REST-�������
  TRestResponse = class
  private
    FRestReq : TRestRequest;
  end;

  // ������ ��� ������ API (REST-Full)
  TRestClient = class
  private
    FHTTP   : THTTPSend;

  public
    function CallApi(Req : TRestRequest) : TRestResponse;

    constructor Create;
    destructor Destroy;
  end;

  // ��������� ��������� � �������, ���������������� REST-�������
  TRestConfig = class
  private
    FBasePath : string;
    FDefHeader : TStringList;
  public
    property BasePath : string read FBasePath write FBasePath;
    property DefHeader : TStringList read FDefHeader write FDefHeader;
  end;


implementation

// ������ � REST-�������
constructor TRestRequest.Create(DefHeader : TStringList);
begin
  inherited Create;
  FHeader := TStringList.Create;
  FHeader.AddStrings(DefHeader);
  FPersDataDTO := TPersDataDTO.Create;
  FAttempts := 0;
end;

// ������ � REST-�������
destructor TRestRequest.Destroy;
begin
  FreeAndNil(FPersDataDTO);
  FreeAndNil(FHeader);
  inherited;
end;

// ������������ ������ ������� (ReqLine) � REST-�������
function TRestRequest.MakeReqLine(Meth : string; Pars : TStringList) : string;
var
  s : string;

begin
  Result := s;
end;


function TRestRequest.MakeAgreement(dsDoc: TDataSet; StreamDoc: TStringStream): Boolean;
var
  OperInf,
  Targ,
  Rights,
  IssDate,
  ExpDate,
  AssgnPers,
  Insp, LeadInsp,
  s: string;
begin
  try
    OperInf  := '����������� �����';
    Targ     := '����������� ������������ ������';
    Rights   := '201,703,208,480,481,482,490,491,527,528,252,465,466,516,517';
    IssDate  := '2021-06-07T13:22:09.619+03:00';
    ExpDate  := '2023-06-07T13:22:09.619+03:00';
    Insp     := '"��������� ������"';
    LeadInsp := ',"��������� ���������� ������"';

    AssgnPers := Format('"assignee_persons":[%s%s]', [Insp, LeadInsp]);

    Result := Format('"agreement":{"operator_info":"%s","target":"%s","rights":[%s],"issue_date":"%s","expiry_date": "%s",%s}',
      [OperInf, Targ, Rights, IssDate, ExpDate, AssgnPers]);
  except
  end;

end;


function TRestRequest.MakeCover(dsDoc: TDataSet; StreamDoc: TStringStream): Boolean;
var
  MsgId,
  MsgTypeCode,
  MsgSrcCode,
  DSet,
  s: string;
begin
  try
  MsgId       := '4D7961DF-3057-4587-A498-5D995C733D80';
  MsgTypeCode := '88';
  MsgSrcCode  := '7689';
  DSet        := '[15]';

  Result := Format('"cover":{"message_id":"%s","message_type":{"code":"%s","type":-2},"message_source":{"code":"%s","type":80},%s,"dataset":%s}',
    [MsgId, MsgTypeCode, MsgSrcCode, MakeAgreement, Dset]);
  except
  end;

end;



function TRestRequest.MakeReqRequest4OneIN(const ReqId, IdNum: string): string;
begin
  try
    ReqId := '1';
    IdNum := '7120691A001PB3';
    Result := Format('{"request_id":"%s","identif_number":"%s"}', [ReqId, IdNum]);
  except
  end;
end;


function TRestRequest.MakeReqRequestByIN(dsDoc: TDataSet; StreamDoc: TStringStream): string;
var
  ReqId,
  IdNum,
  s: string;
begin
  try
  ReqId := '1';
  IdNum :=
  MsgSrcCode  := '7689';
  DSet        := '[15]';

  Result := Format('{"request_id":"%s","identif_number":"%s"}', []);

  except
  end;

end;

function TRestRequest.MakeReqRequestByFIO(dsDoc: TDataSet; StreamDoc: TStringStream): Boolean;
var
  SurName,
  Name,
  SName,
  BDate,
  s: string;
begin
  try
  SurName := '������';
  Name    := '����';
  SName   := '��������';
  BDate   := '20120511';

  Result := Format('"surname":"%s","name":"%s","sname":"%s","bdate":"%s"', [SurName, Name, SName, BDate]);

  except
  end;

end;


function TRestRequest.MakeReqRequest(dsDoc: TDataSet; StreamDoc: TStringStream): Boolean;
var
  MsgTypeCode,
  MsgSrcCode,
  DSet,
  s: string;
begin
  try
  MsgTypeCode := '88';
  MsgSrcCode  := '7689';
  DSet        := '[15]';

  Result := Format('"cover":{"message_type":{"code":"%s","type":-2},"message_source":{"code":"%s","type":80},%s,"dataset":%s}',
    [MsgTypeCode, MsgSrcCode, MakeAgreement, Dset]);
  except
  end;

end;



// ������ ��� ������ API (REST-Full)
constructor TRestClient.Create;
var
  i : Integer;
begin
  inherited;
  FHTTP := THTTPSend.Create;
end;

// ������ ��� ������ API (REST-Full)
destructor TRestClient.Destroy;
begin
  FreeAndNil(FHTTP);
  inherited;
end;








function TRestClient.CallApi(Req : TRestRequest) : TRestResponse;
begin
  Result := TRestResponse.Create;
end;



end.
