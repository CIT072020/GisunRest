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
  uGetSrvX;

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

    //function SetTypeAndIDMsg(ActKind: TActKind; var MessageType: string; const PCount : Integer = -1; const INCount : Integer = -1) : TObject;
    function GetRestIN(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet; const Dokument:TDataSet; slPar:TStringList): TRestResponse;

    ///----!!!!
    //FGetSrv : TGetSrvX;
  public
    property Config : TRestConfig read FConfig write FConfig;
    property ApiClient : TRestClient read FRestClient write FRestClient;

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

    ///----!!!!
    //property GisunX : TGetSrvX read FGetSrv write FGetSrv;
  end;






implementation

uses
  SysUtils,
  kbmMemTable,
  FuncPr;


constructor TRegIntX.Create(MessageSource: string; Ini : TSasaIniFile = nil);
var
  i : Integer;
  DefH : TStringList;
begin
  inherited Create(MessageSource);

  DefH := TStringList.Create;
  DefH.Add('Reg-auth-username:PASSPORT_USER');
  DefH.Add('Reg-auth-password:user_password');
  Config := TRestConfig.Create(DefH);
  FIni := Ini;
  FExchMode := EM_SOAP;
  if (Assigned(Ini)) then begin
    FExchMode := Ini.ReadInteger(SCT_REST, 'EXCHG_MODE', EM_SOAP);
    Config.BasePath := Ini.ReadString(SCT_REST, 'BASE_URI', '');
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


// ��������� �� ��������
function TRegIntX.Get(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet; const Dokument: TDataSet = nil;
    slPar: TStringList = nil; ExchMode: Integer = EM_DEFLT): TRestResponse;
var
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



(*
function TRegIntX.SetTypeAndIDMsg(ActKind: TActKind; var MessageType: string; const PCount: Integer = -1; const INCount: Integer = -1): TObject;
//var
  //old: Integer;
begin
//------------------- �����  16.03.2021   �� ������� ���
  GisunX.TypeMessageCover := 0;
  // ��� ������� ��, ������ ��� ����������� � �����
  if (MessageType = QUERY_INFO) or (ActKind = akZah) or (ActKind = akOpeka) or (ActKind = akPopech) then begin
    //old := GisunX.TypeMessageCover;
    GisunX.TypeMessageCover := -2;
    MessageType := QUERY_INFO;
  end;
  if (PCount < 0) then
    Result := GisunX.CreateRegisterPersonIdentifRequest(MessageType)
  else
    Result := GisunX.CreateRegisterRequest(MessageType, PCount, INCount);

  GisunX.TypeMessageCover := 0;
//-------------------
// ����         registerPersonIdentifRequest:=GisunX.CreateRegisterPersonIdentifRequest(MessageType);
//-------------------
end;
*)



//������ �� ��������� �� �� �.�.�.
//----------------------------------------------------------------
function TRegIntX.GetRestIN(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet; const Dokument:TDataSet; slPar:TStringList): TRestResponse;
var
   registerRequest: wsGisun.register_request;
   registerPersonIdentifRequest: wsGisun.register_person_identif_request;
   registerResponse: wsGisun.register_response;
   Person: wsGisun.ResponsePerson;
   PersonFam: wsGisun.ResponsePerson;
   Identif: wsGisun.ResponseIdentif;
   PersonCount: Integer;
   IdentifierCount: Integer;
   PersonInd: Integer;
   IdentifierInd: Integer;
   Table: TRegTable;
   Temp: TkbmMemTable;
   n,I: Integer;
   sss,s:String;
   lOk:Boolean;
   doc:TRegDocument;
   //FGisun : TGetSrvX;
  ResObs : TRequestResult;

begin
  ResObs := rrFault;
         Result := TRestResponse.Create;
         //registerPersonIdentifRequest := wsGisun.register_person_identif_request(SetTypeAndIDMsg(ActKind, MessageType));
         registerPersonIdentifRequest := wsGisun.register_person_identif_request(1);
         FRequestMessageId:= registerPersonIdentifRequest.cover.message_id;

         //����������� ������ �� ������� ������� � �������� �������
         Table := TableList.Find(True, akGetPersonIdentif, opGet);
         Input.First;
         if not Input.Eof then begin
            Input.Edit;
            Input.FieldByName('REQUEST_ID').AsString:=registerPersonIdentifRequest.request.request_id;
            Input.Post;
            if Table<>nil then begin
               Table.SetProp(registerPersonIdentifRequest.request, Input);
            end;
         end;

         registerResponse:=nil;
         try
            {$IFDEF MY_PROJECT}
            gisun.WriteTextLog('������ ��: '+registerPersonIdentifRequest.request.surname+' '+registerPersonIdentifRequest.request.name_+' '+registerPersonIdentifRequest.request.sname+' '+
                               registerPersonIdentifRequest.request.bdate, LOG_GISUN);

            SetOwnerForm(gisun.CurAkt);
            {$ENDIF}
            OpenMessage('     ������ �� ...          ','',0);
            try
              lOk:=FGisun.GetPersonIdentif(registerPersonIdentifRequest, registerResponse, Log, Username, Password);
            finally
              CloseMessage;
              {$IFDEF MY_PROJECT}
              gisun.CheckMainForm;
              {$ENDIF}
            end;
            FCoverMessageId:=FGisun.CoverMessageId;  //ID ��������� ������
            FCoverMessageTime:=Now; //FGisun.CoverMessageTime;//����� ��������� ������
//  ???             registerResponse.cover.message_time;
//  ???             registerResponse.cover.message_id;

            if lOk then begin
               //Result:=rrOk;
               ResObs := rrOk;
               Output:=CreateOutputTable(akGetPersonalData); //akGetPersonIdentif
               //��������� ��������� ���������
               if registerResponse.cover.parent_message_id<>FRequestMessageId then begin
                  //Result:=rrAfterError;
                  ResObs := rrAfterError;
                  FFaultError:='������ ������ � ���������. �� ��������� �������������� ��������� ������� � ������.';
                  Log.Add('!������: �� ��������� �������������� ���������')
               end;
               Table:=TableList.Find(False, akGetPersonalData, opGet); //akGetPersonIdentif
               for I:=Low(registerResponse.response.personal_data) to High(registerResponse.response.personal_data) do begin
                  Person:=registerResponse.response.personal_data[I];
                  //������������ ������
                  if Person<>nil then begin
                     Output.Append;
                     if Table<>nil then begin
                        Table.GetProp(Person, Output);
                     end;
                     Output.Post;
                  end
                  else begin
                     //Result:=rrAfterError;
                     ResObs := rrAfterError;
                     FFaultError:='������ ������ � ���������. �� ������ ������������� ������� ������������ ������.';
                     Log.Add('!������: �� ��������� �������������� �������� ������������ ������')
                  end;
               end;
            end
            else begin
               //Result:=rrFault;
               ResObs := rrFault;
               Temp:=TkbmMemTable.Create(nil);
               CreateAndCopyMemTable(FGisun.Error, Temp);
               Error:=TDataSet(Temp);
               FFaultError:=FGisun.FaultError;
            end;
            if FFaultError<>'' then begin
              {$IFDEF MY_PROJECT}
              gisun.WriteTextLog('������ �� ������: '+FFaultError, LOG_GISUN);
              {$ENDIF}
            end;
         finally
            registerPersonIdentifRequest.Free;
            registerResponse.Free;
         end
end;







(*
//----------------------------------------------------------------
function TRegIntX.GetRest(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet; const Dokument:TDataSet; slPar:TStringList): TRestResponse;
var
   registerRequest: wsGisun.register_request;
   registerPersonIdentifRequest: wsGisun.register_person_identif_request;
   registerResponse: wsGisun.register_response;
   Person: wsGisun.ResponsePerson;
   PersonFam: wsGisun.ResponsePerson;
   Identif: wsGisun.ResponseIdentif;
   PersonCount: Integer;
   IdentifierCount: Integer;
   PersonInd: Integer;
   IdentifierInd: Integer;
   Table: TRegTable;
   Temp: TkbmMemTable;
   n,I, old: Integer;
   sss,s:String;
   lOk:Boolean;
   doc:TRegDocument;

   function FindPersonData(request_id: WideString; personal_data: wsGisun.Array_Of_ResponsePerson): wsGisun.ResponsePerson;
   var
      I: Integer;
   begin
      Result:=nil;
      for I:=Low(personal_data) to High(personal_data) do begin
         if CompareText(personal_data[I].request_id, request_id)=0 then begin
            Result:=personal_data[I];
            Break;
         end;
      end;
   end;

   function FindResponseIdentif(request_id: WideString; identif_number: wsGisun.Array_Of_ResponseIdentif): wsGisun.ResponseIdentif;
   var
      I: Integer;
   begin
      Result:=nil;
      for I:=Low(identif_number) to High(identif_number) do begin
         if CompareText(identif_number[I].request_id, request_id)=0 then begin
            Result:=identif_number[I];
            Break;
         end;
      end;
   end;
   function GetPar(sParam,sDefault: String): String;
   begin
     Result:=sDefault;
     if (slPar<>nil) and (slPar.Count>0) then begin
       Result:=slPar.Values[sParam];
       if Result=''
         then Result:=sDefault;
     end;
   end;

begin
   Log.Clear;
   Output:=nil;
   Error:=nil;
   FRequestMessageId:='';
   FFaultError:='';
   Result:=rrFault;

   if not CheckLogon then begin
     // ����� �� �����������
     FFaultError := ERR_NO_AUTH;
     Log.Add(FaultError);
     exit;
   end;

   if MessageType='' then begin
      MessageType:=CMessageType[ActKind];
   end;
   case ActKind of
      //������ �� ��������� ������������ ������ �� �.�.�.
      akGetPersonIdentif: begin
        Result := GetRestIN(ActKind, MessageType, Input, Output, Error, Dokument, slPar);
      end;

      //������ �� ��������� ������������ ������
      akGetPersonalData,
      //������� ������ � ��������
      akBirth,
      //������ - CHILD
      //����    - ON
      //����    - ONA
      //������� ������ �� ������������ ���������
      //������� ������ �� ������������ �����������
      akAffiliation,
      //1. ������ - CHILD
      //2. ����    - ON
      //3. ����    - ONA
      //������� ������ � ���������� �����
      akMarriage,
      //1. �����   - ON
      //2. ������� - ONA
      //������� ������ � ������
      akDecease,
      //������ �� �������
      //������� ������ � ����������� �����
      akDivorce,
      //����  - ONA
      //���   - ON
      //������� ������ �� ����������� (����������)
      akAdoption,
      //������         - CHILD
      //����            - ONA
      //����            - ON
      //��������������� - ONA2
      //�����������     - ON2
      //������� ������ � �������� �����
      akNameChange,
      akOpeka,
      akPopech,
      akZah
      //������������ ������ ����
      : begin
         //������� ���������� �������� ��������������� � ������������ ������
         PersonCount:=0;
         IdentifierCount:=0;
         Input.First;
         while not Input.Eof do begin
            if Input.FieldByName('IS_PERSON').AsBoolean then begin
               Inc(PersonCount);
            end
            else begin
               Inc(IdentifierCount);
            end;
            Input.Next;
         end;
{
         FGisun.TypeMessageCover:=0;
         // ��� ������� ������ ��� ����������� � �����
         if (MessageType=QUERY_INFO) or (ActKind=akZah) or (ActKind=akOpeka) or (ActKind=akPopech) then begin
           old:=FGisun.TypeMessageCover;
           FGisun.TypeMessageCover:=-2;
           MessageType:=QUERY_INFO;
         end;
         registerRequest:=FGisun.CreateRegisterRequest(MessageType, PersonCount, IdentifierCount);
         FGisun.TypeMessageCover:=0;

}
         registerRequest   := wsGisun.register_request(SetTypeAndIDMsg(ActKind, MessageType, PersonCount, IdentifierCount));
         FRequestMessageId := registerRequest.cover.message_id;


         //
         Table:=TableList.Find(True, akGetPersonalData, opGet);
         PersonInd:=0;
         IdentifierInd:=0;
         Input.First;
         while not Input.Eof do begin
            if Input.FieldByName('IS_PERSON').AsBoolean then begin
               Input.Edit;
               Input.FieldByName('REQUEST_ID').AsString:=registerRequest.request.person_request[PersonInd].request_id;
               Input.Post;
               if Table<>nil then begin
                  Table.SetProp(registerRequest.request.person_request[PersonInd], Input)
               end;
               Inc(PersonInd);
            end
            else begin
               Input.Edit;
               Input.FieldByName('REQUEST_ID').AsString:=registerRequest.request.identif_request[IdentifierInd].request_id;
               Input.Post;
               if Table<>nil then begin
                  Table.SetProp(registerRequest.request.identif_request[IdentifierInd], Input)
               end;
               Inc(IdentifierInd);
            end;
            Input.Next;
         end;
         registerResponse:=nil;
         try
            {$IFDEF MY_PROJECT}
            if gisun.FEnableTextLog then begin
              s:='';
              if length(registerRequest.request.person_request)>0 then begin
                s:=s+' ������ ������ �� ��: [';
                for i:=0 to length(registerRequest.request.person_request)-1 do begin
                  s:=s+registerRequest.request.person_request[i].identif_number+' ';
                end;
                s:=Trim(s)+']';
              end;
              if length(registerRequest.request.identif_request)>0 then begin
                s:=s+' ������ ��['+IntToStr(length(registerRequest.request.identif_request))+']';
              end;
              if s<>'' then gisun.WriteTextLog(Trim(s),LOG_GISUN);
            end;
            SetOwnerForm(gisun.CurAkt);
            {$ENDIF}
            OpenMessage('     ������ ������ ...          ','',0);
            {$IFDEF GIS_THREAD}
              EnterWorkerThread;
            {$ENDIF}
            try
              lOk:=FGisun.GetPersonalData(registerRequest, registerResponse, Log, Username, Password);
//              registerResponse.response.personal_data[i].data.courts.absents
            finally
//              gisun.CurAkt.WriteToDebug([FormatDateTime('hh:mm:ss',Now)+'  ���������� ������� RegInt  1']);
              {$IFDEF GIS_THREAD}
                LeaveWorkerThread;
              {$ENDIF}
              CloseMessage;
              {$IFDEF MY_PROJECT}
              gisun.CheckMainForm;
              {$ENDIF}
            end;
            {$IFDEF MY_PROJECT}
            gisun.WriteTextLog('���������� ������� ������', LOG_GISUN);
            {$ENDIF}
            if lOk then begin
               Result:=rrOk;
               Output:=CreateOutputTable(akGetPersonalData); //akGetPersonalData
               //��������� ��������� ���������
               if registerResponse.cover.parent_message_id<>FRequestMessageId then begin
                  Result:=rrAfterError;
                  FFaultError:='������ ������ � ���������. �� ��������� �������������� ��������� ������� � ������.';
                  Log.Add('!������: �� ��������� �������������� ���������')
               end;
               //
               FCoverMessageId:=Copy(registerResponse.cover.message_id,2,36);     //GUID ��������� ������
               FCoverMessageTime:=registerResponse.cover.message_time.AsDateTime; //����� ��������� ������
               Table:=TableList.Find(False, akGetPersonalData, opGet);
               Input.First;
               while not Input.Eof do begin
                  if Input.FieldByName('IS_PERSON').AsBoolean then begin
                     Person:=FindPersonData(Input.FieldByName('REQUEST_ID').AsString, registerResponse.response.personal_data);
                     //������������ ������
                     if Person<>nil then begin
                        Output.Append;
                        Output.FieldByName('IS_PERSON').AsBoolean:=Input.FieldByName('IS_PERSON').AsBoolean;
                        Output.FieldByName('PREFIX').AsString:=Input.FieldByName('PREFIX').AsString;
                        if Table<>nil then begin
                           Table.GetProp(Person, Output);
                        end;
                        Output.Post;
                        //-----------------------------------
                        if (person.data.family<>nil) and (GetPar('family', '0')='1') then begin   // load fam
                        {
    property father:      Array_Of_familyInfo
    property mather:      Array_Of_familyInfo
    property wife:        Array_Of_familyInfo
    property husband:     Array_Of_familyInfo
    property child:       Array_Of_familyInfo
                         }
                          Table.ChangePath('ResponsePerson.data','PersonalData'); // !!!
                          try
                            sss:=Input.FieldByName('PREFIX').AsString;
                            if (person.data.family.child<>nil) and (GetPar('child', '0')='1') then begin
                              for n:=Low(person.data.family.child) to HIGH(person.data.family.child) do begin
                                Output.Append;
                                Output.FieldByName('IS_PERSON').AsBoolean:=false;
                                Output.FieldByName('PREFIX').AsString:=sss+'_CHILD'+InttoStr(n+1);
                                Table.GetProp(person.data.family.child[n].person_data, Output);
                                Output.Post;
                              end;
                            end;
                            if (person.data.family.husband<>nil) and (GetPar('husband', '0')='1') then begin
                              Output.Append;
                              Output.FieldByName('IS_PERSON').AsBoolean:=false;
                              Output.FieldByName('PREFIX').AsString:=sss+'_HUSBAND';
                              Table.GetProp(person.data.family.husband.person_data, Output);
                              Output.Post;
                            end;
                            if (person.data.family.wife<>nil) and (GetPar('wife', '0')='1') then begin
                              Output.Append;
                              Output.FieldByName('IS_PERSON').AsBoolean:=false;
                              Output.FieldByName('PREFIX').AsString:=sss+'_WIFE';
                              Table.GetProp(person.data.family.wife.person_data, Output);
                              Output.Post;
                            end;
                            if (person.data.family.father<>nil) and (GetPar('father', '0')='1') then begin
                              Output.Append;
                              Output.FieldByName('IS_PERSON').AsBoolean:=false;
                              Output.FieldByName('PREFIX').AsString:=sss+'_FATHER';
                              Table.GetProp(person.data.family.father.person_data, Output);
                              Output.Post;
                            //  doc:=FindDokumentFromArr(person.data.family.father.documents, '0300', 82);   // load doc
                            //  showmessage(inttostr(HIGH(person.data.family.father.documents))+' '+doc.AuthorName+' '+doc.Number);
                            end;
                            if (person.data.family.mather<>nil) and (GetPar('mather', '0')='1') then begin
                              Output.Append;
                              Output.FieldByName('IS_PERSON').AsBoolean:=false;
                              Output.FieldByName('PREFIX').AsString:=sss+'_MATHER';
                              Table.GetProp(person.data.family.mather.person_data, Output);
                              Output.Post;
                            end;
                          finally
                            Table.ChangePath('PersonalData','ResponsePerson.data'); // !!!
                            Output.First;
                          end;
                        end;
                        //-------------------------------------------
                        if Assigned(FObrPersonalData) then begin
                          FObrPersonalData(Person.data, output, dokument, slPar);
                        end;
                     end
                     else begin
                        Result:=rrAfterError;
                        FFaultError:='������ ������ � ���������. �� ������ ������������� ������� ������������ ������.';
                        Log.Add('!������: �� ��������� �������������� �������� ������������ ������')
                     end;
                  end
                  else begin
                     Identif:=FindResponseIdentif(Input.FieldByName('REQUEST_ID').AsString, registerResponse.response.identif_number);
                     //������������ ������
                     if Identif<>nil then begin
                        Output.Append;
                        Output.FieldByName('IS_PERSON').AsBoolean:=Input.FieldByName('IS_PERSON').AsBoolean;
                        Output.FieldByName('PREFIX').AsString:=Input.FieldByName('PREFIX').AsString;
                        if Table<>nil then begin
                           Table.GetProp(Identif, Output)
                        end;
                        Output.Post;
                     end
                     else begin
                        Result:=rrAfterError;
                        FFaultError:='������ ������ � ���������. �� ������ ������������� ������� ������� ������.';
                        Log.Add('!������: �� ��������� �������������� �������� ������� ������')
                     end;
                  end;
                  Input.Next;
               end;
               //------ ������� ----------------------------
               {
               Output.First;
                sss:=IntToStr(Output.RecordCount)+#13#10;
                while not Output.Eof do begin
                  sss:=sss+Output.FieldByName('PREFIX').AsString+' '+Output.FieldByName('FAMILIA').AsString+' '+Output.FieldByName('NAME').AsString+' '+
                  Output.FieldByName('OTCH').AsString+' '+Output.FieldByName('DATER').AsString+
                  Output.FieldByName('ZH_N_KLAD').AsString+' '+Output.FieldByName('ZH_N_OBL').AsString+' '+Output.FieldByName('ZH_N_RAION').AsString+
                  #13#10;
                  Output.Next;
                end;
                Output.First;
                Showmessage(sss);
                }
                //-------------------------------------------
            end else begin
               Result:=rrFault;
               Temp:=TkbmMemTable.Create(nil);
               CreateAndCopyMemTable(FGisun.Error, Temp);
               Error:=TDataSet(Temp);
               FFaultError:=FGisun.FaultError;
            end;
            if FFaultError<>'' then begin
              {$IFDEF MY_PROJECT}
              gisun.WriteTextLog('������ ������ ������: '+FFaultError, LOG_GISUN);
              {$ENDIF}
            end;
//            gisun.CurAkt.WriteToDebug([FormatDateTime('hh:mm:ss',Now)+'  ���������� ������� RegInt  2']);
         finally
            registerRequest.Free;
            registerResponse.Free;
         end;
      end;
   end;
end;
*)


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
  Req.MakeBody(InDS);

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
  Req.MakeBody(InDS);

  Result := ApiClient.CallApi(Req);
end;




end.
