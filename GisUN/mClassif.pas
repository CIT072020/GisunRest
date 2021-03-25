
unit mClassif;
interface
uses
   Controls, SysUtils, wsClassif, mGisun, Classes, Forms, TypInfo, SoapHTTPClient, XSBuiltIns, InvokeRegistry, FuncPr,
   fShowErrorGISUN, uTypes, Dialogs, DB, NativeXML;

type
   TClassifInterface=class(TObject)
   private
      //SOAP
      FRIO: THTTPRIO;
      //сервис
      FService: ClassifWs;
      //адрес сервиса
      FUrl: string;
      FProxy: string;
      //
      FMessageSource: string;
      FTypeMessageSource: integer;
      //
      FFaultError: string;
      //
      FError: TDataSet;
      FLog: TStringList;
      FIsDebug: Boolean;
      FUser:String;
      FPasw:String;
      procedure SetLog(const Value: TStringList);
      procedure SetIsDebug(const Value: Boolean);
   private
      //события SOAP
      procedure RIOAfterExecute(const MethodName: string; SOAPResponse: TStream);
      procedure RIOBeforeExecute(const MethodName: string; var SOAPRequest: WideString);
      procedure RIOHTTPWebNodeReceivingData(Read, Total: Integer);
      //получение ссылки не сервис
      function GetService: ClassifWs;
      //
      procedure SetUrl(Value: string);
      procedure ClearError;
      procedure CopyErrorList(error_list: ErrorList);
   public

      constructor Create(HTTPRIO:THTTPRIO);
      destructor Destroy; override;
      //ИНТЕРФЕЙС:
      //создание объектов
      procedure SetUserNameToken(User:String;Psw:String);
      function CreateId: string;
      function CreateMessageCover(MessageType, ParentId: string; nTypeClass,nTypeSource:Integer): MessageCover;
      function CreateClassifier(Code: string; ClassifierType: Integer): Classifier;
      function CreateDateTime(DateTime: TDateTime): TXSDateTime;

      //обработка исключений
      procedure HandleException(E: sysutils.Exception; Log: TStrings);
      //запись исключения в error-dataset
      function  FindNodeXML(x:TXMLNode; strFind:String):TXMLNode;
      procedure FaultDetailToError(strFaultDetail:String; var strMessage:String);
      //вызов методов

      //ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ ТЕСТОВ:
      //вывод в лог
      procedure MessageCoverToLog(Log: TStrings; Cover: MessageCover);
      procedure ErrorListToLog(Log: TStrings; error_list: ErrorList);
      //преобразование в строку
      function GetClassifierString(C: Classifier): string;
      function GetDateString(Date: TXSDate): string;
      function GetDateTimeString(DateTime: TXSDateTime): string;
      //другие вспомогательные
      function GetClassifierLexema(C: Classifier): string;
      function GetClassifierCode(C: Classifier): string;
   public
      property MessageSource: string read FMessageSource write FMessageSource;
      property TypeMessageSource: integer read FTypeMessageSource write FTypeMessageSource;
      property Service: ClassifWs read GetService;
      property Url: string read FUrl write SetUrl;
      property Proxy: string read FProxy write FProxy;
      property FaultError: string read FFaultError;
      property Error: TDataSet read FError;
      property Log :TStringList read FLog write SetLog;
      property IsDebug : Boolean read FIsDebug write SetIsDebug;
      procedure ShowError;
      procedure ShowErrorDataSet;
      procedure AddToLog(s:String);

      // запросить измения по типу классификатора
      function RequestChangeClassif(nType:Integer; dDateFrom:TDateTime; dsResult:TDataSet):Boolean;
      // запросить измения по классификатору АТЕ
      function RequestChangeATE(dDateFrom: TDateTime; dsResult:TDataSet): Boolean;
      // запросить классификатор АТЕ по диапазону ID
      function RequestATEInterval(nFrom,nTo:Integer; dsResult:TDataSet): Boolean;
      function RequestATEMaxID: Integer;

   end;

   {
const
   //Типы классификаторов
   //-51 Статус авторизации
   //-50 Статус аутентификации
   //-40 Статус истории приема почты
   //-20 Ошибки в сообщениях вебсервисов
   ctStatus     = -18;  //Статус лица
   //-17 Входные атрибуты запроса
   //-16 Состав запрашиваемых данных
   //-12 Сигналы пользователя
   //-11 Типы операций (репозитарий)
   //-10 Связи семьи
   //-5 Орган установки системы
   //-3 Уровни доступа
   //-2 Типы системных документов
   //-1 Системные параметры
   //1 Области
   //6 Типы изменения гражданства
   //7 Населенные пункты
   ctCountry    =   8;  //Страны
   ctMVD        =  24;  //Органы МВД
   //29 Районы
   ctPol        =  32;  //Пол
   //34 Улицы
   ctTypeCityGit=  35;  //Типы населенных пунктов  места жительства
   ctTypeCity   =  68;  //Типы населенных пунктов  места рождения и места смерти
   ctDocType    =  37;  //Типы документов
   //38 Типы улиц
   ctZags       =  80;  //Органы ЗАГС
   ctDeathCause =  81;  //Причины смерти
   ctActType    =  82;  //Типы актовых записей
   }
implementation
uses
   mRegInt, mSecHeader, uGisun;

{ TClassifInterface }

constructor TClassifInterface.Create(HTTPRIO:THTTPRIO);
begin
   //Список последних ошибок
   FError:=CreateErrorTable;
   //SOAP
   if HTTPRIO=nil then begin
     FRIO:=THTTPRIO.Create(nil);
   end else begin
     FRIO:=HTTPRIO;
   end;
   FRIO.OnAfterExecute:=RIOAfterExecute;
   FRIO.OnBeforeExecute:=RIOBeforeExecute;
   FRIO.HTTPWebNode.OnReceivingData:=RIOHTTPWebNodeReceivingData;
   FLog:=TStringList.Create;
   FIsDebug:=true;
   FUser:='';
   FPasw:='';
   FTypeMessageSource:=0;
end;

destructor TClassifInterface.Destroy;
begin
   FService:=nil;
   //!!!!!!! почему то возникал AV
   //FRIO.Free;
   FError.Close;
   FError.Free;
   FLog.Free;
   inherited;
end;

procedure TClassifInterface.RIOAfterExecute(const MethodName: string; SOAPResponse: TStream);
var
   XMLDoc:TNativeXML;
begin
   //вывод текста запроса
   XMLDoc:=TNativeXML.Create;
   try
      XMLDoc.LoadFromStream(SOAPResponse);

      CheckHash(XMLDoc,true);

      XMLDoc.SaveToFile(ExtractFilePath(Application.ExeName)+'SOAPResponse_Classif.xml');
   finally
      XMLDoc.Free;
   end;
end;

procedure TClassifInterface.RIOBeforeExecute(const MethodName: string; var SOAPRequest: WideString);
var
   S: Utf8String;
   n,m: Integer;
//   st:TStringStream;
   strErr:String;
begin

   CreateETSP(SOAPRequest,strErr,true);

   try
     S:=Utf8Encode(SOAPRequest);
     n:=Pos('<Password>',s);
     m:=Pos('</Password>',s);
     if (n>0) and (m>0) then begin
       s:=Copy(s,1,n+9)+'*****'+Copy(s,m,Length(s));
     end;
     MemoWrite(ExtractFilePath(Application.ExeName)+'SOAPRequest_Classif.xml', S);
   except

   end;
   //вывод текста запроса
   {
   StringList:=TStringList.Create;
   try
      StringList.Text:=SOAPRequest;
      StringList.SaveToFile(ExtractFilePath(Application.ExeName)+'SOAPRequest_Classif.xml');
   finally
      StringList.Free;
   end;
   }
end;

function TClassifInterface.GetService: ClassifWs;
begin
   if FService=nil then begin
      FService:=GetClassifWs(FUrl, FProxy, FRIO);
      //try except end !!! когда нет связи
   end;
   Result:=FService;
end;

{
function TGisunInterface.GetPersonalData(const registerRequest: register_request; var registerResponse: register_response; Log: TStrings): Boolean;
var
   I: Integer;
begin
   ClearError;
   Result:=False;
   try
      if GetService<>nil then begin
         Log.Add('');
         Log.Add('Выполняется запрос на получение данных из регистра:');
         Log.Add('');
         MessageCoverToLog(Log, registerRequest.cover);
         Log.Add('');
         Log.Add(Format('Запрос на получение пресональных данных person_request (%d):', [Length(registerRequest.request.person_request)]));
         for I:=Low(registerRequest.request.person_request) to High(registerRequest.request.person_request) do begin
            Log.Add('');
            Log.Add(Format('person_request/request_id     =%s', [registerRequest.request.person_request[I].request_id]));
            Log.Add(Format('person_request/identif_number =%s', [registerRequest.request.person_request[I].identif_number]));
            DocumenttoLog(Log, registerRequest.request.person_request[I].document, 'person_request/document/');
         end;
         Log.Add('');
         Log.Add(Format('Запрос на генерацию нового идентификационного номера  (%d):', [Length(registerRequest.request.identif_request)]));
         for I:=Low(registerRequest.request.identif_request) to High(registerRequest.request.identif_request) do begin
            Log.Add('');
            Log.Add(Format('identif_request/request_id =%s', [registerRequest.request.identif_request[I].request_id]));
            Log.Add(Format('identif_request/sex        =%s', [GetClassifierString(registerRequest.request.identif_request[I].sex)]));
            Log.Add(Format('identif_request/birth_day  =%s', [registerRequest.request.identif_request[I].birth_day]));
         end;
         registerResponse:=FService.getPersonalData(registerRequest);
         Log.Add('');
         Log.Add('Получен ответ:');
         Log.Add('');
         MessageCoverToLog(Log, registerResponse.cover);
         Log.Add('');
         Log.Add(Format('Список персональных данных personal_data (%d):', [Length(registerResponse.response.personal_data)]));
         for I:=Low(registerResponse.response.personal_data) to High(registerResponse.response.personal_data) do begin
            Log.Add('');
            Log.Add(Format('personal_data/request_id =%s', [registerResponse.response.personal_data[I].request_id]));
            PersonalDataToLog(Log, registerResponse.response.personal_data[I].data, 'personal_data/');
         end;
         Log.Add('');
         Log.Add(Format('Список идентификационных номеров identif_number (%d):', [Length(registerResponse.response.identif_number)]));
         for I:=Low(registerResponse.response.identif_number) to High(registerResponse.response.identif_number) do begin
            Log.Add('');
            Log.Add(Format('identif_number/request_id =%s', [registerResponse.response.identif_number[I].request_id]));
            Log.Add(Format('identif_number/data       =%s', [registerResponse.response.identif_number[I].data]));
         end;
         Result:=True;
      end
      else begin
         Log.Add('ОШИБКА: GetService=nil');
      end;
   except
      on E: Exception do begin
         HandleException(E, Log);
      end;
   end;
end;
}
function TClassifInterface.CreateClassifier(Code: string; ClassifierType: Integer): Classifier;
begin
   //Классификатор
   Result:=Classifier.Create;
   //Кодовое значение
   Result.code:=Code;
   //Тип классификатора
   Result.type_:=ClassifierType;
   //Список лексем
   //Result.lexema/
   //Result.lexema/Text
   //Язык передаваемого значения
   //Result.lexema/lang
   //Признак активности
   //Result.active
   //Дата формирования
   //Result.begin_date
   //Дата упразднения
   //Result.end_date
end;

function TClassifInterface.CreateDateTime(DateTime: TDateTime): TXSDateTime;
begin
   Result:=TXSDateTime.Create;
   Result.AsDateTime:=DateTime;
end;

function TClassifInterface.CreateId: string;
var
   GUID: TGUID;
begin
   CReateGUID(GUID);
   //Внутренний идентификатор
   Result:=GUIDToString(GUID);
end;

function TClassifInterface.CreateMessageCover(MessageType, ParentId: string; nTypeClass,nTypeSource:Integer): MessageCover;
begin
   //Сопроводительная информация к сообщению
   Result:=MessageCover.Create;
   //Идентификатор сообщения
   Result.message_id:=CreateId;
   //Тип сообщения
   Result.message_type:=CreateClassifier(MessageType, nTypeClass);
   //Время отправки сообщения
   Result.message_time:=CreateDateTime(Now);
   //Источник сообщения
   Result.message_source:=CreateClassifier(FMessageSource, nTypeSource);  // ??? !!!
   //Идентификатор сообщения, для которого текущее является ответом
   Result.parent_message_id:=ParentId;
end;

procedure TClassifInterface.MessageCoverToLog(Log: TStrings; Cover: MessageCover);
begin
   if cover<>nil then begin
      AddToLog('/cover/');
      AddToLog(Format('/cover/message_id        =%s', [cover.message_id]));
      AddToLog(Format('/cover/message_type      =%s', [GetClassifierString(cover.message_type)]));
      AddToLog(Format('/cover/message_time      =%s', [GetDateTimeString(cover.message_time)]));
      AddToLog(Format('/cover/message_source    =%s', [GetClassifierString(cover.message_source)]));
      AddToLog(Format('/cover/parent_message_id =%s', [cover.parent_message_id]));
   end
   else begin
      AddToLog('/cover/ =nil');
   end;
end;

procedure TClassifInterface.ErrorListToLog(Log: TStrings; error_list: ErrorList);
var
   I: Integer;
   ErrorList: TStringList;
begin
   ErrorList:=TStringList.Create;
   ErrorList.Add('error_code.code;error_code.text;error_place;wrong_value;correct_value;check_name');
   try
      AddToLog(Format('Список ошибок error_list (%d):', [Length(error_list)]));
      for I:=Low(error_list) to High(error_list) do begin
         AddToLog(Format('error_code=%s', [GetClassifierString(error_list[I].error_code)]));
         AddToLog(Format('error_place=%s', [error_list[I].error_place]));
         AddToLog(Format('wrong_value=%s', [error_list[I].wrong_value]));
         AddToLog(Format('correct_value=%s', [error_list[I].correct_value]));
         AddToLog(Format('check_name=%s', [error_list[I].check_name]));
         ErrorList.Add(Format('"%s";"%s";"%s";"%s";"%s";"%s"', [GetClassifierCode(error_list[I].error_code), GetClassifierLexema(error_list[I].error_code), error_list[I].error_place, error_list[I].wrong_value, error_list[I].correct_value, error_list[I].check_name]));
      end;
      ErrorList.SaveToFile('error_list.csv');
   finally
      ErrorList.Free;
   end;
end;

const
   MapBool: array [Boolean] of string=('False', 'True');

{
procedure TClassifInterface.PersonalDataToLog(Log: TStrings; Data: PersonalData; Add: string);
var
   I: Integer;
begin
   if Data<>nil then begin
      AddToLog(Format(Add+'access         =%s', [GetClassifierString(Data.access)]));
      AddToLog(Format(Add+'identif        =%s', [Data.identif]));
      AddToLog(Format(Add+'last_name      =%s', [Data.last_name]));
      AddToLog(Format(Add+'last_name_bel  =%s', [Data.last_name_bel]));
      AddToLog(Format(Add+'last_name_lat  =%s', [Data.last_name_lat]));
      AddToLog(Format(Add+'name_          =%s', [Data.name_]));
      AddToLog(Format(Add+'name_bel       =%s', [Data.name_bel]));
      AddToLog(Format(Add+'name_lat       =%s', [Data.name_lat]));
      AddToLog(Format(Add+'patronymic     =%s', [Data.patronymic]));
      AddToLog(Format(Add+'patronymic_bel =%s', [Data.patronymic_bel]));
      AddToLog(Format(Add+'patronymic_lat =%s', [Data.patronymic_lat]));
      AddToLog(Format(Add+'sex            =%s', [GetClassifierString(Data.sex)]));
      AddToLog(Format(Add+'birth_day      =%s', [Data.birth_day]));
      AddToLog(Format(Add+'birth_place/country_b    =%s', [GetClassifierString(Data.birth_place.country_b)]));
      AddToLog(Format(Add+'birth_place/area_b       =%s', [Data.birth_place.area_b]));
      AddToLog(Format(Add+'birth_place/area_b_bel   =%s', [Data.birth_place.area_b_bel]));
      AddToLog(Format(Add+'birth_place/region_b     =%s', [Data.birth_place.region_b]));
      AddToLog(Format(Add+'birth_place/region_b_bel =%s', [Data.birth_place.region_b_bel]));
      AddToLog(Format(Add+'birth_place/type_city_b  =%s', [GetClassifierString(Data.birth_place.type_city_b)]));
      AddToLog(Format(Add+'birth_place/city_b       =%s', [Data.birth_place.city_b]));
      AddToLog(Format(Add+'birth_place/city_b_bel   =%s', [Data.birth_place.city_b_bel]));
      AddToLog(Format(Add+'birth_place/city_b_ate   =%s', [GetClassifierString(Data.birth_place.city_b_ate)]));
      AddToLog(Format(Add+'citizenship    =%s', [GetClassifierString(Data.citizenship)]));
      AddToLog(Format(Add+'status         =%s', [GetClassifierString(Data.status)]));
      AddToLog(Format('Список адресов addresses (%d):', [Length(Data.addresses)]));
      for I:=Low(Data.addresses) to High(Data.addresses) do begin
         AddToLog('');
         AddressToLog(Log, Data.addresses[I], Add+'addresses/');
      end;
      AddToLog(Format('Список документов documents (%d):', [Length(Data.documents)]));
      for I:=Low(Data.documents) to High(Data.documents) do begin
         AddToLog('');
         DocumenttoLog(Log, Data.documents[I], Add+'documents/');
      end;
      AddToLog(Format('Список родственных связей family (%d):', [Length(Data.family)]));
      for I:=Low(Data.family) to High(Data.family) do begin
         AddToLog('');
         FamilyToLog(Log, Data.family[I], Add+'family/');
      end;
      AddToLog(Format('Список ? deaths (%d):', [Length(Data.deaths)]));
      for I:=Low(Data.deaths) to High(Data.deaths) do begin
         AddToLog('');
         DeathToLog(Log, Data.deaths[I], Add+'deaths/');
      end;
      AddToLog(Format('Список ? citizenships (%d):', [Length(Data.citizenships)]));
      for I:=Low(Data.citizenships) to High(Data.citizenships) do begin
         AddToLog('');
         CitizenshipToLog(Log, Data.citizenships[I], Add+'citizenships/');
      end;
      AddToLog(Format('Список ? photos (%d):', [Length(Data.photos)]));
      for I:=Low(Data.photos) to High(Data.photos) do begin
      end;
   end
   else begin
      AddToLog(Add+' =nil');
   end;
end;
}

function TClassifInterface.GetClassifierString(C: Classifier): string;
var
   I: Integer;
begin
   if C=nil then begin
      Result:='nil';
   end
   else begin
      Result:=Format('type: %d, code: %s', [C.type_, C.code]);
      for I:=Low(C.lexema) to High(C.lexema) do begin
         Result:=Format('%s, Text: %s, lang: %s', [Result, C.lexema[I].Text, C.lexema[I].lang]);
      end;
   end;
end;

function TClassifInterface.GetDateString(Date: TXSDate): string;
begin
   if Date=nil then begin
      Result:='nil';
   end
   else begin
      Result:=FormatDateTime('yyyy.mm.dd', Date.AsDate);
   end;
end;

function TClassifInterface.GetDateTimeString(DateTime: TXSDateTime): string;
begin
   if DateTime=nil then begin
      Result:='nil';
   end
   else begin
      Result:=FormatDateTime('yyyy.mm.dd hh:nn', DateTime.AsDateTime);
   end;
end;

procedure TClassifInterface.HandleException(E: sysutils.Exception; Log: TStrings);
begin
   if E is WsException then begin
      AddToLog('');       
      AddToLog('!Исключение WsException');
      AddToLog(Format('FaultActor  =%s', [WsException(E).FaultActor]));
      AddToLog(Format('FaultCode   =%s', [WsException(E).FaultCode]));
      AddToLog(Format('FaultDetail =%s', [WsException(E).FaultDetail]));
      AddToLog(Format('Message     =%s', [WsException(E).Message]));
      AddToLog(Format('ClassName   =%s', [WsException(E).ClassName]));
      MessageCoverToLog(Log, WsException(E).cover);
      ErrorListToLog(Log, WsException(E).error_list);
      //обработка исключения
      CopyErrorList(WsException(E).error_list);
   end
   else if E is ERemotableException then begin
      AddToLog('');
      AddToLog('!Исключение ERemotableException');
      AddToLog(Format('FaultActor  =%s', [ERemotableException(E).FaultActor]));
      AddToLog(Format('FaultCode   =%s', [ERemotableException(E).FaultCode]));
      AddToLog(Format('FaultDetail =%s', [ERemotableException(E).FaultDetail]));
      AddToLog(Format('Message     =%s', [ERemotableException(E).Message]));
      AddToLog(Format('ClassName   =%s', [ERemotableException(E).ClassName]));

      //обработка исключения
      FFaultError:=ERemotableException(E).Message;
      FaultDetailToError(ERemotableException(E).FaultDetail,FFaultError);
   end
   //!!! ESOAPHTTPException
   else begin
      AddToLog('');
      AddToLog('!Исключение Exception');
      AddToLog(Format('Message   =%s', [E.Message]));
      AddToLog(Format('ClassName =%s', [E.ClassName]));
      //обработка исключения
      FFaultError:=E.Message;
   end;
end;

function TClassifInterface.FindNodeXML(x:TXMLNode; strFind:String):TXMLNode;
var
  n,m:Integer;
  xx,xxx:TXMLNode;
begin
  Result:=nil;
  for n:=0 to x.NodeCount-1 do begin
    xx:=x.Nodes[n];
    if Pos(strFind,LowerCase(Utf8ToAnsi(xx.Name))) >0 then begin
      Result:=xx;
    end else begin
      for m:=0 to xx.NodeCount-1 do begin
        xxx:=xx.Nodes[m];
        if Pos(strFind,LowerCase(Utf8ToAnsi(xxx.name))) >0 then begin
          Result:=xxx;
          break;
        end else begin
          xxx:=FindNodeXML(xx.Nodes[m],strFind);
          if xxx<>nil then begin
            Result:=xxx;
            break;
          end;
        end;
      end;
    end;
    if Result<>nil then break;
  end;
end;

procedure TClassifInterface.FaultDetailToError(strFaultDetail:String; var strMessage:String);
var
  i,j:Integer;
  XMLDoc:TNativeXML;
  s1,s2,s3,ss:String;
  XMLNode,XMLNodeErr,nd:TXMLNode;
begin
  if strFaultDetail='' then begin
    if Trim(strMessage)=''
      then strMessage:='Неизвестная ошибка';
      {
      then FError.AppendRecord(['--','Неизвестная ошибка','','','',''])
      else FError.AppendRecord(['--',strMessage,'','','','']);
      }
    exit;
  end;
  XMLDoc:=TNativeXML.Create;
  XMLDoc.ReadFromString(AnsiToUtf8(strFaultDetail));
//  XMLNode:=XMLDoc.Root.FindNode(AnsiToUtf8('detail'));
//  if XMLNode<>nil then begin
    XMLNode:=FindNodeXML(XMLDoc.Root,'error_list');
//  end;
  if XMLNode<>nil then begin
    for i:=0 to XMLNode.NodeCount-1 do begin
      XMLNodeErr:=XMLNode.Nodes[i];
      s1:=Utf8ToAnsi(XMLNodeErr.Name);   //  типа: 'ns2:error'
      j:=Pos(':error',s1);
      ss:=Copy(s1,1,j);  // типа 'ns2:'

      //------------------
      nd:=XMLNodeErr.FindNode(AnsiToUtf8('code'));
      if nd<>nil then begin
        s1:=Utf8ToAnsi(nd.ValueAsString);
      end else begin
        nd:=FindNodeXML(XMLNodeErr,':code');
        if nd<>nil then begin
          s1:=Utf8ToANSI(nd.ValueAsString);
        end else begin
          s1:='';
        end;
      end;
      //------------------
      {
      s2:='';
      nd:=XMLNodeErr.FindNode(AnsiToUtf8('lexema'));
      if nd<>nil then begin
        nd:=nd.FindNode('value');
        if nd<>nil then begin
          s2:=Utf8ToANSI(nd.ValueAsString);
        end;
      end;
      if s2='' then begin
        nd:=FindNodeXML(XMLNodeErr,':lexema');
        if nd<>nil then begin
          nd:=FindNodeXML(nd,':value');
          if nd<>nil then begin
            s2:=Utf8ToANSI(nd.ValueAsString);
          end else begin
            s2:='ОШИБКА';
          end;
        end else begin
          s2:='ОШИБКА';
        end;
      end;
      }
      //------------------
      s3:='';
      try
        nd:=XMLNodeErr.FindNode(AnsiToUtf8('check_name'));
        if nd<>nil then begin
          s3:=Utf8ToANSI(nd.ValueAsString);
        end;
      except
        ////
      end;
      if s3='' then begin
        nd:=FindNodeXML(XMLNodeErr,':check_name');
        if nd<>nil then begin
          s3:=Utf8ToANSI(nd.ValueAsString);
        end else begin
          s3:='';
        end;
      end;
      if s3='' then begin
        s3:=strMessage;
      end;
      strMessage:=Trim(s1+'  '+s3);

//      FError.AppendRecord([s1,s2,'',s3,'','']);
      {
      'ERROR_CODE',    Integer(ftString),    10,  //Тип ошибки
      'ERROR_TEXT',    Integer(ftString),   250,  //Текст ошибки
      'ERROR_PLACE',   Integer(ftString),   250,  //Место возникновения ошибки
      'WRONG_VALUE',   Integer(ftString),   250,  //Неправильное значение
      'CORRECT_VALUE', Integer(ftString),   250,  //Правильное значение
      'CHECK_NAME',    Integer(ftString),   250   //Название проверяемого элемента
      }
    end;
  end else begin
    strMessage:='Неизвестная ошибка';
//    FError.AppendRecord(['--','Неизвестная ошибка','','','','']);
  end;
  XMLDoc.Free;
end;

procedure TClassifInterface.SetUrl(Value: string);
begin
   if CompareText(FUrl, Value)<>0 then begin
      FUrl:=Value;
   end;
end;

procedure TClassifInterface.ClearError;
begin
   FFaultError:='';
   FError.First;
   while not FError.Eof do FError.Delete;
end;

procedure TClassifInterface.CopyErrorList(error_list: ErrorList);
var
   I: Integer;
begin
   for I:=Low(error_list) to High(error_list) do begin
      FError.Append;
      //Тип ошибки
      FError.FieldByName('ERROR_CODE').AsString:=GetClassifierCode(error_list[I].error_code);
      //Текст ошибки
      FError.FieldByName('ERROR_TEXT').AsString:=GetClassifierLexema(error_list[I].error_code);
      //Место возникновения ошибки
      FError.FieldByName('ERROR_PLACE').AsString:=error_list[I].error_place;
      //Неправильное значение
      FError.FieldByName('WRONG_VALUE').AsString:=error_list[I].wrong_value;
      //Правильное значение
      FError.FieldByName('CORRECT_VALUE').AsString:=error_list[I].correct_value;
      //Название проверяемого элемента
      FError.FieldByName('CHECK_NAME').AsString:=error_list[I].check_name;
      FError.Post;
   end;
end;

function TClassifInterface.GetClassifierCode(C: Classifier): string;
begin
   Result:='';
   if (C<>nil) then begin
      Result:=C.code;
   end;
end;

function TClassifInterface.GetClassifierLexema(C: Classifier): string;
begin
   Result:='';
   if (C<>nil) and (Length(C.lexema)>0) then begin
//      Result:=C.lexema[0].lang
      Result:=C.lexema[0].Text;
   end;
end;

//----------------------------------------------------------------------------------------------------
function TClassifInterface.RequestChangeClassif(nType: Integer;  dDateFrom: TDateTime; dsResult:TDataSet): Boolean;
var
   i,j: Integer;
   ws: ClassifWs;
//   sl: TStringList;
   ss,sType:String;
   clRequest:cl_request;
   clChange:cl_changes;
   d:TXSDateTime;
   r:ClRequestData;
   c:MessageCover;
   res:ClassifierList;

   hdr: TSOAPHeader;
   Headers: ISOAPHeaders;
begin
  Result := false;
  ClearError;
  try
    if GetService<>nil then begin
      Result := true;
      sType:=IntToStr(nType);
      gisun.WriteTextLog('['+sType+'] запрос изменений с '+DatePropis(dDateFrom,3),LOG_GISUN);
      clRequest:=cl_request.Create;
      d:=TXSDateTime.Create;
      d.AsDateTime:=dDateFrom;
      r:=ClRequestData.Create;
      r.cl_type:=nType;  //  тип классификатора
      r.date_from:=d;
      ClRequest.cover:=CreateMessageCover(sType, '', nType, TypeMessageSource);
      ClRequest.request:=r;

      hdr:=nil;

      if IsCreateHeader then begin
//      if (FUser<>'') and (FPasw<>'') then begin
         gisun.WriteTextLog('['+sType+'] CreateHeader',LOG_GISUN);
         hdr:=CreateHeader(FUser, FPasw, true);
         Headers:=FService as ISOAPHeaders;
         Headers.Send(hdr);
      end;
            
      gisun.WriteTextLog('['+sType+'] выполнение findClChanges',LOG_GISUN);
      clChange:=Service.findClChanges(clRequest);

      hdr.Free;

      if clChange<>nil  then begin
        res:=clChange.changes;
        Application.ProcessMessages;
        gisun.WriteTextLog('['+sType+'] получено изменений ' + InttoStr(High(res)+1),LOG_GISUN);
//      ShowMessage(ClChange.cover.message_id+'   '+intToStr(High(res)));
        for I:=Low(res) to High(res) do begin
          dsResult.Append;
{
    property code:       WideString      Index (IS_OPTN) read Fcode write Setcode stored code_Specified;
    property type_:      Integer         Index (IS_OPTN) read Ftype_ write Settype_ stored type__Specified;
    property lexema:     LangValueList   Index (IS_OPTN) read Flexema write Setlexema stored lexema_Specified;
    property active:     Boolean         Index (IS_OPTN) read Factive write Setactive stored active_Specified;
    property begin_date: TXSDateTime     Index (IS_OPTN) read Fbegin_date write Setbegin_date stored begin_date_Specified;
    property end_date:   TXSDateTime     Index (IS_OPTN) read Fend_date write Setend_date stored end_date_Specified;
    property parents:    ClassifierList  Index (IS_OPTN) read Fparents write Setparents stored parents_Specified;
}
          dsResult.FieldByName('TYPESPR').AsInteger:=nType;
          dsResult.FieldByName('EXTCODE').AsString:=res[i].Code;
          for j:=Low(res[i].lexema) to High(res[i].lexema) do begin
            if j=0 then begin
              dsResult.FieldByName('LEX1').AsString:=res[i].lexema[0].Text;
            end else if j=1 then begin
              dsResult.FieldByName('LEX2').AsString:=res[i].lexema[1].Text;
            end else if j=2 then begin
              dsResult.FieldByName('LEX3').AsString:=res[i].lexema[2].Text;
            end else begin
             //Label3.Caption:='ERROR';      !!!!!
            end;
          end;
          dsResult.FieldByName('PARENT').AsString:=IntToStr(Length(res[i].parents));
          dsResult.FieldByName('EXTTYPE').AsString:=IntToStr(res[i].type_);
          dsResult.FieldByName('Active').AsBoolean:=res[i].active;
          if res[i].begin_date<>nil then dsResult.FieldByName('BEGINDATE').AsDateTime:=res[i].begin_date.AsDateTime;
          if res[i].end_date<>nil then dsResult.FieldByName('ENDDATE').AsDateTime:=res[i].end_date.AsDateTime;
          dsResult.Post;
        end;
        Result:=true;
      end else begin
        gisun.WriteTextLog('['+sType+'] изменения не получены',LOG_GISUN);
      end;

      ClRequest.Free;
      ClChange.Free;
    end else begin
      FFaultError:='Ошибка подключение к сервису справочников';
      Result:=false;
    end;
  except
    on E: sysutils.Exception do begin
      Result:=false;
      HandleException(E,FLog);
    end;
  end;
end;

//----------------------------------------------------------------
function TClassifInterface.RequestATEMaxID: Integer;
var
   I: Integer;
   sl: TStringList;
   ss,sType:String;
   ateInterval:ate_interval;
   ateChange:ate_changes;
   d:TXSDateTime;
   r:AteIntervalData;
   c:MessageCover;
//   res:AteObject;
   res:Array_Of_ateObject;

   hdr: TSOAPHeader;
   Headers: ISOAPHeaders;

begin
   Result:=0;
   sType:='';
   FFaultError:='';
   if GetService<>nil then begin
     ateInterval:=ate_Interval.Create;
     r:=AteIntervalData.Create;
     r.number_from:=0;
     r.number_to:=0;
     ateInterval.request:=r;
     ateInterval.cover:=CreateMessageCover('', '', 0,0);

      hdr:=nil;
      if IsCreateHeader then begin
//      if (FUser<>'') and (FPasw<>'') then begin
         hdr:=CreateHeader(FUser, FPasw, true);
         Headers:=FService as ISOAPHeaders;
         Headers.Send(hdr);
      end;

     try         
       try
         ateChange:=Service.findAteInterval(ateInterval);
         if (ateChange<>nil)  then begin
           Result:=ateChange.changes.max_ate_number;
         end;
       except
         on E: sysutils.Exception do begin
//        HandleException(E,FLog);
          FFaultError:=E.Message;
//          PutError(E.Message);
         end;
       end;
     finally
       ateInterval.Free;
       ateChange.Free;
       hdr.Free;
     end;
   end;
end;

//-------------------------------------------------------------------------------------------------
function TClassifInterface.RequestATEInterval(nFrom,nTo:Integer; dsResult:TDataSet): Boolean;
var
   I: Integer;
   sl: TStringList;
   ss,sType:String;
   ateInterval:ate_interval;
   ateChange:ate_changes;
   d:TXSDateTime;
   r:AteIntervalData;
   c:MessageCover;
//   res:AteObject;
   res:Array_Of_ateObject;

   hdr: TSOAPHeader;
   Headers: ISOAPHeaders;
begin
   Result:=false;
   if not dsResult.Active then exit;
   Result:=true;
   sType:='';
   FFaultError:='';
   if GetService<>nil then begin
     ateInterval:=ate_Interval.Create;
     r:=AteIntervalData.Create;
     r.number_from:=nFrom;
     r.number_to:=nTo;
     ateInterval.request:=r;
     ateInterval.cover:=CreateMessageCover('', '', 0,0);

     hdr:=nil;
     if IsCreateHeader then begin
//     if (FUser<>'') and (FPasw<>'') then begin
       hdr:=CreateHeader(FUser, FPasw, true);
       Headers:=FService as ISOAPHeaders;
       Headers.Send(hdr);
     end;

     try
       try

         ateChange:=Service.findAteInterval(ateInterval);
         if dsResult.Active and (ateChange<>nil)  then begin
//         ateChange.changes.max_ate_number;
           res:=ateChange.changes.ate_object;

//           res:=ateChange.changes;
    //       ShowMessage(ateChange.cover.message_id+'   '+intToStr(High(res)));
           for i:=Low(res) to High(res) do begin
             dsResult.Append;

             dsResult.FieldByName('KOD').AsString:=res[i].SOATO;

             if res[i].datein=nil
               then dsResult.FieldByName('DATEIN').AsString:=''
               else dsResult.FieldByName('DATEIN').AsDateTime:=res[i].datein.AsDateTime;

             if res[i].dateout=nil
               then dsResult.FieldByName('DATEOUT').AsString:=''
               else dsResult.FieldByName('DATEOUT').AsDateTime:=res[i].dateout.AsDateTime;

             dsResult.FieldByName('Name_B').AsString:=res[i].nameobjectBy;
             dsResult.FieldByName('Name').AsString:=res[i].nameobjectRu;
             dsResult.FieldByName('ATE_ParentID').AsString:=intToStr(res[i].parentobjectnumber);
             dsResult.FieldByName('ATE_ID').AsString:=intToStr(res[i].Objectnumber);

             if res[i].category<>nil then begin
               dsResult.FieldByName('FNamec').AsString:=res[i].category.namecategoryRu;
               dsResult.FieldByName('FNamec_B').AsString:=res[i].category.namecategoryBy;
               dsResult.FieldByName('Namec').AsString:=res[i].category.shortnameRu;
               dsResult.FieldByName('Namec_B').AsString:=res[i].category.shortnameBy;
               dsResult.FieldByName('Category').AsString:=IntToStr(res[i].category.category);
               dsResult.FieldByName('Front').AsString:=IntToStr(res[i].category.front);
             end;

             dsResult.Post;
           end;
         end;
       except
         on E: sysutils.Exception do begin
//        HandleException(E,FLog);
          FFaultError:=E.Message;
//          PutError(E.Message);
          Result := false;
         end;
       end;
     finally
       ateInterval.Free;
       ateChange.Free;
       hdr.Free;
     end;
   end else begin
     Result:=false;
   end;
end;

//-------------------------------------------------------------------------------------------------
function TClassifInterface.RequestChangeATE(dDateFrom: TDateTime; dsResult:TDataSet): Boolean;
var
   I: Integer;
   sl: TStringList;
   ss,sType:String;
   ateRequest:ate_request;
   ateChange:ate_changes;
   d:TXSDateTime;
   r:AteRequestData;
   c:MessageCover;
//   res:AteChangeData;
   res:Array_Of_ateObject;

   hdr: TSOAPHeader;
   Headers: ISOAPHeaders;

begin
   Result:=false;
   if not dsResult.Active then exit;
   Result:=true;
   sType:='';
   FFaultError:='';
   ClearError;
   try
     gisun.WriteTextLog('ATE запрос изменений',LOG_GISUN);

     if GetService<>nil then begin
       gisun.WriteTextLog('ATE создание запроса',LOG_GISUN);
       ateRequest:=ate_request.Create;
       d:=TXSDateTime.Create;
       d.AsDateTime:=dDateFrom;
       r:=AteRequestData.Create;
       r.date_from:=d;
       ateRequest.request:=r;
       ateRequest.cover:=CreateMessageCover('', '', 0,0);

       hdr:=nil;
       if IsCreateHeader then begin
//       if (FUser<>'') and (FPasw<>'') then begin
         hdr:=CreateHeader(FUser, FPasw, true);
         Headers:=FService as ISOAPHeaders;
         Headers.Send(hdr);
       end;

       gisun.WriteTextLog('ATE выполнение findAteChanges',LOG_GISUN);
       ateChange:=Service.findAteChanges(ateRequest);
       if dsResult.Active and (ateChange<>nil)  then begin
         res:=ateChange.changes.ate_object;
         gisun.WriteTextLog('ATE получено изменений ' + InttoStr(High(res)),LOG_GISUN);

  //       ShowMessage(ateChange.cover.message_id+'   '+intToStr(High(res)));
         for i:=Low(res) to High(res) do begin
           dsResult.Append;

           dsResult.FieldByName('KOD').AsString:=res[i].SOATO;

           if res[i].datein=nil
             then dsResult.FieldByName('DATEIN').AsString:=''
             else dsResult.FieldByName('DATEIN').AsDateTime:=res[i].datein.AsDateTime;

           if res[i].dateout=nil
             then dsResult.FieldByName('DATEOUT').AsString:=''
             else dsResult.FieldByName('DATEOUT').AsDateTime:=res[i].dateout.AsDateTime;

           dsResult.FieldByName('Name_B').AsString:=res[i].nameobjectBy;
           dsResult.FieldByName('Name').AsString:=res[i].nameobjectRu;
           dsResult.FieldByName('ATE_ParentID').AsString:=intToStr(res[i].parentobjectnumber);
           dsResult.FieldByName('ATE_ID').AsString:=intToStr(res[i].Objectnumber);

           if res[i].category<>nil then begin
             dsResult.FieldByName('FNamec').AsString:=res[i].category.namecategoryRu;
             dsResult.FieldByName('FNamec_B').AsString:=res[i].category.namecategoryBy;
             dsResult.FieldByName('Namec').AsString:=res[i].category.shortnameRu;
             dsResult.FieldByName('Namec_B').AsString:=res[i].category.shortnameBy;
             dsResult.FieldByName('Category').AsString:=IntToStr(res[i].category.category);
             dsResult.FieldByName('Front').AsString:=IntToStr(res[i].category.front);
           end;

           dsResult.Post;
         end;
         Result:=true;
       end else begin
         gisun.WriteTextLog('ATE данные не получены',LOG_GISUN);
       end;

       hdr.Free;
     end else begin
       FFaultError:='Ошибка подключение к сервису справочников';
       Result:=false;
     end;
   except
    on E: sysutils.Exception do begin
      gisun.WriteTextLog('ATE ошибка выполнения запроса '+E.Message,LOG_GISUN);
      Result:=false;
      HandleException(E,FLog);
    end;
{
     on E: sysutils.Exception do begin
//       HandleException(E,FLog);
       FFaultError:=E.Message;
//          PutError(E.Message);
       Result := false;
     end;
}
   end;
   ateRequest.Free;
   ateChange.Free;

end;

//------------------------------------------------------
procedure TClassifInterface.ShowError;
var
  IsInput:Boolean;
  cur:TCursor;
begin
   cur:=Screen.Cursor;
   Screen.Cursor:=crDefault;
   try
     if (Error<>nil) and (Error.RecordCount>0)
       then ShowErrorDataSet
       else PutError(FaultError);
   finally
     Screen.Cursor:=cur;
   end;
end;

//-----------------------------------------------
procedure TClassifInterface.ShowErrorDataSet;
var
  f : TfmShowErrorGISUN;
begin
  f := TfmShowErrorGISUN.Create(nil);
  try
    f.DataSource.DataSet:=Error;
    f.ShowModal;
  finally
    f.Free;
  end;
end;

procedure TClassifInterface.SetLog(const Value: TStringList);
begin
  FLog := Value;
end;

procedure TClassifInterface.SetIsDebug(const Value: Boolean);
begin
  FIsDebug := Value;
end;

procedure TClassifInterface.AddToLog(s:String);
begin
  if IsDebug then FLog.Add(s)
end;

procedure TClassifInterface.SetUserNameToken(User:String;Psw:String);
begin
  FUser:=User;
  FPasw:=Psw;
end;

procedure TClassifInterface.RIOHTTPWebNodeReceivingData(Read,  Total: Integer);
begin 
  if not _WorkedThread_
    then Application.ProcessMessages;
end;

end.//TClassifInterface
