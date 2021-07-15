unit uRestClient;

interface

uses
  Classes,
  SysUtils,
  DB,
  {$IFDEF SYNA} httpsend,  {$ENDIF}
  superobject,
  superdate,
  FuncPr,
  mRegInt,
  uGisun,
  uROCService,
  uUNDTO
  ;

const
  SECURE_TODES = 'SEC_TODES';
  SECURE_OAIS  = 'SEC_OAIS';

type
  TSecure = class;

  // ��������� ��������� � �������, ���������������� REST-�������
  TRestConfig = class
  private
    FBasePath : string;
    FDefHeader : TStringList;
    FOrgan     : string;
    FSec : TSecure;
  public
    property BasePath : string read FBasePath write FBasePath;
    // ��������� ��-���������
    property DefHeader : TStringList read FDefHeader write FDefHeader;
    // ��� ����������
    property Organ : string read FOrgan write FOrgan;
    property Secure : TSecure read FSec write FSec;

    constructor Create(DefH : TStringList = nil);
    destructor Destroy;
  end;

  // ��������� ����������� ������
  TSecure = class
  private
  public
    UseOAIS : Boolean;
    User : string;
    Pass : string;


  end;

  // ������������ ����� ���������� ������� � ���������� HTTP-��������
  TActInf = class
  private
  public
    Act      : TActKind;
    Oper     : TOperation;
    ResPath  : string;
    MsgType  : string;
    VarMeth4MakeBody : TMakePostBoby;
    Method   : string;
  end;

  // ������ � REST-�������
  TRestRequest = class
  private
    FCfg    : TRestConfig;
    // ��������� ������� �������
    FInputDS : TDataSet;
    FActInf   : TActInf;
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
    //FPersDataDTO : TPersDataDTO;

    function MakeAgreement(d : TDateTime) : string;
    function MakeCover(const MsgSrcCode : string; MsgTypeCode : string = uGisun.QUERY_INFO; DSet : string = '[15]') : string;
    function MakeReqInBody(const InDS: TDataSet): string;
  public
    property Params : TStringList read FParams write FParams;
    property Header : TStringList read FHeader write FHeader;
    property Body   : string read FBody write FBody;
    property InDS   : TDataSet read FInputDS write FInputDS;

    function SetActInf(ActKind: TActKind; MessageType: string; const Input : TDataSet; opCode : TOperation): TRestRequest;
    function MakeReqLine(Meth : string; Pars : TStringList = nil) : string;
    // ���������� ���� �������
    function MakeReqBody(const InDS : TDataSet; MessageType: string = ''): TRestRequest;

    constructor Create(Cfg : TRestConfig);
    destructor Destroy;
  end;

  // ����� REST-�������
  TRestResponse = class
  private
    FRestReq : TRestRequest;
    FRetAsSOAP : TRequestResult;
    FRetData : TStringStream;
    FRetCode : Integer;
    FRetMsg  : string;
    // ������ response �� ������ �������
    FSupObj  : ISuperObject;
    FCourt,
    FErrDS   : TDataSet;
    FOutDS   : TDataSet;
    FRespID  : string;

  public
    property Req : TRestRequest read FRestReq write FRestReq;
    property RetCode : integer read FRetCode write FRetCode;
    property RetMsg  : string read FRetMsg write FRetMsg;
    property RetAsSOAP : TRequestResult read FRetAsSOAP write FRetAsSOAP;
    property RetSO : ISuperObject read FSupObj write FSupObj;
    property OutDS : TDataSet read FOutDS write FOutDS;
    property ErrDS : TDataSet read FErrDS write FErrDS;
    property CourtDS : TDataSet read FCourt write FCourt;

    class function CreateCourts(IndexExp : string = '') : TDataSet;

    constructor Create;
    destructor Destroy;
  end;

  // ������ ��� ������ API (REST-Full)
  TRestClient = class
  private
    FHTTP : THTTPSend;
    FResp : TRestResponse;

    procedure SecReq(Req : TRestRequest; var URL : string; var Head : TStringList; var HTTPDoc : TStringStream);
    procedure SetRetCodes(const Meth, URL : string; Resp : TRestResponse);
  public
    property Response : TRestResponse read FResp;

    function CallApi(Req : TRestRequest) : TRestResponse;

    constructor Create;
    destructor Destroy;
  end;



implementation
uses
  ifpii_dbfunc;

// ������ ������� � REST-�������
constructor TRestConfig.Create(DefH : TStringList = nil);
begin
  inherited Create;
  DefHeader := DefH;
  Secure := TSecure.Create;
end;

//
destructor TRestConfig.Destroy;
begin
  FreeAndNil(FSec);
  inherited;
end;


// �������� ������� � REST-�������
constructor TRestRequest.Create(Cfg : TRestConfig);
begin
  inherited Create;
  FCfg := Cfg;
  FHeader := TStringList.Create;
  if (Assigned(Cfg.DefHeader)) then
    FHeader.AddStrings(Cfg.DefHeader);
  FActInf := TActInf.Create;
  //FPersDataDTO := TPersDataDTO.Create;
  FAttempts := 0;
end;

// ������ � REST-�������
destructor TRestRequest.Destroy;
begin
  FreeAndNil(FActInf);
  //FreeAndNil(FPersDataDTO);
  FreeAndNil(FHeader);
  inherited;
end;



// �������� ������ �� REST-�������
constructor TRestResponse.Create;
begin
  inherited Create;
end;

// ������ � REST-�������
destructor TRestResponse.Destroy;
begin
  inherited;
end;

// �������� DataSet ��� ������� ����
class function TRestResponse.CreateCourts(IndexExp : string = '') : TDataSet;
begin
  Result := dbCreateMemTable(
     'FIO,Char,100;' +
     'ID,Char,50;' +
     'TYPE_RESH,Integer;' +
     'DATE_RESH,Date;' +
     'SUD,Char,100;' +
     'TEXT,Char,100;' +
     'CANCEL,Logical;' +
     'REQUEST_ID,Char,50;', IndexExp);
end;


// ������ ��� ������ API (REST-Full)
constructor TRestClient.Create;
var
  i : Integer;
begin
  inherited;
  FHTTP := THTTPSend.Create;
  FHTTP.Protocol := '1.1';
end;

// ������ ��� ������ API (REST-Full)
destructor TRestClient.Destroy;
begin
  FreeAndNil(FHTTP);
  inherited;
end;


// ���������� ������������� ����� � ����������� �� ���� ���������
function TRestRequest.SetActInf(ActKind: TActKind; MessageType: string; const Input : TDataSet; opCode : TOperation): TRestRequest;
var
  s: string;
begin
  FActInf.Act     := ActKind;
  FActInf.MsgType :=  MessageType;
  FActInf.Oper    := opCode;
  case ActKind of
    akGetPersonalData : begin
      FActInf.ResPath := 'common/register';
      FActInf.VarMeth4MakeBody := nil;
      end;
    akGetPersonIdentif : begin
      FActInf.ResPath := 'common/person-identif';
      FActInf.VarMeth4MakeBody := nil;
      end;
    akBirth : begin
    // ������������� � ��������
      FActInf.ResPath  := 'zags/birth-certificate';
      FActInf.MsgType  := '0160';
      FActInf.VarMeth4MakeBody := TActBirth.BirthDS2Json;
      end;
    akAffiliation : begin
    // ������������� �� ������������ ���������
      FActInf.ResPath  := 'zags/affiliation-certificate';
      FActInf.MsgType  := '0200';
      FActInf.VarMeth4MakeBody := TActAffil.AffilDS2Json;
      end;
    akMarriage : begin
    // ������������� � �����
      FActInf.ResPath  := 'zags/marriage-certificate';
      FActInf.MsgType  := '0300';
      FActInf.VarMeth4MakeBody := TActMarr.MarrDS2Json;
      end;
    akDecease : begin
    // ������������� � ������
      FActInf.ResPath  := 'zags/decease-certificate';
      FActInf.MsgType  := '0400';
      FActInf.VarMeth4MakeBody := TActDecease.DeceaseDS2Json;
      end;
    akDivorce : begin
    // ������������� � ����������� �����
      FActInf.ResPath  := 'zags/divorce-certificate';
      FActInf.MsgType  := '0500';
      FActInf.VarMeth4MakeBody := TActDvrc.DvrcDS2Json;
      end;
    akNameChange : begin
    // ������������� � ����� ���
      FActInf.ResPath  := 'zags/name-change-certificate';
      FActInf.MsgType  := '0700';
      FActInf.VarMeth4MakeBody := TActChgName.ChgNameDS2Json;
      end;
  end;
  Result := Self;
end;



// ������������ ������ ������� (ReqLine) � REST-�������
function TRestRequest.MakeReqLine(Meth : string; Pars : TStringList = nil) : string;
var
  s : string;
begin
  FFullURL := FCfg.BasePath + FActInf.ResPath;
  Result := s;
end;

// ��������� agreement ��� GET-�������
function TRestRequest.MakeAgreement(d : TDateTime) : string;
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
    IssDate  := DelphiDateTimeToISO8601Date(d);
    ExpDate  := DelphiDateTimeToISO8601Date(IncMonth(d, 24));;
    Insp     := '"��������� ������"';
    LeadInsp := ',"��������� ���������� ������"';

    AssgnPers := Format('"assignee_persons":[%s%s]', [Insp, LeadInsp]);

    Result := Format('"agreement":{"operator_info":"%s","target":"%s","rights":[%s],"issue_date":"%s","expiry_date": "%s",%s}',
      [OperInf, Targ, Rights, IssDate, ExpDate, AssgnPers]);
  except
  end;

end;


function TRestRequest.MakeCover(const MsgSrcCode : string; MsgTypeCode : string = QUERY_INFO; DSet : string = '[15]') : string;
var
  MsgT,
  Agree,
  MsgId : string;
  d : TDateTime;
begin
  Result := '';
  try
    d     := Now;
    MsgId := NewGUID;
    MsgT  := DelphiDateTimeToISO8601Date(d);
    if (FActInf.Oper = opGet) then begin
      Agree := Format(',%s,"dataset":%s', [MakeAgreement(d), DSet]);
    end else begin
      Agree := '';
    end;
    //Result := Format('"cover":{"message_id":"%s","message_type":{"code":"%s","type":-2},"message_source":{"code":"%s","type":80},%s,"dataset":%s}', [MsgId, MsgTypeCode, MsgSrcCode, MakeAgreement, DSet]);
    Result := Format('"cover":{"message_id":"%s","message_type":{"code":"%s","type":-2},"message_time":"%s","message_source":{"code":"%s","type":80}%s}', [MsgId, MsgTypeCode, MsgT, MsgSrcCode, Agree]);
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
      // ��� GET-��������
      s := '"request":{';
      sPersDat := '';
      sIN := '';

      with InDS do begin
        First;
        if (FActInf.Act = akGetPersonIdentif) then begin
        //������ �� ��������� �� (�� �.�.�.)
          sR := Format('"surname":"%s","name":"%s","sname":"%s","bdate":"%s"', [FieldByName('FAMILIA').AsString, FieldByName('NAME').AsString, FieldByName('OTCH').AsString, FieldByName('DATER').AsString]);
          Last;
        end
        else begin

          iPD := 0;
          iIN := 0;
          while not Eof do begin
            if (FieldByName('IS_PERSON').AsBoolean = True) then begin
            // ������ ������������ ������
              iPD := iPD + 1;
              if (iPD > 1) then
                sPersDat := sPersDat + ',';
              sPersDat := sPersDat + Format('{"request_id":"%s","identif_number":"%s"}', [FieldByName('REQUEST_ID').AsString, FieldByName('IDENTIF').AsString])
            end
            else begin
            // ������ ��
              iIN := iIN + 1;
              if (iIN > 1) then
                sIN := sIN + ',';
              sIN := sIN + Format('{"request_id":"%s","sex":{"code":"%s","type":32},"birth_day":"%s"}', [FieldByName('REQUEST_ID').AsString, FieldByName('POL').AsString, FieldByName('DATER').AsString])
            end;
            Next;
          end;

          if (iPD > 0) then
            sR := '"person_request":[' + sPersDat + ']';
          if (iIN > 0) then begin
            if (Length(sR) > 0) then
              sR := sR + ',';
            sR := sR + '"identif_request":[' + sIN + ']';
          end;

        end;
        s := s + sR + '}';
      end;
    end
    else
      // ��� POST-��������
      s := FActInf.VarMeth4MakeBody(InDS);

  except
  end;
  Result := s;
end;

// ������������ ���� �������
function TRestRequest.MakeReqBody(const InDS : TDataSet; MessageType: string = ''): TRestRequest;
var
  s: string;
begin
  try
    if (Length(MessageType) <= 0) then
      MessageType := FActInf.MsgType;
    Body := MakeCover(FCfg.Organ, MessageType);
    s := MakeReqInBody(InDS);
    Body := Format('{%s,%s}',[Body, s]);

    Result := Self;
  except
  end;
end;



// �������/���������� ���� �������
procedure TRestClient.SecReq(Req : TRestRequest; var URL : string; var Head : TStringList; var HTTPDoc : TStringStream);
var
  sUTF : UTF8String;
begin
  URL := Req.FFullURL;
  Head := TStringList.Create;
  Head.AddStrings(Req.FHeader);
  sUTF := AnsiToUtf8(Req.Body);

  if (Req.FCfg.Secure.UseOAIS = True) then begin


  end else begin

  end;
  HTTPDoc := TStringStream.Create(sUTF);

end;


// ��������� ����� �������� ����� HTTPSend
procedure TRestClient.SetRetCodes(const Meth, URL: string; Resp: TRestResponse);
var
  IsGet, Ret: Boolean;
  nErr: Integer;
  sErr: string;
  ErrList, SORet: ISuperObject;
  StreamDoc: TStringStream;
begin
  sErr := '';
  IsGet := Iif(Resp.FRestReq.FActInf.Oper = opGet, True, False);
  Resp.RetAsSOAP := rrError;

  Ret := FHTTP.HTTPMethod(Meth, URL);
  FHTTP.Document.SaveToFile('BodyUNResp');
  StreamDoc := TStringStream.Create('');
  StreamDoc.Seek(0, soBeginning);
  StreamDoc.CopyFrom(FHTTP.Document, 0);
  Resp.FRetData := StreamDoc;
  try
    if (Ret = True) then begin
      nErr := FHTTP.ResultCode;
      if (IsGet) then begin
      // ���� ��� ������, ������ ������ 200
        if (FHTTP.ResultCode = 200) then
          nErr := 0;
      end
      else begin
      // ���� ��� ������, ������ ������ 201
        if (FHTTP.ResultCode = 201) then
          nErr := 0;
      end;

    // JSON-����� ������ (???) ���� ������ ��� ���������� ����������

      if (nErr = 0) then begin
      // ���� ��� ������
        Resp.RetAsSOAP := rrAfterError;
        try
            SORet := SO(Utf8Decode(StreamDoc.DataString));
            Resp.FSupObj := SORet;
            Resp.FRespID := SORet.S['cover.message_id'];
            if (IsGet) then
              Resp.FRetAsSOAP := rrOk
            else begin
              // ���� ��� 201 �������� ��������� ������
              ErrList := SORet.O['response'].O['error_list'];
              if (Assigned(ErrList) and (Not ErrList.IsType(stNull))) then begin
              // ������ ������ �������� �������
                nErr := 1100;
                sErr := '������ ��������� JSON-������';
              end else
                Resp.FRetAsSOAP := rrOk;
            end;
        except
          // ������ JSON ��������� �����, ������ �����, XML ???
            nErr := 1200;
            sErr := '������ ��������� JSON-������';
            raise Exception.Create(sErr);
        end;
      end
      else begin
        // HTTP-error, ���-�� �� ��� � ������� �� �������
        // nErr ��� �������� FHTTP.ResultCode
        // � Document ����� ���� ���� �� ������
        // Resp.RetAsSOAP ��� ��������  rrError;
        sErr := FHTTP.ResultString + CRLF + StreamDoc.DataString;
      end;
    end
    else begin
      // �����-�� ������� ��������
      nErr := FHTTP.sock.LastError;
      sErr := FHTTP.sock.LastErrorDesc;
      Resp.RetAsSOAP := rrFault;
      raise Exception.Create(sErr);
    end;
  except
    on E: Exception do begin
      if (sErr <> '') then
        sErr := E.Message;
    end;
  end;
  Resp.FRetCode := nErr;
  Resp.FRetMsg  := sErr;
end;

// ���������� ������� � ������� � ���������� ������ � ��������� ��������
function TRestClient.CallApi(Req : TRestRequest) : TRestResponse;
var
  Ret : Boolean;
  sURL : string;
  sUTF : UTF8String;
  SecHead : TStringList;
  DocStream : TStringStream;
begin
  Result := TRestResponse.Create;
  FHTTP.Clear;
  FHTTP.MimeType := 'application/json;charset=UTF-8';

  SecReq(Req, sURL, SecHead, DocStream);
  FHTTP.Headers.AddStrings(SecHead);
  FHTTP.Document.LoadFromStream(DocStream);

  FHTTP.Document.SaveToFile('BodyUN');

  Result.FRestReq := Req;
  SetRetCodes('POST', sURL, Result);
  FResp := Result;
end;


end.
