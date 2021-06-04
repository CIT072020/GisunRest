unit uRestClient;

interface

uses
  Classes,
  SysUtils,
 {$IFDEF SYNA} httpsend  {$ENDIF}
  ;

type

  // Соответствие типов документов методам и параметрам HTTP-запросов
  TAktTypes2Meth = class
  private
  public
    Method : string;
    ResPath : string;
  end;

  // Запрос к REST-серверу
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
  public
    property Params : TStringList read FParams write FParams;
    property Header : TStringList read FHeader write FHeader;
    property Body : string read FBody write FBody;

    function MakeReqLine(Meth : string; Pars : TStringList) : string;

    constructor Create(DefHeader : TStringList);
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


// Запрос к REST-серверу
constructor TRestRequest.Create(DefHeader : TStringList);
begin
  inherited Create;
  FHeader := TStringList.Create;
  FHeader.AddStrings(DefHeader);
  FAttempts := 0;
end;

// Запрос к REST-серверу
destructor TRestRequest.Destroy;
begin
  FreeAndNil(FHeader);
  inherited;
end;

// Формирование строки запроса (ReqLine) к REST-серверу
function TRestRequest.MakeReqLine(Meth : string; Pars : TStringList) : string;
var
  s : string;

begin
  Result := s;
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
begin
  Result := TRestResponse.Create;
end;



end.
