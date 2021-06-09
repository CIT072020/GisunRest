unit uRestClient;

interface

uses
  Classes,
  SysUtils,
  DB,
  {$IFDEF SYNA} httpsend,  {$ENDIF}
  mRegInt,
  uUNDTO
  ;

type
  TRestConfig = class;

  // Соответствие типов документов методам и параметрам HTTP-запросов
  TActInf = class
  private
  public
    Act      : TActKind;
    Oper     : TOperation;
    ResPath  : string;
    Method   : string;
  end;

  // Запрос к REST-серверу
  TRestRequest = class
  private
    FCfg    : TRestConfig;
    FMethod : string;
    FFullURL : string;
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
    FActInf   : TActInf;
    FPersDataDTO : TPersDataDTO;

    function MakeAgreement : string;
    function MakeCover(InDS: TDataSet): string;
    function MakeReqInBody(const InDS: TDataSet): string;
  public
    property Params : TStringList read FParams write FParams;
    property Header : TStringList read FHeader write FHeader;
    property Body : string read FBody write FBody;

    function SetActInf(ActKind: TActKind; MessageType: string; const Input, Dokument: TDataSet; var Output, Error: TDataSet; slPar:TStringList): TRestRequest;
    function MakeReqLine(Meth : string; Pars : TStringList) : string;
    // Подготовка тела запроса
    function MakeBody(const InDS, Dokument: TDataSet; slPar:TStringList): TRestRequest;

    constructor Create(Cfg : TRestConfig);
    destructor Destroy;
  end;

  // Ответ REST-сервера
  TRestResponse = class
  private
    FRestReq : TRestRequest;
  end;

  // Клиент для вызова API (REST-Full)
  TRestClient = class
  private
    FHTTP   : THTTPSend;

  public
    function CallApi(Req : TRestRequest) : TRestResponse;

    constructor Create;
    destructor Destroy;
  end;

  // Настройки обращений к ресурсу, предоставляющему REST-сервисы
  TRestConfig = class
  private
    FBasePath : string;
    FDefHeader : TStringList;
  public
    property BasePath : string read FBasePath write FBasePath;
    property DefHeader : TStringList read FDefHeader write FDefHeader;
  end;


implementation

// Создание запроса к REST-серверу
constructor TRestRequest.Create(Cfg : TRestConfig);
begin
  inherited Create;
  FCfg := Cfg;
  FHeader := TStringList.Create;
  FHeader.AddStrings(Cfg.DefHeader);
  FActInf := TActInf.Create;
  FPersDataDTO := TPersDataDTO.Create;
  FAttempts := 0;
end;

// Запрос к REST-серверу
destructor TRestRequest.Destroy;
begin
  FreeAndNil(FActInf);
  FreeAndNil(FPersDataDTO);
  FreeAndNil(FHeader);
  inherited;
end;


// Заполнение дполнительных полей в зависимости от типа документа
function TRestRequest.SetActInf(ActKind: TActKind; MessageType: string; const Input, Dokument: TDataSet; var Output, Error: TDataSet; slPar: TStringList): TRestRequest;
var
  s: string;
begin
  FActInf.Act := ActKind;
  if (ActKind = akGetPersonalData) OR (ActKind = akGetPersonIdentif) then begin
    FActInf.Oper := opGet;
  end
  else begin
    FActInf.Oper := opPost;

  end;
  case ActKind of
    akGetPersonalData:
      FActInf.ResPath := 'common/register';
    akGetPersonIdentif:
      FActInf.ResPath := 'common/person-identif';
  end;
  Result := Self;
end;



// Формирование строки запроса (ReqLine) к REST-серверу
function TRestRequest.MakeReqLine(Meth : string; Pars : TStringList) : string;
var
  s : string;
begin
  FFullURL := FCfg.BasePath + FResource;
  Result := s;
end;


function TRestRequest.MakeAgreement : string;
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
    OperInf  := 'Организация адрес';
    Targ     := 'верификация персональных данных';
    Rights   := '201,703,208,480,481,482,490,491,527,528,252,465,466,516,517';
    IssDate  := '2021-06-07T13:22:09.619+03:00';
    ExpDate  := '2023-06-07T13:22:09.619+03:00';
    Insp     := '"инспектор Иванов"';
    LeadInsp := ',"начальник инспектора Петров"';

    AssgnPers := Format('"assignee_persons":[%s%s]', [Insp, LeadInsp]);

    Result := Format('"agreement":{"operator_info":"%s","target":"%s","rights":[%s],"issue_date":"%s","expiry_date": "%s",%s}',
      [OperInf, Targ, Rights, IssDate, ExpDate, AssgnPers]);
  except
  end;

end;


function TRestRequest.MakeCover(InDS: TDataSet): string;
var
  MsgId,
  MsgTypeCode,
  MsgSrcCode,
  DSet,
  s: string;
begin
  Result := '';
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


function TRestRequest.MakeReqInBody(const InDS: TDataSet): string;
var
  iIN, iPD: Integer;
  MsgTypeCode, MsgSrcCode, DSet, sPersDat, sIN, sR, s: string;
begin
  s := '';
  try
    if (FActInf.Oper = opGet) then begin
      s := ',"request":{';
      sPersDat := '';
      sIN := '';

      with InDS do begin
        First;
        if (FActInf.Act = akGetPersonIdentif) then begin
        //Запрос на получение ИН (по ф.и.о.)
          sR := Format('"surname":"%s","name":"%s","sname":"%s","bdate":"%s"', [FieldByName('').AsString, FieldByName('').AsString, FieldByName('').AsString, FieldByName('').AsString]);
          Last;
        end
        else begin

          iPD := 0;
          iIN := 0;
          while not Eof do begin
            if (FieldByName('').AsBoolean = True) then begin
            // Запрос персональных данных
              iPD := iPD + 1;
              if (iPD = 1) then
                sPersDat := '"person_request":['
              else
                sPersDat := sPersDat + ',';
              sPersDat := sPersDat + Format('{"request_id":"%s","identif_number":"%s"}', [FieldByName('').AsString, FieldByName('').AsString])
            end
            else begin
            // Запрос ИН
              iIN := iIN + 1;
              if (iIN = 1) then
                sIN := '"person_request":['
              else
                sIN := sIN + ',';
              sIN := sIN + Format('{"request_id":"%s","sex":{"code":"%s","type":32},"birth_day":"%s"}', [FieldByName('').AsString, FieldByName('').AsString])
            end;
            Next;
          end;

          if (iPD > 0) then
            sR := sPersDat;
          if (iIN > 0) then begin
            if (Length(sR) > 0) then
              sR := sR + ',';
            sR := sR + sIN;
          end;

        end;
        s := s + sR + '}';
      end;
    end;

  except
  end;
  Result := s;
end;

// Сформировать тело запроса
function TRestRequest.MakeBody(const InDS, Dokument: TDataSet; slPar:TStringList): TRestRequest;
var
  s: string;
begin
  try
    Body   := MakeCover(InDS) + MakeReqInBody(InDS);
    Result := Self;
  except
  end;
end;



// Клиент для вызова API (REST-Full)
constructor TRestClient.Create;
var
  i : Integer;
begin
  inherited;
  FHTTP := THTTPSend.Create;
end;

// Клиент для вызова API (REST-Full)
destructor TRestClient.Destroy;
begin
  FreeAndNil(FHTTP);
  inherited;
end;








function TRestClient.CallApi(Req : TRestRequest) : TRestResponse;
var
  sUTF : UTF8String;
  DocStream : TStringStream;
begin
  Result := TRestResponse.Create;
  FHTTP.Clear;
  FHTTP.Headers.AddStrings(Req.FHeader);
  sUTF := AnsiToUtf8(Req.Body);
  DocStream.Create(sUTF);
  FHTTP.Document.LoadFromStream(DocStream);
  FHTTP.HTTPMethod('POST', Req.FFullURL);
end;



end.
