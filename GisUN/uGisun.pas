unit uGisun;

interface

{$I Task.inc}

uses
  Windows, Messages, FileCtrl, SysUtils, Math, Classes, WinInet, Controls, Forms, db, Dialogs, ifpii_dbfunc, dbFunc, uCheckKod, DateUtils,
  fSimpleD, uJSON, IdHTTP, IdTCPConnection, ShellApi, uTypes, kbmMemTable, QStrings,
  TasksEx, AsyncCalls, NewDialogs,
  uDataSet2XML, mRegInt, FuncPr, uProjectAll, MetaTask, OpisEdit, DBConsts, Graphics, Variants, mPermit, fLogon, fSetPropUsers,
  {$IFDEF GISUN2} mClassif, {$ENDIF}
  {$IFDEF AVEST_GISUN} uAvest, {$ENDIF}
  EncdDecd, fShowErrorGISUN;

const
  ST_ACTIVE='1';
  ST_DEATH='2';
  ST_ISKL='3';
  ST_INOST='4';
  ST_FIKT='5';

  FIRST_DATE_CLASSIF='1990-01-01';
  LOG_GISUN='gisrn';

  DEU_GDR='908';     // ���������� �����, ������ ���, � ����������� ��������

  QUERY_INFO='88';   // ������ ����������
  PROV_INFO='89';    // �������������� ����������

{ ������������� -2
    8  ����� 19-20 (��������, �������
   22 ��������������
   88 ������ �� �������������� ����������
   89 �������������� ����������
   92 ������������ �����������
   95 �� ���������� �������� �����������
  101 ���������� � ����� �����������
  103 ������ �� ����� � ��������������
}
  AKT_ZAH='101';      //
  AKT_OPEKA='103';    // !!!
  AKT_POPECH='103';   //

  DOC_OPEKA_RESH=4;

type

  TGorodR=record
    Full:String;
    RnGorod:String;
    Ulica:String;
    Full_B:String;
    RnGorod_B:String;
    Ulica_B:String;
    Dom:String;
    Korp:String;
    Kv:String;
  end;

  TPunktMesto=record
    Name:String;
    Name_B:String;
    Type_Kod:String;
    Type_Kod_B:String;
  end;

  TGisun = class(TObject)
  private
    FEnabledReloadETSP:Boolean;
    FVersionINI:Integer;
    FRegInt: TRegInt;
    FMessageSource: String;
    FConstTypeSource:String;
    FConstMessageSource: String;
    FTypeMessage: String;
    FTypeAkt: String;
    FIsDebug: Boolean;
    FIsEnabled: Boolean;
    FLoadGrag: Boolean;
    FTypeEnableControl: Integer;
    FTimeOut: Integer;
    FIsDecodePathError: Boolean;
//    FIsActive: Boolean;
    FIsCheckBelNazv: Boolean;
    FIsCheckQuery: Boolean;
    FDbUserAsGIS:Boolean;
    FPostUserName:Boolean;
    FOrganZagsAsMessageSource:Boolean;
    FActiveETSP:Boolean;
    FAllCreateTagSign:Boolean;   // ������ ��������� ���� <Sign> <Key> <Hash> ��� ������ ��� �������� �������
    FTypeETSP:Integer;
    FCheckUSB:Boolean;
    FLoadSemStatus:Boolean;
    FEnabledSimPin:Boolean;
    FSprWithETSP:Boolean;  // �������� � ����������� ���
    FSprThread:Boolean;
    FOpenDefSession:Boolean;
    FAvestEnabledPIN:Boolean;
    FAvestIgnoreCOC:Boolean;
    FAvestSignType:Integer;
    procedure SetRegInt(const Value: TRegInt);
    procedure SetMessageSource(const Value: String);
    procedure SetTypeMessage(const Value: String);
    procedure SetTypeAkt(const Value: String);
    procedure SetIsDebug(const Value: Boolean);
    procedure SetIsEnabled(const Value: Boolean);
    procedure SetLoadGrag(const Value: Boolean);
    procedure SetTypeEnableControl(const Value: Integer);
    procedure SetIsDecodePathError(const Value: Boolean);
//    procedure SetIsActive(const Value: Boolean);
    procedure SetIsCheckBelNazv(const Value: Boolean);
    procedure SetIsCheckQuery(const Value: Boolean);
    procedure SetDbUserAsGIS(const Value: Boolean);
    procedure SetPostUserName(const Value: Boolean);
    procedure SetActiveETSP(const Value: Boolean);
    procedure SetTypeETSP(const Value: Integer);
    function GetTypeETSP(sUserName:String):Integer;

    procedure SetOpenDefSession(const Value: Boolean);
    procedure SetAvestEnabledPIN(const Value: Boolean);
    procedure SetAvestIgnoreCOC(const Value: Boolean);
    procedure SetAvestSignType(const Value: Integer);
  public
    FEnableTextLog:Boolean;
    FEnableRegisterZah:Boolean;
    FEnableRegisterOpeka:Boolean;
    FCheckZaprosZah:Boolean;
    FPathIni:String;
    DownloadUrl : string;
    NomerUpdate:String;
    NameUpdate:String;
    NameFileUpdate:String;
    //-----�������������� --------------------------------
    ClassifUrl : String;
    ClassifProxy : String;
    //----------------------------------------------------
    OsnPrSm : Boolean; // ���������� � ��� �� �������� ������� ������
    arrTypeAkt : array of Integer;   // ������ ��������� ��� ������ � ��� �� ������� �������
    IsVisibleTmpOff:Boolean;  // ������ � �������� ��������� ���������� ��� ��
    AllSpr  : TDataSet;    // ����������� ��� ��
    Input   : TDataSet;
    Output  : TDataSet;
    Error   : TDataSet;
    Female  : Boolean;       // ����������� ������ � ������
    FemaleU : Boolean;       // ����������� ������ �� ���������������
    Male    : Boolean;       // ����������� ������ �� ����
    MaleU   : Boolean;       // ����������� ������ �� �����������
    Child   : Boolean;       // ����������� ������ � �������
    Person  : Boolean;       // ����������� ������ � ��������
    DeclMen  : Boolean;      // ����������� ������ � ���������
    ChildIdentif: Boolean;  // ����������� �� ��� �������
    RunExchange : Boolean;  // ��������� ������������� ��� ���
    CurAkt : TfmSimpleD;
    HandleErrorToString:Boolean; // � ������� HandleError ������ � ������ ErrorString
    ErrorString:String;          //

    CheckCurDate : Boolean;      // �������������� ��� �������� � ������� ���� ������� ������ � ���� �������������
    CheckRegisterFIO:Boolean;
    CheckRegisterAdres:Boolean;
    CheckAteGis:Boolean;

{!!!}DefaultPoleGrn : Integer;   // �������� ��� ���� POLE_GRN ���� �� ���� ������������ ��������������
    RequestResult : TRequestResult;
    IsWriteLogToBase : Boolean;
    property IsCheckQuery:Boolean read FIsCheckQuery write SetIsCheckQuery;
    property IsEnabled:Boolean read FIsEnabled write SetIsEnabled;    //
//    property IsActive:Boolean read FIsActive write SetIsActive;    //
    property IsDebug : Boolean read FIsDebug write SetIsDebug;
    property TypeAkt : String read FTypeAkt write SetTypeAkt;
    property TypeMessage : String read FTypeMessage write SetTypeMessage;
    property RegInt : TRegInt read FRegInt write SetRegInt;
    property MessageSource : String read FMessageSource write SetMessageSource;
    property ConstMessageSource : String read FConstMessageSource;
    property ConstTypeSource : String read FConstTypeSource;
    property AvestEnabledPIN:Boolean read FAvestEnabledPIN write SetAvestEnabledPIN;
    property AvestIgnoreCOC:Boolean read FAvestIgnoreCOC write SetAvestIgnoreCOC;
    property OpenDefSession:Boolean read FOpenDefSession write SetOpenDefSession;
    property AvestSignType:Integer read FAvestSignType write SetAvestSignType;

    property TimeOut:Integer read FTimeOut write FTimeOut;
    property DbUserAsGIS:Boolean read FDbUserAsGIS write SetDbUserAsGIS;
    property PostUserName:Boolean read FPostUserName write SetPostUserName;
    property ActiveETSP:Boolean read FActiveETSP write SetActiveETSP;
    property TypeETSP:Integer read FTypeETSP write SetTypeETSP;
    function NameETSP:String;
    function IsCreateTagSign:Boolean;   // ��������� ���� <Sign> <Hash> <Key>
    property OrganZagsAsMessageSource:Boolean read FOrganZagsAsMessageSource write FOrganZagsAsMessageSource;
    function CheckMessageSource(f:TfmSimpleD; var sErr:String):Boolean;
    procedure CheckTabStop(Control : TWinControl; lCheck:Boolean);
    procedure CheckMainForm;
    function CheckUSB:Boolean;
    function LoadSemStatus:Boolean;
    function EnabledSimPin:Boolean;
    //----------------------
    function GetTypeMessageSource : Integer;
    property IsCheckBelNazv:Boolean read FIsCheckBelNazv write SetIsCheckBelNazv;
    property LoadGrag : Boolean read FLoadGrag write SetLoadGrag; // ������ �� ����� �����������
    property TypeEnableControl:Integer read FTypeEnableControl write SetTypeEnableControl;
    property IsDecodePathError: Boolean read FIsDecodePathError write SetIsDecodePathError;

    function GetMessageOk:String;
//    function CheckUpdateProg(NAME_PROG:string; var strErr:String):String;
    function DowloadUpdateProg(strURL:string; var strErr:String):Boolean;

    //-----�������������� --------------------------------
    function SprWithETSP:Boolean;  // �������� � ����������� ���
    function GetChangeATE(d:TDateTime; lGisun:Boolean=true):Integer;
    function GetFullATE(nSize:Integer):Integer;
    function GetChangeClassif(nType:Integer; d:TDateTime; lGisun:Boolean; lSaveChange:Boolean=true) : Integer;
    function LoadChangeClassif(nType:Integer; d:TDateTime; ds:TDataSet) : Boolean;
    function GetLastDateChangeClassif(nType:Integer) : TDateTime;
    //----------------------------------------------------

    procedure ShowErrorDataSet;
    procedure ShowMessageErr(strErr:String);

    procedure HandleError(RequestResult: TRequestResult; ActKind: TActKind; Operation: TOperation; Input, Output, Error: TDataSet; FaultError: string);
    function GetPersonalData(strIDENTIF : String; strPol : String) : Boolean;
    procedure ClearDataSets;
    procedure SetPoleGrn(Field: TField; Value: Integer; SubValue: Integer=-1; FieldDate:TField=nil); //overload;
//    procedure SetPoleGrn(Field: TField; Value, SubValue: Integer); overload;
    function GetPoleGrn(ds: TDataSet): Integer; overload;
    function GetPoleGrn(Field: TField): Integer; overload;
    function GetPoleGrn(Value: Integer): Integer; overload;
    function GetPoleGrn(Value: string): Integer; overload;
    function GetGorodR( ds : TDataSet) : String;
    function GetGorodREx( ds : TDataSet; lAddRnGor:Boolean=true; sDelim:String=', ') : TGorodR;
    function GetPoleGrnSub(Value: Integer): Integer;
    procedure SetDateTime(DstField, SrcField: TField);
    procedure SetUserNameToken(sUserName:String; sPassword:String; strPIN:String);
    procedure ClearPassword;
    procedure GetDecodePathError(dsError:TDataSet; IsInput: Boolean; ActKind: TActKind; Operation: TOperation);
    function IsEnableTypeAkt(nType:Integer; lVosstan:Boolean):Boolean;
    function CheckLogon(lSpr:Boolean=false): Boolean;

    function Version:Integer;
    function VersionIni:Integer;

    //-- ��� ��������� --------------------------------------------------
    function Code_Dokument(strType : String) : String;
    function Decode_Dokument(strType : String) : String;
    function GetEmptyDate:String;

    procedure WriteTextLog(sOper:String;sFile:String);
    procedure CheckSizeFileLog(sFile:String; nSizeMB:Integer);

    procedure LogToTableLog(Akt:TfmSimpleD; sOper:String);
    function LoadIdentifData(sl:TStringList; Dok:TDataSet; slPar:TStringList):TDataSet;
    function LoadPersonalIdentif(sl:TStringList; sFamilia:String; sName:String; sOtch:String; dDateR:TDateTime; nTypeDate:Integer=0):Boolean;
//    function LoadPersonalData1(sIDENTIF:String; var arr: TCurrentRecord): Boolean;

    //-- ��� ����������� ������ --------------------------------------------------
//    function Code_TypePunkt(strType : String) : String;
//    function Decode_TypePunkt(strType : String) : String;

    //--- �����
    function  Decode35_My_TypePunkt2(sTypeRN:String):String;
    function  Decode35_My_TypePunkt(var sTypeRN:String; var sType:String; var sName:String; var sNameBel:String; var lGorod:Boolean):Boolean;
    procedure CodePunkt_MestoRogd(dsDokZ: TDataSet; fldTipZ,fldGorodZ,fldGorodBelZ: String; dsPerson: TDataSet; fldTipP,fldGorodP,fldGorodBelP: String);

    procedure DecodePunkt_MestoRogd(dsDokZ: TDataSet; fldTipZ,fldGorodZ,fldGorodBelZ: String; dsPerson: TDataSet);
    function  DecodePunkt_MestoRogdEx(dsPerson: TDataSet) : TPunktMesto;

    function DecodePunkt_MestoSmertEx(dsPerson: TDataSet):TPunktMesto;
    function DecodeObl_MestoSmert( dsDokZ:TDataSet; fldObl,fldOblTip,fldOblBel: String; dsPerson:TDataSet) : String;

    function  AdresGitIsEmpty(dsPerson: TDataSet):Boolean;
    procedure DecodePunkt_MestoGit(dsDokZ: TDataSet; fldTipZ,fldGorodZ,fldGorodBelZ: String; dsPerson: TDataSet);
    function  DecodePunkt_MestoGitEx(dsPerson: TDataSet) : TPunktMesto;
//-------------------------------------------------------------------
    function getSoato(ds:TDataSet; var AteID:Integer; var strSoato:String; var strName:String):Boolean;
    //-- ��� --------------------------------------------------
    function Code_Pol(strPol : String) : String;
    function Decode_Pol(strPol : String) : String;
    //-- ��� ������ -------------------------------------------
    function Code_Alfa3Ex(strKod: String; fldLex:TField; fldLexB:TField): String;
    function Code_Alfa3( strKod : String) : String;
    function Decode_Alfa3( strKod : String; strName:String) : String;
    //--------------------------------------------------------
    function Code_Status(dsDok:TDataSet; sGrag,sStatus:String; sFamilia:String=''):String;
    //-- ���� -------------------------------------------
    function  Code_Date( d: TDateTime; fldType : TField ) : String; overload;
    function  Code_Date( d: TDateTime; nType : Integer ) : String; overload;
    procedure Decode_Date( sDate : String; fldDate, fldType : TField; sName:String='');
    function Decode_Date2( sDate : String; var dDate:TDateTime; var nType:Integer; sName:String=''):Boolean;
    //-- ������ ����������� � -----------------------------------
    function Code_SmPosl( SmPosl: Integer ) : String;
    //-- �������  -----------------------------------
    function Decode_Obl( Obl,OblB: String ) : String;

    procedure CodeObl_MestoRogd( dsDokZ:TDataSet; fldObl,fldOblTip,fldOblBel: String;
                                 dsPerson: TDataSet; fldOblP,fldOblBelP : String);

    function DecodeObl_MestoGit( dsDokZ:TDataSet; fldObl,fldOblTip,fldOblBel: String; dsPerson:TDataSet) : String;
    function DecodeObl_MestoRogd( dsDokZ:TDataSet; fldObl,fldOblTip,fldOblBel: String; dsPerson:TDataSet) : String;

    function G_UpperCase(s:String) : String;
    function CaseFIO(s:String) : String;
    function CaseAdres(s:String) : String;
    function CaseUlica(sUl : String) : String;

    function CheckAllAkt(Simple: TfmSimpleD; var strError:String; lNotSvid:Boolean=false): Boolean;

    //-- �����  -----------------------------------
    function Decode_Raion( Raion,RaionB: String ) : String;
    //-- ����� ������ -----------------------------------
    function Decode_RnGorod(ds:TDataSet; arrFields : array of TVarRec; var strSoato:String):String;

    //---------------------------------------------------------
    function DokumentWithIN(nDok:Integer): Boolean;
//    procedure DataSetAllFieldUpper(ds:TDataSet);
    procedure CheckPovtorToGis(f:TfmSimpleD);
    function SetDokSvid(f:TfmSimpleD; ds:TDataSet; sAdd:String=''; lNotSvid:Boolean=false):String;
    function SetOrganAkt(f:TfmSimpleD; ds:TDataSet):String;

    // ������ ��
    function GetOnlyIdentif(nCount:Integer; sl:TStringList; lShow:Boolean) : Integer;
    function GetOnlyIdentifList(nCount:Integer; sl:TStringList; lShow:Boolean) : Integer;
    //������ ���� � ��������
    function SetTypeMessageAktBirth( Akt : TfmSimpleD; var strError : String) : Boolean;
    function GetIdentifChild( Akt : TfmSimpleD) : Boolean;
    function RegisterChild( Akt : TfmSimpleD; lNotSvid:Boolean) : Boolean;
    procedure CheckAkt(Simple: TfmSimpleD);
    function OtmenaAkt(Simple: TfmSimpleD): Boolean;
    function NotOtmenaAkt(Simple: TfmSimpleD): Boolean;
    function RegisterPovtorAkt(Simple: TfmSimpleD): Boolean;
    function ChangeAkt(Simple: TfmSimpleD): Boolean;
    function RegisterAkt(Simple: TfmSimpleD; lNotSvid:Boolean): Boolean;
    //---------------------------------------------------------
    //��������������� ������ ���� � ��������
    function CheckIdentif(Simple: TfmSimpleD; var Error: string): Boolean;
    function SetTypeMessageAktBirthV(Simple: TfmSimpleD; var Error: string ): Boolean;
    function GetIdentifChildV(Simple: TfmSimpleD): Boolean;
    function RegisterChildV(Simple: TfmSimpleD): Boolean;
    procedure CheckAktV(Simple: TfmSimpleD);
    //---------------------------------------------------------
    //������ ���� �� ������������ ���������
    function SetTypeMessageAktUstOtc( Akt : TfmSimpleD; var strError : String ) : Boolean;
    function GetUstOtc( Akt : TfmSimpleD) : Boolean;
    function RegisterUstOtc( Akt : TfmSimpleD) : Boolean;
    procedure CheckUstOtc(Simple: TfmSimpleD);
    //---------------------------------------------------------
    //������ ���� �� ������������ �����������
    function SetTypeMessageAktUstMat( Akt : TfmSimpleD; var strError : String ) : Boolean;
    function GetUstMat( Akt : TfmSimpleD) : Boolean;
    function RegisterUstMat( Akt : TfmSimpleD) : Boolean;
    procedure CheckUstMat(Simple: TfmSimpleD);
    //---------------------------------------------------------
    //������ ���� � �����
    function SetTypeMessageAktMarriage( Akt : TfmSimpleD; var strError : String ) : Boolean;
    procedure AktBrakAddObrab(data: TPersonalData_; dsOutPut:TDataSet; dsDokument:TDataSet; slPar:TStringList);
    function GetMarriage( Akt : TfmSimpleD) : Boolean;
    function RegisterMarriage( Akt : TfmSimpleD) : Boolean;
    procedure CheckMarriage(Simple: TfmSimpleD);
    //---------------------------------------------------------
    //������ ���� � ������
    function SetTypeMessageAktSmert( Akt : TfmSimpleD; var strError : String ) : Boolean;
    function GetSmert( Akt : TfmSimpleD) : Boolean;
    function RegisterSmert( Akt : TfmSimpleD; lEmptyPrSmert:Boolean) : Boolean;
    procedure CheckSmert(Simple: TfmSimpleD);
    //--------------------------------------
    //������ ���� � �������
    function SetTypeMessageAktRastBrak( Akt : TfmSimpleD; var strError : String ) : Boolean;
    function GetRastBrak( Akt : TfmSimpleD) : Boolean;
    function RegisterRastBrak( Akt : TfmSimpleD) : Boolean;
    procedure CheckRastBrak(Simple: TfmSimpleD);
    //--------------------------------------
    //������ ���� �� �����������
    function SetTypeMessageAktAdopt( Akt : TfmSimpleD; var strError : String ) : Boolean;
    function GetAdopt( Akt : TfmSimpleD) : Boolean;
    function RegisterAdopt( Akt : TfmSimpleD) : Boolean;
    procedure CheckAdopt(Simple: TfmSimpleD);
    //--------------------------------------
    //������ ���� � �������� �����
    function SetTypeMessageAktChName( Akt : TfmSimpleD; var strError : String ) : Boolean;
    function GetChName( Akt : TfmSimpleD) : Boolean;
    function RegisterChName( Akt : TfmSimpleD) : Boolean;
    procedure CheckChName(Simple: TfmSimpleD);
    //---------------------------------------------------------
    //��������������� ������ ���� � �����
    function SetTypeMessageAktMarriageV( Akt : TfmSimpleD; var strError : String ) : Boolean;
    function GetMarriageV( Akt : TfmSimpleD) : Boolean;
    function RegisterMarriageV( Akt : TfmSimpleD) : Boolean;
    procedure CheckMarriageV( Akt : TfmSimpleD);
    //---------------------------------------------------------
    //��������������� ������ ���� � ������
    function SetTypeMessageAktSmertV( Akt : TfmSimpleD; var strError : String ) : Boolean;
    function GetSmertV( Akt : TfmSimpleD) : Boolean;
    function RegisterSmertV( Akt : TfmSimpleD) : Boolean;
    procedure CheckSmertV( Akt : TfmSimpleD);
    //--------------------------------------
    //��� � �����������
    {$IFDEF ADD_ZAH}
    function SetTypeMessageAktZAH( Akt : TfmSimpleD; var strError : String ) : Boolean;
    function GetAktZAH( Akt : TfmSimpleD) : Boolean;
    function RegisterAktZAH(Akt: TfmSimpleD; lEmptyPrSmert:Boolean) : Boolean;
    procedure CheckAktZAH(Simple: TfmSimpleD);
    {$ENDIF}
    //---------------------------------------------------------
    //����� � ��������������
    {$IFDEF ADD_OPEKA}
    function SetTypeMessageAktOpeka( Akt : TfmSimpleD; var strError : String ) : Boolean;
    procedure AktOpekaAddObrab(data: TPersonalData_; dsOutPut:TDataSet; dsDokument:TDataSet; slPar:TStringList);
    function GetAktOpeka( Akt : TfmSimpleD) : Boolean;
    function RegisterAktOpeka(Akt: TfmSimpleD) : Boolean;
    procedure CheckAktOpeka(Simple: TfmSimpleD);
    {$ENDIF}

    //---------------------------------------------------------
    function AdresToString(ds:TDataSet): String;

    function Status2Str(sStatus:String; sDef:String=''):String;

    function SeekClassGisun(nType:Integer; sID:String):Boolean;
    function GetValueClassGisun(sField:String):Variant;
    function SetParamsGISUN(strPathINI:String) : Boolean;
    function ReloadETSP : Boolean;

    function LinkUserToETSP(sUserName:String;lQuest:Boolean):Boolean;
    procedure DropLinkUser(sUserName:String);
    function SaveCertToSChannel:Boolean;
    procedure EditUrlCOC;     //  ������������� ����� CrlDPExt.txt
    procedure ClearETSPSession;

    constructor Create;
    destructor Destroy; override;
  end;

const
   //??? �����������
   rNone     = 0; //??? �����������
   rNotRequired = 1; //�� ���������
   rResponse = 2; //??? �����������
   rPost     = 3; //??? �����������

   //??? �����������
   bChildId = 1;  //������� ������������� ������
   bChild   = 2;  //�������� ������ �� ������
   bFemale  = 4;  //�������� ������ � ������
   bFemaleU = 8;  //�������� ������ �� ���������������
   bMale    =16;  //�������� ������ �� ����
   bMaleU   =32;  //�������� ������ �� �����������
   bNotSvid =64;  //����������� ��� �������� �������������
   bNotPrSm =128;  //����������� ��� �������� �������������
   bPerson  = 2;  //�������� ������ � ��������

   CLASS_TYPEPUNKT_MR=68;   // ��� �������������� ����� �������� � ������
   CLASS_TYPEPUNKT_MG=35;   // ��� �������������� ����� ����������
   CLASS_ORGAN_REG=80;      // ��� �������������� ������ ����������� ����
   CLASS_MKB10=81;          // ���10
   CLASS_STRAN=8;           // ������������� �����

var
  Gisun : TGisun;

implementation

uses dBase, uProject, SasaIniFile, wsZags, IniFiles, fMain, fChLoadClassif,
     {$IFDEF ADD_ZAH}
       fAktZ,
     {$ENDIF}
     {$IFDEF ADD_OPEKA}
       fZapisOpeka,
     {$ENDIF}
     {$IFDEF ADD_ZAGS}
       fZapisRogd, fZapisBrak, fZapisSmert, fZapisUstOtc,
       {$IFDEF ZAGS} fRastBrak, fZapisChName, fZapisSmertV, fZapisAdopt, fZapisRogdV, fZapisUstMat, {$ENDIF}
     {$ENDIF}
     StrUtils, DataTask, mSecHeader, uETSP2, XSBuiltIns;

{ TGisun }

function TGisun.Status2Str(sStatus:String; sDef:String):String;
begin
  if sSTATUS=''
    then Result:=sDef
    else Result:=GlobalTask.CurrentOpisEdit.SeekValue('KEY_GIS_STATUS', sSTATUS, false);
end;

function TGisun.GetMessageOk:String;
begin
  if RegInt.Error07 then begin
    Result:=' ����������� ������ � ���������� ������. ';
  end else begin
    Result:=' ����������� ������ �������. ';
  end;
end;

{
//--------------------------------------------------
function TGisun.CheckUpdateProg(NAME_PROG:string; var strErr:String):String;
var
  Task:Cardinal;
  js, js_cur: TJSONobject;
  o : TZAbstractObject;
  jarr: TJSONArray;
  s,strURL,strURL_,sName,sVer: string;
  i,nTypeUpdate,m,j: integer;
  SStrm: TStringStream;
  nMaxUpdate,nCurUpdate,nCurSysSpr,nCurPath,nEnabledUpdate:Integer;
  nEnabledPath, nMaxPath : Integer;
  lOk:Boolean;
  IdHttp1:TIdHTTP;
  function GetUpdate(sss:String):Integer;
  begin
    try
      Result:=StrToInt(sss);
    except
      Result:=0;
    end;
  end;
  procedure ObrabOneVersion;
  begin
    //------------------------------------------------
    sVer:=js_cur.getString('version');
    if m=3 then begin             // <<<<<<<<< Path
      j:=Pos('-',sVer);
      if j>0 then begin
        nEnabledUpdate:=GetUpdate(Copy(sVer,1,j-1));
        nEnabledPath:=GetUpdate(Copy(sVer,j+1,Length(sVer)));
        if (nCurUpdate=nEnabledUpdate) and (nEnabledPath>nCurPath) then begin// ������ ���������� ���������
          if nEnabledPath>nMaxPath
            then nMaxPath:=nEnabledPath;
        end;
      end;
    end else if (m=2) or (m=1) then begin    // <<<<<<<<<
      nEnabledUpdate:=GetUpdate(sVer);
      if nEnabledUpdate>nMaxUpdate
        then nMaxUpdate:=nEnabledUpdate;
    end;                          // <<<<<<<<<
    //------------------------------------------------
  end;
begin
  Result:='';
  nTypeUpdate:=0;
  NomerUpdate:='';
  NameUpdate:='';
  NameFileUpdate:='';
  strErr:='';

  strURL:=DownloadUrl;
  if strURL='' then begin
    Result:='';
    strErr:='�� �������� URL ��� �������� ����������';
    exit;
  end;

  //------ ������� ���������� ------------------------------------------------
  nCurUpdate:=GetNomerUpdateProg;
  //------- ������� ������ ��������� ������������ -----------------------------------------------
  dmBase.WorkQueryS.Close;
  dmBase.WorkQueryS.SQL.Text := 'SELECT Trim(CONVERT(Version_Major,SQL_CHAR)) FROM '+dmBase.SysQuery('system.dictionary');
  try
    dmBase.WorkQueryS.Open;
    nCurSysSpr:=StrToInt(dmBase.WorkQueryS.Fields[0].AsString);;
  except
    nCurSysSpr:=1;
  end;
  dmBase.WorkQueryS.Active:=false;
  //-------- ������� ��������(Path) �� ��������� ----------------------------------------------
  try
    nCurPath:=dmBase.IniSysParams.ReadInteger('ADMIN','SETUP_PATH', 0);
  except
    nCurPath:=0;
  end;
  //------------------------------------------------------

  Task := EnterWorkerThread;
  _WorkedThread_:=true;
  try

  IdHTTP1:=TIdHTTP.Create(nil);

  for m:=1 to 3 do begin
    lOk:=true;
    case m of
      1: sName:=NAME_PROG;
      2: sName:='sysspr';
      3: sName:='path'+NAME_PROG;
    end;

    SStrm := TStringStream.Create(s);
    try
      IdHTTP1.Get(strURL, SStrm);
      s := SStrm.DataString;
      FreeAndNil(SStrm);
      if lOk then begin
        lOk:=false;
        js := TJSONobject.create(s);
        if js.has('updates') then begin
          o := js.get('updates');
          jarr:=nil;
          if (o is TJSONArray) then begin
            jarr := js.getJSONArray('updates');
          end else if (o is TJSONObject) then begin
            js_cur := js.getJSONObject('updates');
          end;
          if jarr=nil then begin   // ���� �� ������
            s := js_cur.getString('appName');
            if MySameText(s,sName) then begin
              strURL_:=strURL+'/'+sName;
              lOk:=true;
            end;
          end else begin
            jarr := js.getJSONArray('updates');
            for i := 0 to jarr.length - 1 do begin
              js_cur := jarr.getJSONObject(i);
              s := js_cur.getString('appName');
              if MySameText(s,sName) then begin
                strURL_:=strURL+'/'+sName;
                lOk:=true;
                break;
              end;
            end;
          end;
        end;
        js.Free;
      end;
      if lOk then begin
        lOk:=false;
        SStrm := TStringStream.Create(s);
        IdHTTP1.Get(strURL_, SStrm);
        s:=SStrm.DataString;
        FreeAndNil(SStrm);
        js := TJSONobject.create(s);
        if js.has('updates') then begin
          nMaxUpdate:=0;
          nMaxPath:=0;
          o := js.get('updates');
          jarr:=nil;
          if (o is TJSONArray) then begin
            jarr := js.getJSONArray('updates');
          end else if (o is TJSONObject) then begin
            js_cur := js.getJSONObject('updates');
          end;
          if jarr=nil then begin
            ObrabOneVersion;
          end else begin
            for i := 0 to jarr.length - 1 do begin
              js_cur := jarr.getJSONObject(i);
              s := js_cur.getString('appName');
              if js_cur.has('version') and MySameText(s,sNAME) then begin
                ObrabOneVersion;
              end;
            end;
          end;
          if m=3 then begin             // <<<<<<<<< Path
            if nMaxPath>nCurPath then begin
              lOk:=true;
              nEnabledUpdate:=nCurUpdate;
              Result:=strURL_+'/'+IntToStr(nCurUpdate)+'-'+IntToStr(nMaxPath);
              NomerUpdate:=IntToStr(nCurUpdate)+'-'+IntToStr(nMaxPath);
              NameUpdate:='��������� (��������)';
              NameFileUpdate:='Path'+FirstCharUpper(NAME_PROG);
              break;
            end;
          end else if m=2 then begin         // <<<<<<<<< sysSpr
            if nMaxUpdate>nCurSysSpr then begin
              lOk:=true;
              nEnabledUpdate:=nMaxUpdate;
              Result:=strURL_+'/'+IntToStr(nEnabledUpdate);
              NomerUpdate:=IntToStr(nEnabledUpdate);
              NameUpdate:='��������� ������������';
              NameFileUpdate:='UpdateSysSpr';
              break;
            end;
          end else if m=1 then begin         // <<<<<<<<< Update
            if nMaxUpdate>nCurUpdate then begin
              lOk:=true;
              nEnabledUpdate:=nMaxUpdate;
              Result:=strURL_+'/'+IntToStr(nEnabledUpdate);
              NomerUpdate:=IntToStr(nEnabledUpdate);
              NameUpdate:='���������';
              NameFileUpdate:='Update'+FirstCharUpper(NAME_PROG);
              break;
            end;
          end;
        end;
        js.Free;
      end;
    except
//      on E: EIdNotConnected do begin
//        cur:=Screen.Cursor;
//        Screen.Cursor:=crDefault;
//        ShowMessage('�������� ��������.');
//        Screen.Cursor:=cur;
//      end;
      on E:sysutils.Exception do begin
        lOk:=false;
        strErr:=DownloadUrl+chr(13)+E.Message;
      end;
    end;

  end;

  FreeAndNil(SStrm);
  FreeAndNil(IdHTTP1);

  finally
    Task:=0;
    _WorkedThread_:=false;
    LeaveWorkerThread;
  end;

end;
}
//--------------------------------------------------
function TGisun.DowloadUpdateProg(strURL:string; var strErr:String):Boolean;
var
  js: TJSONobject;
  jarr: TJSONArray;
  s,ss,strDir: string;
  i: integer;
  FStrm: TFileStream;
  SStrm: TStringStream;
  IdHttp1:TIdHTTP;
  nTask:Cardinal;
begin
//  cur:=Screen.Cursor;
//  Screen.Cursor:=crHourGlass;

  strErr:='';
  if strURL='' then begin
    Result:=false;
    exit;
  end;
  IdHTTP1:=TIdHTTP.Create(nil);
  IdHTTP1.OnWork:=fmmain.IdHTTP1Work;
  IdHTTP1.OnWorkBegin:=fmmain.IdHTTP1WorkBegin;
  IdHTTP1.OnWorkEnd:=fmmain.IdHTTP1WorkEnd;
  SStrm := TStringStream.Create(s);
  BytesToTransfer:=0;
  AbortTransfer:=false;

  fmMain.CheckVisibleGIF(true,'�������� ����������:');

  try
    nTask:=EnterWorkerThread;
    _WorkedThread_:=true;
    try
      IdHTTP1.Get(strURL, SStrm);
    finally
      _WorkedThread_:=false;
      LeaveWorkerThread;
    end;
    fmMain.CheckVisibleGIF(false,'');
 //   showMessage(InttoStr(nTask));
    s := SStrm.DataString;
    FreeAndNil(SStrm);
    js := TJSONobject.create(s);
    if not js.has('updates') and js.has('data') then begin
      s := js.getString('data');
      if s<>'' then begin

       {$IFDEF DEBUG_GIS}
        ss:=NameFileUpdate+NomerUpdate+'.jpg';
       {$ELSE}
        ss:=NameFileUpdate+NomerUpdate+'.exe';
       {$ENDIF}

        strDir:=''; //GlobalTask.ParamAsString('PATH_SAVE_UP');
        if strDir=''
          then strDir:=CheckSleshN(GetFolderMyDocument)+'����������\'    // CreateTmpPath(0);
          else strDir:=CheckSleshN(strDir);
        ForceDirectories(strDir);

        FStrm := TFileStream.Create( strDir+ss, fmCreate );
        SStrm := TStringStream.Create(s);

        try
          DecodeStream(SStrm, FStrm);
          ShellExecute(Application.Handle, PChar('explore'), PChar(strDir), nil, nil, SW_SHOWNORMAL);
        finally
          SStrm.Free;
          FStrm.Free;
        end;
      end else begin
        strErr:='�������� ������ �����';
      end;
    end else begin
      strErr:='������ ��� �������� �� �������';
    end;
  except
    on E: EIdNotConnected do begin
      strErr:='�������� ��������.';
    end;

    on E:sysutils.Exception do begin
      strErr:=strURL+chr(13)+E.Message;
    end;
  end;
  fmMain.CheckVisibleGIF(false,'');
  BytesToTransfer:=0;
//  Screen.Cursor:=cur;
  FreeAndNil(IdHTTP1);
  result:=(strErr='');
end;
//--------------------------------------------------------------------------
function TGisun.GetFullATE(nSize:Integer):Integer;
begin
  Result:=-1;
  PutError('����� �������� !');
end;
{$IFDEF GISUN2}
{
var
  spr:TClassifInterface;
  nMax,nCur:Integer;
  nn,mm,i:Integer;
  s:String;
  ds:TDataSet;
  lErr:Boolean;
begin
  Result:=-1;
  if not CheckLogon(true) then exit;
  ds:=dbOpenSQL2MemTable('select TOP 1 * from ate', '');  // ��������� MemTable ����� �� ��������� ��� ATE
  dbEmptyMemTable(ds);
//  lOk:=false;
  spr:=nil;
  spr:=TClassifInterface.Create(nil); //(HTTPRIO);
  spr.SetUserNameToken(FRegInt.Username,FRegInt.Password);
  spr.Url:=ClassifUrl; //'http://todes.by:8080/gisun/class/ws';
  spr.Proxy:=ClassifProxy; // '';
  spr.MessageSource:=FMessageSource; //'19194';
  nCur:=1;
  fmMain.CheckVisibleGIF(true,'�������� ���',false);
  lErr:=false;
  try
    try
      nMax:=spr.RequestATEMaxID;
      fmMain.CheckVisibleGIF(true,'�������� ��� '+IntToStr(nMax),false);
      while nCur<nMax do begin
        spr.RequestATEInterval(nCur,nCur+nSize-1,ds);
        fmMain.CheckVisibleGIF(true,'�������� ��� '+IntToStr(nMax)+'->'+IntToStr(nCur+nSize-1),false);
        nCur:=nCur+nSize;
        if nCur>nMax
          then nCur:=nMax;
      end;
    except
      lErr:=true;
    end;
  finally
    fmMain.CheckVisibleGIF(false,'');
  end;
  if not lErr then begin
    if ds.RecordCount>0 then begin
      try
        nn:=0;
        mm:=0;
        ds.First;
        ChangeMessage('    ��������������� �������� ...    ');
        dmBase.AdsConnection.Execute('DELETE FROM ATE;');
        OpenMessage('������ �������������� ��� ...    ','',10);
        while not ds.Eof do begin
          dmBase.ATESys.Append;
          for i:=0 to ds.FieldCount-1 do begin
            if not ds.Fields[i].IsNull
              then dmBase.ATE.Fields[i].Value:=ds.Fields[i].Value
              else dmBase.ATE.Fields[i].AsString:='';
          end;
          dmBase.ATE.Post;
          Inc(mm,1);
          Inc(nn,1);
          ds.Next;
          if nn>999 then begin
            nn:=0;
            ChangeMessage('������: '+IntToStr(mm));
          end;
        end;
        Result:=ds.RecordCount;
      finally
        CloseMessage();
      end;
    end;
  end;
  dbClose(ds);
end;
}
{$ENDIF}

//--------------------------------------------------------------------------
function TGisun.SprWithETSP:Boolean;  // �������� � ����������� ���
begin
  Result:=FSprWithETSP;
end;
//--------------------------------------------------------------------------
function TGisun.GetChangeATE(d:TDateTime; lGisun:Boolean) : Integer;
begin
  Result:=-1;
  PutError('����� �������� !');
end;
{$IFDEF GISUN2}
{
var
  spr:TClassifInterface;
  s:String;
  ds:TDataSet;
  i:Integer;
  fld:TField;
  lOk:Boolean;
  ds2xml:TDataSets2XML;
  sFile:String;
begin
  if not dmBase.IsMainComputer then begin   // ���� �� ������� ���������, �� �� ��������� ���������
    Result:=-2;
    exit;
  end;
  ds2xml:=nil;
  Result:=-1;
  CurAkt:=nil;
  sFile:='changeATE.xml';
  if lGisun then
    if not CheckLogon(true) then exit;
//  s:='KOD,Char,10;NAME,Char,80;NAME_B,Char,80;ATE_PARENTID,Integer,0;ATE_ID,Integer,0;ID,Integer,0;'+
//      'DATEIN,Date,0;DATEOUT,Date,0;CATEGORY,Integer,0;FNAMEC,Char,60;FNAMEC_B,Char,60;NAMEC,Char,10;NAMEC_B,Char,10;FRONT,Integer,0';
//  ds:=dbCreateMemTable(s,'');
  ds:=dbOpenSQL2MemTable('select TOP 1 * from ate', '');  // �������� MemTable ����� �� ��������� ��� ATE
  dbEmptyMemTable(ds);
  lOk:=false;
  spr:=nil;
  if lGisun then begin
    spr:=TClassifInterface.Create(nil); //(HTTPRIO);
    spr.SetUserNameToken(FRegInt.Username,FRegInt.Password);
    spr.Url:=ClassifUrl; //'http://todes.by:8080/gisun/class/ws';
    spr.Proxy:=ClassifProxy; // '';
    spr.MessageSource:=FMessageSource; //'19194';
  end;

  fmMain.CheckVisibleGIF(true,'�������� ��������� ���',false);
  lOk:=false;
  if lGisun then begin
    if FSprThread then begin
      EnterWorkerThread;
      _WorkedThread_:=true;
    end;
    try
      lOk:=spr.RequestChangeATE(d,ds);
    finally
      if FSprThread then begin
        _WorkedThread_:=false;
        LeaveWorkerThread;
      end;
    end;
    ds.First;
    Result:=ds.RecordCount;
    fmMain.CheckVisibleGIF(false,'');
  end else begin
    ds2xml:=TDataSets2XML.Create;
    ds2xml.DS_Add(ds,false);
    if FileExists(sFile) then begin
      if ds2xml.FileToXML(sFile) then begin
        ds2xml.XMLToData;
        Result:=ds.RecordCount;
        lOk:=true;
      end;
    end;
    ds2xml.Free;
    if not lOk then begin
      PutError('������ �������� �����: "'+sFile+'"');
    end;
  end;
  fmMain.CheckVisibleGIF(false,'');

  if lOk then begin
    if Result>0 then begin
      if lGisun then begin
        try
          try
            ds2xml:=TDataSets2XML.Create;
            ds2xml.DS_Add(ds,false);
            if ds2xml.DataToXML then begin
              ds2xml.XMLToFile(sFile);
            end;
          except
          end;
        finally
          ds2xml.Free;
        end;
      end;
      ds.First;
      if ds.RecordCount>0 then begin
        dmBase.ATE.IndexFieldNames:='ATE_ID;DATEIN'; // PR_KEY
        while not ds.Eof do begin
          if dmBase.ATE.FindKey([ds.FieldByName('ATE_ID').AsInteger,ds.FieldByName('DATEIN').AsDateTime]) then begin
            dmBase.ATE.Edit;
          end else begin
            dmBase.ATE.Append;
          end;
          for i:=0 to ds.FieldCount-1 do begin
            if not ds.Fields[i].IsNull
              then dmBase.ATE.Fields[i].Value:=ds.Fields[i].Value
              else dmBase.ATE.Fields[i].AsString:='';
          end;
    //      dmBase.ATE.Cancel;  // ��� �����  !!!
          dmBase.ATE.Post;
          ds.Next;
        end;
      end;
    end;
  end else begin
    if spr<>nil then spr.ShowError;
  end;
  dbClose(ds);
//  ds.Close;
//  FreeAndNil(ds);
end;
}
{$ENDIF}

//--------------------------------------------------------------------------
function TGisun.GetLastDateChangeClassif(nType:Integer) : TDateTime;
var
  d1,d2:TDateTime;
begin
  dmBase.WorkQueryS.Close;
  dmBase.WorkQueryS.SQL.Text := 'SELECT MAX(begindate), MAX(enddate) FROM gisun_class WHERE typespr='+IntToStr(nType);
  d1:=0;
  d2:=0;
  try
    dmBase.WorkQueryS.Open;
    if not dmBase.WorkQueryS.Fields[0].IsNull
      then d1:=dmBase.WorkQueryS.Fields[0].AsDateTime;
    if not dmBase.WorkQueryS.Fields[1].IsNull
      then d2:=dmBase.WorkQueryS.Fields[1].AsDateTime;
  except

  end;
  dmBase.WorkQueryS.Active:=false;
  d1:=Max(d1,d2);
  if d1=0
    then d1:=STOD(FIRST_DATE_CLASSIF,tdAds);
  Result:=d1;
end;

//--------------------------------------------------------------------------
function TGisun.LoadChangeClassif(nType:Integer; d:TDateTime; ds:TDataSet) : Boolean;
{$IFDEF GISUN2}
var
  ncountA,ncountE,np,i,j:Integer;
  dFirst, dMin, dEndDate:TDateTime;
  s:String;
  Opis : TOpisEdit;
  slClass, slClassDate:TStringList;
  lOk:Boolean;
begin
  //---- ����������� ���� ��� ENDDATE -----------------
  dMin:=0;
  slClass:=TStringList.Create;
  slClassDate:=TStringList.Create;
  if GlobalTask.CurrentOpisEdit.GetListOpis('KEY_CLASS_ENDDATE', slClassDate, slClass) then begin
    i:=slClass.IndexOf(IntToStr(nType));
    if i>-1
      then dMin:=STOD(slClassDate.Strings[i],tdAds);
  end;
  slClass.Free;
  slClassDate.Free;
  //----------------------------------------------------
  Result:=false;
  dFirst:=STOD(FIRST_DATE_CLASSIF,tdAds);
  if ds.RecordCount>0 then begin
    ds.First;
    if d=dFirst then begin  // ���������� ������ ���������
      dmBase.AdsSharedConnection.Execute('DELETE FROM GISUN_Class WHERE typespr='+IntToStr(nType));
      dmBase.AllSprGISUN.IndexName:='EXTCODE_KEY';
//  TYPESPR,Integer; EXTCODE,Char,10; LEX1,Char,100; LEX2,Char,100; LEX3,Char,100; PARENT,Char,10; EXTTYPE,Integer; Active,Boolean;
//  BEGINDATE,Date,0; ENDDATE,Date,0;
//��������� �������� ����
      ncountA:=0;
      ncountE:=0;
      np:=0;
      while not ds.Eof do begin
        lOk:=true;
        if dMin>0 then begin
          if ds.FieldByName('ENDDATE').IsNull
            then dEndDate:=0
            else dEndDate:=ds.FieldByName('ENDDATE').AsDateTime;
          if (dEndDate>0) and (dMin>=dEndDate)  // ���� ENDDATE �� ������ � ��� ������ ��� ����� dMin, �� �� ������ ��������
            then lOk:=false;  // !!!
        end;
//        if lOk and (ds.FieldByName('ACTIVE').AsBoolean=true) and (Pos('��������� ��������',ANSIUpperCase(ds.FieldByName('LEX1').AsString))=0) then begin
        if lOk then begin
          j:=0;
          try
            if dmBase.AllSprGISUN.FindKey([nType,ds.FieldByName('EXTCODE').AsString]) then begin
              dmBase.AllSprGISUN.Edit;
              s:='�������������';
              ncountE:=ncountE+1;
            end else begin
              dmBase.AllSprGISUN.Append;
              s:='����������';
              ncountA:=ncountA+1;
            end;
  //          dmBase.AllSprGISUN.Append;
            for i:=0 to ds.FieldCount-1 do begin
              j:=i;
              dmBase.AllSprGISUN.FieldByName(ds.Fields[i].FieldName).Value:=ds.Fields[i].Value;
            end;
            dmBase.AllSprGISUN.Post;
          except
            on E:sysutils.Exception do begin
              PutError('������ '+s+' ������ � �����: '+ds.FieldByName('EXTCODE').AsString+#13+E.Message+#13+
                  ds.Fields[j].FieldName+'='+VarToStr(ds.Fields[j].Value));
              dmBase.AllSprGISUN.Cancel;
            end;
          end;
        end else begin
          np:=np+1;
        end;
        ds.Next;
        Application.ProcessMessages;
      end;
      showmessage('���������� '+inttostr(ds.RecordCount)+' �������'#13#10'��������� '+inttostr(ncountA)+#13#10'���������������� '+inttostr(ncountE)+#13#10'��������� '+inttostr(np));
    end else begin  // ���� ����������� ������ ���������
      dmBase.AllSprGISUN.IndexName:='EXTCODE_KEY';
      while not ds.Eof do begin
        lOk:=true;
        if dMin>0 then begin
          if ds.FieldByName('ENDDATE').IsNull
            then dEndDate:=0
            else dEndDate:=ds.FieldByName('ENDDATE').AsDateTime;
          if (dEndDate>0) and (dMin>=dEndDate)  // ���� ENDDATE �� ������ � ��� ������ ��� ����� dMin, �� �� ������ ��������
            then lOk:=false;  // !!!
        end;
        if lOk and (Pos('��������� ��������',ANSIUpperCase(ds.FieldByName('LEX1').AsString))=0) then begin
          try
            if dmBase.AllSprGISUN.FindKey([nType,ds.FieldByName('EXTCODE').AsString]) then begin
              dmBase.AllSprGISUN.Edit;
              s:='�������������';
            end else begin
              dmBase.AllSprGISUN.Append;
              s:='����������';
            end;
            for i:=0 to ds.FieldCount-1 do begin
              dmBase.AllSprGISUN.FieldByName(ds.Fields[i].FieldName).Value:=ds.Fields[i].Value;
            end;
            dmBase.AllSprGISUN.Post;
          except
            on E:sysutils.Exception do begin
              PutError('������ '+s+' ������ � �����: '+ds.FieldByName('EXTCODE').AsString);
              dmBase.AllSprGISUN.Cancel;
            end;
          end;
        end;
        ds.Next;
        Application.ProcessMessages;
      end;
    end;
    if nType=80 then begin
      Application.ProcessMessages;
      dmBase.AdsSharedConnection.Execute(
                  'update gisun_class set lex3=s.soato '+
                  ' from gisun_class inner join SprZags s on CONVERT(s.id,SQL_CHAR)=extcode '+
                  ' where typespr='+IntToStr(nType)+' and s.soato is not null and (lex3='+QStr('')+' or lex3 is null)');

      Application.ProcessMessages;
      dmBase.AdsSharedConnection.Execute(
                  'update gisun_class set lex3=s.kod '+
//                  ' from gisun_class inner join �������� s on CONVERT(s.id,SQL_CHAR)=extcode '+
                  ' from gisun_class inner join �������� s on s.id=CONVERT(extcode,SQL_INTEGER) '+
                  ' where typespr='+IntToStr(nType)+' and s.kod is not null and (lex3='+QStr('')+' or lex3 is null)');
    end;
    Result:=true;
  end;
end;
{$ELSE}
begin
end;
{$ENDIF}

//--------------------------------------------------------------------------
function TGisun.GetTypeMessageSource : Integer;
begin
//  {$IF Defined(ZAGS) or Defined(LAIS) }
  if FConstTypeSource='' then begin
    {$IFDEF ZAH}
      Result:=TYPESOURCE_ZAH;    // !!!
    {$ELSE}
      {$IFDEF OPEKA}
        Result:=TYPESOURCE_OPEKA;  // !!!
      {$ELSE}
        Result:=TYPESOURCE_ZAGS;    // !!!
      {$ENDIF}
    {$ENDIF}
  end else begin
    Result:=StrToIntDef(FConstTypeSource, TYPESOURCE_ZAGS); 
  end;
end;
//--------------------------------------------------------------------------
// nType - ��� �����������  (80,81)
// d     - ���� �� ������� ������������� ������, ���� d=0, �� ���� ������������ ������������� �
//         �������� ������ ���������
// lGisun- false �������� ����������� �� �������� ����� xml:   "spr<nType>.xml"
//         true  ���������� ������������� �� �������� ���������
function TGisun.GetChangeClassif(nType:Integer; d:TDateTime; lGisun:Boolean; lSaveChange:Boolean) : Integer;
{$IFDEF GISUN2}
var
  spr:TClassifInterface;
  s:String;
  ds:TDataSet;
  i:Integer;
  fld:TField;
//  cur:TCursor;
  lOk:Boolean;
  ds2xml:TDataSets2XML;
  d2xml: TDataset2XML;
  sFile:String;
  sl:TStringList;
  lOnlyChange:Boolean;
begin
  Result:=-1;
  lOnlyChange:=false;
  if nType=0 then begin
    s:=Trim(InputBox('������','��� ��������������:','        '));
    if s<>'' then begin
      try
{       i:=Pos('...',s);
        if i>0 then begin
          nType:=StrToInt(Copy(s,1,i-1));
          nTypeMax:=StrToInt(Copy(s,i+3,100));
        end; }
        if ANSIUpperCase(Copy(s,1,4))='FILE' then begin
          s:=Copy(s,5,Length(s));
          lGisun:=false;            
        end;
        nType:=StrToInt(s);
      except
        nType:=0;    
      end;
    end;
  {$IFDEF ZAH}
  end else if nType=-999 then begin
  {$ELSE}
  end else if nType=-1 then begin
  {$ENDIF}
    sl:=TStringList.Create;
    if ChoiceLoadClassif(sl,lOnlyChange) and (sl.Count>0) then nType:=StrToInt(sl.Strings[0]);
    sl.Free;
    if lOnlyChange
      then d:=0
      else d:=STOD(FIRST_DATE_CLASSIF,tdAds);
    // !!! ���� ����� ������ ��������������� (sl) ���������� ����� ���������  !!!  ������������ ���� ��������
  end;
//!!!  if nType<=0 then exit;
  if nType=0 then exit;

  if nType=777 then begin // ATE
    ShowMessage(InttoStr(GetFullATE(1000)));
    exit;
  end;

  if d=0 then begin
    d:=GetLastDateChangeClassif(nType); // +1;  ���� ��������� ���� ��� ��� ???
  end;
//  lSaveChange:=true;
  if not dmBase.IsMainComputer then begin   // ���� �� ������� ���������, �� �� ��������� ���������
    Result:=-2;
    exit;
  end;
  Result:=-1;
  CurAkt:=nil;
  if lGisun then
    if not CheckLogon(true) then exit;
  s:='TYPESPR,Integer;EXTCODE,Char,12;LEX1,Char,250;LEX2,Char,250;LEX3,Char,100;PARENT,Char,10;EXTTYPE,Integer;Active,Logical;'+
     'BEGINDATE,Date,0;ENDDATE,Date,0;';
  ds:=dbCreateMemTable(s,'');
  ds.Open;

  lOk:=false;
  spr:=nil;
  ds2xml:=nil;
  sFile:='spr'+IntToStr(nType)+'.xml';
  if lGisun then begin  // ��������� � ��������
    spr:=TClassifInterface.Create(nil); //(HTTPRIO);
    spr.SetUserNameToken(FRegInt.Username,FRegInt.Password);
    spr.Url:=ClassifUrl; //'http://todes.by:8080/gisun/class/ws';
    spr.Proxy:=ClassifProxy; // '';
    spr.MessageSource:=FMessageSource; //'19194';
    spr.TypeMessageSource:=GetTypeMessageSource; //80
  end else begin
    try
      ds2xml:=TDataSets2XML.Create;
      try
        d2xml:=ds2xml.DS_Add(ds,false);
        d2xml.NameRoot:='SPR'+IntToStr(nType);
        if FileExists(sFile) then begin
          if ds2xml.FileToXML(sFile) then begin
            ds2xml.XMLToData;
            lOk:=true;
          end;
        end;
      except
      end;
    finally
      ds2xml.Free;
    end;
    if not lOk then begin
      PutError('������ �������� �����: "'+sFile+'"');
    end;
  end;

  fmMain.CheckVisibleGIF(true,'�������� �����������',false);

  if lGisun then begin  // ��������� � ��������
    if FSprThread then begin
      EnterWorkerThread;
      _WorkedThread_:=true;
    end;
    try
//    lOk:=FRegInt.FGisun.RequestChangeClassif(nType,d, ds, nil);
      lOk:=spr.RequestChangeClassif(nType,d, ds);
    finally
      if FSprThread then begin
        _WorkedThread_:=false;
        LeaveWorkerThread;
      end;
    end;
  end;

  fmMain.CheckVisibleGIF(false,'');

  if lOk then begin
    ds.First;
    Result:=ds.RecordCount;
  end else begin
    if spr<>nil then spr.ShowError; // PutError(FaultError);
  end;

  if Result>0 then begin
    OpenMessage('  ������ � ���� ...  ','',10);

//    {$IFDEF ZAGS}
    if lGisun then begin
      try                       
        try
          ds2xml:=TDataSets2XML.Create;
          d2xml:=ds2xml.DS_Add(ds,false);
          d2xml.NameRoot:='SPR'+IntToStr(nType);
          if ds2xml.DataToXML then begin
            ds2xml.XMLToFile(sFile);
          end;
        except
        end;
      finally
        ds2xml.Free;
      end;
    end;
//    {$ENDIF}
    if lSaveChange then begin
      ds.First;
      if ds.RecordCount>0 then begin
        // ���� ��� ����������� ������� ����
        if nType<>81 then begin
          LoadChangeClassif(nType,d,ds);
  //!!!!      end else if nType=134 then begin  // ����� �����������, �������� ��������� ��������� ��� ��� ���10
        {$IFDEF ADD_MKB10}
        end else if nType=81 then begin  // ������� ������ ���10
    //  'TYPESPR,Integer;EXTCODE,Char,12;LEX1,Char,100;LEX2,Char,100;LEX3,Char,100;PARENT,Char,10;EXTTYPE,Integer;Active,Logical;'+
    //  'BEGINDATE,Date,0;ENDDATE,Date,0;';
          // !!! CONNECT ��������� ������������ !!!
          dmBase.AdsSharedConnection.Execute('DELETE FROM SprMkb10');
          while not ds.Eof do begin
            try
              dmBase.SprMKB10.Append;
              for i:=0 to ds.FieldCount-1 do begin
                dmBase.SprMkb10.FieldByName('KOD').AsString:=Trim(ds.FieldByName('EXTCODE').AsString);
                dmBase.SprMkb10.FieldByName('NAME').AsString:=Trim(ds.FieldByName('LEX1').AsString);
                dmBase.SprMkb10.FieldByName('NAME_B').AsString:=Trim(ds.FieldByName('LEX1').AsString);
              end;
              dmBase.SprMKB10.Post;
            except
              on E : Exception do begin
                PutError('������ ���������� ������ � �����: '+ds.FieldByName('EXTCODE').AsString);
                dmBase.AllSprGISUN.Cancel;
              end;
            end;
            ds.Next;
          end;
        {$ENDIF}
        end else begin
          PutError('���������� �� �������� ������ � ����.')
        end;
      end;
    end;
    CloseMessage;
  end else begin
    ShowMessage('��������� �������������� �� ����.');
  end;
  dbClose(ds);
//  ds.Close;
//  FreeAndNil(ds);
end;
{$ELSE}
begin
end;
{$ENDIF}

//---------------------------------------------------------
function TGisun.CheckLogon(lSpr:Boolean): Boolean;
{$IFDEF MY_PROJECT}
var
  sUsr,sPsw,sPIN:String;
  n:Integer;
{$ENDIF}
begin
  Result:=true;
{$IFDEF MY_PROJECT}
  if (PostUserName and ((FRegInt.Username='') or (FRegInt.Password=''))) or
     ( (ActiveETSP and (TypeETSP=ETSP_NIITZI) and (not lSpr or FSprWithETSP)) and (FRegInt.PIN='')) then begin
    sUsr:=FRegInt.Username;
    sPsw:=FRegInt.Password;
    sPIN:=FRegInt.PIN;
    if ActiveETSP and (not lSpr or FSprWithETSP) then begin  // ����������� PIN
      if EnabledSimPin
        then n:=4   // ����������� ����� �������� � ��� ����
        else n:=2;
    end else begin
      n:=1;
    end;
    if ShowLogon( sUsr, sPsw, sPIN, -1, -1, n, CurAkt) then begin
      FRegInt.Username:=sUsr;
      FRegInt.Password:=sPsw;
      FRegInt.PIN:=sPIN;
      Role.UserGIS:=sUsr;
    end else begin
      Result:=false;
    end;
    fmMain.CaptionProg(FRegInt.Username);
  end;
{$ENDIF}
end;

//-------------------------------------------------------------------
//  true, akDecease, opPost
procedure TGisun.GetDecodePathError(dsError:TDataSet; IsInput: Boolean; ActKind: TActKind; Operation: TOperation);
var
  tb:TRegTable;
  i:Integer;
  strPath,s:String;
begin
  dsError.First;
  while not dsError.Eof do begin
    strPath:=dsError.FieldByName('ERROR_PLACE').AsString;
    s:='';
    if strPath<>'' then begin
      strPath:=StringReplace(strPath,'/','.',[rfReplaceAll, rfIgnoreCase]);
      if RightStr(strPath,1)='.'
        then strPath:=Copy(strPath,1,Length(strPath)-1);
      if Copy(strPath,1,1)='.'
        then strPath:=Copy(strPath,2,Length(strPath));
      tb:=FRegInt.TableList.Find(true,akDecease,opPost);
      for i:=0 to tb.FieldList.Count-1 do begin
        if tb.FieldList[i].Path=strPath then begin
          s:=tb.FieldList[i].GrupComm+':'+tb.FieldList[i].Comm;
          exit;
        end;
      end;
    end;
    if s<>'' then begin
      dsError.Edit;
      dsError.FieldByName('ERROR_PLACE').AsString:=s+'  '+dsError.FieldByName('ERROR_PLACE').AsString;
//      'ERROR_CODE',    Integer(ftString),    10,    //��� ������
//      'ERROR_TEXT',    Integer(ftString),   250,  //����� ������
//      'ERROR_PLACE',   Integer(ftString),   250,  //����� ������������� ������
//      'WRONG_VALUE',   Integer(ftString),   250,  //������������ ��������
//      'CORRECT_VALUE', Integer(ftString),   250,  //���������� ��������
//      'CHECK_NAME',    Integer(ftString),   250   //�������� ������������ ��������
      dsError.Post;
    end;
    dsError.Next;
  end;
  dsError.First;
end;

//--------------------------------------------------------
// �������� ��� ��� ��� ��� �� ��� ���� (dBase.TypeObj_ZRogd, ... )
function TGisun.IsEnableTypeAkt(nType:Integer; lVosstan:Boolean):Boolean;
var
  i:Integer;
begin
  Result:=false;
  //   uProject
//  if IsActiveGISUN and IsEnabled then begin  // �������� ������ � ��� ��
    for i:=Low(arrTypeAkt) to High(arrTypeAkt) do begin
      if lVosstan then begin
        if arrTypeAkt[i]=nType+1000
          then Result:=true
      end else begin
        if arrTypeAkt[i]=nType
          then Result:=true
      end;
      if Result
        then break;
    end;
//  end;
end;

//--------------------------------------------------------------------------
function TGisun.CheckUSB:Boolean;
begin
  Result:=FCheckUSB;
end;
//--------------------------------------------------------------------------
function TGisun.LoadSemStatus:Boolean;
begin
  Result:=FLoadSemStatus;
end;
//--------------------------------------------------------------------------
function TGisun.EnabledSimPin:Boolean;
begin
  Result:=FEnabledSimPin;
end;
//--------------------------------------------------------------------------
function TGisun.ReloadETSP : Boolean;
begin
  {$IFDEF SIGN}
    if (TypeETSP=ETSP_NIITZI) and (ETSP2<>nil) and ActiveETSP and FEnabledReloadETSP and (ETSP2.NameLib<>'') then begin
      Result:=ETSP2.LoadLib('');
      if Result then begin
        WriteTextLog('ETSP Reload Lib '+ETSP2.NameLib,LOG_GISUN);
      end else begin
       ActiveETSP:=false;
       WriteTextLog('������ ������������ ���������� ��� ('+ETSP2.NameLib+'). '+ETSP2.LastError,LOG_GISUN);
      end;
    end else begin
      Result:=true;
    end;
  {$ELSE}
    Result:=true;
  {$ENDIF}
end;
//--------------------------------------------------------------------------
function TGisun.SetParamsGISUN(strPathINI:String) : Boolean;
var
  ini, iniETSP : TSasaIniFile;
  sg,s,ss,cNameInputFile,cNameOutputFile,strFile:String;
  sPerem,sPeremValue:String;
  nTimeOut:Integer;
//  TVerify, Len: DWORD;
  lUrlETSP:Boolean;
  lCreateIniETSP:Boolean;
  {$IFDEF AVEST_GISUN}
    i:Integer;
  {$ENDIF}
begin
  Result:=true;
  if strPathIni='' then begin
    strPathIni:=FPathIni;
  end else begin
    FPathIni:=strPathIni;
  end;
  lCreateIniETSP:=false;
  FCheckUSB:=false;
  FLoadSemStatus:=true;
  FEnabledReloadETSP:=false;
  FEnabledSimPin:=true;   
  FSprWithETSP:=true;
  FSprThread:=false;
  FEnableRegisterZah:=true;
  FEnableRegisterOpeka:=false;
  {$IFDEF LAIS}
    FCheckZaprosZah:=true;
  {$ELSE}
    FCheckZaprosZah:=false;
  {$ENDIF}
  IniETSP:=nil;
  // ���� � ����������� ETSP
  {
  strFile:=GlobalTask.PathService+'etsp.ini';
  if FileExists(strFile) then begin
    IniETSP:=TSasaIniFile.Create( strFile );
    if IniETSP.SectionExists('ADMIN') then begin
      lCreateIniETSP:=true;
    end else begin
      FreeAndNil(IniETSP);
      IniETSP:=nil;
    end;
  end;
  }
  Ini:=nil;
  // ���� � ����������� ��� ����������� � ��� �� ������ ��������� �� ������� ���������� ��� �� ���������
  strFile:=strPathINI+'gisun.ini';

  if FileExists(strFile) then begin
    Ini:=TSasaIniFile.Create( strFile );
 //   uProject
    IsActiveGISUN:=Ini.ReadBool('ADMIN','ACTIVE', true);
    IsEnabled:=IsActiveGISUN;
    FEnableTextLog:=Ini.ReadBool('ADMIN','LOG', false);
  end else begin
    PutError('�� ������ ���� ���������� ����������� � ��� ��');
    IsEnabled:=false;
    IsActiveGISUN:=false;
  end;

  sg:=Trim(GlobalTask.GetLastValueAsString('NOT_GISUN'));
  if sg=''
    then GlobalTask.SetLastValueAsString('NOT_GISUN', '0');

  if GlobalTask.GetLastValueAsBoolean('NOT_GISUN') then begin
    IsEnabled:=false;
    IsActiveGISUN:=false;
  end;

  CheckSizeFileLog(LOG_GISUN,4);

  if FRegInt=nil
    then WriteTextLog('<<<<<<<<<< START GISUN >>>>>>>>>>>>',LOG_GISUN);

  if not IsActiveGISUN
    then WriteTextLog('GISUN NOT ACTIVE',LOG_GISUN);

  //--------------------------------------------------------
  FConstMessageSource:='';
  FMessageSource:='';
  if IsEnabled then begin
    WriteTextLog('GISUN open file '+strFile,LOG_GISUN);
    s := Trim(Ini.ReadString('ADMIN', 'MESSAGESOURCE', ''));
    if s='' then begin
      FMessageSource:=Trim(SystemProg.MessageSourceGISUN(GlobalTask));   // ��� ����
    end else begin
      FConstMessageSource:=s;
      FMessageSource:=s;   // ��� ����
    end;
    WriteTextLog('MESSAGESOURCE="'+FMessageSource+'"',LOG_GISUN);

    FConstTypeSource:='';
    {$IFDEF ADD_WS_LOCAL}
      {$IFDEF LAIS}
        //-----------------
      {$ELSE}
         s := Trim(Ini.ReadString('ADMIN', 'TYPEMESSAGESOURCE', ''));
         if s<>'' then begin
           FConstTypeSource:=s;
         end;
      {$ENDIF}
    {$ENDIF}

    {$IFDEF GISUN2}
      IsActiveWorkATE:=Ini.ReadBool('ADMIN','ATE', true);
    {$ENDIF}
    // �������� ���������� ��� ���: ����� ���������� �/� �������� � ���������� ��������� ��� ��������
    OrganZagsAsMessageSource:=Ini.ReadBool('ADMIN', 'ORGANZAGS_AS_MESSAGESOURCE', false);
    if OrganZagsAsMessageSource
      then WriteTextLog('GISUN ORGANZAGS AS MESSAGESOURCE',LOG_GISUN);

    if FRegInt=nil then begin
      FRegInt:=TRegInt.Create(FMessageSource);
    end else begin
      FRegInt.MessageSource:=FMessageSource;
    end;

    FRegInt.PostIsUpper:=Ini.ReadBool('ADMIN', 'POST_UPPER', true);
    CheckRegisterFIO:=Ini.ReadBool('ADMIN', 'CHECK_REGISTER_FIO', false);
    CheckRegisterAdres:=Ini.ReadBool('ADMIN', 'CHECK_REGISTER_ADRES', false);
    FDbUserAsGIS:=Ini.ReadBool('ADMIN', 'DBUSER_AS_GIS', false);
    PostUserName:=Ini.ReadBool('ADMIN', 'POST_USERNAME', true);
    CheckCurDate:=Ini.ReadBool('ADMIN', 'CHECK_CUR_DATE', true);
    FCheckUSB:=Ini.ReadBool('ADMIN', 'CHECK_USB', false);
    FLoadSemStatus:=Ini.ReadBool('ADMIN', 'LOAD_FAM_ST', true);
//    FEnabledSimPin:=Ini.ReadBool('ADMIN', 'PIN_ENABLED_SIM', false);

    CheckAteGis:=Ini.ReadBool('ADMIN', 'ATE_GIS', true);  // ��������� ��� ���������� �� ��������

    FVersionINI:=Ini.ReadInteger('ADMIN','VERSION',FRegInt.Version);  // !!!

    FEnableRegisterZah:=true; //Ini.ReadBool('ADMIN', 'ENABLE_LOCAL_ZAH', false);
    FEnableRegisterOpeka:=Ini.ReadBool('ADMIN', 'ENABLE_LOCAL_OPEKA', false);
    {$IFDEF LAIS}
      FCheckZaprosZah:=Ini.ReadBool('ADMIN', 'CHECK_ZAPROS_ZAH', false);
    {$ELSE}
      FCheckZaprosZah:=Ini.ReadBool('ADMIN', 'CHECK_ZAPROS_ZAH', true);
    {$ENDIF}
    if Ini.ReadBool('ADMIN', 'LOG_WORK', false) then begin
      FRegInt.FGisun.EnabledLog:=true;
      {$IFDEF ADD_WS_LOCAL}
      FRegInt.FLocal.EnabledLog:=true;
      {$ENDIF}
    end else begin
      FRegInt.FGisun.EnabledLog:=false;
      {$IFDEF ADD_WS_LOCAL}
      FRegInt.FLocal.EnabledLog:=false;
      {$ENDIF}
    end;

    lUrlETSP:=false;

    FTimeOut:=0;
    nTimeOut:=Ini.ReadInteger('ADMIN', 'TIMEOUT', 0);
    if nTimeOut>0 then begin
      if nTimeOut<60
        then nTimeOut:=60;
      nTimeOut:=nTimeOut*1000;
      InternetSetOption(nil, INTERNET_OPTION_CONNECT_TIMEOUT, Pointer(@nTimeOut), SizeOf(nTimeOut));
//      ShowMessage(inttostr(GetLastError));
      InternetSetOption(nil, INTERNET_OPTION_SEND_TIMEOUT, Pointer(@nTimeOut), SizeOf(nTimeOut));
      InternetSetOption(nil, INTERNET_OPTION_RECEIVE_TIMEOUT, Pointer(@nTimeOut), SizeOf(nTimeOut));

    end;
    {
    Len:=sizeof(dword);
    InternetQueryOption(nil, INTERNET_OPTION_CONNECT_TIMEOUT, @TVerify, Len);
    ShowMessage(IntToStr(TVerify));
    }
    WriteTextLog('TIMEOUT='+IntToStr(nTimeOut),LOG_GISUN);

    nTimeOut:=Ini.ReadInteger('ADMIN', 'TIMEOUT_BP', 0);
    Global_TimeOut_BeforePost:=0;
    if nTimeOut>0 then begin
      Global_TimeOut_BeforePost:=nTimeOut*1000;
    END;
    if Global_TimeOut_BeforePost>0
      then WriteTextLog('TIMEOUT_BP='+IntToStr(Global_TimeOut_BeforePost),LOG_GISUN);

    {$IFDEF SIGN}
      //----------------- ��� -----------------
      // ��������� ��������� URL ��� ���
      lUrlETSP:=Ini.ReadBool('ADMIN', 'ETSP_URL_SEP', false);

      ActiveETSP:=Ini.ReadBool('ADMIN', 'ETSP_ACTIVE', false);
      if ActiveETSP
        then FAllCreateTagSign:=true
        else FAllCreateTagSign:=Ini.ReadBool('ADMIN', 'ALL_CREATE_TAG_SIGN', false);

      ss:=Trim(UpperCase(Ini.ReadString('ADMIN', 'ETSP_TYPE', 'PAR')));
      s:=' (��������� �� ���������� ��� ��)';
      if ss='AVEST' then begin
        TypeETSP:=ETSP_AVEST;           
      end else if ss='TZI' then begin
        TypeETSP:=ETSP_NIITZI;
      end else begin
        TypeETSP:=GetTypeETSP(Role.User); // 
        s:='';
      end;
      WriteTextLog('��� ������������ ���: '+NameETSP+s,LOG_GISUN);

      if ActiveETSP then begin
        {$IFDEF LAIS}            
          FOpenDefSession:=Ini.ReadBool('ADMIN', 'AVEST_SESSION', false);
          FAvestEnabledPIN:=false;
          FAvestIgnoreCOC:=false;
        {$ELSE}
          FOpenDefSession:=Ini.ReadBool('ADMIN', 'AVEST_SESSION', true);
          FAvestEnabledPIN:=Ini.ReadBool('ADMIN', 'AVEST_PIN', false);        // ����������� ����� PIN ���� ��� ����� � ���� ����� ������������ � ������
          FAvestIgnoreCOC:=Ini.ReadBool('ADMIN', 'AVEST_IGNORE_COC', false);  // ������������ ���������� ��� ��� ����������� � �����
        {$ENDIF}

        FAvestSignType:=Ini.ReadInteger('ADMIN', 'AVEST_SIGNTYPE', 1);
        //---- ������������� ������������ ��� ��� ������� ��������� � ������������ --------------------
        FSprWithETSP:=true; //Ini.ReadBool('ADMIN', 'ETSP_SPR', true);
        SetActiveETSPSpr_(FSprWithETSP);  // !!!  ������� �� mSecHeader.pas
        //---------------------------------------------------------------------------------------------
        FSprThread:=Ini.ReadBool('ADMIN', 'LOADSPRTHREAD', false);  // ��������� ����������� � ������

        //====��� ��� ��� =================================================================
        if TypeETSP=ETSP_NIITZI then begin
          ss:=Trim(Ini.ReadString('ADMIN', 'ETSP_ENV', ''));     // ��� ���������� ����� ���� � ����������
          if ss=''
            then ss:='NKI_LIB';
          sPerem:=ss;
          sPeremValue:='';
          if ss<>'' then begin
            ss:=Trim(GetEnvironmentVariable(ss));    // ��������� ����������
            sPeremValue:=ss;
            if ss<>''
              then ss:=CheckSleshN(ss);    // ��������� ����������
          end;
          s:=Trim(Ini.ReadString('ADMIN', 'ETSP_NAMELIB', ''));
          if s=''
            then s:='libnki_func.dll';
          if (Pos('\',s)=0) and (Pos(':',s)=0) then begin
            s:=ss+s;    // ��� ���������� � ����
          end;
          WriteTextLog('���������� '+sPerem+'='+sPeremValue+'; ��� ���������� '+s,LOG_GISUN);
   //       showmessage(s+chr(13)+ss);
          if ETSP2=nil
            then ETSP2:=TETSP2.Create;
          ETSP2.PathError:=CheckSleshN(GlobalTask.PathService);
          if ETSP2.LoadLib(s) then begin
            if IniETSP=nil
              then IniETSP:=Ini;  {!!!}
            ETSP2.Debug:=IniETSP.ReadBool('ADMIN', 'ETSP_DEBUG', false);
            if ETSP2.Debug then ss:=' ����� �������' else ss:='';
            WriteTextLog('ETSP �������� ���������� '+s+ss,LOG_GISUN);
  //ETSP_ALG_HASH=4
  //ETSP_ALG_SOK=2
  //ETSP_ALG_SIGN=2
            ETSP2.SokAlg:=IniETSP.ReadInteger('ADMIN', 'ETSP_ALG_SOK', 2);
            ETSP2.HashAlg:=IniETSP.ReadInteger('ADMIN', 'ETSP_ALG_HASH', 4);
            ETSP2.SignAlg:=IniETSP.ReadInteger('ADMIN', 'ETSP_ALG_SIGN', 2);
            ETSP2.LengthPIN:=IniETSP.ReadInteger('ADMIN', 'ETSP_PIN', 8);
            ETSP2.InvertSign:=IniETSP.ReadBool('ADMIN', 'ETSP_INVERT', false);
            if ETSP2.InvertSign then ss:='true' else ss:='false';
            WriteTextLog('ETSP_INVERT='+ss+'; ETSP_PIN='+IntToStr(ETSP2.LengthPIN),LOG_GISUN);

            FEnabledReloadETSP:=IniETSP.ReadBool('ADMIN', 'ETSP_RELOAD', true);
          end else begin
            ActiveETSP:=false;
            if ETSP2<>nil then begin
              WriteTextLog('������ �������� ���������� ��� ('+s+'). '+ETSP2.LastError,LOG_GISUN);
            end;
            PutError('������ �������� ���������� ��� ('+s+').'+Chr(13)+ETSP2.LastError+Chr(13)+'���������� ����� '+sPerem+'='+sPeremValue);
            if ETSP2<>nil then begin
              FreeAndNil(ETSP2);
            end;
          end;
        end else begin
          {$IFDEF AVEST_GISUN}
          //====��� "�����" =================================================================
          if Avest=nil then begin   // ����� ������� ��� ��� ����
            Avest:=TAvest.Create;
          end;
          Avest.Debug:=Ini.ReadBool('ADMIN', 'ETSP_DEBUG', false);
          Avest.SetIgnoreCOC(FAvestIgnoreCOC);
          if Avest.Debug
            then WriteTextLog('��� Avest ������� ����� �������', LOG_GISUN);
          //  Avest.OnWriteLog:=
          if Avest.IsActive then begin  // ����� ��� ��������� ��� ����� ����
            WriteTextLog('���������� ��� Avest ('+NAME_AVEST_DLL+') ��� ���������', LOG_GISUN);
          end else begin
            // ������� ��� ��� ����������  AvCryptMail.dll
            s:=Trim(dmBase.IniSysParams.ReadString('PATH','AVEST',''));
            if s<>'0' then begin
              if s='1' then s:='';
              if (s<>'')
                then s:=CheckSleshN(s)+NAME_AVEST_DLL; //'AvCryptMail.dll';
              Avest.LoadDLL(s, ss);
              for i:=0 to Avest.slLogLoad.Count-1 do WriteTextLog(Avest.slLogLoad[i], LOG_GISUN);
            end else begin
              WriteTextLog('����� �� �������� ���������� ��� Avest ('+NAME_AVEST_DLL+'): �������� AVEST=0', LOG_GISUN);
            end;
          end;
          {$ENDIF}
        end;
      end else begin
        WriteTextLog('������� ��� ��������� � ����������, ���������� �� ��������',LOG_GISUN);
        if ETSP2<>nil then begin
          FreeAndNil(ETSP2)
        end;
      end;
    {$ELSE}
      ActiveETSP:=false;
    {$ENDIF}
    FRegInt.DbUserAsGIS:=FDbUserAsGIS;
    FRegInt.PostUserName:=FPostUserName;

{
    if not FDbUserAsGIS then begin
      s:=Trim(Ini.ReadString('ADMIN', '_USER_NAME_', ''));
      ss:=Trim(Ini.ReadString('ADMIN', '_USER_PSW_', ''));
      if (s<>'') and (ss<>'') then begin
        SetUserNameToken(s,ss);
      end;
    end;
}
    //FRegInt.Version
    FIsDebug:=Ini.ReadBool('ADMIN', 'DEBUG', false);
    FRegInt.FGisun.EnabledLog:=FIsDebug;
    IsWriteLogToBase := false;

//    IsActiveSubMenuGISUN := Ini.ReadBool('ADMIN', 'SUBMENU', false);
    IsActiveSubMenuGISUN := true;
    IsVisibleTmpOff:=false;
//    IsVisibleTmpOff:=Ini.ReadBool('ADMIN', 'VISIBLE_TMPOFF', true);
    IsCheckQuery:=Ini.ReadBool('ADMIN', 'CHECK_QUERY', true);

    OsnPrSm:=Ini.ReadBool('ADMIN', 'OSN_PR_SM', true);

    //----------------------------------------------------------------------
    s := Trim(Ini.ReadString('HTTP', 'ZAGS_URL1', ''));
    if ActiveETSP and lUrlETSP and (s<>'') then begin
      FRegInt.ZagsUrl := s;
      s := Ini.ReadString('HTTP', 'ZAGS_PROXY1', '');
      if s<>'' then FRegInt.ZagsProxy := s;
    end else begin
      s := Trim(Ini.ReadString('HTTP', 'ZAGS_URL', ''));
      if s<>'' then FRegInt.ZagsUrl := s;
      s := Ini.ReadString('HTTP', 'ZAGS_PROXY', '');
      if s<>'' then FRegInt.ZagsProxy := s;
    end;
    //----------------------------------------------------------------------
    s := Trim(Ini.ReadString('HTTP', 'GISUN_URL1', ''));
    if ActiveETSP and lUrlETSP and (s<>'') then begin
      FRegInt.GisunUrl := s;
      s := Ini.ReadString('HTTP', 'GISUN_PROXY1', '');
      if s<>'' then FRegInt.GisunProxy := s;
    end else begin
      s := Ini.ReadString('HTTP', 'GISUN_URL', '');
      if s<>'' then FRegInt.GisunUrl := s;
      s := Ini.ReadString('HTTP', 'GISUN_PROXY', '');
      if s<>'' then FRegInt.GisunProxy := s;
    end;
    //-----------------------------------------------------------------------

    {$IFDEF ADD_WS_LOCAL}
      {$IFDEF LAIS}
        s:=StringReplace(FRegInt.ZagsUrl,'/zags/','/local/',[rfIgnoreCase]);
        FRegInt.LocalUrl:=s;
        FRegInt.LocalProxy:='';
        FRegInt.FLocal.TypeMessageSource:=TYPESOURCE_ZAGS;    // !!!
        // FRegInt.FGisun.TypeMessageSource:=ctZags;  // !!! default=ctZags
      {$ELSE}
        if (FConstTypeSource='') or (FConstTypeSource='0') then begin
          {$IFDEF ZAH}
            FRegInt.FLocal.TypeMessageSource:=TYPESOURCE_ZAH;  // !!!
            FRegInt.FGisun.TypeMessageSource:=TYPESOURCE_ZAH;  // !!!
          {$ELSE}
            {$IFDEF OPEKA}
              FRegInt.FLocal.TypeMessageSource:=TYPESOURCE_OPEKA;  // !!!
              FRegInt.FGisun.TypeMessageSource:=TYPESOURCE_OPEKA;  // !!!
            {$ELSE}
              FRegInt.FLocal.TypeMessageSource:=TYPESOURCE_ZAGS;    // !!!
            {$ENDIF}
          {$ENDIF}
        end else begin
          FRegInt.FLocal.TypeMessageSource:=StrToInt(FConstTypeSource);
          FRegInt.FGisun.TypeMessageSource:=StrToInt(FConstTypeSource);
        end;
        s := Trim(Ini.ReadString('HTTP', 'ZAGS_URL1', ''));
        if ActiveETSP and lUrlETSP and (s<>'') then begin
          FRegInt.LocalUrl := s;
          s := Ini.ReadString('HTTP', 'ZAGS_PROXY1', '');
          if s<>'' then FRegInt.LocalProxy := s;
        end else begin
          s := Trim(Ini.ReadString('HTTP', 'ZAGS_URL', ''));
          if s<>'' then FRegInt.LocalUrl := s;
          s := Ini.ReadString('HTTP', 'ZAGS_PROXY', '');
          if s<>'' then FRegInt.LocalProxy := s;
        end;
      {$ENDIF}
    {$ENDIF}

    {$IFDEF GISUN2}
      s := Trim(Ini.ReadString('HTTP', 'CLASSIF_URL', ''));
      if s='' then begin
        s:=StringReplace(FRegInt.GisunUrl,'/common/','/class/',[rfIgnoreCase]);
        ClassifUrl:=s;
        ClassifProxy:='';
      end else begin
        ClassifUrl:=s;
        ClassifProxy:=Trim(Ini.ReadString('HTTP', 'CLASSIF_PROXY', ''));
      end;
    {$ELSE}
      ClassifUrl:='';
      ClassifProxy:='';
    {$ENDIF}

    s := Ini.ReadString('HTTP', 'DOWNLOAD_URL', '');
    if s<>''
      then DownloadUrl:=s+'/updatesvc/download/applications'
      else DownloadUrl:='';

    WriteTextLog('ZAGS  URL='+FRegInt.ZagsUrl,LOG_GISUN);
    WriteTextLog('GISUN URL='+FRegInt.GisunUrl,LOG_GISUN);

    cNameInputFile:=strPathINI+'GISUN_Input.ini';
    cNameOutputFile:=strPathINI+'GISUN_Output.ini';
    if not FRegInt.ReadMetaInfo(cNameInputFile,cNameOutputFile) then begin
      PutError('������ ������ �������������� ��� ��� ��');
      IsEnabled:=false;
      IsActiveGISUN:=false;
    end;
  end;
  FreeAndNil(Ini);
  if lCreateIniETSP and (IniETSP<>nil)
    then FreeAndNil(IniETSP);
end;

//--------------------------------------------------------------------------
constructor TGisun.Create;
var
  ini : TSasaIniFile;
//  s,ss,cNameInputFile,cNameOutputFile,strFile:String;
  strFile:String;
//  i,nTimeOut:Integer;
//  lUrlETSP:Boolean;
//  lCreateIniETSP:Boolean;
begin
  {$IFDEF DEFAULT_AVEST}
    FTypeETSP:=ETSP_AVEST;
  {$ELSE}
    FTypeETSP:=ETSP_NIITZI;
  {$ENDIF}
  FEnabledReloadETSP:=false;
  FIsDecodePathError:=false;
  OsnPrSm:=true;
  AllSpr:=nil;
  LoadGrag:=true;
  IsCheckBelNazv:=false;
  IsVisibleTmpOff:=false;
  IsCheckQuery:=true;
  CheckCurDate:=true;
  FRegInt:=nil;
  ETSP2:=nil;
  CurAkt:=nil;
  FPathIni:='';
  FEnableTextLog:=false;
  HandleErrorToString:=false;
  FEnableRegisterZah:=true;
  FEnableRegisterOpeka:=false;
  FAllCreateTagSign:=false;
  {$IFDEF LAIS}
    FCheckZaprosZah:=true;
  {$ELSE}
    FCheckZaprosZah:=false;
  {$ENDIF}

//  FTypeEnableControl:=1;    // ������������ � readonly
  FTypeEnableControl:=9;    // ��������� ��������� ��������
  //---- ����������� ������ �� ...  ------------------------
  SetLength(arrTypeAkt,11);
  arrTypeAkt[0]:=dmBase.TypeObj_ZRogd;
  arrTypeAkt[1]:=dmBase.TypeObj_ZRogd+1000;   // ���������������
  arrTypeAkt[2]:=dmBase.TypeObj_ZSmert;
//  arrTypeAkt[3]:=dmBase.TypeObj_ZSmert+1000;  // ���������������
  arrTypeAkt[3]:=dmBase.TypeObj_ZBrak;
  arrTypeAkt[4]:=dmBase.TypeObj_ZRast;
  arrTypeAkt[5]:=dmBase.TypeObj_ZUstOtc;
  arrTypeAkt[6]:=dmBase.TypeObj_ZChName;
  arrTypeAkt[7]:=dmBase.TypeObj_ZUstMat;
  arrTypeAkt[8]:=_TypeObj_AktZAH;
  arrTypeAkt[9]:=_TypeObj_Opeka;
  arrTypeAkt[10]:=_TypeObj_QueryGIS;

  IsActiveWorkATE:=false;

//  arrTypeAkt[0]:=dmBase.TypeObj_ZUstMat;
  FPathINI:=GlobalTask.PathServiceMain;
  strFile:=FPathINI+'gisun.ini';
  if FileExists(strFile) then begin
    Ini:=TSasaIniFile.Create( strFile );
    // ����� ���� � ����������� ��� �� �� ��������� ����������
    if ini.ReadString('ADMIN', 'LOCAL', '0')='1' then begin
      FPathINI:=GlobalTask.PathService;
      if not FileExists(FPathINI+'gisun.ini') then begin
        CopyFile(PChar(strFile), PChar(FPathINI+'gisun.ini'),false);
      end;
    end;
    ini.Free;
  end;

  SetParamsGISUN(FPathINI);

end;

procedure TGisun.SetIsEnabled(const Value: Boolean);
begin
  FIsEnabled := Value;
end;

destructor TGisun.Destroy;
begin
  FRegInt.Free;
  inherited;
end;
//----------------------------------------------------------------
procedure TGisun.ShowErrorDataSet;
var
  f : TfmShowErrorGISUN;
  s,ss : String;
begin
  if HandleErrorToString then begin
    ErrorString:='';
    Error.First;
    s:='';
    while not Error.Eof do begin
      ErrorString:=ErrorString+s+
                   Error.FieldByName('ERROR_CODE').AsString+
                   ' '+Trim(Error.FieldByName('ERROR_TEXT').AsString)+
                   ' '+Trim(Error.FieldByName('ERROR_PLACE').AsString)+
                   ' '+Trim(Error.FieldByName('CHECK_NAME').AsString)+
                   ' '+Trim(Error.FieldByName('DESCRIPTION').AsString);
      ss:=Trim(Error.FieldByName('CORRECT_VALUE').AsString);
      if (Error.FieldByName('WRONG_VALUE').AsString<>'') or (ss<>'') then begin
        ErrorString:=ErrorString+' : "'+Trim(Error.FieldByName('WRONG_VALUE').AsString)+'"';
        if ss<>''
          then ErrorString:=ErrorString+' -> "'+ss+'" ';
      end;
      Error.Next;
      s:=CRLF;
    end;
    Error.First;
  end else begin
    f := TfmShowErrorGISUN.Create(nil);
    try
      f.DataSource.DataSet:=Error;
//      f.ShowAsForm:=true;
      f.CheckColumns;
      f.ShowModal;
    finally
      f.Free;
    end;
  end;
{
  if Error<>nil then begin
   // ��������
//      'ERROR_CODE',    Integer(ftString),    10,    //��� ������
//      'ERROR_TEXT',    Integer(ftString),   250,  //����� ������
//      'ERROR_PLACE',   Integer(ftString),   250,  //����� ������������� ������
//      'WRONG_VALUE',   Integer(ftString),   250,  //������������ ��������
//      'CORRECT_VALUE', Integer(ftString),   250,  //���������� ��������
//      'CHECK_NAME',    Integer(ftString),   250   //�������� ������������ ��������
//      'DESCRIPTION',   Integer(ftString),   500   //��������
    sl := TStringList.Create;
    Error.First;
    while not Error.Eof do begin
      sl.Add(Error.FieldByName('ERROR_TEXT').AsString+'  '+Error.FieldByName('ERROR_PLACE').AsString+'  '+#13+
             ' : '+Error.FieldByName('WRONG_VALUE').AsString+' -> '+Error.FieldByName('CORRECT_VALUE').AsString+'  '+Error.FieldByName('CHECK_NAME').AsString);
      Error.Next;
    end;
    Error.First;
    ShowStrings( sl, '������');
    sl.Free;
  end;
}
end;

procedure TGisun.ShowMessageErr(strErr:String);
begin
  if HandleErrorToString
    then ErrorString:=strErr
    else PutError(strErr,CurAkt);
end;
//---------------------------------------------------------------------
procedure TGisun.CheckMainForm;
begin
   Application.BringToFront;
   Application.ProcessMessages;
end;
//---------------------------------------------------------------------
procedure TGisun.HandleError(RequestResult: TRequestResult; ActKind: TActKind; Operation: TOperation; Input, Output, Error: TDataSet; FaultError: string);
var
  IsInput:Boolean;
  cur:TCursor;
begin
   cur:=Screen.Cursor;
   Screen.Cursor:=crDefault;
   try
     if (Error<>nil) and (Error.RecordCount>0) and IsDecodePathError then begin
       if Input<>nil
         then IsInput:=true
         else IsINput:=false;
       GetDecodePathError(Error, IsInput, ActKind, Operation);
     end;
     CheckMainForm;
     case RequestResult of
        rrFault : begin
          if (Error<>nil) and (Error.RecordCount>0) then begin
            ShowErrorDataSet
          end else begin
            ShowMessageErr(FaultError);
          end;
        end;
        rrBeforeError: begin
          ShowMessageErr(FaultError);
        end;
        rrError: begin
          ShowErrorDataSet;
        end;
        rrAfterError: begin
          ShowMessageErr(FaultError);
        end;
     end;
   finally
     Screen.Cursor:=cur;
   end;
end;

procedure TGisun.ClearDataSets;
begin
  FreeAndNil(Output);
  FreeAndNil(Input);
  FreeAndNil(Error);
end;

{
function TGisun.Decode_TypePunkt(strType: String): String;
begin
  Result := '';
  if (strType<>'') then begin
    if strType='111' then begin  // ������� ��
      Result:='1';  // �����
    end else if (strType='113') or (strType='112') or (strType='213') then begin  //
      Result:='1';  // �����
    end else begin
      if dmBase.TypePunkt.Locate('GISUN35',strType,[]) then begin
        Result := dmBase.TypePunkt.FieldByName('ID').AsString;
      end;
    end;
  end;
end;
}

//-------------------------------------------------------------------
{
function TGisun.Code_TypePunkt(strType: String): String;
begin
  Result := '';
  if (strType<>'') and dmBase.TypePunkt.Locate('ID',strType,[]) then begin
    Result := dmBase.TypePunkt.FieldByName('GISUN68').AsString;
  end;
end;
}

//-------------------------------------------------------------------
function TGisun.Decode35_My_TypePunkt(var sTypeRN:String; var sType:String; var sName:String; var sNameBel:String; var lGorod:Boolean):Boolean;
var
  s:String;
begin
  Result:=false;
  if sTypeRN<>'' then begin  // ���� ��� ���. ������ �� "��� ��" �� ������
    sType:='';
    if AllSpr.Locate('TYPESPR;EXTCODE', VarArrayOf([CLASS_TYPEPUNKT_MG, sTypeRN]),[]) then begin
      s:=ANSIUpperCase(AllSpr.FieldByName('LEX1').AsString)+' '; // ������������ ���� ��-������
      if ANSIUpperCase(Copy(sName,1,Length(s)))=s
        then sName:=Copy(sName,Length(s)+1,Length(sName));

      if sNameBel<>'' then begin
        s:=ANSIUpperCase(dmBase.AllSprGISUN.fieldByName('LEX2').AsString)+' '; // ������������ ���� ��-����������
        if ANSIUpperCase(Copy(sNameBel,1,Length(s)))=s
          then sNameBel:=Copy(sNameBel,Length(s)+1,Length(sNameBel));
      end;

      sType:=Decode35_My_TypePunkt2(sTypeRN);
      lGorod:=false;
      if sType<>'' then begin
        if dmBase.TypePunkt.Locate('ID',sType,[]) then begin
          if dmBase.TypePunkt.FieldByName('ISGOROD').AsBoolean then begin
            lGorod:=true;
          end;
        end;
      end;
      if sType<>'' then Result:=true;
    end;
  end;
end;

//-------------------------------------------------------------------
function TGisun.Decode35_My_TypePunkt2(sTypeRN:String):String;
begin
  Result:=IntToStr(Category2TypePunkt(sTypeRN));
end;

// fldTipZ          - ��� ���. ������ � ������� ������
// 'RN_'+fldTipZ    - ��� ���. ������ � ������� ������ ����������� �� ��� ��
//-------------------------------------------------------------------
procedure TGisun.CodePunkt_MestoRogd(dsDokZ: TDataSet; fldTipZ,fldGorodZ,fldGorodBelZ: String;
                                     dsPerson: TDataSet; fldTipP,fldGorodP,fldGorodBelP: String);
var
  sType,sName,sNameBel,s:String;
  fld:TField;
begin
  sName:=Trim(dsDokZ.FieldByName(fldGorodZ).AsString);
  if fldGorodBelZ<>''
    then sNameBel:=Trim(dsDokZ.FieldByName(fldGorodBelZ).AsString)
    else sNameBel:='';
  if sName<>'' then begin
    fld:=dsDokZ.FindField('RN_'+fldTipZ);
    if (fld=nil) or (fld.AsString='') then begin
    // ���� ��� ���. ������ �� ��� �� ������   (��� �������� �������)
      sType:='';
      if dsDokZ.FieldByName(fldTipZ).AsString<>'' then begin
        if dmBase.TypePunkt.Locate('ID',dsDokZ.FieldByName(fldTipZ).AsString,[]) then begin
          sType := dmBase.TypePunkt.FieldByName('GISUN68').AsString;   // ��� ���. ������ ��� ����� ��������
        end;
      end;
    end else begin
    // ���� ��� �������� ��� ���. ������ �� ��� ��
      sType:=fld.AsString;
      s:='';
      if AllSpr.Locate('TYPESPR;EXTCODE', VarArrayOf([CLASS_TYPEPUNKT_MR, sType]),[]) then begin
        s:=ANSIUpperCase(AllSpr.fieldByName('LEX1').AsString)+' '; // ������������ ���� ��-������
        if ANSIUpperCase(Copy(sName,1,Length(s)))=s
          then sName:=Copy(sName,Length(s)+1,Length(sName));
        s:=ANSIUpperCase(AllSpr.fieldByName('LEX2').AsString)+' '; // ������������ ���� ��-����������
        if ANSIUpperCase(Copy(sNameBel,1,Length(s)))=s
          then sNameBel:=Copy(sNameBel,Length(s)+1,Length(sNameBel));
      end;
    end;
    dsPerson.FieldByName(fldTipP).AsString:=sType;
    dsPerson.FieldByName(fldGorodP).AsString:=sName;
    if fldGorodBelZ<>''
      then dsPerson.FieldByName(fldGorodBelP).AsString:=sNameBel;
  end;
end;
//-------------------------------------------------------------------
procedure TGisun.DecodePunkt_MestoGit(dsDokZ: TDataSet; fldTipZ,fldGorodZ,fldGorodBelZ: String; dsPerson: TDataSet);
var
  r:TPunktMesto;
  fld:TField;
begin
{
T_TIP_GOROD        ftString        5   ResponsePerson.data.addresses.locality_type.type_       ;��� ����������� ������ (��� ��������������)
K_TIP_GOROD        ftString       10   ResponsePerson.data.addresses.locality_type.code        ;��� ����������� ������ (������� ��������)
N_TIP_GOROD        ftString      255   ResponsePerson.data.addresses.locality_type.lexema.text ;��� ����������� ������
T_GOROD            ftString        5   ResponsePerson.data.addresses.locality.type_            ;���������� ����� (��� ��������������)
K_GOROD            ftString       10   ResponsePerson.data.addresses.locality.code             ;���������� ����� (������� ��������)
N_GOROD            ftString      255   ResponsePerson.data.addresses.locality.lexema.text      ;���������� �����
}
  // �������� ��� ��������� �� ��� ��
  fld:=dsDokZ.FindField('RN_'+fldTipZ);
  if fld<>nil then fld.AsString:=dsPerson.FieldByName('K_TIP_GOROD').AsString;

  r:=DecodePunkt_MestoGitEx(dsPerson);
  dsDokZ.FieldByName(fldTipZ).AsString:=r.Type_Kod;
  dsDokZ.FieldByName(fldGorodZ).AsString:=r.Name;

  // ������������ �� ���������� ���� �� ����
  {
  if fldGorodBelZ<>'' then begin
    s:=dsPerson.FieldByName('N_TIP_GOROD_B_R').AsString;
    if (s='') and (dsPerson.FieldByName('K_TIP_GOROD_R').AsString<>'') and (AllSpr<>nil) then begin
      if AllSpr.Locate('TYPESPR;EXTCODE', VarArrayOf([35, dsPerson.FieldByName('K_TIP_GOROD_R').AsString]), []) then begin
        s:=AllSpr.fieldByName('LEX2').AsString;
      end;
    end;
    dsDokZ.FieldByName(fldGorodBelZ).AsString:=s+' '+dsPerson.FieldByName('GOROD_B_R').AsString;
  end;
  }
end;

//-------------------------------------------------------------------
function TGisun.AdresGitIsEmpty(dsPerson: TDataSet):Boolean;
begin
  if Trim(dsPerson.FieldByName('N_GOROD').AsString)='' then begin
    Result:=true;
  end else begin
    Result:=false;
  end;
end;
//-------------------------------------------------------------------
function TGisun.getSoato(ds:TDataSet; var AteID:Integer; var strSoato:String; var strName:String):Boolean;
var
  sPunkt, sRnGor:String;
  dsAte:TDataset;
  lName:Boolean;
begin
{
N_OBL              ftString      255   ResponsePerson.data.address.area.lexema.text          ;�������
N_RAION            ftString      255   ResponsePerson.data.address.region.lexema.text        ;�����
N_SOVET            ftString      255   ResponsePerson.data.address.soviet.lexema.text        ;�������� �����
T_TIP_GOROD        ftString        5   ResponsePerson.data.addresses.locality_type.type_       ;��� ����������� ������ (��� ��������������)
K_TIP_GOROD        ftString       10   ResponsePerson.data.addresses.locality_type.code        ;��� ����������� ������ (������� ��������)
N_TIP_GOROD        ftString      255   ResponsePerson.data.addresses.locality_type.lexema.text ;��� ����������� ������
N_TIP_GOROD_B      ftString      255   ResponsePerson.data.addresses.locality_type.lexema.text ;��� ����������� ������ (���.)
T_GOROD            ftString        5   ResponsePerson.data.addresses.locality.type_            ;���������� ����� (��� ��������������)
K_GOROD            ftString       10   ResponsePerson.data.addresses.locality.code             ;���������� ����� (������� ��������)
N_GOROD            ftString      255   ResponsePerson.data.addresses.locality.lexema.text      ;���������� �����
N_GOROD_B          ftString      255   ResponsePerson.data.addresses.locality.lexema.text      ;���������� ����� (���.)
K_RN_GOROD         ftString       10   ResponsePerson.data.address.city_region.code          ;����� ������ (������� ��������)
N_RN_GOROD         ftString      255   ResponsePerson.data.address.city_region.lexema.text   ;����� ������
}
  Result:=false;
  AteID:=0;
  strSoato:='';

  if not CheckAteGis
    then exit;         // �� ����� ���������, �� ��� ������ �� ��������

  sPunkt:=ds.FieldByName('K_GOROD').AsString;
  sRnGor:=ds.FieldByName('K_RN_GOROD').AsString;
  if not dmBase.AteSYS.Active
    then exit;
  dsAte:=dmBase.AteSYS;
  if strName='-' then lName:=false else lName:=true;
  strName:='';
  if sPunkt<>'' then begin
    try
      if sRnGor<>'' then begin
        if dsAte.Locate('ATE_ID', sRnGor, []) then begin
          if dsAte.FieldByName('ATE_PARENTID').AsString=sPunkt then begin  // !!!  ����� �� ������ ������
            strSoato:=dsAte.FieldByName('KOD').AsString;
            AteID:=StrToIntDef(sRnGor,0);
          end;
        end else begin
          sRnGor:='';
        end;
      end else begin
        if dsAte.Locate('ATE_ID', sPunkt, []) then begin
          strSoato:=dsAte.FieldByName('KOD').AsString;
          AteID:=StrToIntDef(sPunkt,0);
        end;
      end;
    except
      strSoato:='';
      AteID:=0;
    end;
  end;
  if (strSoato<>'') and (AteID>0) then begin
    Result:=true;
    if lName then begin
      AddString(strName, ds.FieldByName('N_OBL').AsString, sokrObl, ', ');
      AddString(strName, ds.FieldByName('N_RAION').AsString, sokrRn, ', ');
      AddString(strName, ds.FieldByName('N_GOROD').AsString, ds.FieldByName('N_TIP_GOROD').AsString, ', ');
      AddString(strName, ds.FieldByName('N_RN_GOROD').AsString, sokrRn, ', ');
    end;
  end;
end;
//-------------------------------------------------------------------
function TGisun.DecodePunkt_MestoGitEx(dsPerson: TDataSet):TPunktMesto;
var
  sType:String;
begin
  sType:=Decode35_My_TypePunkt2(dsPerson.FieldByName('K_TIP_GOROD').AsString);
  Result.type_kod:=sType;
  if sType='' then begin      // �� ����� ������������
    Result.Name:=CaseAdres(dsPerson.FieldByName('N_TIP_GOROD').AsString+' '+dsPerson.FieldByName('N_GOROD').AsString);
    Result.Name_B:=CaseAdres(dsPerson.FieldByName('N_TIP_GOROD_B').AsString+' '+dsPerson.FieldByName('N_GOROD_B').AsString);
  end else begin
    Result.Name:=CaseAdres(dsPerson.FieldByName('N_GOROD').AsString);
    Result.Name_B:=CaseAdres(dsPerson.FieldByName('N_GOROD_B').AsString);
  end;

  // ������������ �� ���������� ���� �� ����
  {
  if fldGorodBelZ<>'' then begin
    s:=dsPerson.FieldByName('N_TIP_GOROD_B_R').AsString;
    if (s='') and (dsPerson.FieldByName('K_TIP_GOROD_R').AsString<>'') and (AllSpr<>nil) then begin
      if AllSpr.Locate('TYPESPR;EXTCODE', VarArrayOf([35, dsPerson.FieldByName('K_TIP_GOROD_R').AsString]), []) then begin
        s:=AllSpr.fieldByName('LEX2').AsString;
      end;
    end;
    dsDokZ.FieldByName(fldGorodBelZ).AsString:=s+' '+dsPerson.FieldByName('GOROD_B_R').AsString;
  end;
  }
end;

//-------------------------------------------------------------------
procedure TGisun.DecodePunkt_MestoRogd(dsDokZ: TDataSet; fldTipZ,fldGorodZ,fldGorodBelZ: String; dsPerson: TDataSet);
var
  sType:String;
  r:TPunktMesto;
  fld:TField;
begin
  // �������� ��� ��������� �� ��� ��
  fld:=dsDokZ.FindField('RN_'+fldTipZ);
  if fld<>nil then  fld.AsString:=dsPerson.FieldByName('K_TIP_GOROD_R').AsString;

  r:=DecodePunkt_MestoRogdEx(dsPerson);
  sType:=r.Type_Kod;
  dsDokZ.FieldByName(fldTipZ).AsString:=sType;    // ��� ���. ������ � ��"����"
  dsDokZ.FieldByName(fldGorodZ).AsString:=r.Name;
  if (fldGorodBelZ<>'')  then begin
    dsDokZ.FieldByName(fldGorodBelZ).AsString:=r.Name_B;
  end;
end;

//-------------------------------------------------------------------
function TGisun.DecodePunkt_MestoSmertEx(dsPerson: TDataSet):TPunktMesto;
var
  s,ss,sType:String;
  lLower:Boolean;
begin
{
S_TIP_GOROD        ftString       10   ResponsePerson.data.deaths.death_data.decease_place.type_city_d.code  ;��� ���������� ������
S_TIP_GOROD_N      ftString       50   ResponsePerson.data.deaths.death_data.decease_place.type_city_d.lexema.text  ;��� ���������� ������
S_GOROD            ftString       50   ResponsePerson.data.deaths.death_data.decease_place.city_d       ;��������� ����� �� ������� �����
S_GOROD_B          ftString       50   ResponsePerson.data.deaths.death_data.decease_place.city_d_bel   ;��������� ����� �� ����������� �����
}
  // ������ ������������ � ����������� ����� ���. �������
  ss:=Trim(dsPerson.FieldByName('S_TIP_GOROD').AsString);
  if ss<>'' then begin
    if dmBase.TypePunkt.Locate('GISUN68',ss,[]) then begin
      sType := dmBase.TypePunkt.FieldByName('ID').AsString;   // ��� ���. ������ �� ��"����"
    end else begin
      sType:='';  // �� �����
    end;
  end else begin
    sType:='';  // ������ ������ ���
  end;
  Result.Name_B:='';
  Result.Type_Kod:=sType;    // ��� ���. ������ � ��"����"
  if sType='' then begin  // ���� ��� ������
    // ���������� ������������
    s:=CaseAdres(dsPerson.FieldByName('S_GOROD').AsString);
    lLower:=LastSimIsLower(s); // ��������� ������ � ������������ ���. ������ ���������
    ss:='';  // !!!      'S_TIP_GOROD_NAME'
    if lLower then ss:=ANSILowerCase(dsPerson.FieldByName('S_TIP_GOROD_N').AsString)   // ������������ ���� ������ �� ��� ��
              else ss:=ANSIUpperCase(dsPerson.FieldByName('S_TIP_GOROD_N').AsString);
    Result.Name:=Trim(ss+' '+s);
    Result.Name_B:='';
    // ������������ �� ����������
    {
    if (dsPerson.FieldByName('GOROD_B_R').AsString<>'') then begin
//      s:=dsPerson.FieldByName('N_TIP_GOROD_B_R').AsString;
      s:='';
      if lLower  then s:=ANSILowerCase(s)  else s:=ANSIUpperCase(s);
      //--------- ���� ������������ ��-���������� �� ������ �� ��� �� ---------
      if (s='') and (dsPerson.FieldByName('K_TIP_GOROD_R').AsString<>'') and (AllSpr<>nil) then begin
        if AllSpr.Locate('TYPESPR;EXTCODE', VarArrayOf([CLASS_TYPEPUNKT_MR, dsPerson.FieldByName('K_TIP_GOROD_R').AsString]),[]) then begin
          if lLower
            then s:=ANSILowerCase(AllSpr.fieldByName('LEX2').AsString)
            else s:=ANSIUpperCase(AllSpr.fieldByName('LEX2').AsString);
        end;
      end;
      //-----------------------------------------------------------------------
      Result.Name_B:=s+' '+dsPerson.FieldByName('S_GOROD_B').AsString;
    end;
    }
  end else begin
    Result.Name:=CaseAdres(dsPerson.FieldByName('S_GOROD').AsString);
    Result.Name_B:=CaseAdres(dsPerson.FieldByName('S_GOROD_B').AsString);
  end;
end;

//-------------------------------------------------------------------
function TGisun.DecodePunkt_MestoRogdEx(dsPerson: TDataSet):TPunktMesto;
var
  s,ss,sType:String;
  lLower:Boolean;
begin
{
T_TIP_GOROD_R      ftString        5   ResponsePerson.data.birth_place.type_city_b.type_       ;��� ���������� ������ �������� (��� ��������������)
K_TIP_GOROD_R      ftString       10   ResponsePerson.data.birth_place.type_city_b.code        ;��� ���������� ������ �������� (������� ��������)
N_TIP_GOROD_R      ftString       50   ResponsePerson.data.birth_place.type_city_b.lexema.text ;��� ���������� ������ ��������
N_TIP_GOROD_B_R    ftString       50   ResponsePerson.data.birth_place.type_city_b.lexema[blr].text ;��� ���������� ������ �������� �� ����������
GOROD_R            ftString       80   ResponsePerson.data.birth_place.city_b                  ;��������� ����� �� ������� �����
GOROD_B_R          ftString       80   ResponsePerson.data.birth_place.city_b_bel              ;��������� ����� �� ����������� �����
}
  // ������ ������������ � ����������� ����� ���. �������
  ss:=Trim(dsPerson.FieldByName('K_TIP_GOROD_R').AsString);
  if ss<>'' then begin
    if dmBase.TypePunkt.Locate('GISUN68',ss,[]) then begin
      sType := dmBase.TypePunkt.FieldByName('ID').AsString;   // ��� ���. ������ �� ��"����"
    end else begin
      sType:='';  // �� �����
    end;
  end else begin
    sType:='';  // ������ ������ ���
  end;
  Result.Name_B:='';
  Result.Type_Kod:=sType;    // ��� ���. ������ � ��"����"
  if sType='' then begin  // ���� ��� ������
    // ���������� ������������
    s:=CaseAdres(dsPerson.FieldByName('GOROD_R').AsString);
    lLower:=LastSimIsLower(s); // ��������� ������ � ������������ ���. ������ ���������
    if lLower then ss:=ANSILowerCase(dsPerson.FieldByName('N_TIP_GOROD_R').AsString)   // ������������ ���� ������ �� ��� ��
              else ss:=ANSIUpperCase(dsPerson.FieldByName('N_TIP_GOROD_R').AsString);
    Result.Name:=ss+' '+s;
    // ������������ �� ����������
    if (dsPerson.FieldByName('GOROD_B_R').AsString<>'') then begin
      s:=dsPerson.FieldByName('N_TIP_GOROD_B_R').AsString;
      if lLower  then s:=ANSILowerCase(s)  else s:=ANSIUpperCase(s);
      //--------- ���� ������������ ��-���������� �� ������ �� ��� �� ---------
      if (s='') and (dsPerson.FieldByName('K_TIP_GOROD_R').AsString<>'') and (AllSpr<>nil) then begin
        if AllSpr.Locate('TYPESPR;EXTCODE', VarArrayOf([CLASS_TYPEPUNKT_MR, dsPerson.FieldByName('K_TIP_GOROD_R').AsString]),[]) then begin
          if lLower
            then s:=ANSILowerCase(AllSpr.fieldByName('LEX2').AsString)
            else s:=ANSIUpperCase(AllSpr.fieldByName('LEX2').AsString);
        end;
      end;
      //-----------------------------------------------------------------------
      Result.Name_B:=s+' '+CaseAdres(dsPerson.FieldByName('GOROD_B_R').AsString);
    end;
  end else begin
    Result.Name:=CaseAdres(dsPerson.FieldByName('GOROD_R').AsString);
    Result.Name_B:=CaseAdres(dsPerson.FieldByName('GOROD_B_R').AsString);
  end;
end;


//-------------------------------------------------------------------
function TGisun.Decode_Pol(strPol : String) : String;
begin
  if (strPol='F') or (strPol='�')
    then Result:='�'
    else Result:='�';
end;

function TGisun.Code_Pol(strPol : String) : String;
begin
  if (strPol='�')
    then Result:='F'    // female
    else Result:='M';   // male
end;

//-------------------------------------------------------------------
function TGisun.Decode_Alfa3(strKod : String; strName:String) : String;
begin
  Result := '';
  if strKod<>'' then begin
    if Pos('BELARUS',strKod)>0 then begin
      strKod:='BLR';  // !!!
    end;
    if ANSIUpperCase(strName)='��������' then begin
      Result := DEU_GDR;                // �������� (���� ������ ���)
    end else begin
      if dmBase.SprStran.Locate('ALFA3',strKod,[]) then begin
        Result := dmBase.SprStran.FieldByName('ID').AsString;
      end;
    end;
  end;
end;

//-----------------------------------------------------------------
function TGisun.Code_Alfa3Ex(strKod: String; fldLex:TField; fldLexB:TField): String;
begin
  Result:='0';
  if (strKod<>'') then begin
    if dmBase.SprStran.Locate('ID',strKod,[]) then begin
      Result:=Trim(dmBase.SprStran.FieldByName('ALFA3').AsString);
      if (Result='999') or (Result='') or (Result='0') then begin  // ��� ������������ � ����������� ��� ��
        Result:='0';
        if (fldLex<>nil) then begin
          fldLex.AsString:=Trim(dmBase.SprStran.FieldByName('FNAME').AsString);
        end;
        if (fldLexB<>nil) then begin
          fldLexB.AsString:=Trim(dmBase.SprStran.FieldByName('FNAME_B').AsString);
        end;
      end else begin
        if Copy(Result,1,2)='DE'    // ��� ��������  �.�. �� � ����������� 3 �����
          then Result:='DEU'; // DEU
      end;
    end;
  end;
end;
//-----------------------------------------------------------------
function TGisun.Code_Alfa3(strKod: String): String;
begin
  if (strKod<>'') then begin
    if dmBase.SprStran.Locate('ID',strKod,[]) then begin
      Result:=Trim(dmBase.SprStran.FieldByName('ALFA3').AsString);
      if Copy(dmBase.SprStran.FieldByName('ALFA3').AsString,1,2)='DE'    // ��� ��������  �.�. �� � ����������� 3 �����
        then Result:='DEU'; // DEU
    end else begin
      Result:='0';
    end;
  end else begin
    Result:='0';
  end;
end;

//---------- ������� ������ �������� ------------------------
function TGisun.Code_Status(dsDok:TDataSet; sGrag,sStatus:String; sFamilia:String):String;
begin
  Result:='';
  if (Trim(dsDok.FieldByName(sStatus).AsString)='') or (dsDok.FieldByName(sStatus).AsString=ST_FIKT) then begin  // ���� �� ��� �������� �� ��� ��
    if (dsDok.FieldByName(sGrag).AsString='') then begin
      Result:=ST_FIKT;     // ������� ��� ����������� ���������
    end else if (dsDok.FieldByName(sGrag).AsString<>'112') then begin  // ���� �� �� (��������)
      Result:=ST_INOST;     // ����������
    end;
    if (sFamilia<>'') and (Result='') then begin
      if (dsDok.FieldByName(sFamilia).AsString='') then begin
        Result:=ST_FIKT;     // ������� ��� ������� ���������
      end;
    end;
  end;
  if (Result='') then begin       // ����� ��������� ��� ���������
    Result:=dsDok.FieldByName(sStatus).AsString;
  end;
end;

//------------------------------------------------------------------
function TGisun.Code_Dokument(strType: String): String;
begin
  Result:='';
  if (strType<>'') then begin
    if dmBase.SprTypeDok.Locate('ID',strType,[]) then begin
      Result := dmBase.SprTypeDok.FieldByName('KOD_GISUN').AsString;
    end;
  end;
end;

function TGisun.Decode_Dokument(strType: String): String;
begin
  Result:='';
  if (strType<>'') then begin
    if dmBase.SprTypeDok.Locate('KOD_GISUN',strType,[]) then begin
      Result := dmBase.SprTypeDok.FieldByName('ID').AsString;
    end;
  end;
end;
//-----------------------------------------------------
function TGisun.GetEmptyDate:String;
begin
//  Result:='00000000';  ???
  Result:='';
end;

//----------------------------------------------------------------------------------
function TGisun.DokumentWithIN(nDok:Integer): Boolean;
begin
  Result:=true;
  // ���������� �������� �� ������� ��(1) � �� ��� �� ����������(2,3)
  if (nDok>3) or (nDok=0) then begin
    Result:=false;   // �������� ��� �� (������ �� ���� �� �������������)
  end;
end;

//--------------------------------------------------------------------------
function TGisun.SetDokSvid(f:TfmSimpleD; ds:TDataSet; sAdd:String; lNotSvid:Boolean):String;
var
  sNomer,sSeria:String;
  dDate:TDateTime;
  sID:String;
  lOk:Boolean;
  function GetTypeDok_:String;
  begin
    case f.TypeObj of
      _TypeObj_ZRogd  : result:='54100005';
      _TypeObj_ZSmert : result:='54100009';
      _TypeObj_ZBrak  : result:=DOK_SVID_BRAK;
      _TypeObj_ZRast  : result:=DOK_SVID_RAST;
      _TypeObj_ZChName: result:='54100008';
      _TypeObj_ZAdopt : result:='54100025';
      _TypeObj_ZUstOtc: result:=DOK_SVID_USTOTC;
      _TypeObj_ZUstMat: result:='54100027';
    end;
  end;
begin
  dDate:=0;
  sNomer:='';
  // lNotSvid=true   !!! ����� �������� ��� ������ ������������� !!!
  // lNotSvid=false  ���������� ����� �������������
  if not lNotSvid then begin  //
    // ���� ��������� ������������� � ������� ��� ������
    if f.DokumentPOVTOR.AsBoolean and not f.FOnlySvid then begin
      if f.SvidPovtor.RecordCount>0 then begin
        f.SvidPovtor.Last;
        if not f.SvidPovtorSVID_DATE.IsNull then begin
          dDate:=f.SvidPovtorSVID_DATE.AsDateTime;
        end;
      end;
      sSERIA:=Trim(f.SvidPovtorSVID_SERIA.AsString);
      sNOMER:=Trim(f.SvidPovtorSVID_NOMER.AsString);
    end else begin
      sSERIA:=Trim(f.Dokument.FieldByName('SVID_SERIA').AsString);
      sNOMER:=Trim(f.Dokument.FieldByName('SVID_NOMER').AsString);
      if not f.Dokument.FieldByName('DATESV').IsNull then begin
        dDate:=f.Dokument.FieldByName('DATESV').AsDateTime;
      end;
    end;
  end;
  {$IFDEF LAIS}
    sID:=MessageSource;    //���. �����, �������� ��������    ������ �����������
  {$ELSE}
    // ���� ��������� ������������� ��� ������ �������������
    if f.DokumentPOVTOR.AsBoolean or f.FOnlySvid then begin
      sID:=MessageSource; //���. �����, �������� ��������
    end else begin
      sID:=f.Dokument.FieldByName('ID_ZAGS').AsString;
      if MessageSource<>sID then begin
        {$IFDEF ZAGS}
          // ������ � ��������� �������������� ������� ����  SysSpr.SprZAGS
          lOk:=SystemProg.CheckKodZAGS_to_GISRN(sID);
        {$ELSE}
          lOk:=false;
        {$ENDIF}
        if not lOk then begin
          // ������ � �������������� ������� ���� ��������
          if not AllSpr.Locate('TYPESPR;EXTCODE', VarArrayOf([CLASS_ORGAN_REG,sID]),[]) then begin
            sID:=MessageSource;
          end;
        end;
      end;
    end;
  {$ENDIF}
  Result:='';
  if (sNomer<>'') and (dDate<>0) then begin
    if sAdd='' then begin
      ds.FieldByName('DOC_TIP').AsString:=GetTypeDok_; //��� ���������  ��. ����
      ds.FieldByName('DOC_ORGAN').AsString:=sID; //���. �����, �������� ��������
      ds.FieldByName('DOC_DATE').AsDateTime:=dDate; //���� ������
      ds.FieldByName('DOC_SERIA').AsString:=sSeria; //����� ���������
      ds.FieldByName('DOC_NOMER').AsString:=sNomer; //����� ���������
    end else begin
      ds.FieldByName(sAdd+'TIP').AsString:=GetTypeDok_; //��� ���������  ��. ����
      ds.FieldByName(sAdd+'ORGAN').AsString:=sID; //���. �����, �������� ��������
      ds.FieldByName(sAdd+'DATE').AsDateTime:=dDate; //���� ������
      ds.FieldByName(sAdd+'SERIA').AsString:=sSeria; //����� ���������
      ds.FieldByName(sAdd+'NOMER').AsString:=sNomer; //����� ���������
    end;
    Result:=' ����-��('+GetTypeDok_+','+sID+'): '+sSeria+' '+sNomer+' '+DatePropis(dDate,3);
  end else begin
    if sAdd='' then begin
      ds.FieldByName('DOC_DATE').AsVariant:=null;
    end else begin
      ds.FieldByName(sAdd+'DATE').AsVariant:=null;
    end;
  end;
  if (Result<>'') and FEnableTextLog then begin
    RegInt.TextLog:=RegInt.TextLog+' '+Result;
  end;
end;
//--------------------------------------------------------------------------
procedure TGisun.CheckPovtorToGis(f:TfmSimpleD);
var
  lWrite:Boolean;
begin
  lWrite:=false;
  if f.DokumentPOVTOR.AsBoolean and not f.FOnlySvid then begin
    if f.SvidPovtor.RecordCount>0 then begin
      f.SvidPovtor.Last;
      if (Trim(f.SvidPovtorSVID_NOMER.AsString)<>'') and (f.SvidPovtorGISRN.AsInteger=0) then begin
        EditDataSet(f.SvidPovtor);
        f.SvidPovtorGISRN.AsInteger:=1;
        f.SvidPovtor.Post;
        lWrite:=true;
      end;
    end;
  end else if f.FOnlySvid then begin
    if f.DokumentSVID_GISRN.AsBoolean=false then begin
      EditDataSet(f.Dokument);
      f.DokumentSVID_GISRN.AsBoolean:=true;
      PostDataSet(f.Dokument);
      lWrite:=true;
    end;
  end;
  if lWrite and (f.DokumentID.AsInteger > -1) then
    f.WriteSvidPovtor(f.TypeObj, f.DokumentID.AsInteger);
end;
//--------------------------------------------------------------------------
function TGisun.SetOrganAkt(f:TfmSimpleD; ds:TDataSet):String;       // vadim
{$IFNDEF LAIS}
var
  fld,fldN:TField;
  sID:String;
  lOk:Boolean;
{$ENDIF}
begin
{$IFDEF LAIS}
  ds.FieldByName('ACT_ORGAN').AsString:=MessageSource;
{$ELSE}
  // ������������ ���� ��������� �������
  fldN:=ds.FindField('NAME_ZAGS');
  if (fldN<>nil) and (fldN.AsString<>'') then begin
    ds.FieldByName('ACT_ORGAN').AsString:='0';
    fld:=ds.FindField('ACT_ORGAN_LEX');
    if (fld<>nil) and (fld.AsString<>'') then begin
      fld.AsString:=fldN.AsString;
    end;
    exit;  // !!!
  end;

  sID:=f.Dokument.FieldByName('ID_ZAGS').AsString;
  //���. �����, ������������� ������� ������
  if MessageSource=sID then begin
    ds.FieldByName('ACT_ORGAN').AsString:=MessageSource;
  end else begin
    {$IFDEF ZAGS}
      // ������ � ��������� �������������� ������� ����  SysSpr.SprZAGS
      lOk:=SystemProg.CheckKodZAGS_to_GISRN(sID);
    {$ELSE}
      lOk:=false;
    {$ENDIF}
    if lOk then begin
      ds.FieldByName('ACT_ORGAN').AsString:=sID;
    end else begin
      // ������ � �������������� ������� ���� ��������
      if AllSpr.Locate('TYPESPR;EXTCODE', VarArrayOf([CLASS_ORGAN_REG,sID]),[]) then begin
        ds.FieldByName('ACT_ORGAN').AsString:=sID;
      end else begin
//        ds.FieldByName('ACT_ORGAN').AsString:='0';  ���� !!!
        ds.FieldByName('ACT_ORGAN').AsString:=MessageSource;
        fld:=ds.FindField('ACT_ORGAN_LEX');
        if (fld<>nil) then begin
          if dmBase.SprNames.Locate('ID',sID,[]) then begin
            fld.AsString:=dmBase.SprNames.FieldByName('NAME').AsString;
          end;
        end;
      end;
    end;
  end;
{$ENDIF}
  Result:='���('+ds.FieldByName('ACT_ORGAN').AsString+')';
  if (Result<>'') and FEnableTextLog then begin
    RegInt.TextLog:=RegInt.TextLog+' '+Result;
  end;
end;
//--------------------------------------------------------------------------
function TGisun.CheckMessageSource(f:TfmSimpleD; var sErr:String):Boolean;
var
  sID:String;
begin
  // ���������� ��������� ��������� ����� ���������� �/�
  Result:=true;
  if OrganZagsAsMessageSource then begin
    sErr:='';
    sID:=f.Dokument.FieldByName('ID_ZAGS').AsString;
    if (sID='') or (sID='0') then begin
      sErr:='������� ����� ���� �� ����� ��������� � �������� ��������� ���������.';
      Result:=false;
    end else begin
      if MessageSource<>sID then begin    // ������� �������� �� ��������� � ������� ����
        MessageSource:=sID;
      end;
    end;
  end else begin
    // ������ �� �������
  end;
end;
//-------------------------------------------------------------------------------------
procedure TGisun.LogToTableLog(Akt:TfmSimpleD; sOper:String);
begin
  if IsWriteLogToBase and dmBase.Log.Active then begin
    if (Akt.DokumentID.AsInteger>0) and (RegInt.Log.Text<>'') then begin
      if dmBase.Log.Locate('TYPEOBJ;ID', VarArrayOf([Akt.TypeObj, Akt.DokumentID.AsInteger]),[]) then begin
        dmBase.Log.Edit;
      end else begin
        dmBase.Log.Append;
        dmBase.Log.FieldByName('TYPEOBJ').AsInteger:=Akt.TypeObj;
        dmBase.Log.FieldByName('ID').AsInteger:=Akt.DokumentID.AsInteger;
      end;
      try
        dmBase.Log.FieldByName('USERID').AsString:=dmBase.UserId;
        dmBase.Log.FieldByName('LAST_DATE').AsDateTime:=Now;
        dmBase.Log.FieldByName('LOGSTR').AsString:=dmBase.Log.FieldByName('LOGSTR').AsString+
           StringOfChar('>',40)+chr(13)+
           '>>>>> '+FormatDateTime('dd.mm.yyyy hh:nn:ss',Now)+'  '+sOper+' <<<<< '+chr(13)+
           StringOfChar('>',40)+chr(13)+
           RegInt.Log.Text;
        dmBase.Log.Post;
      except
        dmBase.Log.Cancel;
      end;
    end;
  end;
end;
//-------------------------------------------------------------------------------------
procedure TGisun.WriteTextLog(sOper:String;sFile:String);
begin
  if FEnableTextLog then begin
    if sFile='' then sFile:=LOG_GISUN;
    sFile:=NameFromExe(sFile+'.log');
    try
      WriteStringLog(sOper,sFile);
    except
    end;
  end;
end;
//-------------------------------------------------------------------------------------
procedure TGisun.CheckSizeFileLog(sFile:String; nSizeMB:Integer);
begin
  if FEnableTextLog then begin
    sFile:=NameFromExe(sFile+'.log');
    CheckSizeLog(sFile,nSizeMB);
  end;
end;

//--------------------------------------------------------------------------
function TGisun.LoadIdentifData(sl:TStringList; Dok:TDataSet; slPar:TStringList):TDataSet;
var
  strSOATO,s : String;
  i,t : Integer;
  ag:TGorodR;
  r:TPunktMesto;
  d:TDateTime;
  ds:TDataSet;
begin
  Result:=nil;
  ClearDataSets;
  Input:=FRegInt.CreateInputTable(akMarriage, opGet);
  for i:=0 to sl.Count-1 do begin
    Input.Append;
    Input.FieldByName('IS_PERSON').AsBoolean:=true;
    if Pos('=',sl.Strings[i]) >0 then begin
      Input.FieldByName('PREFIX').AsString:=sl.Names[i];
      Input.FieldByName('IDENTIF').AsString:=sl.ValueFromIndex[i];
    end else begin
      Input.FieldByName('PREFIX').AsString:='DATA'+IntToStr(i);
      Input.FieldByName('IDENTIF').AsString:=sl.Strings[i];
    end;
    Input.Post;
  end;
  TypeMessage:=QUERY_INFO; // !!!    16.03.2021
  RequestResult:=RegInt.Get(akGetPersonalData, TypeMessage, Input, Output, Error, Dok, slPar);

  if IsDebug then begin
     RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_get.txt');
  end;
  if RequestResult=rrOk then begin
   ds := dbCreateMemTable('PREFIX,Char,20;IDENTIF,Char,14;FAMILIA,Char,100;NAME,Char,50;OTCH,Char,60;POL,Char,1;DATER,Date;TYPEDATER,Integer;DATES,Date;'+
         'FAMILIA_B,Char,100;NAME_B,Char,50;OTCH_B,Char,60;GRAG,Integer;STATUS,Char,1;'+
         'DOK_TYPE,Integer;DOK_ORGAN,Char,10;DOKUMENT,Memo;DOK_SERIA,Char,11;DOK_NOMER,Char,11;DOK_DATE,Date;'+
         'GOSUD_R,Integer;B_OBL_R,Logical;OBL_R,Char,100;OBL_B_R,Char,100;RAION_R,Char,100;RAION_B_R,Char,100;TYPE_GOROD_R,Integer;GOROD_R,Char,100;GOROD_B_R,Char,100;'+
         'GOSUD_G,Integer;OBL_G,Char,100;RAION_G,Char,100;TYPE_GOROD_G,Integer;GOROD_G,Char,100;GOROD_R_G,Char,150;'+
         'OBL_B_G,Char,100;RAION_B_G,Char,100;GOROD_B_G,Char,100;GOROD_R_B_G,Char,150;RNGOROD_B_G,Char,100;ULICA_B_G,Char,100;'+
         'ULICA_G,Char,100;DOM_G,Char,10;KORP_G,Char,10;KV_G,Char,10;RNGOROD_G,Char,100;SOATO_G,Char,10;FIO,Char,150;ADRES_R,Memo;ADRES_G,Memo;DOC_NAME,Memo;REG_DATE,Date;REG_DATE_TILL,Date;','');

   if ds<>nil then begin
     ds.Open;
     OutPut.First;
     while not OutPut.Eof do begin
      ds.Append;
      ds.FieldByName('PREFIX').AsString:=OutPut.FieldByName('PREFIX').AsString;
      ds.FieldByName('IDENTIF').AsString:=OutPut.FieldByName('IDENTIF').AsString;
      ds.FieldByName('FAMILIA').AsString:=CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
      ds.FieldByName('FAMILIA_B').AsString:=CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
      ds.FieldByName('NAME').AsString:=CaseFIO(OutPut.FieldByName('NAME').AsString);
      ds.FieldByName('NAME_B').AsString:=CaseFIO(OutPut.FieldByName('NAME_B').AsString);
      ds.FieldByName('OTCH').AsString:=CaseFIO(OutPut.FieldByName('OTCH').AsString);
      ds.FieldByName('OTCH_B').AsString:=CaseFIO(OutPut.FieldByName('OTCH_B').AsString);
      ds.FieldByName('POL').AsString:=Decode_Pol(OutPut.FieldByName('K_POL').AsString);
      ds.FieldByName('GRAG').AsString:=Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
      ds.FieldByName('FIO').AsString:=Trim(ds.FieldByName('FAMILIA').AsString)+' '+Trim(ds.FieldByName('NAME').AsString)+' '+
                                      Trim(ds.FieldByName('OTCH').AsString);

      if Decode_Date2(OutPut.FieldByName('DATER').AsString, d,t) then begin
        ds.FieldByName('DATER').AsDateTime:=d;
        ds.FieldByName('TYPEDATER').AsInteger:=t;
      end else begin
        ds.FieldByName('DATER').AsString:='';
        ds.FieldByName('TYPEDATER').AsInteger:=0;
      end;

      if Decode_Date2(OutPut.FieldByName('DATES').AsString, d,t,'������')
        then ds.FieldByName('DATES').AsDateTime:=d
        else ds.FieldByName('DATES').AsString:='';
//      ds.FieldByName('TYPEDATER').AsInteger:=t;

      ds.FieldByName('STATUS').AsString:=OutPut.FieldByName('K_STATUS').AsString;
      //���������� ������ (��������, �������������� ��������)
      ds.FieldByName('DOK_TYPE').AsString:=Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString);
      ds.FieldByName('DOK_ORGAN').AsString:=OutPut.FieldByName('K_DOC_ORGAN').AsString;
      ds.FieldByName('DOKUMENT').AsString:=OutPut.FieldByName('N_DOC_ORGAN').AsString;
      ds.FieldByName('DOK_SERIA').AsString:=OutPut.FieldByName('DOC_SERIA').AsString;
      ds.FieldByName('DOK_NOMER').AsString:=OutPut.FieldByName('DOC_NOMER').AsString;
      ds.FieldByName('DOK_DATE').AsString:=OutPut.FieldByName('DOC_DATE').AsString;

      try
        if not OutPut.FieldByName('REG_DATE').IsNull
          then ds.FieldByName('REG_DATE').AsDateTime:=OutPut.FieldByName('REG_DATE').AsDateTime;
      except
      end;
      // ����� ��������
      ds.FieldByName('GOSUD_R').AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,OutPut.FieldByName('N_GOSUD_R').AsString);
      DecodeObl_MestoRogd( ds,'OBL_R','B_OBL_R','OBL_B_R',OutPut);
      ds.FieldByName('RAION_R').AsString:=CaseAdres(OutPut.FieldByName('RAION_R').AsString);
      ds.FieldByName('RAION_B_R').AsString:=CaseAdres(OutPut.FieldByName('RAION_B_R').AsString);
      r:=DecodePunkt_MestoRogdEx(OutPut);
      ds.FieldByName('TYPE_GOROD_R').AsString:=r.Type_Kod;
      ds.FieldByName('GOROD_R').AsString:=r.Name;
      ds.FieldByName('GOROD_B_R').AsString:=r.Name_B;
      ds.FieldByName('ADRES_R').AsString:=dmBase.GetAdresAkt3(ds,'GOSUD_R,FName;+OBL_R,B_OBL_R;RAION_R;GOROD_R,TYPE_GOROD_R',2);


      //-------- ����� ���������� ----------------------------
      ds.FieldByName('GOSUD_G').AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');
      ds.FieldByName('OBL_G').AsString:=CaseAdres(OutPut.FieldByName('N_OBL').AsString);
      ds.FieldByName('OBL_B_G').AsString:=CaseAdres(OutPut.FieldByName('N_OBL_B').AsString);
      ds.FieldByName('RAION_G').AsString:=CaseAdres(OutPut.FieldByName('N_RAION').AsString);
      ds.FieldByName('RAION_B_G').AsString:=CaseAdres(OutPut.FieldByName('N_RAION_B').AsString);
      r:=DecodePunkt_MestoGitEx(OutPut);
      if Trim(r.Name)<>'' then begin
        ds.FieldByName('TYPE_GOROD_G').AsString:=r.Type_Kod;
        ds.FieldByName('GOROD_G').AsString:=r.Name;
        ds.FieldByName('GOROD_B_G').AsString:=r.Name_B;
      end else begin
        ds.FieldByName('TYPE_GOROD_G').AsString:='';
        ds.FieldByName('GOROD_G').AsString:='';
        ds.FieldByName('GOROD_B_G').AsString:='';
      end;
      ag:=GetGorodREx(OutPut, true, ', ');
      ds.FieldByName('ULICA_G').AsString:=ag.Ulica;
      ds.FieldByName('ULICA_B_G').AsString:=ag.Ulica_B;
      ds.FieldByName('DOM_G').AsString:=ag.Dom;
      ds.FieldByName('KORP_G').AsString:=ag.Korp;
      ds.FieldByName('KV_G').AsString:=ag.Kv;
      ds.FieldByName('RNGOROD_G').AsString:=Decode_RnGorod(OutPut, ['K_RN_GOROD','N_RN_GOROD'], strSoato);  //inc(n);
      ds.FieldByName('RNGOROD_B_G').AsString:=CaseAdres(OutPut.FieldByName('N_RN_GOROD_B').AsString);  //inc(n);

      ds.FieldByName('SOATO_G').AsString:=strSOATO;
      ds.FieldByName('GOROD_R_G').AsString:=ag.Full;
      ds.FieldByName('GOROD_R_B_G').AsString:=ag.Full_B;
      ds.Post;
      OutPut.Next;
     end;
     ds.First;
     Result:=ds;
   end;
  end else begin
    HandleError(RequestResult, akMarriage, opGet, Input, Output, Error, RegInt.FaultError);
  end;
  ClearDataSets;
end;

//--------------------------------------------------------------------------------------
//  ������ �������������� �� ��� � ���� ��������
function TGisun.LoadPersonalIdentif(sl:TStringList; sFamilia:String; sName:String; sOtch:String; dDateR:TDateTime; nTypeDate:Integer):Boolean;
var
   RequestResult: TRequestResult;
   MessageType:String;
begin
  if (Trim(sFamilia)='') or (Trim(sName)='') or (dDateR=0) then begin
    PutError('���������: �������, ��� � ���� ��������.',curakt);
    Result:=false;
    exit;
  end;

  ClearDataSets;
  //1. ������ ������� ��� �������� ������ � �������
  Input:=FRegInt.CreateInputTable(akGetPersonIdentif, opGet);
  //2. ��������� ������������ ������
  Input.Append;
  //�.�.�.
  Input.FieldByName('FAMILIA').AsString:=AnsiUpperCase(sFamilia);
  Input.FieldByName('NAME').AsString:=AnsiUpperCase(sName);
  Input.FieldByName('OTCH').AsString:=AnsiUpperCase(sOtch);
  Input.FieldByName('DATER').AsString:=Code_Date(dDateR,nTypeDate);
  Input.Post;
//  MessageType:='0100';  ����
  MessageType:=QUERY_INFO;   // 16.03.2021  �� ������� ���

//  DataSetToLog('������ ������', Input, meInput.Lines);
  try
     //3. ��������� ������ � �������
     RequestResult:=FRegInt.Get(akGetPersonIdentif, MessageType, Input, Output, Error);
     Result:=RequestResult=rrOk;
     //4. ������������ ��������� �������
     if RequestResult=rrOk then begin
        //4.1. ��� �������� ���������� ������� ��������� ����� ��������
        //     � ����������� ������� - Output
//        DataSetToLog('����� �� ������ ������', Output, meOutput.Lines);
       OutPut.First;
//       ShowMessage(OutPut.FieldByName('COVER_MESSAGE_ID').AsString+'  '+
//                   FormatDateTime('dd.mm.yyyy hh:nn:ss', OutPut.FieldByName('COVER_MESSAGE_TIME').AsDateTime));

       while not Output.Eof do begin
          sl.Add(Output.FieldByName('IDENTIF').AsString);
          Output.Next;
       end;
       OutPut.First;
     end else begin
       if (Error<>nil) and (Error.RecordCount=1) then begin
         Error.First;
         if Error.FieldByName('ERROR_CODE').AsString='05' then begin  // ������ �� ���� �� �������
           Result:=true; // !!!
           sl.Clear;
         end;
       end;
       if not Result then begin
         //4.2. ������������ ������ �������������� � ���������
         HandleError(RequestResult, akGetPersonIdentif, opGet, Input, Output, Error, FRegInt.FaultError);
       end;
     end;
  finally
    ClearDataSets;
  end;
end;

//--------------------------------------------------------------------------------------
//  ������ ������
{
function TGisun.LoadPersonalData1(sIDENTIF:String; var arr: TCurrentRecord): Boolean;
var
  strError,strSOATO,s : String;
  PoleGrnSub,n,i,t : Integer;
  ag:TGorodR;
  r:TPunktMesto;
  d:TDateTime;
begin
  Result:=false;
  ClearDataSets;
  SetLength(arr,0);
//  if RunExchange then begin
    PoleGrnSub:=0;
    //[1] ������ ������
    //1. ������ ������� ��� �������� ������ � �������
    Input:=FRegInt.CreateInputTable(akMarriage, opGet);
    Input.Append;
    Input.FieldByName('IS_PERSON').AsBoolean:=true;
    Input.FieldByName('PREFIX').AsString:='DATA';
    Input.FieldByName('IDENTIF').AsString:=CheckRus2(sIDENTIF);
    Input.Post;
    //3. ��������� ������ � �������
    RequestResult:=RegInt.Get(akGetPersonalData, TypeMessage, Input, Output, Error);
    if IsDebug then begin
       RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_get.txt');
    end;
    if RequestResult=rrOk then begin
      Result:=true;
      OutPut.First;
      SetLength(arr,100);
      //������������ ������
      n:=0;
      arr[n].FieldName:='IDENTIF';      arr[n].Value:=sIDENTIF;      inc(n);  //1
      arr[n].FieldName:='FAMILIA';      arr[n].Value:=OutPut.FieldByName('FAMILIA').AsString;      inc(n);
      arr[n].FieldName:='FAMILIA_B';    arr[n].Value:=OutPut.FieldByName('FAMILIA_B').AsString;    inc(n);
      arr[n].FieldName:='NAME';         arr[n].Value:=OutPut.FieldByName('NAME').AsString;         inc(n);
      arr[n].FieldName:='NAME_B';       arr[n].Value:=OutPut.FieldByName('NAME_B').AsString;       inc(n);
      arr[n].FieldName:='OTCH';         arr[n].Value:=OutPut.FieldByName('OTCH').AsString;         inc(n);
      arr[n].FieldName:='OTCH_B';       arr[n].Value:=OutPut.FieldByName('OTCH_B').AsString;       inc(n);
      arr[n].FieldName:='POL';          arr[n].Value:=Decode_Pol(OutPut.FieldByName('K_POL').AsString);         inc(n);
      arr[n].FieldName:='GRAG';         arr[n].Value:=Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString);       inc(n);

      Decode_Date2(OutPut.FieldByName('DATER').AsString, d,t);
      arr[n].FieldName:='DATER';         arr[n].Value:=d;       inc(n);  // 9
      arr[n].FieldName:='TYPEDATER';     arr[n].Value:=t;       inc(n);  // 10

      arr[n].FieldName:='STATUS';       arr[n].Value:=OutPut.FieldByName('K_STATUS').AsString;      inc(n); // 11
      //���������� ������ (��������, �������������� ��������)
      arr[n].FieldName:='DOK_TYPE';     arr[n].Value:=Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString); inc(n);  // 12
      arr[n].FieldName:='DOK_ORGAN';    arr[n].Value:=OutPut.FieldByName('K_DOC_ORGAN').AsString;   inc(n);
      arr[n].FieldName:='DOKUMENT';     arr[n].Value:=OutPut.FieldByName('N_DOC_ORGAN').AsString;   inc(n);
      arr[n].FieldName:='DOK_SERIA';    arr[n].Value:=OutPut.FieldByName('DOC_SERIA').AsString;     inc(n);
      arr[n].FieldName:='DOK_NOMER';    arr[n].Value:=OutPut.FieldByName('DOC_NOMER').AsString;     inc(n);
      arr[n].FieldName:='DOK_DATE';     arr[n].Value:=OutPut.FieldByName('DOC_DATE').AsString;      inc(n);
      // ����� ��������
      arr[n].FieldName:='GOSUD_R';      arr[n].Value:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString); inc(n);
      arr[n].FieldName:='OBL_R';        arr[n].Value:=OutPut.FieldByName('OBL_R').AsString;                   inc(n);
      arr[n].FieldName:='OBL_B_R';      arr[n].Value:=OutPut.FieldByName('OBL_B_R').AsString;                 inc(n);
      arr[n].FieldName:='RAION_R';      arr[n].Value:=OutPut.FieldByName('RAION_R').AsString;                   inc(n);
      arr[n].FieldName:='RAION_B_R';    arr[n].Value:=OutPut.FieldByName('RAION_B_R').AsString;                 inc(n);  // 21
      r:=DecodePunkt_MestoRogdEx(OutPut);
      arr[n].FieldName:='TYPE_GOROD_R'; arr[n].Value:=r.Type_Kod;              inc(n);  // 22
      arr[n].FieldName:='GOROD_R';      arr[n].Value:=r.Name;                   inc(n);  //
      arr[n].FieldName:='GOROD_B_R';    arr[n].Value:=r.Name_B;                 inc(n);  //
      // ����� ����������
      arr[n].FieldName:='GOSUD_G';      arr[n].Value:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString);  inc(n); // 25
      arr[n].FieldName:='OBL_G';        arr[n].Value:=OutPut.FieldByName('N_OBL').AsString;                     inc(n);
      arr[n].FieldName:='RAION_G';      arr[n].Value:=OutPut.FieldByName('N_RAION').AsString;                   inc(n);
      r:=DecodePunkt_MestoGitEx(OutPut);
      if Trim(r.Name)<>'' then begin
        arr[n].FieldName:='TYPE_GOROD_G'; arr[n].Value:=r.Type_Kod;          inc(n);
        arr[n].FieldName:='GOROD_G';      arr[n].Value:=r.Name;              inc(n);
      end else begin
        arr[n].FieldName:='TYPE_GOROD_G'; arr[n].Value:=null;            inc(n);
        arr[n].FieldName:='GOROD_G';      arr[n].Value:='';              inc(n);
      end;
      ag:=GetGorodREx(OutPut);
      arr[n].FieldName:='ULICA_G';     arr[n].Value:=ag.Ulica;           inc(n);
      arr[n].FieldName:='DOM_G';       arr[n].Value:=ag.Dom;             inc(n);
      arr[n].FieldName:='KORP_G';      arr[n].Value:=ag.Korp;            inc(n);
      arr[n].FieldName:='KV_G';        arr[n].Value:=ag.Kv;              inc(n);
      arr[n].FieldName:='RNGOROD_G';   arr[n].Value:=Decode_RnGorod(OutPut, ['K_RN_GOROD','N_RN_GOROD'], strSoato);  inc(n);
      arr[n].FieldName:='SOATO_G';     arr[n].Value:=strSOATO;           inc(n);
      SetLEngth(arr,n);
    end else begin
      HandleError(RequestResult, akMarriage, opGet, Input, Output, Error, RegInt.FaultError);
    end;
    ClearDataSets;
//  end;
end;
}
//----------------------------------------------------------------------------------
function TGisun.SetTypeMessageAktBirth( Akt : TfmSimpleD; var strError : String) : Boolean;
{$IFNDEF ADD_ZAGS}
begin
  Result:=false;
end;
{$ELSE}
var
  AktRogd : TfmZapisRogd;
  ON_Vozrast,ONA_Vozrast,m,d : Integer;
  lNotRB_ON,lNotRB_ONA : Boolean;
begin
  AktRogd := TfmZapisRogd(Akt);
  AktRogd.Dokument.CheckBrowseMode;
  Result:=false;

  if not CheckMessageSource(AktRogd, strError) then begin
    exit;
  end;

  strError:='';
  TypeAkt := '0100';

  Female:=true;  // ����� ������ � ����
  Male:=true;    // ����� ������ � ����
  Child:=false;  // ����� ������ � �������
  if AktRogd.DokumentCHERN.AsInteger=1
    then ChildIdentif:=true // ����� �� ��� �������
    else ChildIdentif:=false; // ����� �� ��� �������
  RunExchange:=true;  // ��������� ������������� ��� ���
{!!!}DefaultPoleGrn:=0;  // �������� ��� ���� POLE_GRN ���� �� ���� ������������ ��������������
  ON_Vozrast:=0;
  ONA_Vozrast:=0;
  TypeMessage:='*';
  if AktRogd.DokumentDateR.AsString<>'' then begin
    if AktRogd.DokumentON_DateR.AsString<>'' then begin
      SubDate(AktRogd.DokumentDateR.AsDateTime, AktRogd.DokumentON_DateR.AsDateTime,ON_Vozrast,m,d);
    end;
    if AktRogd.DokumentONA_DateR.AsString<>'' then begin
      SubDate(AktRogd.DokumentDateR.AsDateTime, AktRogd.DokumentONA_DateR.AsDateTime,ONA_Vozrast,m,d);
    end;
  end;
  if AktRogd.DokumentGIVOROGD.AsString='0' then begin                       // ���������������
    TypeMessage:='0140';
  end else if (AktRogd.DokumentFIRSTWEEK.AsBoolean=true) or                 // ���� �� ������ ������ �����
              (AktRogd.DokumentTYPEREG.AsString=SPEC_ROGD_UMER) then begin  // ������� �������
    TypeMessage:='0150';
  end else if AktRogd.DokumentTYPEREG.AsString=SPEC_ROGD_PODKID then begin  // ��������
    TypeMessage:='0130';
    Female:=false;
    Male:=false;
  end else if AktRogd.DokumentTYPEREG.AsString=SPEC_ROGD_OTKAZ then begin   // ��������
    TypeMessage:='0120';
  end else if AktRogd.DokumentTYPEREG.AsString=SPEC_ROGD_TRUP then begin    // ������ ���� �������
    TypeMessage:='0151';
    RunExchange:=false;
  end;

  if AktRogd.DokumentSVED.AsString='3' then begin // �� ��������� ������
    if TypeMessage='*' then TypeMessage:='0110';
    if AktRogd.DokumentON_IDENTIF.AsString=''        // 15.01.2020 change  ���� ���� ���������, �� �������� ����� ��������� ������ �� ����
      then Male:=false;                              //
//  Male:=false;      ����
  end else begin
    if ((ON_Vozrast>0) and (ON_Vozrast<16)) or ((ONA_Vozrast>0) and (ONA_Vozrast<16)) then begin  // ������������������
      if TypeMessage='*' then TypeMessage:='0111';
    end;
  end;

  lNotRB_ON:=false;
  lNotRB_ONA:=false;
  // ���� ��������� �������� �� ������� ��(1) � �� ��� �� ����������(2,3)
  if (AktRogd.DokumentON_DOK_TYPE.AsInteger>3) or (AktRogd.DokumentON_DOK_TYPE.AsInteger=0) then begin
    Male:=false;
    lNotRB_ON:=true;
  end;
  // ���� ���������� �������� �� ������� ��(1) � �� ��� �� ����������(2,3)
  if (AktRogd.DokumentONA_DOK_TYPE.AsInteger>3) or (AktRogd.DokumentONA_DOK_TYPE.AsInteger=0) then begin
    Female:=false;
    lNotRB_ONA:=true;
  end;

  if TypeMessage='*' then begin
    if lNotRB_ON and lNotRB_ONA then begin // ����������
      TypeMessage:='0170';
    end else if lNotRB_ON or lNotRB_ONA then begin // ���� ��������� ��� ������ ��� �� ����������
      TypeMessage:='0160';
    end;
  end;
  if TypeMessage='*'
    then TypeMessage:='0100';

  if Male and (AktRogd.DokumentON_IDENTIF.AsString='') then begin
    strError:='��������� ������������� ����';
  end;
  if FeMale and (AktRogd.DokumentONA_IDENTIF.AsString='') then begin
    strError:='��������� ������������� ������';
  end;
  if ChildIdentif then begin
    if (AktRogd.DokumentPOL.AsString='') then begin
      strError:='��������� ��� �������';
    end;
    if (AktRogd.DokumentDATER.AsString='') then begin
      strError:='��������� ���� �������� �������';
    end;
  end;


  if strError=''
    then Result:=true
    else Result:=false;
end;
{$ENDIF}
//------------------------------------------------------------------
function TGisun.CaseAdres(s:String) : String;
begin
 if CheckRegisterAdres then begin
   Result:=CheckRegisterText(EC_FIRST,s,false);
 end else begin
   Result:=s;
 end;
end;
//------------------------------------------------------------------------
function TGisun.CaseUlica(sUl : String) : String;
begin
 if CheckRegisterAdres then begin
  if Q_CharCount(sUl,' ')<=2 then begin   // ������� �������� �� ���� ����
    Result:=FirstUpperEx(sUl,' ');
  end else begin
    Result:=sUl;
  end;
 end else begin
   Result:=sUl;
 end;
end;
//------------------------------------------------------------------------
function TGisun.GetGorodR( ds : TDataSet) : String;
var
  s:String;
begin
  {$IFDEF GISUN2}
  s:=CaseAdres(OutPut.FieldByName('N_RN_GOROD').AsString);
  {$ELSE}
  s:='';
  {$ENDIF}
  if s<>'' then s:=s+GetWordRaion(s,'R')+', ';
  Result:=s+OutPut.FieldByName('N_TIP_UL').AsString+' '+CaseUlica(OutPut.FieldByName('N_UL').AsString);
  if OutPut.FieldByName('DOM').AsString<>''  then Result:=Result+', '+sokrDom+OutPut.FieldByName('DOM').AsString;
  if OutPut.FieldByName('KORP').AsString<>'' then Result:=Result+', '+sokrKorp+OutPut.FieldByName('KORP').AsString;
  if OutPut.FieldByName('KV').AsString<>''   then Result:=Result+', '+sokrKv+OutPut.FieldByName('KV').AsString;
  if Copy(Result,1,1)=',' then Result:=Copy(Result,2,Length(Result));
  Result:=Trim(Result);
end;

//------------------------------------------------------------------------
function TGisun.GetGorodREx( ds : TDataSet; lAddRnGor:Boolean; sDelim:String) : TGorodR;
var
  s,sB:String;
begin
  {$IFDEF GISUN2}
  Result.RnGorod:=CaseAdres(OutPut.FieldByName('N_RN_GOROD').AsString);
  Result.RnGorod_B:=CaseAdres(OutPut.FieldByName('N_RN_GOROD_B').AsString);
  {$ELSE}
  Result.RnGorod:='';
  Result.RnGorod_B:='';
  {$ENDIF}
  if (Result.RnGorod<>'') and lAddRnGor
    then s:=Result.RnGorod+GetWordRaion(Result.RnGorod,'R')+sDelim
    else s:='';
  if (Result.RnGorod_B<>'') and lAddRnGor
    then sB:=Result.RnGorod_B+GetWordRaion(Result.RnGorod,'B')+sDelim
    else sB:='';
  Result.Ulica:=OutPut.FieldByName('N_TIP_UL').AsString+' '+CaseUlica(OutPut.FieldByName('N_UL').AsString);
  Result.Ulica_B:=OutPut.FieldByName('N_TIP_UL_B').AsString+' '+CaseUlica(OutPut.FieldByName('N_UL_B').AsString);
  Result.Dom:=OutPut.FieldByName('DOM').AsString;
  Result.Korp:=OutPut.FieldByName('KORP').AsString;
  Result.Kv:=OutPut.FieldByName('KV').AsString;

  Result.Full:=s+Result.Ulica;
  if Result.Dom<>''  then Result.Full:=Result.Full+sDelim+sokrDom+Result.Dom;
  if Result.Korp<>'' then Result.Full:=Result.Full+sDelim+sokrKorp+Result.Korp;
  if Result.Kv<>''   then Result.Full:=Result.Full+sDelim+sokrKv+Result.Kv;
  if Copy(Result.Full,1,1)=',' then Result.Full:=Copy(Result.Full,2,Length(Result.Full));
  Result.Full:=Trim(Result.Full);

  Result.Full_B:=sB+Result.Ulica_B;
  if Result.Dom<>''  then Result.Full_B:=Result.Full_B+sDelim+sokrDom+Result.Dom;
  if Result.Korp<>'' then Result.Full_B:=Result.Full_B+sDelim+sokrKorp+Result.Korp;
  if Result.Kv<>''   then Result.Full_B:=Result.Full_B+sDelim+sokrKv+Result.Kv;
  if Copy(Result.Full_B,1,1)=',' then Result.Full_B:=Copy(Result.Full_B,2,Length(Result.Full_B));
  Result.Full_B:=Trim(Result.Full_B);

end;

//------------------------------------------------------------------------
// ������ �� ��� �������
function TGisun.GetOnlyIdentif(nCount:Integer; sl:TStringList; lShow:Boolean) : Integer;
var
  i:Integer;
  lErr:Boolean;
begin
  Result:=0;
  lErr:=false;
  if nCount<=0  then nCount:=1;
  if nCount>100 then nCount:=100;  // ������ �� ������
  sl.Clear;
  WriteTextLog('������ �� � ����������: '+IntToStr(nCount),LOG_GISUN);
  if lShow
    then OpenMessage('������ ��         ','',10);
  try
    for i:=1 to nCount do begin
      ClearDataSets;
      //1. ������ ������� ��� �������� ������ � �������
      Input:=FRegInt.CreateInputTable(akBirth, opGet);
      //2. ��������� ������������ ������
      Input.Append;
      Input.FieldByName('IS_PERSON').AsBoolean:=false;
      Input.FieldByName('PREFIX').AsString:='CHILD';
      Input.FieldByName('POL').AsString:= Code_Pol('�');
      Input.FieldByName('DATER').AsString:=Code_Date(dmBase.getCurDate,DATE_FULL);
      Input.Post;
      //2. ��������� ������ � �������
      RequestResult:=RegInt.Get(akBirth, TypeMessage, Input, Output, Error);
      if RequestResult=rrOk then begin
        Inc(Result,1);
        sl.Add(OutPut.FieldByName('NEW_IDENTIF').AsString);
        if lShow
          then ChangeMessage('������ ��  '+IntToStr(i));
      end;
    end;
  finally
    if sl.Count=0 then begin
      WriteTextLog('�� �� ���������',LOG_GISUN);
      lErr:=true;
    end else begin
      WriteTextLog('�� ��������� � ���������� '+IntToStr(sl.Count)+': '+sl.CommaText,LOG_GISUN);
    end;
  end;
  if lShow then begin
    CloseMessage;
    if lErr then begin
      HandleError(RequestResult, akGetPersonIdentif, opGet, Input, Output, Error, FRegInt.FaultError);
    end;
  end;
end;

// ������ �� ��� �������
function TGisun.GetOnlyIdentifList(nCount:Integer; sl:TStringList; lShow:Boolean) : Integer;
var
  i:Integer;
  lErr:Boolean;
begin
  Result:=0;
  lErr:=false;
  if nCount<=0  then nCount:=1;
  if nCount>100 then nCount:=100;  // ������ �� ������
  sl.Clear;
  if lShow
    then OpenMessage('������ ��         ','',10);
  ClearDataSets;
  //1. ������ ������� ��� �������� ������ � �������
  Input:=FRegInt.CreateInputTable(akBirth, opGet);
  //2. ��������� ������������ ������
  for i:=1 to nCount do begin
    Input.Append;
    Input.FieldByName('IS_PERSON').AsBoolean:=false;
    Input.FieldByName('PREFIX').AsString:='CHILD';
    Input.FieldByName('POL').AsString:= Code_Pol('�');
    Input.FieldByName('DATER').AsString:=Code_Date(dmBase.getCurDate,DATE_FULL);
    Input.Post;
  end;
  //2. ��������� ������ � �������
  RequestResult:=RegInt.Get(akBirth, TypeMessage, Input, Output, Error);
  if RequestResult=rrOk then begin
    OutPut.First;
    while not Output.Eof do begin
      sl.Add(OutPut.FieldByName('NEW_IDENTIF').AsString);
      OutPut.Next;
    end;
    Result:=sl.Count;
    WriteTextLog('�� ��������� � ���������� '+IntToStr(Result)+': '+sl.CommaText,LOG_GISUN);
  end else begin
    WriteTextLog('�� �� ���������',LOG_GISUN);
    lErr:=true;
  end;
  if lShow then begin
    CloseMessage;
  end;
  if lErr then begin
    HandleError(RequestResult, akGetPersonIdentif, opGet, Input, Output, Error, FRegInt.FaultError);
  end;
end;

//------------------------------------------------------------------------
// ������ ������ ��� ������� ������ � �������� ��������+�� ��� �������
function TGisun.GetIdentifChild( Akt : TfmSimpleD) : Boolean;
{$IFNDEF ADD_ZAGS}
begin
  Result:=false;
end;
{$ELSE}
var
  AktRogd : TfmZapisRogd;
  strError,strSOATO,strName : String;
  nAteID,PoleGrnSub : Integer;
  ag:TGorodR;
begin
  Result:=false;
  AktRogd := TfmZapisRogd(Akt);
  AktRogd.Dokument.CheckBrowseMode;
  if not SetTypeMessageAktBirth( AktRogd, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end else begin
//    if not ChildIdentif and not Male and not Female then begin
//      RunExchange:=false;   // !!!
//      ShowMessageErr('��� ������ ��� �������');
//      Result:=false;
//    end;
    ClearDataSets;
    if RunExchange then begin
      PoleGrnSub:=0;
      //[1] ������ ������
      //1. ������ ������� ��� �������� ������ � �������
      Input:=FRegInt.CreateInputTable(akBirth, opGet);
      //2. ��������� ������������ ������
      if ChildIdentif then begin
        //������
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=false;
        Input.FieldByName('PREFIX').AsString:='CHILD';
        Input.FieldByName('POL').AsString:= Code_Pol(AktRogd.DokumentPOL.AsString);
//        Input.FieldByName('DATER').AsString:=DTOS(AktRogd.DokumentDATER.AsDateTime,tdClipper);
        Input.FieldByName('DATER').AsString:=Code_Date(AktRogd.DokumentDATER.AsDateTime,DATE_FULL);
        Input.Post;
        {
      end else begin    // ��� ���������� �������������
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='CHILD';
        Input.FieldByName('IDENTIF').AsString:=AktRogd.DokumentIDENTIF.AsString;
        Input.Post;
        }
      end;
      //����
      if Male then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='ON';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktRogd.DokumentON_IDENTIF.AsString);
        Input.Post;
      end;
      //����
      if Female then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='ONA';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktRogd.DokumentONA_IDENTIF.AsString);
        Input.Post;
      end;
      //3. ��������� ������ � �������
      RequestResult:=RegInt.Get(akBirth, TypeMessage, Input, Output, Error);
      if IsDebug then begin
         RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_get.txt');
      end;
      if RequestResult=rrOk then begin
        Result:=true;
        AktRogd.Dokument.Edit;
        AktRogd.DokumentON_STATUS.AsString  := '';
        AktRogd.DokumentONA_STATUS.AsString := '';
        AktRogd.DokumentTypeMessage.AsString:='';
        AktRogd.MessageID:=RegInt.RequestMessageId;  // �������� ID �������
        if OutPut.Locate('PREFIX','CHILD',[]) then begin
          PoleGrnSub:=PoleGrnSub or bChildId;
          AktRogd.DokumentIDENTIF.AsString := OutPut.FieldByName('NEW_IDENTIF').AsString;
{!!!}     AktRogd.DokumentSTATUS.AsString := '1'; //������� ??? ������
        end;
        //------- ������� -------------------------------------------------
        if Male then begin
          if OutPut.Locate('PREFIX','ON',[]) then begin
            if (OutPut.FieldByName('K_POL').AsString<>'') and (Decode_Pol(OutPut.FieldByName('K_POL').AsString)='�') then begin
              ShowMessageErr('� �������� �������������� ���� ������ ������������� ������� !');
              Result:=false;
            end else begin
              PoleGrnSub:=PoleGrnSub or bMale;
              //------ ����� �������� ������� ������� ------------------------
              if (AktRogd.DokumentFamilia.AsString='') and (AktRogd.DokumentPol.AsString='�') then begin
                AktRogd.DokumentFamilia.AsString := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
              end;
              if ANSIUpperCase(AktRogd.DokumentFamilia.AsString)=ANSIUpperCase(OutPut.FieldByName('FAMILIA').AsString) then begin
                AktRogd.DokumentFamilia_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
              end;
              //------ ����� �������� �������� ������� ------------------------
              if AktRogd.DokumentOtch.AsString='' then begin
                if dmBase.SprNamesM.Locate('NAME', OutPut.FieldByName('NAME').AsString, []) then begin
                  if AktRogd.DokumentPol.AsString='�' then begin
                    AktRogd.DokumentOtch.AsString   := CaseFIO(dmBase.SprNamesM.FieldByName('SUBNAME_M').AsString);
                    AktRogd.DokumentOtch_B.AsString := CaseFIO(dmBase.SprNamesM.FieldByName('SUBNAME_M_B').AsString);
                  end else begin
                    AktRogd.DokumentOtch.AsString  := CaseFIO(dmBase.SprNamesM.FieldByName('SUBNAME_G').AsString);
                    AktRogd.DokumentOtch_B.AsString:= CaseFIO(dmBase.SprNamesM.FieldByName('SUBNAME_G_B').AsString);
                  end;
                end;
              end;
              //---- ������������ ������ ���� -----------------
              AktRogd.DokumentON_IDENTIF.AsString   := OutPut.FieldByName('IDENTIF').AsString;
              AktRogd.DokumentON_Familia.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
              AktRogd.DokumentON_Familia_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
              AktRogd.DokumentON_NAME.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
              AktRogd.DokumentON_Name_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
              AktRogd.DokumentON_OTCH.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
              AktRogd.DokumentON_Otch_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);
              Decode_Date(OutPut.FieldByName('DATER').AsString, AktRogd.DokumentON_DATER, AktRogd.DokumentON_ONLYGOD);
              if LoadGrag then
                AktRogd.DokumentON_GRAG.AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
              AktRogd.DokumentON_STATUS.AsString := OutPut.FieldByName('K_STATUS').AsString;
              //���������� ������ (�������� �������������� ��������)
              AktRogd.DokumentON_DOK_TYPE.AsString:=Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString);
              AktRogd.DokumentON_DOK_ORGAN.AsString:=OutPut.FieldByName('K_DOC_ORGAN').AsString;
              AktRogd.DokumentON_DOKUMENT.AsString:=OutPut.FieldByName('N_DOC_ORGAN').AsString;
              AktRogd.DokumentON_DOK_SERIA.AsString:=OutPut.FieldByName('DOC_SERIA').AsString;
              AktRogd.DokumentON_DOK_NOMER.AsString:=OutPut.FieldByName('DOC_NOMER').AsString;
              AktRogd.DokumentON_DOK_DATE.AsDateTime:=OutPut.FieldByName('DOC_DATE').AsDateTime;


              //����� ����������
              if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!

                DecodeObl_MestoGit( AktRogd.Dokument,'ON_OBL','ON_B_OBL','',OutPut);
                AktRogd.DokumentON_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');
                DecodePunkt_MestoGit(AktRogd.Dokument, 'ON_B_GOROD', 'ON_GOROD', '', OutPut);
  // ����              AktRogd.DokumentON_GOROD_R.AsString:=GetGorodR(OutPut);
  //--------- ����� --------
                ag:=GetGorodREx(OutPut);
                AktRogd.DokumentON_GOROD_R.AsString:=ag.Ulica;
                AktRogd.DokumentON_DOM.AsString:=ag.Dom;
                AktRogd.DokumentON_KORP.AsString:=ag.Korp;
                AktRogd.DokumentON_KV.AsString:=ag.Kv;
  //------------------------
                {$IFDEF GISUN2}
                  AktRogd.DokumentON_RNGOROD.AsString:=Decode_RnGorod(OutPut, ['K_RN_GOROD','N_RN_GOROD'], strSoato);
                {$ENDIF}
              end;
{
T_SOVET            ftString        5   ResponsePerson.data.addresses.soviet.type_              ;�������� ����� (��� ��������������)
K_SOVET            ftString       10   ResponsePerson.data.addresses.soviet.code               ;�������� ����� (������� ��������)
N_SOVET            ftString      255   ResponsePerson.data.addresses.soviet.lexema.text        ;�������� �����
T_RN_GOROD         ftString        5   ResponsePerson.data.addresses.city_region.type_         ;����� ������ (��� ��������������)
K_RN_GOROD         ftString       10   ResponsePerson.data.addresses.city_region.code          ;����� ������ (������� ��������)
N_RN_GOROD         ftString      255   ResponsePerson.data.addresses.city_region.lexema.text   ;����� ������
}

              //����� ��������
              AktRogd.DokumentON_M_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString);

//              AktRogd.DokumentON_M_B_OBL.AsString:='';
//              AktRogd.DokumentON_M_OBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,'');
              DecodeObl_MestoRogd( AktRogd.Dokument,'ON_M_OBL','ON_M_B_OBL','',OutPut);

              AktRogd.DokumentON_M_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,'');

              DecodePunkt_MestoRogd(AktRogd.Dokument, 'ON_M_B_GOROD', 'ON_M_GOROD', '', OutPut);

              if getSoato(OutPut, nAteID, strSoato, strName) then begin
                AktRogd.CheckSoatoAkt(true,false,true, '{SS}', nAteID, strSoato);
              end else begin
                AktRogd.CheckSoatoAkt(true,false,true, '{SS}', 0, ''); // ��� ������ ���� ��������� ��������
              end;

            end;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ �� ���� ! ');
            Result:=false;
          end;
        end;
        //----------- ������� ------------------------------------------------------
        if Result and Female then begin
          if OutPut.Locate('PREFIX','ONA',[]) then begin
            if (OutPut.FieldByName('K_POL').AsString<>'') and (OutPut.FieldByName('K_POL').AsString='M') then begin
              ShowMessageErr('� �������� �������������� ������ ������ ������������� ������� !');
              Result:=false;
            end else begin
              PoleGrnSub:=PoleGrnSub or bFemale;
              //������������ ������
              AktRogd.DokumentONA_IDENTIF.AsString   := OutPut.FieldByName('IDENTIF').AsString;
              AktRogd.DokumentONA_Familia.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
              AktRogd.DokumentONA_Familia_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
              AktRogd.DokumentONA_NAME.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
              AktRogd.DokumentONA_Name_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
              AktRogd.DokumentONA_OTCH.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
              AktRogd.DokumentONA_Otch_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);
              Decode_Date(OutPut.FieldByName('DATER').AsString, AktRogd.DokumentONA_DATER, AktRogd.DokumentONA_ONLYGOD);
              if LoadGrag then
                AktRogd.DokumentONA_GRAG.AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
              AktRogd.DokumentONA_STATUS.AsString := OutPut.FieldByName('K_STATUS').AsString;
              //���������� ������ (��������, �������������� ��������)
              AktRogd.DokumentONA_DOK_TYPE.AsString:=Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString);
              AktRogd.DokumentONA_DOK_ORGAN.AsString:=OutPut.FieldByName('K_DOC_ORGAN').AsString;
              AktRogd.DokumentONA_DOKUMENT.AsString:=OutPut.FieldByName('N_DOC_ORGAN').AsString;
              AktRogd.DokumentONA_DOK_SERIA.AsString:=OutPut.FieldByName('DOC_SERIA').AsString;
              AktRogd.DokumentONA_DOK_NOMER.AsString:=OutPut.FieldByName('DOC_NOMER').AsString;
              AktRogd.DokumentONA_DOK_DATE.AsDateTime:=OutPut.FieldByName('DOC_DATE').AsDateTime;

              //����� ����������
              if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
                AktRogd.DokumentONA_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');
                AktRogd.DokumentONA_B_OBL.AsString:='';
  //              if OutPut.FieldByName('N_OBL').AsString<>'' then AktRogd.DokumentONA_B_OBL.AsString:='1';
  //              AktRogd.DokumentONA_OBL.AsString:=Decode_Obl(OutPut.FieldByName('N_OBL').AsString,'');
                DecodeObl_MestoGit( AktRogd.Dokument,'ONA_OBL','ONA_B_OBL','',OutPut);

                AktRogd.DokumentONA_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');

                DecodePunkt_MestoGit(AktRogd.Dokument, 'ONA_B_GOROD', 'ONA_GOROD', '', OutPut);
                {
                AktRogd.DokumentONA_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD').AsString);
                AktRogd.DokumentONA_GOROD.AsString:=OutPut.FieldByName('N_GOROD').AsString;
                }
  //  ����              AktRogd.DokumentONA_GOROD_R.AsString:=GetGorodR(OutPut);
  //--------- ����� --------
                ag:=GetGorodREx(OutPut);
                AktRogd.DokumentONA_GOROD_R.AsString:=ag.Ulica;
                AktRogd.DokumentONA_DOM.AsString:=ag.Dom;
                AktRogd.DokumentONA_KORP.AsString:=ag.Korp;
                AktRogd.DokumentONA_KV.AsString:=ag.Kv;
  //------------------------
                {$IFDEF GISUN2}
                  AktRogd.DokumentONA_RNGOROD.AsString:=Decode_RnGorod(OutPut, ['K_RN_GOROD','N_RN_GOROD'], strSoato);
                {$ENDIF}
              end;
              //����� ��������
              AktRogd.DokumentONA_M_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString);

              DecodeObl_MestoRogd( AktRogd.Dokument,'ONA_M_OBL','ONA_M_B_OBL','',OutPut);

              AktRogd.DokumentONA_M_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,'');

              DecodePunkt_MestoRogd(AktRogd.Dokument, 'ONA_M_B_GOROD', 'ONA_M_GOROD', '', OutPut);

              if getSoato(OutPut, nAteID, strSoato, strName) then begin
                AktRogd.CheckSoatoAkt(false,true,false, '{SS}', nAteID, strSoato);
              end else begin
                AktRogd.CheckSoatoAkt(false,true,false, '{SS}', 0, ''); // ��� ������ ���� ��������� ��������
              end;

              {
              AktRogd.DokumentONA_M_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString);
              AktRogd.DokumentONA_M_GOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString;
              }
            end;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ � ������ ! ');
            Result:=false;
          end;
        end;


        if not Result then begin
          {!!!}//��� ������ ���� �������� ������������� ������, �� ������ ��������� �����-�� ������
          //--AktRogd.DokumentIDENTIF.AsString := '';
          SetPoleGrn(AktRogd.DokumentPOLE_GRN, 0, 0);
        end else begin
          SetPoleGrn(AktRogd.DokumentPOLE_GRN, 2, PoleGrnSub);
          AktRogd.DokumentTypeMessage.AsString:=TypeMessage;
        end;
        AktRogd.Dokument.Post;
      end else begin
        HandleError(RequestResult, akBirth, opGet, Input, Output, Error, RegInt.FaultError);
      end;
      ClearDataSets;
    end;
  end;
end;
{$ENDIF}

//------------------------------------------------------------------------
function TGisun.RegisterChild( Akt : TfmSimpleD; lNotSvid:Boolean) : Boolean;
var
  strError : String;
begin
  Result:=false;
  if not SetTypeMessageAktBirth( Akt, strError) then begin
    ShowMessageErr(strError);
  end else begin
    Result:=RegisterAkt(Akt,lNotSvid);
  end;
end;

//------------------------------------------------------------------------
// ����� �������� ��� ���� ������� �������
function TGisun.CheckAllAkt(Simple: TfmSimpleD; var strError:String; lNotSvid:Boolean): Boolean;
var
  dMinDate,dDate,dCurDate:TDateTime;
  s,sNomer:String;
begin
  Result:=true;
  dCurDate:=dmBase.GetCurDate;
  dMinDate:=STOD('2013-07-26', tdAds);   // ����������� ���� �������������
  RegInt.TextLog:='';
  if (Simple.Dokument.FieldByName('NOMER').AsString='') then begin
    strError:=strError+'��������� ����� ������� ������'+#13#10;
  end;
  if (Simple.Dokument.FieldByName('DATEZ').AsString='') then begin
    strError:=strError+'��������� ���� ������� ������'+#13#10;
  end else begin
    if Gisun.CheckCurDate then begin
      if Simple.Dokument.FieldByName('DATEZ').AsDateTime>dCurDate then begin
        strError:=strError+'���� ������� ������ ������ ������� ����'+#13#10;
      end;
    end;
  end;
  //---- 01.06.2016  !!! �������� ������������� ������ ������������ � ������ �������� ���������� !!!  -------
  if Simple.DokumentPOVTOR.AsBoolean and not Simple.FOnlySvid then begin
    s:='';
    if Simple.SvidPovtor.Active and (Simple.SvidPovtor.RecordCount>0) then begin
      Simple.SvidPovtor.Last;
      s:=Trim(Simple.SvidPovtorSVID_NOMER.AsString);
    end;
    if s='' then strError:=strError+'��������� ������������� ��� ������'+#13#10;
  end;
  //----------------------------------------------------------------------------------------------------------
  dDate:=0;
  sNomer:='';
  if Gisun.CheckCurDate then begin
    // �������� ���� ������
    if (Simple.TypeObj=_TypeObj_ZSmert) or (Simple.TypeObj=_TypeObj_AktZAH) then begin
      if not Simple.Dokument.FieldByName('DATES').IsNull then begin
        if Simple.Dokument.FieldByName('DATES').AsDateTime>dCurDate then begin
          strError:=strError+'���� ������ ������ ������� ����'+#13#10;
        end;
      end;
    end;
    if Simple.DokumentPOVTOR.AsBoolean and not Simple.FOnlySvid then begin
      if Simple.SvidPovtor.Active and (Simple.SvidPovtor.RecordCount>0) then begin
        Simple.SvidPovtor.Last;
        if not Simple.SvidPovtorSVID_DATE.IsNull then begin
          dDate:=Simple.SvidPovtorSVID_DATE.AsDateTime;
        end;
        sNOMER:=Trim(Simple.SvidPovtorSVID_NOMER.AsString);
      end;
      if not lNotSvid and (dDate>0) and (sNomer<>'') then begin
        if dDate>dCurDate then begin
          strError:=strError+'���� ������������� ������ ������� ����'+#13#10;
        end else if dDate<dMinDate then begin
          if not Simple.IsSpecReg  // ����� ��������� ������ ������
            then strError:=strError+'���� ������������� ������ '+DatePropis(dMinDate,3)+#13#10;
        end;
        // ��� ����������� ����� ���������� ��������� ���� �������� ��������� ����-��
        if (Simple.TypeObj=_TypeObj_ZRast) and (Simple.SvidPovtorWHO_SVID.AsString='') then begin
          strError:=strError+'���� �������� ��������� �������������'+#13#10;
        end;
      end;
    end else begin
      if (Simple.TypeObj=_TypeObj_ZRast) and not Simple.FOnlySvid then begin
        if (Simple.Dokument.FieldByName('ON_SVID_DATE').AsString<>'') and (Simple.Dokument.FieldByName('ON_SVID_NOMER').AsString<>'') then begin
          dDate:=Simple.Dokument.FieldByName('ON_SVID_DATE').AsDateTime;
          if dDate>dCurDate then begin
            strError:=strError+'���� ������������� ������� ������ ������� ����'+#13#10;
          end else if dDate<dMinDate then begin
            if not Simple.IsSpecReg  // ����� ��������� ������ ������
              then strError:=strError+'���� ������������� ������� ������ '+DatePropis(dMinDate,3)+#13#10;
          end;
        end;
        if (Simple.Dokument.FieldByName('ONA_SVID_DATE').AsString<>'') and (Simple.Dokument.FieldByName('ONA_SVID_NOMER').AsString<>'') then begin
          dDate:=Simple.Dokument.FieldByName('ONA_SVID_DATE').AsDateTime;
          if dDate>dCurDate then begin
            strError:=strError+'���� ������������� ������� ������ ������� ����'+#13#10;
          end else if dDate<dMinDate then begin
            if not Simple.IsSpecReg  // ����� ��������� ������ ������
              then strError:=strError+'���� ������������� ������� ������ '+DatePropis(dMinDate,3)+#13#10;
          end;
        end;
      end else begin
        if not lNotSvid and (Simple.Dokument.FieldByName('DATESV').AsString<>'') and (Simple.Dokument.FieldByName('SVID_NOMER').AsString<>'') then begin
          dDate:=Simple.Dokument.FieldByName('DATESV').AsDateTime;
          if dDate>dCurDate then begin
            strError:=strError+'���� ������������� ������ ������� ����'+#13#10;
          end else if dDate<dMinDate then begin
            if not Simple.IsSpecReg  // ����� ��������� ������ ������
              then strError:=strError+'���� ������������� ������ '+DatePropis(dMinDate,3)+#13#10;
          end;
        end;
      end;
    end;
  end;
  if strError='' then begin
    strError:=Simple.CheckFIO;
  end;
  if strError<>'' then begin
    Result:=false;
  end else begin
    if FEnableTextLog then
      RegInt.TextLog:='�'+Simple.Dokument.FieldByName('NOMER').AsString+' '+DatePropis(Simple.Dokument.FieldByName('DATEZ').AsDateTime,3);
  end;
end;

//------------------------------------------------------------------------
// ����������� ������� ������ � ��������
function TGisun.RegisterAkt(Simple: TfmSimpleD; lNotSvid:Boolean): Boolean;
{$IFNDEF ADD_ZAGS}
begin
  Result:=false;
end;
{$ELSE}
var
  AktRogd : TfmZapisRogd;
  strError:String;
begin
  Result:=false;
  AktRogd:=TfmZapisRogd(Simple);
  AktRogd.Dokument.CheckBrowseMode;
  strError:='';
  if (Length(Trim(AktRogd.DokumentIDENTIF.AsString))<14) then begin
    strError:=strError+'��������� ����������������� ����� �������'+#13#10;
  end;
  if (AktRogd.DokumentFamilia_B.AsString='') then begin
    strError:=strError+'��������� ������� ������� �� ����������� �����'+#13#10;
  end;
  if (AktRogd.DokumentFAMILIA.AsString='') then begin
    strError:=strError+'��������� ������� ������� �� ������� �����'+#13#10;
  end;
  if (AktRogd.DokumentName_B.AsString='') then begin
    strError:=strError+'��������� ��� ������� �� ����������� �����'+#13#10;
  end;
  if (AktRogd.DokumentNAME.AsString='') then begin
    strError:=strError+'��������� ��� ������� �� ������� �����'+#13#10;
  end;

  if AktRogd.DokumentOtch.AsString<>'' then begin // ���� �������� �� ������� �� �����
    if (AktRogd.DokumentOtch_B.AsString='') then begin
      strError:=strError+'��������� �������� ������� �� ����������� �����'+#13#10;
    end;
  end;
//    if (AktRogd.DokumentOtch.AsString='') then begin
//      strError:=strError+'��������� �������� ������� �� ������� �����'+#13#10;
//    end;

  CheckAllAkt(AktRogd,strError,lNotSvid);
  if strError<>'' then begin
    ShowMessageErr(strError);
    Result:=false;
  end else begin
    Result:=true;
  end;

  if Result then begin
//    Result:=false;
    ClearDataSets;
    //[2] �������� ������
    //1. ������ ������� ��� �������� ������ � �������
    Input:=FRegInt.CreateInputTable(akBirth, opPost);
    //2. ��������� ������������ ������
    Input.Append;
    //������������ ������ ������
    Input.FieldByName('IDENTIF').AsString:=AktRogd.DokumentIDENTIF.AsString; //������������ �����
    Input.FieldByName('FAMILIA').AsString:=G_UpperCase(AktRogd.DokumentFamilia.AsString); //������� �� ������� �����
    Input.FieldByName('FAMILIA_B').AsString:=G_UpperCase(AktRogd.DokumentFamilia_B.AsString); //������� �� ����������� �����
    Input.FieldByName('NAME').AsString:=G_UpperCase(AktRogd.DokumentName.AsString); //��� �� ������� �����
    Input.FieldByName('NAME_B').AsString:=G_UpperCase(AktRogd.DokumentNAME_B.AsString); //��� �� ����������� �����
    Input.FieldByName('OTCH').AsString:=G_UpperCase(AktRogd.DokumentOtch.AsString);
    Input.FieldByName('OTCH_B').AsString:=G_UpperCase(AktRogd.DokumentOtch_B.AsString);
    Input.FieldByName('POL').AsString:=Code_Pol(AktRogd.DokumentPOL.AsString);
    Input.FieldByName('DATER').AsString:=DTOS(AktRogd.DokumentDateR.AsDateTime,tdClipper); //���� ��������
  {!!!}Input.FieldByName('GOSUD').AsString:=Code_Alfa3(AktRogd.DokumentGOSUD.AsString); //������ ��������
//Input.FieldByName('GOSUD').AsString:=Code_Alfa3Ex(AktRogd.DokumentGOSUD.AsString, Input.FindField('GOSUD_LEX'), Input.FindField('GOSUD_LEX_B')); //������ ��������
  {!!!}Input.FieldByName('GRAJD').AsString:='0';   // ���� 'BLR' �� 02.11.2012    �����������

// �������� 09.01.2017 �� ������� ����� ���������, �.�. ������ ���� �������� ������ ���� � ������
//    if AktRogd.DokumentDATES.IsNull and not AktRogd.DokumentFIRSTWEEK.AsBoolean then begin
//      Input.FieldByName('STATUS').AsString:=ST_ACTIVE;  //������
//    end else begin
//      Input.FieldByName('STATUS').AsString:=ST_DEATH;
//    end;
    Input.FieldByName('STATUS').AsString:=ST_ACTIVE;  //������

    //����� ��������
    CodeObl_MestoRogd( AktRogd.Dokument,'OBL','','OBL_B',Input,'OBL','OBL_B');
//    Input.FieldByName('OBL').AsString:=AktRogd.DokumentOBL.AsString;
//    Input.FieldByName('OBL_B').AsString:=AktRogd.DokumentOBL_B.AsString;

    Input.FieldByName('RAION').AsString:=AktRogd.DokumentRAION.AsString;
    Input.FieldByName('RAION_B').AsString:=AktRogd.DokumentRAION_B.AsString;

    CodePunkt_MestoRogd(AktRogd.Dokument, 'B_GOROD','GOROD','GOROD_B',INput,'TIP_GOROD','GOROD','GOROD_B');

    {$IFDEF GISUN2}
      if IsActiveWorkATE then begin
        if AktRogd.DokumentSOATO_ID.AsInteger>0 then begin
          Input.FieldByName('K_ATE_R').AsString:=AktRogd.DokumentSOATO_ID.AsString;
        end else begin
          Input.FieldByName('K_ATE_R').AsString:='';
        end;
      end else begin
        Input.FieldByName('K_ATE_R').AsString:='';
      end;
    {$ENDIF}

  //  Input.FieldByName('TIP_GOROD').AsString:=Code_TypePunkt(AktRogd.DokumentB_GOROD.AsString);  //��� ���������� ������
  //  Input.FieldByName('GOROD').AsString:=AktRogd.DokumentGOROD.AsString; //��������� ����� �� ������� �����
  //  Input.FieldByName('GOROD_B').AsString:=AktRogd.DokumentGOROD_B.AsString; //��������� ����� �� ����������� �����

  //  if Female then begin    16.11.2011  �������� ������ ������ ???
      //������������ ������ ������
      Input.FieldByName('ONA_IDENTIF').AsString:=AktRogd.DokumentONA_IDENTIF.AsString; //������������ �����
      Input.FieldByName('ONA_FAMILIA').AsString:=AktRogd.Dokument.FieldByName('ONA_FAMILIA').AsString; //������� �� ������� �����
      Input.FieldByName('ONA_FAMILIA_B').AsString:=AktRogd.Dokument.FieldByName('ONA_FAMILIA_B').AsString; //������� �� ����������� �����
      Input.FieldByName('ONA_NAME').AsString:=AktRogd.Dokument.FieldByName('ONA_NAME').AsString; //��� �� ������� �����
      Input.FieldByName('ONA_NAME_B').AsString:=AktRogd.Dokument.FieldByName('ONA_NAME_B').AsString; //��� �� ����������� �����
      Input.FieldByName('ONA_OTCH').AsString:=AktRogd.Dokument.FieldByName('ONA_OTCH').AsString; //�������� �� ������� �����
      Input.FieldByName('ONA_OTCH_B').AsString:=AktRogd.Dokument.FieldByName('ONA_OTCH_B').AsString; //�������� �� ����������� �����
      Input.FieldByName('ONA_POL').AsString:='F'; //���
      Input.FieldByName('ONA_DATER').AsString:=Code_Date(AktRogd.DokumentONA_DATER.AsDateTime, AktRogd.DokumentONA_ONLYGOD);
      Input.FieldByName('ONA_GRAJD').AsString:=Code_Alfa3(AktRogd.DokumentONA_GRAG.AsString); //�����������
      Input.FieldByName('ONA_STATUS').AsString:=Code_Status(AktRogd.Dokument, 'ONA_GRAG', 'ONA_STATUS');

      if (Input.FieldByName('ONA_STATUS').AsString<>ST_INOST) and  // �� ����������
         ((AktRogd.DokumentTYPEREG.AsString='3') or (AktRogd.DokumentTYPEREG.AsString='2')) and    // �������� ������� ��� ��������
         (Input.FieldByName('ONA_IDENTIF').AsString='') then begin // ���� ��� ��
        Input.FieldByName('ONA_STATUS').AsString:=ST_FIKT;    // ���������
      end;

      // ��� ���� ����� �� ���������� ������� ���� �������� ������ ��� ���������
      if (Input.FieldByName('ONA_STATUS').AsString=ST_FIKT) and  AktRogd.DokumentONA_DATER.IsNull then begin
        Input.FieldByName('ONA_DATER').AsString:=GetEmptyDate;  // '00000000'
      end else begin
        Input.FieldByName('ONA_DATER').AsString:=Code_Date(AktRogd.DokumentONA_DATER.AsDateTime, AktRogd.DokumentONA_ONLYGOD);
      end;

  //    Input.FieldByName('ONA_STATUS').AsString:=AktRogd.Dokument.FieldByName('ONA_STATUS').AsString; //������
      //����� ��������
      Input.FieldByName('ONA_GOSUD').AsString:=Code_Alfa3(AktRogd.DokumentONA_M_GOSUD.AsString); //������ ��������
//      Input.FieldByName('ONA_GOSUD').AsString:=Code_Alfa3Ex(AktRogd.DokumentONA_M_GOSUD.AsString, Input.FindField('ONA_GOSUD_LEX'), nil); //������ ��������
      Input.FieldByName('ONA_OBL').AsString:=AktRogd.DokumentONA_M_OBL.AsString; //������� ��������
      Input.FieldByName('ONA_RAION').AsString:=AktRogd.DokumentONA_M_RAION.AsString; //����� ��������

      CodePunkt_MestoRogd(AktRogd.Dokument, 'ONA_M_B_GOROD','ONA_M_GOROD','',Input,'ONA_TIP_GOROD','ONA_GOROD','');
  //    Input.FieldByName('ONA_TIP_GOROD').AsString:=Code_TypePunkt(AktRogd.DokumentONA_M_B_GOROD.AsString); //��� ���������� ������
  //    Input.FieldByName('ONA_GOROD').AsString:=AktRogd.DokumentONA_M_GOROD.AsString; //��������� ����� �� ������� �����
  //  end;
  //  if Male then begin    16.11.2011  �������� ������ ������ ???
      //������������ ������ ����
      Input.FieldByName('ON_IDENTIF').AsString:=AktRogd.Dokument.FieldByName('ON_IDENTIF').AsString; //������������ �����
      Input.FieldByName('ON_FAMILIA').AsString:=G_UpperCase(AktRogd.Dokument.FieldByName('ON_FAMILIA').AsString); //������� �� ������� �����
      Input.FieldByName('ON_FAMILIA_B').AsString:=G_UpperCase(AktRogd.Dokument.FieldByName('ON_FAMILIA_B').AsString); //������� �� ����������� �����
      Input.FieldByName('ON_NAME').AsString:=G_UpperCase(AktRogd.Dokument.FieldByName('ON_NAME').AsString); //��� �� ������� �����
      Input.FieldByName('ON_NAME_B').AsString:=G_UpperCase(AktRogd.Dokument.FieldByName('ON_NAME_B').AsString); //��� �� ����������� �����
      Input.FieldByName('ON_OTCH').AsString:=G_UpperCase(AktRogd.Dokument.FieldByName('ON_OTCH').AsString); //�������� �� ������� �����
      Input.FieldByName('ON_OTCH_B').AsString:=G_UpperCase(AktRogd.Dokument.FieldByName('ON_OTCH_B').AsString); //�������� �� ����������� �����
      Input.FieldByName('ON_POL').AsString:='M'; //���
      Input.FieldByName('ON_GRAJD').AsString:=Code_Alfa3(AktRogd.DokumentON_GRAG.AsString); //�����������

      Input.FieldByName('ON_STATUS').AsString:=Code_Status(AktRogd.Dokument, 'ON_GRAG', 'ON_STATUS');

      if (Input.FieldByName('ON_STATUS').AsString<>ST_INOST) and  // �� ����������
         ((AktRogd.DokumentSVED.AsString='3') or AktRogd.FOnlySvid) and            // �� ��������� ������ ��� ���������� ������ �������������
         (Input.FieldByName('ON_IDENTIF').AsString='') then begin // ���� ��� ��
        Input.FieldByName('ON_STATUS').AsString:=ST_FIKT;    // ���������
      end;
      if (Input.FieldByName('ON_STATUS').AsString<>ST_INOST) and  // �� ����������
         ((AktRogd.DokumentTYPEREG.AsString='3') or (AktRogd.DokumentTYPEREG.AsString='2')) and    // �������� ������� ��� ��������
         (Input.FieldByName('ON_IDENTIF').AsString='') then begin // ���� ��� ��
        Input.FieldByName('ON_STATUS').AsString:=ST_FIKT;    // ���������
      end;

      // ��� ���� ����� �� ���������� ������� ���� �������� ���� ��� ����������
      if (Input.FieldByName('ON_STATUS').AsString=ST_FIKT) and  AktRogd.DokumentON_DATER.IsNull then begin
        if AktRogd.DokumentONA_DATER.IsNull
           then Input.FieldByName('ON_DATER').AsString:=GetEmptyDate
           else Input.FieldByName('ON_DATER').AsString:=Code_Date(AktRogd.DokumentONA_DATER.AsDateTime, AktRogd.DokumentONA_ONLYGOD);
      end else begin
        Input.FieldByName('ON_DATER').AsString:=Code_Date(AktRogd.DokumentON_DATER.AsDateTime, AktRogd.DokumentON_ONLYGOD);
      end;

      //����� ��������
//      Input.FieldByName('ON_GOSUD').AsString:=Code_Alfa3Ex(AktRogd.DokumentON_M_GOSUD.AsString, Input.FindField('ON_GOSUD_LEX'), nil); //������ ��������
      Input.FieldByName('ON_GOSUD').AsString:=Code_Alfa3(AktRogd.DokumentON_M_GOSUD.AsString); //������ ��������
      Input.FieldByName('ON_OBL').AsString:=AktRogd.DokumentON_M_OBL.AsString; //������� ��������
      Input.FieldByName('ON_RAION').AsString:=AktRogd.DokumentON_M_RAION.AsString; //����� ��������
      CodePunkt_MestoRogd(AktRogd.Dokument, 'ON_M_B_GOROD','ON_M_GOROD','',Input,'ON_TIP_GOROD','ON_GOROD','');

      // ���� ��������� ����
      if (Input.FieldByName('ON_STATUS').AsString=ST_FIKT) then begin
        Input.FieldByName('ON_GOSUD').AsString:='BLR'; //������ ��������
        Input.FieldByName('ON_GRAJD').AsString:='BLR'; //�����������
      end;

  //    Input.FieldByName('ON_TIP_GOROD').AsString:=Code_TypePunkt(AktRogd.DokumentON_M_B_GOROD.AsString); //��� ���������� ������
  //    Input.FieldByName('ON_GOROD').AsString:=AktRogd.DokumentON_M_GOROD.AsString; //��������� ����� �� ������� �����
  //  end;
    //���������� �� ������� ������
    Input.FieldByName('ACT_TIP').AsString:=TypeAkt; //��� ������� ������
    SetOrganAkt(AktRogd, Input);
    Input.FieldByName('ACT_DATE').AsDateTime:=AktRogd.Dokument.FieldByName('DATEZ').AsDateTime; //���� ������� ������
    Input.FieldByName('ACT_NOMER').AsString:=AktRogd.Dokument.FieldByName('NOMER').AsString; //����� ������� ������

    //���������� � �������� ���������  !!! ������ ���� ���� �������������
    SetDokSvid(AktRogd, Input, '', lNotSvid);
    RegInt.TextLog:='�/� � �������� '+RegInt.TextLog;

    Input.Post;
    //3. ��������� ������ � �������
    RequestResult:=RegInt.Post(AktRogd.MessageID, akBirth, AktRogd.DokumentTypeMessage.AsString, Input, Error);
    LogToTableLog(AktRogd, '����������� �/� � ��������');

    if IsDebug then begin
       RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_post.txt');
    end;
    if RequestResult=rrOk then begin
      AktRogd.Dokument.CheckBrowseMode;
      AktRogd.Dokument.Edit;
      SetPoleGrn(AktRogd.DokumentPOLE_GRN, 3);
      AktRogd.Dokument.Post;
      if not HandleErrorToString
        then ShowMessageCont(GetMessageOk,CurAkt);
      Result:=True;
    end else begin
      Result:=false;
      //4.2. ������������ ������ �������������� � ���������
      HandleError(RequestResult, akBirth, opGet, Input, Output, Error, FRegInt.FaultError);
    end;
  end;
end;
{$ENDIF}

type
   TxControl=class(TWinControl);


//------------------------------------------------------------------------
procedure TGisun.CheckTabStop(Control : TWinControl; lCheck:Boolean);
begin
  if lCheck then begin
    if TxControl(Control).Color=GetDisableColorGIS
      then TxControl(Control).TabStop:=false
      else TxControl(Control).TabStop:=true
  end;
end;

//------------------------------------------------------------------------
procedure TGisun.CheckAkt(Simple: TfmSimpleD);
{$IFNDEF ADD_ZAGS}
begin
end;
{$ELSE}
const
  {$IFDEF GISUN2}
    CComponentName: array [1..59] of record     // 79
  {$ELSE}
    CComponentName: array [1..57] of record     // 77
  {$ENDIF}
      Name: string;
      Code: Integer;
      Color: TColor;
      nnn: Integer;
    end=(
     //1. ������
     (Name:'ENG_edIDENTIF'; Code: bChildId; Color: clDefault; nnn:0),
     (Name:'edPol'; Code: bChildId; Color: clDefault; nnn:0),
     (Name:'edDateR'; Code: bChildId; Color: clDefault; nnn:0),
     //2. ����
     //������������ ������
     (Name:'ENG_edON_IDENTIF'; Code: bMale; Color: clDefault; nnn:0),
     (Name:'edON_Familia'; Code: bMale; Color: clDefault; nnn:0),
     (Name:'edON_NAME'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_OTCH'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'BLR_edON_Familia'; Code: bMale; Color: clDefault; nnn:0),
     (Name:'BLR_edON_NAME'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'BLR_edON_OTCH'; Code: bMale; Color: clDefault; nnn : 0),

     (Name:'edON_Familia_Sv'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_NAME_Sv'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_OTCH_Sv'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'BLR_edON_FamiliaB_Sv'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'BLR_edON_NAMEB_Sv'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'BLR_edON_OTCHB_Sv'; Code: bMale; Color: clDefault; nnn : 0),

     (Name:'edON_DATER'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'cbOnlyGodON'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_VOZR'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_GRAG'; Code: bMale; Color: clDefault; nnn : 0),   //16.11.2011 ???

     //--'edON_STATUS',
     //���������� ������ (�������� �������������� ��������)
     (Name:'edON_DOK_TYPE'; Code: bMale; Color: clDefault; nnn : 0),
     //--'edON_DOK_ORGAN',
     (Name:'edON_DOKUMENT'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_DOK_SERIA'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_DOK_NOMER'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_DOK_DATE'; Code: bMale; Color: clDefault; nnn : 0),
     //����� ����������
     {  -11
     (Name:'edON_B_RESP'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_GOSUD'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_B_OBL'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_OBL'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_RAION'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_B_GOROD'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_GOROD'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_GOROD_R'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_DOM'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_KORP'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_KV'; Code: bMale; Color: clDefault; nnn : 0),
     }
     //����� ��������
     (Name:'edON_M_GOSUD'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_M_B_OBL'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_M_OBL'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_M_RAION'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_M_B_GOROD'; Code: bMale; Color: clDefault; nnn : 0),
     (Name:'edON_M_GOROD'; Code: bMale; Color: clDefault; nnn : 0),
     //3. ����
     //������������ ������
     (Name:'ENG_edONA_IDENTIF'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_Familia'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_NAME'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_OTCH'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'BLR_edONA_Familia'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'BLR_edONA_NAME'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'BLR_edONA_OTCH'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_Familia_Sv'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_NAME_Sv'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_OTCH_Sv'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'BLR_edONA_FamiliaB_Sv'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'BLR_edONA_NAMEB_Sv'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'BLR_edONA_OTCHB_Sv'; Code: bFemale; Color: clDefault; nnn : 0),

     (Name:'edONA_DATER'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'cbOnlyGodONA'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_VOZR'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_GRAG'; Code: bFemale; Color: clDefault; nnn : 0),      // 16.11.2011 ???
     //--'edONA_STATUS',
     //���������� ������ (��������, �������������� ��������)
     (Name:'edONA_DOK_TYPE'; Code: bFemale; Color: clDefault; nnn : 0),
     //--'edONA_DOK_ORGAN',
     (Name:'edONA_DOKUMENT'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_DOK_SERIA'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_DOK_NOMER'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_DOK_DATE'; Code: bFemale; Color: clDefault; nnn : 0),
     //����� ����������
     {  -13
     (Name:'edONA_B_RESP'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_GOSUD'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_B_OBL'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_OBL'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_RAION'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_B_GOROD'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_GOROD'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_GOROD_R'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_DOM'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_KORP'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_KV'; Code: bFemale; Color: clDefault; nnn : 0),
     }
     {$IFDEF GISUN2}
//     (Name:'edONA_RNGOROD'; Code: bFemale; Color: clDefault; nnn : 0),
//     (Name:'edON_RNGOROD'; Code: bMale; Color: clDefault; nnn : 0),
     {$ENDIF}

     //����� ��������
     (Name:'edONA_M_GOSUD'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_M_B_OBL'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_M_OBL'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_M_RAION'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_M_B_GOROD'; Code: bFemale; Color: clDefault; nnn : 0),
     (Name:'edONA_M_GOROD'; Code: bFemale; Color: clDefault; nnn : 0)
   );
var
   Akt: TfmZapisRogd;
   PoleGrn: Integer;
   PoleGrnSub: Integer;
   I,mmm: Integer;
   Component: TComponent;
   Control: TControl;
   lDisable,l: Boolean;
begin                               
   Akt:=TfmZapisRogd(Simple);
   l:=(IsEnabled and IsEnableTypeAkt(dmBase.TypeObj_ZRogd,false));
   if l then begin
     PoleGrn:=GetPoleGrn(Akt.DokumentPOLE_GRN.AsInteger);
     PoleGrnSub:=GetPoleGrnSub(Akt.DokumentPOLE_GRN.AsInteger);
   end else begin
     PoleGrn:=0;
     PoleGrnSub:=0;
   end;
   //--------- ������ ���� ��������� ��� ������ ������ �� ������� ������� -----------
//   for i:=0 to Akt.edON_Familia.EditButtons.Count-1 do begin
//     Akt.edON_Familia.EditButtons[i].Visible:=not l;
//   end;
   //--------------------------------------------------------------------------------

   //1. ������������ ����������� ������ [� ������ ������� �� ����� ��������]
   //TBItemStep1 - "1. �������� ������������� �������"
   //TBItemStep2 - "2. ���������������� �������"
   {
   if not IsDebug then begin
      case PoleGrn of
         //�� ���� ������ � ��� ��
         0: begin
            Akt.TBItemStep1.Enabled:=True;
            Akt.TBItemStep2.Enabled:=True;
         end;
         1:;
         //������� ����� �� ��� ��
         2: begin
            Akt.TBItemStep1.Enabled:=False;
            Akt.TBItemStep2.Enabled:=True;
         end;
         //���������� ������ �� ������� ������ � ��� ��
         3: begin
            Akt.TBItemStep1.Enabled:=False;
            Akt.TBItemStep2.Enabled:=False;
         end;
      end;
   end;
   }
   //2. ������������ ����������� ��������� ��������������
   //����� ��������� ������ �� ��� �� �������� �������������� ������ ����� ����������
   if Simple.FCheckFieldGRN then begin
     if l and ((PoleGrn=2) or (PoleGrn=3)) then begin
       akt.edON_Familia.HelpContext:=0;
       akt.edON_NATION.HelpContext:=888;
     end else begin
       akt.edON_Familia.HelpContext:=888;
       akt.edON_NATION.HelpContext:=0;
     end;
   end;
   Akt.ENG_edIDENTIF.ReadOnly:=false;
   Akt.ENG_edIDENTIF.Color:=clWindow;

   if Akt.DokumentCHERN.AsInteger=1 then begin
     mmm:=Low(CComponentName);
   end else begin
     mmm:=Low(CComponentName)+3;
   end;
   for I:=mmm to High(CComponentName) do begin
      Component:=Akt.FindComponent(CComponentName[I].Name);
      if (Component<>nil) and (Component is TControl) then begin
         Control:=TControl(Component);
         //2.1.
         if l
           then lDisable:=((PoleGrn=2) or (PoleGrn=3)) and ((PoleGrnSub and CComponentName[I].Code)=CComponentName[I].Code)
           else lDisable:=l;

         if lDisable and (PoleGrn=3) then begin
           lDisable:=false;
         end;

         //2.2.
         if lDisable then begin
            SetEnableControl(FTypeEnableControl,Control,false);
            //Control.Enabled:=False;
//            if TxControl(Control).Color<>clInfoBk then begin
            if TxControl(Control).Color<>GetDisableColorGIS then begin
               CComponentName[I].Color:=TxControl(Control).Color;
            end;
            TxControl(Control).Color:=GetDisableColorGIS; //clInfoBk;
         end
         else begin
            if CComponentName[I].Color<>clDefault then begin
              TxControl(Control).Color:=CComponentName[I].Color;
            end;

            SetEnableControl(FTypeEnableControl,Control,true);
            //Control.Enabled:=True;
         end;
         CheckTabStop(TWinControl(Control), simple.FCheckFieldGRN);
      end
      else begin
         ShowMessageC(CComponentName[I].Name);
      end;
   end;
   if (PoleGrn=3) and (Akt.DokumentIDENTIF.AsString<>'') then begin
     if not Akt.ENG_edIDENTIF.ReadOnly then begin
       Akt.ENG_edIDENTIF.ReadOnly:=true;
       Akt.ENG_edIDENTIF.Color:=GetDisableColor;
     end;
   end;
end;
{$ENDIF}

//--------------------------------------------------------------------------------------
function TGisun.GetPersonalData(strIDENTIF : String; strPol : String) : Boolean;
var
  s : String;
begin
  Result:=false;
  Output:=nil;
  Error:=nil;
  //1. ������ ������� ��� �������� ������ � �������
  Input:=FRegInt.CreateInputTable(akGetPersonalData, opGet);
  //2. ��������� ������������ ������
  Input.Append;
  //������������ �����
  Input.FieldByName('IDENTIF').AsString:=CheckRus2(strIDENTIF);
  Input.Post;
//--   meInput.Lines.Clear;
//--   DataSetToLog(Input, meInput.Lines);
  try
    //3. ��������� ������ � �������
    RequestResult:=FRegInt.Get(akGetPersonalData, '', Input, Output, Error);
//--      meTestLog.Lines.AddStrings(FRegInt.Log);
//--      Result:=RequestResult=rrOk;
    //4. ������������ ��������� �������
    if RequestResult=rrOk then begin
      if (OutPut.FieldByName('POL').AsString='F') or (OutPut.FieldByName('POL').AsString='�')
        then s:='�'
        else s:='�';
      if strPol<>s then begin
        if strPol='�' then ShowMessageErr('�� ��������� ������ � �������! ');
        if strPol='�' then ShowMessageErr('�� ��������� ������ � �������! ');
      end else begin
        Result := true;
      end;
      //4.1. ��� �������� ���������� ������� ��������� ����� ��������
      //     � ����������� ������� - Output
//--         DataSetToLog(Output, meOutput.Lines);
    end else begin
      //4.2. ������������ ������ �������������� � ���������
      HandleError(RequestResult, akBirth, opGet, Input, Output, Error, FRegInt.FaultError);
      FreeAndNil(Output);
    end;
  finally
    FreeAndNil(Input);
  end;
end;

procedure TGisun.SetMessageSource(const Value: String);
begin
  FMessageSource := Value;
  if FRegInt<>nil then begin
    FRegInt.MessageSource := Value;
  end;
end;

procedure TGisun.SetRegInt(const Value: TRegInt);
begin
  FRegInt := Value;
end;

procedure TGisun.SetTypeMessage(const Value: String);
begin
  FTypeMessage := Value;
end;

procedure TGisun.SetTypeAkt(const Value: String);
begin
  FTypeAkt := Value;
end;

//�������� ����:
//0301 - ������������� �����, ������������������� �� � ������ ����;
//0302 - ������������� ������ � �����, ������������������ �� � ������ ����;
//0310 - ��������� �/� � �����;
//0320 - ������������� �/�  � �����;
//2300 - ������ ���������� ������������� � �����;
//3300 - ������ ������������� �/� � �����;
function TGisun.SetTypeMessageAktMarriage(Akt: TfmSimpleD; var strError: String): Boolean;
{$IFNDEF ADD_ZAGS}
begin
  Result:=false;
end;
{$ELSE}
var
  AktBrak : TfmZapisBrak;
  lNotRB_ON,lNotRB_ONA : Boolean;
begin
  AktBrak := TfmZapisBrak(Akt);
  AktBrak.Dokument.CheckBrowseMode;
  Result:=false;

  if not CheckMessageSource(Akt, strError) then begin
    exit;
  end;

  strError:='';
  TypeAkt := '0300';
  {
  // ���� ����� ��������� ������� ��, � ��� �� ��������� ��
  if (AktBrak.DokumentON_DOK_TYPE.AsInteger=1) and (AktBrak.DokumentON_GRAG.AsString<>MY_GRAG_STR) then begin
    strError:='�� ��������� �� ����� ����� ������� ��';
    exit;
  end;
  // ���� ������� ���������� ������� ��, � ���� �� ��������� ��
  if (AktBrak.DokumentONA_DOK_TYPE.AsInteger=1) and (AktBrak.DokumentONA_GRAG.AsString<>MY_GRAG_STR) then begin
    strError:='�� ��������� �� ����� ����� ������� ��';
    exit;
  end;
  // ���� ����� ��������� �� ������� ��, � ��� ��������� ��
  if (AktBrak.DokumentON_DOK_TYPE.AsInteger<>1) and (AktBrak.DokumentON_GRAG.AsString=MY_GRAG_STR) then begin
    strError:='��������� �� ������ ����� ������� ��';
    exit;
  end;
  // ���� ������� ��������� �� ������� ��, � ��� ��������� ��
  if (AktBrak.DokumentONA_DOK_TYPE.AsInteger<>1) and (AktBrak.DokumentONA_GRAG.AsString=MY_GRAG_STR) then begin
    strError:='��������� �� ������ ����� ������� ��';
    exit;
  end;
  }
  Female:=false;  // ����� ������ � �������
  Male:=false;    // ����� ������ � ������
  RunExchange:=true;  // ��������� ������������� ��� ���
  DefaultPoleGrn:=0;  // �������� ��� ���� POLE_GRN ���� �� ���� ������������ ��������������
  TypeMessage:='*';
  {
  lNotRB_ON:=false;
  lNotRB_ONA:=false;

  // ����� ��������� �������� �� ������� ��(1) � �� ��� �� ����������(2,3)
  if (AktBrak.DokumentON_DOK_TYPE.AsInteger>3) or (AktBrak.DokumentON_DOK_TYPE.AsInteger=0) then begin
    Male:=false;
    lNotRB_ON:=true;
  end;
  // ������� ���������� �������� �� ������� ��(1) � �� ��� �� ����������(2,3)
  if (AktBrak.DokumentONA_DOK_TYPE.AsInteger>3) or (AktBrak.DokumentONA_DOK_TYPE.AsInteger=0) then begin
    Female:=false;
    lNotRB_ONA:=true;
  end;
  }

//  if TypeMessage='*' then begin
//    if lNotRB_ON or lNotRB_ONA then // ����������� �����, � ������� ���� �� �������� - ����������� ��������� ��� ���� �� ���������� � ��;
//      TypeMessage:='0305';
//  end;

  if TypeMessage='*'
    then TypeMessage:='0300';

  if (AktBrak.DokumentON_IDENTIF.AsString<>'') then begin
    Male:=true;
  end;
  if (AktBrak.DokumentONA_IDENTIF.AsString<>'') then begin
    FeMale:=true;
  end;
  {
  if Male and (AktBrak.DokumentON_IDENTIF.AsString='') then begin
    strError:='��������� ������������� ������';
  end;
  if FeMale and (AktBrak.DokumentONA_IDENTIF.AsString='') then begin
    strError:='��������� ������������� �������';
  end;
  }
  if strError=''
    then Result:=true
    else Result:=false;
end;
{$ENDIF}

//--------------------------------------------------------------------
procedure TGisun.AktBrakAddObrab(data: TPersonalData_; dsOutPut:TDataSet; dsDokument:TDataSet; slPar:TStringList);
{$IFNDEF ADD_ZAGS}
begin
end;
{$ELSE}
var
  setResh:TListReshSud;
  dsResh:TDataSet;
//  n:Integer;
  s,ss,sAdd,sText,sFIO:String;
  fld,fld2:TField;
  sem:Integer;
  ms:TMartialStatus;
  AktBrak : TfmZapisBrak;
begin
  dsResh:=TDataSet(ObjectFromParams(slPar,'RESH_SUD'));
  setResh:=FRegInt.GetCoursList(data, dsOutPut, dsResh, '', slPar);
  if LoadSemStatus then begin
//    AktBrak:=TfmZapisBrak(ObjectFromParams(slPar,'FORM'));;
    fld:=dsDokument.FindField('OTMETKA');
    s:=dsOutPut.FieldByName('PREFIX').AsString;
    fld2:=dsDokument.FindField(s+'_SEM');  // ON ONA
    if (fld<>nil) and (fld2<>nil) then begin
      ms:=FRegInt.GetMartialStatus(data, '');
      sem:=FRegInt.MartialStatus2Sem(ms.Status);
      if ms.Status>0 then begin
        // 10-������� � �����  11-������(�����) ����������: 21-�/�  22-�� ������� ���� 23-������� ��������
        if (ms.Status=23) or (ms.Status=10)
          then sAdd:=ms.NameStatus+', '+ms.Doc+': ';
        EditDataSet(dsDokument);
        if s='ON' then begin
          fld.AsString:=sAdd+ms.Text;
        end else begin
          if fld.AsString='' then ss:='' else ss:=#13#10;
          fld.AsString:=fld.AsString+ss+'#'+sAdd+ms.Text;
        end;
        if sem>0
          then fld2.AsInteger:=sem;
      end;
    end;
  end;
end;
{$ENDIF}
//--------------------------------------------------------------------------------------
//  ������ ������ ��� ������� ������ � �����
function TGisun.GetMarriage(Akt: TfmSimpleD): Boolean;
{$IFNDEF ADD_ZAGS}
begin
  Result:=false;
end;
{$ELSE}
var
  AktBrak : TfmZapisBrak;
  strError,strSOATO,strName : String;
  nAteID,PoleGrnSub : Integer;
  ag:TGorodR;
  slPar:TStringList;
begin
  Result:=false;
  AktBrak := TfmZapisBrak(Akt);
  AktBrak.Dokument.CheckBrowseMode;
  if not SetTypeMessageAktMarriage( AktBrak, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end else begin
    ClearDataSets;
    if RunExchange then begin
      PoleGrnSub:=0;
      //[1] ������ ������
      //1. ������ ������� ��� �������� ������ � �������
      Input:=FRegInt.CreateInputTable(akMarriage, opGet);
      //2. ��������� ������������ ������
      //�����
      if Male then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='ON';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktBrak.DokumentON_IDENTIF.AsString);
        Input.Post;
      end;
      //�������
      if Female then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='ONA';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktBrak.DokumentONA_IDENTIF.AsString);
        Input.Post;
      end;
//      AktBrak.WriteToDebug([FormatDateTime('hh:mm:ss',Now)+'  ������ ������']);

//   TObrPersonalData = procedure(data: wsGisun.PersonalData; dsOutPut:TDataSet; dsDokument:TDataSet; slPar:TStringList) of object;
      RegInt.FObrPersonalData:=AktBrakAddObrab;  // �������������� ��������� ��� ������� ������ ��� ������� ����
      AktBrak.tbReshSud.EmptyTable;
      slPar:=TStringList.Create;
      slPar.AddObject('RESH_SUD', AktBrak.tbReshSud);
      slPar.AddObject('FORM', AktBrak);

      //3. ��������� ������ � �������
      try
        RequestResult:=RegInt.Get(akMarriage, TypeMessage, Input, Output, Error, AktBrak.Dokument, slPar);
      finally
        RegInt.FObrPersonalData:=nil;
        slPar.Free;
      end;
//      raise exception.Create('222222222222222');
//      AktBrak.WriteToDebug([FormatDateTime('hh:mm:ss',Now)+'  ������ ������ ��������']);

      if IsDebug then begin
         RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_get.txt');
      end;
      if RequestResult=rrOk then begin
        Result:=true;
        AktBrak.Dokument.Edit;    
        AktBrak.DokumentON_STATUS.AsString  := '';
        AktBrak.DokumentONA_STATUS.AsString := '';
        AktBrak.DokumentTypeMessage.AsString:='';
        AktBrak.MessageID:=RegInt.RequestMessageId;  // �������� ID �������
        if Male then begin
          if OutPut.Locate('PREFIX','ON',[]) then begin
            if (OutPut.FieldByName('K_POL').AsString<>'') and (Decode_Pol(OutPut.FieldByName('K_POL').AsString)='�') then begin
              ShowMessageErr('� �������� �������������� ������ ������ ������������� ������� !');
              Result:=false;
            end else begin
              PoleGrnSub:=PoleGrnSub or bMale;
              //������������ ������
              AktBrak.DokumentON_IDENTIF.AsString   := OutPut.FieldByName('IDENTIF').AsString;
              AktBrak.DokumentON_Familia.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
              AktBrak.DokumentON_Familia_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
              AktBrak.DokumentON_NAME.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
              AktBrak.DokumentON_Name_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
              AktBrak.DokumentON_OTCH.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
              AktBrak.DokumentON_Otch_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);
              Decode_Date(OutPut.FieldByName('DATER').AsString, AktBrak.DokumentON_DATER,AktBrak.DokumentON_ONLYGOD);
              if LoadGrag then
                AktBrak.DokumentON_GRAG.AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
              AktBrak.DokumentON_STATUS.AsString := OutPut.FieldByName('K_STATUS').AsString;
              //���������� ������ (��������, �������������� ��������)
              AktBrak.DokumentON_DOK_TYPE.AsString:=Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString);
              AktBrak.DokumentON_DOK_ORGAN.AsString:=OutPut.FieldByName('K_DOC_ORGAN').AsString;
              AktBrak.DokumentON_DOKUMENT.AsString:=OutPut.FieldByName('N_DOC_ORGAN').AsString;
              AktBrak.DokumentON_DOK_SERIA.AsString:=OutPut.FieldByName('DOC_SERIA').AsString;
              AktBrak.DokumentON_DOK_NOMER.AsString:=OutPut.FieldByName('DOC_NOMER').AsString;
              AktBrak.DokumentON_DOK_DATE.AsDateTime:=OutPut.FieldByName('DOC_DATE').AsDateTime;

              try
                if not OutPut.FieldByName('REG_DATE').IsNull
                  then AktBrak.DokumentON_GODPR.AsInteger:=YearOf(OutPut.FieldByName('REG_DATE').AsDateTime);
                WriteDateField(AktBrak.DokumentON_REG_DATE, OutPut.FieldByName('REG_DATE'));
                WriteDateField(AktBrak.DokumentON_REG_DATE_TILL, OutPut.FieldByName('REG_DATE_TILL'));

//                AktBrak.DokumentON_REG_DATE_TILL.AsDateTime:=STOD('20180101',tdClipper);  // test
              except
              end;
              // ����� ��������
              AktBrak.DokumentON_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString); //������ ��������

//              AktBrak.DokumentON_B_OBL.AsString:='';
//              AktBrak.DokumentON_OBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,OutPut.FieldByName('OBL_B_R').AsString); //������� ��������
//              AktBrak.DokumentON_OBL_B.AsString:=OutPut.FieldByName('OBL_B_R').AsString; //������� �������� �� ����������� �����
              DecodeObl_MestoRogd( AktBrak.Dokument,'ON_OBL','ON_B_OBL','ON_OBL_B',OutPut);

              AktBrak.DokumentON_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,OutPut.FieldByName('RAION_B_R').AsString); //����� ��������
              AktBrak.DokumentON_RAION_B.AsString:=CaseAdres(OutPut.FieldByName('RAION_B_R').AsString); //����� �������� �� ����������� �����

              DecodePunkt_MestoRogd(AktBrak.Dokument, 'ON_B_GOROD', 'ON_GOROD', 'ON_GOROD_B', OutPut);
//              AktBrak.DokumentON_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString); //��� ���������� ������ ��������
//              AktBrak.DokumentON_GOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString; //��������� ����� �� ������� �����
//              AktBrak.DokumentON_GOROD_B.AsString:=OutPut.FieldByName('GOROD_B_R').AsString; //��������� ����� �� ����������� �����

              // ����� ����������
              if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
                AktBrak.DokumentON_M_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');

                DecodeObl_MestoGit( AktBrak.Dokument,'ON_M_OBL','ON_M_B_OBL','',OutPut);
  //              AktBrak.DokumentON_M_B_OBL.AsString:='';
  //              AktBrak.DokumentON_M_OBL.AsString:=Decode_Obl(OutPut.FieldByName('N_OBL').AsString,'');

                AktBrak.DokumentON_M_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');

                DecodePunkt_MestoGit(AktBrak.Dokument, 'ON_M_B_GOROD', 'ON_M_GOROD', '', OutPut);
  //              AktBrak.DokumentON_M_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD').AsString);
  //              AktBrak.DokumentON_M_GOROD.AsString:=OutPut.FieldByName('N_GOROD').AsString;

  // ����              AktBrak.DokumentON_M_GOROD_R.AsString:=GetGorodR(OutPut);
  //--------- ����� --------
                ag:=GetGorodREx(OutPut);
                AktBrak.DokumentON_M_GOROD_R.AsString:=ag.Ulica;
                AktBrak.DokumentON_M_DOM.AsString:=ag.Dom;
                AktBrak.DokumentON_M_KORP.AsString:=ag.Korp;
                AktBrak.DokumentON_M_KV.AsString:=ag.Kv;
  //------------------------
                {$IFDEF GISUN2}
                  AktBrak.DokumentON_M_RNGOROD.AsString:=Decode_RnGorod(OutPut, ['K_RN_GOROD','N_RN_GOROD'], strSoato);
                {$ENDIF}
                if getSoato(OutPut, nAteID, strSoato, strName) then begin
                  AktBrak.CheckSoatoAkt(true,false,true, '{SS}', nAteID, strSoato);
                end else begin
                  AktBrak.CheckSoatoAkt(true,false,true, '{SS}', 0, ''); // ��� ������ ���� ��������� ��������
                end;

              end;
            end;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ � ������ ! ');
            Result:=false;
          end;
        end;
        if Result and Female then begin
          if OutPut.Locate('PREFIX','ONA',[]) then begin
            if (OutPut.FieldByName('K_POL').AsString<>'') and (OutPut.FieldByName('K_POL').AsString='M') then begin
              ShowMessageErr('� �������� �������������� ������� ������ ������������� ������� !');
              Result:=false;
            end else begin
              PoleGrnSub:=PoleGrnSub or bFemale;
              //������������ ������
              AktBrak.DokumentONA_IDENTIF.AsString   := OutPut.FieldByName('IDENTIF').AsString;
              AktBrak.DokumentONA_Familia.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
              AktBrak.DokumentONA_Familia_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
              AktBrak.DokumentONA_NAME.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
              AktBrak.DokumentONA_Name_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
              AktBrak.DokumentONA_OTCH.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
              AktBrak.DokumentONA_Otch_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);
              Decode_Date(OutPut.FieldByName('DATER').AsString, AktBrak.DokumentONA_DATER,AktBrak.DokumentONA_ONLYGOD);
              if LoadGrag then
                AktBrak.DokumentONA_GRAG.AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
              AktBrak.DokumentONA_STATUS.AsString := OutPut.FieldByName('K_STATUS').AsString;
              //���������� ������ (��������, �������������� ��������)
              AktBrak.DokumentONA_DOK_TYPE.AsString:=Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString);
              AktBrak.DokumentONA_DOK_ORGAN.AsString:=OutPut.FieldByName('K_DOC_ORGAN').AsString;
              AktBrak.DokumentONA_DOKUMENT.AsString:=OutPut.FieldByName('N_DOC_ORGAN').AsString;
              AktBrak.DokumentONA_DOK_SERIA.AsString:=OutPut.FieldByName('DOC_SERIA').AsString;
              AktBrak.DokumentONA_DOK_NOMER.AsString:=OutPut.FieldByName('DOC_NOMER').AsString;
              AktBrak.DokumentONA_DOK_DATE.AsDateTime:=OutPut.FieldByName('DOC_DATE').AsDateTime;

              try
                if not OutPut.FieldByName('REG_DATE').IsNull
                  then AktBrak.DokumentONA_GODPR.AsInteger:=YearOf(OutPut.FieldByName('REG_DATE').AsDateTime);
                WriteDateField(AktBrak.DokumentONA_REG_DATE, OutPut.FieldByName('REG_DATE'));
                WriteDateField(AktBrak.DokumentONA_REG_DATE_TILL, OutPut.FieldByName('REG_DATE_TILL'));
//                AktBrak.DokumentONA_REG_DATE_TILL.AsDateTime:=STOD('20171011',tdClipper);  // test
              except
              end;

              // ����� ��������
              AktBrak.DokumentONA_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString); //������ ��������

//              AktBrak.DokumentONA_B_OBL.AsString:='';
//              AktBrak.DokumentONA_OBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,OutPut.FieldByName('OBL_B_R').AsString); //������� ��������
//              AktBrak.DokumentONA_OBL_B.AsString:=OutPut.FieldByName('OBL_B_R').AsString; //������� �������� �� ����������� �����
              DecodeObl_MestoRogd( AktBrak.Dokument,'ONA_OBL','ONA_B_OBL','ONA_OBL_B',OutPut);

              AktBrak.DokumentONA_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,OutPut.FieldByName('RAION_B_R').AsString); //����� ��������
              AktBrak.DokumentONA_RAION_B.AsString:=CaseAdres(OutPut.FieldByName('RAION_B_R').AsString); //����� �������� �� ����������� �����

//              AktBrak.DokumentONA_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString); //��� ���������� ������ ��������
//              AktBrak.DokumentONA_GOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString; //��������� ����� �� ������� �����
//              AktBrak.DokumentONA_GOROD_B.AsString:=OutPut.FieldByName('GOROD_B_R').AsString; //��������� ����� �� ����������� �����
              DecodePunkt_MestoRogd(AktBrak.Dokument, 'ONA_B_GOROD', 'ONA_GOROD', 'ONA_GOROD_B', OutPut);

              //----------- ����� ���������� ----------------
              if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
                AktBrak.DokumentONA_M_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');
  //              AktBrak.DokumentONA_M_B_OBL.AsString:='';
  //              AktBrak.DokumentONA_M_OBL.AsString:=Decode_Obl(OutPut.FieldByName('N_OBL').AsString,'');
                DecodeObl_MestoGit( AktBrak.Dokument,'ONA_M_OBL','ONA_M_B_OBL','',OutPut);

                AktBrak.DokumentONA_M_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');
  //              AktBrak.DokumentONA_M_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD').AsString);
  //              AktBrak.DokumentONA_M_GOROD.AsString:=OutPut.FieldByName('N_GOROD').AsString;
                DecodePunkt_MestoGit(AktBrak.Dokument, 'ONA_M_B_GOROD', 'ONA_M_GOROD', '', OutPut);

  // ����              AktBrak.DokumentONA_M_GOROD_R.AsString:=GetGorodR(OutPut);
  //--------- ����� --------
                ag:=GetGorodREx(OutPut);
                AktBrak.DokumentONA_M_GOROD_R.AsString:=ag.Ulica;
                AktBrak.DokumentONA_M_DOM.AsString:=ag.Dom;
                AktBrak.DokumentONA_M_KORP.AsString:=ag.Korp;
                AktBrak.DokumentONA_M_KV.AsString:=ag.Kv;
  //------------------------
                {$IFDEF GISUN2}
                  AktBrak.DokumentONA_M_RNGOROD.AsString:=Decode_RnGorod(OutPut, ['K_RN_GOROD','N_RN_GOROD'], strSoato);
                {$ENDIF}
                if getSoato(OutPut, nAteID, strSoato, strName) then begin
                  AktBrak.CheckSoatoAkt(false,true,true, '{SS}', nAteID, strSoato);
                end else begin
                  AktBrak.CheckSoatoAkt(false,true,true, '{SS}', 0, ''); // ��� ������ ���� ��������� ��������
                end;

              end;
            end;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ � ������� ! ');
            Result:=false;
          end;
        end;


        if not Result then begin
          SetPoleGrn(AktBrak.DokumentPOLE_GRN, 0, 0);
        end else begin
          SetPoleGrn(AktBrak.DokumentPOLE_GRN, 2, PoleGrnSub);
          AktBrak.DokumentTypeMessage.AsString:=TypeMessage;
        end;
        AktBrak.Dokument.Post;
      end else begin
        HandleError(RequestResult, akMarriage, opGet, Input, Output, Error, RegInt.FaultError);
      end;
      ClearDataSets;
//      AktBrak.WriteToDebug([FormatDateTime('hh:mm:ss',Now)+'  ������ � �������� ���������']);
    end;
  end;
end;
{$ENDIF}

//--------------------------------------------------------------------------------------
// ����������� ������� ������ � �����
function TGisun.RegisterMarriage(Akt: TfmSimpleD): Boolean;
{$IFNDEF ADD_ZAGS}
begin
  Result:=false;
end;
{$ELSE}
var
  AktBrak : TfmZapisBrak;
  strError : String;
begin
  Result:=true;
  AktBrak := TfmZapisBrak(Akt);
  AktBrak.Dokument.CheckBrowseMode;
  strError:='';
  if not SetTypeMessageAktMarriage( AktBrak, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end;
  if Result then begin
    if AktBrak.DokumentBRAK_RAST.AsBoolean then begin
      strError:=strError+'������������ ���� � ��� �� �� ������������'+#13#10;
    end;
    //---- �������� ���. ������� ������ ��� ������� ��  -----  (���� ���)!!!
//    if (AktBrak.Dokument.FieldByName('ONA_GRAG').AsInteger=MY_GRAG) and
    if (AktBrak.Dokument.FieldByName('ONA_FAMILIAP_B').AsString='') then begin
      strError:=strError+'��������� ������� ������� �� ����������� ����� ����� �����'+#13#10;
    end;
//    if (AktBrak.Dokument.FieldByName('ON_GRAG').AsInteger=MY_GRAG) and
    if (AktBrak.Dokument.FieldByName('ON_FAMILIAP_B').AsString='') then begin
      strError:=strError+'��������� ������� ������ �� ����������� ����� ����� �����'+#13#10;
    end;
    //--------------------------------------------------------
    if (AktBrak.Dokument.FieldByName('ONA_FAMILIAP').AsString='') then begin
      strError:=strError+'��������� ������� ������� �� ������� ����� ����� �����'+#13#10;
    end;
    if (AktBrak.Dokument.FieldByName('ON_FAMILIAP').AsString='') then begin
      strError:=strError+'��������� ������� ������ �� ������� ����� ����� �����'+#13#10;
    end;
    CheckAllAkt(AktBrak,strError);
    if strError<>'' then begin
      ShowMessageErr(strError);
      Result:=false;
    end;
  end;
  if Result then begin
    Result:=false;
    ClearDataSets;
    //[2] �������� ������
    //1. ������ ������� ��� �������� ������ � �������
    Input:=FRegInt.CreateInputTable(akMarriage, opPost);
    //2. ��������� ������������ ������
    Input.Append;
//    if Female then begin
      //------------------������������ ������ �������--------------------
      Input.FieldByName('ONA_IDENTIF').AsString:=AktBrak.DokumentONA_IDENTIF.AsString; //������������ �����
      Input.FieldByName('ONA_FAMILIA_OLD').AsString:=AktBrak.Dokument.FieldByName('ONA_FAMILIA').AsString; //������� �� �����
      Input.FieldByName('ONA_FAMILIA').AsString:=AnsiUpperCase(AktBrak.Dokument.FieldByName('ONA_FAMILIAP').AsString); //������� �� ������� �����
      Input.FieldByName('ONA_FAMILIA_B').AsString:=AktBrak.Dokument.FieldByName('ONA_FAMILIAP_B').AsString; //������� �� ����������� �����
      Input.FieldByName('ONA_NAME').AsString:=AktBrak.Dokument.FieldByName('ONA_NAME').AsString; //��� �� ������� �����
      Input.FieldByName('ONA_NAME_B').AsString:=AktBrak.Dokument.FieldByName('ONA_NAME_B').AsString; //��� �� ����������� �����
      Input.FieldByName('ONA_OTCH').AsString:=AktBrak.Dokument.FieldByName('ONA_OTCH').AsString; //�������� �� ������� �����
      Input.FieldByName('ONA_OTCH_B').AsString:=AktBrak.Dokument.FieldByName('ONA_OTCH_B').AsString; //�������� �� ����������� �����
      Input.FieldByName('ONA_POL').AsString:='F'; //���
      Input.FieldByName('ONA_DATER').AsString:=Code_Date(AktBrak.DokumentONA_DATER.AsDateTime, AktBrak.DokumentONA_ONLYGOD); //���� ��������
      Input.FieldByName('ONA_GRAJD').AsString:=Code_Alfa3(AktBrak.DokumentONA_GRAG.AsString); //�����������

//      Input.FieldByName('ONA_STATUS').AsString:=AktBrak.Dokument.FieldByName('ONA_STATUS').AsString; //������
      Input.FieldByName('ONA_STATUS').AsString:=Code_Status(AktBrak.Dokument, 'ONA_GRAG', 'ONA_STATUS');

      //����� ��������
      Input.FieldByName('ONA_GOSUD').AsString:=Code_Alfa3(AktBrak.DokumentONA_GOSUD.AsString); //������ ��������
      Input.FieldByName('ONA_OBL').AsString:=AktBrak.DokumentONA_OBL.AsString; //������� ��������
      Input.FieldByName('ONA_OBL_B').AsString:=AktBrak.DokumentONA_OBL_B.AsString; //������� �������� �� ����������� �����
      Input.FieldByName('ONA_RAION').AsString:=AktBrak.DokumentONA_RAION.AsString; //����� ��������
      Input.FieldByName('ONA_RAION_B').AsString:=AktBrak.DokumentONA_RAION_B.AsString; //����� �������� �� ����������� �����

      CodePunkt_MestoRogd(aktBrak.Dokument,'ONA_B_GOROD','ONA_GOROD','ONA_GOROD_B',Input,'ONA_TIP_GOROD','ONA_GOROD','ONA_GOROD_B');
//      Input.FieldByName('ONA_TIP_GOROD').AsString:=Code_TypePunkt(AktBrak.DokumentONA_B_GOROD.AsString); //��� ���������� ������ ��������
//      Input.FieldByName('ONA_GOROD').AsString:=AktBrak.DokumentONA_GOROD.AsString; //��������� ����� �� ������� �����
//      Input.FieldByName('ONA_GOROD_B').AsString:=AktBrak.DokumentONA_GOROD_B.AsString; //��������� ����� �� ����������� �����
//    end;
 //   if Male then begin

      //--------------������������ ������ ������--------------------------
      Input.FieldByName('ON_IDENTIF').AsString:=AktBrak.Dokument.FieldByName('ON_IDENTIF').AsString; //������������ �����
      Input.FieldByName('ON_FAMILIA_OLD').AsString:=AktBrak.Dokument.FieldByName('ON_FAMILIA').AsString; //������� �� �����
      Input.FieldByName('ON_FAMILIA').AsString:=AnsiUpperCase(AktBrak.Dokument.FieldByName('ON_FAMILIAP').AsString); //������� �� ������� �����
      Input.FieldByName('ON_FAMILIA_B').AsString:=AktBrak.Dokument.FieldByName('ON_FAMILIAP_B').AsString; //������� �� ����������� �����
      Input.FieldByName('ON_NAME').AsString:=AktBrak.Dokument.FieldByName('ON_NAME').AsString; //��� �� ������� �����
      Input.FieldByName('ON_NAME_B').AsString:=AktBrak.Dokument.FieldByName('ON_NAME_B').AsString; //��� �� ����������� �����
      Input.FieldByName('ON_OTCH').AsString:=AktBrak.Dokument.FieldByName('ON_OTCH').AsString; //�������� �� ������� �����
      Input.FieldByName('ON_OTCH_B').AsString:=AktBrak.Dokument.FieldByName('ON_OTCH_B').AsString; //�������� �� ����������� �����
      Input.FieldByName('ON_POL').AsString:='M'; //���
      Input.FieldByName('ON_GRAJD').AsString:=Code_Alfa3(AktBrak.DokumentON_GRAG.AsString); //�����������
      Input.FieldByName('ON_DATER').AsString:=Code_Date(AktBrak.DokumentON_DATER.AsDateTime, AktBrak.DokumentON_ONLYGOD); //���� ��������

      Input.FieldByName('ON_STATUS').AsString:=Code_Status(AktBrak.Dokument, 'ON_GRAG', 'ON_STATUS');
//      Input.FieldByName('ON_STATUS').AsString:=AktBrak.Dokument.FieldByName('ON_STATUS').AsString; //������
      //����� ��������
      Input.FieldByName('ON_GOSUD').AsString:=Code_Alfa3(AktBrak.DokumentON_GOSUD.AsString); //������ ��������
      Input.FieldByName('ON_OBL').AsString:=AktBrak.DokumentON_OBL.AsString; //������� ��������
      Input.FieldByName('ON_OBL_B').AsString:=AktBrak.DokumentON_OBL_B.AsString; //������� �������� �� ����������� �����
      Input.FieldByName('ON_RAION').AsString:=AktBrak.DokumentON_RAION.AsString; //����� ��������
      Input.FieldByName('ON_RAION_B').AsString:=AktBrak.DokumentON_RAION_B.AsString; //����� �������� �� ����������� �����

      CodePunkt_MestoRogd(aktBrak.Dokument,'ON_B_GOROD','ON_GOROD','ON_GOROD_B',Input,'ON_TIP_GOROD','ON_GOROD','ON_GOROD_B');
//      Input.FieldByName('ON_TIP_GOROD').AsString:=Code_TypePunkt(AktBrak.DokumentON_B_GOROD.AsString); //��� ���������� ������ ��������
//      Input.FieldByName('ON_GOROD').AsString:=AktBrak.DokumentON_GOROD.AsString; //��������� ����� �� ������� �����
//      Input.FieldByName('ON_GOROD_B').AsString:=AktBrak.DokumentON_GOROD_B.AsString; //��������� ����� �� ����������� �����
//    end;
    //���������� �� ������� ������
    Input.FieldByName('ACT_TIP').AsString:=TypeAkt; //��� ������� ������
    SetOrganAkt(AktBrak, Input);
    Input.FieldByName('ACT_DATE').AsDateTime:=AktBrak.Dokument.FieldByName('DATEZ').AsDateTime; //���� ������� ������
    Input.FieldByName('ACT_NOMER').AsString:=AktBrak.Dokument.FieldByName('NOMER').AsString; //����� ������� ������

    //------------ ���������� � �������� ��������� ---------------------------
    SetDokSvid(AktBrak, Input);

    //�������� � ���������� �����, �� ��������� 18 ���
    Input.Post;
    //3. ��������� ������ � �������
    RequestResult:=RegInt.Post(AktBrak.MessageID, akMarriage, AktBrak.DokumentTypeMessage.AsString, Input, Error);
    LogToTableLog(AktBrak, '����������� �/� � �����');
    if IsDebug then begin
       RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_post.txt');
    end;
    if RequestResult=rrOk then begin
      AktBrak.Dokument.CheckBrowseMode;
      AktBrak.Dokument.Edit;
      SetPoleGrn(AktBrak.DokumentPOLE_GRN, 3);
      AktBrak.Dokument.Post;
      if not HandleErrorToString
        then ShowMessageCont(GetMessageOk,CurAkt);
      Result:=true;
    end else begin
      Result:=false;
      //4.2. ������������ ������ �������������� � ���������
      HandleError(RequestResult, akMarriage, opGet, Input, Output, Error, FRegInt.FaultError);
    end;
  end;
end;
{$ENDIF}

//------------------------------------------------------------------------------
procedure TGisun.CheckMarriage(Simple: TfmSimpleD);
{$IFNDEF ADD_ZAGS}
begin
end;
{$ELSE}
const
  {$IFDEF GISUN2}
     CComponentName: array [1..86] of record   //
  {$ELSE}
     CComponentName: array [1..84] of record   //
  {$ENDIF}
      Name: string;
      Code: Integer;
      Color: TColor;
   end=(
     //1. ����
     //������������ ������
     (Name:'ENG_edON_IDENTIF'; Code: bMale; Color: clDefault),
     (Name:'edON_Familia'; Code: bMale; Color: clDefault),
     (Name:'edON_NAME'; Code: bMale; Color: clDefault),
     (Name:'edON_OTCH'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_Familia'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_NAME'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_OTCH'; Code: bMale; Color: clDefault),
     (Name:'edON_DATER'; Code: bMale; Color: clDefault),
     (Name:'cbOnlyGodON'; Code: bMale; Color: clDefault),
     (Name:'edON_VOZR'; Code: bMale; Color: clDefault),

     //�������������  �����
     (Name:'edON_Familia_Sv'; Code: bMale; Color: clDefault),
     (Name:'edON_NAME_Sv'; Code: bMale; Color: clDefault),
     (Name:'edON_OTCH_Sv'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_Familia_B_Sv'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_NAME_B_Sv'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_OTCH_B_Sv'; Code: bMale; Color: clDefault),
     (Name:'edON_DATER_Sv'; Code: bMale; Color: clDefault),
     (Name:'cbOnlyGodON_Sv'; Code: bMale; Color: clDefault),
     (Name:'edON_VOZR_Sv'; Code: bMale; Color: clDefault),
     //������������� ����� ��������
     (Name:'edON_GOSUD_Sv'; Code: bMale; Color: clDefault),
     (Name:'edON_B_OBL_Sv'; Code: bMale; Color: clDefault),
     (Name:'edON_OBL_R_Sv'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_OBL_R_B_Sv'; Code: bMale; Color: clDefault),
     (Name:'edON_RAION_R_Sv'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_RAION_R_B_Sv'; Code: bMale; Color: clDefault),
     (Name:'edON_B_GOROD_Sv'; Code: bMale; Color: clDefault),
     (Name:'edON_GOROD_Sv'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_GOROD_B_Sv'; Code: bMale; Color: clDefault),

     (Name:'edON_GRAG'; Code: bMale; Color: clDefault),   //???
     //--ON_STATUS
     //���������� ������ (��������, �������������� ��������)
     (Name:'edON_DOK_TYPE'; Code: bMale; Color: clDefault),
     //--ON_DOK_ORGAN
     (Name:'edON_DOKUMENT'; Code: bMale; Color: clDefault),
     (Name:'edON_DOK_SERIA'; Code: bMale; Color: clDefault),
     (Name:'edON_DOK_NOMER'; Code: bMale; Color: clDefault),
     (Name:'edON_DOK_DATE'; Code: bMale; Color: clDefault),
     //����� ��������
     (Name:'edON_GOSUD'; Code: bMale; Color: clDefault),
     (Name:'edON_B_OBL'; Code: bMale; Color: clDefault),
     (Name:'edON_OBL'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_OBL'; Code: bMale; Color: clDefault),
     (Name:'edON_RAION'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_RAION'; Code: bMale; Color: clDefault),
     (Name:'edON_B_GOROD'; Code: bMale; Color: clDefault),
     (Name:'edON_GOROD'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_GOROD'; Code: bMale; Color: clDefault),
     //--edON_GOROD_B
     //2. ����
     //������������ ������
     (Name:'ENG_edONA_IDENTIF'; Code: bFemale; Color: clDefault),
     (Name:'edONA_Familia'; Code: bFemale; Color: clDefault),
     (Name:'edONA_NAME'; Code: bFemale; Color: clDefault),
     (Name:'edONA_OTCH'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_Familia'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_NAME'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_OTCH'; Code: bFemale; Color: clDefault),
     (Name:'edONA_DATER'; Code: bFemale; Color: clDefault),
     (Name:'cbOnlyGodONA'; Code: bFemale; Color: clDefault),
     (Name:'edON_VOZR'; Code: bFemale; Color: clDefault),
     (Name:'edONA_GRAG'; Code: bFemale; Color: clDefault),   //???
     //--ONA_STATUS
     //���������� ������ (��������, �������������� ��������)
     (Name:'edONA_DOK_TYPE'; Code: bFemale; Color: clDefault),
     //--ONA_DOK_ORGAN
     (Name:'edONA_DOKUMENT'; Code: bFemale; Color: clDefault),
     (Name:'edONA_DOK_SERIA'; Code: bFemale; Color: clDefault),
     (Name:'edONA_DOK_NOMER'; Code: bFemale; Color: clDefault),
     (Name:'edONA_DOK_DATE'; Code: bFemale; Color: clDefault),
     //����� ��������
     (Name:'edONA_GOSUD'; Code: bFemale; Color: clDefault),
     (Name:'edONA_B_OBL'; Code: bFemale; Color: clDefault),
     (Name:'edONA_OBL'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_OBL'; Code: bFemale; Color: clDefault),
     (Name:'edONA_RAION'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_RAION'; Code: bFemale; Color: clDefault),
     (Name:'edONA_B_GOROD'; Code: bFemale; Color: clDefault),
     (Name:'edONA_GOROD'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_GOROD'; Code: bFemale; Color: clDefault),
     //������������� �������
     (Name:'edONA_Familia_Sv'; Code: bFemale; Color: clDefault),
     (Name:'edONA_NAME_Sv'; Code: bFemale; Color: clDefault),
     (Name:'edONA_OTCH_Sv'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_Familia_B_Sv'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_NAME_B_Sv'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_OTCH_B_Sv'; Code: bFemale; Color: clDefault),
     (Name:'edONA_DATER_Sv'; Code: bFemale; Color: clDefault),
     (Name:'cbOnlyGodONA_Sv'; Code: bFemale; Color: clDefault),
     (Name:'edONA_VOZR_Sv'; Code: bFemale; Color: clDefault),
     //������������� ����� �������� �������
     (Name:'edONA_GOSUD_Sv'; Code: bFemale; Color: clDefault),
     (Name:'edONA_B_OBL_Sv'; Code: bFemale; Color: clDefault),
     (Name:'edONA_OBL_R_Sv'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_OBL_R_B_Sv'; Code: bFemale; Color: clDefault),
     (Name:'edONA_RAION_R_Sv'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_RAION_R_B_Sv'; Code: bFemale; Color: clDefault),
     (Name:'edONA_B_GOROD_Sv'; Code: bFemale; Color: clDefault),
     (Name:'edONA_GOROD_Sv'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_GOROD_B_Sv'; Code: bFemale; Color: clDefault)

     //--ONA_GOROD_B
     //����� ����������
     {$IFDEF GISUN2}
//       (Name:'edON_M_RNGOROD'; Code: bMale; Color: clDefault),
//       (Name:'edONA_M_RNGOROD'; Code: bFemale; Color: clDefault),
     {$ENDIF}
   );
var
   Akt: TfmZapisBrak;
   PoleGrn: Integer;
   PoleGrnSub: Integer;
   I: Integer;
   Component: TComponent;
   Control: TControl;
   lDisable,l: Boolean;
begin
   Akt:=TfmZapisBrak(Simple);
   l:=(IsEnabled and IsEnableTypeAkt(dmBase.TypeObj_ZBrak,false));
   if l then begin
     PoleGrn:=GetPoleGrn(Akt.DokumentPOLE_GRN.AsInteger);
     PoleGrnSub:=GetPoleGrnSub(Akt.DokumentPOLE_GRN.AsInteger);
   end else begin
     PoleGrn:=0;
     PoleGrnSub:=0;
   end;
   //1. ������������ ����������� ������ [� ������ ������� �� ����� ��������]
   //TBItem1 - "��������� ������"
   //TBItem2 - "���������������� ������� ������"
   {
   if not IsDebug then begin
      case PoleGrn of
         //�� ���� ������ � ��� ��
         0: begin
            Akt.TBItem1.Enabled:=True;
            Akt.TBItem2.Enabled:=True;
         end;
         1:;
         //������� ����� �� ��� ��
         2: begin
            Akt.TBItem1.Enabled:=False;
            Akt.TBItem2.Enabled:=True;
         end;
         //���������� ������ �� ������� ������ � ��� ��
         3: begin
            Akt.TBItem1.Enabled:=False;
            Akt.TBItem2.Enabled:=False;
         end;
      end;
   end;
   }
   //2. ������������ ����������� ��������� ��������������
   //����� ��������� ������ �� ��� �� �������� �������������� ������ ����� ����������
   for I:=Low(CComponentName) to High(CComponentName) do begin
      Component:=Akt.FindComponent(CComponentName[I].Name);
      if (Component<>nil) and (Component is TControl) then begin
         Control:=TControl(Component);
         //2.1.
         if l
           then lDisable:=((PoleGrn=2) or (PoleGrn=3)) and ((PoleGrnSub and CComponentName[I].Code)=CComponentName[I].Code)
           else lDisable:=l;

         if lDisable and (PoleGrn=3) then begin
           lDisable:=false;
         end;

         //2.2.
         if lDisable then begin
            SetEnableControl(FTypeEnableControl,Control,false);
            //Control.Enabled:=False;
            if TxControl(Control).Color<>GetDisableColorGIS then begin
               CComponentName[I].Color:=TxControl(Control).Color;
            end;
            TxControl(Control).Color:=GetDisableColorGIS;
         end
         else begin
            if CComponentName[I].Color<>clDefault then begin
               TxControl(Control).Color:=CComponentName[I].Color;
            end;
            SetEnableControl(FTypeEnableControl,Control,true);
            //Control.Enabled:=True;
         end;
      end
      else begin
         ShowMessageC(CComponentName[I].Name);
      end;
   end;
   Akt.tsReshSud.TabVisible:=(Akt.tbReshSud.RecordCount>0);

   if Akt.DokumentON_SEM_DOK.AsString<>'' then begin
     Akt.edON_SEM.Hint:=Akt.DokumentON_SEM_DOK.AsString;
     Akt.edON_SEM.Color:=GetDisableColorGIS;
   end;
   if Akt.DokumentONA_SEM_DOK.AsString<>'' then begin
     Akt.edONA_SEM.Hint:=Akt.DokumentONA_SEM_DOK.AsString;
     Akt.edONA_SEM.Color:=GetDisableColorGIS;
   end;

end;
{$ENDIF}

//�������� ����:
//0410 - ��������� �/� � ������;
//0420 - ������������� �/�  � ������;
//2400 - ������ ���������� ������������� � ������;
//3400 - ������ ������������� �/� � ������;
function TGisun.SetTypeMessageAktSmert(Akt: TfmSimpleD; var strError: String): Boolean;
var
//  AktSmert : TfmZapisSmert;
  Vozrast,m,d : Integer;
begin
  Akt.Dokument.CheckBrowseMode;
//  AktSmert := TfmZapisSmert(Akt);
  if not CheckMessageSource(Akt, strError) then begin
    Result:=false;
    exit;
  end;
  strError:='';
  TypeAkt := '0400';

  if (Akt.Dokument.FieldByName('LICH_NOMER') .AsString<>'') and (Length(Trim(Akt.Dokument.FieldByName('LICH_NOMER') .AsString))=LEN_IN)
    then Person:=true
    else Person:=false;

  if (Akt.Dokument.FieldByName('DECL_IN') .AsString<>'') and (Length(Trim(Akt.Dokument.FieldByName('DECL_IN') .AsString))=LEN_IN)
    then DeclMen:=true
    else DeclMen:=false;

  RunExchange:=true;  // ��������� ������������� ��� ���
  DefaultPoleGrn:=0;  // �������� ��� ���� POLE_GRN ���� �� ���� ������������ ��������������
  TypeMessage:='0400';

  if not DeclMen and not Person then begin //(Akt.Dokument.FieldByName('LICH_NOMER').AsString='') then begin
    strError:='��������� ����������������� �����';
  end;
  if strError=''
    then Result:=true
    else Result:=false;
end;

//-------------------------------------------------------------------
function TGisun.AdresToString(ds:TDataSet): String;
var
 s,ss,so:String;
 lFull:Boolean;
 r:TPunktMesto;
 ag:TGorodR;
 procedure AddStr(sss:String);
 begin
   if sss<>'' then begin
     if Result<>''
       then Result:=Result+' '+sss
       else Result:=sss;
   end;
 end;
begin
  Result:='';
//-------------- ����� ���������� -----------------
  if not AdresGitIsEmpty(ds) then begin  // ���� ����� ����� ���������� �� ������ !!!
//    lFull:=false;
    lFull:=true;  // !!!
    s:=Decode_Alfa3(ds.FieldByName('K_GOSUD').AsString,'***');
//    if (s<>'') and (s<>MY_GRAG_STR) and dmBase.SprStran.Locate('ID',s,[]) then begin
    if (s<>'') and dmBase.SprStran.Locate('ID',s,[]) then begin
      Result:=dmBase.SprStran.FieldByName('FNAME').AsString;
    end;

//    s:=Trim(GlobalTask.ParamAsString('OBL'));
//    if (s<>'') and dmBase.IsAddTypeObl(s)
//      then s:=s+' ���.';
    ss:=ds.FieldByName('N_OBL').AsString;
    if (ss<>'') and dmBase.IsAddTypeObl(ss)
      then ss:=ss+' ���.';
//    if (ANSIUpperCase(s)<>ANSIUpperCase(ss)) or lFull
    AddStr(FirstCharUpper(ss));

    s:=ds.FieldByName('N_RAION').AsString;
    if s<>'' then AddStr(FirstCharUpper(s)+' �-�');

    r:=DecodePunkt_MestoGitEx(ds);
    AddStr(dmBase.NamePunkt(r.Name, StrToInt(r.Type_Kod), ''));
    ag:=GetGorodREx(ds, false, ' ');
    AddStr(ag.full);
  end;
end;
//--------------------------------------------------------------------
// ��������� ������ ��� ������� ������ � ������
function TGisun.GetSmert(Akt: TfmSimpleD): Boolean;
{$IFNDEF ADD_ZAGS}
begin
  Result:=false;
end;
{$ELSE}
var
  AktSmert : TfmZapisSmert;
  strName, strError,strSOATO : String;
  nAteID, PoleGrnSub : Integer;
  ag:TGorodR; // ����� � ������
  p : TPassport;
  s,ss : String;
begin
  Result:=false;
  AktSmert := TfmZapisSmert(Akt);
  AktSmert.Dokument.CheckBrowseMode;
  if not SetTypeMessageAktSmert( AktSmert, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end else begin
    ClearDataSets;
    if RunExchange then begin
      PoleGrnSub:=0;
      //[1] ������ ������
      //1. ������ ������� ��� �������� ������ � �������
      Input:=FRegInt.CreateInputTable(akDecease, opGet);
      //2. ��������� ������������ ������
      //�������
      if Person then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='MAN';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktSmert.DokumentLICH_NOMER.AsString);
        Input.Post;
      end;
      //���������
      if DeclMen then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='DECL';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktSmert.DokumentDECL_IN.AsString);
        Input.Post;
      end;
      //3. ��������� ������ � �������
      RequestResult:=RegInt.Get(akDecease, TypeMessage, Input, Output, Error);
      if IsDebug then begin
         RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_get.txt');
      end;
      if RequestResult=rrOk then begin
        Result:=true;
        AktSmert.Dokument.Edit;
        AktSmert.DokumentSTATUS.AsString  := '';
        AktSmert.DokumentTypeMessage.AsString:='';
        AktSmert.MessageID:=RegInt.RequestMessageId;  // �������� ID �������
        if Person then begin
          if OutPut.Locate('PREFIX','MAN',[]) then begin
            PoleGrnSub:=PoleGrnSub or bPerson or bChildId;
            //������������ ������ ��������
            AktSmert.DokumentLICH_NOMER.AsString:= OutPut.FieldByName('IDENTIF').AsString;
            AktSmert.DokumentFamilia.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
            AktSmert.DokumentFamilia_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
            AktSmert.DokumentNAME.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
            AktSmert.DokumentName_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
            AktSmert.DokumentOTCH.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
            AktSmert.DokumentOtch_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);

            Decode_Date(OutPut.FieldByName('DATER').AsString, AktSmert.DokumentDATER, AktSmert.DokumentONLYGOD_R);

            if OutPut.FieldByName('DATES').AsString<>''
              then Decode_Date(OutPut.FieldByName('DATES').AsString, AktSmert.DokumentDATES, AktSmert.DokumentONLYGOD,'������');
            if (OutPut.FieldByName('K_CAUSE').AsString<>'') and (AktSmert.DokumentPR_OSN_NAME.AsString='') then begin
              try
                AktSmert.DokumentPR_OSN_NAME.AsString:=OutPut.FieldByName('N_CAUSE').AsString;
                AktSmert.DokumentPR_OSN.AsString:=OutPut.FieldByName('K_CAUSE').AsString;
                AktSmert.DokumentPR_OSN_NAME_B.AsString:='';
              except
              end;
            end;
            AktSmert.DokumentPOL.AsString   := Decode_Pol(OutPut.FieldByName('K_POL').AsString);
            if LoadGrag then
              AktSmert.DokumentGRAG.AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
            AktSmert.DokumentSTATUS.AsString := OutPut.FieldByName('K_STATUS').AsString;
            //���������� ������ (��������, �������������� ��������)
            AktSmert.DokumentDOK_TYPE.AsString:=Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString);
            AktSmert.DokumentDOK_ORGAN.AsString:=OutPut.FieldByName('K_DOC_ORGAN').AsString;
            AktSmert.DokumentDOK_NAME.AsString:=OutPut.FieldByName('N_DOC_ORGAN').AsString;
            AktSmert.DokumentDOK_SERIA.AsString:=OutPut.FieldByName('DOC_SERIA').AsString;
            AktSmert.DokumentDOK_NOMER.AsString:=OutPut.FieldByName('DOC_NOMER').AsString;
            SetDateTime(AktSmert.DokumentDOK_DATE, OutPut.FieldByName('DOC_DATE'));
            if AktSmert.DokumentIS_SDAN_DOK.AsBoolean then begin
              p := dmBase.PasportFromValues(AktSmert.DokumentDOK_TYPE.AsInteger, AktSmert.DokumentDOK_SERIA.AsString,
                                            AktSmert.DokumentDOK_NOMER.AsString, AktSmert.DokumentDOK_NAME.AsString, '',
                                            AktSmert.DokumentDOK_DATE.Value);
              s := dmBase.PasportToText(p,0);
              if s<>'' then begin
                AktSmert.DokumentSDAN_DOK.AsString:=s;
              end;
            end;

            //AktSmert.DokumentDOK_DATE.AsDateTime:=OutPut.FieldByName('DOC_DATE').AsDateTime;
            //--------------- ����� �������� -----------------------
            AktSmert.DokumentRG_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString); //������ ��������

            DecodeObl_MestoRogd( AktSmert.Dokument,'RG_OBL','RG_B_OBL','',OutPut);
            //AktSmert.DokumentRG_B_OBL.AsString:='';
            //AktSmert.DokumentRG_OBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,''); //������� ��������

            AktSmert.DokumentRG_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,''); //����� ��������

            DecodePunkt_MestoRogd(AktSmert.Dokument, 'RG_B_GOROD', 'RG_GOROD', '', OutPut);
            //AktSmert.DokumentRG_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString); //��� ���������� ������ ��������
            //AktSmert.DokumentRG_GOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString; //��������� ����� �� ������� �����

            //-------------- ����� ���������� -----------------
            if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
              AktSmert.DokumentGT_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');

              DecodeObl_MestoGit( AktSmert.Dokument,'GT_OBL','GT_B_OBL','',OutPut);
              //AktSmert.DokumentGT_B_OBL.AsString:='';
              //AktSmert.DokumentGT_OBL.AsString:=Decode_Obl(OutPut.FieldByName('N_OBL').AsString,'');

              AktSmert.DokumentGT_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');

              DecodePunkt_MestoGit(AktSmert.Dokument, 'GT_B_GOROD', 'GT_GOROD', '', OutPut);
              //AktSmert.DokumentGT_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD').AsString);
              //AktSmert.DokumentGT_GOROD.AsString:=OutPut.FieldByName('N_GOROD').AsString;

// ����            AktSmert.DokumentGT_GOROD_R.AsString:=GetGorodR(OutPut);
//--------- ����� --------
              ag:=GetGorodREx(OutPut);
              AktSmert.DokumentGT_GOROD_R.AsString:=ag.Ulica;
              AktSmert.DokumentGT_DOM.AsString:=ag.Dom;
              AktSmert.DokumentGT_KORP.AsString:=ag.Korp;
              AktSmert.DokumentGT_KV.AsString:=ag.Kv;
//------------------------
              {$IFDEF GISUN2}
                AktSmert.DokumentGT_RNGOROD.AsString:=Decode_RnGorod(OutPut, ['K_RN_GOROD','N_RN_GOROD'], strSoato);
              {$ENDIF}
              if getSoato(OutPut, nAteID, strSoato, strName) then begin
                AktSmert.CheckSoatoAkt(true, '{SS}', nAteID, strSoato);
              end else begin
                AktSmert.CheckSoatoAkt(true, '{SS}', 0, '');  // ��� ������ ���� ��������� ��������
              end;
            end;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ �� �������� ! ');
            Result:=false;
          end;
        end;
        //------ ��������� ---------------------------------------------------------------
        if DeclMen then begin
          if OutPut.Locate('PREFIX','DECL',[]) then begin
            s:=CaseFIO(OutPut.FieldByName('FAMILIA').AsString)+' '+CaseFIO(OutPut.FieldByName('NAME').AsString)+' '+
               CaseFIO(OutPut.FieldByName('OTCH').AsString);
            //-------------- ����� ���������� -----------------
            if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
              s:=s+', '+AdresToString(Output);
            end;
            AktSmert.DokumentDECL.AsString:=s;
            //----- ���������� ������ (��������, �������������� ��������)
            p := dmBase.PasportFromValues(StrToIntDef(Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString),888),
                    OutPut.FieldByName('DOC_SERIA').AsString, OutPut.FieldByName('DOC_NOMER').AsString,
                    OutPut.FieldByName('N_DOC_ORGAN').AsString, '', OutPut.FieldByName('DOC_DATE').AsDateTime);
            {
            p.UdostKod:=StrToInt(Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString));
            if p.UdostKod<1 then p.UdostKod:=1;
            p.Udost:=dmBase.GetNamePasport(p.UdostKod);
            p.Organ:=OutPut.FieldByName('N_DOC_ORGAN').AsString;
            p.Seria:=OutPut.FieldByName('DOC_SERIA').AsString;
            p.Nomer:=OutPut.FieldByName('DOC_NOMER').AsString;
            p.Date:=OutPut.FieldByName('DOC_DATE').AsDateTime;
            p.sDate:=DatePropis(OutPut.FieldByName('DOC_DATE').AsDateTime,3);
            }
            s := dmBase.PasportToText(p,0);
            if s<>''
              then AktSmert.DokumentDECL_DOK.AsString:=s;
          end;
        end;
        //----- end ��������� ------------------------------------------------------------

        if not Result then begin
          SetPoleGrn(AktSmert.DokumentPOLE_GRN, 0, 0);
        end else begin
          SetPoleGrn(AktSmert.DokumentPOLE_GRN, 2, PoleGrnSub);
          AktSmert.DokumentTypeMessage.AsString:=TypeMessage;
        end;
        AktSmert.Dokument.Post;
      end else begin
        HandleError(RequestResult, akDecease, opGet, Input, Output, Error, RegInt.FaultError);
      end;
      ClearDataSets;
    end;
  end;
end;
{$ENDIF}

//-----------------------------------------------------------------------
// ����������� ���� � ������
function TGisun.RegisterSmert(Akt: TfmSimpleD; lEmptyPrSmert:Boolean): Boolean;
{$IFNDEF ADD_ZAGS}
begin
  Result:=false;
end;
{$ELSE}
var
  AktSmert : TfmZapisSmert;
  strError,strPrich : String;
begin
  Result:=false;
  AktSmert := TfmZapisSmert(Akt);
  AktSmert.Dokument.CheckBrowseMode;
  Result:=true;
  if not SetTypeMessageAktSmert( AktSmert, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end;
  if Result then begin
    strError:='';

    if not lEmptyPrSmert then begin // not AktSmert.DokumentEMPTY_PRICH.AsBoolean then begin
      if (Trim(AktSmert.DokumentPR_OSN.AsString)='') and (Trim(AktSmert.DokumentPR_NEP.AsString)='') then begin
        strError:=strError+'��������� ��� �������� ��� ���������������� ������� ������'+#13#10;
      end;
    end;
    {
    if (AktSmert.DokumentDateS.AsString='') then begin
      strError:=strError+'��������� ���� ������'+#13#10;
    end;
    }

    CheckAllAkt(AktSmert,strError);
    if strError<>'' then begin
      ShowMessageErr(strError);
      Result:=false;
    end;
  end;
  if Result then begin
    Result:=false;
    ClearDataSets;
    //[2] �������� ������
    //1. ������ ������� ��� �������� ������ � �������
    Input:=FRegInt.CreateInputTable(akDecease, opPost);
    //2. ��������� ������������ ������
    Input.Append;
    //������������ ������ ��������
    Input.FieldByName('IDENTIF').AsString:=AktSmert.DokumentLICH_NOMER.AsString; //������������ �����
    Input.FieldByName('FAMILIA').AsString:=AktSmert.DokumentFamilia.AsString; //������� �� ������� �����
    Input.FieldByName('FAMILIA_B').AsString:=AktSmert.DokumentFamilia_B.AsString; //������� �� ����������� �����
    Input.FieldByName('NAME').AsString:=AktSmert.DokumentName.AsString; //��� �� ������� �����
    Input.FieldByName('NAME_B').AsString:=AktSmert.DokumentNAME_B.AsString; //��� �� ����������� �����
    Input.FieldByName('OTCH').AsString:=AktSmert.DokumentOtch.AsString;
    Input.FieldByName('OTCH_B').AsString:=AktSmert.DokumentOtch_B.AsString;
    Input.FieldByName('POL').AsString:=Code_Pol(AktSmert.DokumentPOL.AsString);
    Input.FieldByName('DATER').AsString:=Code_Date(AktSmert.DokumentDateR.AsDateTime, AktSmert.DokumentONLYGOD_R); //���� ��������
    Input.FieldByName('GRAJD').AsString:=Code_Alfa3(AktSmert.DokumentGRAG.AsString); //�����������
    Input.FieldByName('STATUS').AsString:=AktSmert.DokumentSTATUS.AsString; //������
    //------------------����� �������� ----------------
    Input.FieldByName('GOSUD_R').AsString:=Code_Alfa3(AktSmert.DokumentRG_GOSUD.AsString); //������ ��������

    CodeObl_MestoRogd( AktSmert.Dokument,'RG_OBL','RG_B_OBL','',Input,'OBL_R','');
    //Input.FieldByName('OBL_R').AsString:=AktSmert.DokumentRG_OBL.AsString; //������� ��������

    Input.FieldByName('RAION_R').AsString:=AktSmert.DokumentRG_RAION.AsString; //����� ��������

    CodePunkt_MestoRogd(AktSmert.Dokument, 'RG_B_GOROD','RG_GOROD','',Input,'TIP_GOROD_R','GOROD_R','');
    //Input.FieldByName('TIP_GOROD_R').AsString:=Code_TypePunkt(AktSmert.DokumentRG_B_GOROD.AsString); //��� ���������� ������
    //Input.FieldByName('GOROD_R').AsString:=AktSmert.DokumentRG_GOROD.AsString; //��������� ����� �� ������� �����

    //���������� � ������
    if lEmptyPrSmert then begin
      strPrich:='????';
      Input.FieldByName('SM_PRICH').AsString:=''  // �������� ������ ������� ������
    end else begin
      if Trim(AktSmert.DokumentPR_OSN.AsString)<>''
        then Input.FieldByName('SM_PRICH').AsString:=AktSmert.DokumentPR_OSN.AsString    // ������� ������ ��������
        else Input.FieldByName('SM_PRICH').AsString:=AktSmert.DokumentPR_NEP.AsString;   // ������� ������ ����������������
      strPrich:=Trim(Input.FieldByName('SM_PRICH').AsString);
    end;

    Input.FieldByName('SM_DATE').AsString:=Code_Date(AktSmert.DokumentDateS.AsDateTime, AktSmert.DokumentONLYGOD); //���� ������
    Input.FieldByName('SM_GDE').AsString:=Code_SmPosl(AktSmert.DokumentSMERT_POSL.AsInteger);// ������ ����������� �
    Input.FieldByName('SM_MESTO').AsString:=AktSmert.DokumentMESTO_Z.AsString; //����� �����������
    Input.FieldByName('SM_DOC').AsString:=AktSmert.DokumentDOKUMENT.AsString; //��������, �������������� ���� ������
    //----------------����� ������ ------------------
    Input.FieldByName('GOSUD').AsString:=Code_Alfa3(AktSmert.DokumentSM_GOSUD.AsString); //������

    CodeObl_MestoRogd( AktSmert.Dokument,'SM_OBL','SM_B_OBL','SM_OBL_B',Input,'OBL','OBL_B');
    //Input.FieldByName('OBL').AsString:=AktSmert.DokumentSM_OBL.AsString; //�������
    //Input.FieldByName('OBL_B').AsString:=AktSmert.DokumentSM_OBL_B.AsString; //������� �� �����������

    Input.FieldByName('RAION').AsString:=AktSmert.DokumentSM_RAION.AsString; //�����
    Input.FieldByName('RAION_B').AsString:=AktSmert.DokumentSM_RAION_B.AsString; //����� �� �����������

    CodePunkt_MestoRogd(AktSmert.Dokument, 'SM_B_GOROD','SM_GOROD','SM_GOROD_B',Input,'TIP_GOROD','GOROD','GOROD_B');
    //Input.FieldByName('TIP_GOROD').AsString:=Code_TypePunkt(AktSmert.DokumentSM_B_GOROD.AsString); //��� ���������� ������
    //Input.FieldByName('GOROD').AsString:=AktSmert.DokumentSM_GOROD.AsString; //��������� ����� �� ������� �����
    //Input.FieldByName('GOROD_B').AsString:=AktSmert.DokumentSM_GOROD_B.AsString; //��������� ����� �� ����������� �����

    //���������� �� ������� ������
    Input.FieldByName('ACT_TIP').AsString:=TypeAkt; //��� ������� ������
    SetOrganAkt(AktSmert, Input);
    Input.FieldByName('ACT_DATE').AsDateTime:=AktSmert.Dokument.FieldByName('DATEZ').AsDateTime; //���� ������� ������
    Input.FieldByName('ACT_NOMER').AsString:=AktSmert.Dokument.FieldByName('NOMER').AsString; //����� ������� ������
    //���������� � �������� ���������
    SetDokSvid(AktSmert, Input);

    Input.Post;
    //3. ��������� ������ � �������
    RequestResult:=RegInt.Post(AktSmert.MessageID, akDecease, AktSmert.DokumentTypeMessage.AsString, Input, Error);
    LogToTableLog(AktSmert, '����������� �/� � ������');
    if RequestResult=rrOk then begin
      AktSmert.Dokument.CheckBrowseMode;
      AktSmert.Dokument.Edit;
      SetPoleGrn(AktSmert.DokumentPOLE_GRN, 3);
      AktSmert.Dokument.Post;
      if not HandleErrorToString
        then ShowMessageCont(GetMessageOk,CurAkt);
      Result:=true;
    end else begin
      //4.2. ������������ ������ �������������� � ���������
      {
      if not lPrSmert and (Error.RecordCount>0) then begin
        try
          Error.First;
          while not Error.Eof do begin
            if Trim(Error.FieldByName('WRONG_VALUE').AsString)=strPrich then begin //������������ ��������
              lPrSmert:=true;
            end;
            Error.Next;
          end;
        except
          lPrSmert:=true;
        end;
        Error.First;
      end;
      }
      Result:=false;
      HandleError(RequestResult, akDecease, opGet, Input, Output, Error, FRegInt.FaultError);
    end;
    if IsDebug then begin
       RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_post.txt');
    end;
  end;
end;
{$ENDIF}

//---------------------------------------------------------------
procedure TGisun.CheckSmert(Simple: TfmSimpleD);
{$IFNDEF ADD_ZAGS}
begin
end;
{$ELSE}
const
  {$IFDEF GISUN2}
    CComponentName: array [1..26] of record
  {$ELSE}
    CComponentName: array [1..25] of record   //
  {$ENDIF}
      Name: string;
      Code: Integer;
      Color: TColor;
   end=(
     //�e�����
     //������������ ������ ��������
     (Name:'ENG_edIDENTIF'; Code: bChildId; Color: clDefault),

     (Name:'edFamilia'; Code: bPerson; Color: clDefault),
     (Name:'edNAME'; Code: bPerson; Color: clDefault),
     (Name:'edOTCH'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edFamilia'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edNAME'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edOTCH'; Code: bPerson; Color: clDefault),

     (Name:'edFamilia_Sv'; Code: bPerson; Color: clDefault),
     (Name:'edNAME_Sv'; Code: bPerson; Color: clDefault),
     (Name:'edOTCH_Sv'; Code: bPerson; Color: clDefault),

     (Name:'BLR_edFamiliaB_Sv'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edNAMEB_Sv'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edOTCHB_Sv'; Code: bPerson; Color: clDefault),

     (Name:'edDATER_Sv'; Code: bPerson; Color: clDefault),
     (Name:'N_F_cbOnlyGodR_Sv'; Code: bPerson; Color: clDefault),
     (Name:'edPOL_Sv'; Code: bPerson; Color: clDefault),

     (Name:'edDATER'; Code: bChildId; Color: clDefault),
     (Name:'N_F_cbOnlyGodR'; Code: bChildId; Color: clDefault),
     (Name:'edPOL'; Code: bChildId; Color: clDefault),
     (Name:'edGRAG'; Code: bPerson; Color: clDefault),         //???
     //--STATUS
     //���������� ������ (��������, �������������� ��������)
     //(Name:'edDOK_TYPE'; Code: bPerson; Color: clDefault),
     //--DOK_ORGAN
     //(Name:'edDOK_NAME'; Code: bPerson; Color: clDefault),
     //(Name:'edDOK_SERIA'; Code: bPerson; Color: clDefault),
     //(Name:'edDOK_NOMER'; Code: bPerson; Color: clDefault),
     //(Name:'edDOK_DATE'; Code: bPerson; Color: clDefault),
     //����� ��������
     (Name:'edRG_GOSUD'; Code: bPerson; Color: clDefault),
     (Name:'edRG_B_OBL'; Code: bPerson; Color: clDefault),
     (Name:'edRG_OBL'; Code: bPerson; Color: clDefault),
     (Name:'edRG_RAION'; Code: bPerson; Color: clDefault),
     (Name:'edRG_B_GOROD'; Code: bPerson; Color: clDefault),
     (Name:'edRG_GOROD'; Code: bPerson; Color: clDefault)
     //����� ����������
     {
     (Name:'edGT_B_RESP'; Code: bPerson; Color: clDefault),
     (Name:'edGT_GOSUD'; Code: bPerson; Color: clDefault),
     (Name:'edGT_B_OBL'; Code: bPerson; Color: clDefault),
     (Name:'edGT_OBL'; Code: bPerson; Color: clDefault),
     (Name:'edGT_RAION'; Code: bPerson; Color: clDefault),
     (Name:'edGT_B_GOROD'; Code: bPerson; Color: clDefault),
     (Name:'edGT_GOROD'; Code: bPerson; Color: clDefault),
//     {$IFDEF GISUN2}
//       (Name:'edGT_RNGOROD'; Code: bPerson; Color: clDefault),
//     {$ENDIF}
     {
     (Name:'edGT_GOROD_R'; Code: bPerson; Color: clDefault),
     (Name:'edGT_DOM'; Code: bPerson; Color: clDefault),
     (Name:'edGT_KORP'; Code: bPerson; Color: clDefault),
     (Name:'edGT_KV'; Code: bPerson; Color: clDefault)
     }
     {
     // �������������
     (Name:'edFamilia_Sv'; Code: bPerson; Color: clDefault),
     (Name:'edNAME_Sv'; Code: bPerson; Color: clDefault),
     (Name:'edOTCH_Sv'; Code: bPerson; Color: clDefault),

     (Name:'BLR_edFamiliaB_Sv'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edNAMEB_Sv'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edOTCHB_Sv'; Code: bPerson; Color: clDefault),

     (Name:'edDATER_Sv'; Code: bChildId; Color: clDefault),
     (Name:'cbOnlyGodR_Sv'; Code: bChildId; Color: clDefault),
     (Name:'edPOL_Sv'; Code: bChildId; Color: clDefault)
     }

   );
var
   Akt: TfmZapisSmert;
   PoleGrn: Integer;
   PoleGrnSub: Integer;
   I: Integer;
   Component: TComponent;
   Control: TControl;
   lDisable,l: Boolean;
begin
   Akt:=TfmZapisSmert(Simple);
   l:=(IsEnabled and IsEnableTypeAkt(dmBase.TypeObj_ZSmert,false));
   if l then begin
     PoleGrn:=GetPoleGrn(Akt.DokumentPOLE_GRN.AsInteger);
     PoleGrnSub:=GetPoleGrnSub(Akt.DokumentPOLE_GRN.AsInteger);
   end else begin
     PoleGrn:=0;
     PoleGrnSub:=0;
   end;
   if PoleGrn=rPost then begin
     Akt.TbItemEmptyPrich.Enabled:=false;
   end else begin
     Akt.TbItemEmptyPrich.Enabled:=true;
   end;
   //1. ������������ ����������� ������ [� ������ ������� �� ����� ��������]
   //TBItemStep1 - "��������� ������"
   //TBItemStep2 - "���������������� ������� ������"
   {
   if not IsDebug then begin
      case PoleGrn of
         //�� ���� ������ � ��� ��
         0: begin
            Akt.TBItemStep1.Enabled:=True;
            Akt.TBItemStep2.Enabled:=True;
         end;
         1:;
         //������� ����� �� ��� ��
         2: begin
            Akt.TBItemStep1.Enabled:=False;
            Akt.TBItemStep2.Enabled:=True;
         end;
         //���������� ������ �� ������� ������ � ��� ��
         3: begin
            Akt.TBItemStep1.Enabled:=False;
            Akt.TBItemStep2.Enabled:=False;
         end;
      end;
   end;
   }
   //2. ������������ ����������� ��������� ��������������
   //����� ��������� ������ �� ��� �� �������� �������������� ������ ����� ����������
   for I:=Low(CComponentName) to High(CComponentName) do begin
      Component:=Akt.FindComponent(CComponentName[I].Name);
      if (Component<>nil) and (Component is TControl) then begin
         Control:=TControl(Component);
         //2.1.
         if l
           then lDisable:=((PoleGrn=2) or (PoleGrn=3)) and ((PoleGrnSub and CComponentName[I].Code)=CComponentName[I].Code)
           else lDisable:=l;

         if lDisable and (PoleGrn=3) then begin
           lDisable:=false;
         end;

         //2.2.
         if lDisable then begin
            SetEnableControl(FTypeEnableControl,Control,false);
            //Control.Enabled:=False;
            if TxControl(Control).Color<>GetDisableColorGIS then begin
               CComponentName[I].Color:=TxControl(Control).Color;
            end;
            TxControl(Control).Color:=GetDisableColorGIS;
         end else begin
            if CComponentName[I].Color<>clDefault then begin
               TxControl(Control).Color:=CComponentName[I].Color;
            end;
            SetEnableControl(FTypeEnableControl,Control,true);
            //Control.Enabled:=True;
         end;
      end
      else begin
         ShowMessageC(CComponentName[I].Name);
      end;
   end;
   // !!!!!  ���� ������ ������ ����������� ��������� ��� �������������
   if Akt.edGRAG.Text='' then begin
     Akt.edGRAG.Color:=GetControlColor;
     SetEnableControl(FTypeEnableControl,Akt.edGRAG,true);
   end;
end;
{$ENDIF}

function TGisun.Code_Date( d: TDateTime; fldType : TField ): String;
begin
  if d=0 then begin
    Result:='00000000';
  end else begin
    if fldType.IsNull then begin
      Result := FormatDateTime('YYYYMMDD', d) // ������ ����
    end else begin
      if fldType.DataType=ftBoolean then begin
        if fldType.AsBoolean
          then Result := FormatDateTime('YYYY', d)+'0000' // ������ ���
          else Result := FormatDateTime('YYYYMMDD', d) // ������ ����
      end else begin
        case fldType.AsInteger of
          DATE_FULL     : Result := FormatDateTime('YYYYMMDD', d);
          DATE_GOD      : Result := FormatDateTime('YYYY', d)+'0000';
          DATE_GODMONTH : Result := FormatDateTime('YYYYMM', d)+'00';
        else
          Result := FormatDateTime('YYYYMMDD', d);
        end;
      end;
    end;
  end;
end;

function TGisun.Code_Date(d: TDateTime; nType: Integer): String;
begin
  if d=0 then begin
    Result:='00000000';
  end else begin
    case nType of
      DATE_FULL     : Result := FormatDateTime('YYYYMMDD', d);
      DATE_GOD      : Result := FormatDateTime('YYYY', d)+'0000';
      DATE_GODMONTH : Result := FormatDateTime('YYYYMM', d)+'00';
    else
      Result := FormatDateTime('YYYYMMDD', d);
    end;
  end;
end;

procedure TGisun.Decode_Date( sDate : String; fldDate,fldType : TField;sName:String);
var
  n : Integer;
begin
  n:=Length(sDate);
  if n=8 then begin
    if sDate='00000000' then begin
      n:=0;
    end else if Copy(sDate,5,4)='0000' then begin
      n:=4;
    end else if Copy(sDate,7,2)='00' then begin
      n:=6;
    end;
  end;
  if n>0 then begin
    try
      if fldType.DataType=ftBoolean then begin
         case n of
           8 : begin       // ������ ����
                 fldDate.AsDateTime:=STOD(sDate,tdClipper);
                 fldType.AsBoolean:=false;
               end;
           else           // ������ ���
             fldDate.AsDateTime:=STOD(Copy(sDate,1,4)+'0701',tdClipper);
             fldType.AsBoolean:=true;
         end;
      end else begin
        case n of
          8 : begin       // YYYYMMDD
                fldDate.AsDateTime:=STOD(sDate,tdClipper);
                fldType.AsInteger:=DATE_FULL;
              end;
          6 : begin       // YYYYMM
                fldDate.AsDateTime:=STOD(Copy(sDate,1,6)+'15',tdClipper);
                fldType.AsInteger:=DATE_GODMONTH;
              end;
          4 : begin       // YYYY
                fldDate.AsDateTime:=STOD(Copy(sDate,1,4)+'0701',tdClipper);
                fldType.AsInteger:=DATE_GOD;
              end;
        else
          {!!!}
        end;
      end;
    except
      on E: sysutils.Exception do begin
        if sName='' then sName:='��������';
        ShowMessageErr(E.Message+' ('+sName+') '+sDate);
        fldDate.AsString:='';
        if fldType.DataType=ftBoolean
          then fldType.AsBoolean:=false
          else fldType.AsInteger:=DATE_FULL;
      end;
    end;
  end;
end;
//----------------------------------------------------------------------------------------
function TGisun.Decode_Date2( sDate : String; var dDate:TDateTime; var nType:Integer; sName:String):Boolean;
var
  n : Integer;
begin
  Result:=true;
  n:=Length(sDate);
  if n=8 then begin
    if sDate='00000000' then begin
      n:=0;
    end else if Copy(sDate,5,4)='0000' then begin
      n:=4;
    end else if Copy(sDate,7,2)='00' then begin
      n:=6;
    end;
  end;
  if n>0 then begin
    try
      case n of
        8 : begin       // YYYYMMDD
              dDate:=STOD(sDate,tdClipper);
              nType:=DATE_FULL;
            end;
        6 : begin       // YYYYMM
              dDate:=STOD(Copy(sDate,1,6)+'15',tdClipper);
              nType:=DATE_GODMONTH;
            end;
        4 : begin       // YYYY
              dDate:=STOD(Copy(sDate,1,4)+'0701',tdClipper);
              nType:=DATE_GOD;
            end;
      else
        {!!!}
      end;
    except
      on E: sysutils.Exception do begin
        if sName='' then sName:='��������';
        ShowMessageErr(E.Message+' '+sName+' '+sDate);
        dDate:=0;
        nType:=DATE_FULL;
      end;
    end;
  end else begin
    Result:=false;
  end;
end;

function TGisun.Code_SmPosl(smPosl : Integer): String;
var
  Opis : TOpisEdit;
begin
  Opis := GlobalTask.CurrentOpisEdit.GetListOpisA('KEY_SMERT_POSL');
  Result := Opis.Naim(smPosl, false);
end;

//�������� ����:
//0240 - ��������� �/� �� ������������ ��������� � �������� ��;
//0241 - ��������� �/� �� ������������ ��������� ��� ������� ��;
//3200 - ������ ������������� �/� �� ������������ ���������;
function TGisun.SetTypeMessageAktUstOtc(Akt: TfmSimpleD; var strError: String): Boolean;
{$IFNDEF ADD_ZAGS}
begin
  Result:=false;
end;
{$ELSE}
var
  AktUstOtc : TfmZapisUstOtc;
begin
  AktUstOtc := TfmZapisUstOtc(Akt);
  AktUstOtc.Dokument.CheckBrowseMode;
  Result:=false;

  if not CheckMessageSource(Akt, strError) then begin
    exit;
  end;

  strError:='';
  TypeAkt := '0200';

  if AktUstOtc.DokumentON_IDENTIF.AsString='' then begin
    // ���� ���� ��������� ������� ��, � ��� �� ��������� ��
    if (AktUstOtc.DokumentON_DOK_TYPE.AsInteger=1) and (AktUstOtc.DokumentON_GRAG.AsString<>MY_GRAG_STR) then begin
      strError:='�� ��������� �� ����� ����� ������� ��';
      exit;
    end;
    // ���� ���� ��������� �� ������� ��, � ��� ��������� ��
    if (AktUstOtc.DokumentON_DOK_TYPE.AsInteger<>1) and (AktUstOtc.DokumentON_GRAG.AsString=MY_GRAG_STR) then begin
      strError:='��������� �� ������ ����� ������� ��';
      exit;
    end;
  end;

  if AktUstOtc.DokumentONA_IDENTIF.AsString='' then begin
    // ���� ���� ���������� ������� ��, � ���� �� ��������� ��
    if (AktUstOtc.DokumentONA_DOK_TYPE.AsInteger=1) and (AktUstOtc.DokumentONA_GRAG.AsString<>MY_GRAG_STR) then begin
      strError:='�� ��������� �� ����� ����� ������� ��';
      exit;
    end;
    //  ���� ���� ��������� �� ������� ��, � ��� ��������� ��
    if (AktUstOtc.DokumentONA_DOK_TYPE.AsInteger<>1) and (AktUstOtc.DokumentONA_GRAG.AsString=MY_GRAG_STR) then begin
      strError:='��������� �� ������ ����� ������� ��';
      exit;
    end;
  end;


//  Child:=true;  // ����� ������ � �������
  if AktUstOtc.DokumentCHILD.AsBoolean
    then Child:=true   // ����� ������ �� �������
    else Child:=false;

  Female:=true;  // ����� ������ � ����
  Male:=true;    // ����� ������ � ����
  ChildIdentif:=false; // ����� �� ��� �������
  RunExchange:=true;  // ��������� ������������� ��� ���
  DefaultPoleGrn:=0;  // �������� ��� ���� POLE_GRN ���� �� ���� ������������ ��������������
  TypeMessage:='*';

  //----- !!! ----------------- �� � ������� ������ ������������ ������ 09.12.2011  ��������� ��������
  TypeMessage:='0200';
  ChildIdentif:=false;
  //-----------------------
  {
  case AktUstOtc.DokumentTYPEREG.AsInteger of
    0: begin //
         if AktUstOtc.DokumentIDENTIF.AsString='' then begin //
           TypeMessage:='0200';
           Child:=false;
           ChildIdentif:=false;
         end;
       end;
    1: begin //���� �� ������� � �����
      if AktUstOtc.DokumentIDENTIF.AsString='' then begin //����������� ���������, ����� ���� �� ������� � ����� � �������� ��
         TypeMessage:='0210';
         Child:=false;
         ChildIdentif:=true;
      end
      else begin //����������� ���������, ����� ���� �� ������� � ����� ��� ������� ��
         TypeMessage:='0211';
      end;
    end;
    2: begin //���� ������� � ����� � ����� �������
      if AktUstOtc.DokumentIDENTIF.AsString='' then begin //����������� ���������, ����� ���� ������� � ����� � ����� ������� � �������� ��
         TypeMessage:='0220';
         Child:=false;
         ChildIdentif:=true;
      end
      else begin //����������� ���������, ����� ���� ������� � ����� � ����� ������� ��� ������� ��
         TypeMessage:='0221';
      end;
    end;
    3: begin //���� ������� � ����� �� � ����� �������
      if AktUstOtc.DokumentIDENTIF.AsString='' then begin //����������� ���������, ����� ���� ������� � ����� �� � ����� ������� � �������� ��
         TypeMessage:='0230';
         Child:=false;
         ChildIdentif:=true;
      end
      else begin //����������� ���������, ����� ���� ������� � ����� �� � ����� ������� ��� ������� ��
         TypeMessage:='0231';
      end;
    end;
  end;
  }

//  lNotRB_ON:=false;
//  lNotRB_ONA:=false;
  // ���� ��������� �������� �� ������� ��(1) � �� ��� �� ����������(2,3)
  if (AktUstOtc.DokumentON_DOK_TYPE.AsInteger>3) or (AktUstOtc.DokumentON_DOK_TYPE.AsInteger=0) then begin
    Male:=false;
//    lNotRB_ON:=true;
  end;
  // ���� ���������� �������� �� ������� ��(1) � �� ��� �� ����������(2,3)
  if (AktUstOtc.DokumentONA_DOK_TYPE.AsInteger>3) or (AktUstOtc.DokumentONA_DOK_TYPE.AsInteger=0) then begin
    Female:=false;
//    lNotRB_ONA:=true;
  end;

  if TypeMessage='*'
    then TypeMessage:='0200';
  if Child and (AktUstOtc.DokumentIDENTIF.AsString='') then begin
    strError:='��������� ������������� ������';
  end;
  if Male and (AktUstOtc.DokumentON_IDENTIF.AsString='') then begin
    strError:='��������� ������������� ����';
  end;
  if FeMale and (AktUstOtc.DokumentONA_IDENTIF.AsString='') then begin
    strError:='��������� ������������� ������';
  end;
  if strError=''
    then Result:=true
    else Result:=false;
end;
{$ENDIF}

//---------------------------------------------------------------------------
procedure TGisun.CheckUstOtc(Simple: TfmSimpleD);
{$IFNDEF ADD_ZAGS}
begin
end;
{$ELSE}
const
  {$IFDEF GISUN2}
    CComponentName: array [1..61] of record
  {$ELSE}
    CComponentName: array [1..58] of record
  {$ENDIF}
      Name: string;
      Code: Integer;
      Color: TColor;
   end=(
     //1. ������
     (Name:'ENG_edIDENTIF'; Code: bChildId; Color: clDefault),
     //������������ ������
     (Name:'edFamiliaDo'; Code: bChild; Color: clDefault),
     (Name:'edNameDo'; Code: bChild; Color: clDefault),
     (Name:'edOtchDo'; Code: bChild; Color: clDefault),
     (Name:'BLR_edFamiliaDo'; Code: bChild; Color: clDefault),
     (Name:'BLR_edNameDo'; Code: bChild; Color: clDefault),
     (Name:'BLR_edOtchDo'; Code: bChild; Color: clDefault),
     (Name:'edDATER'; Code: bChildId; Color: clDefault),
     (Name:'edPOL'; Code: bChildId; Color: clDefault),
     //--GRAG
     //--STATUS
     //����� ��������
     (Name:'edGOSUD'; Code: bChild; Color: clDefault),
     (Name:'edB_OBL'; Code: bChild; Color: clDefault),
     (Name:'edOBL'; Code: bChild; Color: clDefault),
     (Name:'edRAION'; Code: bChild; Color: clDefault),
     (Name:'edB_GOROD'; Code: bChild; Color: clDefault),
     (Name:'edGOROD'; Code: bChild; Color: clDefault),
     //2. ����
     //������������ ������
     (Name:'ENG_edON_IDENTIF'; Code: bMale; Color: clDefault),
     (Name:'edON_Familia'; Code: bMale; Color: clDefault),
     (Name:'edON_NAME'; Code: bMale; Color: clDefault),
     (Name:'edON_OTCH'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_Familia'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_NAME'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_OTCH'; Code: bMale; Color: clDefault),
     (Name:'edON_DATER'; Code: bMale; Color: clDefault),
     (Name:'edON_GRAG'; Code: bMale; Color: clDefault),         //???
     //--ON_STATUS
     //���������� ������ (��������, �������������� ��������)
     (Name:'edON_DOK_TYPE'; Code: bMale; Color: clDefault),
     //--ON_DOK_ORGAN
     (Name:'edON_DOKUMENT'; Code: bMale; Color: clDefault),
     (Name:'edON_DOK_SERIA'; Code: bMale; Color: clDefault),
     (Name:'edON_DOK_NOMER'; Code: bMale; Color: clDefault),
     (Name:'edON_DOK_DATE'; Code: bMale; Color: clDefault),
     //����� ����������
     //����� ��������
     (Name:'edON_M_GOSUD'; Code: bMale; Color: clDefault),
     (Name:'edON_M_B_OBL'; Code: bMale; Color: clDefault),
     (Name:'edON_M_OBL'; Code: bMale; Color: clDefault),
     (Name:'edON_M_RAION'; Code: bMale; Color: clDefault),
     (Name:'edON_M_B_GOROD'; Code: bMale; Color: clDefault),
     (Name:'edON_M_GOROD'; Code: bMale; Color: clDefault),
     //3. ����
     //������������ ������
     (Name:'ENG_edONA_IDENTIF'; Code: bFemale; Color: clDefault),
     (Name:'edONA_Familia'; Code: bFemale; Color: clDefault),
     (Name:'edONA_NAME'; Code: bFemale; Color: clDefault),
     (Name:'edONA_OTCH'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_Familia'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_NAME'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_OTCH'; Code: bFemale; Color: clDefault),
     (Name:'edONA_DATER'; Code: bFemale; Color: clDefault),
     (Name:'edONA_GRAG'; Code: bFemale; Color: clDefault),           //???
     //--ONA_STATUS
     //���������� ������ (��������, �������������� ��������)
     (Name:'edONA_DOK_TYPE'; Code: bFemale; Color: clDefault),
     //--ONA_DOK_ORGAN
     (Name:'edONA_DOKUMENT'; Code: bFemale; Color: clDefault),
     (Name:'edONA_DOK_SERIA'; Code: bFemale; Color: clDefault),
     (Name:'edONA_DOK_NOMER'; Code: bFemale; Color: clDefault),
     (Name:'edONA_DOK_DATE'; Code: bFemale; Color: clDefault),
     //����� ����������
     //����� ��������
     (Name:'edONA_M_GOSUD'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_B_OBL'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_OBL'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_RAION'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_B_GOROD'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_GOROD'; Code: bFemale; Color: clDefault),
     {$IFDEF GISUN2}
//     (Name:'edONA_RNGOROD'; Code: bFemale; Color: clDefault),
//     (Name:'edON_RNGOROD'; Code: bMale; Color: clDefault),
     {$ENDIF}
     //====== ������������� ====
     (Name:'BLR_edON_Familia_B_Sv'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_Name_B_Sv'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_Otch_B_Sv'; Code: bMale; Color: clDefault),
      {
     (Name:'BLR_edONA_Familia_B_Sv'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_Name_B_Sv'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_Otch_B_Sv'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edFamiliaDo_B_Sv'; Code: bChild; Color: clDefault),
     (Name:'BLR_edNameDo_B_Sv'; Code: bChild; Color: clDefault),
     (Name:'BLR_edOtchDo_B_Sv'; Code: bChild; Color: clDefault),
     }
     (Name:'edON_Familia_Sv'; Code: bMale; Color: clDefault),
     (Name:'edON_Name_Sv'; Code: bMale; Color: clDefault),
     (Name:'edON_Otch_Sv'; Code: bMale; Color: clDefault)
     {
     (Name:'edONA_Familia_Sv'; Code: bFemale; Color: clDefault),
     (Name:'edONA_Name_Sv'; Code: bFemale; Color: clDefault),
     (Name:'edONA_Otch_Sv'; Code: bFemale; Color: clDefault),
     (Name:'edFamiliaDo_Sv'; Code: bChild; Color: clDefault),
     (Name:'edNameDo_Sv'; Code: bChild; Color: clDefault),
     (Name:'edOtchDo_Sv'; Code: bChild; Color: clDefault)
     }


   );

var
   Akt: TfmZapisUstOtc;
   PoleGrn: Integer;
   PoleGrnSub: Integer;
   I: Integer;
   Component: TComponent;
   Control: TControl;
   lDisable,l: Boolean;
begin
   Akt:=TfmZapisUstOtc(Simple);
   l:=(IsEnabled and IsEnableTypeAkt(dmBase.TypeObj_ZUstOtc,false));
   if l then begin
     PoleGrn:=GetPoleGrn(Akt.DokumentPOLE_GRN.AsInteger);
     PoleGrnSub:=GetPoleGrnSub(Akt.DokumentPOLE_GRN.AsInteger);
   end else begin
     PoleGrn:=0;
     PoleGrnSub:=0;
   end;
   //1. ������������ ����������� ������ [� ������ ������� �� ����� ��������]
   //TBItemStep1 - "��������� ������"
   //TBItemStep2 - "���������������� ������� ������"
   {
   if not IsDebug then begin
      case PoleGrn of
         //�� ���� ������ � ��� ��
         0: begin
            Akt.TBItemStep1.Enabled:=True;
            Akt.TBItemStep2.Enabled:=True;
         end;
         1:;
         //������� ����� �� ��� ��
         2: begin
            Akt.TBItemStep1.Enabled:=False;
            Akt.TBItemStep2.Enabled:=True;
         end;
         //���������� ������ �� ������� ������ � ��� ��
         3: begin
            Akt.TBItemStep1.Enabled:=False;
            Akt.TBItemStep2.Enabled:=False;
         end;
      end;
   end;
   }
   //2. ������������ ����������� ��������� ��������������
   //����� ��������� ������ �� ��� �� �������� �������������� ������ ����� ����������
   for I:=Low(CComponentName) to High(CComponentName) do begin
      Component:=Akt.FindComponent(CComponentName[I].Name);
      if (Component<>nil) and (Component is TControl) then begin
         Control:=TControl(Component);
         //2.1.
         if l
           then lDisable:=((PoleGrn=2) or (PoleGrn=3)) and ((PoleGrnSub and CComponentName[I].Code)=CComponentName[I].Code)
           else lDisable:=l;
         if lDisable and (PoleGrn=3) then begin
           lDisable:=false;
         end;
         //2.2.
         if lDisable then begin
            SetEnableControl(FTypeEnableControl,Control,false);
            //Control.Enabled:=False;
            if TxControl(Control).Color<>GetDisableColorGIS then begin
               CComponentName[I].Color:=TxControl(Control).Color;
            end;
            TxControl(Control).Color:=GetDisableColorGIS;
         end
         else begin
            if CComponentName[I].Color<>clDefault then begin
               TxControl(Control).Color:=CComponentName[I].Color;
            end;
            SetEnableControl(FTypeEnableControl,Control,true);
            //Control.Enabled:=True;
         end;
      end
      else begin
         ShowMessageC(CComponentName[I].Name);
      end;
   end;
end;
{$ENDIF}

//-------------------------------------------------------------------------------
function TGisun.GetUstOtc(Akt: TfmSimpleD): Boolean;
{$IFNDEF ADD_ZAGS}
begin
  Result:=false;
end;
{$ELSE}
var
  AktUstOtc : TfmZapisUstOtc;
  strError,strSOATO,strName : String;
  nAteID,PoleGrnSub,nType : Integer;
  ag:TGorodR;
  dDate:TDateTime;
begin
  Result:=false;
  AktUstOtc := TfmZapisUstOtc(Akt);
  AktUstOtc.Dokument.CheckBrowseMode;
  if not SetTypeMessageAktUstOtc( AktUstOtc, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end else begin
    ClearDataSets;
    if RunExchange then begin
      PoleGrnSub:=0;
      //[1] ������ ������
      //1. ������ ������� ��� �������� ������ � �������
      Input:=FRegInt.CreateInputTable(akAffiliation, opGet);
      //2. ��������� ������������ ������
      if ChildIdentif then begin
        //������
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=false;
        Input.FieldByName('PREFIX').AsString:='CHILD';
        Input.FieldByName('POL').AsString:= Code_Pol(AktUstOtc.DokumentPOL.AsString);
//        Input.FieldByName('DATER').AsString:=DTOS(AktUstOtc.DokumentDATER.AsDateTime,tdClipper);
        Input.FieldByName('DATER').AsString:=Code_Date(AktUstOtc.DokumentDATER.AsDateTime,DATE_FULL);
        Input.Post;
      end;
      //������
      if Child then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='CHILD';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktUstOtc.DokumentIDENTIF.AsString);
        Input.Post;
      end;
      //����
      if Male then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='ON';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktUstOtc.DokumentON_IDENTIF.AsString);
        Input.Post;
      end;
      //����
      if Female then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='ONA';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktUstOtc.DokumentONA_IDENTIF.AsString);
        Input.Post;
      end;
      //3. ��������� ������ � �������
      RequestResult:=RegInt.Get(akAffiliation, TypeMessage, Input, Output, Error);
      if IsDebug then begin
         RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_get.txt');
      end;
      if RequestResult=rrOk then begin
        Result:=true;
        AktUstOtc.Dokument.Edit;
        AktUstOtc.DokumentSTATUS.AsString  := '';
        AktUstOtc.DokumentON_STATUS.AsString  := '';
        AktUstOtc.DokumentONA_STATUS.AsString := '';
        AktUstOtc.DokumentTypeMessage.AsString:='';
        AktUstOtc.MessageID:=RegInt.RequestMessageId;  // �������� ID �������
        if ChildIdentif then begin
          if OutPut.Locate('PREFIX','CHILD',[]) then begin
            PoleGrnSub:=PoleGrnSub or bChildId;
            AktUstOtc.DokumentIDENTIF.AsString := OutPut.FieldByName('NEW_IDENTIF').AsString;
{!!!}       AktUstOtc.DokumentSTATUS.AsString := '1'; //������� ??? ������
          end;
        end;
        if Child then begin
          if OutPut.Locate('PREFIX','CHILD',[]) then begin
            PoleGrnSub:=PoleGrnSub or bChild or bChildId;
            //������������ ������
            AktUstOtc.DokumentIDENTIF.AsString     := OutPut.FieldByName('IDENTIF').AsString;
            AktUstOtc.DokumentFamiliaDo.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
            AktUstOtc.DokumentFamiliaDo_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
            AktUstOtc.DokumentNameDo.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
            AktUstOtc.DokumentNameDo_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
            AktUstOtc.DokumentOtchDo.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
            AktUstOtc.DokumentOtchDo_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);

//            AktUstOtc.DokumentDATER.AsDateTime   := STOD( OutPut.FieldByName('DATER').AsString, tdClipper);
            Decode_Date2(OutPut.FieldByName('DATER').AsString, dDate, nType);
            if dDate<>0
              then AktUstOtc.DokumentDATER.AsDateTime:=dDate;

            AktUstOtc.DokumentPOL.AsString   := Decode_Pol(OutPut.FieldByName('K_POL').AsString);
            if LoadGrag then
              AktUstOtc.DokumentGRAG.AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
            AktUstOtc.DokumentSTATUS.AsString := OutPut.FieldByName('K_STATUS').AsString;
            //����� ��������
            AktUstOtc.DokumentGOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString);

            DecodeObl_MestoRogd(AktUstOtc.Dokument,'OBL','B_OBL','',OutPut);
            //AktUstOtc.DokumentB_OBL.AsString:='';
            //AktUstOtc.DokumentOBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,'');

            AktUstOtc.DokumentRAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,'');

            DecodePunkt_MestoRogd(AktUstOtc.Dokument, 'B_GOROD', 'GOROD', '', OutPut);
            //AktUstOtc.DokumentB_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString);
            //AktUstOtc.DokumentGOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ � ������ ! ');
            Result:=false;
          end;
        end;
        if Result and Male then begin
          if OutPut.Locate('PREFIX','ON',[]) then begin
            if (OutPut.FieldByName('K_POL').AsString<>'') and (Decode_Pol(OutPut.FieldByName('K_POL').AsString)='�') then begin
              ShowMessageErr('� �������� �������������� ���� ������ ������������� ������� !');
              Result:=false;
            end else begin
              PoleGrnSub:=PoleGrnSub or bMale;
              //������������ ������
              AktUstOtc.DokumentON_IDENTIF.AsString   := OutPut.FieldByName('IDENTIF').AsString;
              AktUstOtc.DokumentON_Familia.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
              AktUstOtc.DokumentON_Familia_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
              AktUstOtc.DokumentON_NAME.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
              AktUstOtc.DokumentON_Name_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
              AktUstOtc.DokumentON_OTCH.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
              AktUstOtc.DokumentON_Otch_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);

              Decode_Date2(OutPut.FieldByName('DATER').AsString, dDate, nType);
              if dDate<>0
                then AktUstOtc.DokumentON_DATER.AsDateTime:=dDate;

              if LoadGrag then
                AktUstOtc.DokumentON_GRAG.AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
              AktUstOtc.DokumentON_STATUS.AsString := OutPut.FieldByName('K_STATUS').AsString;
              //���������� ������ (��������, �������������� ��������)
              AktUstOtc.DokumentON_DOK_TYPE.AsString:=Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString);
              AktUstOtc.DokumentON_DOK_ORGAN.AsString:=OutPut.FieldByName('K_DOC_ORGAN').AsString;
              AktUstOtc.DokumentON_DOKUMENT.AsString:=OutPut.FieldByName('N_DOC_ORGAN').AsString;
              AktUstOtc.DokumentON_DOK_SERIA.AsString:=OutPut.FieldByName('DOC_SERIA').AsString;
              AktUstOtc.DokumentON_DOK_NOMER.AsString:=OutPut.FieldByName('DOC_NOMER').AsString;
              AktUstOtc.DokumentON_DOK_DATE.AsDateTime:=OutPut.FieldByName('DOC_DATE').AsDateTime;
              //------------------����� ���������� ----------------------
              if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
                AktUstOtc.DokumentON_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');

                DecodeObl_MestoGit( AktUstOtc.Dokument,'ON_OBL','ON_B_OBL','',OutPut);
                //AktUstOtc.DokumentON_B_OBL.AsString:='';
                //AktUstOtc.DokumentON_OBL.AsString:=Decode_Obl(OutPut.FieldByName('N_OBL').AsString,'');

                AktUstOtc.DokumentON_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');

                DecodePunkt_MestoGit(AktUstOtc.Dokument, 'ON_B_GOROD', 'ON_GOROD', '', OutPut);
                //AktUstOtc.DokumentON_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD').AsString);
                //AktUstOtc.DokumentON_GOROD.AsString:=OutPut.FieldByName('N_GOROD').AsString;

// ����              AktUstOtc.DokumentON_GOROD_R.AsString:=GetGorodR(OutPut);
//--------- ����� --------
                ag:=GetGorodREx(OutPut);
                AktUstOtc.DokumentON_GOROD_R.AsString:=ag.Ulica;
                AktUstOtc.DokumentON_DOM.AsString:=ag.Dom;
                AktUstOtc.DokumentON_KORP.AsString:=ag.Korp;
                AktUstOtc.DokumentON_KV.AsString:=ag.Kv;
//------------------------
                {$IFDEF GISUN2}
                  AktUstOtc.DokumentON_RNGOROD.AsString:=Decode_RnGorod(OutPut, ['K_RN_GOROD','N_RN_GOROD'], strSoato);
                {$ENDIF}
              end;
              //-------------------����� �������� ------------------------
              AktUstOtc.DokumentON_M_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString);

              DecodeObl_MestoRogd( AktUstOtc.Dokument,'ON_M_OBL','ON_M_B_OBL','',OutPut);
              //AktUstOtc.DokumentON_M_B_OBL.AsString:='';
              //AktUstOtc.DokumentON_M_OBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,'');

              AktUstOtc.DokumentON_M_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,'');

              DecodePunkt_MestoRogd(AktUstOtc.Dokument, 'ON_M_B_GOROD', 'ON_M_GOROD', '', OutPut);
              //AktUstOtc.DokumentON_M_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString);
              //AktUstOtc.DokumentON_M_GOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString;

              if getSoato(OutPut, nAteID, strSoato, strName) then begin
                AktUstOtc.CheckSoatoAkt(true,false,true, '{SS}', nAteID, strSoato);
              end else begin
                AktUstOtc.CheckSoatoAkt(true,false,true, '{SS}', 0, ''); // ��� ������ ���� ��������� ��������
              end;

            end;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ �� ���� ! ');
            Result:=false;
          end;
        end;
        if Result and Female then begin
          if OutPut.Locate('PREFIX','ONA',[]) then begin
            if (OutPut.FieldByName('K_POL').AsString<>'') and (OutPut.FieldByName('K_POL').AsString='M') then begin
              ShowMessageErr('� �������� �������������� ������ ������ ������������� ������� !');
              Result:=false;
            end else begin
              PoleGrnSub:=PoleGrnSub or bFemale;
              //������������ ������
              AktUstOtc.DokumentONA_IDENTIF.AsString   := OutPut.FieldByName('IDENTIF').AsString;
              AktUstOtc.DokumentONA_Familia.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
              AktUstOtc.DokumentONA_Familia_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
              AktUstOtc.DokumentONA_NAME.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
              AktUstOtc.DokumentONA_Name_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
              AktUstOtc.DokumentONA_OTCH.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
              AktUstOtc.DokumentONA_Otch_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);

              Decode_Date2(OutPut.FieldByName('DATER').AsString, dDate, nType);
              if dDate<>0
                then AktUstOtc.DokumentONA_DATER.AsDateTime:=dDate;

              if LoadGrag then
                AktUstOtc.DokumentONA_GRAG.AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
              AktUstOtc.DokumentONA_STATUS.AsString := OutPut.FieldByName('K_STATUS').AsString;
              //���������� ������ (��������, �������������� ��������)
              AktUstOtc.DokumentONA_DOK_TYPE.AsString:=Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString);
              AktUstOtc.DokumentONA_DOK_ORGAN.AsString:=OutPut.FieldByName('K_DOC_ORGAN').AsString;
              AktUstOtc.DokumentONA_DOKUMENT.AsString:=OutPut.FieldByName('N_DOC_ORGAN').AsString;
              AktUstOtc.DokumentONA_DOK_SERIA.AsString:=OutPut.FieldByName('DOC_SERIA').AsString;
              AktUstOtc.DokumentONA_DOK_NOMER.AsString:=OutPut.FieldByName('DOC_NOMER').AsString;
              AktUstOtc.DokumentONA_DOK_DATE.AsDateTime:=OutPut.FieldByName('DOC_DATE').AsDateTime;
              //------------------����� ���������� --------------------
              if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
                AktUstOtc.DokumentONA_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');

                DecodeObl_MestoGit( AktUstOtc.Dokument,'ONA_OBL','ONA_B_OBL','',OutPut);
                //AktUstOtc.DokumentONA_B_OBL.AsString:='';
                //AktUstOtc.DokumentONA_OBL.AsString:=Decode_Obl(OutPut.FieldByName('N_OBL').AsString,'');

                AktUstOtc.DokumentONA_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');

                DecodePunkt_MestoGit(AktUstOtc.Dokument, 'ONA_B_GOROD', 'ONA_GOROD', '', OutPut);
                //AktUstOtc.DokumentONA_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD').AsString);
                //AktUstOtc.DokumentONA_GOROD.AsString:=OutPut.FieldByName('N_GOROD').AsString;

// ����              AktUstOtc.DokumentONA_GOROD_R.AsString:=GetGorodR(OutPut);
//--------- ����� --------
                ag:=GetGorodREx(OutPut);
                AktUstOtc.DokumentONA_GOROD_R.AsString:=ag.Ulica;
                AktUstOtc.DokumentONA_DOM.AsString:=ag.Dom;
                AktUstOtc.DokumentONA_KORP.AsString:=ag.Korp;
                AktUstOtc.DokumentONA_KV.AsString:=ag.Kv;
//------------------------
                {$IFDEF GISUN2}
                  AktUstOtc.DokumentONA_RNGOROD.AsString:=Decode_RnGorod(OutPut, ['K_RN_GOROD','N_RN_GOROD'], strSoato);
                {$ENDIF}
              end;
              //------------------����� �������� ------------------
              AktUstOtc.DokumentONA_M_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString);

              DecodeObl_MestoRogd( AktUstOtc.Dokument,'ONA_M_OBL','ONA_M_B_OBL','',OutPut);
              //AktUstOtc.DokumentONA_M_B_OBL.AsString:='';
              //AktUstOtc.DokumentONA_M_OBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,'');

              AktUstOtc.DokumentONA_M_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,'');

              DecodePunkt_MestoRogd(AktUstOtc.Dokument, 'ONA_M_B_GOROD', 'ONA_M_GOROD', '', OutPut);
              //AktUstOtc.DokumentONA_M_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString);
              //AktUstOtc.DokumentONA_M_GOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString;
            end;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ � ������ ! ');
            Result:=false;
          end;
        end;
        if not Result then begin
          //{!!!}
          //--AktUstOtc.DokumentIDENTIF.AsString := '';
          SetPoleGrn(AktUstOtc.DokumentPOLE_GRN, 0, 0);
        end else begin
//          AktUstOtc.CheckSoatoAkt(true,true,true);
          SetPoleGrn(AktUstOtc.DokumentPOLE_GRN, 2, PoleGrnSub);
          AktUstOtc.DokumentTypeMessage.AsString:=TypeMessage;
        end;
        AktUstOtc.Dokument.Post;
      end else begin
        HandleError(RequestResult, akAffiliation, opGet, Input, Output, Error, RegInt.FaultError);
      end;
      ClearDataSets;
    end;
  end;
end;
{$ENDIF}

//----------------------------------------------------------------------------------------------------------
function TGisun.RegisterUstOtc(Akt: TfmSimpleD): Boolean;
{$IFNDEF ADD_ZAGS}
begin
  Result:=false;
end;
{$ELSE}
var
  AktUstOtc : TfmZapisUstOtc;
  strError : String;
  lCheck:Boolean;
begin
  Result:=true;
  AktUstOtc := TfmZapisUstOtc(Akt);
  AktUstOtc.Dokument.CheckBrowseMode;
  if not SetTypeMessageAktUstOtc( AktUstOtc, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end;
  if Result then begin
    if (AktUstOtc.DokumentFamiliaPosle_B.AsString='') then begin
      strError:=strError+'��������� ������� ������� �� ����������� ����� ����� ������������ ���������'+#13#10;
    end;
    if (AktUstOtc.DokumentFamiliaPosle.AsString='') then begin
      strError:=strError+'��������� ������� ������� �� ������� ����� ����� ������������ ���������'+#13#10;
    end;
    if (AktUstOtc.DokumentNamePosle_B.AsString='') then begin
      strError:=strError+'��������� ��� ������� �� ����������� ����� ����� ������������ ���������'+#13#10;
    end;
    if (AktUstOtc.DokumentNamePosle.AsString='') then begin
      strError:=strError+'��������� ��� ������� �� ������� ����� ����� ������������ ���������'+#13#10;
    end;

    if AktUstOtc.DokumentOtchPosle.AsString<>'' then begin // ���� �������� �� ������� �� �����
      if (AktUstOtc.DokumentOtchPosle_B.AsString='') then begin
        strError:=strError+'��������� �������� ������� �� ����������� ����� ����� ������������ ���������'+#13#10;
      end;
    end;
//    if (AktUstOtc.DokumentOtchPosle.AsString='') then begin
//      strError:=strError+'��������� �������� ������� �� ������� ����� ����� ������������ ���������'+#13#10;
//    end;
    CheckAllAkt(AktUstOtc,strError);
    if strError<>'' then begin
      ShowMessageErr(strError);
      Result:=false;
    end;
  end;
  if Result then begin
    Result:=false;
    ClearDataSets;
    //[2] �������� ������
    //1. ������ ������� ��� �������� ������ � �������
    Input:=FRegInt.CreateInputTable(akAffiliation, opPost);
    //2. ��������� ������������ ������
    Input.Append;
    //���������� �� ���� � ��������
    Input.FieldByName('R_TIP').AsString:='0100'; //��� ������� ������
    Input.FieldByName('R_ORGAN').AsString:='0'; //MessageSource; //!!! ??? ���. �����, ������������� ������� ������
    Input.FieldByName('R_DATE').AsDateTime:=AktUstOtc.DokumentMestoDate.AsDateTime; //���� ������� ������
    Input.FieldByName('R_NOMER').AsString:=AktUstOtc.DokumentMestoNomer.AsString; //����� ������� ������
    //������������ ������ ���� �� ������������ ���������
    //������������ ������
    Input.FieldByName('DO_IDENTIF').AsString:=AktUstOtc.DokumentIDENTIF.AsString; //������������ �����
    Input.FieldByName('DO_FAMILIA').AsString:=G_UpperCase(AktUstOtc.DokumentFamiliaDo.AsString); //������� �� ������� �����
    Input.FieldByName('DO_FAMILIA_B').AsString:=G_UpperCase(AktUstOtc.DokumentFamiliaDo_B.AsString); //������� �� ����������� �����
    Input.FieldByName('DO_NAME').AsString:=G_UpperCase(AktUstOtc.DokumentNameDo.AsString); //��� �� ������� �����
    Input.FieldByName('DO_NAME_B').AsString:=G_UpperCase(AktUstOtc.DokumentNameDo_B.AsString); //��� �� ����������� �����
    Input.FieldByName('DO_OTCH').AsString:=G_UpperCase(AktUstOtc.DokumentOtchDo.AsString);
    Input.FieldByName('DO_OTCH_B').AsString:=G_UpperCase(AktUstOtc.DokumentOtchDo_B.AsString);
    Input.FieldByName('DO_POL').AsString:=Code_Pol(AktUstOtc.DokumentPol.AsString);
    Input.FieldByName('DO_DATER').AsString:=DTOS(AktUstOtc.DokumentDateR.AsDateTime,tdClipper); //���� ��������

// !!!   Input.FieldByName('DO_GRAJD').AsString:=Code_Alfa3(AktUstOtc.DokumentGRAG.AsString); // 'BLR' ??? �����������

    Input.FieldByName('DO_STATUS').AsString:=AktUstOtc.DokumentSTATUS.AsString; //������
    //------------����� �������� -----------------------
    Input.FieldByName('DO_GOSUD').AsString:=Code_Alfa3(AktUstOtc.DokumentGOSUD.AsString); //������ ��������

    CodeObl_MestoRogd( Akt.Dokument,'OBL','B_OBL','',Input,'DO_OBL','');
    //Input.FieldByName('DO_OBL').AsString:=AktUstOtc.DokumentOBL.AsString; //������� ��������

    Input.FieldByName('DO_RAION').AsString:=AktUstOtc.DokumentRAION.AsString; //����� ��������

    CodePunkt_MestoRogd(Akt.Dokument, 'B_GOROD','GOROD','',Input,'DO_TIP_GOROD','DO_GOROD','');
    //Input.FieldByName('DO_TIP_GOROD').AsString:=Code_TypePunkt(AktUstOtc.DokumentB_GOROD.AsString); //��� ���������� ������
    //Input.FieldByName('DO_GOROD').AsString:=AktUstOtc.DokumentGOROD.AsString; //��������� ����� �� ������� �����

    //������������ ������ ���� ����� ������������ ���������
    //������������ ������
    Input.FieldByName('PO_IDENTIF').AsString:=AktUstOtc.DokumentIDENTIF.AsString; //������������ �����
    Input.FieldByName('PO_FAMILIA').AsString:=G_UpperCase(AktUstOtc.DokumentFamiliaPosle.AsString); //������� �� ������� �����
    Input.FieldByName('PO_FAMILIA_B').AsString:=G_UpperCase(AktUstOtc.DokumentFamiliaPosle_B.AsString); //������� �� ����������� �����
    Input.FieldByName('PO_NAME').AsString:=G_UpperCase(AktUstOtc.DokumentNamePosle.AsString); //��� �� ������� �����
    Input.FieldByName('PO_NAME_B').AsString:=G_UpperCase(AktUstOtc.DokumentNamePosle_B.AsString); //��� �� ����������� �����
    Input.FieldByName('PO_OTCH').AsString:=G_UpperCase(AktUstOtc.DokumentOtchPosle.AsString);
    Input.FieldByName('PO_OTCH_B').AsString:=G_UpperCase(AktUstOtc.DokumentOtchPosle_B.AsString);
    Input.FieldByName('PO_POL').AsString:=Code_Pol(AktUstOtc.DokumentPol.AsString);
    Input.FieldByName('PO_DATER').AsString:=DTOS(AktUstOtc.DokumentDateR.AsDateTime,tdClipper); //���� ��������

// !!!   Input.FieldByName('PO_GRAJD').AsString:=Code_Alfa3(AktUstOtc.DokumentGRAG.AsString); //'BLR' ??? �����������

    Input.FieldByName('PO_STATUS').AsString:=AktUstOtc.DokumentSTATUS.AsString; //������
    //-------------����� �������� -----------------
    Input.FieldByName('PO_GOSUD').AsString:=Code_Alfa3(AktUstOtc.DokumentGOSUD.AsString); //������ ��������

    CodeObl_MestoRogd( Akt.Dokument,'OBL','B_OBL','',Input,'PO_OBL','');
    //Input.FieldByName('PO_OBL').AsString:=AktUstOtc.DokumentOBL.AsString; //������� ��������

    Input.FieldByName('PO_RAION').AsString:=AktUstOtc.DokumentRAION.AsString; //����� ��������

    CodePunkt_MestoRogd(Akt.Dokument, 'B_GOROD','GOROD','',Input,'PO_TIP_GOROD','PO_GOROD','');
    //Input.FieldByName('PO_TIP_GOROD').AsString:=Code_TypePunkt(AktUstOtc.DokumentB_GOROD.AsString); //��� ���������� ������
    //Input.FieldByName('PO_GOROD').AsString:=AktUstOtc.DokumentGOROD.AsString; //��������� ����� �� ������� �����

//    if Female then begin
      //------------------������������ ������ ������--------------
      Input.FieldByName('ONA_IDENTIF').AsString:=AktUstOtc.DokumentONA_IDENTIF.AsString; //������������ �����
      Input.FieldByName('ONA_FAMILIA').AsString:=AktUstOtc.Dokument.FieldByName('ONA_FAMILIA').AsString; //������� �� ������� �����
      Input.FieldByName('ONA_FAMILIA_B').AsString:=AktUstOtc.Dokument.FieldByName('ONA_FAMILIA_B').AsString; //������� �� ����������� �����
      Input.FieldByName('ONA_NAME').AsString:=AktUstOtc.Dokument.FieldByName('ONA_NAME').AsString; //��� �� ������� �����
      Input.FieldByName('ONA_NAME_B').AsString:=AktUstOtc.Dokument.FieldByName('ONA_NAME_B').AsString; //��� �� ����������� �����
      Input.FieldByName('ONA_OTCH').AsString:=AktUstOtc.Dokument.FieldByName('ONA_OTCH').AsString; //�������� �� ������� �����
      Input.FieldByName('ONA_OTCH_B').AsString:=AktUstOtc.Dokument.FieldByName('ONA_OTCH_B').AsString; //�������� �� ����������� �����
      Input.FieldByName('ONA_POL').AsString:='F'; //���
      Input.FieldByName('ONA_DATER').AsString:=DTOS(AktUstOtc.DokumentONA_DATER.AsDateTime,tdClipper); //���� ��������
      Input.FieldByName('ONA_GRAJD').AsString:=Code_Alfa3(AktUstOtc.DokumentONA_GRAG.AsString); //�����������

//      Input.FieldByName('ONA_STATUS').AsString:=AktUstOtc.Dokument.FieldByName('ONA_STATUS').AsString; //������
      Input.FieldByName('ONA_STATUS').AsString:=Code_Status(AktUstOtc.Dokument, 'ONA_GRAG', 'ONA_STATUS');

      //����� ��������
      Input.FieldByName('ONA_GOSUD').AsString:=Code_Alfa3(AktUstOtc.DokumentONA_M_GOSUD.AsString); //������ ��������

      CodeObl_MestoRogd( AktUstOtc.Dokument,'ONA_M_OBL','ONA_M_B_OBL','',Input,'ONA_OBL','');
      //Input.FieldByName('ONA_OBL').AsString:=AktUstOtc.DokumentONA_M_OBL.AsString; //������� ��������

      Input.FieldByName('ONA_RAION').AsString:=AktUstOtc.DokumentONA_M_RAION.AsString; //����� ��������

      CodePunkt_MestoRogd(AktUstOtc.Dokument, 'ONA_M_B_GOROD','ONA_M_GOROD','',Input,'ONA_TIP_GOROD','ONA_GOROD','');
      //Input.FieldByName('ONA_TIP_GOROD').AsString:=Code_TypePunkt(AktUstOtc.DokumentONA_M_B_GOROD.AsString); //��� ���������� ������
      //Input.FieldByName('ONA_GOROD').AsString:=AktUstOtc.DokumentONA_M_GOROD.AsString; //��������� ����� �� ������� �����
//    end;
//    if Male then begin
      //------------------------������������ ������ ����-------------------
      Input.FieldByName('ON_IDENTIF').AsString:=AktUstOtc.Dokument.FieldByName('ON_IDENTIF').AsString; //������������ �����
      Input.FieldByName('ON_FAMILIA').AsString:=AktUstOtc.Dokument.FieldByName('ON_FAMILIA').AsString; //������� �� ������� �����
      Input.FieldByName('ON_FAMILIA_B').AsString:=AktUstOtc.Dokument.FieldByName('ON_FAMILIA_B').AsString; //������� �� ����������� �����
      Input.FieldByName('ON_NAME').AsString:=AktUstOtc.Dokument.FieldByName('ON_NAME').AsString; //��� �� ������� �����
      Input.FieldByName('ON_NAME_B').AsString:=AktUstOtc.Dokument.FieldByName('ON_NAME_B').AsString; //��� �� ����������� �����
      Input.FieldByName('ON_OTCH').AsString:=AktUstOtc.Dokument.FieldByName('ON_OTCH').AsString; //�������� �� ������� �����
      Input.FieldByName('ON_OTCH_B').AsString:=AktUstOtc.Dokument.FieldByName('ON_OTCH_B').AsString; //�������� �� ����������� �����
      Input.FieldByName('ON_POL').AsString:='M'; //���
      Input.FieldByName('ON_GRAJD').AsString:=Code_Alfa3(AktUstOtc.DokumentON_GRAG.AsString); //�����������
      Input.FieldByName('ON_DATER').AsString:=DTOS(AktUstOtc.DokumentON_DATER.AsDateTime,tdClipper); //���� ��������

//      Input.FieldByName('ON_STATUS').AsString:=AktUstOtc.Dokument.FieldByName('ON_STATUS').AsString; //������
      Input.FieldByName('ON_STATUS').AsString:=Code_Status(AktUstOtc.Dokument, 'ON_GRAG', 'ON_STATUS');

      //---------����� �������� ---------
      Input.FieldByName('ON_GOSUD').AsString:=Code_Alfa3(AktUstOtc.DokumentON_M_GOSUD.AsString); //������ ��������

      CodeObl_MestoRogd( AktUstOtc.Dokument,'ON_M_OBL','ON_M_B_OBL','',Input,'ON_OBL','');
      //Input.FieldByName('ON_OBL').AsString:=AktUstOtc.DokumentON_M_OBL.AsString; //������� ��������

      Input.FieldByName('ON_RAION').AsString:=AktUstOtc.DokumentON_M_RAION.AsString; //����� ��������

      CodePunkt_MestoRogd(AktUstOtc.Dokument, 'ON_M_B_GOROD','ON_M_GOROD','',Input,'ON_TIP_GOROD','ON_GOROD','');
      //Input.FieldByName('ON_TIP_GOROD').AsString:=Code_TypePunkt(AktUstOtc.DokumentON_M_B_GOROD.AsString); //��� ���������� ������
      //Input.FieldByName('ON_GOROD').AsString:=AktUstOtc.DokumentON_M_GOROD.AsString; //��������� ����� �� ������� �����
//    end;
    //��������� ������ ���� �� ������������ ��������� - ������� ����
    if AktUstOtc.DokumentOSNOV.AsInteger=2 then begin //������� ����
      Input.FieldByName('SUD_NAME').AsString:=AktUstOtc.DokumentReshSud.AsString; //������������ ����
      Input.FieldByName('SUD_DATE').AsString:=DTOS(AktUstOtc.DokumentDateDecl.AsDateTime,tdClipper); //���� ��������� �������
      Input.FieldByName('SUD_COMM').AsString:=''; //??? ����������� � ��������� ������ ����
    end;
    //���������� �� ������� ������
    Input.FieldByName('ACT_TIP').AsString:=TypeAkt; //��� ������� ������
    SetOrganAkt(AktUstOtc, Input);
    Input.FieldByName('ACT_DATE').AsDateTime:=AktUstOtc.Dokument.FieldByName('DATEZ').AsDateTime; //���� ������� ������
    Input.FieldByName('ACT_NOMER').AsString:=AktUstOtc.Dokument.FieldByName('NOMER').AsString; //����� ������� ������

    //----------- ���������� � �������� ��������� (������������� ��� ������) --------------------
    if Trim(AktUstOtc.DokumentSVID_NOMER.AsString)<>'' then begin
      SetDokSvid(AktUstOtc, Input, 'DOC_ONA_');
    end;

    lCheck:=false;
    //���������� � �������� ��������� (������������� ��� ����)
    if AktUstOtc.DokumentTWO_SVID.AsBoolean then begin // ���� ���� ������ ��� �������������
      if Trim(AktUstOtc.DokumentSVID_NOMER2.AsString)<>'' then lCheck:=true;
    end else begin
      if Trim(AktUstOtc.DokumentSVID_NOMER.AsString)<>''  then lCheck:=true;
    end;
    if lCheck then begin
      if AktUstOtc.DokumentTWO_SVID.AsBoolean then begin // ���� ���� ������ ��� �������������
//        SetDokSvid(AktUstOtc, Input, 'DOC_ON_', ????? datesv2 ?????);
        Input.FieldByName('DOC_ON_TIP').AsString:=DOK_SVID_USTOTC; //��� ��������� ������������ ���������
        Input.FieldByName('DOC_ON_ORGAN').AsString:=MessageSource; //���. �����, �������� ��������
        Input.FieldByName('DOC_ON_DATE').AsDateTime:=AktUstOtc.DokumentDATESV2.AsDateTime; //���� ������
        Input.FieldByName('DOC_ON_SERIA').AsString:=AktUstOtc.DokumentSVID_SERIA2.AsString; //����� ���������
        Input.FieldByName('DOC_ON_NOMER').AsString:=AktUstOtc.DokumentSVID_NOMER2.AsString; //����� ���������
      end else begin
        SetDokSvid(AktUstOtc, Input, 'DOC_ON_');   // � ���� ���� �������������, ��� � � ����
      end;
    end;

    Input.Post;
    //3. ��������� ������ � �������
    RequestResult:=RegInt.Post(AktUstOtc.MessageID, akAffiliation, AktUstOtc.DokumentTypeMessage.AsString, Input, Error);
    LogToTableLog(AktUstOtc, '����������� �/� �� ���.���������');
    if IsDebug then begin
       RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_post.txt');
    end;
    if RequestResult=rrOk then begin
      AktUstOtc.Dokument.CheckBrowseMode;
      AktUstOtc.Dokument.Edit;
      SetPoleGrn(AktUstOtc.DokumentPOLE_GRN, 3);
      AktUstOtc.Dokument.Post;
      if not HandleErrorToString
        then ShowMessageCont(GetMessageOk,CurAkt);
      Result:=true;
    end else begin
      Result:=false;
      //4.2. ������������ ������ �������������� � ���������
      HandleError(RequestResult, akAffiliation, opGet, Input, Output, Error, FRegInt.FaultError);
    end;
  end;
end;
{$ENDIF}

//=======================================================================
// ������������ �����������
function TGisun.SetTypeMessageAktUstMat(Akt: TfmSimpleD; var strError: String): Boolean;
{$IFDEF ZAGS}
var
  AktUstMat : TfmZapisUstMat;
{$ENDIF}
begin
  result:=false;
{$IFDEF ZAGS}
  AktUstMat := TfmZapisUstMat(Akt);
  AktUstMat.Dokument.CheckBrowseMode;
  strError:='';
  TypeAkt := '92';
  {
  if AktUstMat.DokumentON_IDENTIF.AsString='' then begin
    if (AktUstMat.DokumentON_GRAG.AsString<>MY_GRAG_STR) then begin
      strError:='�� ��������� �� ����� ����� ������� ��';
      exit;
    end;
    // ���� ���� ��������� �� ������� ��, � ��� ��������� ��
    if (AktUstMat.DokumentON_DOK_TYPE.AsInteger<>1) and (AktUstMat.DokumentON_GRAG.AsString=MY_GRAG_STR) then begin
      strError:='��������� �� ������ ����� ������� ��';
      exit;
    end;
  end;

  if AktUstMat.DokumentONA_IDENTIF.AsString='' then begin
    // ���� ���� ���������� ������� ��, � ���� �� ��������� ��
    if (AktUstMat.DokumentONA_DOK_TYPE.AsInteger=1) and (AktUstMat.DokumentONA_GRAG.AsString<>MY_GRAG_STR) then begin
      strError:='�� ��������� �� ����� ����� ������� ��';
      exit;
    end;
    //  ���� ���� ��������� �� ������� ��, � ��� ��������� ��
    if (AktUstMat.DokumentONA_DOK_TYPE.AsInteger<>1) and (AktUstMat.DokumentONA_GRAG.AsString=MY_GRAG_STR) then begin
      strError:='��������� �� ������ ����� ������� ��';
      exit;
    end;
  end;
  }

  Child:=true;  // ����� ������ � �������

//  if AktUstMat.DokumentCHILD.AsBoolean
//    then Child:=true   // ����� ������ �� �������
//    else Child:=false;

  Female:=true;  // ����� ������ � ����
  Male:=true;    // ����� ������ � ����
  ChildIdentif:=false; // ����� �� ��� �������
  RunExchange:=true;  // ��������� ������������� ��� ���
  DefaultPoleGrn:=0;  // �������� ��� ���� POLE_GRN ���� �� ���� ������������ ��������������

  //----- !!! ----------------- �� � ������� ������ ������������ ������ 09.12.2011  ��������� ��������
  TypeMessage:=USTMAT_MESSAGE_TYPE; // 0800  '92';
  ChildIdentif:=false;
  //-----------------------

  if AktUstMat.DokumentIDENTIF.AsString='' then begin
    Child:=false;
  end;
  if AktUstMat.DokumentON_IDENTIF.AsString='' then begin
    Male:=false;
  end;
  // ���� ���������� �������� �� ������� ��(1) � �� ��� �� ����������(2,3)
  if AktUstMat.DokumentONA_IDENTIF.AsString='' then begin
    Female:=false;
  end;

  if strError=''
    then Result:=true
    else Result:=false;
{$ENDIF}
end;

//---------------------------------------------------------------------------
procedure TGisun.CheckUstMat(Simple: TfmSimpleD);
const
  {$IFDEF GISUN2}
    CComponentName: array [1..45] of record
  {$ELSE}
    CComponentName: array [1..42] of record
  {$ENDIF}
      Name: string;
      Code: Integer;
      Color: TColor;
   end=(
     //1. ������
     (Name:'ENG_edIDENTIF'; Code: bChildId; Color: clDefault),
     //������������ ������
     (Name:'edFamiliaDo'; Code: bChild; Color: clDefault),
     (Name:'edNameDo'; Code: bChild; Color: clDefault),
     (Name:'edOtchDo'; Code: bChild; Color: clDefault),
     (Name:'BLR_edFamiliaDo'; Code: bChild; Color: clDefault),
     (Name:'BLR_edNameDo'; Code: bChild; Color: clDefault),
     (Name:'BLR_edOtchDo'; Code: bChild; Color: clDefault),
     (Name:'edDATER'; Code: bChildId; Color: clDefault),
     (Name:'edPOL'; Code: bChildId; Color: clDefault),
     //--GRAG
     //--STATUS
     //����� ��������
     (Name:'edGOSUD'; Code: bChild; Color: clDefault),
     (Name:'edB_OBL'; Code: bChild; Color: clDefault),
     (Name:'edOBL'; Code: bChild; Color: clDefault),
     (Name:'edRAION'; Code: bChild; Color: clDefault),
     (Name:'edB_GOROD'; Code: bChild; Color: clDefault),
     (Name:'edGOROD'; Code: bChild; Color: clDefault),
     //2. ����
     //������������ ������
     (Name:'ENG_edON_IDENTIF'; Code: bMale; Color: clDefault),
     (Name:'edON_Familia'; Code: bMale; Color: clDefault),
     (Name:'edON_NAME'; Code: bMale; Color: clDefault),
     (Name:'edON_OTCH'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_Familia'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_NAME'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_OTCH'; Code: bMale; Color: clDefault),
     (Name:'edON_DATER'; Code: bMale; Color: clDefault),
     (Name:'edON_GRAG'; Code: bMale; Color: clDefault),         //???
     //--ON_STATUS
     //���������� ������ (��������, �������������� ��������)
//     (Name:'edON_DOK_TYPE'; Code: bMale; Color: clDefault),
     //--ON_DOK_ORGAN
//     (Name:'edON_DOKUMENT'; Code: bMale; Color: clDefault),
//     (Name:'edON_DOK_SERIA'; Code: bMale; Color: clDefault),
//     (Name:'edON_DOK_NOMER'; Code: bMale; Color: clDefault),
//     (Name:'edON_DOK_DATE'; Code: bMale; Color: clDefault),
     //����� ����������
     {
     (Name:'edON_B_RESP'; Code: bMale; Color: clDefault),
     (Name:'edON_GOSUD'; Code: bMale; Color: clDefault),
     (Name:'edON_B_OBL'; Code: bMale; Color: clDefault),
     (Name:'edON_OBL'; Code: bMale; Color: clDefault),
     (Name:'edON_RAION'; Code: bMale; Color: clDefault),
     (Name:'edON_B_GOROD'; Code: bMale; Color: clDefault),
     (Name:'edON_GOROD'; Code: bMale; Color: clDefault),
     (Name:'edON_GOROD_R'; Code: bMale; Color: clDefault),
     (Name:'edON_DOM'; Code: bMale; Color: clDefault),
     (Name:'edON_KORP'; Code: bMale; Color: clDefault),
     (Name:'edON_KV'; Code: bMale; Color: clDefault),
     }
     //����� ��������
     (Name:'edON_M_GOSUD'; Code: bMale; Color: clDefault),
     (Name:'edON_M_B_OBL'; Code: bMale; Color: clDefault),
     (Name:'edON_M_OBL'; Code: bMale; Color: clDefault),
     (Name:'edON_M_RAION'; Code: bMale; Color: clDefault),
     (Name:'edON_M_B_GOROD'; Code: bMale; Color: clDefault),
     (Name:'edON_M_GOROD'; Code: bMale; Color: clDefault),
     //3. ����
     //������������ ������
     (Name:'ENG_edONA_IDENTIF'; Code: bFemale; Color: clDefault),
     (Name:'edONA_Familia'; Code: bFemale; Color: clDefault),
     (Name:'edONA_NAME'; Code: bFemale; Color: clDefault),
     (Name:'edONA_OTCH'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_Familia'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_NAME'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_OTCH'; Code: bFemale; Color: clDefault),
     (Name:'edONA_DATER'; Code: bFemale; Color: clDefault),
     (Name:'edONA_GRAG'; Code: bFemale; Color: clDefault),           //???
     //--ONA_STATUS
     //���������� ������ (��������, �������������� ��������)
//     (Name:'edONA_DOK_TYPE'; Code: bFemale; Color: clDefault),
     //--ONA_DOK_ORGAN
//     (Name:'edONA_DOKUMENT'; Code: bFemale; Color: clDefault),
//     (Name:'edONA_DOK_SERIA'; Code: bFemale; Color: clDefault),
//     (Name:'edONA_DOK_NOMER'; Code: bFemale; Color: clDefault),
//     (Name:'edONA_DOK_DATE'; Code: bFemale; Color: clDefault),
     //����� ����������
     {
     (Name:'edONA_B_RESP'; Code: bFemale; Color: clDefault),
     (Name:'edONA_GOSUD'; Code: bFemale; Color: clDefault),
     (Name:'edONA_B_OBL'; Code: bFemale; Color: clDefault),
     (Name:'edONA_OBL'; Code: bFemale; Color: clDefault),
     (Name:'edONA_RAION'; Code: bFemale; Color: clDefault),
     (Name:'edONA_B_GOROD'; Code: bFemale; Color: clDefault),
     (Name:'edONA_GOROD'; Code: bFemale; Color: clDefault),
     (Name:'edONA_GOROD_R'; Code: bFemale; Color: clDefault),
     (Name:'edONA_DOM'; Code: bFemale; Color: clDefault),
     (Name:'edONA_KORP'; Code: bFemale; Color: clDefault),
     (Name:'edONA_KV'; Code: bFemale; Color: clDefault),
     }
     //����� ��������
     (Name:'edONA_M_GOSUD'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_B_OBL'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_OBL'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_RAION'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_B_GOROD'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_GOROD'; Code: bFemale; Color: clDefault)
     {$IFDEF GISUN2}
//     (Name:'edONA_RNGOROD'; Code: bFemale; Color: clDefault),
//     (Name:'edON_RNGOROD'; Code: bMale; Color: clDefault),
     {$ENDIF}
     //====== ������������� ====
//     (Name:'BLR_edON_Familia_B_Sv'; Code: bMale; Color: clDefault),
//     (Name:'BLR_edON_Name_B_Sv'; Code: bMale; Color: clDefault),
//     (Name:'BLR_edON_Otch_B_Sv'; Code: bMale; Color: clDefault),
      {
     (Name:'BLR_edONA_Familia_B_Sv'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_Name_B_Sv'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_Otch_B_Sv'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edFamiliaDo_B_Sv'; Code: bChild; Color: clDefault),
     (Name:'BLR_edNameDo_B_Sv'; Code: bChild; Color: clDefault),
     (Name:'BLR_edOtchDo_B_Sv'; Code: bChild; Color: clDefault),
     }
//     (Name:'edON_Familia_Sv'; Code: bMale; Color: clDefault),
//     (Name:'edON_Name_Sv'; Code: bMale; Color: clDefault),
//     (Name:'edON_Otch_Sv'; Code: bMale; Color: clDefault)
     {
     (Name:'edONA_Familia_Sv'; Code: bFemale; Color: clDefault),
     (Name:'edONA_Name_Sv'; Code: bFemale; Color: clDefault),
     (Name:'edONA_Otch_Sv'; Code: bFemale; Color: clDefault),
     (Name:'edFamiliaDo_Sv'; Code: bChild; Color: clDefault),
     (Name:'edNameDo_Sv'; Code: bChild; Color: clDefault),
     (Name:'edOtchDo_Sv'; Code: bChild; Color: clDefault)
     }


   );
{$IFDEF ZAGS}
var
   Akt: TfmZapisUstMat;
   PoleGrn: Integer;
   PoleGrnSub: Integer;
   I: Integer;
   Component: TComponent;
   Control: TControl;
   lDisable,l: Boolean;
{$ENDIF}
begin
{$IFDEF ZAGS}
   Akt:=TfmZapisUstMat(Simple);
   l:=(IsEnabled and IsEnableTypeAkt(dmBase.TypeObj_ZUstMat,false));
   if l then begin
     PoleGrn:=GetPoleGrn(Akt.DokumentPOLE_GRN.AsInteger);
     PoleGrnSub:=GetPoleGrnSub(Akt.DokumentPOLE_GRN.AsInteger);
   end else begin
     PoleGrn:=0;
     PoleGrnSub:=0;
   end;
   //1. ������������ ����������� ������ [� ������ ������� �� ����� ��������]
   //TBItemStep1 - "��������� ������"
   //TBItemStep2 - "���������������� ������� ������"
   {
   if not IsDebug then begin
      case PoleGrn of
         //�� ���� ������ � ��� ��
         0: begin
            Akt.TBItemStep1.Enabled:=True;
            Akt.TBItemStep2.Enabled:=True;
         end;
         1:;
         //������� ����� �� ��� ��
         2: begin
            Akt.TBItemStep1.Enabled:=False;
            Akt.TBItemStep2.Enabled:=True;
         end;
         //���������� ������ �� ������� ������ � ��� ��
         3: begin
            Akt.TBItemStep1.Enabled:=False;
            Akt.TBItemStep2.Enabled:=False;
         end;
      end;
   end;
   }
   //2. ������������ ����������� ��������� ��������������
   //����� ��������� ������ �� ��� �� �������� �������������� ������ ����� ����������
   for I:=Low(CComponentName) to High(CComponentName) do begin
      Component:=Akt.FindComponent(CComponentName[I].Name);
      if (Component<>nil) and (Component is TControl) then begin
         Control:=TControl(Component);
         //2.1.
         if l
           then lDisable:=((PoleGrn=2) or (PoleGrn=3)) and ((PoleGrnSub and CComponentName[I].Code)=CComponentName[I].Code)
           else lDisable:=l;
         if lDisable and (PoleGrn=3) then begin
           lDisable:=false;
         end;
         //2.2.
         if lDisable then begin
            SetEnableControl(FTypeEnableControl,Control,false);
            //Control.Enabled:=False;
            if TxControl(Control).Color<>GetDisableColorGIS then begin
               CComponentName[I].Color:=TxControl(Control).Color;
            end;
            TxControl(Control).Color:=GetDisableColorGIS;
         end
         else begin
            if CComponentName[I].Color<>clDefault then begin
               TxControl(Control).Color:=CComponentName[I].Color;
            end;
            SetEnableControl(FTypeEnableControl,Control,true);
            //Control.Enabled:=True;
         end;
      end
      else begin
         ShowMessageC(CComponentName[I].Name);
      end;
   end;
{$ENDIF}
end;

//-------------------------------------------------------------------------------
function TGisun.GetUstMat(Akt: TfmSimpleD): Boolean;
{$IFDEF ZAGS}
var
  AktUstMat : TfmZapisUstMat;
  strError,strSOATO : String;
  PoleGrnSub,nType : Integer;
  ag:TGorodR;
  dDate:TDateTime;
{$ENDIF}
begin
  Result:=false;
{$IFDEF ZAGS}
  AktUstMat := TfmZapisUstMat(Akt);
  AktUstMat.Dokument.CheckBrowseMode;
  if not SetTypeMessageAktUstMat( AktUstMat, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end else begin
    ClearDataSets;
    if RunExchange then begin
      PoleGrnSub:=0;
      //[1] ������ ������
      //1. ������ ������� ��� �������� ������ � �������
      Input:=FRegInt.CreateInputTable(akAffiliation, opGet);
      //2. ��������� ������������ ������
      if ChildIdentif then begin
        //������
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=false;
        Input.FieldByName('PREFIX').AsString:='CHILD';
        Input.FieldByName('POL').AsString:= Code_Pol(AktUstMat.DokumentPOL.AsString);
//        Input.FieldByName('DATER').AsString:=DTOS(AktUstMat.DokumentDATER.AsDateTime,tdClipper);
        Input.FieldByName('DATER').AsString:=Code_Date(AktUstMat.DokumentDATER.AsDateTime,DATE_FULL);
        Input.Post;
      end;
      //������
      if Child then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='CHILD';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktUstMat.DokumentIDENTIF.AsString);
        Input.Post;
      end;
      //����
      if Male then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='ON';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktUstMat.DokumentON_IDENTIF.AsString);
        Input.Post;
      end;
      //����
      if Female then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='ONA';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktUstMat.DokumentONA_IDENTIF.AsString);
        Input.Post;
      end;
      //3. ��������� ������ � �������
      RequestResult:=RegInt.Get(akAffiliation, TypeMessage, Input, Output, Error);
      if IsDebug then begin
         RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_get.txt');
      end;
      if RequestResult=rrOk then begin
        Result:=true;
        AktUstMat.Dokument.Edit;
        AktUstMat.DokumentSTATUS.AsString  := '';
        AktUstMat.DokumentON_STATUS.AsString  := '';
        AktUstMat.DokumentONA_STATUS.AsString := '';
        AktUstMat.DokumentTypeMessage.AsString:='';
        AktUstMat.MessageID:=RegInt.RequestMessageId;  // �������� ID �������
        if ChildIdentif then begin
          if OutPut.Locate('PREFIX','CHILD',[]) then begin
            PoleGrnSub:=PoleGrnSub or bChildId;
            AktUstMat.DokumentIDENTIF.AsString := OutPut.FieldByName('NEW_IDENTIF').AsString;
{!!!}       AktUstMat.DokumentSTATUS.AsString := '1'; //������� ??? ������
          end;
        end;
        if Child then begin
          //------------ ������� ----------------------------------------------
          if OutPut.Locate('PREFIX','CHILD',[]) then begin
            PoleGrnSub:=PoleGrnSub or bChild or bChildId;
            //������������ ������
            AktUstMat.DokumentIDENTIF.AsString     := OutPut.FieldByName('IDENTIF').AsString;
            AktUstMat.DokumentFamiliaDo.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
            AktUstMat.DokumentFamiliaDo_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
            AktUstMat.DokumentNameDo.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
            AktUstMat.DokumentNameDo_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
            AktUstMat.DokumentOtchDo.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
            AktUstMat.DokumentOtchDo_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);

            Decode_Date2(OutPut.FieldByName('DATER').AsString, dDate, nType);
            if dDate<>0
              then AktUstMat.DokumentDATER.AsDateTime:=dDate;

            AktUstMat.DokumentPOL.AsString   := Decode_Pol(OutPut.FieldByName('K_POL').AsString);
            if LoadGrag then
              AktUstMat.DokumentGRAG.AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
            AktUstMat.DokumentSTATUS.AsString := OutPut.FieldByName('K_STATUS').AsString;
            //------------------����� �������� -------------------------
            AktUstMat.DokumentGOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString);
            DecodeObl_MestoRogd(AktUstMat.Dokument,'OBL','B_OBL','',OutPut);
            AktUstMat.DokumentRAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,'');
            DecodePunkt_MestoRogd(AktUstMat.Dokument, 'B_GOROD', 'GOROD', '', OutPut);
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ � ������ ! ');
            Result:=false;
          end;
        end;
        if Result and Male then begin
          if OutPut.Locate('PREFIX','ON',[]) then begin
            if (OutPut.FieldByName('K_POL').AsString<>'') and (Decode_Pol(OutPut.FieldByName('K_POL').AsString)='�') then begin
              ShowMessageErr('� �������� �������������� ���� ������ ������������� ������� !');
              Result:=false;
            end else begin
              PoleGrnSub:=PoleGrnSub or bMale;
              //������������ ������
              AktUstMat.DokumentON_IDENTIF.AsString   := OutPut.FieldByName('IDENTIF').AsString;
              AktUstMat.DokumentON_Familia.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
              AktUstMat.DokumentON_Familia_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
              AktUstMat.DokumentON_NAME.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
              AktUstMat.DokumentON_Name_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
              AktUstMat.DokumentON_OTCH.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
              AktUstMat.DokumentON_Otch_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);

              Decode_Date2(OutPut.FieldByName('DATER').AsString, dDate, nType);
              if dDate<>0
                then AktUstMat.DokumentON_DATER.AsDateTime:=dDate;

              if LoadGrag then
                AktUstMat.DokumentON_GRAG.AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
              AktUstMat.DokumentON_STATUS.AsString := OutPut.FieldByName('K_STATUS').AsString;
              //-------------------����� �������� ------------------------
              AktUstMat.DokumentON_M_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString);
              DecodeObl_MestoRogd( AktUstMat.Dokument,'ON_M_OBL','ON_M_B_OBL','',OutPut);
              AktUstMat.DokumentON_M_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,'');
              DecodePunkt_MestoRogd(AktUstMat.Dokument, 'ON_M_B_GOROD', 'ON_M_GOROD', '', OutPut);
            end;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ �� ���� ! ');
            Result:=false;
          end;
        end;

          { ??? ���������� ������ ���������  ???

              AktUstMat.DokumentON_DOK_TYPE.AsString:=Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString);
              AktUstMat.DokumentON_DOK_ORGAN.AsString:=OutPut.FieldByName('K_DOC_ORGAN').AsString;
              AktUstMat.DokumentON_DOKUMENT.AsString:=OutPut.FieldByName('N_DOC_ORGAN').AsString;
              AktUstMat.DokumentON_DOK_SERIA.AsString:=OutPut.FieldByName('DOC_SERIA').AsString;
              AktUstMat.DokumentON_DOK_NOMER.AsString:=OutPut.FieldByName('DOC_NOMER').AsString;
              AktUstMat.DokumentON_DOK_DATE.AsDateTime:=OutPut.FieldByName('DOC_DATE').AsDateTime;
          }

        if Result and Female then begin
          if OutPut.Locate('PREFIX','ONA',[]) then begin
            if (OutPut.FieldByName('K_POL').AsString<>'') and (OutPut.FieldByName('K_POL').AsString='M') then begin
              ShowMessageErr('� �������� �������������� ������ ������ ������������� ������� !');
              Result:=false;
            end else begin
              PoleGrnSub:=PoleGrnSub or bFemale;
              //������������ ������
              AktUstMat.DokumentONA_IDENTIF.AsString   := OutPut.FieldByName('IDENTIF').AsString;
              AktUstMat.DokumentONA_Familia.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
              AktUstMat.DokumentONA_Familia_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
              AktUstMat.DokumentONA_NAME.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
              AktUstMat.DokumentONA_Name_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
              AktUstMat.DokumentONA_OTCH.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
              AktUstMat.DokumentONA_Otch_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);

              Decode_Date2(OutPut.FieldByName('DATER').AsString, dDate, nType);
              if dDate<>0
                then AktUstMat.DokumentONA_DATER.AsDateTime:=dDate;

              if LoadGrag then
                AktUstMat.DokumentONA_GRAG.AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
              AktUstMat.DokumentONA_STATUS.AsString := OutPut.FieldByName('K_STATUS').AsString;
              //------------------����� ���������� --------------------
              if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
                AktUstMat.DokumentONA_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');
                DecodeObl_MestoGit( AktUstMat.Dokument,'ONA_OBL','ONA_B_OBL','',OutPut);
                AktUstMat.DokumentONA_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');
                DecodePunkt_MestoGit(AktUstMat.Dokument, 'ONA_B_GOROD', 'ONA_GOROD', '', OutPut);
                AktUstMat.DokumentONA_GOROD_R.AsString:=GetGorodR(OutPut);
              end;
              //------------------����� �������� ------------------
              AktUstMat.DokumentONA_M_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString);
              DecodeObl_MestoRogd( AktUstMat.Dokument,'ONA_M_OBL','ONA_M_B_OBL','',OutPut);
              AktUstMat.DokumentONA_M_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,'');
              DecodePunkt_MestoRogd(AktUstMat.Dokument, 'ONA_M_B_GOROD', 'ONA_M_GOROD', '', OutPut);
            end;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ � ������ ! ');
            Result:=false;
          end;
        end;
        if not Result then begin
          //{!!!}
          //--AktUstMat.DokumentIDENTIF.AsString := '';
          SetPoleGrn(AktUstMat.DokumentPOLE_GRN, 0, 0);
        end else begin
          SetPoleGrn(AktUstMat.DokumentPOLE_GRN, 2, PoleGrnSub);
          AktUstMat.DokumentTypeMessage.AsString:=TypeMessage;
        end;
        AktUstMat.Dokument.Post;
      end else begin
        HandleError(RequestResult, akAffiliation, opGet, Input, Output, Error, RegInt.FaultError);
      end;
      ClearDataSets;
    end;
  end;
{$ENDIF}
end;
//----------------------------------------------------------------------------------------------------------
function TGisun.RegisterUstMat(Akt: TfmSimpleD): Boolean;
{$IFDEF ZAGS}
var
  AktUstMat : TfmZapisUstMat;
  strError : String;
{$ENDIF}
begin
  Result:=true;
{$IFDEF ZAGS}
  AktUstMat := TfmZapisUstMat(Akt);
  AktUstMat.Dokument.CheckBrowseMode;
  if not SetTypeMessageAktUstMat( AktUstMat, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end;
  if Result then begin
    if (AktUstMat.DokumentFamiliaPosle_B.AsString='') then begin
      strError:=strError+'��������� ������� ������� �� ����������� ����� ����� ������������ ���������'+#13#10;
    end;
    if (AktUstMat.DokumentFamiliaPosle.AsString='') then begin
      strError:=strError+'��������� ������� ������� �� ������� ����� ����� ������������ ���������'+#13#10;
    end;
    if (AktUstMat.DokumentNamePosle_B.AsString='') then begin
      strError:=strError+'��������� ��� ������� �� ����������� ����� ����� ������������ ���������'+#13#10;
    end;
    if (AktUstMat.DokumentNamePosle.AsString='') then begin
      strError:=strError+'��������� ��� ������� �� ������� ����� ����� ������������ ���������'+#13#10;
    end;

    if AktUstMat.DokumentOtchPosle.AsString<>'' then begin // ���� �������� �� ������� �� �����
      if (AktUstMat.DokumentOtchPosle_B.AsString='') then begin
        strError:=strError+'��������� �������� ������� �� ����������� ����� ����� ������������ ���������'+#13#10;
      end;
    end;
//    if (AktUstMat.DokumentOtchPosle.AsString='') then begin
//      strError:=strError+'��������� �������� ������� �� ������� ����� ����� ������������ ���������'+#13#10;
//    end;
    CheckAllAkt(AktUstMat,strError);
    if strError<>'' then begin
      ShowMessageErr(strError);
      Result:=false;
    end;
  end;
  if Result then begin
    Result:=false;
    ClearDataSets;
    //[2] �������� ������
    //1. ������ ������� ��� �������� ������ � �������
    Input:=FRegInt.CreateInputTable(akAffiliation, opPost);
    //2. ��������� ������������ ������
    Input.Append;
    //���������� �� ���� � ��������
    Input.FieldByName('R_TIP').AsString:='0100'; //��� ������� ������
    Input.FieldByName('R_ORGAN').AsString:='0'; //MessageSource; //!!! ??? ���. �����, ������������� ������� ������
    Input.FieldByName('R_DATE').AsDateTime:=AktUstMat.DokumentMestoDate.AsDateTime; //���� ������� ������
    Input.FieldByName('R_NOMER').AsString:=AktUstMat.DokumentMestoNomer.AsString; //����� ������� ������
    //������������ ������ ���� �� ������������ �����������
    //������������ ������
    Input.FieldByName('DO_IDENTIF').AsString:=AktUstMat.DokumentIDENTIF.AsString; //������������ �����
    Input.FieldByName('DO_FAMILIA').AsString:=G_UpperCase(AktUstMat.DokumentFamiliaDo.AsString); //������� �� ������� �����
    Input.FieldByName('DO_FAMILIA_B').AsString:=G_UpperCase(AktUstMat.DokumentFamiliaDo_B.AsString); //������� �� ����������� �����
    Input.FieldByName('DO_NAME').AsString:=G_UpperCase(AktUstMat.DokumentNameDo.AsString); //��� �� ������� �����
    Input.FieldByName('DO_NAME_B').AsString:=G_UpperCase(AktUstMat.DokumentNameDo_B.AsString); //��� �� ����������� �����
    Input.FieldByName('DO_OTCH').AsString:=G_UpperCase(AktUstMat.DokumentOtchDo.AsString);
    Input.FieldByName('DO_OTCH_B').AsString:=G_UpperCase(AktUstMat.DokumentOtchDo_B.AsString);
    Input.FieldByName('DO_POL').AsString:=Code_Pol(AktUstMat.DokumentPol.AsString);
    Input.FieldByName('DO_DATER').AsString:=DTOS(AktUstMat.DokumentDateR.AsDateTime,tdClipper); //���� ��������
//    Input.FieldByName('DO_GRAJD').AsString:='BLR'; //  ??? �����������
//    Input.FieldByName('DO_GRAJD').AsString:=Code_Alfa3(AktUstMat.DokumentGRAG.AsString); // 'BLR' ??? �����������
    Input.FieldByName('DO_STATUS').AsString:=AktUstMat.DokumentSTATUS.AsString; //������
    //------------����� �������� -----------------------
    Input.FieldByName('DO_GOSUD').AsString:=Code_Alfa3(AktUstMat.DokumentGOSUD.AsString); //������ ��������

    CodeObl_MestoRogd( Akt.Dokument,'OBL','B_OBL','',Input,'DO_OBL','');
    //Input.FieldByName('DO_OBL').AsString:=AktUstMat.DokumentOBL.AsString; //������� ��������

    Input.FieldByName('DO_RAION').AsString:=AktUstMat.DokumentRAION.AsString; //����� ��������

    CodePunkt_MestoRogd(Akt.Dokument, 'B_GOROD','GOROD','',Input,'DO_TIP_GOROD','DO_GOROD','');
    //Input.FieldByName('DO_TIP_GOROD').AsString:=Code_TypePunkt(AktUstMat.DokumentB_GOROD.AsString); //��� ���������� ������
    //Input.FieldByName('DO_GOROD').AsString:=AktUstMat.DokumentGOROD.AsString; //��������� ����� �� ������� �����

    //������������ ������ ���� ����� ������������ �����������
    //������������ ������
    Input.FieldByName('PO_IDENTIF').AsString:=AktUstMat.DokumentIDENTIF.AsString; //������������ �����
    Input.FieldByName('PO_FAMILIA').AsString:=G_UpperCase(AktUstMat.DokumentFamiliaPosle.AsString); //������� �� ������� �����
    Input.FieldByName('PO_FAMILIA_B').AsString:=G_UpperCase(AktUstMat.DokumentFamiliaPosle_B.AsString); //������� �� ����������� �����
    Input.FieldByName('PO_NAME').AsString:=G_UpperCase(AktUstMat.DokumentNamePosle.AsString); //��� �� ������� �����
    Input.FieldByName('PO_NAME_B').AsString:=G_UpperCase(AktUstMat.DokumentNamePosle_B.AsString); //��� �� ����������� �����
    Input.FieldByName('PO_OTCH').AsString:=G_UpperCase(AktUstMat.DokumentOtchPosle.AsString);
    Input.FieldByName('PO_OTCH_B').AsString:=G_UpperCase(AktUstMat.DokumentOtchPosle_B.AsString);
    Input.FieldByName('PO_POL').AsString:=Code_Pol(AktUstMat.DokumentPol.AsString);
    Input.FieldByName('PO_DATER').AsString:=DTOS(AktUstMat.DokumentDateR.AsDateTime,tdClipper); //���� ��������
//    Input.FieldByName('PO_GRAJD').AsString:='BLR'; // ??? �����������
//    Input.FieldByName('PO_GRAJD').AsString:=Code_Alfa3(AktUstMat.DokumentGRAG.AsString); //'BLR' ??? �����������
    Input.FieldByName('PO_STATUS').AsString:=AktUstMat.DokumentSTATUS.AsString; //������
    //-------------����� �������� -----------------
    Input.FieldByName('PO_GOSUD').AsString:=Code_Alfa3(AktUstMat.DokumentGOSUD.AsString); //������ ��������

    CodeObl_MestoRogd( Akt.Dokument,'OBL','B_OBL','',Input,'PO_OBL','');
    //Input.FieldByName('PO_OBL').AsString:=AktUstMat.DokumentOBL.AsString; //������� ��������

    Input.FieldByName('PO_RAION').AsString:=AktUstMat.DokumentRAION.AsString; //����� ��������

    CodePunkt_MestoRogd(Akt.Dokument, 'B_GOROD','GOROD','',Input,'PO_TIP_GOROD','PO_GOROD','');
    //Input.FieldByName('PO_TIP_GOROD').AsString:=Code_TypePunkt(AktUstMat.DokumentB_GOROD.AsString); //��� ���������� ������
    //Input.FieldByName('PO_GOROD').AsString:=AktUstMat.DokumentGOROD.AsString; //��������� ����� �� ������� �����

//    if Female then begin
      //------------------������������ ������ ������--------------
      Input.FieldByName('ONA_IDENTIF').AsString:=AktUstMat.DokumentONA_IDENTIF.AsString; //������������ �����
      Input.FieldByName('ONA_FAMILIA').AsString:=AktUstMat.Dokument.FieldByName('ONA_FAMILIA').AsString; //������� �� ������� �����
      Input.FieldByName('ONA_FAMILIA_B').AsString:=AktUstMat.Dokument.FieldByName('ONA_FAMILIA_B').AsString; //������� �� ����������� �����
      Input.FieldByName('ONA_NAME').AsString:=AktUstMat.Dokument.FieldByName('ONA_NAME').AsString; //��� �� ������� �����
      Input.FieldByName('ONA_NAME_B').AsString:=AktUstMat.Dokument.FieldByName('ONA_NAME_B').AsString; //��� �� ����������� �����
      Input.FieldByName('ONA_OTCH').AsString:=AktUstMat.Dokument.FieldByName('ONA_OTCH').AsString; //�������� �� ������� �����
      Input.FieldByName('ONA_OTCH_B').AsString:=AktUstMat.Dokument.FieldByName('ONA_OTCH_B').AsString; //�������� �� ����������� �����
      Input.FieldByName('ONA_POL').AsString:='F'; //���
      Input.FieldByName('ONA_DATER').AsString:=DTOS(AktUstMat.DokumentONA_DATER.AsDateTime,tdClipper); //���� ��������
      Input.FieldByName('ONA_GRAJD').AsString:=Code_Alfa3(AktUstMat.DokumentONA_GRAG.AsString); //�����������

//      Input.FieldByName('ONA_STATUS').AsString:=AktUstMat.Dokument.FieldByName('ONA_STATUS').AsString; //������
      Input.FieldByName('ONA_STATUS').AsString:=Code_Status(AktUstMat.Dokument, 'ONA_GRAG', 'ONA_STATUS');

      //����� ��������
      Input.FieldByName('ONA_GOSUD').AsString:=Code_Alfa3(AktUstMat.DokumentONA_M_GOSUD.AsString); //������ ��������

      CodeObl_MestoRogd( AktUstMat.Dokument,'ONA_M_OBL','ONA_M_B_OBL','',Input,'ONA_OBL','');
      //Input.FieldByName('ONA_OBL').AsString:=AktUstMat.DokumentONA_M_OBL.AsString; //������� ��������

      Input.FieldByName('ONA_RAION').AsString:=AktUstMat.DokumentONA_M_RAION.AsString; //����� ��������

      CodePunkt_MestoRogd(AktUstMat.Dokument, 'ONA_M_B_GOROD','ONA_M_GOROD','',Input,'ONA_TIP_GOROD','ONA_GOROD','');
      //Input.FieldByName('ONA_TIP_GOROD').AsString:=Code_TypePunkt(AktUstMat.DokumentONA_M_B_GOROD.AsString); //��� ���������� ������
      //Input.FieldByName('ONA_GOROD').AsString:=AktUstMat.DokumentONA_M_GOROD.AsString; //��������� ����� �� ������� �����
//    end;
//    if Male then begin
      //------------------------������������ ������ ����-------------------
      Input.FieldByName('ON_IDENTIF').AsString:=AktUstMat.Dokument.FieldByName('ON_IDENTIF').AsString; //������������ �����
      Input.FieldByName('ON_FAMILIA').AsString:=AktUstMat.Dokument.FieldByName('ON_FAMILIA').AsString; //������� �� ������� �����
      Input.FieldByName('ON_FAMILIA_B').AsString:=AktUstMat.Dokument.FieldByName('ON_FAMILIA_B').AsString; //������� �� ����������� �����
      Input.FieldByName('ON_NAME').AsString:=AktUstMat.Dokument.FieldByName('ON_NAME').AsString; //��� �� ������� �����
      Input.FieldByName('ON_NAME_B').AsString:=AktUstMat.Dokument.FieldByName('ON_NAME_B').AsString; //��� �� ����������� �����
      Input.FieldByName('ON_OTCH').AsString:=AktUstMat.Dokument.FieldByName('ON_OTCH').AsString; //�������� �� ������� �����
      Input.FieldByName('ON_OTCH_B').AsString:=AktUstMat.Dokument.FieldByName('ON_OTCH_B').AsString; //�������� �� ����������� �����
      Input.FieldByName('ON_POL').AsString:='M'; //���
      Input.FieldByName('ON_GRAJD').AsString:=Code_Alfa3(AktUstMat.DokumentON_GRAG.AsString); //�����������
      Input.FieldByName('ON_DATER').AsString:=DTOS(AktUstMat.DokumentON_DATER.AsDateTime,tdClipper); //���� ��������

//      Input.FieldByName('ON_STATUS').AsString:=AktUstMat.Dokument.FieldByName('ON_STATUS').AsString; //������
      Input.FieldByName('ON_STATUS').AsString:=Code_Status(AktUstMat.Dokument, 'ON_GRAG', 'ON_STATUS');

      //---------����� �������� ---------
      Input.FieldByName('ON_GOSUD').AsString:=Code_Alfa3(AktUstMat.DokumentON_M_GOSUD.AsString); //������ ��������

      CodeObl_MestoRogd( AktUstMat.Dokument,'ON_M_OBL','ON_M_B_OBL','',Input,'ON_OBL','');
      //Input.FieldByName('ON_OBL').AsString:=AktUstMat.DokumentON_M_OBL.AsString; //������� ��������

      Input.FieldByName('ON_RAION').AsString:=AktUstMat.DokumentON_M_RAION.AsString; //����� ��������

      CodePunkt_MestoRogd(AktUstMat.Dokument, 'ON_M_B_GOROD','ON_M_GOROD','',Input,'ON_TIP_GOROD','ON_GOROD','');
      //Input.FieldByName('ON_TIP_GOROD').AsString:=Code_TypePunkt(AktUstMat.DokumentON_M_B_GOROD.AsString); //��� ���������� ������
      //Input.FieldByName('ON_GOROD').AsString:=AktUstMat.DokumentON_M_GOROD.AsString; //��������� ����� �� ������� �����
//    end;
    //��������� ������ ���� �� ������������ ��������� - ������� ����
    if AktUstMat.DokumentOSNOV.AsInteger=2 then begin //������� ����
      Input.FieldByName('SUD_NAME').AsString:=AktUstMat.DokumentReshSud.AsString; //������������ ����
      Input.FieldByName('SUD_DATE').AsString:=DTOS(AktUstMat.DokumentDateDecl.AsDateTime,tdClipper); //���� ��������� �������
      Input.FieldByName('SUD_COMM').AsString:=''; //??? ����������� � ��������� ������ ����
    end;
    //���������� �� ������� ������
    Input.FieldByName('ACT_TIP').AsString:=TypeAkt; //��� ������� ������
    SetOrganAkt(AktUstMat, Input);
    Input.FieldByName('ACT_DATE').AsDateTime:=AktUstMat.Dokument.FieldByName('DATEZ').AsDateTime; //���� ������� ������
    Input.FieldByName('ACT_NOMER').AsString:=AktUstMat.Dokument.FieldByName('NOMER').AsString; //����� ������� ������
    //??? ����� ��� �������������

    //���������� � �������� ��������� (������������� ��� ������)
    if Trim(AktUstMat.DokumentSVID_NOMER.AsString)<>'' then begin
      SetDokSvid(AktUstMat, Input, 'DOC_ONA_');
    end else begin
      Input.FieldByName('DOC_ONA_DATE').AsVariant:=null;
    end;

    //���������� � �������� ��������� (������������� ��� ����)
    if Trim(AktUstMat.DokumentSVID_NOMER.AsString)<>'' then begin
      SetDokSvid(AktUstMat, Input, 'DOC_ON_');
    end else begin
      Input.FieldByName('DOC_ON_DATE').AsVariant:=null;
    end;

    Input.Post;
    //3. ��������� ������ � �������
    RequestResult:=RegInt.Post(AktUstMat.MessageID, akAffiliation, USTMAT_MESSAGE_TYPE, Input, Error);
//!!!    RequestResult:=RegInt.Post(AktUstMat.MessageID, akAffiliation, AktUstMat.DokumentTypeMessage.AsString, Input, Error);
    LogToTableLog(AktUstMat, '����������� �/� �� ���.�����������');
    if IsDebug then begin
       RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_post.txt');
    end;
    if RequestResult=rrOk then begin
      AktUstMat.Dokument.CheckBrowseMode;
      AktUstMat.Dokument.Edit;
      SetPoleGrn(AktUstMat.DokumentPOLE_GRN, 3);
      AktUstMat.DokumentTYPEMESSAGE.AsString:=USTMAT_MESSAGE_TYPE;
      AktUstMat.Dokument.Post;
      if not HandleErrorToString
        then ShowMessageCont(GetMessageOk,CurAkt);
      Result:=true;
    end else begin
      Result:=false;
      //4.2. ������������ ������ �������������� � ���������
      HandleError(RequestResult, akAffiliation, opGet, Input, Output, Error, FRegInt.FaultError);
    end;
  end;
{$ENDIF}
end;

//========================================================================
//  end ������������ ����������
//========================================================================


//--------------------------------------------------------------------------
{
procedure TGisun.DataSetAllFieldUpper(ds:TDataSet);
var
  i:Integer;
begin
  if ds<>nil then begin
    ds.Edit;
    for i:=0 to ds.FieldCount-1 do begin
      if ds.Fields[i].DataType=ftString then begin
        ds.Fields[i].AsString:=ANSIUpperCase(ds.Fields[i].AsString);
      end;
    end;
    ds.Post;
  end;
end;
}
//--------------------------------------------------------------------------
// ����������� ����������� �����
function TGisun.RegisterRastBrak(Akt: TfmSimpleD): Boolean;
{$IFDEF ZAGS}
var
  AktRastBrak : TfmRastBrak;
  strError,s : String;
{$ENDIF}
begin
  Result:=true;
{$IFDEF ZAGS}
  AktRastBrak := TfmRastBrak(Akt);
  AktRastBrak.Dokument.CheckBrowseMode;

  CheckAllAkt(AktRastBrak,strError);
  if strError<>'' then begin
    ShowMessageErr(strError);
    Result:=false;
  end;

  if Result then begin
    if not SetTypeMessageAktRastBrak( AktRastBrak, strError) then begin
      ShowMessageErr(strError);
      Result:=false;
    end else begin
      ClearDataSets;
      //[2] �������� ������
      //1. ������ ������� ��� �������� ������ � �������
      Input:=FRegInt.CreateInputTable(akDivorce, opPost);
      //2. ��������� ������������ ������
      Input.Append;
   //   if Female then begin
        //------------------������������ ������ ����----------------------
        Input.FieldByName('ONA_IDENTIF').AsString:=AktRastBrak.DokumentONA_IDENTIF.AsString; //������������ �����
        Input.FieldByName('ONA_FAMILIA').AsString:=G_UpperCase(AktRastBrak.Dokument.FieldByName('ONA_FAMILIAP').AsString); //������� �� ������� �����
        Input.FieldByName('ONA_FAMILIA_B').AsString:=G_UpperCase(AktRastBrak.Dokument.FieldByName('ONA_FAMILIAP_B').AsString); //������� �� ����������� �����
        Input.FieldByName('ONA_NAME').AsString:=G_UpperCase(AktRastBrak.Dokument.FieldByName('ONA_NAME').AsString); //��� �� ������� �����
        Input.FieldByName('ONA_NAME_B').AsString:=G_UpperCase(AktRastBrak.Dokument.FieldByName('ONA_NAME_B').AsString); //��� �� ����������� �����
        Input.FieldByName('ONA_OTCH').AsString:=G_UpperCase(AktRastBrak.Dokument.FieldByName('ONA_OTCH').AsString); //�������� �� ������� �����
        Input.FieldByName('ONA_OTCH_B').AsString:=G_UpperCase(AktRastBrak.Dokument.FieldByName('ONA_OTCH_B').AsString); //�������� �� ����������� �����
        Input.FieldByName('ONA_POL').AsString:='F'; //���
        Input.FieldByName('ONA_DATER').AsString:=DTOS(AktRastBrak.DokumentONA_DATER.AsDateTime,tdClipper); //���� ��������
        Input.FieldByName('ONA_DATER').AsString:=Code_Date(AktRastBrak.DokumentONA_DATER.AsDateTime, AktRastBrak.DokumentONA_ONLYGOD);
        Input.FieldByName('ONA_GRAJD').AsString:=Code_Alfa3(AktRastBrak.DokumentONA_GRAG.AsString); //�����������

  //      Input.FieldByName('ONA_STATUS').AsString:=AktRastBrak.Dokument.FieldByName('ONA_STATUS').AsString; //������
        Input.FieldByName('ONA_STATUS').AsString:=Code_Status(AktRastBrak.Dokument, 'ONA_GRAG', 'ONA_STATUS');

        //--------------����� �������� -------------------------------
        Input.FieldByName('ONA_GOSUD').AsString:=Code_Alfa3(AktRastBrak.DokumentONA_GOSUD.AsString); //������ ��������

        CodeObl_MestoRogd( AktRastBrak.Dokument,'ONA_OBL','ONA_B_OBL','',Input,'ONA_OBL','');
        //Input.FieldByName('ONA_OBL').AsString:=AktRastBrak.DokumentONA_OBL.AsString; //������� ��������

        Input.FieldByName('ONA_RAION').AsString:=AktRastBrak.DokumentONA_RAION.AsString; //����� ��������

        CodePunkt_MestoRogd(Akt.Dokument, 'ONA_B_GOROD','ONA_GOROD','',Input,'ONA_TIP_GOROD','ONA_GOROD','');
        //Input.FieldByName('ONA_TIP_GOROD').AsString:=Code_TypePunkt(AktRastBrak.DokumentONA_B_GOROD.AsString); //��� ���������� ������ ��������
        //Input.FieldByName('ONA_GOROD').AsString:=AktRastBrak.DokumentONA_GOROD.AsString; //��������� ����� �� ������� �����

        //������� �� ����������� �����
        Input.FieldByName('ONA_FAMILIA_OLD').AsString:=G_UpperCase(AktRastBrak.Dokument.FieldByName('ONA_FAMILIA').AsString); //������� �� �����
  //    end;
  //    if Male then begin
        //----------------------������������ ������ ����------------------------
        Input.FieldByName('ON_IDENTIF').AsString:=AktRastBrak.Dokument.FieldByName('ON_IDENTIF').AsString; //������������ �����
        Input.FieldByName('ON_FAMILIA').AsString:=G_UpperCase(AktRastBrak.Dokument.FieldByName('ON_FAMILIAP').AsString); //������� �� ������� �����
        Input.FieldByName('ON_FAMILIA_B').AsString:=G_UpperCase(AktRastBrak.Dokument.FieldByName('ON_FAMILIAP_B').AsString); //������� �� ����������� �����
        Input.FieldByName('ON_NAME').AsString:=G_UpperCase(AktRastBrak.Dokument.FieldByName('ON_NAME').AsString); //��� �� ������� �����
        Input.FieldByName('ON_NAME_B').AsString:=G_UpperCase(AktRastBrak.Dokument.FieldByName('ON_NAME_B').AsString); //��� �� ����������� �����
        Input.FieldByName('ON_OTCH').AsString:=G_UpperCase(AktRastBrak.Dokument.FieldByName('ON_OTCH').AsString); //�������� �� ������� �����
        Input.FieldByName('ON_OTCH_B').AsString:=G_UpperCase(AktRastBrak.Dokument.FieldByName('ON_OTCH_B').AsString); //�������� �� ����������� �����
        Input.FieldByName('ON_POL').AsString:='M'; //���
        Input.FieldByName('ON_GRAJD').AsString:=Code_Alfa3(AktRastBrak.DokumentON_GRAG.AsString); //�����������
        Input.FieldByName('ON_DATER').AsString:=Code_Date(AktRastBrak.DokumentON_DATER.AsDateTime, AktRastBrak.DokumentON_ONLYGOD);

  //      Input.FieldByName('ON_STATUS').AsString:=AktRastBrak.Dokument.FieldByName('ON_STATUS').AsString; //������
        Input.FieldByName('ON_STATUS').AsString:=Code_Status(AktRastBrak.Dokument, 'ON_GRAG', 'ON_STATUS');

        //------------------ ����� �������� ------------------------------------
        Input.FieldByName('ON_GOSUD').AsString:=Code_Alfa3(AktRastBrak.DokumentON_GOSUD.AsString); //������ ��������

        CodeObl_MestoRogd( AktRastBrak.Dokument,'ON_OBL','ON_B_OBL','',Input,'ON_OBL','');
        //Input.FieldByName('ON_OBL').AsString:=AktRastBrak.DokumentON_OBL.AsString; //������� ��������

        Input.FieldByName('ON_RAION').AsString:=AktRastBrak.DokumentON_RAION.AsString; //����� ��������

        CodePunkt_MestoRogd(AktRastBrak.Dokument, 'ON_B_GOROD','ON_GOROD','',Input,'ON_TIP_GOROD','ON_GOROD','');
        //Input.FieldByName('ON_TIP_GOROD').AsString:=Code_TypePunkt(AktRastBrak.DokumentON_B_GOROD.AsString); //��� ���������� ������ ��������
        //Input.FieldByName('ON_GOROD').AsString:=AktRastBrak.DokumentON_GOROD.AsString; //��������� ����� �� ������� �����

        //������� �� ����������� �����
        Input.FieldByName('ON_FAMILIA_OLD').AsString:=G_UpperCase(AktRastBrak.Dokument.FieldByName('ON_FAMILIA').AsString); //������� �� �����
  //    end;
      //���������� �� ���� � ����������� �����
      //???
      {
      Input.FieldByName('BRAK_TIP').AsString:=; //��� ������� ������
      Input.FieldByName('BRAK_ORGAN').AsString:=; //���. �����, ������������� ������� ������
      Input.FieldByName('BRAK_DATE').AsDateTime:=; //���� ������� ������
      Input.FieldByName('BRAK_NOMER').AsString:=; //����� ������� ������
      }
      //��������� ������ ���� � ����������� �����  - ������� ����
      Input.FieldByName('SUD_NAME').AsString:=AktRastBrak.DokumentSUD_NAME.AsString; //������������ ����
      Input.FieldByName('SUD_DATE').AsString:=DTOS(AktRastBrak.DokumentSUD_DATE.AsDateTime,tdClipper); //���� ��������� �������
      Input.FieldByName('SUD_COMM').AsString:=''; //����������� � ��������� ������ ����
      //���������� �� ������� ������
      Input.FieldByName('ACT_TIP').AsString:=TypeAkt; //��� ������� ������
      SetOrganAkt(AktRastBrak, Input);
      Input.FieldByName('ACT_DATE').AsDateTime:=AktRastBrak.Dokument.FieldByName('DATEZ').AsDateTime; //���� ������� ������
      Input.FieldByName('ACT_NOMER').AsString:=AktRastBrak.Dokument.FieldByName('NOMER').AsString; //����� ������� ������

      //------- ��������� ������������� ---------------
      if AktRastBrak.DokumentPOVTOR.AsBoolean then begin
        s:='';
        if AktRastBrak.FOnlySvid then begin  // ������� ����� �������������
          if AktRastBrak.DokumentWHO_SVID.AsString='�' then s:='ONA_';
          if AktRastBrak.DokumentWHO_SVID.AsString='�' then s:='ON_';
        end else begin                      // �� ������� ������
          if AktRastBrak.SvidPovtorWHO_SVID.AsString='�' then s:='ONA_';
          if AktRastBrak.SvidPovtorWHO_SVID.AsString='�' then s:='ON_';
        end;
        if AktRastBrak.FOnlySvid then begin  // ������� ����� �������������
          if (s<>'') and (Trim(AktRastBrak.DokumentSVID_NOMER.AsString)<>'') then begin
            Input.FieldByName(s+'TIP').AsString:=DOK_SVID_RAST; //��� ��������� ����������� �����
            Input.FieldByName(s+'ORGAN').AsString:=MessageSource; //���. �����, �������� ��������
            Input.FieldByName(s+'DATE').AsDateTime:=AktRastBrak.DokumentDATESV.AsDateTime; //���� ������
            Input.FieldByName(s+'SERIA').AsString:=AktRastBrak.DokumentSVID_SERIA.AsString; //����� ���������
            Input.FieldByName(s+'NOMER').AsString:=AktRastBrak.DokumentSVID_NOMER.AsString; //����� ���������
          end else begin
            Input.FieldByName(s+'DATE').AsVariant:=null;
          end;
        end else begin                      // �� ������� ������
          if (s<>'') and (Trim(AktRastBrak.SvidPovtorSVID_NOMER.AsString)<>'') then begin
            Input.FieldByName(s+'TIP').AsString:=DOK_SVID_RAST; //��� ��������� ����������� �����
            Input.FieldByName(s+'ORGAN').AsString:=MessageSource; //���. �����, �������� ��������
            Input.FieldByName(s+'DATE').AsDateTime:=AktRastBrak.SvidPovtorSVID_DATE.AsDateTime; //���� ������
            Input.FieldByName(s+'SERIA').AsString:=AktRastBrak.SvidPovtorSVID_SERIA.AsString; //����� ���������
            Input.FieldByName(s+'NOMER').AsString:=AktRastBrak.SvidPovtorSVID_NOMER.AsString; //����� ���������
          end else begin
            Input.FieldByName(s+'DATE').AsVariant:=null;
          end;
        end;
      //------- ��������� ������������� ---------------
      end else begin
        //-------���������� � �������� ��������� (������������� ��� ������ ����)
        if (Trim(AktRastBrak.DokumentONA_SVID_NOMER.AsString)<>'') and
           not AktRastBrak.DokumentONA_SVID_DATE.IsNull then begin
    //      SetDokSvid(AktRastBrak, Input, 'ONA_', ???? ONA_SVID_DATE ????);
          Input.FieldByName('ONA_TIP').AsString:=DOK_SVID_RAST; //��� ��������� ����������� �����
          Input.FieldByName('ONA_ORGAN').AsString:=MessageSource; //���. �����, �������� ��������
          Input.FieldByName('ONA_DATE').AsDateTime:=AktRastBrak.DokumentONA_SVID_DATE.AsDateTime; //���� ������
          Input.FieldByName('ONA_SERIA').AsString:=AktRastBrak.DokumentONA_SVID_SERIA.AsString; //����� ���������
          Input.FieldByName('ONA_NOMER').AsString:=AktRastBrak.DokumentONA_SVID_NOMER.AsString; //����� ���������
        end else begin
          Input.FieldByName('ONA_DATE').AsVariant:=null;
        end;

        //------���������� � �������� ��������� (������������� ��� ������� ����)
        if (Trim(AktRastBrak.DokumentON_SVID_NOMER.AsString)<>'') and 
           not AktRastBrak.DokumentON_SVID_DATE.IsNull then begin
    //      SetDokSvid(AktRastBrak, Input, 'ONA_');
          Input.FieldByName('ON_TIP').AsString:=DOK_SVID_RAST; //��� ���������  ����������� �����
          Input.FieldByName('ON_ORGAN').AsString:=MessageSource; //���. �����, �������� ��������
          Input.FieldByName('ON_DATE').AsDateTime:=AktRastBrak.DokumentON_SVID_DATE.AsDateTime; //���� ������
          Input.FieldByName('ON_SERIA').AsString:=AktRastBrak.DokumentON_SVID_SERIA.AsString; //����� ���������
          Input.FieldByName('ON_NOMER').AsString:=AktRastBrak.DokumentON_SVID_NOMER.AsString; //����� ���������
        end else begin
          Input.FieldByName('ON_DATE').AsVariant:=null;
        end;

      end;

      //�������� � ���������� �����, �� ��������� 18 ���
      //???
      Input.Post;
      //3. ��������� ������ � �������
      RequestResult:=RegInt.Post(AktRastBrak.MessageID, akDivorce, AktRastBrak.DokumentTypeMessage.AsString, Input, Error);
      LogToTableLog(AktRastBrak, '����������� �/� � ����������� �����');
      if IsDebug then begin
         RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_post.txt');
      end;
      if RequestResult=rrOk then begin
        AktRastBrak.Dokument.CheckBrowseMode;
        AktRastBrak.Dokument.Edit;
        SetPoleGrn(AktRastBrak.DokumentPOLE_GRN, 3);
        AktRastBrak.Dokument.Post;
        if not HandleErrorToString
          then ShowMessageCont(GetMessageOk,CurAkt);
        result:=true;
      end else begin
        result:=false;
        //4.2. ������������ ������ �������������� � ���������
        HandleError(RequestResult, akDivorce, opGet, Input, Output, Error, FRegInt.FaultError);
      end;
    end;
  end;
{$ENDIF}
end;

function TGisun.GetRastBrak(Akt: TfmSimpleD): Boolean;
{$IFDEF ZAGS}
var
  AktRastBrak : TfmRastBrak;
  strError,strSOATO,strName: String;
  nAteID,PoleGrnSub : Integer;
  ag:TGorodR;
{$ENDIF}
begin
  Result:=false;
{$IFDEF ZAGS}
  AktRastBrak := TfmRastBrak(Akt);
  AktRastBrak.Dokument.CheckBrowseMode;
  if not SetTypeMessageAktRastBrak( AktRastBrak, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end else begin
    ClearDataSets;
    if RunExchange then begin
      PoleGrnSub:=0;
      //[1] ������ ������
      //1. ������ ������� ��� �������� ������ � �������
      Input:=FRegInt.CreateInputTable(akDivorce, opGet);
      //2. ��������� ������������ ������
      //���
      if Male then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='ON';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktRastBrak.DokumentON_IDENTIF.AsString);
        Input.Post;
      end;
      //����
      if Female then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='ONA';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktRastBrak.DokumentONA_IDENTIF.AsString);
        Input.Post;
      end;
      //3. ��������� ������ � �������
      RequestResult:=RegInt.Get(akDivorce, TypeMessage, Input, Output, Error);
      if IsDebug then begin
         RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_get.txt');
      end;
      if RequestResult=rrOk then begin
        Result:=true;
        AktRastBrak.Dokument.Edit;
        AktRastBrak.DokumentON_STATUS.AsString  := '';
        AktRastBrak.DokumentONA_STATUS.AsString := '';
        AktRastBrak.DokumentTypeMessage.AsString:='';
        AktRastBrak.MessageID:=RegInt.RequestMessageId;  // �������� ID �������
        if Male then begin
          if OutPut.Locate('PREFIX','ON',[]) then begin
            if (OutPut.FieldByName('K_POL').AsString<>'') and (Decode_Pol(OutPut.FieldByName('K_POL').AsString)='�') then begin
              ShowMessageErr('� �������� �������������� ���� ������ ������������� ������� !');
              Result:=false;
            end else begin
              PoleGrnSub:=PoleGrnSub or bMale;
              //������������ ������
              AktRastBrak.DokumentON_IDENTIF.AsString   := OutPut.FieldByName('IDENTIF').AsString;
              AktRastBrak.DokumentON_Familia.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
              AktRastBrak.DokumentON_Familia_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
              AktRastBrak.DokumentON_NAME.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
              AktRastBrak.DokumentON_Name_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
              AktRastBrak.DokumentON_OTCH.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
              AktRastBrak.DokumentON_Otch_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);
              Decode_Date(OutPut.FieldByName('DATER').AsString, AktRastBrak.DokumentON_DATER, AktRastBrak.DokumentON_ONLYGOD);
              if LoadGrag then
                AktRastBrak.DokumentON_GRAG.AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
              AktRastBrak.DokumentON_STATUS.AsString := OutPut.FieldByName('K_STATUS').AsString;
              //���������� ������ (��������, �������������� ��������)
              AktRastBrak.DokumentON_DOK_TYPE.AsString:=Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString);
              AktRastBrak.DokumentON_DOK_ORGAN.AsString:=OutPut.FieldByName('K_DOC_ORGAN').AsString;
              AktRastBrak.DokumentON_DOKUMENT.AsString:=OutPut.FieldByName('N_DOC_ORGAN').AsString;
              AktRastBrak.DokumentON_DOK_SERIA.AsString:=OutPut.FieldByName('DOC_SERIA').AsString;
              AktRastBrak.DokumentON_DOK_NOMER.AsString:=OutPut.FieldByName('DOC_NOMER').AsString;
              AktRastBrak.DokumentON_DOK_DATE.AsDateTime:=OutPut.FieldByName('DOC_DATE').AsDateTime;
              //------------����� �������� -----------------
              AktRastBrak.DokumentON_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString); //������ ��������
              AktRastBrak.DokumentON_B_OBL.AsString:='';

              DecodeObl_MestoRogd( AktRastBrak.Dokument,'ON_OBL','ON_B_OBL','',OutPut);
              //AktRastBrak.DokumentON_OBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,''); //������� ��������

              AktRastBrak.DokumentON_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,''); //����� ��������

              DecodePunkt_MestoRogd(AktRastBrak.Dokument, 'ON_B_GOROD', 'ON_GOROD', '', OutPut);
              //AktRastBrak.DokumentON_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString); //��� ���������� ������ ��������
              //AktRastBrak.DokumentON_GOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString; //��������� ����� �� ������� �����

              //------------ ����� ���������� --------------------
              if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
                AktRastBrak.DokumentON_M_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');

                DecodeObl_MestoGit(AktRastBrak.Dokument,'ON_M_OBL','ON_M_B_OBL','',OutPut);
                //AktRastBrak.DokumentON_M_B_OBL.AsString:='';
                //AktRastBrak.DokumentON_M_OBL.AsString:=Decode_Obl(OutPut.FieldByName('N_OBL').AsString,'');

                AktRastBrak.DokumentON_M_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');

                DecodePunkt_MestoGit(AktRastBrak.Dokument, 'ON_M_B_GOROD', 'ON_M_GOROD', '', OutPut);
                //AktRastBrak.DokumentON_M_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD').AsString);
                //AktRastBrak.DokumentON_M_GOROD.AsString:=OutPut.FieldByName('N_GOROD').AsString;

  // ����              AktRastBrak.DokumentON_M_GOROD_R.AsString:=GetGorodR(OutPut);
  //--------- ����� --------
                ag:=GetGorodREx(OutPut);
                AktRastBrak.DokumentON_M_GOROD_R.AsString:=ag.Ulica;
                AktRastBrak.DokumentON_M_DOM.AsString:=ag.Dom;
                AktRastBrak.DokumentON_M_KORP.AsString:=ag.Korp;
                AktRastBrak.DokumentON_M_KV.AsString:=ag.Kv;
  //------------------------
                {$IFDEF GISUN2}
                  AktRastBrak.DokumentON_M_RNGOROD.AsString:=Decode_RnGorod(OutPut, ['K_RN_GOROD','N_RN_GOROD'], strSoato);
                {$ENDIF}

                if getSoato(OutPut, nAteID, strSoato, strName) then begin
                  AktRastBrak.CheckSoatoAkt(true,false,true, '', nAteID, strSoato);
                end else begin
                  AktRastBrak.CheckSoatoAkt(true,false,true, '', 0, ''); // ��� ������ ���� ��������� ��������
                end;

              end;
            end;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ � ���� ! ');
            Result:=false;
          end;
        end;
        if Result and Female then begin
          if OutPut.Locate('PREFIX','ONA',[]) then begin
            if (OutPut.FieldByName('K_POL').AsString<>'') and (OutPut.FieldByName('K_POL').AsString='M') then begin
              ShowMessageErr('� �������� �������������� ���� ������ ������������� ������� !');
              Result:=false;
            end else begin
              PoleGrnSub:=PoleGrnSub or bFemale;
              //������������ ������
              AktRastBrak.DokumentONA_IDENTIF.AsString   := OutPut.FieldByName('IDENTIF').AsString;
              AktRastBrak.DokumentONA_Familia.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
              AktRastBrak.DokumentONA_Familia_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
              AktRastBrak.DokumentONA_NAME.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
              AktRastBrak.DokumentONA_Name_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
              AktRastBrak.DokumentONA_OTCH.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
              AktRastBrak.DokumentONA_Otch_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);
              Decode_Date(OutPut.FieldByName('DATER').AsString, AktRastBrak.DokumentONA_DATER, AktRastBrak.DokumentONA_ONLYGOD);
              if LoadGrag then
                AktRastBrak.DokumentONA_GRAG.AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
              AktRastBrak.DokumentONA_STATUS.AsString := OutPut.FieldByName('K_STATUS').AsString;
              //���������� ������ (��������, �������������� ��������)
              AktRastBrak.DokumentONA_DOK_TYPE.AsString:=Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString);
              AktRastBrak.DokumentONA_DOK_ORGAN.AsString:=OutPut.FieldByName('K_DOC_ORGAN').AsString;
              AktRastBrak.DokumentONA_DOKUMENT.AsString:=OutPut.FieldByName('N_DOC_ORGAN').AsString;
              AktRastBrak.DokumentONA_DOK_SERIA.AsString:=OutPut.FieldByName('DOC_SERIA').AsString;
              AktRastBrak.DokumentONA_DOK_NOMER.AsString:=OutPut.FieldByName('DOC_NOMER').AsString;
              AktRastBrak.DokumentONA_DOK_DATE.AsDateTime:=OutPut.FieldByName('DOC_DATE').AsDateTime;
              //-----------------����� �������� -----------------------
              AktRastBrak.DokumentONA_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString); //������ ��������

              DecodeObl_MestoRogd( AktRastBrak.Dokument,'ONA_OBL','ONA_B_OBL','',OutPut);
              //AktRastBrak.DokumentONA_B_OBL.AsString:='';
              //AktRastBrak.DokumentONA_OBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,''); //������� ��������

              AktRastBrak.DokumentONA_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,''); //����� ��������

              DecodePunkt_MestoRogd(AktRastBrak.Dokument, 'ONA_B_GOROD', 'ONA_GOROD', '', OutPut);
              //AktRastBrak.DokumentONA_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString); //��� ���������� ������ ��������
              //AktRastBrak.DokumentONA_GOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString; //��������� ����� �� ������� �����

              //---------------- ����� ���������� -----------------
              if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
                AktRastBrak.DokumentONA_M_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');

                DecodeObl_MestoGit( AktRastBrak.Dokument,'ONA_M_OBL','ONA_M_B_OBL','',OutPut);
                //AktRastBrak.DokumentONA_M_B_OBL.AsString:='';
                //AktRastBrak.DokumentONA_M_OBL.AsString:=Decode_Obl(OutPut.FieldByName('N_OBL').AsString,'');

                AktRastBrak.DokumentONA_M_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');

                DecodePunkt_MestoGit(AktRastBrak.Dokument, 'ONA_M_B_GOROD', 'ONA_M_GOROD', '', OutPut);
                //AktRastBrak.DokumentONA_M_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD').AsString);
                //AktRastBrak.DokumentONA_M_GOROD.AsString:=OutPut.FieldByName('N_GOROD').AsString;

  // ����              AktRastBrak.DokumentONA_M_GOROD_R.AsString:=GetGorodR(OutPut);
  //--------- ����� --------
                ag:=GetGorodREx(OutPut);
                AktRastBrak.DokumentONA_M_GOROD_R.AsString:=ag.Ulica;
                AktRastBrak.DokumentONA_M_DOM.AsString:=ag.Dom;
                AktRastBrak.DokumentONA_M_KORP.AsString:=ag.Korp;
                AktRastBrak.DokumentONA_M_KV.AsString:=ag.Kv;
  //------------------------
                {$IFDEF GISUN2}
                  AktRastBrak.DokumentONA_M_RNGOROD.AsString:=Decode_RnGorod(OutPut, ['K_RN_GOROD','N_RN_GOROD'], strSoato);
                {$ENDIF}
                if getSoato(OutPut, nAteID, strSoato, strName) then begin
                  AktRastBrak.CheckSoatoAkt(false,true,true, '', nAteID, strSoato);
                end else begin
                  AktRastBrak.CheckSoatoAkt(false,true,true, '', 0, ''); // ��� ������ ���� ��������� ��������
                end;
              end;
            end;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ � ���� ! ');
            Result:=false;
          end;
        end;

        if not Result then begin
          SetPoleGrn(AktRastBrak.DokumentPOLE_GRN, 0, 0);
        end else begin
          SetPoleGrn(AktRastBrak.DokumentPOLE_GRN, 2, PoleGrnSub);
          AktRastBrak.DokumentTypeMessage.AsString:=TypeMessage;
        end;
        AktRastBrak.Dokument.Post;
      end else begin
        HandleError(RequestResult, akDivorce, opGet, Input, Output, Error, RegInt.FaultError);
      end;
      ClearDataSets;
    end;
  end;
{$ENDIF}
end;

//�������� ����:
//0510 - ��������� �/� � ����������� �����;
//0520 - ������������� �/� � ����������� �����;
function TGisun.SetTypeMessageAktRastBrak(Akt: TfmSimpleD; var strError: String): Boolean;
{$IFDEF ZAGS}
var
  AktRastBrak : TfmRastBrak;
{$ENDIF}
begin
  Result:=false;
{$IFDEF ZAGS}
  AktRastBrak := TfmRastBrak(Akt);
  AktRastBrak.Dokument.CheckBrowseMode;
  if not CheckMessageSource(Akt, strError) then begin
    Result:=false;
    exit;
  end;

  strError:='';
  TypeAkt := '0500';

  Female:=true;  // ����� ������ � ����
  Male:=true;    // ����� ������ � ����

  // �� ��������� �������� �� ������� ��(1) � �� ��� �� ����������(2,3)
  if (AktRastBrak.DokumentON_DOK_TYPE.AsInteger>3) or (AktRastBrak.DokumentON_DOK_TYPE.AsInteger=0) then begin
    Male:=false;
  end;
  // ��� ���������� �������� �� ������� ��(1) � �� ��� �� ����������(2,3)
  if (AktRastBrak.DokumentONA_DOK_TYPE.AsInteger>3) or (AktRastBrak.DokumentONA_DOK_TYPE.AsInteger=0) then begin
    Female:=false;
  end;

  RunExchange:=true;  // ��������� ������������� ��� ���
  DefaultPoleGrn:=0;  // �������� ��� ���� POLE_GRN ���� �� ���� ������������ ��������������
  TypeMessage:='*';

  if TypeMessage='*'
    then TypeMessage:='0500';
  if Male and (AktRastBrak.DokumentON_IDENTIF.AsString='') then begin
    strError:='��: ��������� �������������';
  end;
  if FeMale and (AktRastBrak.DokumentONA_IDENTIF.AsString='') then begin
    strError:='���: ��������� �������������';
  end;
  if strError=''
    then Result:=true
    else Result:=false;
{$ENDIF}
end;

procedure TGisun.CheckRastBrak(Simple: TfmSimpleD);
{$IFDEF ZAGS}
const
  {$IFDEF GISUN2}
     CComponentName: array [1..44] of record   //
  {$ELSE}
     CComponentName: array [1..42] of record   //
  {$ENDIF}
      Name: string;
      Code: Integer;
      Color: TColor;
   end=(
     //1. ���
     //������������ ������
     (Name:'ENG_edON_IDENTIF'; Code: bMale; Color: clDefault),
     (Name:'edON_Familia'; Code: bMale; Color: clDefault),
     (Name:'edON_NAME'; Code: bMale; Color: clDefault),
     (Name:'edON_OTCH'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_Familia'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_NAME'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_OTCH'; Code: bMale; Color: clDefault),
     //--ON_Otch_B
     (Name:'edON_DATER'; Code: bMale; Color: clDefault),
     (Name:'cbOnlyGodON'; Code: bMale; Color: clDefault),
     (Name:'edON_VOZR'; Code: bMale; Color: clDefault),
     (Name:'edON_GRAG'; Code: bMale; Color: clDefault),      //   ???
     //--ON_STATUS
     //���������� ������ (��������, �������������� ��������)
     (Name:'edON_DOK_TYPE'; Code: bMale; Color: clDefault),
     //--ON_DOK_ORGAN
     (Name:'edON_DOKUMENT'; Code: bMale; Color: clDefault),
     (Name:'edON_DOK_SERIA'; Code: bMale; Color: clDefault),
     (Name:'edON_DOK_NOMER'; Code: bMale; Color: clDefault),
     (Name:'edON_DOK_DATE'; Code: bMale; Color: clDefault),
     //����� ��������
     (Name:'edON_GOSUD'; Code: bMale; Color: clDefault),
     (Name:'edON_B_OBL'; Code: bMale; Color: clDefault),
     (Name:'edON_OBL_R'; Code: bMale; Color: clDefault),
     (Name:'edON_RAION_R'; Code: bMale; Color: clDefault),
     (Name:'edON_B_GOROD'; Code: bMale; Color: clDefault),
     (Name:'edON_GOROD'; Code: bMale; Color: clDefault),
     //����� ����������
     {
     (Name:'edON_M_B_RESP'; Code: bMale; Color: clDefault),
     (Name:'edON_M_GOSUD'; Code: bMale; Color: clDefault),
     (Name:'edON_M_B_OBL'; Code: bMale; Color: clDefault),
     (Name:'edON_M_OBL'; Code: bMale; Color: clDefault),
     (Name:'edON_M_RAION'; Code: bMale; Color: clDefault),
     (Name:'edON_M_B_GOROD'; Code: bMale; Color: clDefault),
     (Name:'edON_M_GOROD'; Code: bMale; Color: clDefault),
     (Name:'edON_M_GOROD_R'; Code: bMale; Color: clDefault),
     (Name:'edON_M_DOM'; Code: bMale; Color: clDefault),
     (Name:'edON_M_KORP'; Code: bMale; Color: clDefault),
     (Name:'edON_M_KV'; Code: bMale; Color: clDefault),
      }
     {$IFDEF GISUN2}
//       (Name:'edON_M_RNGOROD'; Code: bMale; Color: clDefault),
//       (Name:'edONA_M_RNGOROD'; Code: bFemale; Color: clDefault),
     {$ENDIF}

     //2. ����
     //������������ ������
     (Name:'ENG_edONA_IDENTIF'; Code: bFemale; Color: clDefault),
     (Name:'edONA_Familia'; Code: bFemale; Color: clDefault),
     (Name:'edONA_NAME'; Code: bFemale; Color: clDefault),
     (Name:'edONA_OTCH'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_Familia'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_NAME'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_OTCH'; Code: bFemale; Color: clDefault),
     (Name:'edONA_DATER'; Code: bFemale; Color: clDefault),
     (Name:'cbOnlyGodONA'; Code: bFemale; Color: clDefault),
     (Name:'edONA_VOZR'; Code: bFemale; Color: clDefault),
     (Name:'edONA_GRAG'; Code: bFemale; Color: clDefault),          //     ???
     //--ONA_STATUS
     //���������� ������ (��������, �������������� ��������),
     (Name:'edONA_DOK_TYPE'; Code: bFemale; Color: clDefault),
     //--ONA_DOK_ORGAN
     (Name:'edONA_DOKUMENT'; Code: bFemale; Color: clDefault),
     (Name:'edONA_DOK_SERIA'; Code: bFemale; Color: clDefault),
     (Name:'edONA_DOK_NOMER'; Code: bFemale; Color: clDefault),
     (Name:'edONA_DOK_DATE'; Code: bFemale; Color: clDefault),
     //����� ��������
     (Name:'edONA_GOSUD'; Code: bFemale; Color: clDefault),
     (Name:'edONA_B_OBL'; Code: bFemale; Color: clDefault),
     (Name:'edONA_OBL_R'; Code: bFemale; Color: clDefault),
     (Name:'edONA_RAION_R'; Code: bFemale; Color: clDefault),
     (Name:'edONA_B_GOROD'; Code: bFemale; Color: clDefault),
     (Name:'edONA_GOROD'; Code: bFemale; Color: clDefault)
     //����� ����������
     {
     (Name:'edONA_M_B_RESP'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_GOSUD'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_B_OBL'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_OBL'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_RAION'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_B_GOROD'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_GOROD'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_GOROD_R'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_DOM'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_KORP'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_KV'; Code: bFemale; Color: clDefault)
     }
   );
var
   Akt: TfmRastBrak;
   PoleGrn: Integer;
   PoleGrnSub: Integer;
   I: Integer;
   Component: TComponent;
   Control: TControl;
   lDisable,l: Boolean;
{$ENDIF}
begin
{$IFDEF ZAGS}
   Akt:=TfmRastBrak(Simple);
   l:=(IsEnabled and IsEnableTypeAkt(dmBase.TypeObj_ZRast,false));
   if l then begin
     PoleGrn:=GetPoleGrn(Akt.DokumentPOLE_GRN.AsInteger);
     PoleGrnSub:=GetPoleGrnSub(Akt.DokumentPOLE_GRN.AsInteger);
   end else begin
     PoleGrn:=0;
     PoleGrnSub:=0;
   end;
   //1. ������������ ����������� ������ [� ������ ������� �� ����� ��������]
   //TBItemStep1 - "��������� ������"
   //TBItemStep2 - "���������������� ������� ������"
   {
   if not IsDebug then begin
      case PoleGrn of
         //�� ���� ������ � ��� ��
         0: begin
            Akt.TBItemStep1.Enabled:=True;
            Akt.TBItemStep2.Enabled:=True;
         end;
         1:;
         //������� ����� �� ��� ��
         2: begin
            Akt.TBItemStep1.Enabled:=False;
            Akt.TBItemStep2.Enabled:=True;
         end;
         //���������� ������ �� ������� ������ � ��� ��
         3: begin
            Akt.TBItemStep1.Enabled:=False;
            Akt.TBItemStep2.Enabled:=False;
         end;
      end;
   end;
   }
   //2. ������������ ����������� ��������� ��������������
   //����� ��������� ������ �� ��� �� �������� �������������� ������ ����� ����������
   for I:=Low(CComponentName) to High(CComponentName) do begin
      Component:=Akt.FindComponent(CComponentName[I].Name);
      if (Component<>nil) and (Component is TControl) then begin
         Control:=TControl(Component);
         //2.1.
         if l
           then lDisable:=((PoleGrn=2) or (PoleGrn=3)) and ((PoleGrnSub and CComponentName[I].Code)=CComponentName[I].Code)
           else lDisable:=l;
         //2.2.

         if lDisable and (PoleGrn=3) then begin
           lDisable:=false;
         end;

         if lDisable then begin
            SetEnableControl(FTypeEnableControl,Control,false);
            //Control.Enabled:=False;
            if TxControl(Control).Color<>GetDisableColorGIS then begin
               CComponentName[I].Color:=TxControl(Control).Color;
            end;
            TxControl(Control).Color:=GetDisableColorGIS;
         end
         else begin
            if CComponentName[I].Color<>clDefault then begin
               TxControl(Control).Color:=CComponentName[I].Color;
            end;
            SetEnableControl(FTypeEnableControl,Control,true);
            //Control.Enabled:=True;
         end;
      end
      else begin
         ShowMessageC(CComponentName[I].Name);
      end;
   end;
{$ENDIF}
end;

//----------------------------------------------------------------------
procedure TGisun.CheckAdopt(Simple: TfmSimpleD);
{$IFDEF ZAGS}
const
   CComponentName: array [1..72] of record   // 99       ???
      Name: string;
      Code: Integer;
      Color: TColor;
   end=(
     //1. ������
     //������������ ������
     (Name:'ENG_edIDENTIF_Do'; Code: bChildId; Color: clDefault),
     (Name:'edFamiliaDo'; Code: bChild; Color: clDefault),
     (Name:'edNameDo'; Code: bChild; Color: clDefault),
     (Name:'edOtchDo'; Code: bChild; Color: clDefault),
     (Name:'BLR_edFamiliaDo'; Code: bChild; Color: clDefault),
     (Name:'BLR_edNameDo'; Code: bChild; Color: clDefault),
     (Name:'BLR_edOtchDo'; Code: bChild; Color: clDefault),
     (Name:'edDATER_DO'; Code: bChildId; Color: clDefault),
     (Name:'edPOL'; Code: bChildId; Color: clDefault),
     //--GRAG_Do
     //--STATUS
     //����� ��������
     (Name:'edGOSUD'; Code: bChild; Color: clDefault),
     (Name:'edB_OBL_DO'; Code: bChild; Color: clDefault),
     (Name:'edOBL'; Code: bChild; Color: clDefault),
     (Name:'BLR_edOBL'; Code: bChild; Color: clDefault),
     (Name:'edRAION'; Code: bChild; Color: clDefault),
     (Name:'BLR_edRAION'; Code: bChild; Color: clDefault),
     (Name:'edB_GOROD'; Code: bChild; Color: clDefault),
     (Name:'edGOROD'; Code: bChild; Color: clDefault),
     (Name:'BLR_edGOROD'; Code: bChild; Color: clDefault),

     //--GOROD_DO_B
     //2. ����
     //������������ ������
     (Name:'ENG_edOTEC_IDENTIF'; Code: bMale; Color: clDefault),
     (Name:'edOTEC_Familia'; Code: bMale; Color: clDefault),
     (Name:'edOTEC_NAME'; Code: bMale; Color: clDefault),
     (Name:'edOTEC_OTCH'; Code: bMale; Color: clDefault),
     (Name:'edOTEC_DATER'; Code: bMale; Color: clDefault),
     (Name:'edOTEC_GRAG'; Code: bMale; Color: clDefault),         //  ???
     //--OTEC_STATUS
     //����� ����������
     {
     (Name:'edOTEC_B_RESP'; Code: bMale; Color: clDefault),
     (Name:'edOTEC_GOSUD'; Code: bMale; Color: clDefault),
     (Name:'edOTEC_B_OBL'; Code: bMale; Color: clDefault),
     (Name:'edOTEC_OBL'; Code: bMale; Color: clDefault),
     (Name:'edOTEC_RAION'; Code: bMale; Color: clDefault),
     (Name:'edOTEC_B_GOROD'; Code: bMale; Color: clDefault),
     (Name:'edOTEC_GOROD'; Code: bMale; Color: clDefault),
     (Name:'edOTEC_GOROD_R'; Code: bMale; Color: clDefault),
     }
     //����� ��������
     (Name:'edOTEC_M_GOSUD'; Code: bMale; Color: clDefault),
     (Name:'edOTEC_M_B_OBL'; Code: bMale; Color: clDefault),
     (Name:'edOTEC_M_OBL'; Code: bMale; Color: clDefault),
     (Name:'edOTEC_M_RAION'; Code: bMale; Color: clDefault),
     (Name:'edOTEC_M_B_GOROD'; Code: bMale; Color: clDefault),
     (Name:'edOTEC_M_GOROD'; Code: bMale; Color: clDefault),
     //3. �����������
     //������������ ������
     (Name:'ENG_edON_IDENTIF'; Code: bMaleU; Color: clDefault),
     (Name:'edON_Familia'; Code: bMaleU; Color: clDefault),
     (Name:'edON_NAME'; Code: bMaleU; Color: clDefault),
     (Name:'edON_OTCH'; Code: bMaleU; Color: clDefault),
     (Name:'BLR_edON_Familia'; Code: bMaleU; Color: clDefault),
     (Name:'BLR_edON_NAME'; Code: bMaleU; Color: clDefault),
     (Name:'BLR_edON_OTCH'; Code: bMaleU; Color: clDefault),

     (Name:'edON_DATER'; Code: bMaleU; Color: clDefault),
     (Name:'edON_GRAG'; Code: bMaleU; Color: clDefault),        // ???
     //--ON_STATUS
     //����� ����������
     {
     (Name:'edON_B_RESP'; Code: bMaleU; Color: clDefault),
     (Name:'edON_GOSUD'; Code: bMaleU; Color: clDefault),
     (Name:'edON_B_OBL'; Code: bMaleU; Color: clDefault),
     (Name:'edON_OBL'; Code: bMaleU; Color: clDefault),
     (Name:'edON_RAION'; Code: bMaleU; Color: clDefault),
     (Name:'edON_B_GOROD'; Code: bMaleU; Color: clDefault),
     (Name:'edON_GOROD'; Code: bMaleU; Color: clDefault),
     (Name:'edON_GOROD_R'; Code: bMaleU; Color: clDefault),
     }
     //����� ��������
     (Name:'edON_M_GOSUD'; Code: bMaleU; Color: clDefault),
     (Name:'edON_M_B_OBL'; Code: bMaleU; Color: clDefault),
     (Name:'edON_M_OBL'; Code: bMaleU; Color: clDefault),
     (Name:'edON_M_RAION'; Code: bMaleU; Color: clDefault),
     (Name:'edON_M_B_GOROD'; Code: bMaleU; Color: clDefault),
     (Name:'edON_M_GOROD'; Code: bMaleU; Color: clDefault),
     //4. ����
     //������������ ������
     (Name:'ENG_edMAT_IDENTIF'; Code: bFemale; Color: clDefault),
     (Name:'edMAT_Familia'; Code: bFemale; Color: clDefault),
     (Name:'edMAT_NAME'; Code: bFemale; Color: clDefault),
     (Name:'edMAT_OTCH'; Code: bFemale; Color: clDefault),
     (Name:'edMAT_DATER'; Code: bFemale; Color: clDefault),
     (Name:'edMAT_GRAG'; Code: bFemale; Color: clDefault),          // ???
     //--MAT_STATUS
     //����� ����������
     {
     (Name:'edMAT_B_RESP'; Code: bFemale; Color: clDefault),
     (Name:'edMAT_GOSUD'; Code: bFemale; Color: clDefault),
     (Name:'edMAT_B_OBL'; Code: bFemale; Color: clDefault),
     (Name:'edMAT_OBL'; Code: bFemale; Color: clDefault),
     (Name:'edMAT_RAION'; Code: bFemale; Color: clDefault),
     (Name:'edMAT_B_GOROD'; Code: bFemale; Color: clDefault),
     (Name:'edMAT_GOROD'; Code: bFemale; Color: clDefault),
     (Name:'edMAT_GOROD_R'; Code: bFemale; Color: clDefault),
     }
     //����� ��������
     (Name:'edMAT_M_GOSUD'; Code: bFemale; Color: clDefault),
     (Name:'edMAT_M_B_OBL'; Code: bFemale; Color: clDefault),
     (Name:'edMAT_M_OBL'; Code: bFemale; Color: clDefault),
     (Name:'edMAT_M_RAION'; Code: bFemale; Color: clDefault),
     (Name:'edMAT_M_B_GOROD'; Code: bFemale; Color: clDefault),
     (Name:'edMAT_M_GOROD'; Code: bFemale; Color: clDefault),
     //5. ���������������
     //������������ ������
     (Name:'ENG_edONA_IDENTIF'; Code: bFemaleU; Color: clDefault),
     (Name:'edONA_Familia'; Code: bFemaleU; Color: clDefault),
     (Name:'edONA_NAME'; Code: bFemaleU; Color: clDefault),
     (Name:'edONA_OTCH'; Code: bFemaleU; Color: clDefault),
     (Name:'BLR_edONA_Familia'; Code: bFemaleU; Color: clDefault),
     (Name:'BLR_edONA_NAME'; Code: bFemaleU; Color: clDefault),
     (Name:'BLR_edONA_OTCH'; Code: bFemaleU; Color: clDefault),
     (Name:'edONA_DATER'; Code: bFemaleU; Color: clDefault),
     (Name:'edONA_GRAG'; Code: bFemaleU; Color: clDefault),          //???
     //--ONA_STATUS
     //����� ����������
     {
     (Name:'edONA_B_RESP'; Code: bFemaleU; Color: clDefault),
     (Name:'edONA_GOSUD'; Code: bFemaleU; Color: clDefault),
     (Name:'edONA_B_OBL'; Code: bFemaleU; Color: clDefault),
     (Name:'edONA_OBL'; Code: bFemaleU; Color: clDefault),
     (Name:'edONA_RAION'; Code: bFemaleU; Color: clDefault),
     (Name:'edONA_B_GOROD'; Code: bFemaleU; Color: clDefault),
     (Name:'edONA_GOROD'; Code: bFemaleU; Color: clDefault),
     (Name:'edONA_GOROD_R'; Code: bFemaleU; Color: clDefault),
     }
     //����� ��������
     (Name:'edONA_M_GOSUD'; Code: bFemaleU; Color: clDefault),
     (Name:'edONA_M_B_OBL'; Code: bFemaleU; Color: clDefault),
     (Name:'edONA_M_OBL'; Code: bFemaleU; Color: clDefault),
     (Name:'edONA_M_RAION'; Code: bFemaleU; Color: clDefault),
     (Name:'edONA_M_B_GOROD'; Code: bFemaleU; Color: clDefault),
     (Name:'edONA_M_GOROD'; Code: bFemaleU; Color: clDefault)
   );
var
   Akt: TfmZapisAdopt;
   PoleGrn: Integer;
   PoleGrnSub: Integer;
   I: Integer;
   Component: TComponent;
   Control: TControl;
   lDisable,l: Boolean;
{$ENDIF}
begin
{$IFDEF ZAGS}
   Akt:=TfmZapisAdopt(Simple);
   l:=(IsEnabled and IsEnableTypeAkt(dmBase.TypeObj_ZAdopt,false));
   if l then begin
     PoleGrn:=GetPoleGrn(Akt.DokumentPOLE_GRN.AsInteger);
     PoleGrnSub:=GetPoleGrnSub(Akt.DokumentPOLE_GRN.AsInteger);
   end else begin
     PoleGrn:=0;
     PoleGrnSub:=0;
   end;
   //1. ������������ ����������� ������ [� ������ ������� �� ����� ��������]
   //TBItemStep1 - "��������� ������"
   //TBItemStep2 - "���������������� ������� ������"
   {
   if not IsDebug then begin
      case PoleGrn of
         //�� ���� ������ � ��� ��
         0: begin
            Akt.TBItemStep1.Enabled:=True;
            Akt.TBItemStep2.Enabled:=True;
         end;
         1:;
         //������� ����� �� ��� ��
         2: begin
            Akt.TBItemStep1.Enabled:=False;
            Akt.TBItemStep2.Enabled:=True;
         end;
         //���������� ������ �� ������� ������ � ��� ��
         3: begin
            Akt.TBItemStep1.Enabled:=False;
            Akt.TBItemStep2.Enabled:=False;
         end;
      end;
   end;
   }
   //2. ������������ ����������� ��������� ��������������
   //����� ��������� ������ �� ��� �� �������� �������������� ������ ����� ����������
   for I:=Low(CComponentName) to High(CComponentName) do begin
      Component:=Akt.FindComponent(CComponentName[I].Name);
      if (Component<>nil) and (Component is TControl) then begin
         Control:=TControl(Component);
         //2.1.
         if l
           then lDisable:=((PoleGrn=2) or (PoleGrn=3)) and ((PoleGrnSub and CComponentName[I].Code)=CComponentName[I].Code)
           else lDisable:=l;
         if lDisable and (PoleGrn=3) then begin
           lDisable:=false;
         end;

         //2.2.
         if lDisable then begin
            SetEnableControl(FTypeEnableControl,Control,false);
            //Control.Enabled:=False;
            if TxControl(Control).Color<>GetDisableColorGIS then begin
               CComponentName[I].Color:=TxControl(Control).Color;
            end;
            TxControl(Control).Color:=GetDisableColorGIS;
         end
         else begin
            if CComponentName[I].Color<>clDefault then begin
               TxControl(Control).Color:=CComponentName[I].Color;
            end;
            SetEnableControl(FTypeEnableControl,Control,true);
            //Control.Enabled:=True;
         end;
      end
      else begin
         ShowMessageC(CComponentName[I].Name);
      end;
   end;
{$ENDIF}
end;


procedure TGisun.CheckChName(Simple: TfmSimpleD);
{$IFDEF ZAGS}
const
   CComponentName: array [1..42] of record       // 29 ???
      Name: string;
      Code: Integer;
      Color: TColor;
   end=(
     //�������
     //������������ ������ ��������
     (Name:'ENG_edIDENTIF'; Code: bPerson; Color: clDefault),
     (Name:'edFamiliaDo'; Code: bPerson; Color: clDefault),
     (Name:'edNameDo'; Code: bPerson; Color: clDefault),
     (Name:'edOtchDo'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edFamiliaDo'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edNameDo'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edOtchDo'; Code: bPerson; Color: clDefault),
     (Name:'edDATER'; Code: bPerson; Color: clDefault),
     (Name:'edPOL'; Code: bPerson; Color: clDefault),
     (Name:'edGRAG'; Code: bPerson; Color: clDefault),           //    ???
     //--STATUS
     //���������� ������ (��������, �������������� ��������)
     (Name:'edDOK_TYPE'; Code: bPerson; Color: clDefault),
     //--DOK_ORGAN
     (Name:'edDOKUMENT'; Code: bPerson; Color: clDefault),
     (Name:'edDOK_SERIA'; Code: bPerson; Color: clDefault),
     (Name:'edDOK_NOMER'; Code: bPerson; Color: clDefault),
     (Name:'edDOK_DATE'; Code: bPerson; Color: clDefault),
     //����� ��������
     (Name:'edGOSUD'; Code: bPerson; Color: clDefault),
     (Name:'edB_OBL'; Code: bPerson; Color: clDefault),
     (Name:'edOBL'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edOBL'; Code: bPerson; Color: clDefault),
     (Name:'edRAION'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edRAION'; Code: bPerson; Color: clDefault),
     (Name:'edB_GOROD'; Code: bPerson; Color: clDefault),
     (Name:'edGOROD'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edGOROD'; Code: bPerson; Color: clDefault),

     //������������� ------------------------------------
     (Name:'edFamilia_Sv'; Code: bPerson; Color: clDefault),
     (Name:'edNAME_Sv'; Code: bPerson; Color: clDefault),
     (Name:'edOTCH_Sv'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edFamiliaB_Sv'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edNAMEB_Sv'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edOTCHB_Sv'; Code: bPerson; Color: clDefault),

     (Name:'edPOL_Sv'; Code: bPerson; Color: clDefault),
     (Name:'edDATER_Sv'; Code: bPerson; Color: clDefault),
     //������������� ����� ��������
     (Name:'edGOSUD_Sv'; Code: bPerson; Color: clDefault),
     (Name:'edOBL_Sv'; Code: bPerson; Color: clDefault),
     (Name:'edRAION_Sv'; Code: bPerson; Color: clDefault),
     (Name:'edTypeGOROD_Sv'; Code: bPerson; Color: clDefault),
     (Name:'edGOROD_Sv'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edGOSUD_Sv_B'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edOBLB_Sv'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edRAIONB_Sv'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edTypeGORODB_Sv'; Code: bPerson; Color: clDefault),
     (Name:'BLR_edGORODB_Sv'; Code: bPerson; Color: clDefault)

     //����� ����������
     {
     (Name:'edM_B_RESP'; Code: bPerson; Color: clDefault),
     (Name:'edM_GOSUD'; Code: bPerson; Color: clDefault),
     (Name:'edM_B_OBL'; Code: bPerson; Color: clDefault),
     (Name:'edM_OBL'; Code: bPerson; Color: clDefault),
     (Name:'edM_RAION'; Code: bPerson; Color: clDefault),
     (Name:'edM_B_GOROD'; Code: bPerson; Color: clDefault),
     (Name:'edM_GOROD'; Code: bPerson; Color: clDefault),
     (Name:'edM_GOROD_R'; Code: bPerson; Color: clDefault)
     }
   );
var
   Akt: TfmZapisChName;
   PoleGrn: Integer;
   PoleGrnSub: Integer;
   I: Integer;
   Component: TComponent;
   Control: TControl;
   lDisable,l: Boolean;
{$ENDIF}
begin
{$IFDEF ZAGS}
   Akt:=TfmZapisChName(Simple);
   l:=(IsEnabled and IsEnableTypeAkt(dmBase.TypeObj_ZChName,false));
   if l then begin
     PoleGrn:=GetPoleGrn(Akt.DokumentPOLE_GRN.AsInteger);
     PoleGrnSub:=GetPoleGrnSub(Akt.DokumentPOLE_GRN.AsInteger);
   end else begin
     PoleGrn:=0;
     PoleGrnSub:=0;
   end;
   //1. ������������ ����������� ������ [� ������ ������� �� ����� ��������]
   //TBItemStep1 - "��������� ������"
   //TBItemStep2 - "���������������� ������� ������"
   {
   if not IsDebug then begin
      case PoleGrn of
         //�� ���� ������ � ��� ��
         0: begin
            Akt.TBItemStep1.Enabled:=True;
            Akt.TBItemStep2.Enabled:=True;
         end;
         1:;
         //������� ����� �� ��� ��
         2: begin
            Akt.TBItemStep1.Enabled:=False;
            Akt.TBItemStep2.Enabled:=True;
         end;
         //���������� ������ �� ������� ������ � ��� ��
         3: begin
            Akt.TBItemStep1.Enabled:=False;
            Akt.TBItemStep2.Enabled:=False;
         end;
      end;
   end;
   }
   //2. ������������ ����������� ��������� ��������������
   //����� ��������� ������ �� ��� �� �������� �������������� ������ ����� ����������
   for I:=Low(CComponentName) to High(CComponentName) do begin
      Component:=Akt.FindComponent(CComponentName[I].Name);
      if (Component<>nil) and (Component is TControl) then begin
         Control:=TControl(Component);
         //2.1.
         if l
           then lDisable:=((PoleGrn=2) or (PoleGrn=3)) and ((PoleGrnSub and CComponentName[I].Code)=CComponentName[I].Code)
           else lDisable:=l;

         if lDisable and (PoleGrn=3) then begin
           lDisable:=false;
         end;

         //2.2.
         if lDisable then begin
            SetEnableControl(FTypeEnableControl,Control,false);
            //Control.Enabled:=False;
            if TxControl(Control).Color<>GetDisableColorGIS then begin
               CComponentName[I].Color:=TxControl(Control).Color;
            end;
            TxControl(Control).Color:=GetDisableColorGIS;
         end
         else begin
            if CComponentName[I].Color<>clDefault then begin
               TxControl(Control).Color:=CComponentName[I].Color;
            end;
            SetEnableControl(FTypeEnableControl,Control,true);
            //Control.Enabled:=True;
         end;
      end
      else begin
         ShowMessageC(CComponentName[I].Name);
      end;
   end;
{$ENDIF}
end;

//------------------------------------------------------------
// ������ ������ ��� ���� �� �����������
function TGisun.GetAdopt(Akt: TfmSimpleD): Boolean;
{$IFDEF ZAGS}
var
  AktAdopt : TfmZapisAdopt;
  strError : String;
  PoleGrnSub : Integer;
  nType:Integer;
  dDate:TDateTime;
  p : TPassport;
  s : String;
{$ENDIF}
begin
  Result:=false;
{$IFDEF ZAGS}
  AktAdopt := TfmZapisAdopt(Akt);
  AktAdopt.Dokument.CheckBrowseMode;
  if not SetTypeMessageAktAdopt( AktAdopt, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end else begin
    ClearDataSets;
    if RunExchange then begin
      PoleGrnSub:=0;
      //[1] ������ ������
      //1. ������ ������� ��� �������� ������ � �������
      Input:=FRegInt.CreateInputTable(akAdoption, opGet);
      //2. ��������� ������������ ������
      //������
      if ChildIdentif then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=false;
        Input.FieldByName('PREFIX').AsString:='CHILD';
        Input.FieldByName('POL').AsString:= Code_Pol(AktAdopt.DokumentPOL.AsString);
        Input.FieldByName('DATER').AsString:=DTOS(AktAdopt.DokumentDATER_POSLE.AsDateTime,tdClipper);
        Input.Post;
      end;
      if Child then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='CHILD';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktAdopt.DokumentIDENTIF_DO.AsString);
        Input.Post;
      end;
      //����
      if Male then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='OTEC';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktAdopt.DokumentOTEC_IDENTIF.AsString);
        Input.Post;
      end;
      //�����������
      if MaleU then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='ON';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktAdopt.DokumentON_IDENTIF.AsString);
        Input.Post;
      end;
      //����
      if Female then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='MAT';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktAdopt.DokumentMAT_IDENTIF.AsString);
        Input.Post;
      end;
      //���������������
      if FemaleU then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='ONA';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktAdopt.DokumentONA_IDENTIF.AsString);
        Input.Post;
      end;
      //3. ��������� ������ � �������
      RequestResult:=RegInt.Get(akAdoption, TypeMessage, Input, Output, Error);
      if IsDebug then begin
         RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_get.txt');
      end;
      if RequestResult=rrOk then begin
        Result:=true;
        AktAdopt.Dokument.Edit;
        AktAdopt.DokumentSTATUS.AsString  := '';
        AktAdopt.DokumentON_STATUS.AsString  := '';
        AktAdopt.DokumentOTEC_STATUS.AsString := '';
        AktAdopt.DokumentONA_STATUS.AsString := '';
        AktAdopt.DokumentMAT_STATUS.AsString := '';
        AktAdopt.DokumentTypeMessage.AsString:='';
        AktAdopt.MessageID:=RegInt.RequestMessageId;  // �������� ID �������
        //������
        if OutPut.Locate('PREFIX','CHILD',[]) then begin
          if ChildIdentif then begin
            PoleGrnSub:=PoleGrnSub or bChildId;
            AktAdopt.DokumentIDENTIF_Do.AsString := OutPut.FieldByName('NEW_IDENTIF').AsString;
{!!!}       AktAdopt.DokumentSTATUS.AsString := '1'; //������� ??? ������
          end
          else begin
            PoleGrnSub:=PoleGrnSub or bChild or bChildId;
            //������������ ������
            AktAdopt.DokumentFamiliaDo.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
            AktAdopt.DokumentFamiliaDo_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
            AktAdopt.DokumentNameDo.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
            AktAdopt.DokumentNameDo_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
            AktAdopt.DokumentOtchDo.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
            AktAdopt.DokumentOtchDo_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);

//            if OutPut.FieldByName('DATER').AsString<>''
//              then AktAdopt.DokumentDATER_DO.AsDateTime  := STOD( OutPut.FieldByName('DATER').AsString, tdClipper);
            Decode_Date2(OutPut.FieldByName('DATER').AsString, dDate, nType);
            if dDate<>0
              then AktAdopt.DokumentDATER_DO.AsDateTime:=dDate;

            AktAdopt.DokumentPOL.AsString         := Decode_Pol(OutPut.FieldByName('K_POL').AsString);
            if LoadGrag then
              AktAdopt.DokumentGRAG_Do.AsString        := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
            AktAdopt.DokumentSTATUS.AsString      := OutPut.FieldByName('K_STATUS').AsString;
            //-----------------����� �������� -------------
            AktAdopt.DokumentGOSUD_DO.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString);
            DecodeObl_MestoRogd( AktAdopt.Dokument,'OBL_DO','B_OBL_DO','OBL_DO_B',OutPut);
            AktAdopt.DokumentRAION_DO.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,OutPut.FieldByName('RAION_B_R').AsString);
            AktAdopt.DokumentRAION_DO_B.AsString:=CaseAdres(OutPut.FieldByName('RAION_B_R').AsString);
            DecodePunkt_MestoRogd(AktAdopt.Dokument, 'B_GOROD_DO', 'GOROD_DO', 'GOROD_DO_B', OutPut);
          end;
        end;
        //����
        if Result and Male then begin
          if OutPut.Locate('PREFIX','OTEC',[]) then begin
            if (OutPut.FieldByName('K_POL').AsString<>'') and (Decode_Pol(OutPut.FieldByName('K_POL').AsString)='�') then begin
              ShowMessageErr('� �������� �������������� ���� ������ ������������� ������� !');
              Result:=false;
            end else begin
              PoleGrnSub:=PoleGrnSub or bMale;
              //������������ ������
              AktAdopt.DokumentOTEC_IDENTIF.AsString := OutPut.FieldByName('IDENTIF').AsString;
              AktAdopt.DokumentOTEC_Familia.AsString := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
              AktAdopt.DokumentOTEC_NAME.AsString    := CaseFIO(OutPut.FieldByName('NAME').AsString);
              AktAdopt.DokumentOTEC_OTCH.AsString    := CaseFIO(OutPut.FieldByName('OTCH').AsString);

//              if OutPut.FieldByName('DATER').AsString<>''
//                then AktAdopt.DokumentOTEC_DATER.AsDateTime := STOD( OutPut.FieldByName('DATER').AsString, tdClipper);
              Decode_Date2(OutPut.FieldByName('DATER').AsString, dDate, nType);
              if dDate<>0
                then AktAdopt.DokumentOTEC_DATER.AsDateTime:=dDate;

              if LoadGrag then
                AktAdopt.DokumentOTEC_GRAG.AsString    := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
              AktAdopt.DokumentOTEC_STATUS.AsString  := OutPut.FieldByName('K_STATUS').AsString;
              //-------------����� ����������
              if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
                AktAdopt.DokumentOTEC_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');

                DecodeObl_MestoGit( AktAdopt.Dokument,'OTEC_OBL','OTEC_B_OBL','',OutPut);
                //AktAdopt.DokumentOTEC_B_OBL.AsString:='';
                //AktAdopt.DokumentOTEC_OBL.AsString:=Decode_Obl(OutPut.FieldByName('N_OBL').AsString,'');

                AktAdopt.DokumentOTEC_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');

                DecodePunkt_MestoGit(Akt.Dokument, 'OTEC_B_GOROD', 'OTEC_GOROD', '', OutPut);
                //AktAdopt.DokumentOTEC_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD').AsString);
                //AktAdopt.DokumentOTEC_GOROD.AsString:=OutPut.FieldByName('N_GOROD').AsString;

                AktAdopt.DokumentOTEC_GOROD_R.AsString:=GetGorodR(OutPut);
              end;
              //---------------����� ��������
              AktAdopt.DokumentOTEC_M_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString);

              DecodeObl_MestoRogd( AktAdopt.Dokument,'OTEC_M_OBL','OTEC_M_B_OBL','',OutPut);
              //AktAdopt.DokumentOTEC_M_B_OBL.AsString:='';
              //AktAdopt.DokumentOTEC_M_OBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,'');

              AktAdopt.DokumentOTEC_M_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,'');

              DecodePunkt_MestoRogd(Akt.Dokument, 'OTEC_M_B_GOROD', 'OTEC_M_GOROD', '', OutPut);
              //AktAdopt.DokumentOTEC_M_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString);
              //AktAdopt.DokumentOTEC_M_GOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString;

            end;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ �� ���� ! ');
            Result:=false;
          end;
        end;
        //�����������
        if Result and MaleU then begin
          if OutPut.Locate('PREFIX','ON',[]) then begin
            if (OutPut.FieldByName('K_POL').AsString<>'') and (Decode_Pol(OutPut.FieldByName('K_POL').AsString)='�') then begin
              ShowMessageErr('� �������� �������������� ����������� ������ ������������� ������� !');
              Result:=false;
            end else begin
              PoleGrnSub:=PoleGrnSub or bMaleU;
              //������������ ������
              AktAdopt.DokumentON_IDENTIF.AsString   := OutPut.FieldByName('IDENTIF').AsString;
              AktAdopt.DokumentON_Familia.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
              AktAdopt.DokumentON_Familia_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
              AktAdopt.DokumentON_NAME.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
              AktAdopt.DokumentON_NAME_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
              AktAdopt.DokumentON_OTCH.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
              AktAdopt.DokumentON_OTCH_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);

//              if OutPut.FieldByName('DATER').AsString<>''
//                then AktAdopt.DokumentON_DATER.AsDateTime   := STOD( OutPut.FieldByName('DATER').AsString, tdClipper);
              Decode_Date2(OutPut.FieldByName('DATER').AsString, dDate, nType);
              if dDate<>0
                then AktAdopt.DokumentON_DATER.AsDateTime:=dDate;

              if LoadGrag then
                AktAdopt.DokumentON_GRAG.AsString      := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
              AktAdopt.DokumentON_STATUS.AsString    := OutPut.FieldByName('K_STATUS').AsString;
              //���������� ������ (�������� �������������� ��������)
              AktAdopt.DokumentON_DOK_TYPE.AsString:=Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString);
              AktAdopt.DokumentON_DOK_ORGAN.AsString:=OutPut.FieldByName('K_DOC_ORGAN').AsString;
              AktAdopt.DokumentON_DOK_NAME.AsString:=OutPut.FieldByName('N_DOC_ORGAN').AsString;
              AktAdopt.DokumentON_DOK_SERIA.AsString:=OutPut.FieldByName('DOC_SERIA').AsString;
              AktAdopt.DokumentON_DOK_NOMER.AsString:=OutPut.FieldByName('DOC_NOMER').AsString;
              AktAdopt.DokumentON_DOK_DATE.AsDateTime:=OutPut.FieldByName('DOC_DATE').AsDateTime;
              p := dmBase.PasportFromValues(AktAdopt.DokumentON_DOK_TYPE.AsInteger,
                      AktAdopt.DokumentON_DOK_SERIA.AsString, AktAdopt.DokumentON_DOK_NOMER.AsString,
                      AktAdopt.DokumentON_DOK_NAME.AsString, '', AktAdopt.DokumentON_DOK_DATE.AsDateTime);
              s := dmBase.PasportToText(p,0);
              if s<>''
                then AktAdopt.DokumentON_DOKUMENT.AsString:=s;

              //-----------------------����� ����������
              if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
                AktAdopt.DokumentON_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');

                DecodeObl_MestoGit( AktAdopt.Dokument,'ON_OBL','ON_B_OBL','',OutPut);
                //AktAdopt.DokumentON_B_OBL.AsString:='';
                //AktAdopt.DokumentON_OBL.AsString:=Decode_Obl(OutPut.FieldByName('N_OBL').AsString,'');

                AktAdopt.DokumentON_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');

                DecodePunkt_MestoGit(AktAdopt.Dokument, 'ON_B_GOROD', 'ON_GOROD', '', OutPut);
                //AktAdopt.DokumentON_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD').AsString);
                //AktAdopt.DokumentON_GOROD.AsString:=OutPut.FieldByName('N_GOROD').AsString;

                AktAdopt.DokumentON_GOROD_R.AsString:=GetGorodR(OutPut);
              end;
              //------------------------����� ��������
              AktAdopt.DokumentON_M_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString);

              DecodeObl_MestoRogd( AktAdopt.Dokument,'ON_M_OBL','ON_M_B_OBL','',OutPut);
              //AktAdopt.DokumentON_M_B_OBL.AsString:='';
              //AktAdopt.DokumentON_M_OBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,'');

              AktAdopt.DokumentON_M_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,'');

              DecodePunkt_MestoRogd(AktAdopt.Dokument, 'ON_M_B_GOROD', 'ON_M_GOROD', '', OutPut);
              //AktAdopt.DokumentON_M_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString);
              //AktAdopt.DokumentON_M_GOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString;
            end;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ �� ����������� ! ');
            Result:=false;
          end;
        end;
        //����
        if Result and Female then begin
          if OutPut.Locate('PREFIX','MAT',[]) then begin
            if (OutPut.FieldByName('K_POL').AsString<>'') and (OutPut.FieldByName('K_POL').AsString='M') then begin
              ShowMessageErr('� �������� �������������� ������ ������ ������������� ������� !');
              Result:=false;
            end else begin
              PoleGrnSub:=PoleGrnSub or bFemale;
              //������������ ������
              AktAdopt.DokumentMAT_IDENTIF.AsString   := OutPut.FieldByName('IDENTIF').AsString;
              AktAdopt.DokumentMAT_Familia.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
              AktAdopt.DokumentMAT_NAME.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
              AktAdopt.DokumentMAT_OTCH.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);

//              if OutPut.FieldByName('DATER').AsString<>''
//                then AktAdopt.DokumentMAT_DATER.AsDateTime   := STOD( OutPut.FieldByName('DATER').AsString, tdClipper);
              Decode_Date2(OutPut.FieldByName('DATER').AsString, dDate, nType);
              if dDate<>0
                then AktAdopt.DokumentMAT_DATER.AsDateTime:=dDate;

              if LoadGrag then
                AktAdopt.DokumentMAT_GRAG.AsString      := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
              AktAdopt.DokumentMAT_STATUS.AsString    := OutPut.FieldByName('K_STATUS').AsString;
              //--------------------------����� ����������
              if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
                AktAdopt.DokumentMAT_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');

                DecodeObl_MestoGit( AktAdopt.Dokument,'MAT_OBL','MAT_B_OBL','',OutPut);
                //AktAdopt.DokumentMAT_B_OBL.AsString:='';
                //AktAdopt.DokumentMAT_OBL.AsString:=Decode_Obl(OutPut.FieldByName('N_OBL').AsString,'');

                AktAdopt.DokumentMAT_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');

                DecodePunkt_MestoGit(AktAdopt.Dokument, 'MAT_B_GOROD', 'MAT_GOROD', '', OutPut);
                //AktAdopt.DokumentMAT_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD').AsString);
                //AktAdopt.DokumentMAT_GOROD.AsString:=OutPut.FieldByName('N_GOROD').AsString;

                AktAdopt.DokumentMAT_GOROD_R.AsString:=GetGorodR(OutPut);
              end;
              //--------------------------����� ��������
              AktAdopt.DokumentMAT_M_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString);

              DecodeObl_MestoRogd( AktAdopt.Dokument,'MAT_M_OBL','MAT_M_B_OBL','',OutPut);
              //AktAdopt.DokumentMAT_M_B_OBL.AsString:='';
              //AktAdopt.DokumentMAT_M_OBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,'');

              AktAdopt.DokumentMAT_M_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,'');

              DecodePunkt_MestoRogd(AktAdopt.Dokument, 'MAT_M_B_GOROD', 'MAT_M_GOROD', '', OutPut);
              //AktAdopt.DokumentMAT_M_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString);
              //AktAdopt.DokumentMAT_M_GOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString;
            end;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ � ������ ! ');
            Result:=false;
          end;
        end;
        //���������������
        if Result and FemaleU then begin
          if OutPut.Locate('PREFIX','ONA',[]) then begin
            if (OutPut.FieldByName('K_POL').AsString<>'') and (OutPut.FieldByName('K_POL').AsString='M') then begin
              ShowMessageErr('� �������� �������������� ��������������� ������ ������������� ������� !');
              Result:=false;
            end else begin
              PoleGrnSub:=PoleGrnSub or bFemaleU;
              //������������ ������
              AktAdopt.DokumentONA_IDENTIF.AsString   := OutPut.FieldByName('IDENTIF').AsString;
              AktAdopt.DokumentONA_Familia.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
              AktAdopt.DokumentONA_Familia_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
              AktAdopt.DokumentONA_NAME.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
              AktAdopt.DokumentONA_NAME_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
              AktAdopt.DokumentONA_OTCH.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
              AktAdopt.DokumentONA_OTCH_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);

//              if OutPut.FieldByName('DATER').AsString<>''
//                then AktAdopt.DokumentONA_DATER.AsDateTime   := STOD( OutPut.FieldByName('DATER').AsString, tdClipper);
              Decode_Date2(OutPut.FieldByName('DATER').AsString, dDate, nType);
              if dDate<>0
                then AktAdopt.DokumentONA_DATER.AsDateTime:=dDate;

              if LoadGrag then
                AktAdopt.DokumentONA_GRAG.AsString      := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
              AktAdopt.DokumentONA_STATUS.AsString    := OutPut.FieldByName('K_STATUS').AsString;
              //���������� ������ (�������� �������������� ��������)
              AktAdopt.DokumentONA_DOK_TYPE.AsString:=Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString);
              AktAdopt.DokumentONA_DOK_ORGAN.AsString:=OutPut.FieldByName('K_DOC_ORGAN').AsString;
              AktAdopt.DokumentONA_DOK_NAME.AsString:=OutPut.FieldByName('N_DOC_ORGAN').AsString;
              AktAdopt.DokumentONA_DOK_SERIA.AsString:=OutPut.FieldByName('DOC_SERIA').AsString;
              AktAdopt.DokumentONA_DOK_NOMER.AsString:=OutPut.FieldByName('DOC_NOMER').AsString;
              AktAdopt.DokumentONA_DOK_DATE.AsDateTime:=OutPut.FieldByName('DOC_DATE').AsDateTime;
              p := dmBase.PasportFromValues(AktAdopt.DokumentONA_DOK_TYPE.AsInteger,
                      AktAdopt.DokumentONA_DOK_SERIA.AsString, AktAdopt.DokumentONA_DOK_NOMER.AsString,
                      AktAdopt.DokumentONA_DOK_NAME.AsString, '', AktAdopt.DokumentONA_DOK_DATE.AsDateTime);
              s := dmBase.PasportToText(p,0);
              if s<>''
                then AktAdopt.DokumentONA_DOKUMENT.AsString:=s;
              //------------------------------����� ����������
              if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
                AktAdopt.DokumentONA_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');

                DecodeObl_MestoGit( AktAdopt.Dokument,'ONA_OBL','ONA_B_OBL','',OutPut);
                //AktAdopt.DokumentONA_B_OBL.AsString:='';
                //AktAdopt.DokumentONA_OBL.AsString:=Decode_Obl(OutPut.FieldByName('N_OBL').AsString,'');

                AktAdopt.DokumentONA_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');

                DecodePunkt_MestoGit(AktAdopt.Dokument, 'ONA_B_GOROD', 'ONA_GOROD', '', OutPut);
                //AktAdopt.DokumentONA_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD').AsString);
                //AktAdopt.DokumentONA_GOROD.AsString:=OutPut.FieldByName('N_GOROD').AsString;

                AktAdopt.DokumentONA_GOROD_R.AsString:=GetGorodR(OutPut);
              end;
              //------------------------------����� ��������
              AktAdopt.DokumentONA_M_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString);

              DecodeObl_MestoRogd( AktAdopt.Dokument,'ONA_M_OBL','ONA_M_B_OBL','',OutPut);
              //AktAdopt.DokumentONA_M_B_OBL.AsString:='';
              //AktAdopt.DokumentONA_M_OBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,'');

              AktAdopt.DokumentONA_M_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,'');

              DecodePunkt_MestoRogd(AktAdopt.Dokument, 'ONA_M_B_GOROD', 'ONA_M_GOROD', '', OutPut);
              //AktAdopt.DokumentONA_M_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString);
              //AktAdopt.DokumentONA_M_GOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString;
            end;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ �� ��������������� ! ');
            Result:=false;
          end;
        end;
        if not Result then begin
          SetPoleGrn(AktAdopt.DokumentPOLE_GRN, 0, 0);
        end else begin
          SetPoleGrn(AktAdopt.DokumentPOLE_GRN, 2, PoleGrnSub);
          AktAdopt.DokumentTypeMessage.AsString:=TypeMessage;
        end;
        AktAdopt.Dokument.Post;
      end else begin
        HandleError(RequestResult, akAdoption, opGet, Input, Output, Error, RegInt.FaultError);
      end;
      ClearDataSets;
    end;
  end;
{$ENDIF}
end;

//----------------------------------------------------------------------------
//  ������ ������ ��� ���� � �������� �����
function TGisun.GetChName(Akt: TfmSimpleD): Boolean;
{$IFDEF ZAGS}
var
  AktChName : TfmZapisChName;
  strError : String;
  PoleGrnSub,nType : Integer;
  dDate:TDateTime;
{$ENDIF}
begin
  Result:=false;
{$IFDEF ZAGS}
  AktChName := TfmZapisChName(Akt);
  AktChName.Dokument.CheckBrowseMode;
  if not SetTypeMessageAktChName( AktChName, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end else begin
    ClearDataSets;
    if RunExchange then begin
      PoleGrnSub:=0;
      //[1] ������ ������
      //1. ������ ������� ��� �������� ������ � �������
      Input:=FRegInt.CreateInputTable(akNameChange, opGet);
      //2. ��������� ������������ ������
      //�������
      if Person then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='MAN';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktChName.DokumentIDENTIF.AsString);
        Input.Post;
      end;
      //3. ��������� ������ � �������
      RequestResult:=RegInt.Get(akNameChange, TypeMessage, Input, Output, Error);
      if IsDebug then begin
         RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_get.txt');
      end;
      if RequestResult=rrOk then begin
        Result:=true;
        AktChName.Dokument.Edit;
        AktChName.DokumentSTATUS.AsString  := '';
        AktChName.DokumentTypeMessage.AsString:='';
        AktChName.MessageID:=RegInt.RequestMessageId;  // �������� ID �������
        if Person then begin
          if OutPut.Locate('PREFIX','MAN',[]) then begin
            PoleGrnSub:=PoleGrnSub or bPerson;
            //������������ ������ ��������
            AktChName.DokumentIDENTIF.AsString     := OutPut.FieldByName('IDENTIF').AsString;
            AktChName.DokumentFamiliaDo.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
            AktChName.DokumentFamiliaDo_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
            AktChName.DokumentNameDo.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
            AktChName.DokumentNameDo_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
            AktChName.DokumentOtchDo.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
            AktChName.DokumentOtchDo_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);

//            AktChName.DokumentDATER.AsDateTime   := STOD( OutPut.FieldByName('DATER').AsString, tdClipper);
            Decode_Date2(OutPut.FieldByName('DATER').AsString, dDate, nType);
            if dDate<>0
              then AktChName.DokumentDATER.AsDateTime:=dDate;

            AktChName.DokumentPOL.AsString   := Decode_Pol(OutPut.FieldByName('K_POL').AsString);
            if LoadGrag then
              AktChName.DokumentGRAG.AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
            AktChName.DokumentSTATUS.AsString := OutPut.FieldByName('K_STATUS').AsString;

            //���������� ������ (��������, �������������� ��������)
            AktChName.DokumentDOK_TYPE.AsString:=Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString);
            AktChName.DokumentDOK_ORGAN.AsString:=OutPut.FieldByName('K_DOC_ORGAN').AsString;
            AktChName.DokumentDOKUMENT.AsString:=OutPut.FieldByName('N_DOC_ORGAN').AsString;
            AktChName.DokumentDOK_SERIA.AsString:=OutPut.FieldByName('DOC_SERIA').AsString;
            AktChName.DokumentDOK_NOMER.AsString:=OutPut.FieldByName('DOC_NOMER').AsString;
            AktChName.DokumentDOK_DATE.AsDateTime:=OutPut.FieldByName('DOC_DATE').AsDateTime;
            // ����� ��������
            AktChName.DokumentGOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString); //������ ��������

            DecodeObl_MestoRogd( AktChName.Dokument,'OBL','B_OBL','OBL_B',OutPut);
            //AktChName.DokumentB_OBL.AsString:='';
            //AktChName.DokumentOBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,OutPut.FieldByName('OBL_B_R').AsString); //������� ��������
            //AktChName.DokumentOBL_B.AsString:=OutPut.FieldByName('OBL_B_R').AsString; //������� ��������

            AktChName.DokumentRAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,OutPut.FieldByName('RAION_B_R').AsString); //����� ��������
            AktChName.DokumentRAION_B.AsString:=CaseAdres(OutPut.FieldByName('RAION_B_R').AsString); //����� ��������

            DecodePunkt_MestoRogd(Akt.Dokument, 'B_GOROD', 'GOROD', 'GOROD_B', OutPut);
            //AktChName.DokumentB_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString); //��� ���������� ������ ��������
            //AktChName.DokumentGOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString; //��������� ����� �� ������� �����
            //AktChName.DokumentGOROD_B.AsString:=OutPut.FieldByName('GOROD_B_R').AsString; //��������� ����� �� ������� �����

            // ����� ����������
            if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
              AktChName.DokumentM_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');

              DecodeObl_MestoGit( AktChName.Dokument,'M_OBL','M_B_OBL','',OutPut);
              //AktChName.DokumentM_B_OBL.AsString:='';
              //AktChName.DokumentM_OBL.AsString:=Decode_Obl(OutPut.FieldByName('N_OBL').AsString,'');

              AktChName.DokumentM_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');

              DecodePunkt_MestoGit(AktChName.Dokument, 'M_B_GOROD', 'M_GOROD', '', OutPut);
              //AktChName.DokumentM_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD').AsString);
              //AktChName.DokumentM_GOROD.AsString:=OutPut.FieldByName('N_GOROD').AsString;

              AktChName.DokumentM_GOROD_R.AsString:=GetGorodR(OutPut);
            end;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ �� �������� ! ');
            Result:=false;
          end;
        end;
        if not Result then begin
          SetPoleGrn(AktChName.DokumentPOLE_GRN, 0, 0);
        end else begin
          SetPoleGrn(AktChName.DokumentPOLE_GRN, 2, PoleGrnSub);
          AktChName.DokumentTypeMessage.AsString:=TypeMessage;
        end;
        AktChName.Dokument.Post;
      end else begin
        HandleError(RequestResult, akNameChange, opGet, Input, Output, Error, RegInt.FaultError);
      end;
      ClearDataSets;
    end;
  end;
{$ENDIF}
end;

//---------------------------------------------------------------------
//  ����������� ���� �� �����������
function TGisun.RegisterAdopt(Akt: TfmSimpleD): Boolean;
{$IFDEF ZAGS}
var
  AktAdopt : TfmZapisAdopt;
  strError : String;
{$ENDIF}
begin
  Result:=true;
{$IFDEF ZAGS}
  AktAdopt := TfmZapisAdopt(Akt);
  AktAdopt.Dokument.CheckBrowseMode;
  if not SetTypeMessageAktAdopt( AktAdopt, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end;
  if Result then begin
    if (AktAdopt.DokumentFamiliaPosle_B.AsString='') then begin
      strError:=strError+'��������� ������� ������� �� ����������� ����� ����� �����������'+#13#10;
    end;
    if (AktAdopt.DokumentFamiliaPosle.AsString='') then begin
      strError:=strError+'��������� ������� ������� �� ������� ����� ����� �����������'+#13#10;
    end;
    if (AktAdopt.DokumentNamePosle_B.AsString='') then begin
      strError:=strError+'��������� ��� ������� �� ����������� ����� ����� �����������'+#13#10;
    end;
    if (AktAdopt.DokumentNamePosle.AsString='') then begin
      strError:=strError+'��������� ��� ������� �� ������� ����� ����� �����������'+#13#10;
    end;
    if AktAdopt.DokumentOtchPosle.AsString<>'' then begin // ���� �������� �� ������� �� �����
      if (AktAdopt.DokumentOtchPosle_B.AsString='') then begin
        strError:=strError+'��������� �������� ������� �� ����������� ����� ����� �����������'+#13#10;
      end;
    end;
//    if (AktAdopt.DokumentOtchPosle.AsString='') then begin
//      strError:=strError+'��������� �������� ������� �� ������� ����� ����� �����������'+#13#10;
//    end;
    if (AktAdopt.DokumentGOROD_POSLE.AsString='') then begin
      strError:=strError+'��������� ���. ����� �������� ������� �� ������� ����� ����� �����������'+#13#10;
    end;
    if (AktAdopt.DokumentGOROD_POSLE_B.AsString='') then begin
      strError:=strError+'��������� ���. ����� �������� ������� �� ����������� ����� ����� �����������'+#13#10;
    end;
    CheckAllAkt(AktAdopt,strError);
    if strError<>'' then begin
      ShowMessageErr(strError);
      Result:=false;
    end;
  end;
  if Result then begin
    Result:=false;
    ClearDataSets;
    //[2] �������� ������
    //1. ������ ������� ��� �������� ������ � �������
    Input:=FRegInt.CreateInputTable(akAdoption, opPost);
    //2. ��������� ������������ ������
    Input.Append;
    //�������� �� ������������
    //����������������� ����� �������������
    Input.FieldByName('IDENTIF').AsString:=AktAdopt.DokumentIDENTIF_Posle.AsString;
    //�������� �� ������������ �� �����������
    //������������ ������ ������������� �� �����������
    Input.FieldByName('DO_IDENTIF').AsString:=AktAdopt.DokumentIDENTIF_Do.AsString; //������������ �����
    Input.FieldByName('DO_FAMILIA').AsString:=AktAdopt.DokumentFamiliaDo.AsString; //������� �� ������� �����
    Input.FieldByName('DO_FAMILIA_B').AsString:=AktAdopt.DokumentFamiliaDo_B.AsString; //������� �� ����������� �����
    Input.FieldByName('DO_NAME').AsString:=AktAdopt.DokumentNameDo.AsString; //��� �� ������� �����
    Input.FieldByName('DO_NAME_B').AsString:=AktAdopt.DokumentNAMEDo_B.AsString; //��� �� ����������� �����
    Input.FieldByName('DO_OTCH').AsString:=AktAdopt.DokumentOtchDo.AsString;
    Input.FieldByName('DO_OTCH_B').AsString:=AktAdopt.DokumentOtchDo_B.AsString;
    Input.FieldByName('DO_POL').AsString:=Code_Pol(AktAdopt.DokumentPOL.AsString);
    Input.FieldByName('DO_DATER').AsString:=DTOS(AktAdopt.DokumentDateR_Do.AsDateTime,tdClipper); //���� ��������
    Input.FieldByName('DO_GRAJD').AsString:=Code_Alfa3(AktAdopt.DokumentGRAG_Do.AsString);; //�����������
    Input.FieldByName('DO_STATUS').AsString:=AktAdopt.DokumentSTATUS.AsString; //������
    //------------------------����� ��������
    Input.FieldByName('DO_GOSUD').AsString:=Code_Alfa3(AktAdopt.DokumentGOSUD_DO.AsString); //������ ��������

    CodeObl_MestoRogd( AktAdopt.Dokument,'OBL_DO','B_OBL_DO','OBL_DO_B',Input,'DO_OBL','DO_OBL_B');
    //Input.FieldByName('DO_OBL').AsString:=AktAdopt.DokumentOBL_DO.AsString;
    //Input.FieldByName('DO_OBL_B').AsString:=AktAdopt.DokumentOBL_DO_B.AsString;

    Input.FieldByName('DO_RAION').AsString:=AktAdopt.DokumentRAION_DO.AsString;
    Input.FieldByName('DO_RAION_B').AsString:=AktAdopt.DokumentRAION_DO_B.AsString;

    CodePunkt_MestoRogd(AktAdopt.Dokument, 'B_GOROD_DO','GOROD_DO','GOROD_DO_B',Input,'DO_TIP_GOROD','DO_GOROD','DO_GOROD_B');
    //Input.FieldByName('DO_TIP_GOROD').AsString:=Code_TypePunkt(AktAdopt.DokumentB_GOROD_DO.AsString);  //��� ���������� ������
    //Input.FieldByName('DO_GOROD').AsString:=AktAdopt.DokumentGOROD_DO.AsString; //��������� ����� �� ������� �����
    //Input.FieldByName('DO_GOROD_B').AsString:=AktAdopt.DokumentGOROD_DO_B.AsString; //��������� ����� �� ����������� �����

    //���������� �� ���� � �������� (�� �����������)
    Input.FieldByName('DO_TIP').AsString:='0100'; //��� ������� ������
    Input.FieldByName('DO_ORGAN').AsString:='0'; //MessageSource; //!!! REG_MESTO_POSLE ??? ���. �����, ������������� ������� ������
    Input.FieldByName('DO_DATE').AsDateTime:=AktAdopt.DokumentREG_DATE_DO.AsDateTime; //���� ������� ������
    Input.FieldByName('DO_NOMER').AsString:=AktAdopt.DokumentREG_NOMER_DO.AsString; //����� ������� ������
    //�������� �� ������������ ����� �����������
    //������������ ������ ������������� ����� �����������
    Input.FieldByName('PO_IDENTIF').AsString:=AktAdopt.DokumentIDENTIF_Posle.AsString; //������������ �����
    Input.FieldByName('PO_FAMILIA').AsString:=G_UpperCase(AktAdopt.DokumentFamiliaPosle.AsString); //������� �� ������� �����
    Input.FieldByName('PO_FAMILIA_B').AsString:=G_UpperCase(AktAdopt.DokumentFamiliaPosle_B.AsString); //������� �� ����������� �����
    Input.FieldByName('PO_NAME').AsString:=G_UpperCase(AktAdopt.DokumentNamePosle.AsString); //��� �� ������� �����
    Input.FieldByName('PO_NAME_B').AsString:=G_UpperCase(AktAdopt.DokumentNAMEPosle_B.AsString); //��� �� ����������� �����
    Input.FieldByName('PO_OTCH').AsString:=G_UpperCase(AktAdopt.DokumentOtchPosle.AsString);
    Input.FieldByName('PO_OTCH_B').AsString:=G_UpperCase(AktAdopt.DokumentOtchPosle_B.AsString);
    Input.FieldByName('PO_POL').AsString:=Code_Pol(AktAdopt.DokumentPOL.AsString);
{!!!}Input.FieldByName('PO_DATER').AsString:=DTOS(AktAdopt.DokumentDateR_Posle.AsDateTime,tdClipper); //���� ��������
{!!!}Input.FieldByName('PO_GRAJD').AsString:='BLR';//Code_Alfa3(AktAdopt.DokumentGRAG_Posle.AsString);; //�����������
    Input.FieldByName('PO_STATUS').AsString:=AktAdopt.DokumentSTATUS.AsString; //������
    //-------------------------����� ��������
    Input.FieldByName('PO_GOSUD').AsString:=Code_Alfa3(AktAdopt.DokumentGOSUD_Posle.AsString); //������ ��������

    CodeObl_MestoRogd( AktAdopt.Dokument,'OBL_POSLE','B_OBL_POSLE','OBL_POSLE_B',Input,'PO_OBL','PO_OBL_B');
    //Input.FieldByName('PO_OBL').AsString:=AktAdopt.DokumentOBL_Posle.AsString;
    //--Input.FieldByName('PO_OBL_B').AsString:=AktAdopt.DokumentOBL_DO_B.AsString;

    Input.FieldByName('PO_RAION').AsString:=AktAdopt.DokumentRAION_Posle.AsString;
    //--Input.FieldByName('PO_RAION_B').AsString:=AktAdopt.DokumentRAION_DO_B.AsString;

    CodePunkt_MestoRogd(AktAdopt.Dokument, 'B_GOROD_POSLE','GOROD_POSLE','GOROD_POSLE_B',Input,'PO_TIP_GOROD','PO_GOROD','PO_GOROD_B');
    //Input.FieldByName('PO_TIP_GOROD').AsString:=Code_TypePunkt(AktAdopt.DokumentB_GOROD_Posle.AsString);  //��� ���������� ������
    //Input.FieldByName('PO_GOROD').AsString:=AktAdopt.DokumentGOROD_Posle.AsString; //��������� ����� �� ������� �����
    //Input.FieldByName('PO_GOROD_B').AsString:=AktAdopt.DokumentGOROD_POSLE_B.AsString; //??? (�� ��������) ��������� ����� �� ����������� �����

    //���������� �� ���� � �������� (�� �����������)
    Input.FieldByName('PO_TIP').AsString:='0100'; //��� ������� ������
    Input.FieldByName('PO_ORGAN').AsString:='0'; //MessageSource; //!!! REG_MESTO_POSLE ??? ���. �����, ������������� ������� ������
    Input.FieldByName('PO_DATE').AsDateTime:=AktAdopt.DokumentREG_DATE_Posle.AsDateTime; //���� ������� ������
    Input.FieldByName('PO_NOMER').AsString:=AktAdopt.DokumentREG_NOMER_Posle.AsString; //����� ������� ������
//    if Female then begin
      //-------------------������������ ������ ������------------------
      Input.FieldByName('ONA_IDENTIF').AsString:=AktAdopt.DokumentMAT_IDENTIF.AsString; //������������ �����
      Input.FieldByName('ONA_FAMILIA').AsString:=AktAdopt.DokumentMAT_FAMILIA.AsString; //������� �� ������� �����
      //--Input.FieldByName('ONA_FAMILIA_B').AsString:=AktAdopt.DokumentMAT_FAMILIA_B.AsString; //������� �� ����������� �����
      Input.FieldByName('ONA_NAME').AsString:=AktAdopt.DokumentMAT_NAME.AsString; //��� �� ������� �����
      //--Input.FieldByName('ONA_NAME_B').AsString:=AktAdopt.DokumentMAT_NAME_B.AsString; //��� �� ����������� �����
      Input.FieldByName('ONA_OTCH').AsString:=AktAdopt.DokumentMAT_OTCH.AsString; //�������� �� ������� �����
      //--Input.FieldByName('ONA_OTCH_B').AsString:=AktAdopt.DokumentMAT_OTCH_B.AsString; //�������� �� ����������� �����
      Input.FieldByName('ONA_POL').AsString:='F'; //���
      Input.FieldByName('ONA_DATER').AsString:=DTOS(AktAdopt.DokumentMAT_DATER.AsDateTime,tdClipper); //���� ��������
      Input.FieldByName('ONA_GRAJD').AsString:=Code_Alfa3(AktAdopt.DokumentMAT_GRAG.AsString); //�����������
//      Input.FieldByName('ONA_STATUS').AsString:=AktAdopt.DokumentMAT_STATUS.AsString; //������
      Input.FieldByName('ONA_STATUS').AsString:=Code_Status(AktAdopt.Dokument, 'MAT_GRAG', 'MAT_STATUS');

      //����� ��������
      Input.FieldByName('ONA_GOSUD').AsString:=Code_Alfa3(AktAdopt.DokumentMAT_M_GOSUD.AsString); //������ ��������

      CodeObl_MestoRogd( AktAdopt.Dokument,'MAT_M_OBL','MAT_M_B_OBL','',Input,'ONA_OBL','');
      //Input.FieldByName('ONA_OBL').AsString:=AktAdopt.DokumentMAT_M_OBL.AsString; //������� ��������

      Input.FieldByName('ONA_RAION').AsString:=AktAdopt.DokumentMAT_M_RAION.AsString; //����� ��������

      CodePunkt_MestoRogd(AktAdopt.Dokument, 'MAT_M_B_GOROD','MAT_M_GOROD','',Input,'ONA_TIP_GOROD','ONA_GOROD','');
      //Input.FieldByName('ONA_TIP_GOROD').AsString:=Code_TypePunkt(AktAdopt.DokumentMAT_M_B_GOROD.AsString); //��� ���������� ������
      //Input.FieldByName('ONA_GOROD').AsString:=AktAdopt.DokumentMAT_M_GOROD.AsString; //��������� ����� �� ������� �����
//    end;

//    if Male then begin
      //--------------------������������ ������ ����-----------------------------
      Input.FieldByName('ON_IDENTIF').AsString:=AktAdopt.DokumentOTEC_IDENTIF.AsString; //������������ �����
      Input.FieldByName('ON_FAMILIA').AsString:=AktAdopt.DokumentOTEC_FAMILIA.AsString; //������� �� ������� �����
      //--Input.FieldByName('ON_FAMILIA_B').AsString:=AktAdopt.DokumentOTEC_FAMILIA_B.AsString; //������� �� ����������� �����
      Input.FieldByName('ON_NAME').AsString:=AktAdopt.DokumentOTEC_NAME.AsString; //��� �� ������� �����
      //--Input.FieldByName('ON_NAME_B').AsString:=AktAdopt.DokumentOTEC_NAME_B.AsString; //��� �� ����������� �����
      Input.FieldByName('ON_OTCH').AsString:=AktAdopt.DokumentOTEC_OTCH.AsString; //�������� �� ������� �����
      //--Input.FieldByName('ON_OTCH_B').AsString:=AktAdopt.DokumentOTEC_OTCH_B.AsString; //�������� �� ����������� �����
      Input.FieldByName('ON_POL').AsString:='M'; //���
      Input.FieldByName('ON_GRAJD').AsString:=Code_Alfa3(AktAdopt.DokumentOTEC_GRAG.AsString); //�����������
      Input.FieldByName('ON_DATER').AsString:=DTOS(AktAdopt.DokumentOTEC_DATER.AsDateTime,tdClipper); //���� ��������

//      Input.FieldByName('ON_STATUS').AsString:=AktAdopt.DokumentOTEC_STATUS.AsString; //������
      Input.FieldByName('ON_STATUS').AsString:=Code_Status(AktAdopt.Dokument, 'OTEC_GRAG', 'OTEC_STATUS');

      //����� ��������
      Input.FieldByName('ON_GOSUD').AsString:=Code_Alfa3(AktAdopt.DokumentOTEC_M_GOSUD.AsString); //������ ��������

      CodeObl_MestoRogd( AktAdopt.Dokument,'OTEC_M_OBL','OTEC_M_B_OBL','',Input,'ON_OBL','');
      //Input.FieldByName('ON_OBL').AsString:=AktAdopt.DokumentOTEC_M_OBL.AsString; //������� ��������

      Input.FieldByName('ON_RAION').AsString:=AktAdopt.DokumentOTEC_M_RAION.AsString; //����� ��������

      CodePunkt_MestoRogd(AktAdopt.Dokument, 'OTEC_M_B_GOROD','OTEC_M_GOROD','',Input,'ON_TIP_GOROD','ON_GOROD','');
      //Input.FieldByName('ON_TIP_GOROD').AsString:=Code_TypePunkt(AktAdopt.DokumentOTEC_M_B_GOROD.AsString); //��� ���������� ������
      //Input.FieldByName('ON_GOROD').AsString:=AktAdopt.DokumentOTEC_M_GOROD.AsString; //��������� ����� �� ������� �����
//    end;

//    if FemaleU then begin
      //------------------------������������ ������ ���������������--------------------
      Input.FieldByName('ONA2_IDENTIF').AsString:=AktAdopt.DokumentONA_IDENTIF.AsString; //������������ �����
      Input.FieldByName('ONA2_FAMILIA').AsString:=AktAdopt.DokumentONA_FAMILIA.AsString; //������� �� ������� �����
      Input.FieldByName('ONA2_FAMILIA_B').AsString:=AktAdopt.DokumentONA_FAMILIA_B.AsString; //������� �� ����������� �����
      Input.FieldByName('ONA2_NAME').AsString:=AktAdopt.DokumentONA_NAME.AsString; //��� �� ������� �����
      Input.FieldByName('ONA2_NAME_B').AsString:=AktAdopt.DokumentONA_NAME_B.AsString; //��� �� ����������� �����
      Input.FieldByName('ONA2_OTCH').AsString:=AktAdopt.DokumentONA_OTCH.AsString; //�������� �� ������� �����
      Input.FieldByName('ONA2_OTCH_B').AsString:=AktAdopt.DokumentONA_OTCH_B.AsString; //�������� �� ����������� �����
      Input.FieldByName('ONA2_POL').AsString:='F'; //���
      Input.FieldByName('ONA2_DATER').AsString:=DTOS(AktAdopt.DokumentONA_DATER.AsDateTime,tdClipper); //���� ��������
      Input.FieldByName('ONA2_GRAJD').AsString:=Code_Alfa3(AktAdopt.DokumentONA_GRAG.AsString); //�����������
//      Input.FieldByName('ONA2_STATUS').AsString:=AktAdopt.DokumentONA_STATUS.AsString; //������
      Input.FieldByName('ONA2_STATUS').AsString:=Code_Status(AktAdopt.Dokument, 'ONA_GRAG', 'ONA_STATUS');

      //---------------------����� ��������
      Input.FieldByName('ONA2_GOSUD').AsString:=Code_Alfa3(AktAdopt.DokumentONA_M_GOSUD.AsString); //������ ��������

      CodeObl_MestoRogd( AktAdopt.Dokument,'ONA_M_OBL','ONA_M_B_OBL','',Input,'ONA2_OBL','');
      //Input.FieldByName('ONA2_OBL').AsString:=AktAdopt.DokumentONA_M_OBL.AsString; //������� ��������

      Input.FieldByName('ONA2_RAION').AsString:=AktAdopt.DokumentONA_M_RAION.AsString; //����� ��������

      CodePunkt_MestoRogd(AktAdopt.Dokument, 'ONA_M_B_GOROD','ONA_M_GOROD','',Input,'ONA2_TIP_GOROD','ONA2_GOROD','');
      //Input.FieldByName('ONA2_TIP_GOROD').AsString:=Code_TypePunkt(AktAdopt.DokumentONA_M_B_GOROD.AsString); //��� ���������� ������
      //Input.FieldByName('ONA2_GOROD').AsString:=AktAdopt.DokumentONA_M_GOROD.AsString; //��������� ����� �� ������� �����
//    end;
//    if MaleU then begin
      //--------------------------������������ ������ �����������--------------------------
      Input.FieldByName('ON2_IDENTIF').AsString:=AktAdopt.DokumentON_IDENTIF.AsString; //������������ �����
      Input.FieldByName('ON2_FAMILIA').AsString:=AktAdopt.DokumentON_FAMILIA.AsString; //������� �� ������� �����
      Input.FieldByName('ON2_FAMILIA_B').AsString:=AktAdopt.DokumentON_FAMILIA_B.AsString; //������� �� ����������� �����
      Input.FieldByName('ON2_NAME').AsString:=AktAdopt.DokumentON_NAME.AsString; //��� �� ������� �����
      Input.FieldByName('ON2_NAME_B').AsString:=AktAdopt.DokumentON_NAME_B.AsString; //��� �� ����������� �����
      Input.FieldByName('ON2_OTCH').AsString:=AktAdopt.DokumentON_OTCH.AsString; //�������� �� ������� �����
      Input.FieldByName('ON2_OTCH_B').AsString:=AktAdopt.DokumentON_OTCH_B.AsString; //�������� �� ����������� �����
      Input.FieldByName('ON2_POL').AsString:='M'; //���
      Input.FieldByName('ON2_GRAJD').AsString:=Code_Alfa3(AktAdopt.DokumentON_GRAG.AsString); //�����������
      Input.FieldByName('ON2_DATER').AsString:=DTOS(AktAdopt.DokumentON_DATER.AsDateTime,tdClipper); //���� ��������
//      Input.FieldByName('ON2_STATUS').AsString:=AktAdopt.DokumentON_STATUS.AsString; //������
      Input.FieldByName('ON2_STATUS').AsString:=Code_Status(AktAdopt.Dokument, 'ON_GRAG', 'ON_STATUS');
      //����� ��������
      Input.FieldByName('ON2_GOSUD').AsString:=Code_Alfa3(AktAdopt.DokumentON_M_GOSUD.AsString); //������ ��������

      CodeObl_MestoRogd( AktAdopt.Dokument,'ON_M_OBL','ON_M_B_OBL','',Input,'ON2_OBL','');
      //Input.FieldByName('ON2_OBL').AsString:=AktAdopt.DokumentON_M_OBL.AsString; //������� ��������

      Input.FieldByName('ON2_RAION').AsString:=AktAdopt.DokumentON_M_RAION.AsString; //����� ��������

      CodePunkt_MestoRogd(AktAdopt.Dokument, 'ON_M_B_GOROD','ON_M_GOROD','',Input,'ON2_TIP_GOROD','ON2_GOROD','');
      //Input.FieldByName('ON2_TIP_GOROD').AsString:=Code_TypePunkt(AktAdopt.DokumentON_M_B_GOROD.AsString); //��� ���������� ������
      //Input.FieldByName('ON2_GOROD').AsString:=AktAdopt.DokumentON_M_GOROD.AsString; //��������� ����� �� ������� �����
//    end;

    //�������� � ����������� ���������� �����
    //������� ���������� �����
//    if AktAdopt.DokumentBRAK_NOMER.AsString<>'' then begin
      if AktAdopt.DokumentBRAK_M.AsBoolean
        then Input.FieldByName('BRAK_FLAG').AsInteger:=Integer(adoptiveParentsMarr) //���� ����� �������������
        else Input.FieldByName('BRAK_FLAG').AsInteger:=Integer(parentAndAdoptiveMarr); //���� ����� ��������� � ������������
//    end
    //���������� �� ���� � ���������� �����
    Input.FieldByName('BRAK_TIP').AsString:='0300'; //��� ������� ������
    Input.FieldByName('BRAK_ORGAN').AsString:='0'; //MessageSource; //!!! BRAK_NAME ??? ���. �����, ������������� ������� ������
    Input.FieldByName('BRAK_DATE').AsDateTime:=AktAdopt.DokumentBRAK_DATE.AsDateTime; //���� ������� ������
    Input.FieldByName('BRAK_NOMER').AsString:=AktAdopt.DokumentBRAK_NOMER.AsString; //����� ������� ������

    //��������� ������ ���� �� ����������� (����������) - ������� ����
    Input.FieldByName('SUD_NAME').AsString:=AktAdopt.DokumentSUD_NAME.AsString; //������������ ����
    Input.FieldByName('SUD_DATE').AsString:=DTOS(AktAdopt.DokumentSUD_DATE.AsDateTime, tdClipper); //���� ��������� �������
    Input.FieldByName('SUD_COMM').AsString:=''; //??? ����������� � ��������� ������ ����
    //������������ �� ����������� ���������� ������
    if AktAdopt.DokumentISRODIT.AsBoolean
      then Input.FieldByName('RODIT_FLAG').AsInteger:=Integer(yes) //��
      else Input.FieldByName('RODIT_FLAG').AsInteger:=Integer(no); //���
    //���������� �� ������� ������
    Input.FieldByName('ACT_TIP').AsString:=TypeAkt; //��� ������� ������
    SetOrganAkt(AktAdopt, Input);
    Input.FieldByName('ACT_DATE').AsDateTime:=AktAdopt.Dokument.FieldByName('DATEZ').AsDateTime; //���� ������� ������
    Input.FieldByName('ACT_NOMER').AsString:=AktAdopt.Dokument.FieldByName('NOMER').AsString; //����� ������� ������

    SetDokSvid(AktAdopt, Input);

    Input.Post;
    //3. ��������� ������ � �������
    RequestResult:=RegInt.Post(AktAdopt.MessageID, akAdoption, AktAdopt.DokumentTypeMessage.AsString, Input, Error);
    LogToTableLog(AktAdopt, '����������� �/� �� �����������');
    if IsDebug then begin
       RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_post.txt');
    end;
    if RequestResult=rrOk then begin
      AktAdopt.Dokument.CheckBrowseMode;
      AktAdopt.Dokument.Edit;
      SetPoleGrn(AktAdopt.DokumentPOLE_GRN, 3);
      AktAdopt.Dokument.Post;
      if not HandleErrorToString
        then ShowMessageCont(GetMessageOk,CurAkt);
      Result:=true;
    end else begin
      Result:=false;
      //4.2. ������������ ������ �������������� � ���������
      HandleError(RequestResult, akAdoption, opGet, Input, Output, Error, FRegInt.FaultError);
    end;
  end;
{$ENDIF}
end;

//------------------------------------------------------------
// ����������� ���� � �������� �����
function TGisun.RegisterChName(Akt: TfmSimpleD): Boolean;
{$IFDEF ZAGS}
var
  AktChName : TfmZapisChName;
  strError : String;
{$ENDIF}
begin
  Result:=true;
{$IFDEF ZAGS}
  AktChName := TfmZapisChName(Akt);
  AktChName.Dokument.CheckBrowseMode;
  if not SetTypeMessageAktChName( AktChName, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end;
  if Result then begin
    strError:='';
    if (AktChName.DokumentFamiliaPosle_B.AsString='') then begin
      strError:=strError+'��������� ������� �� ����������� ����� ����� ��������'+#13#10;
    end;
    if (AktChName.DokumentFamiliaPosle.AsString='') then begin
      strError:=strError+'��������� ������� �� ������� ����� ����� ��������'+#13#10;
    end;
    if (AktChName.DokumentNamePosle_B.AsString='') then begin
      strError:=strError+'��������� ��� �� ����������� ����� ����� ��������'+#13#10;
    end;
    if (AktChName.DokumentNamePosle.AsString='') then begin
      strError:=strError+'��������� ��� �� ������� ����� ����� ��������'+#13#10;
    end;
    if AktChName.DokumentOtchPosle.AsString<>'' then begin // ���� �������� �� ������� �� �����
      if (AktChName.DokumentOtchPosle_B.AsString='') then begin
        strError:=strError+'��������� �������� �� ����������� ����� ����� ��������'+#13#10;
      end;
    end;
//    if (AktChName.DokumentOtchPosle.AsString='') then begin
//      strError:=strError+'��������� �������� �� ������� ����� ����� ��������'+#13#10;
//    end;
    CheckAllAkt(AktChName,strError);
    if strError<>'' then begin
      ShowMessageErr(strError);
      Result:=false;
    end;
  end;

  if Result then begin
    Result:=false;
    ClearDataSets;
    //[2] �������� ������
    //1. ������ ������� ��� �������� ������ � �������
    Input:=FRegInt.CreateInputTable(akNameChange, opPost);
    //2. ��������� ������������ ������
    Input.Append;
    //������������ ������ ��������
    Input.FieldByName('IDENTIF').AsString:=AktChName.DokumentIDENTIF.AsString; //������������ �����
    Input.FieldByName('FAMILIA').AsString:=G_UpperCase(AktChName.DokumentFamiliaPosle.AsString); //������� �� ������� �����
    Input.FieldByName('FAMILIA_B').AsString:=G_UpperCase(AktChName.DokumentFamiliaPosle_B.AsString); //������� �� ����������� �����
    Input.FieldByName('NAME').AsString:=G_UpperCase(AktChName.DokumentNamePosle.AsString); //��� �� ������� �����
    Input.FieldByName('NAME_B').AsString:=G_UpperCase(AktChName.DokumentNamePosle_B.AsString); //��� �� ����������� �����
    Input.FieldByName('OTCH').AsString:=G_UpperCase(AktChName.DokumentOtchPosle.AsString);
    Input.FieldByName('OTCH_B').AsString:=G_UpperCase(AktChName.DokumentOtchPosle_B.AsString);
    Input.FieldByName('POL').AsString:=Code_Pol(AktChName.DokumentPOL.AsString);
    Input.FieldByName('DATER').AsString:=Code_Date(AktChName.DokumentDateR.AsDateTime, DATE_FULL); //���� ��������
    Input.FieldByName('GRAJD').AsString:=Code_Alfa3(AktChName.DokumentGRAG.AsString); //�����������
    Input.FieldByName('STATUS').AsString:=AktChName.DokumentSTATUS.AsString; //������
    Input.FieldByName('DO_FAMILIA').AsString:=G_UpperCase(AktChName.DokumentFamiliaDo.AsString); // ������� �� �������� �����
    Input.FieldByName('DO_NAME').AsString:=G_UpperCase(AktChName.DokumentNameDo.AsString); // ��� �� �������� �����
    Input.FieldByName('DO_OTCH').AsString:=G_UpperCase(AktChName.DokumentOtchDo.AsString); // �������� �� �������� �����
    //����� ��������
    Input.FieldByName('GOSUD').AsString:=Code_Alfa3(AktChName.DokumentGOSUD.AsString); //������ ��������

    CodeObl_MestoRogd( AktChName.Dokument,'OBL','B_OBL','OBL_B',Input,'OBL','OBL_B');
    //Input.FieldByName('OBL').AsString:=AktChName.DokumentOBL.AsString; //������� ��������
    //Input.FieldByName('OBL_B').AsString:=AktChName.DokumentOBL_B.AsString; //������� ��������

    Input.FieldByName('RAION').AsString:=AktChName.DokumentRAION.AsString; //����� ��������
    Input.FieldByName('RAION_B').AsString:=AktChName.DokumentRAION_B.AsString; //����� ��������

    CodePunkt_MestoRogd(AktChName.Dokument, 'B_GOROD','GOROD','GOROD_B',Input,'TIP_GOROD','GOROD','GOROD_B');
    //Input.FieldByName('TIP_GOROD').AsString:=Code_TypePunkt(AktChName.DokumentB_GOROD.AsString); //��� ���������� ������
    //Input.FieldByName('GOROD').AsString:=AktChName.DokumentGOROD.AsString; //��������� ����� �� ������� �����
    //Input.FieldByName('GOROD_B').AsString:=AktChName.DokumentGOROD_B.AsString; //��������� ����� �� ������� �����

    //���������� �� ���� � ��������
    Input.FieldByName('R_TIP').AsString:='0100'; //��� ������� ������
    Input.FieldByName('R_ORGAN').AsString:='0'; //MessageSource; //REG_ZAGS ??? ���. �����, ������������� ������� ������
    Input.FieldByName('R_DATE').AsDateTime:=AktChName.DokumentREG_DATE.AsDateTime; //���� ������� ������
    Input.FieldByName('R_NOMER').AsString:=AktChName.DokumentREG_NOMER.AsString; //����� ������� ������
    //�������� � �����, �� ��������� 18 ���
    //???
    //��������� ������ ���� � �������� �����
    Input.FieldByName('OSNOV').AsString:=AktChName.DokumentOSNOV.AsString;
    //���������� �� ������� ������
    Input.FieldByName('ACT_TIP').AsString:=TypeAkt; //��� ������� ������
    SetOrganAkt(AktChName, Input);
    Input.FieldByName('ACT_DATE').AsDateTime:=AktChName.Dokument.FieldByName('DATEZ').AsDateTime; //���� ������� ������
    Input.FieldByName('ACT_NOMER').AsString:=AktChName.Dokument.FieldByName('NOMER').AsString; //����� ������� ������

    SetDokSvid(AktChName,Input);

    Input.Post;
    //3. ��������� ������ � �������
    RequestResult:=RegInt.Post(AktChName.MessageID, akNameChange, AktChName.DokumentTypeMessage.AsString, Input, Error);
    LogToTableLog(AktChName, '����������� �/� � �������� ���');
    if IsDebug then begin
       RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_post.txt');
    end;
    if RequestResult=rrOk then begin
      AktChName.Dokument.CheckBrowseMode;
      AktChName.Dokument.Edit;
      SetPoleGrn(AktChName.DokumentPOLE_GRN, 3);
      AktChName.Dokument.Post;
      if not HandleErrorToString
        then ShowMessageCont(GetMessageOk,CurAkt);
      Result:=true;
    end else begin
      Result:=false;
      //4.2. ������������ ������ �������������� � ���������
      HandleError(RequestResult, akNameChange, opGet, Input, Output, Error, FRegInt.FaultError);
    end;
  end;
{$ENDIF}
end;

//�������� ����:
//0610 - ��������� �/� �� ����������� � �������� ��;
//0611 - ��������� �/� �� ����������� ��� ������� ��;
//0620 - ������������� �/�  �� �����������;
//3500 - ������ ������������� �/� �� �����������.
function TGisun.SetTypeMessageAktAdopt(Akt: TfmSimpleD;  var strError: String): Boolean;
{$IFDEF ZAGS}
var
  AktAdopt : TfmZapisAdopt;
{$ENDIF}
begin
  Result:=false;
{$IFDEF ZAGS}
  AktAdopt := TfmZapisAdopt(Akt);
  AktAdopt.Dokument.CheckBrowseMode;
  if not CheckMessageSource(Akt, strError) then begin
    Result:=false;
    exit;
  end;
  strError:='';
  TypeAkt := '0600';
  {
  // ���� ���� ��������� ������� ��, � ��� �� ��������� ��
  if (AktRogd.DokumentON_DOK_TYPE.AsInteger=1) and (AktRogd.DokumentON_GRAG.AsInteger<>MY_GRAG) then begin
    strError:='�� ��������� �� ����� ����� ������� ��';
    exit;
  end;
  // ���� ���� ���������� ������� ��, � ���� �� ��������� ��
  if (AktRogd.DokumentONA_DOK_TYPE.AsInteger=1) and (AktRogd.DokumentONA_GRAG.AsInteger<>MY_GRAG) then begin
    strError:='�� ��������� �� ����� ����� ������� ��';
    exit;
  end;
  // ���� ���� ��������� �� ������� ��, � ��� ��������� ��
  if (AktRogd.DokumentON_DOK_TYPE.AsInteger<>1) and (AktRogd.DokumentON_GRAG.AsInteger=MY_GRAG) then begin
    strError:='��������� �� ������ ����� ������� ��';
    exit;
  end;
  // ���� ���� ��������� �� ������� ��, � ��� ��������� ��
  if (AktRogd.DokumentON_DOK_TYPE.AsInteger<>1) and (AktRogd.DokumentONA_GRAG.AsInteger=MY_GRAG) then begin
    strError:='��������� �� ������ ����� ������� ��';
    exit;
  end;
  }
  Female:=AktAdopt.DokumentMAT_IDENTIF.AsString<>'';   // ����� ������ � ����
  FemaleU:=AktAdopt.DokumentONA_IDENTIF.AsString<>'';  // ����� ������ �� ���������������
  Male:=AktAdopt.DokumentOTEC_IDENTIF.AsString<>'';    // ����� ������ � ����
  MaleU:=AktAdopt.DokumentON_IDENTIF.AsString<>'';     // ����� ������ �� �����������
  //----------- !!! ---------------------------  �� � ������� ������ ������������ ������ 09.12.2011  ��������� ��������
  Child:=AktAdopt.DokumentIDENTIF_DO.AsString<>'';        // ����� ������ � �������
  ChildIdentif:=false;  // ����� �� ��� �������
  //--------------------------------------------
  if not Female and not FemaleU and not Male and not MaleU and not Child then begin
    strError:='�� ������ �� ���� ����������������� �����.';
    exit;
  end;

//  Child:=AktAdopt.DokumentIDENTIF_DO.AsString<>'';        // ����� ������ � �������
//  ChildIdentif:=AktAdopt.DokumentIDENTIF_DO.AsString='';  // ����� �� ��� �������

  RunExchange:=true;   // ��������� ������������� ��� ���
  DefaultPoleGrn:=0;   // �������� ��� ���� POLE_GRN ���� �� ���� ������������ ��������������

  // !!! ��� ��������� ����������, ��� ������������ ����� ����� ???
//  if FemaleU and not MaleU  //����������� ����� ������������ (��������)
//     then TypeMessage:='0601';
//  if not FemaleU and MaleU  //����������� ����� ������������ (��������)
//     then TypeMessage:='0602';

  if TypeMessage='*'
    then TypeMessage:='0600';
  if strError=''
    then Result:=true
    else Result:=false;
{$ENDIF}
end;

//�������� ����:
//0701 - �������� ������� (�����, ��������) � �������� ��;
function TGisun.SetTypeMessageAktChName(Akt: TfmSimpleD; var strError: String): Boolean;
{$IFDEF ZAGS}
var
  AktChName : TfmZapisChName;
{$ENDIF}
begin
  Result:=false;
{$IFDEF ZAGS}
  AktChName := TfmZapisChName(Akt);
  AktChName.Dokument.CheckBrowseMode;
  if not CheckMessageSource(Akt, strError) then begin
    exit;
  end;
  strError:='';
  TypeAkt := '0700';
  Person:=true; // ����� ������ � ��������
  RunExchange:=true;  // ��������� ������������� ��� ���
  DefaultPoleGrn:=0;  // �������� ��� ���� POLE_GRN ���� �� ���� ������������ ��������������
  TypeMessage:='*';
  if TypeMessage='*'
    then TypeMessage:='0700';
  if (AktChName.DokumentIDENTIF.AsString='') then begin
    strError:='��������� ����������������� �����';
  end;
  if strError=''
    then Result:=true
    else Result:=false;
{$ENDIF}
end;

procedure TGisun.CheckAktV(Simple: TfmSimpleD);
{$IFDEF ZAGS}
const
   CComponentName: array [1..51] of record      // 52  ???
      Name: string;
      Code: Integer;
      Color: TColor;
   end=(
     //1. ������
     //������������ ������
     (Name:'ENG_edIDENTIF'; Code: bChildId; Color: clDefault),
     (Name:'edFamilia'; Code: bChild; Color: clDefault),
     (Name:'edNAME'; Code: bChild; Color: clDefault),
     (Name:'edOTCH'; Code: bChild; Color: clDefault),
     (Name:'BLR_edFamilia'; Code: bChild; Color: clDefault),
     (Name:'BLR_edNAME'; Code: bChild; Color: clDefault),
     (Name:'BLR_edOTCH'; Code: bChild; Color: clDefault),

     //--Otch_B
     (Name:'edPol'; Code: bChildId; Color: clDefault),
     (Name:'edDATER'; Code: bChildId; Color: clDefault),
     //--GRAG
     //--ON_STATUS
     //����� ��������
     (Name:'edGOSUD'; Code: bChild; Color: clDefault),
     (Name:'edOBL'; Code: bChild; Color: clDefault),
     (Name:'BLR_edOBL'; Code: bChild; Color: clDefault),
     (Name:'edRAION'; Code: bChild; Color: clDefault),
     (Name:'BLR_edRAION'; Code: bChild; Color: clDefault),
     (Name:'edB_GOROD'; Code: bChild; Color: clDefault),
     (Name:'edGOROD'; Code: bChild; Color: clDefault),
     (Name:'BLR_edGOROD'; Code: bChild; Color: clDefault),
     //����� ����������
     {
     (Name:'edB_M_RESP'; Code: bChild; Color: clDefault),
     (Name:'edM_GOSUD'; Code: bChild; Color: clDefault),
     (Name:'edB_M_OBL'; Code: bChild; Color: clDefault),
     (Name:'edM_OBL'; Code: bChild; Color: clDefault),
     (Name:'edM_RAION'; Code: bChild; Color: clDefault),
     (Name:'edB_M_GOROD'; Code: bChild; Color: clDefault),
     (Name:'edM_GOROD'; Code: bChild; Color: clDefault),
     (Name:'edM_GOROD_R'; Code: bChild; Color: clDefault),
     }
     //2. ����
     //������������ ������
     (Name:'ENG_edON_IDENTIF'; Code: bMale; Color: clDefault),
     (Name:'edON_Familia'; Code: bMale; Color: clDefault),
     (Name:'edON_NAME'; Code: bMale; Color: clDefault),
     (Name:'edON_OTCH'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_Familia'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_NAME'; Code: bMale; Color: clDefault),
     (Name:'BLR_edON_OTCH'; Code: bMale; Color: clDefault),
     (Name:'edON_DATER'; Code: bMale; Color: clDefault),
     (Name:'cbOnlyGodON'; Code: bMale; Color: clDefault),
     (Name:'edON_VOZR'; Code: bMale; Color: clDefault),
     (Name:'edON_GRAG'; Code: bMale; Color: clDefault),        //  ???
     //--ON_STATUS
     //����� ��������
     (Name:'edON_M_GOSUD'; Code: bMale; Color: clDefault),
     (Name:'edON_M_B_OBL'; Code: bMale; Color: clDefault),
     (Name:'edON_M_OBL'; Code: bMale; Color: clDefault),
     (Name:'edON_M_RAION'; Code: bMale; Color: clDefault),
     (Name:'edON_M_B_GOROD'; Code: bMale; Color: clDefault),
     (Name:'edON_M_GOROD'; Code: bMale; Color: clDefault),
     //3. ����
     //������������ ������
     (Name:'ENG_edONA_IDENTIF'; Code: bFemale; Color: clDefault),
     (Name:'edONA_Familia'; Code: bFemale; Color: clDefault),
     (Name:'edONA_NAME'; Code: bFemale; Color: clDefault),
     (Name:'edONA_OTCH'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_Familia'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_NAME'; Code: bFemale; Color: clDefault),
     (Name:'BLR_edONA_OTCH'; Code: bFemale; Color: clDefault),
     (Name:'edONA_DATER'; Code: bFemale; Color: clDefault),
     (Name:'cbOnlyGodONA'; Code: bFemale; Color: clDefault),
     (Name:'edONA_VOZR'; Code: bFemale; Color: clDefault),
     (Name:'edONA_GRAG'; Code: bFemale; Color: clDefault),          // ???
     //--ONA_STATUS
     //����� ��������
     (Name:'edONA_M_GOSUD'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_B_OBL'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_OBL'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_RAION'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_B_GOROD'; Code: bFemale; Color: clDefault),
     (Name:'edONA_M_GOROD'; Code: bFemale; Color: clDefault)
   );
var
   Akt: TfmZapisRogdV;
   PoleGrn: Integer;
   PoleGrnSub: Integer;
   I: Integer;
   Component: TComponent;
   Control: TControl;
   lDisable,l: Boolean;
{$ENDIF}                         
begin
{$IFDEF ZAGS}
   Akt:=TfmZapisRogdV(Simple);
   l:=(IsEnabled and IsEnableTypeAkt(dmBase.TypeObj_ZRogd,true));
   if l then begin
     PoleGrn:=GetPoleGrn(Akt.DokumentPOLE_GRN.AsInteger);
     PoleGrnSub:=GetPoleGrnSub(Akt.DokumentPOLE_GRN.AsInteger);
   end else begin
     PoleGrn:=0;
     PoleGrnSub:=0;
   end;
   //1. ������������ ����������� ������ [� ������ ������� �� ����� ��������]
   //TBItemStep1 - "1. �������� ������������� �������"
   //TBItemStep2 - "2. ���������������� �������"
   {
   if not IsDebug then begin
      case PoleGrn of
         //�� ���� ������ � ��� ��
         0: begin
            Akt.TBItemStep1.Enabled:=True;
            Akt.TBItemStep2.Enabled:=True;
         end;
         1:;
         //������� ����� �� ��� ��
         2: begin
            Akt.TBItemStep1.Enabled:=False;
            Akt.TBItemStep2.Enabled:=True;
         end;
         //���������� ������ �� ������� ������ � ��� ��
         3: begin
            Akt.TBItemStep1.Enabled:=False;
            Akt.TBItemStep2.Enabled:=False;
         end;
      end;
   end;
   }
   //2. ������������ ����������� ��������� ��������������
   //����� ��������� ������ �� ��� �� �������� �������������� ������ ����� ����������
   for I:=Low(CComponentName) to High(CComponentName) do begin
      Component:=Akt.FindComponent(CComponentName[I].Name);
      if (Component<>nil) and (Component is TControl) then begin
         Control:=TControl(Component);
         //2.1.
         if l
           then lDisable:=((PoleGrn=2) or (PoleGrn=3)) and ((PoleGrnSub and CComponentName[I].Code)=CComponentName[I].Code)
           else lDisable:=l;
         if lDisable and (PoleGrn=3) then begin
           lDisable:=false;
         end;
         //2.2.
         if lDisable then begin
            SetEnableControl(FTypeEnableControl,Control,false);
            //Control.Enabled:=False;
            if TxControl(Control).Color<>GetDisableColorGIS then begin
               CComponentName[I].Color:=TxControl(Control).Color;
            end;
            TxControl(Control).Color:=GetDisableColorGIS;
         end
         else begin
            if CComponentName[I].Color<>clDefault then begin
               TxControl(Control).Color:=CComponentName[I].Color;
            end;
            SetEnableControl(FTypeEnableControl,Control,true);
            //Control.Enabled:=True;
         end;
      end
      else begin
         ShowMessageC(CComponentName[I].Name);
      end;
   end;
{$ENDIF}
end;

procedure TGisun.CheckMarriageV(Akt: TfmSimpleD);
begin

end;

procedure TGisun.CheckSmertV(Akt: TfmSimpleD);
begin

end;

function TGisun.GetIdentifChildV(Simple: TfmSimpleD): Boolean;
{$IFDEF ZAGS}
var
   Akt: TfmZapisRogdV;
   ErrorMsg: string;
   PoleGrnSub,nType: Integer;
   dDate:TDateTime;

   procedure AddPersonRequest(Flag: Boolean; Prefix, Identif: string);
   begin
      if Flag then begin
         Input.Append;
         Input.FieldByName('IS_PERSON').AsBoolean:=True;
         Input.FieldByName('PREFIX').AsString:=Prefix;
         Input.FieldByName('IDENTIF').AsString:=Identif;
         Input.Post;
      end;
   end;

   procedure AddIdentifRequest(Flag: Boolean; Prefix, Pol: string; Date: TDateTime);
   begin
      if Flag then begin
         Input.Append;
         Input.FieldByName('IS_PERSON').AsBoolean:=False;
         Input.FieldByName('PREFIX').AsString:=Prefix;
         Input.FieldByName('POL').AsString:=Code_Pol(Pol);
         Input.FieldByName('DATER').AsString:=DTOS(Date, tdClipper);
         Input.Post;
      end;
   end;
{$ENDIF}
begin
  Result:=False;
{$IFDEF ZAGS}
   Akt:=TfmZapisRogdV(Simple);
   Akt.Dokument.CheckBrowseMode;
   if not CheckIdentif(Simple, ErrorMsg) then begin
      ShowMessageErr(ErrorMsg);
   end
   else begin
      ClearDataSets;
      if RunExchange then begin
         PoleGrnSub:=0;
         //[1] ������ ������
         //1. ������ ������� ��� �������� ������ � �������
         Input:=FRegInt.CreateInputTable(akBirth, opGet);
         //2. ��������� ������������ ������
         //������
         AddIdentifRequest(ChildIdentif, 'CHILD', Akt.DokumentPOL.AsString, Akt.DokumentDATER.AsDateTime);
         AddPersonRequest(Child, 'CHILD', Akt.DokumentIDENTIF.AsString);
         //����
         AddPersonRequest(Male, 'ON', Akt.DokumentON_IDENTIF.AsString);
         //����
         AddPersonRequest(Female, 'ONA', Akt.DokumentONA_IDENTIF.AsString);
         //3. ��������� ������ � �������
         RequestResult:=RegInt.Get(akBirth, TypeMessage, Input, Output, Error);
         if IsDebug then begin
            RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_get.txt');
         end;
         if RequestResult=rrOk then begin
            Result:=true;
            Akt.Dokument.Edit;
            Akt.DokumentTypeMessage.AsString:='';
            Akt.MessageID:=RegInt.RequestMessageId;
            //������
            if OutPut.Locate('PREFIX','CHILD',[]) then begin
               if ChildIdentif then begin
                  PoleGrnSub:=PoleGrnSub or bChildId;
                  Akt.DokumentIDENTIF.AsString:=OutPut.FieldByName('NEW_IDENTIF').AsString;
{!!!}             Akt.DokumentSTATUS.AsString:='1'; //������� ??? ������
               end
               else if Child then begin
                  PoleGrnSub:=PoleGrnSub or bChild or bChildId;
                  //������������ ������
                  Akt.DokumentFamilia.AsString:=CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
                  Akt.DokumentFamilia_B.AsString:=CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
                  Akt.DokumentName.AsString:=CaseFIO(OutPut.FieldByName('NAME').AsString);
                  Akt.DokumentName_B.AsString:=CaseFIO(OutPut.FieldByName('NAME_B').AsString);
                  Akt.DokumentOtch.AsString:=CaseFIO(OutPut.FieldByName('OTCH').AsString);
                  Akt.DokumentOtch_B.AsString:=CaseFIO(OutPut.FieldByName('OTCH_B').AsString);

//                  Akt.DokumentDater.AsDateTime:=STOD(OutPut.FieldByName('DATER').AsString, tdClipper);
                  Decode_Date2(OutPut.FieldByName('DATER').AsString, dDate, nType);
                  if dDate<>0
                    then Akt.DokumentDATER.AsDateTime:=dDate;

                  Akt.DokumentPol.AsString:=Decode_Pol(OutPut.FieldByName('K_POL').AsString);
                  if LoadGrag then
                    Akt.DokumentGrag.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
                  Akt.DokumentStatus.AsString:=OutPut.FieldByName('K_STATUS').AsString;
                  //----------------����� �������� -------------------
                  Akt.DokumentGOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString);

                  Akt.DokumentOBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,'');
                  Akt.DokumentOBL_B.AsString:=Decode_Obl(OutPut.FieldByName('OBL_B_R').AsString,'');

                  Akt.DokumentRAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,'');
                  Akt.DokumentRAION_B.AsString:=Decode_Raion(OutPut.FieldByName('RAION_B_R').AsString,'');

                  DecodePunkt_MestoRogd(Akt.Dokument, 'B_GOROD', 'GOROD', 'GOROD_B', OutPut);
                  //Akt.DokumentB_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString);
                  //Akt.DokumentGOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString;
                  //Akt.DokumentGOROD_B.AsString:=OutPut.FieldByName('GOROD_B_R').AsString;

                  //------------����� ���������� --------------
                  if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
                    Akt.DokumentB_M_RESP.AsString:='';
                    Akt.DokumentM_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');

                    DecodeObl_MestoGit( Akt.Dokument,'M_OBL','B_M_OBL','',OutPut);
//                    Akt.DokumentB_M_OBL.AsString:='';
//                    Akt.DokumentM_OBL.AsString:=Decode_Obl(OutPut.FieldByName('N_OBL').AsString,'');

                    Akt.DokumentM_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');

                    DecodePunkt_MestoGit(Akt.Dokument, 'B_M_GOROD', 'M_GOROD', '', OutPut);
//                    Akt.DokumentB_M_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD').AsString);
//                    Akt.DokumentM_GOROD.AsString:=OutPut.FieldByName('N_GOROD').AsString;

                    Akt.DokumentM_GOROD_R.AsString:=GetGorodR(OutPut);
                  end;
               end;
            end;
            //����
            if Male then begin
               if OutPut.Locate('PREFIX','ON',[]) then begin
                  if (OutPut.FieldByName('K_POL').AsString<>'') and (Decode_Pol(OutPut.FieldByName('K_POL').AsString)='�') then begin
                     ShowMessageErr('� �������� �������������� ���� ������ ������������� ������� !');
                  end
                  else begin
                     PoleGrnSub:=PoleGrnSub or bMale;
                     //������������ ������
                     Akt.DokumentON_Familia.AsString:=CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
                     Akt.DokumentON_Familia_B.AsString:=CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
                     Akt.DokumentON_NAME.AsString:=CaseFIO(OutPut.FieldByName('NAME').AsString);
                     Akt.DokumentON_Name_B.AsString:=CaseFIO(OutPut.FieldByName('NAME_B').AsString);
                     Akt.DokumentON_OTCH.AsString:=CaseFIO(OutPut.FieldByName('OTCH').AsString);
                     Akt.DokumentON_Otch_B.AsString:=CaseFIO(OutPut.FieldByName('OTCH_B').AsString);
                     Decode_Date(OutPut.FieldByName('DATER').AsString, Akt.DokumentON_DATER, Akt.DokumentON_ONLYGOD);
                     if LoadGrag then
                       Akt.DokumentON_GRAG.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
                     Akt.DokumentON_STATUS.AsString:=OutPut.FieldByName('K_STATUS').AsString;
                     //-------------����� �������� ----------------
                     Akt.DokumentON_M_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString);

                     DecodeObl_MestoRogd( Akt.Dokument,'ON_M_OBL','ON_M_B_OBL','',OutPut);
                     //Akt.DokumentON_M_B_OBL.AsString:='';
                     //Akt.DokumentON_M_OBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,'');

                     Akt.DokumentON_M_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,'');

                     DecodePunkt_MestoRogd(Akt.Dokument, 'ON_M_B_GOROD', 'ON_M_GOROD', '', OutPut);
                     //Akt.DokumentON_M_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString);
                     //Akt.DokumentON_M_GOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString;
                  end;
               end
               else begin
                  ShowMessageErr('�� �������� �� ��������� ������ �� ���� ! ');
               end;
            end;
            //����
            if Result and Female then begin
               if OutPut.Locate('PREFIX','ONA',[]) then begin
                  if (OutPut.FieldByName('K_POL').AsString<>'') and (OutPut.FieldByName('K_POL').AsString='M') then begin
                     ShowMessageErr('� �������� �������������� ������ ������ ������������� ������� !');
                  end
                  else begin
                     PoleGrnSub:=PoleGrnSub or bFemale;
                     //������������ ������
                     Akt.DokumentONA_Familia.AsString:=CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
                     Akt.DokumentONA_Familia_B.AsString:=CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
                     Akt.DokumentONA_NAME.AsString:=CaseFIO(OutPut.FieldByName('NAME').AsString);
                     Akt.DokumentONA_Name_B.AsString:=CaseFIO(OutPut.FieldByName('NAME_B').AsString);
                     Akt.DokumentONA_OTCH.AsString:=CaseFIO(OutPut.FieldByName('OTCH').AsString);
                     Akt.DokumentONA_Otch_B.AsString:=CaseFIO(OutPut.FieldByName('OTCH_B').AsString);
                     Decode_Date(OutPut.FieldByName('DATER').AsString, Akt.DokumentONA_DATER, Akt.DokumentONA_ONLYGOD);
                     if LoadGrag then
                       Akt.DokumentONA_GRAG.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
                     Akt.DokumentONA_STATUS.AsString:=OutPut.FieldByName('K_STATUS').AsString;
                     //����� ��������
                     Akt.DokumentONA_M_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString);

                     DecodeObl_MestoRogd( Akt.Dokument,'ONA_M_OBL','ONA_M_B_OBL','',OutPut);
                     //Akt.DokumentONA_M_B_OBL.AsString:='';
                     //Akt.DokumentONA_M_OBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,'');

                     Akt.DokumentONA_M_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,'');

                     DecodePunkt_MestoRogd(Akt.Dokument, 'ONA_M_B_GOROD', 'ONA_M_GOROD', '', OutPut);
                     //Akt.DokumentONA_M_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString);
                     //Akt.DokumentONA_M_GOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString;
                  end;
               end
               else begin
                  ShowMessageErr('�� �������� �� ��������� ������ � ������ ! ');
               end;
            end;
            if not Result then begin
               SetPoleGrn(Akt.DokumentPOLE_GRN, 0, 0);
            end
            else begin
               SetPoleGrn(Akt.DokumentPOLE_GRN, 2, PoleGrnSub);
               Akt.DokumentTypeMessage.AsString:=TypeMessage;
            end;
            Akt.Dokument.Post;
            Result:=True;
         end
         else begin
            HandleError(RequestResult, akBirth, opGet, Input, Output, Error, RegInt.FaultError);
         end;
         ClearDataSets;
      end;
   end;
{$ENDIF}
end;

function TGisun.GetMarriageV(Akt: TfmSimpleD): Boolean;
begin
   Result:=True;
end;

function TGisun.GetSmertV(Akt: TfmSimpleD): Boolean;
{$IFNDEF ZAGS}
begin
  Result:=false;
end;
{$ELSE}
var
  AktSmert : TfmZapisSmertV;
  strError : String;
  PoleGrnSub : Integer;
  d:TdateTime;
  t:Integer;
begin
  Result:=false;
  AktSmert := TfmZapisSmertV(Akt);
  AktSmert.Dokument.CheckBrowseMode;
  if not SetTypeMessageAktSmert( AktSmert, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end else begin
    ClearDataSets;
    if RunExchange then begin
      PoleGrnSub:=0;
      //[1] ������ ������
      //1. ������ ������� ��� �������� ������ � �������
      Input:=FRegInt.CreateInputTable(akDecease, opGet);
      //2. ��������� ������������ ������
      Input.Append;
      Input.FieldByName('IS_PERSON').AsBoolean:=true;
      Input.FieldByName('PREFIX').AsString:='MAN';
      Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktSmert.DokumentLICH_NOMER.AsString);
      Input.Post;

      //3. ��������� ������ � �������
      RequestResult:=RegInt.Get(akDecease, TypeMessage, Input, Output, Error);
      if IsDebug then begin
         RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_get.txt');
      end;
      if RequestResult=rrOk then begin
        Result:=true;
        AktSmert.Dokument.Edit;
        AktSmert.DokumentSTATUS.AsString  := '';
        AktSmert.DokumentTypeMessage.AsString:='';
        AktSmert.MessageID:=RegInt.RequestMessageId;  // �������� ID �������
        if ChildIdentif then begin
          if OutPut.Locate('PREFIX','CHILD',[]) then begin
            PoleGrnSub:=PoleGrnSub or bChildId;
            AktSmert.DokumentLICH_NOMER.AsString := OutPut.FieldByName('NEW_IDENTIF').AsString;
{!!!}       AktSmert.DokumentSTATUS.AsString := '1'; //������� ??? ������
          end;
        end;
        if Person then begin
          if OutPut.Locate('PREFIX','MAN',[]) then begin
            PoleGrnSub:=PoleGrnSub or bPerson or bChildId;
            //������������ ������ ��������
            AktSmert.DokumentLICH_NOMER.AsString:= OutPut.FieldByName('IDENTIF').AsString;
            AktSmert.DokumentFamilia.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
            AktSmert.DokumentFamilia_B.AsString := CaseFIO(OutPut.FieldByName('FAMILIA_B').AsString);
            AktSmert.DokumentNAME.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
            AktSmert.DokumentName_B.AsString    := CaseFIO(OutPut.FieldByName('NAME_B').AsString);
            AktSmert.DokumentOTCH.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
            AktSmert.DokumentOtch_B.AsString    := CaseFIO(OutPut.FieldByName('OTCH_B').AsString);

//            Decode_Date(OutPut.FieldByName('DATER').AsString, AktSmert.DokumentDATER, AktSmert.DokumentONLYGOD_R);
//            Decode_Date(OutPut.FieldByName('DATES').AsString, AktSmert.DokumentDATES, AktSmert.DokumentONLYGOD);
            if Decode_Date2(OutPut.FieldByName('DATER').AsString, d,t) then begin
              AktSmert.DokumentDATER.AsDateTime:=d;
            end;
            if Decode_Date2(OutPut.FieldByName('DATES').AsString, d,t,'������') then begin
              AktSmert.DokumentDATES.AsDateTime:=d;
            end;

            AktSmert.DokumentPOL.AsString   := Decode_Pol(OutPut.FieldByName('K_POL').AsString);
            if LoadGrag then
              AktSmert.DokumentGRAG.AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
            AktSmert.DokumentSTATUS.AsString := OutPut.FieldByName('K_STATUS').AsString;
            //--------------- ����� �������� -----------------------
            AktSmert.DokumentRG_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                       OutPut.FieldByName('N_GOSUD_R').AsString); //������ ��������

            DecodeObl_MestoRogd( AktSmert.Dokument,'RG_OBL','RG_B_OBL','',OutPut);
            //AktSmert.DokumentRG_B_OBL.AsString:='';
            //AktSmert.DokumentRG_OBL.AsString:=Decode_Obl(OutPut.FieldByName('OBL_R').AsString,''); //������� ��������

            AktSmert.DokumentRG_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,''); //����� ��������

            DecodePunkt_MestoRogd(AktSmert.Dokument, 'RG_B_GOROD', 'RG_GOROD', '', OutPut);
            //AktSmert.DokumentRG_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD_R').AsString); //��� ���������� ������ ��������
            //AktSmert.DokumentRG_GOROD.AsString:=OutPut.FieldByName('GOROD_R').AsString; //��������� ����� �� ������� �����

            //-------------- ����� ���������� -----------------
            if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
              AktSmert.DokumentGT_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');

              DecodeObl_MestoGit( AktSmert.Dokument,'GT_OBL','GT_B_OBL','',OutPut);
              //AktSmert.DokumentGT_B_OBL.AsString:='';
              //AktSmert.DokumentGT_OBL.AsString:=Decode_Obl(OutPut.FieldByName('N_OBL').AsString,'');

              AktSmert.DokumentGT_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');

              DecodePunkt_MestoGit(AktSmert.Dokument, 'GT_B_GOROD', 'GT_GOROD', '', OutPut);
              //AktSmert.DokumentGT_B_GOROD.AsString:=Decode_TypePunkt(OutPut.FieldByName('K_TIP_GOROD').AsString);
              //AktSmert.DokumentGT_GOROD.AsString:=OutPut.FieldByName('N_GOROD').AsString;

             AktSmert.DokumentGT_GOROD_R.AsString:=GetGorodR(OutPut);
//--------- ����� --------
{
              ag:=GetGorodREx(OutPut);
              AktSmert.DokumentGT_GOROD_R.AsString:=ag.Ulica;
              AktSmert.DokumentGT_DOM.AsString:=ag.Dom;
              AktSmert.DokumentGT_KORP.AsString:=ag.Korp;
              AktSmert.DokumentGT_KV.AsString:=ag.Kv;
}
//------------------------
              {$IFDEF GISUN2}
//                AktSmert.DokumentGT_RNGOROD.AsString:=Decode_RnGorod(OutPut, ['K_RN_GOROD','N_RN_GOROD'], strSoato);
              {$ENDIF}

//              AktSmert.WriteSoato(AktSmert.DokumentSOATO,true);
            end;
          end else begin
            ShowMessageErr('�� �������� �� ��������� ������ �� �������� ! ');
            Result:=false;
          end;
        end;
        if not Result then begin
          SetPoleGrn(AktSmert.DokumentPOLE_GRN, 0, 0);
        end else begin
          SetPoleGrn(AktSmert.DokumentPOLE_GRN, 2, PoleGrnSub);
          AktSmert.DokumentTypeMessage.AsString:=TypeMessage;
        end;
        AktSmert.Dokument.Post;
      end else begin
        HandleError(RequestResult, akDecease, opGet, Input, Output, Error, RegInt.FaultError);
      end;
      ClearDataSets;
    end;
  end;
end;
{$ENDIF}

//--------------------------------------------------------------------------------
//  ��������������� ������� ������ � ��������
function TGisun.RegisterChildV(Simple: TfmSimpleD): Boolean;
{$IFDEF ZAGS}
var
   Akt: TfmZapisRogdV;
   ErrorMsg: string;
{$ENDIF}
begin
 Result:=False;
{$IFDEF ZAGS}
   Akt:=TfmZapisRogdV(Simple);
   Akt.Dokument.CheckBrowseMode;
   if not SetTypeMessageAktBirthV(Simple, ErrorMsg) then begin
      ShowMessageErr(ErrorMsg);
   end
   else begin
      ClearDataSets;
      //[2] �������� ������
      //1. ������ ������� ��� �������� ������ � �������
      Input:=FRegInt.CreateInputTable(akBirth, opPost);
      //2. ��������� ������������ ������
      Input.Append;
      //������������ ������ ������
      Input.FieldByName('IDENTIF').AsString:=Akt.DokumentIDENTIF.AsString; //������������ �����
      Input.FieldByName('FAMILIA').AsString:=Akt.DokumentFamilia.AsString; //������� �� ������� �����
      Input.FieldByName('FAMILIA_B').AsString:=Akt.DokumentFamilia_B.AsString; //������� �� ����������� �����
      Input.FieldByName('NAME').AsString:=Akt.DokumentName.AsString; //��� �� ������� �����
      Input.FieldByName('NAME_B').AsString:=Akt.DokumentNAME_B.AsString; //��� �� ����������� �����
      Input.FieldByName('OTCH').AsString:=Akt.DokumentOtch.AsString;
      Input.FieldByName('OTCH_B').AsString:=Akt.DokumentOtch_B.AsString;
      Input.FieldByName('POL').AsString:=Code_Pol(Akt.DokumentPOL.AsString);
      Input.FieldByName('DATER').AsString:=DTOS(Akt.DokumentDateR.AsDateTime,tdClipper); //���� ��������
{!!!} Input.FieldByName('GOSUD').AsString:=Code_Alfa3(Akt.DokumentGOSUD.AsString); //������ ��������
{!!!} Input.FieldByName('GRAJD').AsString:='0';   // ���� 'BLR' �� 27.08.2015    �����������

      Input.FieldByName('STATUS').AsString:=Akt.DokumentSTATUS.AsString; //������
      //---------------------------����� ��������

      CodeObl_MestoRogd( Akt.Dokument,'OBL','','OBL_B',Input,'OBL','OBL_B');
//      Input.FieldByName('OBL').AsString:=Akt.DokumentOBL.AsString;
//      Input.FieldByName('OBL_B').AsString:=Akt.DokumentOBL_B.AsString;

      Input.FieldByName('RAION').AsString:=Akt.DokumentRAION.AsString;
      Input.FieldByName('RAION_B').AsString:=Akt.DokumentRAION_B.AsString;

      CodePunkt_MestoRogd(Akt.Dokument, 'B_GOROD','GOROD','GOROD_B',Input,'TIP_GOROD','GOROD','GOROD_B');
      //Input.FieldByName('TIP_GOROD').AsString:=Code_TypePunkt(Akt.DokumentB_GOROD.AsString);  //��� ���������� ������
      //Input.FieldByName('GOROD').AsString:=Akt.DokumentGOROD.AsString; //��������� ����� �� ������� �����
      //Input.FieldByName('GOROD_B').AsString:=Akt.DokumentGOROD_B.AsString; //��������� ����� �� ����������� �����

//      if Female then begin
         //������������ ������ ������
         Input.FieldByName('ONA_IDENTIF').AsString:=Akt.DokumentONA_IDENTIF.AsString; //������������ �����
         Input.FieldByName('ONA_FAMILIA').AsString:=Akt.Dokument.FieldByName('ONA_FAMILIA').AsString; //������� �� ������� �����
         Input.FieldByName('ONA_FAMILIA_B').AsString:=Akt.Dokument.FieldByName('ONA_FAMILIA_B').AsString; //������� �� ����������� �����
         Input.FieldByName('ONA_NAME').AsString:=Akt.Dokument.FieldByName('ONA_NAME').AsString; //��� �� ������� �����
         Input.FieldByName('ONA_NAME_B').AsString:=Akt.Dokument.FieldByName('ONA_NAME_B').AsString; //��� �� ����������� �����
         Input.FieldByName('ONA_OTCH').AsString:=Akt.Dokument.FieldByName('ONA_OTCH').AsString; //�������� �� ������� �����
         Input.FieldByName('ONA_OTCH_B').AsString:=Akt.Dokument.FieldByName('ONA_OTCH_B').AsString; //�������� �� ����������� �����
         Input.FieldByName('ONA_POL').AsString:='F'; //���
         Input.FieldByName('ONA_GRAJD').AsString:=Code_Alfa3(Akt.DokumentONA_GRAG.AsString); //�����������
   //      Input.FieldByName('ONA_STATUS').AsString:=Akt.Dokument.FieldByName('ONA_STATUS').AsString; //������
         Input.FieldByName('ONA_STATUS').AsString:=Code_Status(Akt.Dokument, 'ONA_GRAG', 'ONA_STATUS');

         if (Input.FieldByName('ONA_STATUS').AsString<>ST_INOST) and  // �� ����������
            (Input.FieldByName('ONA_IDENTIF').AsString='') then begin // ���� ��� ��
           Input.FieldByName('ONA_STATUS').AsString:=ST_FIKT;    // ���������
         end;
         // ��� ���� ����� �� ���������� ������� ���� �������� ���� ��� ���������
         if (Input.FieldByName('ONA_STATUS').AsString=ST_FIKT) and Akt.DokumentONA_DATER.IsNull then begin
           Input.FieldByName('ONA_DATER').AsString:=GetEmptyDate;  // '00000000'
         end else begin
           Input.FieldByName('ONA_DATER').AsString:=Code_Date(Akt.DokumentONA_DATER.AsDateTime, Akt.DokumentONA_ONLYGOD);
         end;



         //����� ��������
         Input.FieldByName('ONA_GOSUD').AsString:=Code_Alfa3(Akt.DokumentONA_M_GOSUD.AsString); //������ ��������

         CodeObl_MestoRogd( Akt.Dokument,'ONA_M_OBL','ONA_M_B_OBL','',Input,'ONA_OBL','');
         //Input.FieldByName('ONA_OBL').AsString:=Akt.DokumentONA_M_OBL.AsString; //������� ��������

         Input.FieldByName('ONA_RAION').AsString:=Akt.DokumentONA_M_RAION.AsString; //����� ��������

         CodePunkt_MestoRogd(Akt.Dokument, 'ONA_M_B_GOROD','ONA_M_GOROD','',Input,'ONA_TIP_GOROD','ONA_GOROD','');
         //Input.FieldByName('ONA_TIP_GOROD').AsString:=Code_TypePunkt(Akt.DokumentONA_M_B_GOROD.AsString); //��� ���������� ������
         //Input.FieldByName('ONA_GOROD').AsString:=Akt.DokumentONA_M_GOROD.AsString; //��������� ����� �� ������� �����
//      end;
//      if Male then begin
         //������������ ������ ����
         Input.FieldByName('ON_IDENTIF').AsString:=Akt.Dokument.FieldByName('ON_IDENTIF').AsString; //������������ �����
         Input.FieldByName('ON_FAMILIA').AsString:=Akt.Dokument.FieldByName('ON_FAMILIA').AsString; //������� �� ������� �����
         Input.FieldByName('ON_FAMILIA_B').AsString:=Akt.Dokument.FieldByName('ON_FAMILIA_B').AsString; //������� �� ����������� �����
         Input.FieldByName('ON_NAME').AsString:=Akt.Dokument.FieldByName('ON_NAME').AsString; //��� �� ������� �����
         Input.FieldByName('ON_NAME_B').AsString:=Akt.Dokument.FieldByName('ON_NAME_B').AsString; //��� �� ����������� �����
         Input.FieldByName('ON_OTCH').AsString:=Akt.Dokument.FieldByName('ON_OTCH').AsString; //�������� �� ������� �����
         Input.FieldByName('ON_OTCH_B').AsString:=Akt.Dokument.FieldByName('ON_OTCH_B').AsString; //�������� �� ����������� �����
         Input.FieldByName('ON_POL').AsString:='M'; //���

         Input.FieldByName('ON_GRAJD').AsString:=Code_Alfa3(Akt.DokumentON_GRAG.AsString); //�����������

         Input.FieldByName('ON_STATUS').AsString:=Code_Status(Akt.Dokument, 'ON_GRAG', 'ON_STATUS');

         if (Input.FieldByName('ON_STATUS').AsString<>ST_INOST) and  // �� ����������
            (Input.FieldByName('ON_IDENTIF').AsString='') then begin // ���� ��� ��
           Input.FieldByName('ON_STATUS').AsString:=ST_FIKT;    // ���������
         end;
         // ��� ���� ����� �� ���������� ������� ���� �������� ���� ��� ����������
         if (Input.FieldByName('ON_STATUS').AsString=ST_FIKT) and Akt.DokumentON_DATER.IsNull then begin
           Input.FieldByName('ON_DATER').AsString:=GetEmptyDate;
         end else begin
           Input.FieldByName('ON_DATER').AsString:=Code_Date(Akt.DokumentON_DATER.AsDateTime, Akt.DokumentON_ONLYGOD);
         end;

         //����� ��������
         Input.FieldByName('ON_GOSUD').AsString:=Code_Alfa3(Akt.DokumentON_M_GOSUD.AsString); //������ ��������
         CodeObl_MestoRogd( Akt.Dokument,'ON_M_OBL','ON_M_B_OBL','',Input,'ON_OBL','');
         //Input.FieldByName('ON_OBL').AsString:=Akt.DokumentON_M_OBL.AsString; //������� ��������
         Input.FieldByName('ON_RAION').AsString:=Akt.DokumentON_M_RAION.AsString; //����� ��������
         CodePunkt_MestoRogd(Akt.Dokument, 'ON_M_B_GOROD','ON_M_GOROD','',Input,'ON_TIP_GOROD','ON_GOROD','');
         //Input.FieldByName('ON_TIP_GOROD').AsString:=Code_TypePunkt(Akt.DokumentON_M_B_GOROD.AsString); //��� ���������� ������
         //Input.FieldByName('ON_GOROD').AsString:=Akt.DokumentON_M_GOROD.AsString; //��������� ����� �� ������� �����
//      end;
      //���������� �� ������� ������
      Input.FieldByName('ACT_TIP').AsString:=TypeAkt; //��� ������� ������
      SetOrganAkt(Akt, Input);
      Input.FieldByName('ACT_DATE').AsDateTime:=Akt.Dokument.FieldByName('DATEZ').AsDateTime; //���� ������� ������
      Input.FieldByName('ACT_NOMER').AsString:=Akt.Dokument.FieldByName('NOMER').AsString; //����� ������� ������

      //-------------���������� � �������� ���������
      SetDokSvid(Akt,Input);

      Input.Post;
      //3. ��������� ������ � �������
      RequestResult:=RegInt.Post(Akt.MessageID, akBirth, Akt.DokumentTypeMessage.AsString, Input, Error);
      LogToTableLog(Akt, '����������� �����. �/� � ��������');
     if IsDebug then begin
         RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_post.txt');
      end;
      if RequestResult=rrOk then begin
         Akt.Dokument.Edit;
         SetPoleGrn(Akt.DokumentPOLE_GRN, 3);
         Akt.Dokument.Post;
         if not HandleErrorToString
           then ShowMessageCont(GetMessageOk,CurAkt);
         Result:=True;
      end else begin
         Result:=false;
         //4.2. ������������ ������ �������������� � ���������
         HandleError(RequestResult, akBirth, opGet, Input, Output, Error, FRegInt.FaultError);
      end;
   end;
{$ENDIF}
end;

function TGisun.RegisterMarriageV(Akt: TfmSimpleD): Boolean;
begin
   Result:=True;
end;

function TGisun.RegisterSmertV(Akt: TfmSimpleD): Boolean;
begin
   Result:=True;
end;

function TGisun.SetTypeMessageAktBirthV(Simple: TfmSimpleD; var Error: String): Boolean;
begin
   Result:=CheckIdentif(Simple, Error);
end;

//�������� ����:
//1200 - �������������� �/� � �����;
function TGisun.SetTypeMessageAktMarriageV(Akt: TfmSimpleD; var strError: String): Boolean;
begin
   Result:=True;
end;

//�������� ����:
//1400 - �������������� �/� � ������;
function TGisun.SetTypeMessageAktSmertV(Akt: TfmSimpleD; var strError: String): Boolean;
begin
   Result:=True;
end;

//------------------------------------------------------------------------------
function TGisun.DecodeObl_MestoGit( dsDokZ:TDataSet; fldObl,fldOblTip,fldOblBel: String; dsPerson:TDataSet) : String;
var
  sObl:String;
begin
{
;����� - ����� ����������
T_OBL              ftString        5   ResponsePerson.data.addresses.area.type_                ;������� (��� ��������������)
K_OBL              ftString       10   ResponsePerson.data.addresses.area.code                 ;������� (������� ��������)
N_OBL              ftString      255   ResponsePerson.data.addresses.area.lexema.text          ;�������
}
  dsDokZ.FieldByName(fldOblTip).AsString:='';   // null
  // ������������ �� ��� ��
  sObl:=CaseAdres(dsPerson.FieldByName('N_OBL').AsString);
  // ���� � �������� ��� ����� �������
  if Pos('�������', ANSIUpperCase(sObl))=0 then begin
    dsDokZ.FieldByName(fldOblTip).AsBoolean:=true;
  end else begin
    dsDokZ.FieldByName(fldOblTip).AsBoolean:=true;
    sObl:=StringReplace(sObl,'�������','',[rfIgnoreCase])
  end;
  dsDokZ.FieldByName(fldObl).AsString:=CaseAdres(sObl);
  if fldOblBel<>'' then begin
//    dsDokZ.FieldByName(fldObl).AsString:=dsPerson.FieldByName('N_OBL').AsString;
  end;
end;

//------------------------------------------------------------------------------
procedure TGisun.CodeObl_MestoRogd( dsDokZ:TDataSet; fldObl,fldOblTip,fldOblBel: String;
                             dsPerson: TDataSet; fldOblP,fldOblBelP : String);
var
  s1,s2:String;
begin
  if Trim(dsDokZ.FieldByName(fldObl).AsString)<>'' then begin  // ���� ������� ������� ��-������
    // ���� ���� ��� ������� �����������
    if fldOblTip='' then begin
      s1:='';
      s2:='';
      if Pos('�������',ANSIUpperCase(dsDokZ.FieldByName(fldObl).AsString))=0 then begin
        s1:=' �������';
        s2:=' ��������';
      end;
      dsPerson.FieldByName(fldOblP).AsString:=dsDokZ.FieldByName(fldObl).AsString+s1;
      if fldOblBel<>''
        then dsPerson.FieldByName(fldOblBelP).AsString:=dsDokZ.FieldByName(fldOblBel).AsString+s2;
    // ���� ��� ������� �� ������
    end else if dsDokZ.FieldByName(fldOblTip).AsString='' then begin
      dsPerson.FieldByName(fldOblP).AsString:=dsDokZ.FieldByName(fldObl).AsString;
      if fldOblBel<>''
        then dsPerson.FieldByName(fldOblBelP).AsString:=dsDokZ.FieldByName(fldOblBel).AsString;
    end else begin
    // ���� ���������� ��� �������
      s1:='';
      s2:='';
      if dsDokZ.FieldByName(fldOblTip).AsBoolean then begin
        if Pos('�������',ANSIUpperCase(dsDokZ.FieldByName(fldObl).AsString))=0 then begin
          s1:=' �������';
          s2:=' ��������';
        end;
      end else begin
        if Pos('����',ANSIUpperCase(dsDokZ.FieldByName(fldObl).AsString))=0 then begin
          s1:=' ����';
          s2:=s1;
        end;
      end;
      dsPerson.FieldByName(fldOblP).AsString:=dsDokZ.FieldByName(fldObl).AsString+s1;
      if fldOblBel<>''
        then dsPerson.FieldByName(fldOblBelP).AsString:=dsDokZ.FieldByName(fldOblBel).AsString+s2;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TGisun.DecodeObl_MestoRogd( dsDokZ:TDataSet; fldObl,fldOblTip,fldOblBel: String; dsPerson:TDataSet) : String;
var
  s:String;
begin
{
;����� ��������
OBL_R              ftString       80   ResponsePerson.data.birth_place.area_b                  ;������� ��������
OBL_B_R            ftString       80   ResponsePerson.data.birth_place.area_b_bel              ;������� �������� �� ����������� �����
}
  dsDokZ.FieldByName(fldOblTip).AsString:='';   // null
  // ������������ �� ��� ��
  s:=dsPerson.FieldByName('OBL_R').AsString;

  if (Pos('�������', ANSIUpperCase(s))>0)then begin
    dsDokZ.FieldByName(fldOblTip).AsBoolean:=true;
    s:=Trim(StringReplace(s,'�������','',[rfIgnoreCase]));
  end;

  dsDokZ.FieldByName(fldObl).AsString:=CaseAdres(s);
// ���� � �������� ��� ����� �������
//  if (Pos('�������', ANSIUpperCase(s))=0) and (Pos('����', ANSIUpperCase(s))=0) then begin
//    dsDokZ.FieldByName(fldOblTip).AsBoolean:=true;
//  end;
  if fldOblBel<>'' then begin
    s:=dsPerson.FieldByName('OBL_B_R').AsString;
    if (Pos('��������', ANSIUpperCase(s))>0)then begin
      s:=Trim(StringReplace(s,'��������','',[rfIgnoreCase]));
    end else if (Pos('�����C��', ANSIUpperCase(s))>0)then begin  // ����� "C" ����������
      s:=Trim(StringReplace(s,'�����C��','',[rfIgnoreCase]));
    end;
    dsDokZ.FieldByName(fldOblBel).AsString:=CaseAdres(s);
  end;
end;
//-------------------------------------------------
function TGisun.Decode_Obl(Obl,OblB: String): String;
begin
  Obl:=CaseAdres(Obl);
  Result:=Obl;
  if IsCheckBelNazv then begin
    if OblB='' then begin
      dmBase.CheckNazv(1, false, Obl);
    end else begin
      dmBase.CheckBelNazv(1, false, Obl, CaseAdres(OblB));
    end;
  end;
end;
//------------------------------------------------------------------------------
function TGisun.DecodeObl_MestoSmert( dsDokZ:TDataSet; fldObl,fldOblTip,fldOblBel: String; dsPerson:TDataSet) : String;
var
  s:String;
begin
{
S_OBL              ftString       50   ResponsePerson.data.deaths.death_data.decease_place.area_d       ;�������
S_OBL_B            ftString       50   ResponsePerson.data.deaths.death_data.decease_place.area_d_bel   ;������� �� �����������
}
  dsDokZ.FieldByName(fldOblTip).AsString:='';   // null
  // ������������ �� ��� ��
  s:=dsPerson.FieldByName('S_OBL').AsString;

  if (Pos('�������', ANSIUpperCase(s))>0)then begin
    dsDokZ.FieldByName(fldOblTip).AsBoolean:=true;
    s:=Trim(StringReplace(s,'�������','',[rfIgnoreCase]));
  end;
  dsDokZ.FieldByName(fldObl).AsString:=CaseAdres(s);
  {
  if fldOblBel<>'' then begin
    s:=dsPerson.FieldByName('OBL_B_R').AsString;
    if (Pos('��������', ANSIUpperCase(s))>0)then begin
      s:=StringReplace(s,'��������','',[rfIgnoreCase])
    end else if (Pos('�����C��', ANSIUpperCase(s))>0)then begin  // ����� "C" ����������
      s:=StringReplace(s,'�����C��','',[rfIgnoreCase])
    end;
    dsDokZ.FieldByName(fldOblBel).AsString:=CaseAdres(s);
  end;
  }
end;

//-------------------------------------------------
function TGisun.Decode_Raion(Raion,RaionB: String): String;
begin
  Raion:=CaseAdres(Raion);
  Result:=Raion;
  if IsCheckBelNazv then begin
    if RaionB='' then begin
      dmBase.CheckNazv(2, false, Raion);
    end else begin
      dmBase.CheckBelNazv(2, false, Raion, CaseAdres(RaionB));
    end;
  end;
end;
//-------------------------------------------------
function TGisun.Decode_RnGorod(ds: TDataSet; arrFields: array of TVarRec; var strSoato: String): String;
begin
// arrFields[0] - ��� ���� ���� ������ , arrFields[1] - ��� ���� �������� ������
  Result:=ds.FieldByName( VarRecToStr(arrFields[1]) ).AsString;
  if (Result<>'') then begin
    Result:=CaseAdres(Result);
    dmBase.CheckNazv(4, false, Result);
  end;
end;
//-------------------------------------------------
procedure TGisun.SetIsDebug(const Value: Boolean);
begin
  FIsDebug := Value;
end;

function TGisun.GetPoleGrn(ds: TDataSet): Integer;
var
   POLE_GRN: TField;
begin
   POLE_GRN:=ds.FieldByName('POLE_GRN');
   Result:=POLE_GRN.AsInteger div 1000;
end;

//procedure TGisun.SetPoleGrn(Field: TField; Value: Integer);
//begin
//   Field.AsInteger:=Value*1000+(Field.AsInteger mod 1000);
//end;

procedure TGisun.SetPoleGrn(Field: TField; Value: Integer; SubValue: Integer; FieldDate:TField);
begin
   if SubValue=-1
     then SubValue:=Field.AsInteger mod 1000;
   Field.AsInteger:=Value*1000+SubValue;
   if FieldDate<>nil
     then FieldDate.AsDateTime:=Now;
end;

{
procedure TGisun.SetPoleGrnSub(Field: TField; Value: Integer);
begin
   Field.AsInteger:=(Field.AsInteger div 1000)+Value;
end;
}
function TGisun.GetPoleGrn(Field: TField): Integer;
begin
   Result:=Field.AsInteger div 1000;
end;

function TGisun.GetPoleGrn(Value: Integer): Integer;
begin
   Result:=Value div 1000;
end;

function TGisun.GetPoleGrn(Value: string): Integer;
begin
   Result:=StrToIntDef(Value, 0) div 1000;
end;

function TGisun.GetPoleGrnSub(Value: Integer): Integer;
begin
   Result:=(Value mod 1000);
end;

procedure TGisun.SetDateTime(DstField, SrcField: TField);
begin
   if SrcField.IsNull then begin
      DstField.AsString:='';
   end
   else begin
      DstField.AsDateTime:=SrcField.AsDateTime;
   end;
end;

function TGisun.CheckIdentif(Simple: TfmSimpleD; var Error: string): Boolean;
{$IFDEF ZAGS}
var
   Akt: TfmZapisRogdV;
{$ENDIF}
begin
  Result:=false;
{$IFDEF ZAGS}
   Akt:=TfmZapisRogdV(Simple);
   Akt.Dokument.CheckBrowseMode;

   if not CheckMessageSource(Akt, Error) then begin
     exit;
   end;

{!!!}TypeAkt:='0100';//'1100';
   TypeMessage:='1100'; //�������������� �/� � ��������
   Female:=Akt.DokumentONA_IDENTIF.AsString<>'';
   Male:=Akt.DokumentON_IDENTIF.AsString<>'';

//   ChildIdentif:=Akt.DokumentIDENTIF.AsString='';
//   Child:=not ChildIdentif;

  //----- !!! ----------------- �� � ������� ������ ������������ ������ 09.12.2011  ��������� ��������
//   ChildIdentif:=false;
   Child:=false; //Akt.DokumentIDENTIF.AsString<>'';
//   ChildIdentif:=Akt.DokumentIDENTIF.AsString='';

  if Akt.DokumentCHERN.AsInteger=1
    then ChildIdentif:=true // ����� �� ��� �������
    else ChildIdentif:=false; // �� ����� �� ��� �������

   RunExchange:=Female or Male or Child or ChildIdentif;
   Error:='';
   {
   if (Akt.DokumentIDENTIF.AsString='') and Child then AddString(Error, '��������� ������������� �������', #13#10);
   if Akt.DokumentON_IDENTIF.AsString='' then AddString(Error, '��������� ������������� ����', #13#10);
   if Akt.DokumentONA_IDENTIF.AsString='' then AddString(Error, '��������� ������������� ������', #13#10);
   }
   Result:=Error='';
{$ENDIF}
end;

function TGisun.NotOtmenaAkt(Simple: TfmSimpleD): Boolean;
{$IFNDEF ADD_ZAGS}
begin
  Result:=false;
end;
{$ELSE}
var
   Akt: TfmZapisRogd;
   PoleGrn: Integer;
   PoleGrnSub: Integer;
begin
   Result:=False;
   Akt:=TfmZapisRogd(Simple);
   Akt.Dokument.CheckBrowseMode;
   PoleGrn:=GetPoleGrn(Akt.DokumentPOLE_GRN.AsInteger);
   PoleGrnSub:=GetPoleGrnSub(Akt.DokumentPOLE_GRN.AsInteger);
   //1. ������ ���� ��� ���� �������� � ��� ��
   //������� �������, ��� ������ ��������������� �� ���������
   if PoleGrn=rPost then begin
      //������ ������������� �/� � ��������
      TypeMessage:='3100';
      TypeAkt:='0100';
      Male:=(PoleGrnSub and bMale)=bMale;
      Female:=(PoleGrnSub and bFemale)=bFemale;
      Result:=RegisterAkt(Simple,false);
   end
   //2. ������ ������� �� ������������ � ��� ��
   //������� ���������� ��������� ������� ���������������
   else if PoleGrn=rNone then begin
      //{!!!}�����������
   end
   else begin
      ShowMessageErr('������ ���� �� ����������������.');
      Result:=False;
   end;
end;
{$ENDIF}

function TGisun.OtmenaAkt(Simple: TfmSimpleD): Boolean;
{$IFNDEF ADD_ZAGS}
begin
  Result:=false;
end;
{$ELSE}
var
   Akt: TfmZapisRogd;
   PoleGrn: Integer;
   PoleGrnSub: Integer;
begin
   Result:=False;
   Akt:=TfmZapisRogd(Simple);
   Akt.Dokument.CheckBrowseMode;
   PoleGrn:=GetPoleGrn(Akt.DokumentPOLE_GRN.AsInteger);
   PoleGrnSub:=GetPoleGrnSub(Akt.DokumentPOLE_GRN.AsInteger);
   //1. ������ ���� ��� ���� �������� � ��� ��
   //������� �������, ��� ������ ��������������� �� ���������
   if PoleGrn=rPost then begin
      //������������� �/� � ��������
      TypeMessage:='0190';
      TypeAkt:='0100';
      Male:=(PoleGrnSub and bMale)=bMale;
      Female:=(PoleGrnSub and bFemale)=bFemale;
      Result:=RegisterAkt(Simple,false);
   end
   //2. ������ ������� �� ������������ � ��� ��
   //������� ���������� ��������� ������� ���������������
   else if PoleGrn=rNone then begin
      //{!!!}�����������
      //��������� �� ��� ������ (��� �������������)
      //��� ��������� ������ �� (��� �������������)
   end
   else begin
      ShowMessageErr('������ ���� �� ����������������.');
      Result:=False;
   end;
end;
{$ENDIF}

//�������� ����:
//2100 - ������ ���������� ������������� � �������� � �������� ��;
function TGisun.RegisterPovtorAkt(Simple: TfmSimpleD): Boolean;
{$IFNDEF ADD_ZAGS}
begin
  Result:=false;
end;
{$ELSE}
var
   Akt: TfmZapisRogd;
   PoleGrn: Integer;
   PoleGrnSub: Integer;
begin
   Result:=False;
   Akt:=TfmZapisRogd(Simple);
   Akt.Dokument.CheckBrowseMode;
   PoleGrn:=GetPoleGrn(Akt.DokumentPOLE_GRN.AsInteger);
   PoleGrnSub:=GetPoleGrnSub(Akt.DokumentPOLE_GRN.AsInteger);
   //1. ������ ���� ��� ���� �������� � ��� ��
   //������� �������, ��� ������ ��������������� �� ���������
   if PoleGrn=rPost then begin
      //������ ���������� ������������� � �������� ��� ������� ��
      TypeMessage:='2101';
      TypeAkt:='0100';
      Male:=(PoleGrnSub and bMale)=bMale;
      Female:=(PoleGrnSub and bFemale)=bFemale;
      Result:=RegisterAkt(Simple,false);
   end
   //2. ������ ������� �� ������������ � ��� ��
   //������� ���������� ��������� ������� ���������������
   else if PoleGrn=rNone then begin
      //{!!!}�����������
      //��������� �� ��� ������ (��� �������������)
      //��� ��������� ������ �� (��� �������������)
   end
   else begin
      ShowMessageErr('������ ���� �� ����������������.');
      Result:=False;
   end;
end;
{$ENDIF}

//{!!!}
//�������� ����:
//0180 - ��������� �/� � �������� � �������� ��;
//0182 - ��������� �/� � �������� � ����� � ������������ ������� ��������;
//0183 - ��������� �/� � �������� � ����� � ������������ ������� ��������;
function TGisun.ChangeAkt(Simple: TfmSimpleD): Boolean;
{$IFNDEF ADD_ZAGS}
begin
  Result:=false;
end;
{$ELSE}
var
   Akt: TfmZapisRogd;
   PoleGrn: Integer;
   PoleGrnSub: Integer;
begin
   Result:=False;
   Akt:=TfmZapisRogd(Simple);
   Akt.Dokument.CheckBrowseMode;
   PoleGrn:=GetPoleGrn(Akt.DokumentPOLE_GRN.AsInteger);
   PoleGrnSub:=GetPoleGrnSub(Akt.DokumentPOLE_GRN.AsInteger);
   //1. ������ ���� ��� ���� �������� � ��� ��
   //������� �������, ��� ������ ��������������� �� ���������
   if PoleGrn=rPost then begin
      //��������� �/� � �������� ��� ������� ��
      TypeMessage:='0181';
      TypeAkt:='0100';
      Male:=(PoleGrnSub and bMale)=bMale;
      Female:=(PoleGrnSub and bFemale)=bFemale;
      Result:=RegisterAkt(Simple,false);
   end
   //2. ������ ������� �� ������������ � ��� ��
   //������� ���������� ��������� ������� ���������������
   else if PoleGrn=rNone then begin
      //{!!!}�����������
      //��������� �� ��� ������ (��� �������������)
      //��� ��������� ������ �� (��� �������������)
   end
   else begin
      ShowMessageErr('������ ���� �� ����������������.');
      Result:=False;
   end;
end;
{$ENDIF}

{$IFDEF ADD_ZAH}
//=== begin AktZAH ==========================================================
// ��� � �����������
//===========================================================================
function TGisun.SetTypeMessageAktZAH(Akt: TfmSimpleD; var strError: String): Boolean;
var
  Vozrast,m,d : Integer;
begin
  Akt.Dokument.CheckBrowseMode;
  if not CheckMessageSource(Akt, strError) then begin
    Result:=false;
    exit;
  end;
  strError:='';
  Person:=true; // ����� ������ � ��������
  ChildIdentif:=false; // ����� �� ��� �������������������
  RunExchange:=true;  // ��������� ������������� ��� ���
  DefaultPoleGrn:=0;  // �������� ��� ���� POLE_GRN ���� �� ���� ������������ ��������������
  Vozrast:=0;
  TypeAkt:=AKT_ZAH;
  TypeMessage:=AKT_ZAH;
//  if Trim(Akt.Dokument.FieldByName('LICH_NOMER').AsString)='' then begin
//    strError:='��������� ����������������� �����';
//  end;
  if (Akt.Dokument.FieldByName('LICH_NOMER') .AsString<>'') and (Length(Trim(Akt.Dokument.FieldByName('LICH_NOMER') .AsString))=LEN_IN)
    then Person:=true
    else Person:=false;
  if (Akt.Dokument.FieldByName('DECL_IN') .AsString<>'') and (Length(Trim(Akt.Dokument.FieldByName('DECL_IN') .AsString))=LEN_IN)
    then DeclMen:=true
    else DeclMen:=false;
  if not DeclMen and not Person then begin
    strError:='��������� ����������������� �����';
  end;
  if strError=''
    then Result:=true
    else Result:=false;
end;

//--------------------------------------------------------------------
// ��������� ������ ��� ������� ������ � ������
function TGisun.GetAktZAH(Akt: TfmSimpleD): Boolean;
var
  AktSmert : TfmAktZ;
  strError,strSOATO : String;
  n,PoleGrnSub,nType : Integer;
  ag:TGorodR; // ����� � ������
  p : TPassport;
  s : String;
  dDAte:TDateTime;
  r:TPunktMesto;
  lLoadFIO:Boolean;
  col:TColor;
begin
//  ShowMessage(IntToStr(RegInt.Version));
  Result:=false;
  AktSmert := TfmAktZ(Akt);
  AktSmert.Dokument.CheckBrowseMode;
  if not SetTypeMessageAktZAH( AktSmert, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end else begin
    ClearDataSets;
    if RunExchange then begin
      PoleGrnSub:=0;
      //[1] ������ ������
      //1. ������ ������� ��� �������� ������ � �������
      Input:=FRegInt.CreateInputTable(akDecease, opGet);
      //2. ��������� ������������ ������
      //�������
      if Person then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='MAN';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktSmert.DokumentLICH_NOMER.AsString);
        Input.Post;
      end;
      //���������
      if DeclMen then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='DECL';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktSmert.DokumentDECL_IN.AsString);
        Input.Post;
      end;
      //3. ��������� ������ � �������
      RequestResult:=RegInt.Get(akZah, QUERY_INFO, Input, Output, Error);
      if IsDebug then begin
         RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_get.txt');
      end;
      if RequestResult=rrOk then begin
        Result:=true;
        AktSmert.Dokument.Edit;
        AktSmert.DokumentSTATUS.AsString:='';
        AktSmert.DokumentTypeMessage.AsString:='';
        AktSmert.MessageID:=RegInt.RequestMessageId;  // �������� ID �������

        if Person and OutPut.Locate('PREFIX','MAN',[]) then begin
          PoleGrnSub:=PoleGrnSub or bPerson or bChildId;
          //������������ ������ ��������
          AktSmert.DokumentLICH_NOMER.AsString:= OutPut.FieldByName('IDENTIF').AsString;
          lLoadFIO:=true;
          AktSmert.DokumentFAMILIA_GIS.AsString:= '';
          AktSmert.DokumentNAME_GIS.AsString   := '';
          AktSmert.DokumentOTCH_GIS.AsString   := '';
          if AktSmert.DokumentLOAD_CHECK.AsString='0' then begin  // ������ �� ���������
            if (AktSmert.DokumentFamilia.AsString<>'') and (ANSIUpperCase(CreateFIO(AktSmert.Dokument,''))<>ANSIUpperCase(CreateFIO(OutPut,''))) then begin
              AktSmert.DokumentFAMILIA_GIS.AsString:= CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
              AktSmert.DokumentNAME_GIS.AsString   := CaseFIO(OutPut.FieldByName('NAME').AsString);
              AktSmert.DokumentOTCH_GIS.AsString   := CaseFIO(OutPut.FieldByName('OTCH').AsString);
              lLoadFIO:=false;
            end;
          end;
          if lLoadFIO then begin
            AktSmert.DokumentLOAD_FIO.AsBoolean:=true;
            AktSmert.DokumentFamilia.AsString := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
            AktSmert.DokumentNAME.AsString    := CaseFIO(OutPut.FieldByName('NAME').AsString);
            AktSmert.DokumentOTCH.AsString    := CaseFIO(OutPut.FieldByName('OTCH').AsString);
          end else begin
            AktSmert.DokumentLOAD_FIO.AsBoolean:=false;
          end;
   //       ShowMessage(OutPut.FieldByName('DATER').AsString+'    '+Vartostr(OutPut.FieldByName('DATER').Value));
          Decode_Date(OutPut.FieldByName('DATER').AsString, AktSmert.DokumentDATER, AktSmert.DokumentONLYGOD_R);
          if OutPut.FieldByName('DATES').AsString<>''
            then Decode_Date(OutPut.FieldByName('DATES').AsString, AktSmert.DokumentDATES, AktSmert.DokumentONLYGOD,'������');
          if OutPut.FieldByName('K_CAUSE').AsString<>'' then begin
            try
              AktSmert.DokumentPR_OSN_NAME.AsString:=OutPut.FieldByName('K_CAUSE').AsString+' '+OutPut.FieldByName('N_CAUSE').AsString;
            except
            end;
          end;
          AktSmert.DokumentPOL.AsString   := Decode_Pol(OutPut.FieldByName('K_POL').AsString);
          if LoadGrag then
            AktSmert.DokumentGRAG.AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
          AktSmert.DokumentSTATUS.AsString := OutPut.FieldByName('K_STATUS').AsString;

          if AktSmert.FLoadGisunZAH and (GetPoleGrn(AktSmert.DokumentPOLE_GRN)<>rPost) then begin
            n:=StrToIntDef(OutPut.FieldByName('ZH_K_KLAD').AsString,0);
            if (n>0) then begin
              if dmBase.SprZAH.Locate('ID_GIS', n, []) then begin
                AktSmert.DokumentZH_KLAD.AsInteger:=dmBase.SprZAH.FieldByName('ID').AsInteger;    // ��������
                AktSmert.DokumentZH_UCH.AsString:=OutPut.FieldByName('ZH_SECTOR').AsString;
                AktSmert.DokumentZH_RAD.AsString:=OutPut.FieldByName('ZH_RAD').AsString;
                AktSmert.DokumentZH_UCH2.AsString:=OutPut.FieldByName('ZH_UCH').AsString;
                AktSmert.DokumentZH_MOG.AsString:=OutPut.FieldByName('ZH_MOG').AsString;
                AktSmert.DokumentZH_STAKAN.AsString:=OutPut.FieldByName('ZH_STAKAN').AsString;
                s:=OutPut.FieldByName('ZH_KLUM').AsString;   //  wall_section   ����� ����. �����/����� ����
                n:=Pos('/', s);
                if n>0 then begin
                  AktSmert.DokumentZH_ST_KLUM.AsString:=Copy(s,1,n-1);
                  AktSmert.DokumentZH_KLUM.AsString:=Copy(s,n+1,Length(s));
                end else begin
                  AktSmert.DokumentZH_ST_KLUM.AsString:=s;
                end;
                AktSmert.DokumentBOOK.AsString:=OutPut.FieldByName('ZH_BOOK').AsString;    // ����� �����
                col:=GetDisableColorGIS;
                AktSmert.edZH_KLAD.Color:=col;
                AktSmert.edBOOK.Color:=col;
                AktSmert.edSector.Color:=col;
                AktSmert.edRow.Color:=col;
                AktSmert.edPlace.Color:=col;
                AktSmert.edMogila.Color:=col;
                AktSmert.edStenaKlum.Color:=col;
                AktSmert.edKlum.Color:=col;
                AktSmert.edKlumStakan.Color:=col;
                AktSmert.edSklep.Color:=col;
              end else begin
                // � ���� ����������� ��� �������� !!!   ������ ��������� !!!
                ShowMessageErr('������� ��� ��������� '#13'����� ����������� "'+InttoStr(n)+' '+OutPut.FieldByName('ZH_N_KLAD').AsString+'" ����������� � ����� �����������');
              end;
            end;
          end;
          if RegInt.Version>=4 then begin
            AktSmert.DokumentSM_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('S_GOSUD').AsString,'');
            DecodeObl_MestoSmert( AktSmert.Dokument, 'SM_OBL','SM_B_OBL','',OutPut);
            AktSmert.DokumentSM_RAION.AsString:=CaseAdres(OutPut.FieldByName('S_RAION').AsString);
            r:=DecodePunkt_MestoSmertEx(OutPut);
            AktSmert.DokumentSM_B_GOROD.AsString:=r.Type_Kod;
            AktSmert.DokumentSM_GOROD.AsString:=r.Name;
            // �������������
            if OutPut.FieldByName('SM_SV_N_DOC_ORGAN').AsString<>''
              then AktSmert.DokumentSVID_ZAGS.AsString:=OutPut.FieldByName('SM_SV_N_DOC_ORGAN').AsString;
            if OutPut.FieldByName('SM_SV_DOC_NOMER').AsString<>''
              then AktSmert.DokumentSVID_NOMER.AsString:=OutPut.FieldByName('SM_SV_DOC_NOMER').AsString;
            try
              if OutPut.FieldByName('SM_SV_DOC_DATE').AsString<>''
                then AktSmert.DokumentDATESV.AsDateTime:=OutPut.FieldByName('SM_SV_DOC_DATE').AsDateTime;
            except
            end;
            // ������ ����
            try
              AktSmert.DokumentZAPAKT_NOMER.AsString:=OutPut.FieldByName('SM_AKT_DOC_NOMER').AsString;
              AktSmert.DokumentZAPAKT_ZAGS.AsString:=OutPut.FieldByName('SM_SV_N_DOC_ORGAN').AsString;
              if OutPut.FieldByName('SM_AKT_DOC_DATE').AsString<>''
                then AktSmert.DokumentZAPAKT_DATE.AsDateTime:=OutPut.FieldByName('SM_AKT_DOC_DATE').AsDateTime;
            except
            end;
          end;

          //���������� ������ (��������, �������������� ��������)
          {
          AktSmert.DokumentDOK_TYPE.AsString:=Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString);
          AktSmert.DokumentDOK_ORGAN.AsString:=OutPut.FieldByName('K_DOC_ORGAN').AsString;
          AktSmert.DokumentDOK_NAME.AsString:=OutPut.FieldByName('N_DOC_ORGAN').AsString;
          AktSmert.DokumentDOK_SERIA.AsString:=OutPut.FieldByName('DOC_SERIA').AsString;
          AktSmert.DokumentDOK_NOMER.AsString:=OutPut.FieldByName('DOC_NOMER').AsString;
          SetDateTime(AktSmert.DokumentDOK_DATE, OutPut.FieldByName('DOC_DATE'));
          if AktSmert.DokumentIS_SDAN_DOK.AsBoolean then begin
            p := dmBase.PasportFromValues(AktSmert.DokumentDOK_TYPE.AsInteger, AktSmert.DokumentDOK_SERIA.AsString,
                                          AktSmert.DokumentDOK_NOMER.AsString, AktSmert.DokumentDOK_NAME.AsString, '',
                                          AktSmert.DokumentDOK_DATE.Value);
            s := dmBase.PasportToText(p,0);
            if s<>'' then begin
              AktSmert.DokumentSDAN_DOK.AsString:=s;
            end;
          end;
          }
          //AktSmert.DokumentDOK_DATE.AsDateTime:=OutPut.FieldByName('DOC_DATE').AsDateTime;
          //--------------- ����� �������� -----------------------
          AktSmert.DokumentRG_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString,
                                                     OutPut.FieldByName('N_GOSUD_R').AsString); //������ ��������
          DecodeObl_MestoRogd( AktSmert.Dokument,'RG_OBL','RG_B_OBL','',OutPut);
          AktSmert.DokumentRG_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,''); //����� ��������
          DecodePunkt_MestoRogd(AktSmert.Dokument, 'RG_B_GOROD', 'RG_GOROD', '', OutPut);
          //-------------- ��������� ����� ����������  -----------------
          if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
            AktSmert.DokumentPR_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');
            DecodeObl_MestoGit( AktSmert.Dokument,'PR_OBL','PR_B_OBL','',OutPut);
            AktSmert.DokumentPR_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');
            DecodePunkt_MestoGit(AktSmert.Dokument, 'PR_B_GOROD', 'PR_GOROD', '', OutPut);
            ag:=GetGorodREx(OutPut);
            AktSmert.DokumentPR_GOROD_R.AsString:=ag.Ulica;
            AktSmert.DokumentPR_DOM.AsString:=ag.Dom;
            AktSmert.DokumentPR_KORP.AsString:=ag.Korp;
            AktSmert.DokumentPR_KV.AsString:=ag.Kv;
//            AktSmert.DokumentPR_RNGOROD.AsString:=Decode_RnGorod(OutPut, ['K_RN_GOROD','N_RN_GOROD'], strSoato);
//            AktSmert.CheckSoatoAkt(true);
          end;

        end;
        if DeclMen and OutPut.Locate('PREFIX','DECL',[]) then begin
          s:=CaseFIO(OutPut.FieldByName('FAMILIA').AsString)+' '+CaseFIO(OutPut.FieldByName('NAME').AsString)+' '+
             CaseFIO(OutPut.FieldByName('OTCH').AsString);
          //-------------- ����� ���������� -----------------
          if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
            DecodeObl_MestoGit( AktSmert.Dokument,'GT_OBL','GT_B_OBL','',OutPut);
            AktSmert.DokumentGT_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');
            DecodePunkt_MestoGit(AktSmert.Dokument, 'GT_B_GOROD', 'GT_GOROD', '', OutPut);
            ag:=GetGorodREx(OutPut);
            AktSmert.DokumentGT_GOROD_R.AsString:=ag.Ulica;
            AktSmert.DokumentGT_DOM.AsString:=ag.Dom;
            AktSmert.DokumentGT_KORP.AsString:=ag.Korp;
            AktSmert.DokumentGT_KV.AsString:=ag.Kv;
//              s:=s+', '+AdresToString(Output);
          end;
          AktSmert.DokumentDECL.AsString:=s;
          try
            //----- ���������� ������ (��������, �������������� ��������)
            p:=dmBase.PasportFromValues(StrToIntDef(Decode_Dokument(OutPut.FieldByName('K_DOC_TYPE').AsString),888),
                    OutPut.FieldByName('DOC_SERIA').AsString, OutPut.FieldByName('DOC_NOMER').AsString,
                    OutPut.FieldByName('N_DOC_ORGAN').AsString, '', OutPut.FieldByName('DOC_DATE').AsDateTime);
            s:=dmBase.PasportToText(p,0);
            if s<>''
              then AktSmert.DokumentDECL_DOK.AsString:=s;
          except
          end;
        end;
        if not Result then begin
          SetPoleGrn(AktSmert.DokumentPOLE_GRN, 0, 0);
        end else begin
          SetPoleGrn(AktSmert.DokumentPOLE_GRN, 2, PoleGrnSub);
          AktSmert.DokumentTypeMessage.AsString:=TypeMessage;
        end;
        AktSmert.Dokument.Post;
      end else begin
        HandleError(RequestResult, akDecease, opGet, Input, Output, Error, RegInt.FaultError);
      end;
      ClearDataSets;
    end;
  end;
end;
//-----------------------------------------------------------------------
// ����������� ���� � �����������
function TGisun.RegisterAktZAH(Akt: TfmSimpleD; lEmptyPrSmert:Boolean): Boolean;
var
  AktSmert : TfmAktZ;
  s,strError : String;
  nID,nID_GIS,PoleGrn:Integer;
  dDateDok:TDateTime;
  ATE:TATE;
  fld:TField;
begin
  Result:=false;
  AktSmert := TfmAktZ(Akt);
  AktSmert.Dokument.CheckBrowseMode;
  Result:=SetTypeMessageAktZAH( AktSmert, strError);
  if not Result then begin
    ShowMessageErr(strError);
    exit;
  end;

  strError:='';
  ATE.ATE_ID:=0;
  nID_GIS:=0;
  dDateDok:=0;
  if Result and Gisun.FCheckZaprosZah then begin
    PoleGrn:=GetPoleGrn(AktSmert.DokumentPOLE_GRN.AsInteger);
    if (PoleGrn<>rNotRequired) and (PoleGrn<>rPost) and (AktSmert.DokumentSTATUS.AsString='') then begin
      strError:='������ ��� ��������� �� ������������� � ��� ��';
      Result:=false;
    end;
  end;
  if Result then begin
    if not AktSmert.IsRegisterGisun then begin
      strError:='�� ����������� �������� �� �������� �������� � ��� ��';
    end else begin
      nID:=AktSmert.DokumentZH_KLAD.AsInteger;    // ��������
      if nID>0 then begin
        if dmBase.SprZAH.Locate('ID', nID, []) then begin
          nID_GIS:=dmBase.SprZAH.FieldByName('ID_GIS').AsInteger;
          ATE.ATE_ID:=dmBase.SprZAH.FieldByName('ATE').AsInteger;
          if ATE.ATE_ID=0 then strError:='����������� ��� ��� ����������';
          if nID_GIS=0 then strError:='����������� ��� ����� ����������� � ��� ��';
          dDateDok:=BookKlad_Date(nID, AktSmert.DokumentBOOK.AsInteger);
          if dDateDok=0 then begin
            strError:='���������� ���� ����� �'+AktSmert.DokumentBOOK.AsString;
          end else if (dDateDok>Now) or (dDateDok<STOD('1945-01-01',tdAds)) then begin
            strError:='�������� ���� �������� ����� �'+AktSmert.DokumentBOOK.AsString+': '+DatePropis(dDateDok,3);
          end;
        end else begin
          strError:='����������� ��� ����� ����������� '+IntToStr(nID);
        end;
      end else begin
        strError:='��������� ����� �����������';
      end;
    end;
    if strError<>'' then Result:=false;
    if Result then begin
      s:=Trim(FullNameFromATE(ATE,0,', '));
      if s='' then begin   // �� ����� � �������������� ���  ATE.ATE_ID
        strError:='����������� ��� ��� ���������� '+IntToStr(ATE.ATE_ID);
        Result:=false;
      end;
    end;

  end;

//  if Result then begin
//    CheckAllAkt(AktSmert,strError);
//    if (strError<>'') then begin
//      Result:=false;
//    end;
//  end;

  if (strError<>'') then begin
    ShowMessageErr(strError);
  end;

  if Result then begin
    Result:=false;
    ClearDataSets;
    //[2] �������� ������
    //1. ������ ������� ��� �������� ������ � �������
    Input:=FRegInt.CreateInputTable(akZah, opPost);
    //2. ��������� ������������ ������
    Input.Append;
    //������������ ������ ��������
    Input.FieldByName('IDENTIF').AsString:=AktSmert.DokumentLICH_NOMER.AsString; //������������ �����
    Input.FieldByName('FAMILIA').AsString:=AktSmert.DokumentFamilia.AsString; //������� �� ������� �����
    Input.FieldByName('NAME').AsString:=AktSmert.DokumentName.AsString; //��� �� ������� �����
    Input.FieldByName('OTCH').AsString:=AktSmert.DokumentOtch.AsString;
//    Input.FieldByName('POL').AsString:=Code_Pol(AktSmert.DokumentPOL.AsString);
//    Input.FieldByName('DATER').AsString:=Code_Date(AktSmert.DokumentDateR.AsDateTime, AktSmert.DokumentONLYGOD_R); //���� ��������
//    Input.FieldByName('GRAJD').AsString:=Code_Alfa3(AktSmert.DokumentGRAG.AsString); //�����������
//    Input.FieldByName('STATUS').AsString:=AktSmert.DokumentSTATUS.AsString; //������
    //���������� � ������
    Input.FieldByName('ZH_K_GOSUD').AsString:='BLR';
    Input.FieldByName('ZH_K_OBL').AsInteger:=ATE.idOBL;
    Input.FieldByName('ZH_K_RAION').AsInteger:=ATE.idRAION;
    Input.FieldByName('ZH_K_SS').AsInteger:=ATE.idSS;
    Input.FieldByName('ZH_K_NP').AsInteger:=ATE.idPunkt; // ATE.ATE_ID;
    Input.FieldByName('ZH_K_KLAD').AsInteger:=nID_GIS;
    Input.FieldByName('ZH_UCH').AsString:=Trim(AktSmert.DokumentZH_UCH.AsString);
    Input.FieldByName('ZH_RAD').AsString:=Trim(AktSmert.DokumentZH_RAD.AsString);
    Input.FieldByName('ZH_UCH2').AsString:=Trim(AktSmert.DokumentZH_UCH2.AsString);
    fld:=Input.FindField('ZH_MOG');
    if fld<>nil then begin
      fld.AsString:=Trim(AktSmert.DokumentZH_MOG.AsString);  // ZH_MOG
      Input.FieldByName('ZH_SKLEP').AsString:=Trim(AktSmert.DokumentZH_SKLEP.AsString);    // ����� ������
      Input.FieldByName('ZH_STAKAN').AsString:=Trim(AktSmert.DokumentZH_STAKAN.AsString);  // ����� ������� � �����. ���������
      s:=Trim(AktSmert.DokumentZH_ST_KLUM.AsString);   // ����� ����. �����/����� ����
      if s<>'' then begin
        if Trim(AktSmert.DokumentZH_KLUM.AsString)<>''
          then s:=s+'/'+Trim(AktSmert.DokumentZH_KLUM.AsString);
        Input.FieldByName('ZH_KLUM').AsString:=s;
      end;
    end;
    // ����:   ���� ������ � ������� (DATEZ) ��� SprZah.book_date ��� SprKnig.book_date  !!!

//  Input.FieldByName('DOC_NOMER').AsString:=AktSmert.DokumentNOMER.AsString;  // ����� ������
//  Input.FieldByName('DOC_DATE').AsDateTime:=AktSmert.DokumentDATEZ.AsDateTime

    Input.FieldByName('DOC_NOMER').AsString:=AktSmert.DokumentBOOK.AsString;     // ����� �����
    Input.FieldByName('DOC_DATE').AsDateTime:=dDateDok; // ���� ������   !!!
    if dDateDok < STOD('2016-07-29',tdAds)   // ���� ���������� � ���� ������������� �� ������� ���� �� �����
    //��� ���������  �������. 133
      then Input.FieldByName('DOC_TIP').AsInteger:=1    // ��������������� �����
      else Input.FieldByName('DOC_TIP').AsInteger:=2;   // ����� ���������������� ����� �������� ��� �����������, ���� � ����������, �������

    Input.FieldByName('DOC_ORGAN').AsString:=MessageSource;    // !!!  �������. 142 ��� 80   (������� ������ 80) !!!

//    AktSmert.DokumentZH_KLUM.AsString;
    Input.Post;
//    RegInt.Log.Add(s);
    //3. ��������� ������ � �������

    RequestResult:=RegInt.Post(AktSmert.MessageID, akZah, AKT_ZAH, Input, Error);

    LogToTableLog(AktSmert, '����������� ���� � �����������');
    if RequestResult=rrOk then begin
      AktSmert.Dokument.CheckBrowseMode;
      AktSmert.Dokument.Edit;
      SetPoleGrn(AktSmert.DokumentPOLE_GRN, 3);
      AktSmert.Dokument.Post;
      if not HandleErrorToString
        then ShowMessageCont(GetMessageOk,CurAkt);
      Result:=true;
    end else begin
      Result:=false;
      HandleError(RequestResult, akDecease, opGet, Input, Output, Error, FRegInt.FaultError);
    end;
    if IsDebug then begin
       RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_post.txt');
    end;
  end;
end;

//---------------------------------------------------------------
procedure TGisun.CheckAktZAH(Simple: TfmSimpleD);
const
  CComponentName: array [1..32] of record
      Name: string;
      Code: Integer;
      Color: TColor;
   end=(
     //�e�����
     //������������ ������ ��������
     (Name:'ENG_edIDENTIF'; Code: bChildId; Color: clDefault),
     (Name:'ENG_edIDENTIF_Akt'; Code: bChildId; Color: clDefault),

     (Name:'edFamilia'; Code: bPerson; Color: clDefault),
     (Name:'edNAME'; Code: bPerson; Color: clDefault),
     (Name:'edOTCH'; Code: bPerson; Color: clDefault),
     (Name:'edFamilia_Akt'; Code: bPerson; Color: clDefault),
     (Name:'edNAME_Akt'; Code: bPerson; Color: clDefault),
     (Name:'edOTCH_Akt'; Code: bPerson; Color: clDefault),
     (Name:'edDATER'; Code: bChildId; Color: clDefault),
     (Name:'edDATES'; Code: bChildId; Color: clDefault),
     (Name:'edDATER_Akt'; Code: bChildId; Color: clDefault),
     (Name:'N_F_cbOnlyGodR'; Code: bChildId; Color: clDefault),
     (Name:'N_F_cbOnlyGodR_Akt'; Code: bChildId; Color: clDefault),
     (Name:'edPOL'; Code: bChildId; Color: clDefault),
     (Name:'edPOL_Akt'; Code: bChildId; Color: clDefault),
//     (Name:'edGRAG'; Code: bPerson; Color: clDefault),         //???
     (Name:'edRG_GOSUD'; Code: bPerson; Color: clDefault),
     (Name:'edRG_OBL'; Code: bPerson; Color: clDefault),
     (Name:'edRG_RAION'; Code: bPerson; Color: clDefault),
     (Name:'edRG_B_GOROD'; Code: bPerson; Color: clDefault),
     (Name:'edRG_GOROD'; Code: bPerson; Color: clDefault),

     (Name:'edSM_GOSUD'; Code: bPerson; Color: clDefault),
//     (Name:'cbSM_OBL'; Code: bPerson; Color: clDefault),
     (Name:'edSM_OBL'; Code: bPerson; Color: clDefault),
     (Name:'edSM_RAION'; Code: bPerson; Color: clDefault),
     (Name:'edSM_B_GOROD'; Code: bPerson; Color: clDefault),
     (Name:'edSM_GOROD'; Code: bPerson; Color: clDefault),

     (Name:'edSVID_NOMER'; Code: bPerson; Color: clDefault),
     (Name:'edSVID_DATE'; Code: bPerson; Color: clDefault),
     (Name:'edSVID_ZAGS'; Code: bPerson; Color: clDefault),

     (Name:'edZAPAKTNOMER'; Code: bPerson; Color: clDefault),
     (Name:'edZAPAKTDATE'; Code: bPerson; Color: clDefault),
     (Name:'edZAPAKTZAGS'; Code: bPerson; Color: clDefault),

     (Name:'edPrOsn_Name'; Code: bPerson; Color: clDefault)
   );
var
   Akt: TfmAktZ;
   PoleGrn: Integer;
   PoleGrnSub: Integer;
   I: Integer;
   Component: TComponent;
   Control: TControl;
   lDisable,l: Boolean;
   col:TColor;
begin
   Akt:=TfmAktZ(Simple);
   l:=(IsEnabled and IsEnableTypeAkt(_TypeObj_AktZAH,false));
   if l then begin
     PoleGrn:=GetPoleGrn(Akt.DokumentPOLE_GRN.AsInteger);
     PoleGrnSub:=GetPoleGrnSub(Akt.DokumentPOLE_GRN.AsInteger);
   end else begin
     PoleGrn:=0;
     PoleGrnSub:=0;
   end;
   {
   if PoleGrn=rPost then begin
     Akt.TbItemEmptyPrich.Enabled:=false;
   end else begin
     Akt.TbItemEmptyPrich.Enabled:=true;
   end;
   }
   //2. ������������ ����������� ��������� ��������������
   //����� ��������� ������ �� ��� �� �������� �������������� ������ ����� ����������
   for I:=Low(CComponentName) to High(CComponentName) do begin
      Component:=Akt.FindComponent(CComponentName[I].Name);
      if (Component<>nil) and (Component is TControl) then begin
         Control:=TControl(Component);
         //2.1.
         if l
           then lDisable:=((PoleGrn=2) or (PoleGrn=3)) and ((PoleGrnSub and CComponentName[I].Code)=CComponentName[I].Code)
           else lDisable:=l;

         if lDisable and (PoleGrn=3) then begin
           lDisable:=false;
         end;

         //2.2.
         if lDisable then begin
            SetEnableControl(FTypeEnableControl,Control,false);
            //Control.Enabled:=False;
            if TxControl(Control).Color<>GetDisableColorGIS then begin
               CComponentName[I].Color:=TxControl(Control).Color;
            end;
            TxControl(Control).Color:=GetDisableColorGIS;
         end else begin
            if CComponentName[I].Color<>clDefault then begin
               TxControl(Control).Color:=CComponentName[I].Color;
            end;
            SetEnableControl(FTypeEnableControl,Control,true);
            //Control.Enabled:=True;
         end;
      end
      else begin
         ShowMessageC(CComponentName[I].Name);
      end;
   end;
   if not Akt.DokumentLOAD_FIO.IsNull and not Akt.DokumentLOAD_FIO.AsBoolean then begin
     col:=Akt.edDECL_TEL.Color;
     Akt.edFamilia.Color:=col;
     Akt.edName.Color:=col;
     Akt.edOtch.Color:=col;
   end;

   // !!!!!  ���� ������ ������ ����������� ��������� ��� �������������
//   if Akt.edGRAG.Text='' then begin
//     Akt.edGRAG.Color:=GetControlColor;
//     SetEnableControl(FTypeEnableControl,Akt.edGRAG,true);
//   end;
end;

{$ENDIF}
//== end AktZAH =============================================================


{$IFDEF ADD_OPEKA}
//=== begin AktOpeka  ����� ==========================================================
// ����� � ��������������
//===========================================================================
function TGisun.SetTypeMessageAktOpeka(Akt: TfmSimpleD; var strError: String): Boolean;
var
  Vozrast,m,d : Integer;
  AktOpeka : TfmZapisOpeka;
begin
  Result:=false;
  AktOpeka := TfmZapisOpeka(Akt);
  Akt.Dokument.CheckBrowseMode;
  if not CheckMessageSource(Akt, strError) then begin
    exit;
  end;
  strError:='';
  TypeAkt := AKT_OPEKA;
  Person:=true; // ����� ������ � ��������
  ChildIdentif:=false; // ����� �� ��� �������������������
  RunExchange:=true;  // ��������� ������������� ��� ���
  DefaultPoleGrn:=0;  // �������� ��� ���� POLE_GRN ���� �� ���� ������������ ��������������
  Vozrast:=0;

  Female:=AktOpeka.DokumentMAT_IDENTIF.AsString<>'';   // ����� ������ � ����
  Male:=AktOpeka.DokumentOTEC_IDENTIF.AsString<>'';    // ����� ������ � ����
  MaleU:=AktOpeka.DokumentON_IDENTIF.AsString<>'';     // ����� ������ �� �������
  FemaleU:=AktOpeka.DokumentONA_IDENTIF.AsString<>'';  // ����� ������ �� ������� (�������)
  Child:=AktOpeka.DokumentIDENTIF.AsString<>'';        // ����� ������ � �������
  ChildIdentif:=false;  // ����� �� ��� �������
  //--------------------------------------------
  if not Female and not Male and not MaleU and not FemaleU and not Child then begin
    strError:='�� ������ �� ���� ����������������� �����.';
    exit;
  end;

  TypeMessage:='*';
  if TypeMessage='*'
    then TypeMessage:=AKT_OPEKA;

  if strError=''
    then Result:=true
end;
//--------------------------------------------------------------------
procedure TGisun.AktOpekaAddObrab(data: TPersonalData_; dsOutPut:TDataSet; dsDokument:TDataSet; slPar:TStringList);
var
  setResh:TListReshSud;
  dsResh:TDataSet;
begin
  dsResh:=TDataSet(ObjectFromParams(slPar,'RESH_SUD'));
  setResh:=FRegInt.GetCoursList(data, dsOutPut, dsResh, '', slPar);
end;
//--------------------------------------------------------------------
// ��������� ������ �����
function TGisun.GetAktOpeka(Akt: TfmSimpleD): Boolean;
var
  AktOpeka : TfmZapisOpeka;
  strError,strSOATO : String;
  PoleGrnSub,nType,i : Integer;
  ag:TGorodR; // ����� � ������
  p : TPassport;
  s,ss : String;
  dDate:TDateTime;
  slPar:TstringList;
begin
//  ShowMessage(IntToStr(RegInt.Version));
  Result:=false;
  AktOpeka := TfmZapisOpeka(Akt);
  AktOpeka.Dokument.CheckBrowseMode;
  if not SetTypeMessageAktOpeka( AktOpeka, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end else begin
    ClearDataSets;
    if RunExchange then begin
      PoleGrnSub:=0;
      //[1] ������ ������
      //1. ������ ������� ��� �������� ������ � �������
      Input:=FRegInt.CreateInputTable(akDecease, opGet);
      //2. ��������� ������������ ������
      if Child then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='CHILD';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktOpeka.DokumentIDENTIF.AsString);
        Input.Post;
      end;
      //����������
      if MaleU then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='ON';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktOpeka.DokumentON_IDENTIF.AsString);
        Input.Post;
      end;
      //���������� (������)
      if FemaleU then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='ONA';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktOpeka.DokumentONA_IDENTIF.AsString);
        Input.Post;
      end;
      //����
      if Male then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='OTEC';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktOpeka.DokumentOTEC_IDENTIF.AsString);
        Input.Post;
      end;
      //����
      if Female then begin
        Input.Append;
        Input.FieldByName('IS_PERSON').AsBoolean:=true;
        Input.FieldByName('PREFIX').AsString:='MAT';
        Input.FieldByName('IDENTIF').AsString:=CheckRus2(AktOpeka.DokumentMAT_IDENTIF.AsString);
        Input.Post;
      end;

      //3. ��������� ������ � �������
//      RequestResult:=RegInt.Get(akDecease, TypeMessage, Input, Output, Error);

//   TObrPersonalData = procedure(data: wsGisun.PersonalData; dsOutPut:TDataSet; dsDokument:TDataSet; slPar:TStringList) of object;
      RegInt.FObrPersonalData:=AktOpekaAddObrab;  // �������������� ��������� ��� ������� ������ ��� ������� ����
      slPar:=TStringList.Create;
      AktOpeka.tbReshSud.EmptyTable;
      AktOpeka.cbType.ItemIndex:=0;
      slPar.AddObject('RESH_SUD', AktOpeka.tbReshSud);
      try
        RequestResult:=RegInt.Get(akOpeka, QUERY_INFO, Input, Output, Error, AktOpeka.Dokument, slPar);
      finally
        RegInt.FObrPersonalData:=nil;
        slPar.Free;
      end;
      AktOpeka.pnAdd.Visible:=AktOpeka.CheckAddPanel(s);

      if IsDebug then begin
        RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_get.txt');
      end;
      if RequestResult=rrOk then begin
        Result:=true;
        AktOpeka.Dokument.Edit;
        AktOpeka.DokumentSTATUS.AsString  := '';
        AktOpeka.DokumentTypeMessage.AsString:='';
        AktOpeka.MessageID:=RegInt.RequestMessageId;  // �������� ID �������

        if OutPut.Locate('PREFIX','CHILD',[]) then begin
{!!! ???}          PoleGrnSub:=PoleGrnSub or bPerson or bChildId;
          //������������ ������ �������
          AktOpeka.DokumentIDENTIF.AsString:= OutPut.FieldByName('IDENTIF').AsString;
          AktOpeka.DokumentFamilia.AsString   := CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
          AktOpeka.DokumentNAME.AsString      := CaseFIO(OutPut.FieldByName('NAME').AsString);
          AktOpeka.DokumentOTCH.AsString      := CaseFIO(OutPut.FieldByName('OTCH').AsString);
          Decode_Date2(OutPut.FieldByName('DATER').AsString, dDate, nType);
          if dDate<>0 then AktOpeka.DokumentDATER.AsDateTime:=dDate;
          AktOpeka.DokumentPOL.AsString   := Decode_Pol(OutPut.FieldByName('K_POL').AsString);
          if LoadGrag then
            AktOpeka.DokumentGRAG.AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
          AktOpeka.DokumentSTATUS.AsString := OutPut.FieldByName('K_STATUS').AsString;
          //-----------------����� �������� -------------
          AktOpeka.DokumentRG_GOSUD.AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD_R').AsString, OutPut.FieldByName('N_GOSUD_R').AsString);
          DecodeObl_MestoRogd( AktOpeka.Dokument,'RG_OBL','RG_B_OBL','',OutPut);
          AktOpeka.DokumentRG_RAION.AsString:=Decode_Raion(OutPut.FieldByName('RAION_R').AsString,'');
          DecodePunkt_MestoRogd(AktOpeka.Dokument, 'RG_B_GOROD', 'RG_GOROD', '', OutPut);
          //----------------����� ����������-----------------
          if not AdresGitIsEmpty(OutPut) then begin  // ���� ����� ����� ���������� �� ������ !!!
            DecodeObl_MestoGit( AktOpeka.Dokument,'GT_OBL','GT_B_OBL','',OutPut);
            AktOpeka.DokumentGT_RAION.AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');
            DecodePunkt_MestoGit(AktOpeka.Dokument, 'GT_B_GOROD', 'GT_GOROD', '', OutPut);
            ag:=GetGorodREx(OutPut);
            AktOpeka.DokumentGT_GOROD_R.AsString:=ag.Ulica;
            AktOpeka.DokumentGT_DOM.AsString:=ag.Dom;
            AktOpeka.DokumentGT_KORP.AsString:=ag.Korp;
            AktOpeka.DokumentGT_KV.AsString:=ag.Kv;
            //------------------------
            {$IFDEF GISUN2}
              AktOpeka.DokumentGT_RNGOROD.AsString:=Decode_RnGorod(OutPut, ['K_RN_GOROD','N_RN_GOROD'], strSoato);
            {$ENDIF}
          end;
        end;
        for i:=1 to 4 do begin
          if i=1 then ss:='ON'   else
          if i=2 then ss:='ONA'  else
          if i=3 then ss:='OTEC' else
          if i=4 then ss:='MAT';
          if OutPut.Locate('PREFIX',ss,[]) then begin
            AktOpeka.Dokument.FieldByName(ss+'_IDENTIF').AsString:= OutPut.FieldByName('IDENTIF').AsString;
            AktOpeka.Dokument.FieldByName(ss+'_Familia').AsString:= CaseFIO(OutPut.FieldByName('FAMILIA').AsString);
            AktOpeka.Dokument.FieldByName(ss+'_NAME').AsString   := CaseFIO(OutPut.FieldByName('NAME').AsString);
            AktOpeka.Dokument.FieldByName(ss+'_OTCH').AsString   := CaseFIO(OutPut.FieldByName('OTCH').AsString);
            Decode_Date2(OutPut.FieldByName('DATER').AsString, dDate, nType);
            if dDate<>0 then AktOpeka.Dokument.FieldByName(ss+'_DATER').AsDateTime:=dDate;

            if (i=1) or (i=2) then
              AktOpeka.Dokument.FieldByName(ss+'_POL').AsString    := Decode_Pol(OutPut.FieldByName('K_POL').AsString);

            if LoadGrag then
              AktOpeka.Dokument.FieldByName(ss+'_GRAG').AsString := Decode_Alfa3(OutPut.FieldByName('K_GRAJD').AsString,'***');
            AktOpeka.Dokument.FieldByName(ss+'_STATUS').AsString := OutPut.FieldByName('K_STATUS').AsString;
            //----------------����� ����������-----------------
            if not AdresGitIsEmpty(OutPut) and (i<>2) then begin  // ���� ����� ����� ���������� �� ������ !!!
              AktOpeka.Dokument.FieldByName(ss+'_GOSUD').AsString:=Decode_Alfa3(OutPut.FieldByName('K_GOSUD').AsString,'***');
              DecodeObl_MestoGit( AktOpeka.Dokument,ss+'_OBL',ss+'_B_OBL','',OutPut);
              AktOpeka.Dokument.FieldByName(ss+'_RAION').AsString:=Decode_Raion(OutPut.FieldByName('N_RAION').AsString,'');
              DecodePunkt_MestoGit(AktOpeka.Dokument, ss+'_B_GOROD', ss+'_GOROD', '', OutPut);
              ag:=GetGorodREx(OutPut);
              AktOpeka.Dokument.FieldByName(ss+'_GOROD_R').AsString:=ag.Ulica;
              AktOpeka.Dokument.FieldByName(ss+'_DOM').AsString:=ag.Dom;
              AktOpeka.Dokument.FieldByName(ss+'_KORP').AsString:=ag.Korp;
              AktOpeka.Dokument.FieldByName(ss+'_KV').AsString:=ag.Kv;
              //------------------------
              {$IFDEF GISUN2}
  //              AktOpeka.DokumentON_RNGOROD.AsString:=Decode_RnGorod(OutPut, ['K_RN_GOROD','N_RN_GOROD'], strSoato);
              {$ENDIF}
            end;
          end;
        end;

        if not Result then begin
          SetPoleGrn(AktOpeka.DokumentPOLE_GRN, 0, 0);
        end else begin
          SetPoleGrn(AktOpeka.DokumentPOLE_GRN, 2, PoleGrnSub);
//!!!          AktOpeka.DokumentTypeMessage.AsString:=TypeMessage;
        end;
        AktOpeka.Dokument.Post;
      end else begin
        HandleError(RequestResult, akDecease, opGet, Input, Output, Error, RegInt.FaultError);
      end;
      ClearDataSets;
    end;
  end;
end;
//-----------------------------------------------------------------------
// ����������� �����
function TGisun.RegisterAktOpeka(Akt: TfmSimpleD): Boolean;
var
  AktOpeka : TfmZapisOpeka;
  strError,strPrich,s : String;
  nTypeOpeka,nTypeDoc,nTypeDate, nTypeSn, nTypeSprOrgan:Integer;
  dDateUst, dDateOtm:TDateTime;
  lNotD,lChild:Boolean;
  fldNomerDok, fldDateDok:TField;
begin
  Result:=true;

  {$IFDEF LAIS}
  if not FEnableRegisterOpeka then begin
    ShowMessageErr('����������� ����������.');
    Result:=false;
    exit;
  end;
  {$ENDIF}

  AktOpeka := TfmZapisOpeka(Akt);
  AktOpeka.Dokument.CheckBrowseMode;
  if not SetTypeMessageAktOpeka( AktOpeka, strError) then begin
    ShowMessageErr(strError);
    Result:=false;
  end;
  // ���� ���� ������������ ������ � ��� �����������
  if AktOpeka.DokumentDATEZ.IsNull and not AktOpeka.DokumentUST_OTHER.AsBoolean then begin
    strError:='��������� ���� ������������';
    Result:=false;
  end;
  if Result and (AktOpeka.DokumentDATEZ.IsNull and AktOpeka.DokumentDATE_OTM.IsNull) then begin // and AktOpeka.DokumentDATE_OTST.IsNull and AktOpeka.DokumentDATE_OSV.IsNull) then begin
    strError:='��������� ���� �� ���: ������������ ��� �����������(������������, �����������)';
    Result:=false;
  end;
  nTypeSn:=AktOpeka.DokumentTYPE_SN.AsInteger;
  if not AktOpeka.DokumentDATE_OTM.IsNull and (nTypeSn=0) then begin
    strError:='��������� ��� ����������� �����(��������������)';
    Result:=false;
  end;
  if not Result and (strError<>'') then begin
    ShowMessageErr(strError);
  end;
  if Result then begin
    nTypeOpeka:=AktOpeka.GetTypeOpeka(lNotD,lChild);  // 1-�����  2-��������������

    Result:=false;
    ClearDataSets;
    //[2] �������� ������
    //1. ������ ������� ��� �������� ������ � �������
    if nTypeOpeka=1
      then Input:=FRegInt.CreateInputTable(akOpeka, opPost)
      else Input:=FRegInt.CreateInputTable(akPopech, opPost);

 // while true !!!  ����� ���� �� ON_ � ONA_ ���� � ������ ������� �������� !!!
      //2. ��������� ������������ ������
      TkbmMemTable(Input).EmptyTable;
      Input.Append;
      //������������ ������ �����������
      Input.FieldByName('IDENTIF').AsString:=AktOpeka.DokumentIDENTIF.AsString; //������������ �����
      Input.FieldByName('FAMILIA').AsString:=AktOpeka.DokumentFamilia.AsString; //������� �� ������� �����
      Input.FieldByName('NAME').AsString:=AktOpeka.DokumentName.AsString; //��� �� ������� �����
      Input.FieldByName('OTCH').AsString:=AktOpeka.DokumentOtch.AsString;
      Input.FieldByName('POL').AsString:=Code_Pol(AktOpeka.DokumentPOL.AsString);
      Input.FieldByName('DATER').AsString:=Code_Date(AktOpeka.DokumentDateR.AsDateTime, DATE_FULL); //���� ��������
  //    Input.FieldByName('GRAJD').AsString:=Code_Alfa3(AktOpeka.DokumentGRAG.AsString); //�����������
  //    Input.FieldByName('STATUS').AsString:=AktOpeka.DokumentSTATUS.AsString; //������
      //������������ ������ �������
      Input.FieldByName('ON_IDENTIF').AsString:=AktOpeka.DokumentON_IDENTIF.AsString; //������������ �����
      Input.FieldByName('ON_FAMILIA').AsString:=AktOpeka.DokumentON_Familia.AsString; //������� �� ������� �����
      Input.FieldByName('ON_NAME').AsString:=AktOpeka.DokumentON_Name.AsString; //��� �� ������� �����
      Input.FieldByName('ON_OTCH').AsString:=AktOpeka.DokumentON_Otch.AsString;
      Input.FieldByName('ON_POL').AsString:=Code_Pol(AktOpeka.DokumentON_POL.AsString);
      Input.FieldByName('ON_DATER').AsString:=Code_Date(AktOpeka.DokumentON_DateR.AsDateTime, DATE_FULL); //���� ��������

      Input.FieldByName('ON_GRAJD').AsString:=Code_Alfa3(AktOpeka.DokumentON_GRAG.AsString); //�����������
      if AktOpeka.DokumentON_GRAG.AsInteger<>MY_GRAG then begin
        if AktOpeka.DokumentON_GRAG.AsString=''
          then Input.FieldByName('ON_STATUS').AsString:=ST_FIKT
          else Input.FieldByName('ON_STATUS').AsString:=ST_INOST;
      end else begin
        Input.FieldByName('ON_STATUS').AsString:=AktOpeka.DokumentON_STATUS.AsString;
      end;

      //--------------------------------------------------------------------------
      Input.FieldByName('DATE_UST').AsString:='';
      Input.FieldByName('DATE_OTM').AsString:='';
      Input.FieldByName('DATE_OTST').AsString:='';
//!!! ����� ��������    Input.FieldByName('DATE_OSV').AsString:='';               dismissal_trustee_date       (dismissal-������������)
    {
    property establish_trusteeship_date:   TXSDate       Index (IS_OPTN) read Festablish_trusteeship_date write Setestablish_trusteeship_date stored establish_trusteeship_date_Specified;
    property termination_trusteeship_date: TXSDate       Index (IS_OPTN) read Ftermination_trusteeship_date write Settermination_trusteeship_date stored termination_trusteeship_date_Specified;
    property remove_trustee_date:          TXSDate       Index (IS_OPTN) read Fremove_trustee_date write Setremove_trustee_date stored remove_trustee_date_Specified;
    property dismissal_trustee_date:       TXSDate       Index (IS_OPTN) read Fdismissal_trustee_date write Setdismissal_trustee_date stored dismissal_trustee_date_Specified;
    }

      nTypeDate:=AktOpeka.GetTypeDate;
      dDateUst:=getDateField(AktOpeka.DokumentDATEZ,0);
      if dDateUst>0
        then Input.FieldByName('DATE_UST').AsDateTime:=dDateUst;

      // ------ !!!!!!!!!!!!!!!!!!!!!1! -------------------------------------------------------
      // �.�. ���� ����������� ���� � ��� �� ���, �� ����������� ��� ����, ����� �������: ���� ����������� ����� ��������� ��� �������� � �������
      {  ���� �� 29.04.2019
      dDateOtm:=0
      if not AktOpeka.DokumentDATE_OSV.IsNull
        then dDateOtm:=AktOpeka.DokumentDATE_OSV.AsDateTime;
      if not AktOpeka.DokumentDATE_OTM.IsNull
        then dDateOtm:=AktOpeka.DokumentDATE_OTM.AsDateTime;
      }
      dDateOtm:=getDateField(AktOpeka.DokumentDATE_OTM,0);
      if dDateOtm>0 then begin
        case nTypeSn of
          1: Input.FieldByName('DATE_OTM').AsDateTime:=dDateOtm; // ����� �������� ������ 
          2: Input.FieldByName('DATE_OSV').AsDateTime:=dDateOtm;//  release_guardian_date   release_trustee_date
          3: Input.FieldByName('DATE_OTST').AsDateTime:=dDateOtm;

         { ���� �� 28.01.2021         
          1,2: Input.FieldByName('DATE_OTM').AsDateTime:=dDateOtm; // ����� �������� ������ 1 !!!
//   !!!  2: Input.FieldByName('DATE_OSV').AsDateTime:=dDateOtm;    release_guardian_date
          3: Input.FieldByName('DATE_OTST').AsDateTime:=dDateOtm;
          }
        end;
      end;
      {  ���� �� 29.04.2019
      if dDateOtm>0
        then Input.FieldByName('DATE_OTM').AsDateTime:=dDateOtm;
      //--------------------------------------------------------------------------------------
      Input.FieldByName('DATE_OTST').AsString:='';
      if not AktOpeka.DokumentDATE_OTST.IsNull
        then Input.FieldByName('DATE_OTST').AsDateTime:=AktOpeka.DokumentDATE_OTST.AsDateTime;

      if (dDateOtm=0) and not Input.FieldByName('DATE_OTST').IsNull   //
        then dDateOtm:=Input.FieldByName('DATE_OTST').AsDateTime;     //  ���� ����� �� �����������
      }
      // ------ !!!!!!!!!!!!!!!!!!!!!!! -----

// ����     sNomerDok:=AktOpeka.DokumentNOMER_UST.AsString;     // ����� ������� �� ������������;

      fldNomerDok:=AktOpeka.FieldForNomerDok(fldDateDok); // 26.12.2018

// ����  if not AktOpeka.DokumentDATEZ.IsNull
//         then dDateDok:=AktOpeka.DokumentDATEZ.AsDateTime
//         else dDateDok:=0;

      // ����� ��������� ����� ������� �� ������������
      if fldNomerDok.FieldName='NOMER_UST' then  begin
        s:='������������';
        if AktOpeka.DokumentDOC_OPEKA.IsNull
          then nTypeDoc:=DOC_OPEKA_RESH
          else nTypeDoc:=AktOpeka.DokumentDOC_OPEKA.AsInteger;
      end else begin
        s:=AktOpeka.N_F_edTypeSn.Text;  // !!!
        if AktOpeka.DokumentDOC_OPEKA_OTM.IsNull
          then nTypeDoc:=DOC_OPEKA_RESH
          else nTypeDoc:=AktOpeka.DokumentDOC_OPEKA_OTM.AsInteger;
//        nTypeDoc:=DOC_OPEKA_RESH;  ���� 09.04.2019
      end;

      {$IFDEF LAIS}
        Input.FieldByName('DOC_ORGAN').AsString:=MessageSource;    //  �������. 131
      {$ELSE}
        // ����� ��������� ����� ������� �� ������������
        if fldNomerDok.FieldName='NOMER_UST' then  begin
          if AktOpeka.DokumentUST_ORG_SPR.AsString='' then begin
            Input.FieldByName('DOC_ORGAN').AsString:=MessageSource;    //  �������. 131
          end else begin
            Input.FieldByName('DOC_ORGAN').AsString:=AktOpeka.DokumentUST_ORG_SPR.AsString;    //  �������. 131
            nTypeSprOrgan:=AktOpeka.DokumentUST_ORG_TYPE.AsInteger;
            if (nTypeSprOrgan>0) and (nTypeSprOrgan<>ctOpeka) then begin  // !!!
              Input.FieldByName('DOC_ORGAN').AsString:=Input.FieldByName('DOC_ORGAN').AsString+'#'+IntToStr(nTypeSprOrgan);
            end;
          end;
        end else begin
          if AktOpeka.DokumentOTM_ORG_SPR.AsString='' then begin
            Input.FieldByName('DOC_ORGAN').AsString:=MessageSource;    //  �������. 131
          end else begin
            Input.FieldByName('DOC_ORGAN').AsString:=AktOpeka.DokumentOTM_ORG_SPR.AsString;    //  �������. 131
            nTypeSprOrgan:=AktOpeka.DokumentOTM_ORG_TYPE.AsInteger;
            if (nTypeSprOrgan>0) and (nTypeSprOrgan<>ctOpeka) then begin  // !!!
              Input.FieldByName('DOC_ORGAN').AsString:=Input.FieldByName('DOC_ORGAN').AsString+'#'+IntToStr(nTypeSprOrgan);
            end;
          end;
//          Input.FieldByName('DOC_ORGAN').AsString:=MessageSource;  ���� 09.04.2019
        end;
      {$ENDIF}
      Input.FieldByName('DOC_TIP').AsInteger:=nTypeDoc;          //��� ���������  ��. ����  ������������� 133 (4-������� 8-������ )
      Input.FieldByName('DOC_DATE').AsDateTime:=fldDateDok.AsDateTime;  //  ���� �������, �������
      Input.FieldByName('DOC_NOMER').AsString:=fldNomerDok.AsString;    //  ����� �������, �������

      Input.Post;
      //3. ��������� ������ � �������
      if nTypeOpeka=1
        then RequestResult:=RegInt.Post(AktOpeka.MessageID, akOpeka, AKT_OPEKA{AktOpeka.DokumentTypeMessage.AsString}, Input, Error) // !!!
        else RequestResult:=RegInt.Post(AktOpeka.MessageID, akPopech, AKT_POPECH{AktOpeka.DokumentTypeMessage.AsString}, Input, Error); // !!!

      if nTypeOpeka=1
        then LogToTableLog(AktOpeka, '����������� ���������� �� ����� '+fldNomerDok.FieldName)
        else LogToTableLog(AktOpeka, '����������� ���������� � �������������� '+fldNomerDok.FieldName);
      if RequestResult=rrOk then begin
        AktOpeka.Dokument.CheckBrowseMode;
        AktOpeka.Dokument.Edit;
        SetPoleGrn(AktOpeka.DokumentPOLE_GRN, 3, nTypeDate, nil);   // !!!

//        if not AktOpeka.DokumentDATEZ.IsNull     then AktOpeka.DokumentREG_UST.AsBoolean:=true;
//        if not AktOpeka.DokumentDATE_OTM.IsNull  then AktOpeka.DokumentREG_OTM.AsBoolean:=true;
//        if not AktOpeka.DokumentDATE_OTST.IsNull then AktOpeka.DokumentREG_OTST.AsBoolean:=true;
//!!!      if not AktOpeka.DokumentDATE_OSV.IsNull  then AktOpeka.DokumentREG_OSV.AsBoolean:=true;

        AktOpeka.Dokument.Post;
        AktOpeka.WriteReg;

        if not HandleErrorToString
          then ShowMessageCont(GetMessageOk,CurAkt);
        Result:=true;
      end else begin
        Result:=false;
      // !!! �������� akDecease
        HandleError(RequestResult, akDecease, opGet, Input, Output, Error, FRegInt.FaultError);
      end;
      if IsDebug then begin
         RegInt.Log.SaveToFile(ExtractFilePath(Application.ExeName)+'gisun_post.txt');
      end;
 // end while true !!!  ����� ���� �� ON_ � ONA_ ���� � ������ ������� �������� !!!

  end;
end;
//---------------------------------------------------------------
procedure TGisun.CheckAktOpeka(Simple: TfmSimpleD);
const
  CComponentName: array [1..13] of record
      Name: string;
      Code: Integer;
      Color: TColor;
   end=(
     //�e�����
     //������������ ������ ��������
     (Name:'ENG_edIDENTIF'; Code: bChildId; Color: clDefault),
     (Name:'edFamilia'; Code: bPerson; Color: clDefault),
     (Name:'edNAME'; Code: bPerson; Color: clDefault),
     (Name:'edOTCH'; Code: bPerson; Color: clDefault),
     (Name:'edDATER'; Code: bChildId; Color: clDefault),
     (Name:'edPOL'; Code: bChildId; Color: clDefault),
     (Name:'edGRAG'; Code: bPerson; Color: clDefault),         //???
     (Name:'edRG_GOSUD'; Code: bPerson; Color: clDefault),
     (Name:'edRG_B_OBL'; Code: bPerson; Color: clDefault),
     (Name:'edRG_OBL'; Code: bPerson; Color: clDefault),
     (Name:'edRG_RAION'; Code: bPerson; Color: clDefault),
     (Name:'edRG_B_GOROD'; Code: bPerson; Color: clDefault),
     (Name:'edRG_GOROD'; Code: bPerson; Color: clDefault)
   );
var
   Akt: TfmZapisOpeka;
   PoleGrn: Integer;
   PoleGrnSub: Integer;
   I: Integer;
   Component: TComponent;
   Control: TControl;
   lDisable,l: Boolean;
begin
   Akt:=TfmZapisOpeka(Simple);
   l:=(IsEnabled and IsEnableTypeAkt(_TypeObj_Opeka,false));
   if l then begin
     PoleGrn:=GetPoleGrn(Akt.DokumentPOLE_GRN.AsInteger);
     PoleGrnSub:=GetPoleGrnSub(Akt.DokumentPOLE_GRN.AsInteger);
   end else begin
     PoleGrn:=0;
     PoleGrnSub:=0;
   end;
   {
   if PoleGrn=rPost then begin
     Akt.TbItemEmptyPrich.Enabled:=false;
   end else begin
     Akt.TbItemEmptyPrich.Enabled:=true;
   end;
   }
   //2. ������������ ����������� ��������� ��������������
   //����� ��������� ������ �� ��� �� �������� �������������� ������ ����� ����������
   for I:=Low(CComponentName) to High(CComponentName) do begin
      Component:=Akt.FindComponent(CComponentName[I].Name);
      if (Component<>nil) and (Component is TControl) then begin
         Control:=TControl(Component);
         //2.1.
         if l
           then lDisable:=((PoleGrn=2) or (PoleGrn=3)) and ((PoleGrnSub and CComponentName[I].Code)=CComponentName[I].Code)
           else lDisable:=l;

         if lDisable and (PoleGrn=3) then begin
           lDisable:=false;
         end;

         //2.2.
         if lDisable then begin
            SetEnableControl(FTypeEnableControl,Control,false);
            //Control.Enabled:=False;
            if TxControl(Control).Color<>GetDisableColorGIS then begin
               CComponentName[I].Color:=TxControl(Control).Color;
            end;
            TxControl(Control).Color:=GetDisableColorGIS;
         end else begin
            if CComponentName[I].Color<>clDefault then begin
               TxControl(Control).Color:=CComponentName[I].Color;
            end;
            SetEnableControl(FTypeEnableControl,Control,true);
            //Control.Enabled:=True;
         end;
      end
      else begin
         ShowMessageC(CComponentName[I].Name);
      end;
   end;
   // !!!!!  ���� ������ ������ ����������� ��������� ��� �������������
//   if Akt.edGRAG.Text='' then begin
//     Akt.edGRAG.Color:=GetControlColor;
//     SetEnableControl(FTypeEnableControl,Akt.edGRAG,true);
//   end;
end;

{$ENDIF}
//== end AktOpeka ����� =============================================================

//------------------------------------------------------------------
function TGisun.G_UpperCase(s:String) : String;
begin
  Result:=ANSIUpperCase(s);
end;
//------------------------------------------------------------------
function TGisun.CaseFIO(s:String) : String;
begin
 if CheckRegisterFIO then begin
   Result:=CheckRegisterText(EC_FIRST,s,false);
 end else begin
   Result:=s;
 end;
end;
//------------------------------------------------------------------
procedure TGisun.SetLoadGrag(const Value: Boolean);
begin
  FLoadGrag := Value;
end;
//------------------------------------------------------------------
procedure TGisun.SetTypeEnableControl(const Value: Integer);
begin
  FTypeEnableControl := Value;
end;

procedure TGisun.SetIsDecodePathError(const Value: Boolean);
begin
  FIsDecodePathError := Value;
end;                                                  

//procedure TGisun.SetIsActive(const Value: Boolean);
//begin
//  FIsActive := Value;
//end;
//--------------------------------------------------------------------
function TGisun.Version:Integer;
begin
  if FRegInt=nil
    then Result:=0
    else Result:=FRegInt.Version;
end;
//--------------------------------------------------------------------
function TGisun.VersionINI:Integer;
begin
  Result:=FVersionINI;
end;
//--------------------------------------------------------------------
procedure TGisun.SetIsCheckBelNazv(const Value: Boolean);
begin
  FIsCheckBelNazv := Value;
end;
//--------------------------------------------------------------------
procedure TGisun.SetIsCheckQuery(const Value: Boolean);
begin
  FIsCheckQuery := Value;
end;
//--------------------------------------------------------------------
procedure TGisun.SetOpenDefSession(const Value: Boolean);
begin
  FOpenDefSession := Value;
end;
procedure TGisun.SetAvestEnabledPIN(const Value: Boolean);
begin
  FAvestEnabledPIN:=Value;
end;
procedure TGisun.SetAvestIgnoreCOC(const Value: Boolean);
begin
  FAvestIgnoreCOC:=Value;
end;
//--------------------------------------------------------------------
procedure TGisun.SetAvestSignType(const Value: Integer);
begin
  FAvestSignType := Value;
end;
//--------------------------------------------------------------------
procedure TGisun.SetUserNameToken(sUserName:String; sPassword:String; strPIN:String);
begin
  if FPostUserName then begin
    FRegInt.Username:=sUserName;
    FRegInt.Password:=sPassword;
    FRegInt.DbUserAsGIS:=FDbUserAsGIS;
    FRegInt.PostUserName:=FPostUserName;
    Role.UserGIS:=sUserName;
  end else begin
    FRegInt.Username:='';
    FRegInt.Password:='';
    Role.UserGIS:='';
  end;
  if ActiveETSP then begin
    if strPIN<>'not_change!'
      then FRegInt.PIN:=strPIN;
  end else begin
    FRegInt.PIN:='';
  end;
end;
//--------------------------------------------------------------------
procedure TGisun.ClearPassword;
begin
  FRegInt.Password:='';
end;
//--------------------------------------------------------------------
procedure TGisun.SetDbUserAsGIS(const Value: Boolean);
begin
  FDbUserAsGIS:=Value;
end;
//--------------------------------------------------------------------
procedure TGisun.SetPostUserName(const Value: Boolean);
begin
  FPostUserName:=Value;
  SetActiveUserName_(Value)
end;
//--------------------------------------------------------------------
procedure TGisun.SetActiveETSP(const Value: Boolean);
begin
  FActiveETSP:=Value;
  SetActiveETSP_(Value);
end;
//--------------------------------------------------------------------
procedure TGisun.SetTypeETSP(const Value: Integer);
begin
  FTypeETSP:=Value;
end;
function TGisun.NameETSP:String;
begin
  if FTypeETSP=ETSP_AVEST
    then Result:='"�����"'
    else Result:='"��� ���"';
end;
//--------------------------------------------------------------------
function TGisun.IsCreateTagSign:Boolean;   // ��������� ���� <Sign> <Hash> <Key>
begin
  if FActiveETSP or FAllCreateTagSign
    then Result:=true
    else Result:=false;
end;
//--------------------------------------------------------------------
procedure TGisun.ClearETSPSession;
begin
  {$IFDEF AVEST_GISUN}
  if (TypeETSP=ETSP_AVEST) and (Avest<>nil) and (Avest.hDefSession<>nil)
    then Avest.CloseSession;
  {$ENDIF}                                       
end;
//--------------------------------------------------
// ��� ������������ ��� �������������
function TGisun.GetTypeETSP(sUserName:String):Integer;
var
  nDef:Integer;
begin
  if MySameText(sUserName,'ADSSYS') then begin
    Result:=ETSP_AVEST;
  end else begin
    {$IFDEF DEFAULT_AVEST}
      nDef:=ETSP_AVEST;
    {$ELSE}
      nDef:=ETSP_NIITZI;
    {$ENDIF}
    Result:=StrToIntDef(GetPropertyUser(sUserName, 'GISRN_ETSP', IntToStr(nDef)), nDef);
    if (Result<1) or (Result>ETSP_MAX) then begin
      Result:=nDef;
      WriteTextLog('������ ����������� ���� ��� ��� "'+sUserName+'"',LOG_GISUN);
    end;
  end;
end;
//--------------------------------------------------
// ��������� ������������ sUserName � ��� ����� � ����������� PublicKey ����������� � ������� ���� ������
function TGisun.LinkUserToETSP(sUserName:String;lQuest:Boolean):Boolean;
var
  sKey,ss:String;
  n:Integer;
  lOk:Boolean;
begin
  Result:=false;
  ss:='+';
  n:=Avest.ChoicePublicKey(sKey,ss);
  if n=0 then begin
    if lQuest
      then lOk:=Problem('��������� ������������ "'+sUserName+'" � �����������:'#13#10+ss)
      else lOk:=true;
    if lOk then begin
      SetPropertyUser(sUserName, PROP_USER_PUBKEY, sKey);
      Result:=true;
    end;
  end else begin
    PutError(Avest.ErrorInfo(n));
  end;
end;
//--------------------------------------------------
// �������� ������������ sUserName �� ��� �����
procedure TGisun.DropLinkUser(sUserName:String);
var
  sKey,ss:String;
  n:Integer;
begin
  SetPropertyUser(sUserName, PROP_USER_PUBKEY, '');
end;
//--------------------------------------------
// ������� � ��������� ���������� � ��������� base64 � ����� CA ��������� SChannel
function TGisun.SaveCertToSChannel:Boolean;
var
  sFile,sOpis,sDir,ss:String;
  n:Integer;
  lOk:Boolean;
  sCert:AnsiString;
begin
  Result:=false;
  if (Avest=nil) or not Avest.IsActive then begin
    PutError('����� �� ��������');
    exit;
  end;
  ss:=Trim(GetEnvironmentVariable('OPENSSL_ENGINES'));    // ��������� ����������
  sDir:='';
  if ss<>'' then begin
    sDir:=CheckSleshN(ss);
    if not FileExists(sDir+'SChannel.exe') then begin
      sDir:='';
    end;
  end;
  if sDir='' then begin
    PutError('�� ������� ����� ��������� ��������� SChannel');
    if SelectDirectory('����� ��� ���������� �����������', '', sDir) then begin
      sDir:=CheckSleshN(sDir);
    end else begin
      exit;
    end;
  end else begin
    sDir:=sDir+'CA\';
  end;
  n:=Avest.ChoiceCertAsString(sCert, sOpis);
  if (n=0) and (sDir<>'') then begin
    n:=Pos(',', sOpis);
    if n=0
      then sFile:='������ ����������'
      else sFile:=Trim(Copy(sOpis,1,n-1));
    if Problem('��������� ���� ����������� � �����: "'+sDir+'"') then begin
      sFile:=sDir+sFile+'.cer';
      if not FileExists(sFile) or Problem('���� "'+sFile+'" ����������. ������������?') then begin
        if MemoWrite(sFile,sCert) then begin
          Result:=true;
          ShellExecute(Application.Handle, PChar('explore'), PChar(sDir), nil, nil, SW_SHOWNORMAL);
        end else begin
          PutError('������ ������ �����: "'+sFile+'"');
        end;
      end;
    end;
  end;
end;
//-------------------------------------------------------------
// ������������� ����� CrlDPExt.txt
procedure TGisun.EditUrlCOC;
var
  n:Integer;
  ss,s,sUrl:String;
  lCreate:Boolean;
begin
  if Avest.IsActive then begin
    s:=CheckSleshN(Avest.PathDLL)+'CrlDPExt.txt';
    lCreate:=false;
    if FileExists(s) then begin
      MemoRead(s,sURL);
      DelChars(sURL, ' '+#13#10#9);
      if sUrl='' then begin
        lCreate:=true;
        ss:='���� "'+s+'" �� �������� ��������. ����������� ?';
      end;
    end else begin
      lCreate:=true;
      ss:='���� �� ������ "'+s+'" . ������� ?';
    end;
    if lCreate then begin
      n:=QuestionPos(ss, '������; nces.by ; 10.30.254.20 ;���;','',-1,-1,qtConfirmation, nil);
      case n of
        1:sUrl:=' ';
        2:sUrl:=GlobalTask.ParamAsString('URL_COC_INT');
        3:sUrl:=GlobalTask.ParamAsString('URL_COC_NCES');
      end;
      if (n>0) and (n<4) then begin
        MemoWrite(s,sUrl);
      end;
    end;
    ShellExecute(Application.Handle, nil, PChar(s), nil, nil, SW_SHOWNORMAL);
  end;
end;
//--------------------------------------------------------------------
function TGisun.SeekClassGisun(nType:Integer; sID:String):Boolean;
begin
  if dmBase.AllSprGISUN.Locate('TYPESPR;EXTCODE',VarArrayOf([nType,sID]),[])
    then Result:=true
    else Result:=false;
end;
//--------------------------------------------------------------------
function TGisun.GetValueClassGisun(sField:String):Variant;
begin
  if sField='NAME' then sField:='LEX1'
  else
  if sField='NAME_B' then sField:='LEX2'
  else
  if sField='ID' then sField:='EXTCODE'
  else
  if sField='SOATO' then sField:='LEX3';
  Result:=dmBase.AllSprGISUN.FieldByName(sField).Value;
end;


initialization
  Gisun:=nil;
finalization
  FreeAndNil(Gisun);

end.
