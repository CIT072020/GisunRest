unit mLocal;

interface

{$I Task.inc}

uses
   wsLocal,
   SysUtils, Dialogs, Classes, Forms, TypInfo, SoapHTTPClient, WinInet, SOAPHTTPTrans, uProject, XSBuiltIns, uTypes,
   InvokeRegistry, DB, NativeXML, FuncPr, Variants;

type
   //Интерфейс
   TLocalInterface=class(TObject)
   private
      FCurLog:TStrings;
      //адрес сервиса
      FUrl: string;
      FProxy: string;
      //код источника сообщений (MessageCover.message_source)
      FMessageSource: string;
      FTypeMessageSource: integer;
      //
      FFaultError: string;
      //
      FError: TDataSet;
   private
      //события SOAP
      procedure RIOAfterExecute(const MethodName: string; SOAPResponse: TStream);
      procedure RIOBeforeExecute(const MethodName: string; var SOAPRequest: WideString);
      procedure RIOHTTPWebNodeReceivingData(Read, Total: Integer);
      procedure RIOHTTPWebNodePostingData(Write, Total: Integer);
      procedure RIOHTTPWebNodeBeforePost(const HTTPReqResp: THTTPReqResp; Data: Pointer);

      //получение ссылки не сервис
      function GetService: LocalWs;
      //
      procedure SetUrl(Value: string);
      procedure ClearError;
      procedure CopyErrorList(error_list: ErrorList);
   public
      EnabledLog:Boolean;
      //SOAP
      FRIO: THTTPRIO;
      //сервис
      FService: LocalWs;

      constructor Create;
      destructor Destroy; override;
      //ИНТЕРФЕЙС:
      //создание объектов
      function CreateId: string;
      function CreateMessageCover(MessageType, ParentId: string): MessageCover;
//      function CreateRequestData(PersonCount, IdentifierCount: Integer): RequestData;
//      function CreateActReason: ActReason;
//      function CreateActData: ActData;
      function CreatePersonalData: PersonalData;
      function CreateDocument: Document;
      function CreateClassifier(Code: string; ClassifierType: Integer): Classifier;
      function CreateDateTime(DateTime: TDateTime): TXSDateTime;
      function CreateDate(Date: TDateTime): TXSDate;
      //информация об опеке
      function CreateGuardRequest(MessageType, ParentMessageId: string): guardianship_data_request;
      function CreateGuardData: guardianshipInfo2;
      function PostGuardCertificate(const guardRequest: guardianship_data_request; Log: TStrings; User, Pasw: string): WsReturnCode;
      procedure GuardDataToLog(Log: TStrings; Act: guardianshipInfo2);
      // информация о попечительстве------------
      function CreateTrusteeRequest(MessageType, ParentMessageId: string): trusteeship_data_request;
      function CreateTrusteeData: TrusteeshipInfo2;
      function PostTrusteedCertificate(const TrusteeRequest: trusteeship_data_request; Log: TStrings; User, Pasw: string): WsReturnCode;
      procedure TrusteeDataToLog(Log: TStrings; Act: TrusteeshipInfo2);
      // информация о захоронении---------------
      function CreateBurialRequest(MessageType, ParentMessageId: string): burial_request;
      function CreateBurialData: burialInfo;
      procedure BurialDataToLog(Log: TStrings; Act: burialInfo);
      function PostBurialCertificate(const Request: burial_request; Log: TStrings; User, Pasw: string): WsReturnCode;
      //----------------------------------------
      procedure PersonalDataToLog(Log: TStrings; Data: PersonalData; Add: string);
      //обработка исключений
      procedure HandleException(E: Exception; Log: TStrings);
      //ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ ТЕСТОВ:
      //вывод в лог
      procedure MessageCoverToLog(Log: TStrings; Cover: MessageCover);
      procedure ReturnCodeToLog(Log: TStrings; ReturnCode: WsReturnCode);
      procedure ErrorListToLog(Log: TStrings; error_list: ErrorList);
      procedure DocumentToLog(Log: TStrings; Doc: Document; Add: string);

      procedure ActDataToLog(Log: TStrings; Act: ActData; Add: string);
//      procedure ActReasonToLog(Log: TStrings; Act: ActReason; Add: string);

      //преобразование в строку
      function GetClassifierString(C: Classifier): string;
      function GetDateString(Date: TXSDate): string;
      function GetDateTimeString(DateTime: TXSDateTime): string;
      //другие вспомогательные
      function GetClassifierLexema(C: Classifier): string;
      function GetClassifierCode(C: Classifier): string;
      //
      procedure UpdateUrl(Value: string);
   public
      property MessageSource: string read FMessageSource write FMessageSource;
      property TypeMessageSource: integer read FTypeMessageSource write FTypeMessageSource;
      property Service: LocalWs read GetService;
      property Url: string read FUrl write SetUrl;
      property Proxy: string read FProxy write FProxy;
      property FaultError: string read FFaultError;
      property Error: TDataSet read FError;
   end;

// ctDocIsp=131    CODE=3  NAME=ДОКУМЕНТ ИЗ ИСПОЛКОМА О ДАННЫЕ ОБ ОПЕКЕ И ПОПЕЧИТЕЛЬСТВЕ
// ctDocIsp=131    CODE=1  NAME=ДОКУМЕНТ ИЗ ИСПОЛКОМА О ДАННЫЕ О МЕСТЕ ЗАХОРОНЕНИЯ
// ctIspolcom=133  CODE=1  NAME=ИСПОЛКОМ Г. МИНСКА

implementation
uses
   mRegInt, mSecHeader; //,mGisun;

{TLocalInterface}

constructor TLocalInterface.Create;
begin
   EnabledLog:=true;
   //Список последних ошибок
   FError:=CreateErrorTable;
   //SOAP
   FRIO:=THTTPRIO.Create(nil);
   FRIO.OnAfterExecute:=RIOAfterExecute;
   FRIO.OnBeforeExecute:=RIOBeforeExecute;
   FRIO.HTTPWebNode.OnReceivingData:=RIOHTTPWebNodeReceivingData;
   FRIO.HTTPWebNode.OnPostingData:=RIOHTTPWebNodePostingData;
   FRIO.HTTPWebNode.OnBeforePost:=RIOHTTPWebNodeBeforePost;
end;

destructor TLocalInterface.Destroy;
begin
   FService:=nil;
   //!!!!!!! почему то возникал AV
   //FRIO.Free;
   FError.Close;
   FError.Free;
   inherited;
end;
//-----------------------------------------------------------------------------------------------------------------------
procedure TLocalInterface.RIOHTTPWebNodeBeforePost(const HTTPReqResp: THTTPReqResp; Data: Pointer);
begin
  if Global_TimeOut_BeforePost>0 then begin
    InternetSetOption(Data, INTERNET_OPTION_CONNECT_TIMEOUT, Pointer(@Global_TimeOut_BeforePost), SizeOf(Global_TimeOut_BeforePost));
    InternetSetOption(Data, INTERNET_OPTION_SEND_TIMEOUT, Pointer(@Global_TimeOut_BeforePost), SizeOf(Global_TimeOut_BeforePost));
    InternetSetOption(Data, INTERNET_OPTION_RECEIVE_TIMEOUT, Pointer(@Global_TimeOut_BeforePost), SizeOf(Global_TimeOut_BeforePost));
  end;
end;
//-----------------------------------------------------------------------------------------------------------------------
procedure TLocalInterface.RIOHTTPWebNodeReceivingData(Read, Total: Integer);
begin
  if (FCurLog<>nil) and EnabledLog
    then FCurLog.Add('Получение данных    получено='+IntToStr(Read)+', всего='+IntToStr(Total));
end;
//-----------------------------------------------------------------------------------------------------------------------
procedure TLocalInterface.RIOHTTPWebNodePostingData(Write, Total: Integer);
begin
  if (FCurLog<>nil) and EnabledLog
    then FCurLog.Add('Отправка данных    отправлено='+IntToStr(Write)+', всего='+IntToStr(Total));
end;

procedure TLocalInterface.RIOAfterExecute(const MethodName: string; SOAPResponse: TStream);
var
//   XMLDoc:TNativeXML;
   sFile:String;
   stFile:TFileStream;
begin
   //вывод текста запроса
   sFile:=ExtractFilePath(Application.ExeName)+'Регистрация_ответ.xml';
   DeleteFile(sFile);
   stFile:=TFileStream.Create(sFile, fmCreate);
   SOAPResponse.Position:=0;
   try
     stFile.CopyFrom(SOAPResponse, SOAPResponse.Size);
   finally
     stFile.Free;
   end;
   SOAPResponse.Position:=0;
{
   XMLDoc:=TNativeXML.Create;
   try
      XMLDoc.LoadFromStream(SOAPResponse);
      CheckHash(XMLDoc);
//      XMLDoc.SaveToFile(ExtractFilePath(Application.ExeName)+'Регистрация_ответ.xml');
   finally
      XMLDoc.Free;
   end;
}
end;

procedure TLocalInterface.RIOBeforeExecute(const MethodName: string; var SOAPRequest: WideString);
var
   S: Utf8String;
   n,m: Integer;
   strErr:String;
//   XMLDoc:TNativeXML;
//   SStrm:TStringStream;
begin
   //вывод текста запроса
   CreateETSP(SOAPRequest,strErr);
   try
     S:=Utf8Encode(SOAPRequest);
     n:=Pos('<Password>',s);
     m:=Pos('</Password>',s);
     if (n>0) and (m>0) then begin
       s:=Copy(s,1,n+9)+'*****'+Copy(s,m,Length(s));
     end;
{
   XMLDoc:=TNativeXML.Create;

   SStrm := TStringStream.Create(s);
   try
      XMLDoc.LoadFromStream(SStrm);
      XMLDoc.RootNodeList.AttributeAdd('encoding','UTF-8');
      XMLDoc.SaveToFile(ExtractFilePath(Application.ExeName)+'Регистрация.xml');
   finally
      SStrm.Free;
      XMLDoc.Free;
   end;
}
     MemoWrite(ExtractFilePath(Application.ExeName)+'Регистрация.xml', S);
   except

   end;
end;

function TLocalInterface.GetService: LocalWs;
begin  
   if FService=nil then begin
      FService:=GetLocalWs2(FUrl, FProxy, FRIO);
//      FRIO.URL:='ddd';
      //try except end !!! когда нет связи
   end;
   Result:=FService;
end;

function TLocalInterface.CreateMessageCover(MessageType, ParentId: string): MessageCover;
begin
   //Сопроводительная информация к сообщению
   Result:=MessageCover.Create;
   //идентификатор сообщения
   Result.message_id:=CreateId;
   //тип сообщения
   Result.message_type:=CreateClassifier(MessageType, ctSysDoc{--ctActType});
   //время отправки сообщения
   Result.message_time:=CreateDateTime(Now);
   //источник сообщения
   Result.message_source:=CreateClassifier(FMessageSource, FTypeMessageSource);
   //идентификатор сообщения, для которого текущее является ответом
   Result.parent_message_id:=ParentId;
end;
//---- ЗАХОРОНЕНИЯ (ZAH) BEGIN ---------------------------------------------------------------------------------------
{
  function  postBurialData(const burialStatus: burial_request): return_code2; stdcall;

  burial_request = class(burialRequest)

  burialRequest = class(TRemotable)
    property cover:       MessageCover  read Fcover write Fcover;
    property burial_info: burialInfo    read Fburial_info write Fburial_info;
  end;
//---------
  burialInfo = class(TRemotable)
    property person_data:     PersonalData  read Fperson_data write Fperson_data;
    property burial_data:     burialData    read Fburial_data write Fburial_data;
    property burial_document: Document      read Fburial_document write Fburial_document;
  end;
//---------
burialData = class(TRemotable)
    property country:     Classifier  Index (IS_OPTN) read Fcountry write Setcountry stored country_Specified;
    property area:        Classifier  Index (IS_OPTN) read Farea write Setarea stored area_Specified;
    property region:      Classifier  Index (IS_OPTN) read Fregion write Setregion stored region_Specified;
    property soviet:      Classifier  Index (IS_OPTN) read Fsoviet write Setsoviet stored soviet_Specified;
    property city:        Classifier  Index (IS_OPTN) read Fcity write Setcity stored city_Specified;
    property burial_name: Classifier  Index (IS_OPTN) read Fburial_name write Setburial_name stored burial_name_Specified;
    property sector:      WideString  Index (IS_OPTN) read Fsector write Setsector stored sector_Specified;
    property row:         WideString  Index (IS_OPTN) read Frow write Setrow stored row_Specified;
    property place:       WideString  Index (IS_OPTN) read Fplace write Setplace stored place_Specified;
end;
}
function TLocalInterface.CreateBurialRequest(MessageType, ParentMessageId: string): burial_request;
begin
   Result:=burial_request.Create;
   //Системная информация
   Result.cover:=CreateMessageCover(MessageType, ParentMessageId);
   //
   Result.burial_info:=CreateBurialData;
end;
//------------------------------------------
function TLocalInterface.CreateBurialData: burialInfo;
begin
   Result:=burialInfo.Create;
   Result.person_data:=CreatePersonalData;
   Result.burial_data:=burialData.Create;
   Result.burial_document:=CreateDocument;
end;
//------------------------------------------
function TLocalInterface.PostBurialCertificate(const Request: burial_request; Log: TStrings; User, Pasw: string): WsReturnCode;
var
   hdr: TSOAPHeader;
   Headers: ISOAPHeaders;
begin
   ClearError;
   Result:=nil;
   try
      if GetService<>nil then begin
         if (Log<>nil) and EnabledLog then begin
           Log.Add('');
           Log.Add('Выполняется отправка данных в регистр:');
           Log.Add('');
           Log.Add('Информация о захоронении');
           Log.Add('');
           MessageCoverToLog(Log, Request.cover);
           Log.Add('');
           burialDataToLog(Log, Request.burial_info);
         end;
         hdr:=nil;
         {$IFDEF MY_PROJECT}
         if IsCreateHeader then begin
         {$ELSE}
         if (User<>'') and (Pasw<>'') then begin
         {$ENDIF}
            hdr:=CreateHeader(User, Pasw);
            Headers:=FService as ISOAPHeaders;
            Headers.Send(hdr);
         end;

         FCurLog:=Log;
         Result:=FService.postBurialData(Request);

         hdr.Free;

         if (Log<>nil) and EnabledLog then begin
           Log.Add('');
           Log.Add('Получен ответ:');
           Log.Add('');
           ReturnCodeToLog(Log, Result);
         end;
         CopyErrorList(Result.error_list);
      end
      else begin
         if (Log<>nil) and EnabledLog then begin
           Log.Add('ОШИБКА: GetService=nil');
         end;
      end;
   except
      on E: Exception do begin
         HandleException(E, Log);
      end;
   end;
   FCurLog:=nil;
end;
procedure TLocalInterface.BurialDataToLog(Log: TStrings; Act: burialInfo);
var
  Adr:burialData;
  s:String;
begin
   FCurLog:=Log;
   Log.Add('Персональные данные');
   Log.Add('');
   PersonalDataToLog(Log, Act.person_data, 'person_data/');
   Log.Add('');
   Log.Add('Захоронение');
   Log.Add('');
   Adr:=Act.burial_data;
   if Adr<>nil then begin
     s:='burial_data/';
     Log.Add(Format(s+'country       =%s', [GetClassifierString(Adr.country)]));
     Log.Add(Format(s+'area          =%s', [GetClassifierString(Adr.area)]));
     Log.Add(Format(s+'region        =%s', [GetClassifierString(Adr.region)]));
     Log.Add(Format(s+'soviet        =%s', [GetClassifierString(Adr.soviet)]));
     Log.Add(Format(s+'city          =%s', [GetClassifierString(Adr.city)]));
     Log.Add(Format(s+'burial_name   =%s', [GetClassifierString(Adr.burial_name)]));
     Log.Add(Format(s+'sector         =%s', [Adr.sector]));
     Log.Add(Format(s+'row            =%s', [Adr.row]));
     Log.Add(Format(s+'place          =%s', [Adr.place]));
   end else begin
     Log.Add('burial_data=nil');
   end;
   Log.Add('');
   Log.Add('Информация о документе');
   Log.Add('');
   DocumentToLog(Log, Act.burial_document, 'burial_document/');
   FCurLog:=nil;
end;

//---- ЗАХОРОНЕНИЯ (ZAH) END ---------------------------------------------------------------------------------------

//---- ОПЕКА BEGIN ---------------------------------------------------------------------------------------
function TLocalInterface.CreateGuardRequest(MessageType, ParentMessageId: string): guardianship_data_request;
begin
   Result:=guardianship_data_request.Create;
   //Системная информация
   Result.cover:=CreateMessageCover(MessageType, ParentMessageId);
   //
   Result.guardianship_info:=CreateGuardData;
end;
//------------------------------------------
function TLocalInterface.CreateGuardData: guardianshipInfo2;
begin
   Result:=guardianshipInfo2.Create;
   //Персональные подопечного
   Result.ward_data:=CreatePersonalData;
   //Персональные данные опекуна
   Result.guardian_data:=CreatePersonalData;
   // дата установления опеки
   Result.establish_guardianship_date:=nil; //CreateDate(0);
   // дата прекращения опеки
   Result.termination_guardianship_date:=nil; //CreateDate(0);
   // дата отстранения опекуна
   Result.remove_guardian_date:=nil; //CreateDate(0);
   //информация документе
   Result.guardianship_document:=CreateDocument;
end;
//------------------------------------------
function TLocalInterface.PostGuardCertificate(const guardRequest: guardianship_data_request; Log: TStrings; User, Pasw: string): WsReturnCode;
var
   hdr: TSOAPHeader;
   Headers: ISOAPHeaders;
begin
   ClearError;
   Result:=nil;
   try
      if GetService<>nil then begin
         if (Log<>nil) and EnabledLog then begin
           Log.Add('');
           Log.Add('Выполняется отправка данных в регистр:');
           Log.Add('');
           Log.Add('Запись опеки');
           Log.Add('');
           MessageCoverToLog(Log, guardRequest.cover);
           Log.Add('');
           guardDataToLog(Log, guardRequest.guardianship_info);
         end;
         hdr:=nil;
         {$IFDEF MY_PROJECT}
         if IsCreateHeader then begin
         {$ELSE}
         if (User<>'') and (Pasw<>'') then begin
         {$ENDIF}
            hdr:=CreateHeader(User, Pasw);
            Headers:=FService as ISOAPHeaders;
            Headers.Send(hdr);
         end;

         FCurLog:=Log;
         Result:=FService.postGuardianshipData(guardRequest);

         hdr.Free;

         if (Log<>nil) and EnabledLog then begin
           Log.Add('');
           Log.Add('Получен ответ:');
           Log.Add('');
           ReturnCodeToLog(Log, Result);
         end;
         CopyErrorList(Result.error_list);
      end
      else begin
         if (Log<>nil) and EnabledLog then begin
           Log.Add('ОШИБКА: GetService=nil');
         end;
      end;
   except
      on E: Exception do begin
         HandleException(E, Log);
      end;
   end;
   FCurLog:=nil;
end;
procedure TLocalInterface.GuardDataToLog(Log: TStrings; Act: guardianshipInfo2);
begin
   FCurLog:=Log;
   Log.Add('Персональные данные подопечного');
   Log.Add('');
   PersonalDataToLog(Log, Act.ward_data, 'ward_data/');
   Log.Add('');
   Log.Add('Персональные данные опекуна');
   Log.Add('');
   PersonalDataToLog(Log, Act.guardian_data, 'guardian_data/');
   Log.Add('');
//   Log.Add('Информация о печатном документе');
//   Log.Add('');
//   DocumentToLog(Log, Act.guardianship_document, 'guardianship_document/');
   FCurLog:=nil;
end;

//---- ОПЕКА END--------------------------------------------------------------------------------------------

//---- ПОПЕЧИТЕЛЬСТВО BEGIN ---------------------------------------------------------------------------------------
function TLocalInterface.CreateTrusteeRequest(MessageType, ParentMessageId: string): trusteeship_data_request;
begin

   Result:=trusteeship_data_request.Create;
   //Системная информация
   Result.cover:=CreateMessageCover(MessageType, ParentMessageId);
   //
   Result.trusteeship_info:=CreateTrusteeData;
end;
//------------------------------------------
function TLocalInterface.CreateTrusteeData: TrusteeshipInfo2;
begin
   Result:=trusteeshipInfo2.Create;
   //Персональные подопечного
   Result.ward_data:=CreatePersonalData;
   //Персональные данные опекуна
   Result.trustee_data:=CreatePersonalData;
   // дата установления опеки
   Result.establish_trusteeship_date:=nil; //CreateDate(0);
   // дата прекращения опеки
   Result.termination_trusteeship_date:=nil; //CreateDate(0);
   // дата отстранения опекуна
   Result.remove_trustee_date:=nil; //CreateDate(0);
   //информация документе
   Result.trusteeship_document:=CreateDocument;
end;
//------------------------------------------
function TLocalInterface.PostTrusteedCertificate(const trusteeRequest: trusteeship_data_request; Log: TStrings; User, Pasw: string): WsReturnCode;
var
   hdr: TSOAPHeader;
   Headers: ISOAPHeaders;
begin
   ClearError;
   Result:=nil;
   try
      if GetService<>nil then begin
         if (Log<>nil) and EnabledLog then begin
           Log.Add('');
           Log.Add('Выполняется отправка данных в регистр:');
           Log.Add('');
           Log.Add('Запись попечительства');
           Log.Add('');
           MessageCoverToLog(Log, TrusteeRequest.cover);
           Log.Add('');
           TrusteeDataToLog(Log, TrusteeRequest.trusteeship_info);
         end;
         hdr:=nil;
         {$IFDEF MY_PROJECT}
         if IsCreateHeader then begin
         {$ELSE}
         if (User<>'') and (Pasw<>'') then begin
         {$ENDIF}
            hdr:=CreateHeader(User, Pasw);
            Headers:=FService as ISOAPHeaders;
            Headers.Send(hdr);
         end;

         FCurLog:=Log;
         Result:=FService.postTrusteeshipData(TrusteeRequest);

         hdr.Free;

         if (Log<>nil) and EnabledLog then begin
           Log.Add('');
           Log.Add('Получен ответ:');
           Log.Add('');
           ReturnCodeToLog(Log, Result);
         end;
         CopyErrorList(Result.error_list);
      end
      else begin
         if (Log<>nil) and EnabledLog then begin
           Log.Add('ОШИБКА: GetService=nil');
         end;
      end;
   except
      on E: Exception do begin
         HandleException(E, Log);
      end;
   end;
   FCurLog:=nil;
end;
procedure TLocalInterface.TrusteeDataToLog(Log: TStrings; Act: TrusteeshipInfo2);
begin
   FCurLog:=Log;
   Log.Add('Персональные данные подопечного');
   Log.Add('');
   PersonalDataToLog(Log, Act.ward_data, 'ward_data/');
   Log.Add('');
   Log.Add('Персональные данные попечителя');
   Log.Add('');
   PersonalDataToLog(Log, Act.Trustee_data, 'trustee_data/');
   Log.Add('');
//   Log.Add('Информация о печатном документе');
//   Log.Add('');
//   DocumentToLog(Log, Act.guardianship_document, 'guardianship_document/');
   FCurLog:=nil;
end;

//---- ПОПЕЧИТЕЛЬСТВО END--------------------------------------------------------------------------------------------

procedure TLocalInterface.PersonalDataToLog(Log: TStrings; Data: PersonalData; Add: string);
var
   I: Integer;
begin
   if Data<>nil then begin
      Log.Add(Format(Add+'identif        =%s', [Data.identif]));
      Log.Add(Format(Add+'last_name      =%s', [Data.last_name]));
      Log.Add(Format(Add+'name_          =%s', [Data.name_]));
      Log.Add(Format(Add+'patronymic     =%s', [Data.patronymic]));
      Log.Add(Format(Add+'sex            =%s', [GetClassifierString(Data.sex)]));
      Log.Add(Format(Add+'birth_day      =%s', [Data.birth_day]));
      Log.Add(Format(Add+'citizenship    =%s', [GetClassifierString(Data.citizenship)]));
      Log.Add(Format(Add+'status         =%s', [GetClassifierString(Data.status)]));
      {
      Log.Add(Format('Список документов documents (%d):', [Length(Data. documents)]));
      for I:=Low(Data.documents) to High(Data.documents) do begin
         Log.Add('');
         DocumentToLog(Log, Data.documents[I], Add+'documents/');
      end;}
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

function TLocalInterface.CreatePersonalData: PersonalData;
begin
   //Персональные данные
   Result:=PersonalData.Create;
   //Место рождения
   Result.birth_place:=birth_place.Create;
end;

function TLocalInterface.CreateDocument: Document;
begin
   //Документ, удостоверяющий личность
   Result:=Document.Create;
   //Тип документа
   //Result.document_type: Classifier;
   //Гос. орган, выдавший документ
   //Result.authority: Classifier;
   //Дата выдачи документа
   //Result.date_of_issue: TXSDate;
   //Срок действия документа
   //Result.expire_date: TXSDate;
   //Серия документа
   //Result.series: WideString;
   //Номер документа
   //Result.number: WideString;
   //Информация по актовой записи
   //Result.act_data: ActData;
end;

function TLocalInterface.CreateClassifier(Code: string; ClassifierType: Integer): Classifier;
begin
   Result:=Classifier.Create;
   Result.code:=Code;
   Result.type_:=ClassifierType;
end;

function TLocalInterface.CreateDateTime(DateTime: TDateTime): TXSDateTime;
begin
   Result:=TXSDateTime.Create;
   Result.AsDateTime:=DateTime;
end;

function TLocalInterface.CreateDate(Date: TDateTime): TXSDate;
begin
   Result:=TXSDate.Create;
   if Date>0
     then Result.AsDate:=Date;
end;

procedure TLocalInterface.MessageCoverToLog(Log: TStrings; Cover: MessageCover);
begin
   if cover<>nil then begin
      Log.Add('/cover/');
      Log.Add(Format('/cover/message_id        =%s', [cover.message_id]));
      Log.Add(Format('/cover/message_type      =%s', [GetClassifierString(cover.message_type)]));
      Log.Add(Format('/cover/message_time      =%s', [GetDateTimeString(cover.message_time)]));
      Log.Add(Format('/cover/message_source    =%s', [GetClassifierString(cover.message_source)]));
      Log.Add(Format('/cover/parent_message_id =%s', [cover.parent_message_id]));
   end
   else begin
      Log.Add('cover=nil');
   end;
end;

procedure TLocalInterface.ReturnCodeToLog(Log: TStrings; ReturnCode: WsReturnCode);
begin
   if ReturnCode<>nil then begin
      MessageCoverToLog(Log, ReturnCode.cover);
      Log.Add('');
      ErrorListToLog(Log, ReturnCode.error_list);
   end
   else begin
      Log.Add('ReturnCode=nil');
   end;
end;

procedure TLocalInterface.ErrorListToLog(Log: TStrings; error_list: ErrorList);
var
   I: Integer;
   ErrorList: TStringList;
begin
   ErrorList:=TStringList.Create;
   ErrorList.Add('error_code.code;error_code.text;error_place;wrong_value;correct_value;check_name;description;identif');
   try
      Log.Add(Format('Список ошибок error_list (%d):', [Length(error_list)]));
      for I:=Low(error_list) to High(error_list) do begin
         Log.Add('');
         Log.Add(Format('error_code    =%s', [GetClassifierString(error_list[I].error_code)]));
         Log.Add(Format('error_place   =%s', [error_list[I].error_place]));
         Log.Add(Format('wrong_value   =%s', [error_list[I].wrong_value]));
         Log.Add(Format('correct_value =%s', [error_list[I].correct_value]));
         Log.Add(Format('check_name    =%s', [error_list[I].check_name]));
         Log.Add(Format('description   =%s', [error_list[I].description]));
         Log.Add(Format('identif       =%s', [error_list[I].identif]));
         ErrorList.Add(Format('"%s";"%s";"%s";"%s";"%s";"%s";"%s";"%s"', [GetClassifierCode(error_list[I].error_code), GetClassifierLexema(error_list[I].error_code), error_list[I].error_place, error_list[I].wrong_value, error_list[I].correct_value, error_list[I].check_name, error_list[I].description, error_list[I].identif]));
      end;
      ErrorList.SaveToFile('error_list.csv');
   finally
      ErrorList.Free;
   end;
end;

function TLocalInterface.GetClassifierString(C: Classifier): string;
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

function TLocalInterface.GetDateString(Date: TXSDate): string;
begin
   if Date=nil then begin
      Result:='nil';
   end
   else begin
//     if Copy(Date.NativeToXS,1,2)='00'
//       then Result:=''
     Result:=FormatDateTime('yyyy.mm.dd', Date.AsDate);
   end;
end;

function TLocalInterface.GetDateTimeString(DateTime: TXSDateTime): string;
begin
   if DateTime=nil then begin
      Result:='nil';
   end
   else begin
      Result:=FormatDateTime('yyyy.mm.dd hh:nn', DateTime.AsDateTime);
   end;
end;

procedure TLocalInterface.HandleException(E: Exception; Log: TStrings);  // vadim
begin
   FCurLog:=Log;
   Log.Add('!Исключение Exception');
   Log.Add(Format('Message=%s', [E.Message]));
   Log.Add(Format('ClassName=%s', [E.ClassName]));
   //обработка исключения
   FFaultError:=E.Message;
   FCurLog:=nil;
end;

function TLocalInterface.CreateId: string;
var
   GUID: TGUID;
begin
   CReateGUID(GUID);
   //Внутренний идентификатор
   Result:=GUIDToString(GUID);
end;

procedure TLocalInterface.SetUrl(Value: string);
begin
   if CompareText(FUrl, Value)<>0 then begin
      FUrl:=Value;
   end;
end;

procedure TLocalInterface.ClearError;
begin
   FFaultError:='';
   FError.First;
   while not FError.Eof do FError.Delete;
end;

procedure TLocalInterface.CopyErrorList(error_list: ErrorList);
var
   I: Integer;
   lAdd:Boolean;
begin
   for I:=Low(error_list) to High(error_list) do begin
      lAdd:=true;
      if (error_list[I].error_place<>'') and (error_list[I].wrong_value<>'') then begin
        if FError.Locate('ERROR_PLACE;WRONG_VALUE', VarArrayOf([error_list[I].error_place,error_list[I].wrong_value]), [])
          then lAdd:=false;
      end;
      if lAdd then begin
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
        //
        try
          FError.FieldByName('DESCRIPTION').AsString:=error_list[I].description;
        except
        end;
        //
        try
          FError.FieldByName('IDENTIF').AsString:=error_list[I].identif;
        except
        end;
        FError.Post;
      end;
   end;
end;

procedure TLocalInterface.DocumentToLog(Log: TStrings; Doc: Document; Add: string);
begin
   FCurLog:=Log;
   if Doc<>nil then begin
      Log.Add(Format(Add+'document_type =%s', [GetClassifierString(Doc.document_type)]));
      Log.Add(Format(Add+'authority     =%s', [GetClassifierString(Doc.authority)]));
      Log.Add(Format(Add+'date_of_issue =%s', [GetDateString(Doc.date_of_issue)]));
      Log.Add(Format(Add+'expire_date   =%s', [GetDateString(Doc.expire_date)]));
      Log.Add(Format(Add+'series        =%s', [Doc.series]));
      Log.Add(Format(Add+'number        =%s', [Doc.number]));
      ActDataToLog(Log, Doc.act_data, Add+'act_data/');
   end
   else begin
      Log.Add(Add+' =nil');
   end;
   FCurLog:=nil;
end;

procedure TLocalInterface.ActDataToLog(Log: TStrings; Act: ActData; Add: string);
begin
   FCurLog:=Log;
   if Act<>nil then begin
      Log.Add(Format(Add+'act_type  =%s', [GetClassifierString(Act.act_type)]));
      Log.Add(Format(Add+'authority =%s', [GetClassifierString(Act.authority)]));
      Log.Add(Format(Add+'date      =%s', [GetDateString(Act.date)]));
      Log.Add(Format(Add+'number    =%s', [Act.number]));
   end
   else begin
      Log.Add(Add+' =nil');
   end;
   FCurLog:=nil;
end;

function TLocalInterface.GetClassifierCode(C: Classifier): string;
begin
   Result:='';
   if (C<>nil) then begin
      Result:=C.code;
   end;
end;

function TLocalInterface.GetClassifierLexema(C: Classifier): string;
begin
   Result:='';
   if (C<>nil) and (Length(C.lexema)>0) then begin
      Result:=C.lexema[0].Text;
   end;
end;

procedure TLocalInterface.UpdateUrl(Value: string);
begin
   if FService<>nil then begin
      FRIO.URL:=Value;
   end;
end;

end.//TLocalInterface
