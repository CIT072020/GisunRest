unit mSecHeader;
interface

{$I Task.inc}

uses
   Windows, Dialogs, SysUtils, Classes, Forms,
   TasksEx, AsyncCalls, uTypes,
   InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns, FuncPr, NativeXML; //, ComObj, Variants;

type

   EETSPError = class(Exception);
   EAvestError = class(Exception);

   UsernameToken = class(TRemotable)
   private
      FUsername: WideString;
      FPassword: WideString;
   published
      property Username: WideString read FUsername write FUsername;
      property Password: WideString read FPassword write FPassword;
   end;

   UsernameTokenT = class(TSOAPHeader)
   private
      FUsername: WideString;
      FPassword: WideString;
   published
      property Username: WideString read FUsername write FUsername;
      property Password: WideString read FPassword write FPassword;
   end;

   Security = class(TSOAPHeader)
   private
      FUsernameToken: UsernameToken;
      {$IFDEF SIGN}
      FSign: WideString;
      FKey: WideString;
      FHash: WideString;
      FSignDate: WideString;
      {$ENDIF}
   public
      destructor Destroy; override;
   published
      property UsernameToken: UsernameToken read FUsernameToken write FUsernameToken;
      {$IFDEF SIGN}
      property Sign: WideString read FSign write FSign;
      property Key: WideString read FKey write FKey;
      property Hash: WideString read FHash write FHash;
      property SignDate: WideString read FSignDate write FSignDate;
      {$ENDIF}
   end;

function CreateHeader(Username: string; Password: string; lSpr:Boolean=false): TSOAPHeader;
function CreateETSP(var strSOAP:WideString; var strErr:String; lSpr:Boolean=false):Boolean;
function CheckHash(XMLDoc:TNativeXML; lSpr:Boolean=false):Boolean;

function GetActiveETSP_:Boolean;
procedure SetActiveETSP_(l:Boolean);
function GetActiveUserName_:Boolean;
procedure SetActiveUserName_(l:Boolean);
function IsCreateHeader:Boolean;

procedure SetActiveETSPSpr_(l:Boolean);
{
-------- SOAPHTTPTrans.pas ----------------------------
procedure  THTTPReqResp.Receive(Context: Integer; Resp: TStream; IsGet: Boolean);
...
  Check(not InternetReadFile(Pointer(Context), @S[1], Size, Downloaded));
  Resp.Write(S[1], Size);   в этом месте можно сохранить в файл то, что получили, сохранив строку S
...
}
implementation

uses  wsGisun, wsZags, wsClassif, uETSP2, uWideStrUtils, EncdDecd, StrUtils,
      {$IFDEF AVEST_GISUN} uAvest, {$ENDIF}
      uGisun;

var
  ActiveETSP:Boolean;
  ActiveETSPSpr:Boolean;
  ActiveUserName:Boolean;
  IsCreateHash:Boolean;
  IsCreateSignDate:Boolean;

//-------------------------------------------------------------------------------------------------------
{
function StringReplaceW(const S, OldPattern, NewPattern: WideString; Flags: TReplaceFlags): WideString;
var
    objRegExp: OleVariant;
    Pattern: WideString;
    i: Integer;
begin
    Pattern := '';
    for i := 1 to Length(OldPattern) do
        Pattern := Pattern+'\u'+IntToHex(Ord(OldPattern[i]), 4);

    objRegExp := CreateOleObject('VBScript.RegExp');
    try
        objRegExp.Pattern := Pattern;
        objRegExp.IgnoreCase := (rfIgnoreCase in Flags);
        objRegExp.Global := (rfReplaceAll in Flags);

        Result := objRegExp.Replace(S, NewPattern);
    finally
        objRegExp := Null;
    end;
end;
}
//--------------------------------------------------------------------------
function CreateHeader(Username: string; Password: string; lSpr:Boolean): TSOAPHeader;
var
   Security_: Security;
   UsernameToken_: UsernameToken;
begin
//   if ActiveUserName then begin
     UsernameToken_:=UsernameToken.Create();
     UsernameToken_.Username := Username;
     UsernameToken_.Password := Password;
//   end;     

   Security_:=Security.Create();

//   if ActiveUserName then begin
     Security_.UsernameToken:=UsernameToken_;
//   end else begin
//     Security_.UsernameToken:=nil;
//   end;

   Security_.Sign := '';
   Security_.Key := '';
   Security_.Hash := '';
   Security_.SignDate := '';
   {$IFDEF SIGN}
    if Gisun.IsCreateTagSign then begin
      Security_.Sign := '##Sign##';
      Security_.Key  := '##Key##';
      if IsCreateHash
        then Security_.Hash := '##Hash##';
    end;
    if IsCreateSignDate
      then Security_.SignDate := '##SignDate##';
   {$ENDIF}
   Result:=Security_;
end;
//----------------------------------------------------------------
function CreateETSP(var strSOAP:WideString; var strErr:String; lSpr:Boolean=false):Boolean;
var
  n,m:Integer;
  s:Utf8String;
  ss:WideString;
  CurKeyBoard:LongWord;
  sss:String;
  sOld:String;
  sUtf8:Utf8String;
  sKey,sSign,sHash:String;
  d:TDateTime;
//  XMLDoc:TNativeXML;
//  XMLNode:TXMLNode;
//  st:TStringStream;
  {$IFDEF AVEST_GISUN}
  res:DWORD;
  lOpenDefSession,l:Boolean;
  {$ENDIF}
begin
  strErr:='';
  {$IFDEF SIGN}
    if ActiveETSP and (not lSpr or ActiveETSPSpr) then begin
      Result:=true;
      ss:='';
      {
      St:=TStringStream.Create(strSOAP);
      XMLDoc:=TNativeXML.Create;
      XMLDoc.LoadFromStream(st);
      XMLNode:=XMLDoc.Root.FindNode('SOAP-ENV:BODY');
      if XMLNode<>nil then begin
        s:=XMLNode.WriteToString;
        s:=WideStringReplace(s, '</SOAP-ENV:Body>', '', []);
        s:=WideStringReplace(s, '<SOAP-ENV:Body>', '', []);
        MemoWrite(ExtractFilePath(Application.ExeName)+'Body1.xml', s);
      end;
      XMLDoc.Free;
      st.Free;
      }

      n:=Pos('<SOAP-ENV:BODY>',WideUpperCase(strSOAP));
      m:=Pos('</SOAP-ENV:BODY>',WideUpperCase(strSOAP));
      if (n>0) and (m>0) then begin
        ss:=MidStr(strSOAP,n+15,m-n-15);
      end;
      sUtf8:=Utf8Encode(ss);
      MemoWrite(ExtractFilePath(Application.ExeName)+'Body.xml', sUtf8);
//      ss:=DecodeString('QUFBQUFBQUFBQQ==')+chr(13)+chr(10)+DecodeString('QkJCQkJCQkJCQg==');
//      MemoWrite(ExtractFilePath(Application.ExeName)+'!!!.txt', ss);
      sKey:='';
      sSign:='';
      sHash:='';
      if Gisun.TypeETSP=ETSP_NIITZI then begin
        if (ETSP2<>nil) and ETSP2.Active then begin
  {
          if Gisun.CurAkt<>nil then begin
            sss:=Gisun.CurAkt.stBar.Panels[0].Text;
            Gisun.CurAkt.stBar.Panels[0].Text:='Формирование ЭЦП ...';
            Application.ProcessMessages;
          end;
  }
          // работает или нет поток созданный функцией EnterWorkerThread
          if _WorkedThread_ then begin
            EnterMainThread;
            try
              SetOwnerForm(Gisun.CurAkt);
              sOld:=getCurMessage;
              if sOld=''
                then OpenMessage('Формирование ЭЦП ...','',0)
                else ChangeMessage('Формирование ЭЦП ...');
            finally
              LeaveMainThread;
            end;
          end else begin
            SetOwnerForm(Gisun.CurAkt);
    //        OpenMessage('Формирование ЭЦП ...','',0);
            sOld:=getCurMessage;
            if sOld=''
              then OpenMessage('Формирование ЭЦП ...','',0)
              else ChangeMessage('Формирование ЭЦП ...');
          end;
          try
            ETSP2.PIN:=Gisun.RegInt.PIN;
            sKey:=ETSP2.GetSOK;
            gisun.WriteTextLog('ЭЦП прочитать "СОК"  '+ETSP2.LastError,LOG_GISUN);
            if ETSP2.Debug then begin
              MemoWrite(ExtractFilePath(Application.ExeName)+'cert.cer', sKey);
            end;
            sSign:=ETSP2.Sign(Length(sUtf8),sUtf8);
            gisun.WriteTextLog('ЭЦП подписать '+ETSP2.LastError,LOG_GISUN);
            if ETSP2.Debug then begin
              MemoWrite(ExtractFilePath(Application.ExeName)+'zchannel sign', sSign);
            end;
          finally                                
            // работает или нет поток созданный функцией EnterWorkerThread
            if _WorkedThread_ then begin
              EnterMainThread;
              try
                if sOld=''
                  then CloseMessage
                  else ChangeMessage(sOld);
              finally
                LeaveMainThread;
              end;
            end else begin
              if sOld=''
                then CloseMessage
                else ChangeMessage(sOld);
  //          CloseMessage;
            end;
          end;
          {
          if Gisun.CurAkt<>nil then begin
            Gisun.CurAkt.stBar.Panels[0].Text:=sss;
            Application.ProcessMessages;
          end;
          }

  //        if Gisun.CurAkt<>nil
  //          then Gisun.CurAkt.BringToFront;

          Application.ProcessMessages;
          if ETSP2.LastError<>'' then begin
            Result:=false;
            strErr:=ETSP2.LastError;
            if strErr<>'' then begin
              CloseMessage;
              raise EETSPError.Create(strErr);
            end;
          end;
        end;
// !!!       if Pos('BEGIN CERTIFICATE',sKey)=0  // !!!
// !!!         then sKey:=EncodeString(sKey);    // если не в Base64 то переводим в Base64
        strSOAP := WideStringReplace(strSOAP, '##Sign##', EncodeString(sSign), []);
// !!!       strSOAP := WideStringReplace(strSOAP, '##Key##', sKey, []);
        strSOAP := WideStringReplace(strSOAP, '##Key##', EncodeString(sKey), []);
        strSOAP := WideStringReplace(strSOAP, '##Hash##', EncodeString(sHash), []);
      end else begin
      {$IFDEF AVEST_GISUN}
        if (Avest<>nil) and Avest.IsActive then begin
          sOld:=getCurMessage;
          if sOld<>''
            then CloseMessage();
          CurKeyBoard:=GetTypeKeyBoard;
          ActivateENGKeyboard;                                             
//          l:=Avest.FDeleteCRLF;
//          Avest.FDeleteCRLF:=false;

          if Gisun.AvestEnabledPIN and (Gisun.RegInt.PIN<>'') then begin
            Avest.SetLoginParams(Gisun.RegInt.PIN, '');
          end else begin
            Gisun.RegInt.PIN:='';
            Avest.SetLoginParams('', '');
          end;
          sKey:='+';  // !!! вернуть сертификат в переменную sKey !!!
          res:=Avest.SignText(ANSIString(sUtf8), sSign, sKey, Gisun.OpenDefSession, Gisun.AvestSignType, true);
//          res:=Avest.SignTextSimple(ANSIString(sUtf8), sSign, sKey, Gisun.OpenDefSession, '');
          if CurKeyBoard>0 then
            ActivateKeyboardLayout(CurKeyBoard,KLF_ACTIVATE);
          if sKey='+' then sKey:=''; // !!!
//          Avest.FDeleteCRLF:=l;
          if res=0 then begin
            if Avest.Debug then begin
              MemoWrite('sign',sSign);
              MemoWrite('cert.cer',sKey);
            end;
{
            res:=Avest.VerifyTextSimple(sUtf8, sSign, Gisun.OpenDefSession, '');
            if res<>0 then begin
              s:=Avest.ErrorInfo(res);
              PutError(s);
            end;
}
          end else begin
            Result:=false;
            s:=Avest.ErrorInfo(res);
            gisun.WriteTextLog('ошибка ЭЦП: '+s,LOG_GISUN);
            raise EAvestError.Create(s);
          end;
          SetOwnerForm(Gisun.CurAkt);
          if sOld<>''
            then OpenMessage(sOld,'',0);
          Application.ProcessMessages;
        end;
        strSOAP := WideStringReplace(strSOAP, '##Sign##', sSign, []);  // !!! перевод в в BASE64 уже выполнен в  Avest.SignText
        strSOAP := WideStringReplace(strSOAP, '##Key##',  sKey, []);   // !!! перевод в в BASE64 уже выполнен в  Avest.SignText
//        strSOAP := WideStringReplace(strSOAP, '##Sign##', EncodeString(sSign), []);
//        strSOAP := WideStringReplace(strSOAP, '##Key##',  EncodeString(sKey), []);

//        MemoRead('s2.cer',sKey);
//        strSOAP := WideStringReplace(strSOAP, '##Key##',  sKey, []);
        strSOAP := WideStringReplace(strSOAP, '##Hash##', sHash, []);
      {$ENDIF}
      end;
      d:=Now;
      if IsCreateSignDate
       then strSOAP:=WideStringReplace(strSOAP, '##SignDate##', FormatDateTime('yyyy-mm-dd',d)+'T'+FormatDateTime('hh:mm:ss',d), []);
//         then strSOAP:=WideStringReplace(strSOAP, '##SignDate##', EncodeString(FormatDateTime('yyyy-mm-dd',d)+'T'+FormatDateTime('hh:mm:ss',d)), []);

        //---- !!! ----------------------------------------------------------------------
        //  из-за ошибки в RIO.pas
        //  procedure TRIO.DoBeforeExecute(const MethodName: string; Request: TStream);
        //              ...
        //       StrStrm := TStringStream.Create(string(ReqWideStr));
        //
        // надо  StrStrm := TStringStream.Create(string(UTF8Encode(ReqWideStr)));
//        strSOAP := UTF8Encode(strSOAP);
        //-------------------------------------------------------------------------------

    end else begin      //==========================================================
      Result:=true;
      strSOAP := WideStringReplace(strSOAP, '##Sign##', '', []);
      strSOAP := WideStringReplace(strSOAP, '##Key##', '', []);
      strSOAP := WideStringReplace(strSOAP, '##Hash##', '', []);
      d:=Now;
      if IsCreateSignDate
        then strSOAP:=WideStringReplace(strSOAP, '##SignDate##', FormatDateTime('yyyy-mm-dd',d)+'T'+FormatDateTime('hh:mm:ss',d), []);
    end;
  {$ELSE}
    Result:=true;
  {$ENDIF}
end;

//-------------------------------------------------------------------
procedure WriteWideString(const ws: WideString; stream: TStream);
var
  nChars: LongInt;
begin
  nChars := Length(ws);
  stream.WriteBuffer(ws[1], nChars * SizeOf(ws[1]));
end;
//-------------------------------------------------------------------
procedure WideString2File(sFile:String; const ws: WideString);
var
  fs:TFileStream;
  L:LongInt;
begin
  fs:=TFileStream.Create(sFile, fmCreate);
  L := Length(ws);
  fs.WriteBuffer(ws[1], L * SizeOf(WideChar));
  fs.Free;
end;
//------------------------------------------------------------------
function ReadWideString(stream: TStream): WideString;
var
  nChars: LongInt;
begin
  stream.ReadBuffer(nChars, SizeOf(nChars));
  SetLength(Result, nChars);
  if nChars > 0 then
    stream.ReadBuffer(Result[1], nChars * SizeOf(Result[1]));
end;
//----------------------------------------------------------------
function CheckHash(XMLDoc:TNativeXML; lSpr:Boolean):Boolean;
var
  n,m:Integer;
  sUtf8:Utf8String;
  sHash,sCalcHash:String;
  XMLNode:TXMLNode;
//  ws:WideString;
begin
  {$IFDEF SIGN}
    if ActiveETSP and (not lSpr or ActiveETSPSpr) then begin
      Result:=true;
      sHash:='';
      sCalcHash:='';
      {
      XMLNode:=XMLDoc.Root.FindNode('Sec:Header');
      if XMLNode<>nil then begin
      }
        XMLNode:=XMLDoc.Root.FindNode('wsse:Hash');
        if XMLNode<>nil then begin
          sHash:=XMLNode.ValueAsString;
        end;
      {
      end;
      }

// function UTF8Decode(const S: UTF8String): WideString;
// function UTF8Encode(const WS: WideString): UTF8String;

      if sHash='' then begin
//        PutError('Не найдено хеш-значение, секция <wsse:Hash>', Gisun.CurAkt);
      end else begin
//        sHash1:=DecodeString(sHash);
        XMLNode:=XMLDoc.Root.FindNode('S:Body');
        sUtf8:='';
        if XMLNode<>nil then begin
          sUtf8:=XMLNode.WriteToString;
          sUtf8:=sdUTF8StringReplace(sUtf8, '</S:Body>', '');
          sUtf8:=sdUTF8StringReplace(sUtf8, '<S:Body>', '');
        end;
        MemoWrite(ExtractFilePath(Application.ExeName)+'Body_ответ.xml', sUtf8);
        {
        if s='' then begin
          PutError('Не найдена секция <S:Body>', Gisun.CurAkt);
        end;
        }
        if (ETSP2<>nil) and ETSP2.Active and (sUtf8<>'') then begin
//          ws:=UTF8Decode(s);
          ETSP2.PIN:=Gisun.RegInt.PIN;
          sCalcHash:=ETSP2.Hash(Length(sUtf8),sUtf8);
          sCalcHash:=EncodeString(sCalcHash);  // приводим к Base64
          if (sCalcHash<>'') and (sHash<>'') and (sCalcHash<>sHash) then begin
            gisun.WriteTextLog('Ошибка полученных данных: неверное Хеш-значение'+ //, Gisun.CurAkt);
                 'полученный:['+sHash+']   рассчитанный  :['+sCalcHash+']',  LOG_GISUN);
//                 'декодированный:'+sHash1+chr(13)+   // StrToHex(sHash1,' ')
            Result:=false;
          end else begin
           {
            ShowMessageCont('Хеш-значение верное'+ //, Gisun.CurAkt);
                 'полученный    :'+sHash+chr(13)+
                 'рассчитанный  :'+sCalcHash,
                  Gisun.CurAkt);
            Result:=false;
           }
          end;
        end;
      end;
    end else begin
      Result:=true;
    end;
  {$ELSE}
    Result:=true;
  {$ENDIF}
end;

//--------------------------------------------------------------------------
function IsCreateHeader:Boolean;
begin
  if ActiveETSP or ActiveUserName
    then Result:=true
    else Result:=false;
end;

//--------------------------------------------------------------------------
function GetActiveETSP_:Boolean;
begin
  Result:=ActiveETSP;
end;
//--------------------------------------------------------------------------
procedure SetActiveETSP_(l:Boolean);
begin
  ActiveETSP:=l;
end;
procedure SetActiveETSPSpr_(l:Boolean);
begin
  ActiveETSPSpr:=l;
end;
//--------------------------------------------------------------------------
function GetActiveUserName_:Boolean;
begin
  Result:=ActiveUserName;
end;
//--------------------------------------------------------------------------
procedure SetActiveUserName_(l:Boolean);
begin
  ActiveUserName:=l;
end;

//--------------------------------------------------------------------------
destructor Security.Destroy;
begin
   FreeAndNil(FUsernameToken);
   inherited Destroy;
end;

initialization
   ActiveETSP:=false;
   ActiveETSPSpr:=false;
   ActiveUserName:=false;
   IsCreateHash:=true;
//   IsCreateSignDate:=false;
   IsCreateSignDate:=true;

   InvRegistry.RegisterHeaderClass(TypeInfo(GisunCommonWs), Security, 'Security', 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd');
   InvRegistry.RegisterHeaderClass(TypeInfo(ZagsWS), Security, 'Security', 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd');
   InvRegistry.RegisterHeaderClass(TypeInfo(ClassifWS), Security, 'Security', 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd');

   RemClassRegistry.RegisterXSClass(UsernameToken, 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd', 'UsernameToken');
   RemClassRegistry.RegisterXSClass(Security, 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd', 'Security');

end.
