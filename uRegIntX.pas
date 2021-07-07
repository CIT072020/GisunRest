unit uRegIntX;

interface

{$I Task.inc}

uses
  Classes,
  DB,
  Variants,
  superobject,
  superdate,
  SasaIniFile,
  uROCService,
  mGisun,
  mRegInt,
  wsGisun,
  uGisun,
  uRestClient,
  uUNDTO;

const
//=== *** === === *** === === *** === === *** === =>
  UN_INI_NAME  = '..\GISUN\GISUN.ini';
  UN_IN_FILES  = '..\GISUN\GISUN_Input.ini';
  UN_OUT_FILES = '..\GISUN\GISUN_Output.ini';

  // ������ INI-�����
  SCT_REST = 'REST';



//=== *** === === *** === === *** === === *** === <=

  // ������ ������ � ��������� ���������
  EM_DEFLT = 0;
  EM_SOAP  = 1;
  EM_JSON  = 2;
  EM_MIXED = 3;

  // ��������� �� �������
  ERR_NO_AUTH = '����� �� ��������������';


type
  TExchangeMode = (emDefault, emSOAP, emJSON, emMIXED);

   //��������� ��� ������ � ��������� ���������
  TRegIntX = class(TRegInt)
  private
    FExchMode : Integer;
    FConfig   : TRestConfig;
    FIniIn,
    FIniOut,
    FIni : TSasaIniFile;
    FRestClient : TRestClient;

    function SetErrData(const Act: TActKind; Resp: TRestResponse) : Integer;
    function SetOutDS(const Act: TActKind; slPar : TStringList; Resp: TRestResponse): Integer;
    function GetResponse : TRestResponse;
  public
    property Config : TRestConfig read FConfig write FConfig;
    property ApiClient : TRestClient read FRestClient write FRestClient;
    property Response : TRestResponse read GetResponse;

    // ��������� ������������ ������, ��, �������������� ��
    function Get(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet; const Dokument: TDataSet = nil;
    slPar: TStringList = nil; ExchMode: Integer = EM_DEFLT): TRestResponse;

    // ������ ��� ������ � REST-���������
    function GetRest(ActKind: TActKind; MessageType: string; const InDS, Dokument: TDataSet; var Output, Error: TDataSet; slPar:TStringList): TRestResponse;

    // �������� ���������� � �������
    function Post(RequestMessageId: string; ActKind: TActKind; MessageType: string; const Input: TDataSet; var Error: TDataSet; ExchMode: Integer = EM_DEFLT): TRestResponse;
    function PostRest(RequestMessageId: string; ActKind: TActKind; MessageType: string; const InDS : TDataSet; var Error: TDataSet): TRestResponse;

    constructor Create(MessageSource: string; Ini : TSasaIniFile = nil);
    destructor Destroy;

  end;


implementation

uses
  SysUtils,
  kbmMemTable,
  FuncPr;


constructor TRegIntX.Create(MessageSource: string; Ini : TSasaIniFile = nil);
var
  IsOAIS : Boolean;
  SecMode : string;
  i : Integer;
  DefH : TStringList;
begin
  inherited Create(MessageSource);

  DefH := TStringList.Create;
  DefH.Add('Reg-auth-username:PASSPORT_USER');
  DefH.Add('Reg-auth-password:user_password');
  Config := TRestConfig.Create(DefH);
  Config.Secure.UseOAIS := False;
  FIni := Ini;
  FExchMode := EM_SOAP;
  if (Assigned(Ini)) then begin
    FExchMode := Ini.ReadInteger(SCT_REST, 'EXCHG_MODE', EM_SOAP);
    Config.BasePath := Ini.ReadString(SCT_REST, 'BASE_URI', '');
    SecMode := Ini.ReadString(SCT_REST, 'SECURE_MODE', SECURE_OAIS);
    Config.Secure.UseOAIS := Iif(SecMode = SECURE_OAIS, True, False);
  end;
  Config.Organ := MessageSource;
  ApiClient := TRestClient.Create;

  //FGetSrv := TGetSrvX.Create;
end;


destructor TRegIntX.Destroy;
begin
  FreeAndNil(FRestClient);
  FreeAndNil(FConfig);
  inherited;
end;

// �������� ��������� ����� �� �������
function TRegIntX.GetResponse : TRestResponse;
begin
  Result := FRestClient.Response;
end;

// ����������� DataSet � ������ ������
function TRegIntX.SetErrData(const Act: TActKind; Resp: TRestResponse): Integer;
var
  ErrsInSO: Integer;
begin
  ErrsInSO := 0;
  if (Resp.RetAsSOAP = rrOk) then begin
    Resp.ErrDS := nil;
  end
  else begin
    Resp.ErrDS := CreateErrorTable;
    if (Resp.RetAsSOAP = rrBeforeError) then begin
      AddOneErr(Resp.ErrDS, IntToStr(Resp.RetCode), Resp.RetMsg);
    end
    else begin
      // ������� �� ������� ������ �� ���������
      ErrsInSO := TPersData.SObj2DSErr(Resp.RetSO, Resp.ErrDS);
      if (ErrsInSO <= 0) then
        AddOneErr(Resp.ErrDS, IntToStr(Resp.RetCode), Resp.RetMsg);
    end;

  end;
  Result := ErrsInSO;
end;







// ��� GET-�������� ���������� �������� DataSet
function TRegIntX.SetOutDS(const Act: TActKind; slPar : TStringList; Resp: TRestResponse): Integer;
var
  i, iMax, nErr: Integer;
  OnePD, SOArrPD: ISuperObject;
begin
  nErr := 0;
  try
    SOArrPD := Resp.RetSO.O['response'].O['personal_data'];
    if (Assigned(SOArrPD) and (SOArrPD.IsType(stArray))) then begin

      iMax := SOArrPD.AsArray.Length - 1;
      for i := 0 to iMax do begin
        OnePD := SOArrPD.AsArray.O[i].O['data'];
        Resp.RetDS.Append;
        try
          if (Act = akGetPersonIdentif) then begin
        // ������ ������� ����������� �� �� ���
            Resp.RetDS.FieldByName('IS_PERSON').AsBoolean := False;
            TPersData.SObj2DSPersData(OnePD, Resp.RetDS, False);
          end
          else begin
        // ������ ������� ������������ ������
            Resp.RetDS.FieldByName('IS_PERSON').AsBoolean := True;
            TPersData.SObj2DSPersData(OnePD, Resp.RetDS);

          end;
        finally
          Resp.RetDS.Post;
        end;
      end;
    end
    else begin
    // ������ �����������

    end;

    SOArrPD := Resp.RetSO.O['response'].O['identif_number'];
    if (Assigned(SOArrPD) and (SOArrPD.IsType(stArray))) then begin
      iMax := SOArrPD.AsArray.Length - 1;

      for i := 0 to iMax do begin
    // ������ ������� ����������������� ����� ��
        OnePD := SOArrPD.AsArray.O[i];
        Resp.RetDS.Append;
        //Resp.RetDS.FieldByName('REQUEST_ID').AsString := OnePD.S['request_id'];
        Resp.RetDS.FieldByName('NEW_IDENTIF').AsString := OnePD.S['data'];
        Resp.RetDS.FieldByName('IS_PERSON').AsBoolean := False;
        Resp.RetDS.Post;
      end;

    end;

  except
    nErr := 1;
  end;

end;















// ��������� �� ��������
function TRegIntX.Get(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet; const Dokument: TDataSet = nil;
    slPar: TStringList = nil; ExchMode: Integer = EM_DEFLT): TRestResponse;
var
  nErr : Integer;
  ResObs : TRequestResult;
begin
  if (ExchMode = EM_DEFLT) then
    ExchMode := FExchMode;
  if (ExchMode = EM_SOAP) then begin
    ResObs := inherited Get(ActKind, MessageType, Input, Output, Error, Dokument, slPar);
    Result := TRestResponse.Create;
    Result.RetAsSOAP := ResObs;
  end
  else begin
    // ����� REST-������
    Result := GetRest(ActKind, MessageType, Input, Dokument, Output, Error, slPar);
    if (Result.RetAsSOAP = rrOk) then begin
       Result.RetDS := CreateOutputTable(akGetPersonalData);
       Output := Result.RetDS;
       nErr := SetOutDS(ActKind, slPar, Result);
     end;
    SetErrData(ActKind, Result);
    Error := Result.ErrDS;
  end;
end;

// ������ � ������� ����������
function TRegIntX.Post(RequestMessageId: string; ActKind: TActKind; MessageType: string; const Input: TDataSet; var Error: TDataSet; ExchMode: Integer = EM_DEFLT): TRestResponse;
var
  ResObs : TRequestResult;
begin
  if (ExchMode = EM_DEFLT) then
    ExchMode := FExchMode;
  if (ExchMode = EM_SOAP) then begin
    ResObs := inherited Post(RequestMessageId, ActKind, MessageType, Input, Error);
    Result := TRestResponse.Create;
    Result.RetAsSOAP := ResObs;
  end
  else begin
    // ����� REST-������
    Result := PostRest(RequestMessageId, ActKind, MessageType, Input, Error);
  end;
end;




// ��������� ������������ ������, ��, �������������� �� ����� REST-������
function TRegIntX.GetRest(ActKind: TActKind; MessageType: string; const InDS, Dokument: TDataSet; var Output, Error: TDataSet; slPar:TStringList): TRestResponse;
var
  i : Integer;
  s : string;
  Req : TRestRequest;

begin
  // ������������ ������� �� ������
  Req := TRestRequest.Create(Self.Config);
  Req.SetActInf(ActKind, MessageType, InDS, slPar);

  Req.MakeReqLine('POST', slPar);

  // ������������ ���� �������
  Req.MakeReqBody(InDS, MessageType);

  Result := ApiClient.CallApi(Req);
end;

// �������� ������ ����� REST-������
function TRegIntX.PostRest(RequestMessageId: string; ActKind: TActKind; MessageType: string; const InDS : TDataSet; var Error: TDataSet): TRestResponse;
var
  i : Integer;
  s : string;
  Req : TRestRequest;
begin
  // ������������ ������� �� ������
  Req := TRestRequest.Create(Self.Config);
  Req.SetActInf(ActKind, MessageType, InDS);

  Req.MakeReqLine('POST');

  // ������������ ���� �������
  Req.MakeReqBody(InDS, MessageType);

  Result := ApiClient.CallApi(Req);
end;




end.
