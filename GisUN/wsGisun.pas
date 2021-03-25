// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://127.0.0.1:8000/gisun-inf/common/ws?wsdl
//  >Import : http://127.0.0.1:8000/gisun-inf/common/ws?wsdl:0
//  >Import : http://127.0.0.1:8000/gisun-inf/common/ws?xsd=1
//  >Import : http://127.0.0.1:8000/gisun-inf/common/ws?xsd=2
//  >Import : http://127.0.0.1:8000/gisun-inf/common/ws?wsdl:1
// Encoding : UTF-8
// Version  : 1.0
// (11.01.2021 12:33:26 - - $Rev: 10138 $)
// ************************************************************************ //

unit wsGisun;   // vadim

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns, OPConvert;    // vadim

const
  IS_OPTN = $0001;
  IS_UNBD = $0002;
  IS_NLBL = $0004;
  IS_UNQL = $0008;
  IS_ATTR = $0010;
  IS_TEXT = $0020;


type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Borland types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:int             - "http://www.w3.org/2001/XMLSchema"[Lit][Gbl]
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:dateTime        - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:date            - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:base64Binary    - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:decimal         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:integer         - "http://www.w3.org/2001/XMLSchema"[Gbl]

  Classifier           = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  LangValue            = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  Document             = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  ActData              = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  birth_place          = class;                 { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  Citizenship          = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  photoInfo            = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  Nationality2         = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  Address              = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  Death                = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  deathInfo            = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  decease_place        = class;                 { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  burialData           = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  burialDataInfo       = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  guardianshipInfo     = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  trusteeshipInfo      = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  parentRightsInfo     = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  familyInfo           = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  martialStatus        = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  martialStatusInfo    = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  parentRightsData     = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  educationInfo        = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  Education            = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  ScienceRank          = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  scienceRankInfo      = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  ScienceDegree        = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  scienceDegreeInfo    = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  employmentStatusInfo = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  employmentInfo       = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  fszn                 = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  employmentPeriod     = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  CourtList            = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  courtDeathInfo       = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  courtDecision        = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  CourtDeathData       = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  CourtAbsentData      = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  courtAbsentInfo      = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  CourtUnefficientData = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  courtUnefficientInfo = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  CourtRestrictEfficientData = class;           { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  courtRestrictEfficientInfo = class;           { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  unemploymentData     = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  unemploymentInfo     = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  Pension              = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  pensionInfo          = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  salaryData           = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  salaryInfo           = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  Insurance            = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  insuranceInfo        = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  Tax                  = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  taxInfo              = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  Military             = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  militaryInfo         = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  Disability           = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  disabilityInfo       = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  MessageCover         = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  QueryParam           = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  personalDataInfo     = class;                 { "http://gisun.agatsystem.by/common/ws/"[GblCplx] }
  LexemStatus          = class;                 { "http://gisun.agatsystem.by/common/ws/"[GblCplx] }
  RegisterResponse     = class;                 { "http://gisun.agatsystem.by/common/ws/"[Lit][GblCplx] }
  ResponsePerson       = class;                 { "http://gisun.agatsystem.by/common/ws/"[GblCplx] }
  ResponseIdentif      = class;                 { "http://gisun.agatsystem.by/common/ws/"[GblCplx] }
  WsError              = class;                 { "http://gisun.agatsystem.by/common/ws/"[GblCplx] }
  WsException          = class;                 { "http://gisun.agatsystem.by/common/ws/"[Flt][GblCplx] }
  RegisterPersonListRequest = class;            { "http://gisun.agatsystem.by/common/ws/"[Lit][GblCplx] }
  PersonListRequest    = class;                 { "http://gisun.agatsystem.by/common/ws/"[GblCplx] }
  RegisterRequest      = class;                 { "http://gisun.agatsystem.by/common/ws/"[Lit][GblCplx] }
  PersonRequest        = class;                 { "http://gisun.agatsystem.by/common/ws/"[GblCplx] }
  IdentifRequest       = class;                 { "http://gisun.agatsystem.by/common/ws/"[GblCplx] }
  ClassifierChangeRequest = class;              { "http://gisun.agatsystem.by/common/ws/"[Lit][GblCplx] }
  RegisterPersonIdentifRequest = class;         { "http://gisun.agatsystem.by/common/ws/"[Lit][GblCplx] }
  PersonIdentifRequest = class;                 { "http://gisun.agatsystem.by/common/ws/"[GblCplx] }
  classifier_change_request = class;            { "http://gisun.agatsystem.by/common/ws/"[GblElm] }
  exception            = class;                 { "http://gisun.agatsystem.by/common/ws/"[Flt][GblElm] }
  getClassifierChange  = class;                 { "http://gisun.agatsystem.by/common/ws/"[Lit][GblElm] }
  register_person_identif_request = class;      { "http://gisun.agatsystem.by/common/ws/"[Lit][GblElm] }
  register_person_list_request = class;         { "http://gisun.agatsystem.by/common/ws/"[Lit][GblElm] }
  register_request     = class;                 { "http://gisun.agatsystem.by/common/ws/"[Lit][GblElm] }
  register_response    = class;                 { "http://gisun.agatsystem.by/common/ws/"[Lit][GblElm] }
  value                = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  classifier2          = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  nationality_info     = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  temp_address         = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  death2               = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  burial_info          = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  guardianship_info    = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  trusteeship_info     = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  educations_info      = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  science_ranks_info   = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  science_degrees_info = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  employment_info      = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  pensions_info        = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  insurances_info      = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  taxies_info          = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  militaries_info      = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  disability_info      = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  document2            = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  prnt_rights_data     = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  employment_period    = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  death_info           = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  absent_info          = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  unefficient_info     = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  restrict_efficient_info = class;              { "http://gisun.agatsystem.by/common/types/"[Alias] }
  param                = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  personal_data_info   = class;                 { "http://gisun.agatsystem.by/common/ws/"[Alias] }
  address2             = class;                 { "http://gisun.agatsystem.by/common/ws/"[Alias] }
  error                = class;                 { "http://gisun.agatsystem.by/common/ws/"[Alias] }
  lexemStatus2         = class;                 { "http://gisun.agatsystem.by/common/ws/"[Alias] }
  History              = class;                 { "http://gisun.agatsystem.by/common/ws/"[GblCplx] }
  PersonalData         = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  personalData2        = class;                 { "http://gisun.agatsystem.by/common/types/"[GblElm] }
  FamilyDataHistory    = class;                 { "http://gisun.agatsystem.by/common/ws/"[GblCplx] }
  FamilyData           = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  ResponseData         = class;                 { "http://gisun.agatsystem.by/common/ws/"[GblCplx] }
  RequestData          = class;                 { "http://gisun.agatsystem.by/common/ws/"[GblCplx] }

  LangValueList = array of value;               { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  ClassifierList = array of classifier2;        { "http://gisun.agatsystem.by/common/types/"[Lit][GblCplx] }


  // ************************************************************************ //
  // XML       : Classifier, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  Classifier = class(TRemotable)
  private
    Fcode: WideString;
    Fcode_Specified: boolean;
    Ftype_: Integer;
    Ftype__Specified: boolean;
    Flexema: LangValueList;
    Flexema_Specified: boolean;
    Factive: Boolean;
    Factive_Specified: boolean;
    Fbegin_date: TXSDateTime;
    Fbegin_date_Specified: boolean;
    Fend_date: TXSDateTime;
    Fend_date_Specified: boolean;
    Fparents: ClassifierList;
    Fparents_Specified: boolean;
    procedure Setcode(Index: Integer; const AWideString: WideString);
    function  code_Specified(Index: Integer): boolean;
    procedure Settype_(Index: Integer; const AInteger: Integer);
    function  type__Specified(Index: Integer): boolean;
    procedure Setlexema(Index: Integer; const ALangValueList: LangValueList);
    function  lexema_Specified(Index: Integer): boolean;
    procedure Setactive(Index: Integer; const ABoolean: Boolean);
    function  active_Specified(Index: Integer): boolean;
    procedure Setbegin_date(Index: Integer; const ATXSDateTime: TXSDateTime);
    function  begin_date_Specified(Index: Integer): boolean;
    procedure Setend_date(Index: Integer; const ATXSDateTime: TXSDateTime);
    function  end_date_Specified(Index: Integer): boolean;
    procedure Setparents(Index: Integer; const AClassifierList: ClassifierList);
    function  parents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property code:       WideString      Index (IS_OPTN) read Fcode write Setcode stored code_Specified;
    property type_:      Integer         Index (IS_OPTN) read Ftype_ write Settype_ stored type__Specified;
    property lexema:     LangValueList   Index (IS_OPTN) read Flexema write Setlexema stored lexema_Specified;
    property active:     Boolean         Index (IS_OPTN) read Factive write Setactive stored active_Specified;
    property begin_date: TXSDateTime     Index (IS_OPTN) read Fbegin_date write Setbegin_date stored begin_date_Specified;
    property end_date:   TXSDateTime     Index (IS_OPTN) read Fend_date write Setend_date stored end_date_Specified;
    property parents:    ClassifierList  Index (IS_OPTN) read Fparents write Setparents stored parents_Specified;
  end;



  // ************************************************************************ //
  // XML       : LangValue, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  LangValue = class(TRemotable)
  private
    FText: WideString;
    Flang: WideString;
  published
    property Text: WideString  Index (IS_TEXT) read FText write FText;
    property lang: WideString  Index (IS_ATTR) read Flang write Flang;
  end;



  // ************************************************************************ //
  // XML       : Document, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  Document = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Fdocument_type: Classifier;
    Fdocument_type_Specified: boolean;
    Fauthority: Classifier;
    Fauthority_Specified: boolean;
    Fdate_of_issue: TXSDate;
    Fdate_of_issue_Specified: boolean;
    Fexpire_date: TXSDate;
    Fexpire_date_Specified: boolean;
    Fseries: WideString;
    Fseries_Specified: boolean;
    Fnumber: WideString;
    Fnumber_Specified: boolean;
    Fact_data: ActData;
    Fact_data_Specified: boolean;
    Factive: Boolean;
    Factive_Specified: boolean;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Setdocument_type(Index: Integer; const AClassifier: Classifier);
    function  document_type_Specified(Index: Integer): boolean;
    procedure Setauthority(Index: Integer; const AClassifier: Classifier);
    function  authority_Specified(Index: Integer): boolean;
    procedure Setdate_of_issue(Index: Integer; const ATXSDate: TXSDate);
    function  date_of_issue_Specified(Index: Integer): boolean;
    procedure Setexpire_date(Index: Integer; const ATXSDate: TXSDate);
    function  expire_date_Specified(Index: Integer): boolean;
    procedure Setseries(Index: Integer; const AWideString: WideString);
    function  series_Specified(Index: Integer): boolean;
    procedure Setnumber(Index: Integer; const AWideString: WideString);
    function  number_Specified(Index: Integer): boolean;
    procedure Setact_data(Index: Integer; const AActData: ActData);
    function  act_data_Specified(Index: Integer): boolean;
    procedure Setactive(Index: Integer; const ABoolean: Boolean);
    function  active_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:        Classifier  Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property document_type: Classifier  Index (IS_OPTN) read Fdocument_type write Setdocument_type stored document_type_Specified;
    property authority:     Classifier  Index (IS_OPTN) read Fauthority write Setauthority stored authority_Specified;
    property date_of_issue: TXSDate     Index (IS_OPTN) read Fdate_of_issue write Setdate_of_issue stored date_of_issue_Specified;
    property expire_date:   TXSDate     Index (IS_OPTN) read Fexpire_date write Setexpire_date stored expire_date_Specified;
    property series:        WideString  Index (IS_OPTN) read Fseries write Setseries stored series_Specified;
    property number:        WideString  Index (IS_OPTN) read Fnumber write Setnumber stored number_Specified;
    property act_data:      ActData     Index (IS_OPTN) read Fact_data write Setact_data stored act_data_Specified;
    property active:        Boolean     Index (IS_OPTN) read Factive write Setactive stored active_Specified;
  end;



  // ************************************************************************ //
  // XML       : ActData, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  ActData = class(TRemotable)
  private
    Fact_type: Classifier;
    Fact_type_Specified: boolean;
    Fauthority: Classifier;
    Fauthority_Specified: boolean;
    Fdate: TXSDate;
    Fdate_Specified: boolean;
    Fnumber: WideString;
    Fnumber_Specified: boolean;
    procedure Setact_type(Index: Integer; const AClassifier: Classifier);
    function  act_type_Specified(Index: Integer): boolean;
    procedure Setauthority(Index: Integer; const AClassifier: Classifier);
    function  authority_Specified(Index: Integer): boolean;
    procedure Setdate(Index: Integer; const ATXSDate: TXSDate);
    function  date_Specified(Index: Integer): boolean;
    procedure Setnumber(Index: Integer; const AWideString: WideString);
    function  number_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property act_type:  Classifier  Index (IS_OPTN) read Fact_type write Setact_type stored act_type_Specified;
    property authority: Classifier  Index (IS_OPTN) read Fauthority write Setauthority stored authority_Specified;
    property date:      TXSDate     Index (IS_OPTN) read Fdate write Setdate stored date_Specified;
    property number:    WideString  Index (IS_OPTN) read Fnumber write Setnumber stored number_Specified;
  end;



  // ************************************************************************ //
  // XML       : birth_place, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  birth_place = class(TRemotable)
  private
    Fcountry_b: Classifier;
    Fcountry_b_Specified: boolean;
    Farea_b: WideString;
    Farea_b_Specified: boolean;
    Farea_b_bel: WideString;
    Farea_b_bel_Specified: boolean;
    Fregion_b: WideString;
    Fregion_b_Specified: boolean;
    Fregion_b_bel: WideString;
    Fregion_b_bel_Specified: boolean;
    Ftype_city_b: Classifier;
    Ftype_city_b_Specified: boolean;
    Fcity_b: WideString;
    Fcity_b_Specified: boolean;
    Fcity_b_bel: WideString;
    Fcity_b_bel_Specified: boolean;
    Fcity_b_ate: Classifier;
    Fcity_b_ate_Specified: boolean;
    procedure Setcountry_b(Index: Integer; const AClassifier: Classifier);
    function  country_b_Specified(Index: Integer): boolean;
    procedure Setarea_b(Index: Integer; const AWideString: WideString);
    function  area_b_Specified(Index: Integer): boolean;
    procedure Setarea_b_bel(Index: Integer; const AWideString: WideString);
    function  area_b_bel_Specified(Index: Integer): boolean;
    procedure Setregion_b(Index: Integer; const AWideString: WideString);
    function  region_b_Specified(Index: Integer): boolean;
    procedure Setregion_b_bel(Index: Integer; const AWideString: WideString);
    function  region_b_bel_Specified(Index: Integer): boolean;
    procedure Settype_city_b(Index: Integer; const AClassifier: Classifier);
    function  type_city_b_Specified(Index: Integer): boolean;
    procedure Setcity_b(Index: Integer; const AWideString: WideString);
    function  city_b_Specified(Index: Integer): boolean;
    procedure Setcity_b_bel(Index: Integer; const AWideString: WideString);
    function  city_b_bel_Specified(Index: Integer): boolean;
    procedure Setcity_b_ate(Index: Integer; const AClassifier: Classifier);
    function  city_b_ate_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property country_b:    Classifier  Index (IS_OPTN) read Fcountry_b write Setcountry_b stored country_b_Specified;
    property area_b:       WideString  Index (IS_OPTN) read Farea_b write Setarea_b stored area_b_Specified;
    property area_b_bel:   WideString  Index (IS_OPTN) read Farea_b_bel write Setarea_b_bel stored area_b_bel_Specified;
    property region_b:     WideString  Index (IS_OPTN) read Fregion_b write Setregion_b stored region_b_Specified;
    property region_b_bel: WideString  Index (IS_OPTN) read Fregion_b_bel write Setregion_b_bel stored region_b_bel_Specified;
    property type_city_b:  Classifier  Index (IS_OPTN) read Ftype_city_b write Settype_city_b stored type_city_b_Specified;
    property city_b:       WideString  Index (IS_OPTN) read Fcity_b write Setcity_b stored city_b_Specified;
    property city_b_bel:   WideString  Index (IS_OPTN) read Fcity_b_bel write Setcity_b_bel stored city_b_bel_Specified;
    property city_b_ate:   Classifier  Index (IS_OPTN) read Fcity_b_ate write Setcity_b_ate stored city_b_ate_Specified;
  end;



  // ************************************************************************ //
  // XML       : Citizenship, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  Citizenship = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Fcitizenship_change: Classifier;
    Fcitizenship_change_Specified: boolean;
    Fcitizenship_type: Classifier;
    Fcitizenship_type_Specified: boolean;
    Fdate_citizenship: TXSDateTime;
    Fdate_citizenship_Specified: boolean;
    Factive: Boolean;
    Factive_Specified: boolean;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Setcitizenship_change(Index: Integer; const AClassifier: Classifier);
    function  citizenship_change_Specified(Index: Integer): boolean;
    procedure Setcitizenship_type(Index: Integer; const AClassifier: Classifier);
    function  citizenship_type_Specified(Index: Integer): boolean;
    procedure Setdate_citizenship(Index: Integer; const ATXSDateTime: TXSDateTime);
    function  date_citizenship_Specified(Index: Integer): boolean;
    procedure Setactive(Index: Integer; const ABoolean: Boolean);
    function  active_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:             Classifier   Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property citizenship_change: Classifier   Index (IS_OPTN) read Fcitizenship_change write Setcitizenship_change stored citizenship_change_Specified;
    property citizenship_type:   Classifier   Index (IS_OPTN) read Fcitizenship_type write Setcitizenship_type stored citizenship_type_Specified;
    property date_citizenship:   TXSDateTime  Index (IS_OPTN) read Fdate_citizenship write Setdate_citizenship stored date_citizenship_Specified;
    property active:             Boolean      Index (IS_OPTN) read Factive write Setactive stored active_Specified;
  end;

  nationality = array of nationality_info;      { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  temp_addresses = array of temp_address;       { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  deaths     = array of death2;                 { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  burials    = array of burial_info;            { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  guardianships = array of guardianship_info;   { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  trusteeships = array of trusteeship_info;     { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  educations = array of educations_info;        { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  scienceRanks = array of science_ranks_info;   { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  scienceDegrees = array of science_degrees_info;   { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  employments = array of employment_info;       { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  pensions   = array of pensions_info;          { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  insurances = array of insurances_info;        { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  taxies     = array of taxies_info;            { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  militaries = array of militaries_info;        { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  disabilities = array of disability_info;      { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  documents  = array of document2;              { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : photoInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  photoInfo = class(TRemotable)
  private
    Fphoto: TByteDynArray;
    Fphoto_Specified: boolean;
    Fdocuments: documents;
    Fdocuments_Specified: boolean;
    procedure Setphoto(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  photo_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments: documents);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property photo:     TByteDynArray  Index (IS_OPTN) read Fphoto write Setphoto stored photo_Specified;
    property documents: documents      Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;

  documents2 = array of document2;              { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : Nationality, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  Nationality2 = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Fnationality: Classifier;
    Fnationality_Specified: boolean;
    Fdocuments: documents2;
    Fdocuments_Specified: boolean;
    Factive: Boolean;
    Factive_Specified: boolean;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Setnationality(Index: Integer; const AClassifier: Classifier);
    function  nationality_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments2: documents2);
    function  documents_Specified(Index: Integer): boolean;
    procedure Setactive(Index: Integer; const ABoolean: Boolean);
    function  active_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:      Classifier  Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property nationality: Classifier  Index (IS_OPTN) read Fnationality write Setnationality stored nationality_Specified;
    property documents:   documents2  Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
    property active:      Boolean     Index (IS_OPTN) read Factive write Setactive stored active_Specified;
  end;



  // ************************************************************************ //
  // XML       : Address, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  Address = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Fcountry: Classifier;
    Fcountry_Specified: boolean;
    Farea: Classifier;
    Farea_Specified: boolean;
    Fregion: Classifier;
    Fregion_Specified: boolean;
    Fsoviet: Classifier;
    Fsoviet_Specified: boolean;
    Flocality_type: Classifier;
    Flocality_type_Specified: boolean;
    Flocality: Classifier;
    Flocality_Specified: boolean;
    Fcity_region: Classifier;
    Fcity_region_Specified: boolean;
    Fstreet_type: Classifier;
    Fstreet_type_Specified: boolean;
    Fstreet: Classifier;
    Fstreet_Specified: boolean;
    Fhouse: WideString;
    Fhouse_Specified: boolean;
    Fbuilding: WideString;
    Fbuilding_Specified: boolean;
    Fflat: WideString;
    Fflat_Specified: boolean;
    Freg_date: TXSDate;
    Freg_date_Specified: boolean;
    Freg_date_till: TXSDate;
    Freg_date_till_Specified: boolean;
    Fsign_away: Boolean;
    Fsign_away_Specified: boolean;
    FaddrNum: TXSDecimal;
    FaddrNum_Specified: boolean;
    FateAddress: WideString;
    FateAddress_Specified: boolean;
    Factive: Boolean;
    Factive_Specified: boolean;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Setcountry(Index: Integer; const AClassifier: Classifier);
    function  country_Specified(Index: Integer): boolean;
    procedure Setarea(Index: Integer; const AClassifier: Classifier);
    function  area_Specified(Index: Integer): boolean;
    procedure Setregion(Index: Integer; const AClassifier: Classifier);
    function  region_Specified(Index: Integer): boolean;
    procedure Setsoviet(Index: Integer; const AClassifier: Classifier);
    function  soviet_Specified(Index: Integer): boolean;
    procedure Setlocality_type(Index: Integer; const AClassifier: Classifier);
    function  locality_type_Specified(Index: Integer): boolean;
    procedure Setlocality(Index: Integer; const AClassifier: Classifier);
    function  locality_Specified(Index: Integer): boolean;
    procedure Setcity_region(Index: Integer; const AClassifier: Classifier);
    function  city_region_Specified(Index: Integer): boolean;
    procedure Setstreet_type(Index: Integer; const AClassifier: Classifier);
    function  street_type_Specified(Index: Integer): boolean;
    procedure Setstreet(Index: Integer; const AClassifier: Classifier);
    function  street_Specified(Index: Integer): boolean;
    procedure Sethouse(Index: Integer; const AWideString: WideString);
    function  house_Specified(Index: Integer): boolean;
    procedure Setbuilding(Index: Integer; const AWideString: WideString);
    function  building_Specified(Index: Integer): boolean;
    procedure Setflat(Index: Integer; const AWideString: WideString);
    function  flat_Specified(Index: Integer): boolean;
    procedure Setreg_date(Index: Integer; const ATXSDate: TXSDate);
    function  reg_date_Specified(Index: Integer): boolean;
    procedure Setreg_date_till(Index: Integer; const ATXSDate: TXSDate);
    function  reg_date_till_Specified(Index: Integer): boolean;
    procedure Setsign_away(Index: Integer; const ABoolean: Boolean);
    function  sign_away_Specified(Index: Integer): boolean;
    procedure SetaddrNum(Index: Integer; const ATXSDecimal: TXSDecimal);
    function  addrNum_Specified(Index: Integer): boolean;
    procedure SetateAddress(Index: Integer; const AWideString: WideString);
    function  ateAddress_Specified(Index: Integer): boolean;
    procedure Setactive(Index: Integer; const ABoolean: Boolean);
    function  active_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:        Classifier  Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property country:       Classifier  Index (IS_OPTN) read Fcountry write Setcountry stored country_Specified;
    property area:          Classifier  Index (IS_OPTN) read Farea write Setarea stored area_Specified;
    property region:        Classifier  Index (IS_OPTN) read Fregion write Setregion stored region_Specified;
    property soviet:        Classifier  Index (IS_OPTN) read Fsoviet write Setsoviet stored soviet_Specified;
    property locality_type: Classifier  Index (IS_OPTN) read Flocality_type write Setlocality_type stored locality_type_Specified;
    property locality:      Classifier  Index (IS_OPTN) read Flocality write Setlocality stored locality_Specified;
    property city_region:   Classifier  Index (IS_OPTN) read Fcity_region write Setcity_region stored city_region_Specified;
    property street_type:   Classifier  Index (IS_OPTN) read Fstreet_type write Setstreet_type stored street_type_Specified;
    property street:        Classifier  Index (IS_OPTN) read Fstreet write Setstreet stored street_Specified;
    property house:         WideString  Index (IS_OPTN) read Fhouse write Sethouse stored house_Specified;
    property building:      WideString  Index (IS_OPTN) read Fbuilding write Setbuilding stored building_Specified;
    property flat:          WideString  Index (IS_OPTN) read Fflat write Setflat stored flat_Specified;
    property reg_date:      TXSDate     Index (IS_OPTN) read Freg_date write Setreg_date stored reg_date_Specified;
    property reg_date_till: TXSDate     Index (IS_OPTN) read Freg_date_till write Setreg_date_till stored reg_date_till_Specified;
    property sign_away:     Boolean     Index (IS_OPTN) read Fsign_away write Setsign_away stored sign_away_Specified;
    property addrNum:       TXSDecimal  Index (IS_OPTN) read FaddrNum write SetaddrNum stored addrNum_Specified;
    property ateAddress:    WideString  Index (IS_OPTN) read FateAddress write SetateAddress stored ateAddress_Specified;
    property active:        Boolean     Index (IS_OPTN) read Factive write Setactive stored active_Specified;
  end;



  // ************************************************************************ //
  // XML       : Death, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  Death = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Fdeath_cause: Classifier;
    Fdeath_cause_Specified: boolean;
    Fdeath_date: WideString;
    Fdeath_date_Specified: boolean;
    Fdecease_place: decease_place;
    Fdecease_place_Specified: boolean;
    Fdeath_place: WideString;
    Fdeath_place_Specified: boolean;
    Fburial_place: WideString;
    Fburial_place_Specified: boolean;
    Factive: Boolean;
    Factive_Specified: boolean;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Setdeath_cause(Index: Integer; const AClassifier: Classifier);
    function  death_cause_Specified(Index: Integer): boolean;
    procedure Setdeath_date(Index: Integer; const AWideString: WideString);
    function  death_date_Specified(Index: Integer): boolean;
    procedure Setdecease_place(Index: Integer; const Adecease_place: decease_place);
    function  decease_place_Specified(Index: Integer): boolean;
    procedure Setdeath_place(Index: Integer; const AWideString: WideString);
    function  death_place_Specified(Index: Integer): boolean;
    procedure Setburial_place(Index: Integer; const AWideString: WideString);
    function  burial_place_Specified(Index: Integer): boolean;
    procedure Setactive(Index: Integer; const ABoolean: Boolean);
    function  active_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:        Classifier     Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property death_cause:   Classifier     Index (IS_OPTN) read Fdeath_cause write Setdeath_cause stored death_cause_Specified;
    property death_date:    WideString     Index (IS_OPTN) read Fdeath_date write Setdeath_date stored death_date_Specified;
    property decease_place: decease_place  Index (IS_OPTN) read Fdecease_place write Setdecease_place stored decease_place_Specified;
    property death_place:   WideString     Index (IS_OPTN) read Fdeath_place write Setdeath_place stored death_place_Specified;
    property burial_place:  WideString     Index (IS_OPTN) read Fburial_place write Setburial_place stored burial_place_Specified;
    property active:        Boolean        Index (IS_OPTN) read Factive write Setactive stored active_Specified;
  end;

  documents3 = array of document2;              { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : deathInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  deathInfo = class(TRemotable)
  private
    Fdeath_data: Death;
    Fdeath_data_Specified: boolean;
    Fdocuments: documents3;
    Fdocuments_Specified: boolean;
    procedure Setdeath_data(Index: Integer; const ADeath: Death);
    function  death_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments3: documents3);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property death_data: Death       Index (IS_OPTN) read Fdeath_data write Setdeath_data stored death_data_Specified;
    property documents:  documents3  Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;



  // ************************************************************************ //
  // XML       : decease_place, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  decease_place = class(TRemotable)
  private
    Fcountry_d: Classifier;
    Fcountry_d_Specified: boolean;
    Farea_d: WideString;
    Farea_d_Specified: boolean;
    Farea_d_bel: WideString;
    Farea_d_bel_Specified: boolean;
    Fregion_d: WideString;
    Fregion_d_Specified: boolean;
    Fregion_d_bel: WideString;
    Fregion_d_bel_Specified: boolean;
    Ftype_city_d: Classifier;
    Ftype_city_d_Specified: boolean;
    Fcity_d: WideString;
    Fcity_d_Specified: boolean;
    Fcity_d_bel: WideString;
    Fcity_d_bel_Specified: boolean;
    procedure Setcountry_d(Index: Integer; const AClassifier: Classifier);
    function  country_d_Specified(Index: Integer): boolean;
    procedure Setarea_d(Index: Integer; const AWideString: WideString);
    function  area_d_Specified(Index: Integer): boolean;
    procedure Setarea_d_bel(Index: Integer; const AWideString: WideString);
    function  area_d_bel_Specified(Index: Integer): boolean;
    procedure Setregion_d(Index: Integer; const AWideString: WideString);
    function  region_d_Specified(Index: Integer): boolean;
    procedure Setregion_d_bel(Index: Integer; const AWideString: WideString);
    function  region_d_bel_Specified(Index: Integer): boolean;
    procedure Settype_city_d(Index: Integer; const AClassifier: Classifier);
    function  type_city_d_Specified(Index: Integer): boolean;
    procedure Setcity_d(Index: Integer; const AWideString: WideString);
    function  city_d_Specified(Index: Integer): boolean;
    procedure Setcity_d_bel(Index: Integer; const AWideString: WideString);
    function  city_d_bel_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property country_d:    Classifier  Index (IS_OPTN) read Fcountry_d write Setcountry_d stored country_d_Specified;
    property area_d:       WideString  Index (IS_OPTN) read Farea_d write Setarea_d stored area_d_Specified;
    property area_d_bel:   WideString  Index (IS_OPTN) read Farea_d_bel write Setarea_d_bel stored area_d_bel_Specified;
    property region_d:     WideString  Index (IS_OPTN) read Fregion_d write Setregion_d stored region_d_Specified;
    property region_d_bel: WideString  Index (IS_OPTN) read Fregion_d_bel write Setregion_d_bel stored region_d_bel_Specified;
    property type_city_d:  Classifier  Index (IS_OPTN) read Ftype_city_d write Settype_city_d stored type_city_d_Specified;
    property city_d:       WideString  Index (IS_OPTN) read Fcity_d write Setcity_d stored city_d_Specified;
    property city_d_bel:   WideString  Index (IS_OPTN) read Fcity_d_bel write Setcity_d_bel stored city_d_bel_Specified;
  end;



  // ************************************************************************ //
  // XML       : burialData, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  burialData = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Fcountry: Classifier;
    Fcountry_Specified: boolean;
    Farea: Classifier;
    Farea_Specified: boolean;
    Fregion: Classifier;
    Fregion_Specified: boolean;
    Fsoviet: Classifier;
    Fsoviet_Specified: boolean;
    Fcity: Classifier;
    Fcity_Specified: boolean;
    Fburial_name: Classifier;
    Fburial_name_Specified: boolean;
    Fsector: WideString;
    Fsector_Specified: boolean;
    Frow: WideString;
    Frow_Specified: boolean;
    Fplace: WideString;
    Fplace_Specified: boolean;
    Fgrave: WideString;
    Fgrave_Specified: boolean;
    Fvault: WideString;
    Fvault_Specified: boolean;
    Fwall_section: WideString;
    Fwall_section_Specified: boolean;
    Fwall_box: WideString;
    Fwall_box_Specified: boolean;
    Factive: Integer;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Setcountry(Index: Integer; const AClassifier: Classifier);
    function  country_Specified(Index: Integer): boolean;
    procedure Setarea(Index: Integer; const AClassifier: Classifier);
    function  area_Specified(Index: Integer): boolean;
    procedure Setregion(Index: Integer; const AClassifier: Classifier);
    function  region_Specified(Index: Integer): boolean;
    procedure Setsoviet(Index: Integer; const AClassifier: Classifier);
    function  soviet_Specified(Index: Integer): boolean;
    procedure Setcity(Index: Integer; const AClassifier: Classifier);
    function  city_Specified(Index: Integer): boolean;
    procedure Setburial_name(Index: Integer; const AClassifier: Classifier);
    function  burial_name_Specified(Index: Integer): boolean;
    procedure Setsector(Index: Integer; const AWideString: WideString);
    function  sector_Specified(Index: Integer): boolean;
    procedure Setrow(Index: Integer; const AWideString: WideString);
    function  row_Specified(Index: Integer): boolean;
    procedure Setplace(Index: Integer; const AWideString: WideString);
    function  place_Specified(Index: Integer): boolean;
    procedure Setgrave(Index: Integer; const AWideString: WideString);
    function  grave_Specified(Index: Integer): boolean;
    procedure Setvault(Index: Integer; const AWideString: WideString);
    function  vault_Specified(Index: Integer): boolean;
    procedure Setwall_section(Index: Integer; const AWideString: WideString);
    function  wall_section_Specified(Index: Integer): boolean;
    procedure Setwall_box(Index: Integer; const AWideString: WideString);
    function  wall_box_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:       Classifier  Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property country:      Classifier  Index (IS_OPTN) read Fcountry write Setcountry stored country_Specified;
    property area:         Classifier  Index (IS_OPTN) read Farea write Setarea stored area_Specified;
    property region:       Classifier  Index (IS_OPTN) read Fregion write Setregion stored region_Specified;
    property soviet:       Classifier  Index (IS_OPTN) read Fsoviet write Setsoviet stored soviet_Specified;
    property city:         Classifier  Index (IS_OPTN) read Fcity write Setcity stored city_Specified;
    property burial_name:  Classifier  Index (IS_OPTN) read Fburial_name write Setburial_name stored burial_name_Specified;
    property sector:       WideString  Index (IS_OPTN) read Fsector write Setsector stored sector_Specified;
    property row:          WideString  Index (IS_OPTN) read Frow write Setrow stored row_Specified;
    property place:        WideString  Index (IS_OPTN) read Fplace write Setplace stored place_Specified;
    property grave:        WideString  Index (IS_OPTN) read Fgrave write Setgrave stored grave_Specified;
    property vault:        WideString  Index (IS_OPTN) read Fvault write Setvault stored vault_Specified;
    property wall_section: WideString  Index (IS_OPTN) read Fwall_section write Setwall_section stored wall_section_Specified;
    property wall_box:     WideString  Index (IS_OPTN) read Fwall_box write Setwall_box stored wall_box_Specified;
    property active:       Integer     read Factive write Factive;
  end;

  documents4 = array of document2;              { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : burialDataInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  burialDataInfo = class(TRemotable)
  private
    Fburial_data: burialData;
    Fburial_data_Specified: boolean;
    Fdocuments: documents4;
    Fdocuments_Specified: boolean;
    procedure Setburial_data(Index: Integer; const AburialData: burialData);
    function  burial_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments4: documents4);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property burial_data: burialData  Index (IS_OPTN) read Fburial_data write Setburial_data stored burial_data_Specified;
    property documents:   documents4  Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;

  documents5 = array of document2;              { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : guardianshipInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  guardianshipInfo = class(TRemotable)
  private
    Fguardian: PersonalData;
    Fguardian_Specified: boolean;
    Festablish_guardianship_date: TXSDate;
    Festablish_guardianship_date_Specified: boolean;
    Ftermination_guardianship_date: TXSDate;
    Ftermination_guardianship_date_Specified: boolean;
    Fremove_guardian_date: TXSDate;
    Fremove_guardian_date_Specified: boolean;
    Frelease_guardian_date: TXSDate;
    Frelease_guardian_date_Specified: boolean;
    Fdocuments: documents5;
    Fdocuments_Specified: boolean;
    procedure Setguardian(Index: Integer; const APersonalData: PersonalData);
    function  guardian_Specified(Index: Integer): boolean;
    procedure Setestablish_guardianship_date(Index: Integer; const ATXSDate: TXSDate);
    function  establish_guardianship_date_Specified(Index: Integer): boolean;
    procedure Settermination_guardianship_date(Index: Integer; const ATXSDate: TXSDate);
    function  termination_guardianship_date_Specified(Index: Integer): boolean;
    procedure Setremove_guardian_date(Index: Integer; const ATXSDate: TXSDate);
    function  remove_guardian_date_Specified(Index: Integer): boolean;
    procedure Setrelease_guardian_date(Index: Integer; const ATXSDate: TXSDate);
    function  release_guardian_date_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments5: documents5);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property guardian:                      PersonalData  Index (IS_OPTN) read Fguardian write Setguardian stored guardian_Specified;
    property establish_guardianship_date:   TXSDate       Index (IS_OPTN) read Festablish_guardianship_date write Setestablish_guardianship_date stored establish_guardianship_date_Specified;
    property termination_guardianship_date: TXSDate       Index (IS_OPTN) read Ftermination_guardianship_date write Settermination_guardianship_date stored termination_guardianship_date_Specified;
    property remove_guardian_date:          TXSDate       Index (IS_OPTN) read Fremove_guardian_date write Setremove_guardian_date stored remove_guardian_date_Specified;
    property release_guardian_date:         TXSDate       Index (IS_OPTN) read Frelease_guardian_date write Setrelease_guardian_date stored release_guardian_date_Specified;
    property documents:                     documents5    Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;

  documents6 = array of document2;              { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : trusteeshipInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  trusteeshipInfo = class(TRemotable)
  private
    Ftrustee: PersonalData;
    Ftrustee_Specified: boolean;
    Festablish_trusteeship_date: TXSDate;
    Festablish_trusteeship_date_Specified: boolean;
    Ftermination_trusteeship_date: TXSDate;
    Ftermination_trusteeship_date_Specified: boolean;
    Fremove_trustee_date: TXSDate;
    Fremove_trustee_date_Specified: boolean;
    Frelease_trustee_date: TXSDate;
    Frelease_trustee_date_Specified: boolean;
    Fdocuments: documents6;
    Fdocuments_Specified: boolean;
    procedure Settrustee(Index: Integer; const APersonalData: PersonalData);
    function  trustee_Specified(Index: Integer): boolean;
    procedure Setestablish_trusteeship_date(Index: Integer; const ATXSDate: TXSDate);
    function  establish_trusteeship_date_Specified(Index: Integer): boolean;
    procedure Settermination_trusteeship_date(Index: Integer; const ATXSDate: TXSDate);
    function  termination_trusteeship_date_Specified(Index: Integer): boolean;
    procedure Setremove_trustee_date(Index: Integer; const ATXSDate: TXSDate);
    function  remove_trustee_date_Specified(Index: Integer): boolean;
    procedure Setrelease_trustee_date(Index: Integer; const ATXSDate: TXSDate);
    function  release_trustee_date_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments6: documents6);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property trustee:                      PersonalData  Index (IS_OPTN) read Ftrustee write Settrustee stored trustee_Specified;
    property establish_trusteeship_date:   TXSDate       Index (IS_OPTN) read Festablish_trusteeship_date write Setestablish_trusteeship_date stored establish_trusteeship_date_Specified;
    property termination_trusteeship_date: TXSDate       Index (IS_OPTN) read Ftermination_trusteeship_date write Settermination_trusteeship_date stored termination_trusteeship_date_Specified;
    property remove_trustee_date:          TXSDate       Index (IS_OPTN) read Fremove_trustee_date write Setremove_trustee_date stored remove_trustee_date_Specified;
    property release_trustee_date:         TXSDate       Index (IS_OPTN) read Frelease_trustee_date write Setrelease_trustee_date stored release_trustee_date_Specified;
    property documents:                    documents6    Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;

  prnt_rights = array of prnt_rights_data;      { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : parentRightsInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  parentRightsInfo = class(TRemotable)
  private
    Fdeprivation_prnt_rights_date: TXSDate;
    Fdeprivation_prnt_rights_date_Specified: boolean;
    Freturn_prnt_rights_date: TXSDate;
    Freturn_prnt_rights_date_Specified: boolean;
    Fchild_data: PersonalData;
    Fchild_data_Specified: boolean;
    procedure Setdeprivation_prnt_rights_date(Index: Integer; const ATXSDate: TXSDate);
    function  deprivation_prnt_rights_date_Specified(Index: Integer): boolean;
    procedure Setreturn_prnt_rights_date(Index: Integer; const ATXSDate: TXSDate);
    function  return_prnt_rights_date_Specified(Index: Integer): boolean;
    procedure Setchild_data(Index: Integer; const APersonalData: PersonalData);
    function  child_data_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property deprivation_prnt_rights_date: TXSDate       Index (IS_OPTN) read Fdeprivation_prnt_rights_date write Setdeprivation_prnt_rights_date stored deprivation_prnt_rights_date_Specified;
    property return_prnt_rights_date:      TXSDate       Index (IS_OPTN) read Freturn_prnt_rights_date write Setreturn_prnt_rights_date stored return_prnt_rights_date_Specified;
    property child_data:                   PersonalData  Index (IS_OPTN) read Fchild_data write Setchild_data stored child_data_Specified;
  end;

  documents7 = array of document2;              { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : familyInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  familyInfo = class(TRemotable)
  private
    Fperson_data: PersonalData;
    Fperson_data_Specified: boolean;
    Fprnt_rights_info: parentRightsInfo;
    Fprnt_rights_info_Specified: boolean;
    Fdocuments: documents7;
    Fdocuments_Specified: boolean;
    procedure Setperson_data(Index: Integer; const APersonalData: PersonalData);
    function  person_data_Specified(Index: Integer): boolean;
    procedure Setprnt_rights_info(Index: Integer; const AparentRightsInfo: parentRightsInfo);
    function  prnt_rights_info_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments7: documents7);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property person_data:      PersonalData      Index (IS_OPTN) read Fperson_data write Setperson_data stored person_data_Specified;
    property prnt_rights_info: parentRightsInfo  Index (IS_OPTN) read Fprnt_rights_info write Setprnt_rights_info stored prnt_rights_info_Specified;
    property documents:        documents7        Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;



  // ************************************************************************ //
  // XML       : martialStatus, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  martialStatus = class(TRemotable)
  private
    Fdate: TXSDate;
    Fdate_Specified: boolean;
    Fregion: Classifier;
    Fregion_Specified: boolean;
    Fdvc_date: TXSDate;
    Fdvc_date_Specified: boolean;
    Fdvc_region: Classifier;
    Fdvc_region_Specified: boolean;
    Finvalid_mrg_date: TXSDate;
    Finvalid_mrg_date_Specified: boolean;
    Finvalid_mrg_region: Classifier;
    Finvalid_mrg_region_Specified: boolean;
    procedure Setdate(Index: Integer; const ATXSDate: TXSDate);
    function  date_Specified(Index: Integer): boolean;
    procedure Setregion(Index: Integer; const AClassifier: Classifier);
    function  region_Specified(Index: Integer): boolean;
    procedure Setdvc_date(Index: Integer; const ATXSDate: TXSDate);
    function  dvc_date_Specified(Index: Integer): boolean;
    procedure Setdvc_region(Index: Integer; const AClassifier: Classifier);
    function  dvc_region_Specified(Index: Integer): boolean;
    procedure Setinvalid_mrg_date(Index: Integer; const ATXSDate: TXSDate);
    function  invalid_mrg_date_Specified(Index: Integer): boolean;
    procedure Setinvalid_mrg_region(Index: Integer; const AClassifier: Classifier);
    function  invalid_mrg_region_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property date:               TXSDate     Index (IS_OPTN) read Fdate write Setdate stored date_Specified;
    property region:             Classifier  Index (IS_OPTN) read Fregion write Setregion stored region_Specified;
    property dvc_date:           TXSDate     Index (IS_OPTN) read Fdvc_date write Setdvc_date stored dvc_date_Specified;
    property dvc_region:         Classifier  Index (IS_OPTN) read Fdvc_region write Setdvc_region stored dvc_region_Specified;
    property invalid_mrg_date:   TXSDate     Index (IS_OPTN) read Finvalid_mrg_date write Setinvalid_mrg_date stored invalid_mrg_date_Specified;
    property invalid_mrg_region: Classifier  Index (IS_OPTN) read Finvalid_mrg_region write Setinvalid_mrg_region stored invalid_mrg_region_Specified;
  end;

  documents8 = array of document2;              { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : martialStatusInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  martialStatusInfo = class(TRemotable)
  private
    Fcert_data: martialStatus;
    Fcert_data_Specified: boolean;
    Fdocuments: documents8;
    Fdocuments_Specified: boolean;
    procedure Setcert_data(Index: Integer; const AmartialStatus: martialStatus);
    function  cert_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments8: documents8);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property cert_data: martialStatus  Index (IS_OPTN) read Fcert_data write Setcert_data stored cert_data_Specified;
    property documents: documents8     Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;

  documents9 = array of document2;              { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : parentRightsData, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  parentRightsData = class(TRemotable)
  private
    Fprnt_rights_info: parentRightsInfo;
    Fprnt_rights_info_Specified: boolean;
    Fdocuments: documents9;
    Fdocuments_Specified: boolean;
    procedure Setprnt_rights_info(Index: Integer; const AparentRightsInfo: parentRightsInfo);
    function  prnt_rights_info_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments9: documents9);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property prnt_rights_info: parentRightsInfo  Index (IS_OPTN) read Fprnt_rights_info write Setprnt_rights_info stored prnt_rights_info_Specified;
    property documents:        documents9        Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;

  documents10 = array of document2;             { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : educationInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  educationInfo = class(TRemotable)
  private
    Feducation_data: Education;
    Feducation_data_Specified: boolean;
    Fdocuments: documents10;
    Fdocuments_Specified: boolean;
    procedure Seteducation_data(Index: Integer; const AEducation: Education);
    function  education_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments10: documents10);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property education_data: Education    Index (IS_OPTN) read Feducation_data write Seteducation_data stored education_data_Specified;
    property documents:      documents10  Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;



  // ************************************************************************ //
  // XML       : Education, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  Education = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Feducation_specialization: Classifier;
    Feducation_specialization_Specified: boolean;
    Feducation_department: Classifier;
    Feducation_department_Specified: boolean;
    Feducation_begin_data: TXSDate;
    Feducation_begin_data_Specified: boolean;
    Feducation_end_data: TXSDate;
    Feducation_end_data_Specified: boolean;
    Feducation_record_number: Int64;
    Feducation_record_number_Specified: boolean;
    Factive: Boolean;
    Factive_Specified: boolean;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Seteducation_specialization(Index: Integer; const AClassifier: Classifier);
    function  education_specialization_Specified(Index: Integer): boolean;
    procedure Seteducation_department(Index: Integer; const AClassifier: Classifier);
    function  education_department_Specified(Index: Integer): boolean;
    procedure Seteducation_begin_data(Index: Integer; const ATXSDate: TXSDate);
    function  education_begin_data_Specified(Index: Integer): boolean;
    procedure Seteducation_end_data(Index: Integer; const ATXSDate: TXSDate);
    function  education_end_data_Specified(Index: Integer): boolean;
    procedure Seteducation_record_number(Index: Integer; const AInt64: Int64);
    function  education_record_number_Specified(Index: Integer): boolean;
    procedure Setactive(Index: Integer; const ABoolean: Boolean);
    function  active_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:                   Classifier  Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property education_specialization: Classifier  Index (IS_OPTN) read Feducation_specialization write Seteducation_specialization stored education_specialization_Specified;
    property education_department:     Classifier  Index (IS_OPTN) read Feducation_department write Seteducation_department stored education_department_Specified;
    property education_begin_data:     TXSDate     Index (IS_OPTN) read Feducation_begin_data write Seteducation_begin_data stored education_begin_data_Specified;
    property education_end_data:       TXSDate     Index (IS_OPTN) read Feducation_end_data write Seteducation_end_data stored education_end_data_Specified;
    property education_record_number:  Int64       Index (IS_OPTN) read Feducation_record_number write Seteducation_record_number stored education_record_number_Specified;
    property active:                   Boolean     Index (IS_OPTN) read Factive write Setactive stored active_Specified;
  end;



  // ************************************************************************ //
  // XML       : ScienceRank, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  ScienceRank = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Fscience_rank: Classifier;
    Fscience_rank_Specified: boolean;
    Fscience_rank_date: TXSDate;
    Fscience_rank_date_Specified: boolean;
    Fscience_rank_number: WideString;
    Fscience_rank_number_Specified: boolean;
    Factive: Boolean;
    Factive_Specified: boolean;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Setscience_rank(Index: Integer; const AClassifier: Classifier);
    function  science_rank_Specified(Index: Integer): boolean;
    procedure Setscience_rank_date(Index: Integer; const ATXSDate: TXSDate);
    function  science_rank_date_Specified(Index: Integer): boolean;
    procedure Setscience_rank_number(Index: Integer; const AWideString: WideString);
    function  science_rank_number_Specified(Index: Integer): boolean;
    procedure Setactive(Index: Integer; const ABoolean: Boolean);
    function  active_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:              Classifier  Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property science_rank:        Classifier  Index (IS_OPTN) read Fscience_rank write Setscience_rank stored science_rank_Specified;
    property science_rank_date:   TXSDate     Index (IS_OPTN) read Fscience_rank_date write Setscience_rank_date stored science_rank_date_Specified;
    property science_rank_number: WideString  Index (IS_OPTN) read Fscience_rank_number write Setscience_rank_number stored science_rank_number_Specified;
    property active:              Boolean     Index (IS_OPTN) read Factive write Setactive stored active_Specified;
  end;

  documents11 = array of document2;             { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : scienceRankInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  scienceRankInfo = class(TRemotable)
  private
    Fscience_rank_data: ScienceRank;
    Fscience_rank_data_Specified: boolean;
    Fdocuments: documents11;
    Fdocuments_Specified: boolean;
    procedure Setscience_rank_data(Index: Integer; const AScienceRank: ScienceRank);
    function  science_rank_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments11: documents11);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property science_rank_data: ScienceRank  Index (IS_OPTN) read Fscience_rank_data write Setscience_rank_data stored science_rank_data_Specified;
    property documents:         documents11  Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;



  // ************************************************************************ //
  // XML       : ScienceDegree, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  ScienceDegree = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Fscience_degree: Classifier;
    Fscience_degree_Specified: boolean;
    Fscience_degree_date: TXSDate;
    Fscience_degree_date_Specified: boolean;
    Fscience_degree_number: WideString;
    Fscience_degree_number_Specified: boolean;
    Factive: Boolean;
    Factive_Specified: boolean;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Setscience_degree(Index: Integer; const AClassifier: Classifier);
    function  science_degree_Specified(Index: Integer): boolean;
    procedure Setscience_degree_date(Index: Integer; const ATXSDate: TXSDate);
    function  science_degree_date_Specified(Index: Integer): boolean;
    procedure Setscience_degree_number(Index: Integer; const AWideString: WideString);
    function  science_degree_number_Specified(Index: Integer): boolean;
    procedure Setactive(Index: Integer; const ABoolean: Boolean);
    function  active_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:                Classifier  Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property science_degree:        Classifier  Index (IS_OPTN) read Fscience_degree write Setscience_degree stored science_degree_Specified;
    property science_degree_date:   TXSDate     Index (IS_OPTN) read Fscience_degree_date write Setscience_degree_date stored science_degree_date_Specified;
    property science_degree_number: WideString  Index (IS_OPTN) read Fscience_degree_number write Setscience_degree_number stored science_degree_number_Specified;
    property active:                Boolean     Index (IS_OPTN) read Factive write Setactive stored active_Specified;
  end;

  documents12 = array of document2;             { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : scienceDegreeInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  scienceDegreeInfo = class(TRemotable)
  private
    Fscience_degree_data: ScienceDegree;
    Fscience_degree_data_Specified: boolean;
    Fdocuments: documents12;
    Fdocuments_Specified: boolean;
    procedure Setscience_degree_data(Index: Integer; const AScienceDegree: ScienceDegree);
    function  science_degree_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments12: documents12);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property science_degree_data: ScienceDegree  Index (IS_OPTN) read Fscience_degree_data write Setscience_degree_data stored science_degree_data_Specified;
    property documents:           documents12    Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;

  documents13 = array of document2;             { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : employmentStatusInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  employmentStatusInfo = class(TRemotable)
  private
    Femployment_status_data: Classifier;
    Femployment_status_data_Specified: boolean;
    Fdocuments: documents13;
    Fdocuments_Specified: boolean;
    procedure Setemployment_status_data(Index: Integer; const AClassifier: Classifier);
    function  employment_status_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments13: documents13);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property employment_status_data: Classifier   Index (IS_OPTN) read Femployment_status_data write Setemployment_status_data stored employment_status_data_Specified;
    property documents:              documents13  Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;

  documents14 = array of document2;             { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : employmentInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  employmentInfo = class(TRemotable)
  private
    Femployment_data: fszn;
    Femployment_data_Specified: boolean;
    Fdocuments: documents14;
    Fdocuments_Specified: boolean;
    procedure Setemployment_data(Index: Integer; const Afszn: fszn);
    function  employment_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments14: documents14);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property employment_data: fszn         Index (IS_OPTN) read Femployment_data write Setemployment_data stored employment_data_Specified;
    property documents:       documents14  Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;

  employment_periods = array of employment_period;   { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : fszn, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  fszn = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Femployment_organization: WideString;
    Femployment_organization_Specified: boolean;
    Femployment_organization_name: WideString;
    Femployment_organization_name_Specified: boolean;
    Femployment_periods: employment_periods;
    Femployment_periods_Specified: boolean;
    Factive: Integer;
    Factive_Specified: boolean;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Setemployment_organization(Index: Integer; const AWideString: WideString);
    function  employment_organization_Specified(Index: Integer): boolean;
    procedure Setemployment_organization_name(Index: Integer; const AWideString: WideString);
    function  employment_organization_name_Specified(Index: Integer): boolean;
    procedure Setemployment_periods(Index: Integer; const Aemployment_periods: employment_periods);
    function  employment_periods_Specified(Index: Integer): boolean;
    procedure Setactive(Index: Integer; const AInteger: Integer);
    function  active_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:                       Classifier          Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property employment_organization:      WideString          Index (IS_OPTN) read Femployment_organization write Setemployment_organization stored employment_organization_Specified;
    property employment_organization_name: WideString          Index (IS_OPTN) read Femployment_organization_name write Setemployment_organization_name stored employment_organization_name_Specified;
    property employment_periods:           employment_periods  Index (IS_OPTN) read Femployment_periods write Setemployment_periods stored employment_periods_Specified;
    property active:                       Integer             Index (IS_OPTN) read Factive write Setactive stored active_Specified;
  end;



  // ************************************************************************ //
  // XML       : employmentPeriod, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  employmentPeriod = class(TRemotable)
  private
    Femployment_begin_date: TXSDate;
    Femployment_begin_date_Specified: boolean;
    Femployment_end_date: TXSDate;
    Femployment_end_date_Specified: boolean;
    procedure Setemployment_begin_date(Index: Integer; const ATXSDate: TXSDate);
    function  employment_begin_date_Specified(Index: Integer): boolean;
    procedure Setemployment_end_date(Index: Integer; const ATXSDate: TXSDate);
    function  employment_end_date_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property employment_begin_date: TXSDate  Index (IS_OPTN) read Femployment_begin_date write Setemployment_begin_date stored employment_begin_date_Specified;
    property employment_end_date:   TXSDate  Index (IS_OPTN) read Femployment_end_date write Setemployment_end_date stored employment_end_date_Specified;
  end;

  deaths2    = array of death_info;             { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  absents    = array of absent_info;            { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  unefficients = array of unefficient_info;     { "http://gisun.agatsystem.by/common/types/"[Cplx] }
  restrict_efficients = array of restrict_efficient_info;   { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : CourtList, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  CourtList = class(TRemotable)
  private
    Fdeaths: deaths2;
    Fdeaths_Specified: boolean;
    Fabsents: absents;
    Fabsents_Specified: boolean;
    Funefficients: unefficients;
    Funefficients_Specified: boolean;
    Frestrict_efficients: restrict_efficients;
    Frestrict_efficients_Specified: boolean;
    procedure Setdeaths(Index: Integer; const Adeaths2: deaths2);
    function  deaths_Specified(Index: Integer): boolean;
    procedure Setabsents(Index: Integer; const Aabsents: absents);
    function  absents_Specified(Index: Integer): boolean;
    procedure Setunefficients(Index: Integer; const Aunefficients: unefficients);
    function  unefficients_Specified(Index: Integer): boolean;
    procedure Setrestrict_efficients(Index: Integer; const Arestrict_efficients: restrict_efficients);
    function  restrict_efficients_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property deaths:              deaths2              Index (IS_OPTN) read Fdeaths write Setdeaths stored deaths_Specified;
    property absents:             absents              Index (IS_OPTN) read Fabsents write Setabsents stored absents_Specified;
    property unefficients:        unefficients         Index (IS_OPTN) read Funefficients write Setunefficients stored unefficients_Specified;
    property restrict_efficients: restrict_efficients  Index (IS_OPTN) read Frestrict_efficients write Setrestrict_efficients stored restrict_efficients_Specified;
  end;

  documents15 = array of document2;             { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : courtDeathInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  courtDeathInfo = class(TRemotable)
  private
    Fdeath_data: CourtDeathData;
    Fdeath_data_Specified: boolean;
    Fdocuments: documents15;
    Fdocuments_Specified: boolean;
    procedure Setdeath_data(Index: Integer; const ACourtDeathData: CourtDeathData);
    function  death_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments15: documents15);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property death_data: CourtDeathData  Index (IS_OPTN) read Fdeath_data write Setdeath_data stored death_data_Specified;
    property documents:  documents15     Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;



  // ************************************************************************ //
  // XML       : courtDecision, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  courtDecision = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Factive: Integer;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access: Classifier  Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property active: Integer     read Factive write Factive;
  end;



  // ************************************************************************ //
  // XML       : CourtDeathData, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  CourtDeathData = class(courtDecision)
  private
    Fdeath_date: TXSDate;
    Fdeath_date_Specified: boolean;
    Fdeath_date_cancel: TXSDate;
    Fdeath_date_cancel_Specified: boolean;
    procedure Setdeath_date(Index: Integer; const ATXSDate: TXSDate);
    function  death_date_Specified(Index: Integer): boolean;
    procedure Setdeath_date_cancel(Index: Integer; const ATXSDate: TXSDate);
    function  death_date_cancel_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property death_date:        TXSDate  Index (IS_OPTN) read Fdeath_date write Setdeath_date stored death_date_Specified;
    property death_date_cancel: TXSDate  Index (IS_OPTN) read Fdeath_date_cancel write Setdeath_date_cancel stored death_date_cancel_Specified;
  end;



  // ************************************************************************ //
  // XML       : CourtAbsentData, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  CourtAbsentData = class(courtDecision)
  private
    Fabsent_date: TXSDate;
    Fabsent_date_Specified: boolean;
    Fabsent_date_cancel: TXSDate;
    Fabsent_date_cancel_Specified: boolean;
    procedure Setabsent_date(Index: Integer; const ATXSDate: TXSDate);
    function  absent_date_Specified(Index: Integer): boolean;
    procedure Setabsent_date_cancel(Index: Integer; const ATXSDate: TXSDate);
    function  absent_date_cancel_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property absent_date:        TXSDate  Index (IS_OPTN) read Fabsent_date write Setabsent_date stored absent_date_Specified;
    property absent_date_cancel: TXSDate  Index (IS_OPTN) read Fabsent_date_cancel write Setabsent_date_cancel stored absent_date_cancel_Specified;
  end;

  documents16 = array of document2;             { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : courtAbsentInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  courtAbsentInfo = class(TRemotable)
  private
    Fabsent_data: CourtAbsentData;
    Fabsent_data_Specified: boolean;
    Fdocuments: documents16;
    Fdocuments_Specified: boolean;
    procedure Setabsent_data(Index: Integer; const ACourtAbsentData: CourtAbsentData);
    function  absent_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments16: documents16);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property absent_data: CourtAbsentData  Index (IS_OPTN) read Fabsent_data write Setabsent_data stored absent_data_Specified;
    property documents:   documents16      Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;



  // ************************************************************************ //
  // XML       : CourtUnefficientData, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  CourtUnefficientData = class(courtDecision)
  private
    Funefficient_date: TXSDate;
    Funefficient_date_Specified: boolean;
    Funefficient_date_cancel: TXSDate;
    Funefficient_date_cancel_Specified: boolean;
    procedure Setunefficient_date(Index: Integer; const ATXSDate: TXSDate);
    function  unefficient_date_Specified(Index: Integer): boolean;
    procedure Setunefficient_date_cancel(Index: Integer; const ATXSDate: TXSDate);
    function  unefficient_date_cancel_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property unefficient_date:        TXSDate  Index (IS_OPTN) read Funefficient_date write Setunefficient_date stored unefficient_date_Specified;
    property unefficient_date_cancel: TXSDate  Index (IS_OPTN) read Funefficient_date_cancel write Setunefficient_date_cancel stored unefficient_date_cancel_Specified;
  end;

  documents17 = array of document2;             { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : courtUnefficientInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  courtUnefficientInfo = class(TRemotable)
  private
    Funefficient_data: CourtUnefficientData;
    Funefficient_data_Specified: boolean;
    Fdocuments: documents17;
    Fdocuments_Specified: boolean;
    procedure Setunefficient_data(Index: Integer; const ACourtUnefficientData: CourtUnefficientData);
    function  unefficient_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments17: documents17);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property unefficient_data: CourtUnefficientData  Index (IS_OPTN) read Funefficient_data write Setunefficient_data stored unefficient_data_Specified;
    property documents:        documents17           Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;



  // ************************************************************************ //
  // XML       : CourtRestrictEfficientData, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  CourtRestrictEfficientData = class(courtDecision)
  private
    Frestrict_unefficient_date: TXSDate;
    Frestrict_unefficient_date_Specified: boolean;
    Frestrict_unefficient_date_cancel: TXSDate;
    Frestrict_unefficient_date_cancel_Specified: boolean;
    procedure Setrestrict_unefficient_date(Index: Integer; const ATXSDate: TXSDate);
    function  restrict_unefficient_date_Specified(Index: Integer): boolean;
    procedure Setrestrict_unefficient_date_cancel(Index: Integer; const ATXSDate: TXSDate);
    function  restrict_unefficient_date_cancel_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property restrict_unefficient_date:        TXSDate  Index (IS_OPTN) read Frestrict_unefficient_date write Setrestrict_unefficient_date stored restrict_unefficient_date_Specified;
    property restrict_unefficient_date_cancel: TXSDate  Index (IS_OPTN) read Frestrict_unefficient_date_cancel write Setrestrict_unefficient_date_cancel stored restrict_unefficient_date_cancel_Specified;
  end;

  documents18 = array of document2;             { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : courtRestrictEfficientInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  courtRestrictEfficientInfo = class(TRemotable)
  private
    Frestrict_efficient_data: CourtRestrictEfficientData;
    Frestrict_efficient_data_Specified: boolean;
    Fdocuments: documents18;
    Fdocuments_Specified: boolean;
    procedure Setrestrict_efficient_data(Index: Integer; const ACourtRestrictEfficientData: CourtRestrictEfficientData);
    function  restrict_efficient_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments18: documents18);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property restrict_efficient_data: CourtRestrictEfficientData  Index (IS_OPTN) read Frestrict_efficient_data write Setrestrict_efficient_data stored restrict_efficient_data_Specified;
    property documents:               documents18                 Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;



  // ************************************************************************ //
  // XML       : unemploymentData, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  unemploymentData = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Funemployment_begin_data: TXSDate;
    Funemployment_begin_data_Specified: boolean;
    Funemployment_end_data: TXSDate;
    Funemployment_end_data_Specified: boolean;
    Factive: Integer;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Setunemployment_begin_data(Index: Integer; const ATXSDate: TXSDate);
    function  unemployment_begin_data_Specified(Index: Integer): boolean;
    procedure Setunemployment_end_data(Index: Integer; const ATXSDate: TXSDate);
    function  unemployment_end_data_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:                  Classifier  Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property unemployment_begin_data: TXSDate     Index (IS_OPTN) read Funemployment_begin_data write Setunemployment_begin_data stored unemployment_begin_data_Specified;
    property unemployment_end_data:   TXSDate     Index (IS_OPTN) read Funemployment_end_data write Setunemployment_end_data stored unemployment_end_data_Specified;
    property active:                  Integer     read Factive write Factive;
  end;

  documents19 = array of document2;             { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : unemploymentInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  unemploymentInfo = class(TRemotable)
  private
    Funemplyment_data: unemploymentData;
    Funemplyment_data_Specified: boolean;
    Fdocuments: documents19;
    Fdocuments_Specified: boolean;
    procedure Setunemplyment_data(Index: Integer; const AunemploymentData: unemploymentData);
    function  unemplyment_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments19: documents19);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property unemplyment_data: unemploymentData  Index (IS_OPTN) read Funemplyment_data write Setunemplyment_data stored unemplyment_data_Specified;
    property documents:        documents19       Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;



  // ************************************************************************ //
  // XML       : Pension, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  Pension = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Fpension_type: Classifier;
    Fpension_type_Specified: boolean;
    Fpension_awarding_date: TXSDate;
    Fpension_awarding_date_Specified: boolean;
    Fpension_suspension_date: TXSDate;
    Fpension_suspension_date_Specified: boolean;
    Factive: Integer;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Setpension_type(Index: Integer; const AClassifier: Classifier);
    function  pension_type_Specified(Index: Integer): boolean;
    procedure Setpension_awarding_date(Index: Integer; const ATXSDate: TXSDate);
    function  pension_awarding_date_Specified(Index: Integer): boolean;
    procedure Setpension_suspension_date(Index: Integer; const ATXSDate: TXSDate);
    function  pension_suspension_date_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:                  Classifier  Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property pension_type:            Classifier  Index (IS_OPTN) read Fpension_type write Setpension_type stored pension_type_Specified;
    property pension_awarding_date:   TXSDate     Index (IS_OPTN) read Fpension_awarding_date write Setpension_awarding_date stored pension_awarding_date_Specified;
    property pension_suspension_date: TXSDate     Index (IS_OPTN) read Fpension_suspension_date write Setpension_suspension_date stored pension_suspension_date_Specified;
    property active:                  Integer     read Factive write Factive;
  end;

  documents20 = array of document2;             { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : pensionInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  pensionInfo = class(TRemotable)
  private
    Fpension_data: Pension;
    Fpension_data_Specified: boolean;
    Fdocuments: documents20;
    Fdocuments_Specified: boolean;
    procedure Setpension_data(Index: Integer; const APension: Pension);
    function  pension_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments20: documents20);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property pension_data: Pension      Index (IS_OPTN) read Fpension_data write Setpension_data stored pension_data_Specified;
    property documents:    documents20  Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;



  // ************************************************************************ //
  // XML       : salaryData, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  salaryData = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Fsalary_awarding_date: TXSDate;
    Fsalary_awarding_date_Specified: boolean;
    Fsalary_suspension_date: TXSDate;
    Fsalary_suspension_date_Specified: boolean;
    Factive: Integer;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Setsalary_awarding_date(Index: Integer; const ATXSDate: TXSDate);
    function  salary_awarding_date_Specified(Index: Integer): boolean;
    procedure Setsalary_suspension_date(Index: Integer; const ATXSDate: TXSDate);
    function  salary_suspension_date_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:                 Classifier  Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property salary_awarding_date:   TXSDate     Index (IS_OPTN) read Fsalary_awarding_date write Setsalary_awarding_date stored salary_awarding_date_Specified;
    property salary_suspension_date: TXSDate     Index (IS_OPTN) read Fsalary_suspension_date write Setsalary_suspension_date stored salary_suspension_date_Specified;
    property active:                 Integer     read Factive write Factive;
  end;

  documents21 = array of document2;             { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : salaryInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  salaryInfo = class(TRemotable)
  private
    Fsalary_data: salaryData;
    Fsalary_data_Specified: boolean;
    Fdocuments: documents21;
    Fdocuments_Specified: boolean;
    procedure Setsalary_data(Index: Integer; const AsalaryData: salaryData);
    function  salary_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments21: documents21);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property salary_data: salaryData   Index (IS_OPTN) read Fsalary_data write Setsalary_data stored salary_data_Specified;
    property documents:   documents21  Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;



  // ************************************************************************ //
  // XML       : Insurance, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  Insurance = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Finsurance_awarding_date: TXSDate;
    Finsurance_awarding_date_Specified: boolean;
    Finsurance_suspension_date: TXSDate;
    Finsurance_suspension_date_Specified: boolean;
    Factive: Boolean;
    Factive_Specified: boolean;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Setinsurance_awarding_date(Index: Integer; const ATXSDate: TXSDate);
    function  insurance_awarding_date_Specified(Index: Integer): boolean;
    procedure Setinsurance_suspension_date(Index: Integer; const ATXSDate: TXSDate);
    function  insurance_suspension_date_Specified(Index: Integer): boolean;
    procedure Setactive(Index: Integer; const ABoolean: Boolean);
    function  active_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:                    Classifier  Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property insurance_awarding_date:   TXSDate     Index (IS_OPTN) read Finsurance_awarding_date write Setinsurance_awarding_date stored insurance_awarding_date_Specified;
    property insurance_suspension_date: TXSDate     Index (IS_OPTN) read Finsurance_suspension_date write Setinsurance_suspension_date stored insurance_suspension_date_Specified;
    property active:                    Boolean     Index (IS_OPTN) read Factive write Setactive stored active_Specified;
  end;

  documents22 = array of document2;             { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : insuranceInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  insuranceInfo = class(TRemotable)
  private
    Finsurance_data: Insurance;
    Finsurance_data_Specified: boolean;
    Fdocuments: documents22;
    Fdocuments_Specified: boolean;
    procedure Setinsurance_data(Index: Integer; const AInsurance: Insurance);
    function  insurance_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments22: documents22);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property insurance_data: Insurance    Index (IS_OPTN) read Finsurance_data write Setinsurance_data stored insurance_data_Specified;
    property documents:      documents22  Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;



  // ************************************************************************ //
  // XML       : Tax, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  Tax = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Ftax_awarding_date: TXSDate;
    Ftax_awarding_date_Specified: boolean;
    Ftax_number: WideString;
    Ftax_number_Specified: boolean;
    Ftax_debt_data: Integer;
    Ftax_debt_data_Specified: boolean;
    Factive: Integer;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Settax_awarding_date(Index: Integer; const ATXSDate: TXSDate);
    function  tax_awarding_date_Specified(Index: Integer): boolean;
    procedure Settax_number(Index: Integer; const AWideString: WideString);
    function  tax_number_Specified(Index: Integer): boolean;
    procedure Settax_debt_data(Index: Integer; const AInteger: Integer);
    function  tax_debt_data_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:            Classifier  Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property tax_awarding_date: TXSDate     Index (IS_OPTN) read Ftax_awarding_date write Settax_awarding_date stored tax_awarding_date_Specified;
    property tax_number:        WideString  Index (IS_OPTN) read Ftax_number write Settax_number stored tax_number_Specified;
    property tax_debt_data:     Integer     Index (IS_OPTN) read Ftax_debt_data write Settax_debt_data stored tax_debt_data_Specified;
    property active:            Integer     read Factive write Factive;
  end;

  documents23 = array of document2;             { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : taxInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  taxInfo = class(TRemotable)
  private
    Ftax_data: Tax;
    Ftax_data_Specified: boolean;
    Fdocuments: documents23;
    Fdocuments_Specified: boolean;
    procedure Settax_data(Index: Integer; const ATax: Tax);
    function  tax_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments23: documents23);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property tax_data:  Tax          Index (IS_OPTN) read Ftax_data write Settax_data stored tax_data_Specified;
    property documents: documents23  Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;



  // ************************************************************************ //
  // XML       : Military, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  Military = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Fmilitary_service_awarding_date: TXSDate;
    Fmilitary_service_awarding_date_Specified: boolean;
    Fmilitary_service_suspension_date: TXSDate;
    Fmilitary_service_suspension_date_Specified: boolean;
    Factive: Integer;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Setmilitary_service_awarding_date(Index: Integer; const ATXSDate: TXSDate);
    function  military_service_awarding_date_Specified(Index: Integer): boolean;
    procedure Setmilitary_service_suspension_date(Index: Integer; const ATXSDate: TXSDate);
    function  military_service_suspension_date_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:                           Classifier  Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property military_service_awarding_date:   TXSDate     Index (IS_OPTN) read Fmilitary_service_awarding_date write Setmilitary_service_awarding_date stored military_service_awarding_date_Specified;
    property military_service_suspension_date: TXSDate     Index (IS_OPTN) read Fmilitary_service_suspension_date write Setmilitary_service_suspension_date stored military_service_suspension_date_Specified;
    property active:                           Integer     read Factive write Factive;
  end;

  documents24 = array of document2;             { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : militaryInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  militaryInfo = class(TRemotable)
  private
    Fmilitary_data: Military;
    Fmilitary_data_Specified: boolean;
    Fdocuments: documents24;
    Fdocuments_Specified: boolean;
    procedure Setmilitary_data(Index: Integer; const AMilitary: Military);
    function  military_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments24: documents24);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property military_data: Military     Index (IS_OPTN) read Fmilitary_data write Setmilitary_data stored military_data_Specified;
    property documents:     documents24  Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;



  // ************************************************************************ //
  // XML       : Disability, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  Disability = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Fdisability_group: Classifier;
    Fdisability_group_Specified: boolean;
    Fdisability_date: TXSDate;
    Fdisability_date_Specified: boolean;
    Fdisability_term: TXSDate;
    Fdisability_term_Specified: boolean;
    Fdisability_cause: Classifier;
    Fdisability_cause_Specified: boolean;
    Factive: Boolean;
    Factive_Specified: boolean;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Setdisability_group(Index: Integer; const AClassifier: Classifier);
    function  disability_group_Specified(Index: Integer): boolean;
    procedure Setdisability_date(Index: Integer; const ATXSDate: TXSDate);
    function  disability_date_Specified(Index: Integer): boolean;
    procedure Setdisability_term(Index: Integer; const ATXSDate: TXSDate);
    function  disability_term_Specified(Index: Integer): boolean;
    procedure Setdisability_cause(Index: Integer; const AClassifier: Classifier);
    function  disability_cause_Specified(Index: Integer): boolean;
    procedure Setactive(Index: Integer; const ABoolean: Boolean);
    function  active_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:           Classifier  Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property disability_group: Classifier  Index (IS_OPTN) read Fdisability_group write Setdisability_group stored disability_group_Specified;
    property disability_date:  TXSDate     Index (IS_OPTN) read Fdisability_date write Setdisability_date stored disability_date_Specified;
    property disability_term:  TXSDate     Index (IS_OPTN) read Fdisability_term write Setdisability_term stored disability_term_Specified;
    property disability_cause: Classifier  Index (IS_OPTN) read Fdisability_cause write Setdisability_cause stored disability_cause_Specified;
    property active:           Boolean     Index (IS_OPTN) read Factive write Setactive stored active_Specified;
  end;

  documents25 = array of document2;             { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : disabilityInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  disabilityInfo = class(TRemotable)
  private
    Fdisability_data: Disability;
    Fdisability_data_Specified: boolean;
    Fdocuments: documents25;
    Fdocuments_Specified: boolean;
    procedure Setdisability_data(Index: Integer; const ADisability: Disability);
    function  disability_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments25: documents25);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property disability_data: Disability   Index (IS_OPTN) read Fdisability_data write Setdisability_data stored disability_data_Specified;
    property documents:       documents25  Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
  end;

  query_params = array of param;                { "http://gisun.agatsystem.by/common/types/"[Cplx] }


  // ************************************************************************ //
  // XML       : MessageCover, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  MessageCover = class(TRemotable)
  private
    Fmessage_id: WideString;
    Fmessage_type: Classifier;
    Fmessage_time: TXSDateTime;
    Fmessage_source: Classifier;
    Fparent_message_id: WideString;
    Fparent_message_id_Specified: boolean;
    Fsystem_id: Classifier;
    Fsystem_id_Specified: boolean;
    Fquery_params: query_params;
    Fquery_params_Specified: boolean;
    procedure Setparent_message_id(Index: Integer; const AWideString: WideString);
    function  parent_message_id_Specified(Index: Integer): boolean;
    procedure Setsystem_id(Index: Integer; const AClassifier: Classifier);
    function  system_id_Specified(Index: Integer): boolean;
    procedure Setquery_params(Index: Integer; const Aquery_params: query_params);
    function  query_params_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property message_id:        WideString    read Fmessage_id write Fmessage_id;
    property message_type:      Classifier    read Fmessage_type write Fmessage_type;
    property message_time:      TXSDateTime   read Fmessage_time write Fmessage_time;
    property message_source:    Classifier    read Fmessage_source write Fmessage_source;
    property parent_message_id: WideString    Index (IS_OPTN) read Fparent_message_id write Setparent_message_id stored parent_message_id_Specified;
    property system_id:         Classifier    Index (IS_OPTN) read Fsystem_id write Setsystem_id stored system_id_Specified;
    property query_params:      query_params  Index (IS_OPTN) read Fquery_params write Setquery_params stored query_params_Specified;
  end;



  // ************************************************************************ //
  // XML       : QueryParam, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  QueryParam = class(TRemotable)
  private
    Fparam_type: Classifier;
    Fparam_type_Specified: boolean;
    Fparam_value: WideString;
    Fparam_value_Specified: boolean;
    procedure Setparam_type(Index: Integer; const AClassifier: Classifier);
    function  param_type_Specified(Index: Integer): boolean;
    procedure Setparam_value(Index: Integer; const AWideString: WideString);
    function  param_value_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property param_type:  Classifier  Index (IS_OPTN) read Fparam_type write Setparam_type stored param_type_Specified;
    property param_value: WideString  Index (IS_OPTN) read Fparam_value write Setparam_value stored param_value_Specified;
  end;

  personal_history = array of personal_data_info;   { "http://gisun.agatsystem.by/common/ws/"[Cplx] }
  nationality3 = array of nationality_info;     { "http://gisun.agatsystem.by/common/ws/"[Cplx] }
  addresses  = array of address2;               { "http://gisun.agatsystem.by/common/ws/"[Cplx] }
  temp_addresses2 = array of temp_address;      { "http://gisun.agatsystem.by/common/ws/"[Cplx] }
  deaths3    = array of death2;                 { "http://gisun.agatsystem.by/common/ws/"[Cplx] }
  burials2   = array of burial_info;            { "http://gisun.agatsystem.by/common/ws/"[Cplx] }
  guardianships2 = array of guardianship_info;   { "http://gisun.agatsystem.by/common/ws/"[Cplx] }
  trusteeships2 = array of trusteeship_info;    { "http://gisun.agatsystem.by/common/ws/"[Cplx] }
  educations2 = array of educations_info;       { "http://gisun.agatsystem.by/common/ws/"[Cplx] }
  scienceRanks2 = array of science_ranks_info;   { "http://gisun.agatsystem.by/common/ws/"[Cplx] }
  scienceDegrees2 = array of science_degrees_info;   { "http://gisun.agatsystem.by/common/ws/"[Cplx] }
  employments2 = array of employment_info;      { "http://gisun.agatsystem.by/common/ws/"[Cplx] }
  pensions2  = array of pensions_info;          { "http://gisun.agatsystem.by/common/ws/"[Cplx] }
  insurances2 = array of insurances_info;       { "http://gisun.agatsystem.by/common/ws/"[Cplx] }
  taxies2    = array of taxies_info;            { "http://gisun.agatsystem.by/common/ws/"[Cplx] }
  militaries2 = array of militaries_info;       { "http://gisun.agatsystem.by/common/ws/"[Cplx] }
  disabilities2 = array of disability_info;     { "http://gisun.agatsystem.by/common/ws/"[Cplx] }
  documents26 = array of document2;             { "http://gisun.agatsystem.by/common/ws/"[Cplx] }


  // ************************************************************************ //
  // XML       : personalDataInfo, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  personalDataInfo = class(TRemotable)
  private
    Fpersonal_data: PersonalData;
    Fpersonal_data_Specified: boolean;
    Fdocuments: documents26;
    Fdocuments_Specified: boolean;
    procedure Setpersonal_data(Index: Integer; const APersonalData: PersonalData);
    function  personal_data_Specified(Index: Integer): boolean;
    procedure Setdocuments(Index: Integer; const Adocuments26: documents26);
    function  documents_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property personal_data: PersonalData  Index (IS_OPTN or IS_UNQL) read Fpersonal_data write Setpersonal_data stored personal_data_Specified;
    property documents:     documents26   Index (IS_OPTN or IS_UNQL) read Fdocuments write Setdocuments stored documents_Specified;
  end;

  prnt_rights2 = array of prnt_rights_data;     { "http://gisun.agatsystem.by/common/ws/"[Cplx] }


  // ************************************************************************ //
  // XML       : LexemStatus, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  LexemStatus = class(TRemotable)
  private
    Flexema: LangValueList;
    Flexema_Specified: boolean;
    Factive: Boolean;
    Factive_Specified: boolean;
    procedure Setlexema(Index: Integer; const ALangValueList: LangValueList);
    function  lexema_Specified(Index: Integer): boolean;
    procedure Setactive(Index: Integer; const ABoolean: Boolean);
    function  active_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property lexema: LangValueList  Index (IS_OPTN) read Flexema write Setlexema stored lexema_Specified;
    property active: Boolean        Index (IS_OPTN) read Factive write Setactive stored active_Specified;
  end;



  // ************************************************************************ //
  // XML       : RegisterResponse, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  RegisterResponse = class(TRemotable)
  private
    Fcover: MessageCover;
    Fresponse: ResponseData;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:    MessageCover  read Fcover write Fcover;
    property response: ResponseData  read Fresponse write Fresponse;
  end;



  // ************************************************************************ //
  // XML       : ResponsePerson, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  ResponsePerson = class(TRemotable)
  private
    Frequest_id: WideString;
    Fdata: PersonalData;
  public
    destructor Destroy; override;
  published
    property request_id: WideString    read Frequest_id write Frequest_id;
    property data:       PersonalData  read Fdata write Fdata;
  end;



  // ************************************************************************ //
  // XML       : ResponseIdentif, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  ResponseIdentif = class(TRemotable)
  private
    Frequest_id: WideString;
    Fdata: WideString;
  published
    property request_id: WideString  read Frequest_id write Frequest_id;
    property data:       WideString  read Fdata write Fdata;
  end;

  ErrorList  = array of error;                  { "http://gisun.agatsystem.by/common/ws/"[GblCplx] }


  // ************************************************************************ //
  // XML       : WsError, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  WsError = class(TRemotable)
  private
    Ferror_code: Classifier;
    Ferror_place: WideString;
    Ferror_place_Specified: boolean;
    Fwrong_value: WideString;
    Fwrong_value_Specified: boolean;
    Fcorrect_value: WideString;
    Fcorrect_value_Specified: boolean;
    Fcheck_name: WideString;
    Fcheck_name_Specified: boolean;
    Fdescription: WideString;
    Fdescription_Specified: boolean;
    Fidentif: WideString;
    Fidentif_Specified: boolean;
    procedure Seterror_place(Index: Integer; const AWideString: WideString);
    function  error_place_Specified(Index: Integer): boolean;
    procedure Setwrong_value(Index: Integer; const AWideString: WideString);
    function  wrong_value_Specified(Index: Integer): boolean;
    procedure Setcorrect_value(Index: Integer; const AWideString: WideString);
    function  correct_value_Specified(Index: Integer): boolean;
    procedure Setcheck_name(Index: Integer; const AWideString: WideString);
    function  check_name_Specified(Index: Integer): boolean;
    procedure Setdescription(Index: Integer; const AWideString: WideString);
    function  description_Specified(Index: Integer): boolean;
    procedure Setidentif(Index: Integer; const AWideString: WideString);
    function  identif_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property error_code:    Classifier  read Ferror_code write Ferror_code;
    property error_place:   WideString  Index (IS_OPTN) read Ferror_place write Seterror_place stored error_place_Specified;
    property wrong_value:   WideString  Index (IS_OPTN) read Fwrong_value write Setwrong_value stored wrong_value_Specified;
    property correct_value: WideString  Index (IS_OPTN) read Fcorrect_value write Setcorrect_value stored correct_value_Specified;
    property check_name:    WideString  Index (IS_OPTN) read Fcheck_name write Setcheck_name stored check_name_Specified;
    property description:   WideString  Index (IS_OPTN) read Fdescription write Setdescription stored description_Specified;
    property identif:       WideString  Index (IS_OPTN) read Fidentif write Setidentif stored identif_Specified;
  end;



  // ************************************************************************ //
  // XML       : WsException, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // Info      : Fault
  // ************************************************************************ //
  WsException = class(ERemotableException)
  private
    Fcover: MessageCover;
    Ferror_list: ErrorList;
    Ferror_list_Specified: boolean;
    procedure Seterror_list(Index: Integer; const AErrorList: ErrorList);
    function  error_list_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property cover:      MessageCover  read Fcover write Fcover;
    property error_list: ErrorList     Index (IS_OPTN) read Ferror_list write Seterror_list stored error_list_Specified;
  end;



  // ************************************************************************ //
  // XML       : RegisterPersonListRequest, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  RegisterPersonListRequest = class(TRemotable)
  private
    Fcover: MessageCover;
    Frequest: PersonListRequest;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:   MessageCover       read Fcover write Fcover;
    property request: PersonListRequest  read Frequest write Frequest;
  end;



  // ************************************************************************ //
  // XML       : PersonListRequest, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  PersonListRequest = class(TRemotable)
  private
    Frequest_id: WideString;
    Fsurname: WideString;
    Fsurname_Specified: boolean;
    Fname_: WideString;
    Fname__Specified: boolean;
    Fsname: WideString;
    Fsname_Specified: boolean;
    Fbdate: WideString;
    Fbdate_Specified: boolean;
    FbdateTo: WideString;
    FbdateTo_Specified: boolean;
    Fidentif: WideString;
    Fidentif_Specified: boolean;
    Farrival: Boolean;
    Farrival_Specified: boolean;
    Fdeparture: Boolean;
    Fdeparture_Specified: boolean;
    FpermAddress: Boolean;
    FpermAddress_Specified: boolean;
    FtempAddress: Boolean;
    FtempAddress_Specified: boolean;
    Farea: Classifier;
    Farea_Specified: boolean;
    Fregion: Classifier;
    Fregion_Specified: boolean;
    Fsoviet: Classifier;
    Fsoviet_Specified: boolean;
    Ftype_city: Classifier;
    Ftype_city_Specified: boolean;
    Fcity: Classifier;
    Fcity_Specified: boolean;
    Ftype_street: Classifier;
    Ftype_street_Specified: boolean;
    Fstreet: Classifier;
    Fstreet_Specified: boolean;
    Fhouse: WideString;
    Fhouse_Specified: boolean;
    Fkorps: WideString;
    Fkorps_Specified: boolean;
    Fapp: WideString;
    Fapp_Specified: boolean;
    Fquery_reason: WideString;
    Fquery_reason_Specified: boolean;
    Farchive: Boolean;
    Farchive_Specified: boolean;
    Fcount: Integer;
    Fcount_Specified: boolean;
    procedure Setsurname(Index: Integer; const AWideString: WideString);
    function  surname_Specified(Index: Integer): boolean;
    procedure Setname_(Index: Integer; const AWideString: WideString);
    function  name__Specified(Index: Integer): boolean;
    procedure Setsname(Index: Integer; const AWideString: WideString);
    function  sname_Specified(Index: Integer): boolean;
    procedure Setbdate(Index: Integer; const AWideString: WideString);
    function  bdate_Specified(Index: Integer): boolean;
    procedure SetbdateTo(Index: Integer; const AWideString: WideString);
    function  bdateTo_Specified(Index: Integer): boolean;
    procedure Setidentif(Index: Integer; const AWideString: WideString);
    function  identif_Specified(Index: Integer): boolean;
    procedure Setarrival(Index: Integer; const ABoolean: Boolean);
    function  arrival_Specified(Index: Integer): boolean;
    procedure Setdeparture(Index: Integer; const ABoolean: Boolean);
    function  departure_Specified(Index: Integer): boolean;
    procedure SetpermAddress(Index: Integer; const ABoolean: Boolean);
    function  permAddress_Specified(Index: Integer): boolean;
    procedure SettempAddress(Index: Integer; const ABoolean: Boolean);
    function  tempAddress_Specified(Index: Integer): boolean;
    procedure Setarea(Index: Integer; const AClassifier: Classifier);
    function  area_Specified(Index: Integer): boolean;
    procedure Setregion(Index: Integer; const AClassifier: Classifier);
    function  region_Specified(Index: Integer): boolean;
    procedure Setsoviet(Index: Integer; const AClassifier: Classifier);
    function  soviet_Specified(Index: Integer): boolean;
    procedure Settype_city(Index: Integer; const AClassifier: Classifier);
    function  type_city_Specified(Index: Integer): boolean;
    procedure Setcity(Index: Integer; const AClassifier: Classifier);
    function  city_Specified(Index: Integer): boolean;
    procedure Settype_street(Index: Integer; const AClassifier: Classifier);
    function  type_street_Specified(Index: Integer): boolean;
    procedure Setstreet(Index: Integer; const AClassifier: Classifier);
    function  street_Specified(Index: Integer): boolean;
    procedure Sethouse(Index: Integer; const AWideString: WideString);
    function  house_Specified(Index: Integer): boolean;
    procedure Setkorps(Index: Integer; const AWideString: WideString);
    function  korps_Specified(Index: Integer): boolean;
    procedure Setapp(Index: Integer; const AWideString: WideString);
    function  app_Specified(Index: Integer): boolean;
    procedure Setquery_reason(Index: Integer; const AWideString: WideString);
    function  query_reason_Specified(Index: Integer): boolean;
    procedure Setarchive(Index: Integer; const ABoolean: Boolean);
    function  archive_Specified(Index: Integer): boolean;
    procedure Setcount(Index: Integer; const AInteger: Integer);
    function  count_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property request_id:   WideString  read Frequest_id write Frequest_id;
    property surname:      WideString  Index (IS_OPTN) read Fsurname write Setsurname stored surname_Specified;
    property name_:        WideString  Index (IS_OPTN) read Fname_ write Setname_ stored name__Specified;
    property sname:        WideString  Index (IS_OPTN) read Fsname write Setsname stored sname_Specified;
    property bdate:        WideString  Index (IS_OPTN) read Fbdate write Setbdate stored bdate_Specified;
    property bdateTo:      WideString  Index (IS_OPTN) read FbdateTo write SetbdateTo stored bdateTo_Specified;
    property identif:      WideString  Index (IS_OPTN) read Fidentif write Setidentif stored identif_Specified;
    property arrival:      Boolean     Index (IS_OPTN) read Farrival write Setarrival stored arrival_Specified;
    property departure:    Boolean     Index (IS_OPTN) read Fdeparture write Setdeparture stored departure_Specified;
    property permAddress:  Boolean     Index (IS_OPTN) read FpermAddress write SetpermAddress stored permAddress_Specified;
    property tempAddress:  Boolean     Index (IS_OPTN) read FtempAddress write SettempAddress stored tempAddress_Specified;
    property area:         Classifier  Index (IS_OPTN) read Farea write Setarea stored area_Specified;
    property region:       Classifier  Index (IS_OPTN) read Fregion write Setregion stored region_Specified;
    property soviet:       Classifier  Index (IS_OPTN) read Fsoviet write Setsoviet stored soviet_Specified;
    property type_city:    Classifier  Index (IS_OPTN) read Ftype_city write Settype_city stored type_city_Specified;
    property city:         Classifier  Index (IS_OPTN) read Fcity write Setcity stored city_Specified;
    property type_street:  Classifier  Index (IS_OPTN) read Ftype_street write Settype_street stored type_street_Specified;
    property street:       Classifier  Index (IS_OPTN) read Fstreet write Setstreet stored street_Specified;
    property house:        WideString  Index (IS_OPTN) read Fhouse write Sethouse stored house_Specified;
    property korps:        WideString  Index (IS_OPTN) read Fkorps write Setkorps stored korps_Specified;
    property app:          WideString  Index (IS_OPTN) read Fapp write Setapp stored app_Specified;
    property query_reason: WideString  Index (IS_OPTN) read Fquery_reason write Setquery_reason stored query_reason_Specified;
    property archive:      Boolean     Index (IS_OPTN) read Farchive write Setarchive stored archive_Specified;
    property count:        Integer     Index (IS_OPTN) read Fcount write Setcount stored count_Specified;
  end;



  // ************************************************************************ //
  // XML       : RegisterRequest, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  RegisterRequest = class(TRemotable)
  private
    Fcover: MessageCover;
    Frequest: RequestData;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:   MessageCover  read Fcover write Fcover;
    property request: RequestData   read Frequest write Frequest;
  end;



  // ************************************************************************ //
  // XML       : PersonRequest, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  PersonRequest = class(TRemotable)
  private
    Frequest_id: WideString;
    Fidentif_number: WideString;
    Fdocument: Document;
  public
    destructor Destroy; override;
  published
    property request_id:     WideString  read Frequest_id write Frequest_id;
    property identif_number: WideString  read Fidentif_number write Fidentif_number;
    property document:       Document    read Fdocument write Fdocument;
  end;



  // ************************************************************************ //
  // XML       : IdentifRequest, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  IdentifRequest = class(TRemotable)
  private
    Frequest_id: WideString;
    Fsex: Classifier;
    Fbirth_day: WideString;
  public
    destructor Destroy; override;
  published
    property request_id: WideString  read Frequest_id write Frequest_id;
    property sex:        Classifier  read Fsex write Fsex;
    property birth_day:  WideString  read Fbirth_day write Fbirth_day;
  end;

  LexemStatusList = array of lexemStatus2;      { "http://gisun.agatsystem.by/common/ws/"[Lit][GblCplx] }


  // ************************************************************************ //
  // XML       : ClassifierChangeRequest, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  ClassifierChangeRequest = class(TRemotable)
  private
    Ftype_: Integer;
    Fdate: TXSDateTime;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property type_: Integer      read Ftype_ write Ftype_;
    property date:  TXSDateTime  read Fdate write Fdate;
  end;



  // ************************************************************************ //
  // XML       : RegisterPersonIdentifRequest, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  RegisterPersonIdentifRequest = class(TRemotable)
  private
    Fcover: MessageCover;
    Frequest: PersonIdentifRequest;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:   MessageCover          read Fcover write Fcover;
    property request: PersonIdentifRequest  read Frequest write Frequest;
  end;



  // ************************************************************************ //
  // XML       : PersonIdentifRequest, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  PersonIdentifRequest = class(TRemotable)
  private
    Frequest_id: WideString;
    Fsurname: WideString;
    Fname_: WideString;
    Fsname: WideString;
    Fbdate: WideString;
  published
    property request_id: WideString  read Frequest_id write Frequest_id;
    property surname:    WideString  read Fsurname write Fsurname;
    property name_:      WideString  read Fname_ write Fname_;
    property sname:      WideString  read Fsname write Fsname;
    property bdate:      WideString  read Fbdate write Fbdate;
  end;



  // ************************************************************************ //
  // XML       : classifier_change_request, global, <element>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  classifier_change_request = class(ClassifierChangeRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : exception, global, <element>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // Info      : Fault
  // ************************************************************************ //
  exception = class(WsException)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : getClassifierChange, global, <element>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // Info      : Wrapper
  // ************************************************************************ //
  getClassifierChange = class(ClassifierChangeRequest)
  private
  published
  end;

  getClassifierChangeResponse =  type ClassifierList;      { "http://gisun.agatsystem.by/common/ws/"[Lit][GblElm] }
  getLexemStatus  =  type Integer;      { "http://gisun.agatsystem.by/common/ws/"[Lit][GblElm] }
  getLexemStatusResponse =  type LexemStatusList;      { "http://gisun.agatsystem.by/common/ws/"[Lit][GblElm] }


  // ************************************************************************ //
  // XML       : register_person_identif_request, global, <element>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // Info      : Wrapper
  // ************************************************************************ //
  register_person_identif_request = class(RegisterPersonIdentifRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : register_person_list_request, global, <element>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // Info      : Wrapper
  // ************************************************************************ //
  register_person_list_request = class(RegisterPersonListRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : register_request, global, <element>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // Info      : Wrapper
  // ************************************************************************ //
  register_request = class(RegisterRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : register_response, global, <element>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // Info      : Wrapper
  // ************************************************************************ //
  register_response = class(RegisterResponse)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : value, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  value = class(LangValue)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : classifier, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  classifier2 = class(Classifier)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : nationality_info, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  nationality_info = class(Nationality2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : temp_address, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  temp_address = class(Address)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : death, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  death2 = class(deathInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : burial_info, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  burial_info = class(burialDataInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : guardianship_info, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  guardianship_info = class(guardianshipInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : trusteeship_info, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  trusteeship_info = class(trusteeshipInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : educations_info, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  educations_info = class(educationInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : science_ranks_info, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  science_ranks_info = class(scienceRankInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : science_degrees_info, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  science_degrees_info = class(scienceDegreeInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : employment_info, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  employment_info = class(employmentInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : pensions_info, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  pensions_info = class(pensionInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : insurances_info, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  insurances_info = class(insuranceInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : taxies_info, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  taxies_info = class(taxInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : militaries_info, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  militaries_info = class(militaryInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : disability_info, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  disability_info = class(disabilityInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : document, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  document2 = class(Document)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : prnt_rights_data, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  prnt_rights_data = class(parentRightsData)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : employment_period, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  employment_period = class(employmentPeriod)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : death_info, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  death_info = class(courtDeathInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : absent_info, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  absent_info = class(courtAbsentInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : unefficient_info, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  unefficient_info = class(courtUnefficientInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : restrict_efficient_info, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  restrict_efficient_info = class(courtRestrictEfficientInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : param, alias
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  param = class(QueryParam)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : personal_data_info, alias
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  personal_data_info = class(personalDataInfo)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : address, alias
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  address2 = class(Address)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : error, alias
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  error = class(WsError)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : lexemStatus, alias
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  lexemStatus2 = class(LexemStatus)
  private
  published
  end;

  Array_Of_Document = array of Document;        { "http://gisun.agatsystem.by/common/types/"[GblUbnd] }
  Array_Of_photoInfo = array of photoInfo;      { "http://gisun.agatsystem.by/common/types/"[GblUbnd] }
  Array_Of_Citizenship = array of Citizenship;   { "http://gisun.agatsystem.by/common/types/"[GblUbnd] }


  // ************************************************************************ //
  // XML       : History, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  History = class(TRemotable)
  private
    Fpersonal_history: personal_history;
    Fpersonal_history_Specified: boolean;
    Fnationality_data: Array_Of_Citizenship;
    Fnationality_data_Specified: boolean;
    Fnationality: nationality3;
    Fnationality_Specified: boolean;
    Faddresses: addresses;
    Faddresses_Specified: boolean;
    Ftemp_addresses: temp_addresses2;
    Ftemp_addresses_Specified: boolean;
    Fdeaths: deaths3;
    Fdeaths_Specified: boolean;
    Fburials: burials2;
    Fburials_Specified: boolean;
    Fguardianships: guardianships2;
    Fguardianships_Specified: boolean;
    Ftrusteeships: trusteeships2;
    Ftrusteeships_Specified: boolean;
    Ffamily: FamilyDataHistory;
    Ffamily_Specified: boolean;
    Feducations: educations2;
    Feducations_Specified: boolean;
    FscienceRanks: scienceRanks2;
    FscienceRanks_Specified: boolean;
    FscienceDegrees: scienceDegrees2;
    FscienceDegrees_Specified: boolean;
    Femployment_status_info: employmentStatusInfo;
    Femployment_status_info_Specified: boolean;
    Femployments: employments2;
    Femployments_Specified: boolean;
    Fcourts: CourtList;
    Fcourts_Specified: boolean;
    Funemplyment_info: unemploymentInfo;
    Funemplyment_info_Specified: boolean;
    Fpensions: pensions2;
    Fpensions_Specified: boolean;
    Fsalary_info: salaryInfo;
    Fsalary_info_Specified: boolean;
    Finsurances: insurances2;
    Finsurances_Specified: boolean;
    Ftaxies: taxies2;
    Ftaxies_Specified: boolean;
    Fmilitaries: militaries2;
    Fmilitaries_Specified: boolean;
    Fdisabilities: disabilities2;
    Fdisabilities_Specified: boolean;
    procedure Setpersonal_history(Index: Integer; const Apersonal_history: personal_history);
    function  personal_history_Specified(Index: Integer): boolean;
    procedure Setnationality_data(Index: Integer; const AArray_Of_Citizenship: Array_Of_Citizenship);
    function  nationality_data_Specified(Index: Integer): boolean;
    procedure Setnationality(Index: Integer; const Anationality3: nationality3);
    function  nationality_Specified(Index: Integer): boolean;
    procedure Setaddresses(Index: Integer; const Aaddresses: addresses);
    function  addresses_Specified(Index: Integer): boolean;
    procedure Settemp_addresses(Index: Integer; const Atemp_addresses2: temp_addresses2);
    function  temp_addresses_Specified(Index: Integer): boolean;
    procedure Setdeaths(Index: Integer; const Adeaths3: deaths3);
    function  deaths_Specified(Index: Integer): boolean;
    procedure Setburials(Index: Integer; const Aburials2: burials2);
    function  burials_Specified(Index: Integer): boolean;
    procedure Setguardianships(Index: Integer; const Aguardianships2: guardianships2);
    function  guardianships_Specified(Index: Integer): boolean;
    procedure Settrusteeships(Index: Integer; const Atrusteeships2: trusteeships2);
    function  trusteeships_Specified(Index: Integer): boolean;
    procedure Setfamily(Index: Integer; const AFamilyDataHistory: FamilyDataHistory);
    function  family_Specified(Index: Integer): boolean;
    procedure Seteducations(Index: Integer; const Aeducations2: educations2);
    function  educations_Specified(Index: Integer): boolean;
    procedure SetscienceRanks(Index: Integer; const AscienceRanks2: scienceRanks2);
    function  scienceRanks_Specified(Index: Integer): boolean;
    procedure SetscienceDegrees(Index: Integer; const AscienceDegrees2: scienceDegrees2);
    function  scienceDegrees_Specified(Index: Integer): boolean;
    procedure Setemployment_status_info(Index: Integer; const AemploymentStatusInfo: employmentStatusInfo);
    function  employment_status_info_Specified(Index: Integer): boolean;
    procedure Setemployments(Index: Integer; const Aemployments2: employments2);
    function  employments_Specified(Index: Integer): boolean;
    procedure Setcourts(Index: Integer; const ACourtList: CourtList);
    function  courts_Specified(Index: Integer): boolean;
    procedure Setunemplyment_info(Index: Integer; const AunemploymentInfo: unemploymentInfo);
    function  unemplyment_info_Specified(Index: Integer): boolean;
    procedure Setpensions(Index: Integer; const Apensions2: pensions2);
    function  pensions_Specified(Index: Integer): boolean;
    procedure Setsalary_info(Index: Integer; const AsalaryInfo: salaryInfo);
    function  salary_info_Specified(Index: Integer): boolean;
    procedure Setinsurances(Index: Integer; const Ainsurances2: insurances2);
    function  insurances_Specified(Index: Integer): boolean;
    procedure Settaxies(Index: Integer; const Ataxies2: taxies2);
    function  taxies_Specified(Index: Integer): boolean;
    procedure Setmilitaries(Index: Integer; const Amilitaries2: militaries2);
    function  militaries_Specified(Index: Integer): boolean;
    procedure Setdisabilities(Index: Integer; const Adisabilities2: disabilities2);
    function  disabilities_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property personal_history:       personal_history      Index (IS_OPTN or IS_UNQL) read Fpersonal_history write Setpersonal_history stored personal_history_Specified;
    property nationality_data:       Array_Of_Citizenship  Index (IS_OPTN or IS_UNBD or IS_UNQL) read Fnationality_data write Setnationality_data stored nationality_data_Specified;
    property nationality:            nationality3          Index (IS_OPTN or IS_UNQL) read Fnationality write Setnationality stored nationality_Specified;
    property addresses:              addresses             Index (IS_OPTN or IS_UNQL) read Faddresses write Setaddresses stored addresses_Specified;
    property temp_addresses:         temp_addresses2       Index (IS_OPTN or IS_UNQL) read Ftemp_addresses write Settemp_addresses stored temp_addresses_Specified;
    property deaths:                 deaths3               Index (IS_OPTN or IS_UNQL) read Fdeaths write Setdeaths stored deaths_Specified;
    property burials:                burials2              Index (IS_OPTN or IS_UNQL) read Fburials write Setburials stored burials_Specified;
    property guardianships:          guardianships2        Index (IS_OPTN or IS_UNQL) read Fguardianships write Setguardianships stored guardianships_Specified;
    property trusteeships:           trusteeships2         Index (IS_OPTN or IS_UNQL) read Ftrusteeships write Settrusteeships stored trusteeships_Specified;
    property family:                 FamilyDataHistory     Index (IS_OPTN or IS_UNQL) read Ffamily write Setfamily stored family_Specified;
    property educations:             educations2           Index (IS_OPTN or IS_UNQL) read Feducations write Seteducations stored educations_Specified;
    property scienceRanks:           scienceRanks2         Index (IS_OPTN or IS_UNQL) read FscienceRanks write SetscienceRanks stored scienceRanks_Specified;
    property scienceDegrees:         scienceDegrees2       Index (IS_OPTN or IS_UNQL) read FscienceDegrees write SetscienceDegrees stored scienceDegrees_Specified;
    property employment_status_info: employmentStatusInfo  Index (IS_OPTN or IS_UNQL) read Femployment_status_info write Setemployment_status_info stored employment_status_info_Specified;
    property employments:            employments2          Index (IS_OPTN or IS_UNQL) read Femployments write Setemployments stored employments_Specified;
    property courts:                 CourtList             Index (IS_OPTN or IS_UNQL) read Fcourts write Setcourts stored courts_Specified;
    property unemplyment_info:       unemploymentInfo      Index (IS_OPTN or IS_UNQL) read Funemplyment_info write Setunemplyment_info stored unemplyment_info_Specified;
    property pensions:               pensions2             Index (IS_OPTN or IS_UNQL) read Fpensions write Setpensions stored pensions_Specified;
    property salary_info:            salaryInfo            Index (IS_OPTN or IS_UNQL) read Fsalary_info write Setsalary_info stored salary_info_Specified;
    property insurances:             insurances2           Index (IS_OPTN or IS_UNQL) read Finsurances write Setinsurances stored insurances_Specified;
    property taxies:                 taxies2               Index (IS_OPTN or IS_UNQL) read Ftaxies write Settaxies stored taxies_Specified;
    property militaries:             militaries2           Index (IS_OPTN or IS_UNQL) read Fmilitaries write Setmilitaries stored militaries_Specified;
    property disabilities:           disabilities2         Index (IS_OPTN or IS_UNQL) read Fdisabilities write Setdisabilities stored disabilities_Specified;
  end;



  // ************************************************************************ //
  // XML       : PersonalData, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  PersonalData = class(TRemotable)
  private
    Faccess: Classifier;
    Faccess_Specified: boolean;
    Fidentif: WideString;
    Fidentif_Specified: boolean;
    Flast_name: WideString;
    Flast_name_Specified: boolean;
    Flast_name_bel: WideString;
    Flast_name_bel_Specified: boolean;
    Flast_name_lat: WideString;
    Flast_name_lat_Specified: boolean;
    Fname_: WideString;
    Fname__Specified: boolean;
    Fname_bel: WideString;
    Fname_bel_Specified: boolean;
    Fname_lat: WideString;
    Fname_lat_Specified: boolean;
    Fpatronymic: WideString;
    Fpatronymic_Specified: boolean;
    Fpatronymic_bel: WideString;
    Fpatronymic_bel_Specified: boolean;
    Fpatronymic_lat: WideString;
    Fpatronymic_lat_Specified: boolean;
    Fsex: Classifier;
    Fsex_Specified: boolean;
    Fbirth_day: WideString;
    Fbirth_day_Specified: boolean;
    Fbirth_place: birth_place;
    Fbirth_place_Specified: boolean;
    Fcitizenship: Classifier;
    Fcitizenship_Specified: boolean;
    Fstatus: Classifier;
    Fstatus_Specified: boolean;
    Fdocument: Array_Of_Document;
    Fdocument_Specified: boolean;
    Fphoto: Array_Of_photoInfo;
    Fphoto_Specified: boolean;
    Fnationality_data: Array_Of_Citizenship;
    Fnationality_data_Specified: boolean;
    Fnationality: nationality;
    Fnationality_Specified: boolean;
    Faddress: Address;
    Faddress_Specified: boolean;
    Ftemp_addresses: temp_addresses;
    Ftemp_addresses_Specified: boolean;
    Fdeaths: deaths;
    Fdeaths_Specified: boolean;
    Fburials: burials;
    Fburials_Specified: boolean;
    Fguardianships: guardianships;
    Fguardianships_Specified: boolean;
    Ftrusteeships: trusteeships;
    Ftrusteeships_Specified: boolean;
    Ffamily: FamilyData;
    Ffamily_Specified: boolean;
    Feducations: educations;
    Feducations_Specified: boolean;
    FscienceRanks: scienceRanks;
    FscienceRanks_Specified: boolean;
    FscienceDegrees: scienceDegrees;
    FscienceDegrees_Specified: boolean;
    Femployment_status_info: employmentStatusInfo;
    Femployment_status_info_Specified: boolean;
    Femployments: employments;
    Femployments_Specified: boolean;
    Fcourts: CourtList;
    Fcourts_Specified: boolean;
    Funemplyment_info: unemploymentInfo;
    Funemplyment_info_Specified: boolean;
    Fpensions: pensions;
    Fpensions_Specified: boolean;
    Fsalary_info: salaryInfo;
    Fsalary_info_Specified: boolean;
    Finsurances: insurances;
    Finsurances_Specified: boolean;
    Ftaxies: taxies;
    Ftaxies_Specified: boolean;
    Fmilitaries: militaries;
    Fmilitaries_Specified: boolean;
    Fdisabilities: disabilities;
    Fdisabilities_Specified: boolean;
    Fhistory: History;
    Fhistory_Specified: boolean;
    procedure Setaccess(Index: Integer; const AClassifier: Classifier);
    function  access_Specified(Index: Integer): boolean;
    procedure Setidentif(Index: Integer; const AWideString: WideString);
    function  identif_Specified(Index: Integer): boolean;
    procedure Setlast_name(Index: Integer; const AWideString: WideString);
    function  last_name_Specified(Index: Integer): boolean;
    procedure Setlast_name_bel(Index: Integer; const AWideString: WideString);
    function  last_name_bel_Specified(Index: Integer): boolean;
    procedure Setlast_name_lat(Index: Integer; const AWideString: WideString);
    function  last_name_lat_Specified(Index: Integer): boolean;
    procedure Setname_(Index: Integer; const AWideString: WideString);
    function  name__Specified(Index: Integer): boolean;
    procedure Setname_bel(Index: Integer; const AWideString: WideString);
    function  name_bel_Specified(Index: Integer): boolean;
    procedure Setname_lat(Index: Integer; const AWideString: WideString);
    function  name_lat_Specified(Index: Integer): boolean;
    procedure Setpatronymic(Index: Integer; const AWideString: WideString);
    function  patronymic_Specified(Index: Integer): boolean;
    procedure Setpatronymic_bel(Index: Integer; const AWideString: WideString);
    function  patronymic_bel_Specified(Index: Integer): boolean;
    procedure Setpatronymic_lat(Index: Integer; const AWideString: WideString);
    function  patronymic_lat_Specified(Index: Integer): boolean;
    procedure Setsex(Index: Integer; const AClassifier: Classifier);
    function  sex_Specified(Index: Integer): boolean;
    procedure Setbirth_day(Index: Integer; const AWideString: WideString);
    function  birth_day_Specified(Index: Integer): boolean;
    procedure Setbirth_place(Index: Integer; const Abirth_place: birth_place);
    function  birth_place_Specified(Index: Integer): boolean;
    procedure Setcitizenship(Index: Integer; const AClassifier: Classifier);
    function  citizenship_Specified(Index: Integer): boolean;
    procedure Setstatus(Index: Integer; const AClassifier: Classifier);
    function  status_Specified(Index: Integer): boolean;
    procedure Setdocument(Index: Integer; const AArray_Of_Document: Array_Of_Document);
    function  document_Specified(Index: Integer): boolean;
    procedure Setphoto(Index: Integer; const AArray_Of_photoInfo: Array_Of_photoInfo);
    function  photo_Specified(Index: Integer): boolean;
    procedure Setnationality_data(Index: Integer; const AArray_Of_Citizenship: Array_Of_Citizenship);
    function  nationality_data_Specified(Index: Integer): boolean;
    procedure Setnationality(Index: Integer; const Anationality: nationality);
    function  nationality_Specified(Index: Integer): boolean;
    procedure Setaddress(Index: Integer; const AAddress: Address);
    function  address_Specified(Index: Integer): boolean;
    procedure Settemp_addresses(Index: Integer; const Atemp_addresses: temp_addresses);
    function  temp_addresses_Specified(Index: Integer): boolean;
    procedure Setdeaths(Index: Integer; const Adeaths: deaths);
    function  deaths_Specified(Index: Integer): boolean;
    procedure Setburials(Index: Integer; const Aburials: burials);
    function  burials_Specified(Index: Integer): boolean;
    procedure Setguardianships(Index: Integer; const Aguardianships: guardianships);
    function  guardianships_Specified(Index: Integer): boolean;
    procedure Settrusteeships(Index: Integer; const Atrusteeships: trusteeships);
    function  trusteeships_Specified(Index: Integer): boolean;
    procedure Setfamily(Index: Integer; const AFamilyData: FamilyData);
    function  family_Specified(Index: Integer): boolean;
    procedure Seteducations(Index: Integer; const Aeducations: educations);
    function  educations_Specified(Index: Integer): boolean;
    procedure SetscienceRanks(Index: Integer; const AscienceRanks: scienceRanks);
    function  scienceRanks_Specified(Index: Integer): boolean;
    procedure SetscienceDegrees(Index: Integer; const AscienceDegrees: scienceDegrees);
    function  scienceDegrees_Specified(Index: Integer): boolean;
    procedure Setemployment_status_info(Index: Integer; const AemploymentStatusInfo: employmentStatusInfo);
    function  employment_status_info_Specified(Index: Integer): boolean;
    procedure Setemployments(Index: Integer; const Aemployments: employments);
    function  employments_Specified(Index: Integer): boolean;
    procedure Setcourts(Index: Integer; const ACourtList: CourtList);
    function  courts_Specified(Index: Integer): boolean;
    procedure Setunemplyment_info(Index: Integer; const AunemploymentInfo: unemploymentInfo);
    function  unemplyment_info_Specified(Index: Integer): boolean;
    procedure Setpensions(Index: Integer; const Apensions: pensions);
    function  pensions_Specified(Index: Integer): boolean;
    procedure Setsalary_info(Index: Integer; const AsalaryInfo: salaryInfo);
    function  salary_info_Specified(Index: Integer): boolean;
    procedure Setinsurances(Index: Integer; const Ainsurances: insurances);
    function  insurances_Specified(Index: Integer): boolean;
    procedure Settaxies(Index: Integer; const Ataxies: taxies);
    function  taxies_Specified(Index: Integer): boolean;
    procedure Setmilitaries(Index: Integer; const Amilitaries: militaries);
    function  militaries_Specified(Index: Integer): boolean;
    procedure Setdisabilities(Index: Integer; const Adisabilities: disabilities);
    function  disabilities_Specified(Index: Integer): boolean;
    procedure Sethistory(Index: Integer; const AHistory: History);
    function  history_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property access:                 Classifier            Index (IS_OPTN) read Faccess write Setaccess stored access_Specified;
    property identif:                WideString            Index (IS_OPTN) read Fidentif write Setidentif stored identif_Specified;
    property last_name:              WideString            Index (IS_OPTN) read Flast_name write Setlast_name stored last_name_Specified;
    property last_name_bel:          WideString            Index (IS_OPTN) read Flast_name_bel write Setlast_name_bel stored last_name_bel_Specified;
    property last_name_lat:          WideString            Index (IS_OPTN) read Flast_name_lat write Setlast_name_lat stored last_name_lat_Specified;
    property name_:                  WideString            Index (IS_OPTN) read Fname_ write Setname_ stored name__Specified;
    property name_bel:               WideString            Index (IS_OPTN) read Fname_bel write Setname_bel stored name_bel_Specified;
    property name_lat:               WideString            Index (IS_OPTN) read Fname_lat write Setname_lat stored name_lat_Specified;
    property patronymic:             WideString            Index (IS_OPTN) read Fpatronymic write Setpatronymic stored patronymic_Specified;
    property patronymic_bel:         WideString            Index (IS_OPTN) read Fpatronymic_bel write Setpatronymic_bel stored patronymic_bel_Specified;
    property patronymic_lat:         WideString            Index (IS_OPTN) read Fpatronymic_lat write Setpatronymic_lat stored patronymic_lat_Specified;
    property sex:                    Classifier            Index (IS_OPTN) read Fsex write Setsex stored sex_Specified;
    property birth_day:              WideString            Index (IS_OPTN) read Fbirth_day write Setbirth_day stored birth_day_Specified;
    property birth_place:            birth_place           Index (IS_OPTN) read Fbirth_place write Setbirth_place stored birth_place_Specified;
    property citizenship:            Classifier            Index (IS_OPTN) read Fcitizenship write Setcitizenship stored citizenship_Specified;
    property status:                 Classifier            Index (IS_OPTN) read Fstatus write Setstatus stored status_Specified;
    property document:               Array_Of_Document     Index (IS_OPTN or IS_UNBD) read Fdocument write Setdocument stored document_Specified;
    property photo:                  Array_Of_photoInfo    Index (IS_OPTN or IS_UNBD) read Fphoto write Setphoto stored photo_Specified;
    property nationality_data:       Array_Of_Citizenship  Index (IS_OPTN or IS_UNBD) read Fnationality_data write Setnationality_data stored nationality_data_Specified;
    property nationality:            nationality           Index (IS_OPTN) read Fnationality write Setnationality stored nationality_Specified;
    property address:                Address               Index (IS_OPTN) read Faddress write Setaddress stored address_Specified;
    property temp_addresses:         temp_addresses        Index (IS_OPTN) read Ftemp_addresses write Settemp_addresses stored temp_addresses_Specified;
    property deaths:                 deaths                Index (IS_OPTN) read Fdeaths write Setdeaths stored deaths_Specified;
    property burials:                burials               Index (IS_OPTN) read Fburials write Setburials stored burials_Specified;
    property guardianships:          guardianships         Index (IS_OPTN) read Fguardianships write Setguardianships stored guardianships_Specified;
    property trusteeships:           trusteeships          Index (IS_OPTN) read Ftrusteeships write Settrusteeships stored trusteeships_Specified;
    property family:                 FamilyData            Index (IS_OPTN) read Ffamily write Setfamily stored family_Specified;
    property educations:             educations            Index (IS_OPTN) read Feducations write Seteducations stored educations_Specified;
    property scienceRanks:           scienceRanks          Index (IS_OPTN) read FscienceRanks write SetscienceRanks stored scienceRanks_Specified;
    property scienceDegrees:         scienceDegrees        Index (IS_OPTN) read FscienceDegrees write SetscienceDegrees stored scienceDegrees_Specified;
    property employment_status_info: employmentStatusInfo  Index (IS_OPTN) read Femployment_status_info write Setemployment_status_info stored employment_status_info_Specified;
    property employments:            employments           Index (IS_OPTN) read Femployments write Setemployments stored employments_Specified;
    property courts:                 CourtList             Index (IS_OPTN) read Fcourts write Setcourts stored courts_Specified;
    property unemplyment_info:       unemploymentInfo      Index (IS_OPTN) read Funemplyment_info write Setunemplyment_info stored unemplyment_info_Specified;
    property pensions:               pensions              Index (IS_OPTN) read Fpensions write Setpensions stored pensions_Specified;
    property salary_info:            salaryInfo            Index (IS_OPTN) read Fsalary_info write Setsalary_info stored salary_info_Specified;
    property insurances:             insurances            Index (IS_OPTN) read Finsurances write Setinsurances stored insurances_Specified;
    property taxies:                 taxies                Index (IS_OPTN) read Ftaxies write Settaxies stored taxies_Specified;
    property militaries:             militaries            Index (IS_OPTN) read Fmilitaries write Setmilitaries stored militaries_Specified;
    property disabilities:           disabilities          Index (IS_OPTN) read Fdisabilities write Setdisabilities stored disabilities_Specified;
    property history:                History               Index (IS_OPTN) read Fhistory write Sethistory stored history_Specified;
  end;



  // ************************************************************************ //
  // XML       : personalData, global, <element>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  personalData2 = class(PersonalData)
  private
  published
  end;

  Array_Of_familyInfo = array of familyInfo;    { "http://gisun.agatsystem.by/common/types/"[GblUbnd] }


  // ************************************************************************ //
  // XML       : FamilyDataHistory, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  FamilyDataHistory = class(TRemotable)
  private
    Ffather: Array_Of_familyInfo;
    Ffather_Specified: boolean;
    Fmather: Array_Of_familyInfo;
    Fmather_Specified: boolean;
    Fwife: Array_Of_familyInfo;
    Fwife_Specified: boolean;
    Fhusband: Array_Of_familyInfo;
    Fhusband_Specified: boolean;
    Fchild: Array_Of_familyInfo;
    Fchild_Specified: boolean;
    Fprnt_rights: prnt_rights2;
    Fprnt_rights_Specified: boolean;
    procedure Setfather(Index: Integer; const AArray_Of_familyInfo: Array_Of_familyInfo);
    function  father_Specified(Index: Integer): boolean;
    procedure Setmather(Index: Integer; const AArray_Of_familyInfo: Array_Of_familyInfo);
    function  mather_Specified(Index: Integer): boolean;
    procedure Setwife(Index: Integer; const AArray_Of_familyInfo: Array_Of_familyInfo);
    function  wife_Specified(Index: Integer): boolean;
    procedure Sethusband(Index: Integer; const AArray_Of_familyInfo: Array_Of_familyInfo);
    function  husband_Specified(Index: Integer): boolean;
    procedure Setchild(Index: Integer; const AArray_Of_familyInfo: Array_Of_familyInfo);
    function  child_Specified(Index: Integer): boolean;
    procedure Setprnt_rights(Index: Integer; const Aprnt_rights2: prnt_rights2);
    function  prnt_rights_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property father:      Array_Of_familyInfo  Index (IS_OPTN or IS_UNBD or IS_NLBL or IS_UNQL) read Ffather write Setfather stored father_Specified;
    property mather:      Array_Of_familyInfo  Index (IS_OPTN or IS_UNBD or IS_NLBL or IS_UNQL) read Fmather write Setmather stored mather_Specified;
    property wife:        Array_Of_familyInfo  Index (IS_OPTN or IS_UNBD or IS_NLBL or IS_UNQL) read Fwife write Setwife stored wife_Specified;
    property husband:     Array_Of_familyInfo  Index (IS_OPTN or IS_UNBD or IS_NLBL or IS_UNQL) read Fhusband write Sethusband stored husband_Specified;
    property child:       Array_Of_familyInfo  Index (IS_OPTN or IS_UNBD or IS_NLBL or IS_UNQL) read Fchild write Setchild stored child_Specified;
    property prnt_rights: prnt_rights2         Index (IS_OPTN or IS_UNQL) read Fprnt_rights write Setprnt_rights stored prnt_rights_Specified;
  end;



  // ************************************************************************ //
  // XML       : FamilyData, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/types/
  // ************************************************************************ //
  FamilyData = class(TRemotable)
  private
    Ffather: familyInfo;
    Ffather_Specified: boolean;
    Fmather: familyInfo;
    Fmather_Specified: boolean;
    Fmartial_status: martialStatusInfo;
    Fmartial_status_Specified: boolean;
    Fwife: familyInfo;
    Fwife_Specified: boolean;
    Fhusband: familyInfo;
    Fhusband_Specified: boolean;
    Fchild: Array_Of_familyInfo;
    Fchild_Specified: boolean;
    Fprnt_rights: prnt_rights;
    Fprnt_rights_Specified: boolean;
    procedure Setfather(Index: Integer; const AfamilyInfo: familyInfo);
    function  father_Specified(Index: Integer): boolean;
    procedure Setmather(Index: Integer; const AfamilyInfo: familyInfo);
    function  mather_Specified(Index: Integer): boolean;
    procedure Setmartial_status(Index: Integer; const AmartialStatusInfo: martialStatusInfo);
    function  martial_status_Specified(Index: Integer): boolean;
    procedure Setwife(Index: Integer; const AfamilyInfo: familyInfo);
    function  wife_Specified(Index: Integer): boolean;
    procedure Sethusband(Index: Integer; const AfamilyInfo: familyInfo);
    function  husband_Specified(Index: Integer): boolean;
    procedure Setchild(Index: Integer; const AArray_Of_familyInfo: Array_Of_familyInfo);
    function  child_Specified(Index: Integer): boolean;
    procedure Setprnt_rights(Index: Integer; const Aprnt_rights: prnt_rights);
    function  prnt_rights_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property father:         familyInfo           Index (IS_OPTN) read Ffather write Setfather stored father_Specified;
    property mather:         familyInfo           Index (IS_OPTN) read Fmather write Setmather stored mather_Specified;
    property martial_status: martialStatusInfo    Index (IS_OPTN) read Fmartial_status write Setmartial_status stored martial_status_Specified;
    property wife:           familyInfo           Index (IS_OPTN) read Fwife write Setwife stored wife_Specified;
    property husband:        familyInfo           Index (IS_OPTN) read Fhusband write Sethusband stored husband_Specified;
    property child:          Array_Of_familyInfo  Index (IS_OPTN or IS_UNBD or IS_NLBL) read Fchild write Setchild stored child_Specified;
    property prnt_rights:    prnt_rights          Index (IS_OPTN) read Fprnt_rights write Setprnt_rights stored prnt_rights_Specified;
  end;

  Array_Of_ResponsePerson = array of ResponsePerson;   { "http://gisun.agatsystem.by/common/ws/"[GblUbnd] }
  Array_Of_ResponseIdentif = array of ResponseIdentif;   { "http://gisun.agatsystem.by/common/ws/"[GblUbnd] }


  // ************************************************************************ //
  // XML       : ResponseData, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  ResponseData = class(TRemotable)
  private
    Fpersonal_data: Array_Of_ResponsePerson;
    Fpersonal_data_Specified: boolean;
    Fidentif_number: Array_Of_ResponseIdentif;
    Fidentif_number_Specified: boolean;
    procedure Setpersonal_data(Index: Integer; const AArray_Of_ResponsePerson: Array_Of_ResponsePerson);
    function  personal_data_Specified(Index: Integer): boolean;
    procedure Setidentif_number(Index: Integer; const AArray_Of_ResponseIdentif: Array_Of_ResponseIdentif);
    function  identif_number_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property personal_data:  Array_Of_ResponsePerson   Index (IS_OPTN or IS_UNBD) read Fpersonal_data write Setpersonal_data stored personal_data_Specified;
    property identif_number: Array_Of_ResponseIdentif  Index (IS_OPTN or IS_UNBD) read Fidentif_number write Setidentif_number stored identif_number_Specified;
  end;

  Array_Of_PersonRequest = array of PersonRequest;   { "http://gisun.agatsystem.by/common/ws/"[GblUbnd] }
  Array_Of_IdentifRequest = array of IdentifRequest;   { "http://gisun.agatsystem.by/common/ws/"[GblUbnd] }


  // ************************************************************************ //
  // XML       : RequestData, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  RequestData = class(TRemotable)
  private
    Fperson_request: Array_Of_PersonRequest;
    Fperson_request_Specified: boolean;
    Fidentif_request: Array_Of_IdentifRequest;
    Fidentif_request_Specified: boolean;
    procedure Setperson_request(Index: Integer; const AArray_Of_PersonRequest: Array_Of_PersonRequest);
    function  person_request_Specified(Index: Integer): boolean;
    procedure Setidentif_request(Index: Integer; const AArray_Of_IdentifRequest: Array_Of_IdentifRequest);
    function  identif_request_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property person_request:  Array_Of_PersonRequest   Index (IS_OPTN or IS_UNBD) read Fperson_request write Setperson_request stored person_request_Specified;
    property identif_request: Array_Of_IdentifRequest  Index (IS_OPTN or IS_UNBD) read Fidentif_request write Setidentif_request stored identif_request_Specified;
  end;


  // ************************************************************************ //
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // soapAction: ||urn:getPersonIdentif|urn:getPersonList|urn:getPersonalData
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : wsBinding
  // service   : ws
  // port      : ws
  // URL       : http://127.0.0.1:8000/gisun-inf/common/ws
  // ************************************************************************ //
  GisunCommonWs = interface(IInvokable)
  ['{16FFF6A9-8631-D0C4-E000-7E8955849292}']

    // Cannot unwrap: 
    //     - The input part is not a complex type
    function  getLexemStatus(const getLexemStatus: getLexemStatus): getLexemStatusResponse; stdcall;
    function  getClassifierChange(const getClassifierChange: getClassifierChange): getClassifierChangeResponse; stdcall;

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  getPersonIdentif(const registerPersonIdentifRequest: register_person_identif_request): register_response; stdcall;

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  getPersonList(const registerPersonListRequest: register_person_list_request): register_response; stdcall;

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  getPersonalData(const registerRequest: register_request): register_response; stdcall;
  end;

function GetGisunCommonWsImpl(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): GisunCommonWs;  // vadim
function GetGisunWs(Addr, Proxy: string; RIO: THTTPRIO): GisunCommonWs;  // vadim


implementation
  uses SysUtils;

function GetGisunWs(Addr, Proxy: string; RIO: THTTPRIO): GisunCommonWs;  // vadim
begin
   Result := nil;
   if Addr<>'' then begin
      RIO.Converter.Options:=[soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soDocument, soDontSendEmptyNodes, soCacheMimeResponse, soLiteralParams, soUTF8EncodeXML];
      RIO.URL:=Addr;
      RIO.HTTPWebNode.Proxy:=Proxy;
      Result:=(RIO as GisunCommonWs);
   end;
end;

function GetGisunCommonWsImpl(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): GisunCommonWs;
const
  defWSDL = 'http://127.0.0.1:8000/gisun-inf/common/ws?wsdl';
  defURL  = 'http://127.0.0.1:8000/gisun-inf/common/ws';
  defSvc  = 'ws';
  defPrt  = 'ws';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as GisunCommonWs);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;


destructor Classifier.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Flexema)-1 do
    FreeAndNil(Flexema[I]);
  SetLength(Flexema, 0);
  for I := 0 to Length(Fparents)-1 do
    FreeAndNil(Fparents[I]);
  SetLength(Fparents, 0);
  FreeAndNil(Fbegin_date);
  FreeAndNil(Fend_date);
  inherited Destroy;
end;

procedure Classifier.Setcode(Index: Integer; const AWideString: WideString);
begin
  Fcode := AWideString;
  Fcode_Specified := True;
end;

function Classifier.code_Specified(Index: Integer): boolean;
begin
  Result := Fcode_Specified;
end;

procedure Classifier.Settype_(Index: Integer; const AInteger: Integer);
begin
  Ftype_ := AInteger;
  Ftype__Specified := True;
end;

function Classifier.type__Specified(Index: Integer): boolean;
begin
  Result := Ftype__Specified;
end;

procedure Classifier.Setlexema(Index: Integer; const ALangValueList: LangValueList);
begin
  Flexema := ALangValueList;
  Flexema_Specified := True;
end;

function Classifier.lexema_Specified(Index: Integer): boolean;
begin
  Result := Flexema_Specified;
end;

procedure Classifier.Setactive(Index: Integer; const ABoolean: Boolean);
begin
  Factive := ABoolean;
  Factive_Specified := True;
end;

function Classifier.active_Specified(Index: Integer): boolean;
begin
  Result := Factive_Specified;
end;

procedure Classifier.Setbegin_date(Index: Integer; const ATXSDateTime: TXSDateTime);
begin
  Fbegin_date := ATXSDateTime;
  Fbegin_date_Specified := True;
end;

function Classifier.begin_date_Specified(Index: Integer): boolean;
begin
  Result := Fbegin_date_Specified;
end;

procedure Classifier.Setend_date(Index: Integer; const ATXSDateTime: TXSDateTime);
begin
  Fend_date := ATXSDateTime;
  Fend_date_Specified := True;
end;

function Classifier.end_date_Specified(Index: Integer): boolean;
begin
  Result := Fend_date_Specified;
end;

procedure Classifier.Setparents(Index: Integer; const AClassifierList: ClassifierList);
begin
  Fparents := AClassifierList;
  Fparents_Specified := True;
end;

function Classifier.parents_Specified(Index: Integer): boolean;
begin
  Result := Fparents_Specified;
end;

destructor Document.Destroy;
begin
  FreeAndNil(Faccess);
  FreeAndNil(Fdocument_type);
  FreeAndNil(Fauthority);
  FreeAndNil(Fdate_of_issue);
  FreeAndNil(Fexpire_date);
  FreeAndNil(Fact_data);
  inherited Destroy;
end;

procedure Document.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function Document.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure Document.Setdocument_type(Index: Integer; const AClassifier: Classifier);
begin
  Fdocument_type := AClassifier;
  Fdocument_type_Specified := True;
end;

function Document.document_type_Specified(Index: Integer): boolean;
begin
  Result := Fdocument_type_Specified;
end;

procedure Document.Setauthority(Index: Integer; const AClassifier: Classifier);
begin
  Fauthority := AClassifier;
  Fauthority_Specified := True;
end;

function Document.authority_Specified(Index: Integer): boolean;
begin
  Result := Fauthority_Specified;
end;

procedure Document.Setdate_of_issue(Index: Integer; const ATXSDate: TXSDate);
begin
  Fdate_of_issue := ATXSDate;
  Fdate_of_issue_Specified := True;
end;

function Document.date_of_issue_Specified(Index: Integer): boolean;
begin
  Result := Fdate_of_issue_Specified;
end;

procedure Document.Setexpire_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Fexpire_date := ATXSDate;
  Fexpire_date_Specified := True;
end;

function Document.expire_date_Specified(Index: Integer): boolean;
begin
  Result := Fexpire_date_Specified;
end;

procedure Document.Setseries(Index: Integer; const AWideString: WideString);
begin
  Fseries := AWideString;
  Fseries_Specified := True;
end;

function Document.series_Specified(Index: Integer): boolean;
begin
  Result := Fseries_Specified;
end;

procedure Document.Setnumber(Index: Integer; const AWideString: WideString);
begin
  Fnumber := AWideString;
  Fnumber_Specified := True;
end;

function Document.number_Specified(Index: Integer): boolean;
begin
  Result := Fnumber_Specified;
end;

procedure Document.Setact_data(Index: Integer; const AActData: ActData);
begin
  Fact_data := AActData;
  Fact_data_Specified := True;
end;

function Document.act_data_Specified(Index: Integer): boolean;
begin
  Result := Fact_data_Specified;
end;

procedure Document.Setactive(Index: Integer; const ABoolean: Boolean);
begin
  Factive := ABoolean;
  Factive_Specified := True;
end;

function Document.active_Specified(Index: Integer): boolean;
begin
  Result := Factive_Specified;
end;

destructor ActData.Destroy;
begin
  FreeAndNil(Fact_type);
  FreeAndNil(Fauthority);
  FreeAndNil(Fdate);
  inherited Destroy;
end;

procedure ActData.Setact_type(Index: Integer; const AClassifier: Classifier);
begin
  Fact_type := AClassifier;
  Fact_type_Specified := True;
end;

function ActData.act_type_Specified(Index: Integer): boolean;
begin
  Result := Fact_type_Specified;
end;

procedure ActData.Setauthority(Index: Integer; const AClassifier: Classifier);
begin
  Fauthority := AClassifier;
  Fauthority_Specified := True;
end;

function ActData.authority_Specified(Index: Integer): boolean;
begin
  Result := Fauthority_Specified;
end;

procedure ActData.Setdate(Index: Integer; const ATXSDate: TXSDate);
begin
  Fdate := ATXSDate;
  Fdate_Specified := True;
end;

function ActData.date_Specified(Index: Integer): boolean;
begin
  Result := Fdate_Specified;
end;

procedure ActData.Setnumber(Index: Integer; const AWideString: WideString);
begin
  Fnumber := AWideString;
  Fnumber_Specified := True;
end;

function ActData.number_Specified(Index: Integer): boolean;
begin
  Result := Fnumber_Specified;
end;

destructor birth_place.Destroy;
begin
  FreeAndNil(Fcountry_b);
  FreeAndNil(Ftype_city_b);
  FreeAndNil(Fcity_b_ate);
  inherited Destroy;
end;

procedure birth_place.Setcountry_b(Index: Integer; const AClassifier: Classifier);
begin
  Fcountry_b := AClassifier;
  Fcountry_b_Specified := True;
end;

function birth_place.country_b_Specified(Index: Integer): boolean;
begin
  Result := Fcountry_b_Specified;
end;

procedure birth_place.Setarea_b(Index: Integer; const AWideString: WideString);
begin
  Farea_b := AWideString;
  Farea_b_Specified := True;
end;

function birth_place.area_b_Specified(Index: Integer): boolean;
begin
  Result := Farea_b_Specified;
end;

procedure birth_place.Setarea_b_bel(Index: Integer; const AWideString: WideString);
begin
  Farea_b_bel := AWideString;
  Farea_b_bel_Specified := True;
end;

function birth_place.area_b_bel_Specified(Index: Integer): boolean;
begin
  Result := Farea_b_bel_Specified;
end;

procedure birth_place.Setregion_b(Index: Integer; const AWideString: WideString);
begin
  Fregion_b := AWideString;
  Fregion_b_Specified := True;
end;

function birth_place.region_b_Specified(Index: Integer): boolean;
begin
  Result := Fregion_b_Specified;
end;

procedure birth_place.Setregion_b_bel(Index: Integer; const AWideString: WideString);
begin
  Fregion_b_bel := AWideString;
  Fregion_b_bel_Specified := True;
end;

function birth_place.region_b_bel_Specified(Index: Integer): boolean;
begin
  Result := Fregion_b_bel_Specified;
end;

procedure birth_place.Settype_city_b(Index: Integer; const AClassifier: Classifier);
begin
  Ftype_city_b := AClassifier;
  Ftype_city_b_Specified := True;
end;

function birth_place.type_city_b_Specified(Index: Integer): boolean;
begin
  Result := Ftype_city_b_Specified;
end;

procedure birth_place.Setcity_b(Index: Integer; const AWideString: WideString);
begin
  Fcity_b := AWideString;
  Fcity_b_Specified := True;
end;

function birth_place.city_b_Specified(Index: Integer): boolean;
begin
  Result := Fcity_b_Specified;
end;

procedure birth_place.Setcity_b_bel(Index: Integer; const AWideString: WideString);
begin
  Fcity_b_bel := AWideString;
  Fcity_b_bel_Specified := True;
end;

function birth_place.city_b_bel_Specified(Index: Integer): boolean;
begin
  Result := Fcity_b_bel_Specified;
end;

procedure birth_place.Setcity_b_ate(Index: Integer; const AClassifier: Classifier);
begin
  Fcity_b_ate := AClassifier;
  Fcity_b_ate_Specified := True;
end;

function birth_place.city_b_ate_Specified(Index: Integer): boolean;
begin
  Result := Fcity_b_ate_Specified;
end;

destructor Citizenship.Destroy;
begin
  FreeAndNil(Faccess);
  FreeAndNil(Fcitizenship_change);
  FreeAndNil(Fcitizenship_type);
  FreeAndNil(Fdate_citizenship);
  inherited Destroy;
end;

procedure Citizenship.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function Citizenship.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure Citizenship.Setcitizenship_change(Index: Integer; const AClassifier: Classifier);
begin
  Fcitizenship_change := AClassifier;
  Fcitizenship_change_Specified := True;
end;

function Citizenship.citizenship_change_Specified(Index: Integer): boolean;
begin
  Result := Fcitizenship_change_Specified;
end;

procedure Citizenship.Setcitizenship_type(Index: Integer; const AClassifier: Classifier);
begin
  Fcitizenship_type := AClassifier;
  Fcitizenship_type_Specified := True;
end;

function Citizenship.citizenship_type_Specified(Index: Integer): boolean;
begin
  Result := Fcitizenship_type_Specified;
end;

procedure Citizenship.Setdate_citizenship(Index: Integer; const ATXSDateTime: TXSDateTime);
begin
  Fdate_citizenship := ATXSDateTime;
  Fdate_citizenship_Specified := True;
end;

function Citizenship.date_citizenship_Specified(Index: Integer): boolean;
begin
  Result := Fdate_citizenship_Specified;
end;

procedure Citizenship.Setactive(Index: Integer; const ABoolean: Boolean);
begin
  Factive := ABoolean;
  Factive_Specified := True;
end;

function Citizenship.active_Specified(Index: Integer): boolean;
begin
  Result := Factive_Specified;
end;

destructor photoInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  inherited Destroy;
end;

procedure photoInfo.Setphoto(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Fphoto := ATByteDynArray;
  Fphoto_Specified := True;
end;

function photoInfo.photo_Specified(Index: Integer): boolean;
begin
  Result := Fphoto_Specified;
end;

procedure photoInfo.Setdocuments(Index: Integer; const Adocuments: documents);
begin
  Fdocuments := Adocuments;
  Fdocuments_Specified := True;
end;

function photoInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor Nationality2.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Faccess);
  FreeAndNil(Fnationality);
  inherited Destroy;
end;

procedure Nationality2.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function Nationality2.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure Nationality2.Setnationality(Index: Integer; const AClassifier: Classifier);
begin
  Fnationality := AClassifier;
  Fnationality_Specified := True;
end;

function Nationality2.nationality_Specified(Index: Integer): boolean;
begin
  Result := Fnationality_Specified;
end;

procedure Nationality2.Setdocuments(Index: Integer; const Adocuments2: documents2);
begin
  Fdocuments := Adocuments2;
  Fdocuments_Specified := True;
end;

function Nationality2.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

procedure Nationality2.Setactive(Index: Integer; const ABoolean: Boolean);
begin
  Factive := ABoolean;
  Factive_Specified := True;
end;

function Nationality2.active_Specified(Index: Integer): boolean;
begin
  Result := Factive_Specified;
end;

destructor Address.Destroy;
begin
  FreeAndNil(Faccess);
  FreeAndNil(Fcountry);
  FreeAndNil(Farea);
  FreeAndNil(Fregion);
  FreeAndNil(Fsoviet);
  FreeAndNil(Flocality_type);
  FreeAndNil(Flocality);
  FreeAndNil(Fcity_region);
  FreeAndNil(Fstreet_type);
  FreeAndNil(Fstreet);
  FreeAndNil(Freg_date);
  FreeAndNil(Freg_date_till);
  FreeAndNil(FaddrNum);
  inherited Destroy;
end;

procedure Address.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function Address.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure Address.Setcountry(Index: Integer; const AClassifier: Classifier);
begin
  Fcountry := AClassifier;
  Fcountry_Specified := True;
end;

function Address.country_Specified(Index: Integer): boolean;
begin
  Result := Fcountry_Specified;
end;

procedure Address.Setarea(Index: Integer; const AClassifier: Classifier);
begin
  Farea := AClassifier;
  Farea_Specified := True;
end;

function Address.area_Specified(Index: Integer): boolean;
begin
  Result := Farea_Specified;
end;

procedure Address.Setregion(Index: Integer; const AClassifier: Classifier);
begin
  Fregion := AClassifier;
  Fregion_Specified := True;
end;

function Address.region_Specified(Index: Integer): boolean;
begin
  Result := Fregion_Specified;
end;

procedure Address.Setsoviet(Index: Integer; const AClassifier: Classifier);
begin
  Fsoviet := AClassifier;
  Fsoviet_Specified := True;
end;

function Address.soviet_Specified(Index: Integer): boolean;
begin
  Result := Fsoviet_Specified;
end;

procedure Address.Setlocality_type(Index: Integer; const AClassifier: Classifier);
begin
  Flocality_type := AClassifier;
  Flocality_type_Specified := True;
end;

function Address.locality_type_Specified(Index: Integer): boolean;
begin
  Result := Flocality_type_Specified;
end;

procedure Address.Setlocality(Index: Integer; const AClassifier: Classifier);
begin
  Flocality := AClassifier;
  Flocality_Specified := True;
end;

function Address.locality_Specified(Index: Integer): boolean;
begin
  Result := Flocality_Specified;
end;

procedure Address.Setcity_region(Index: Integer; const AClassifier: Classifier);
begin
  Fcity_region := AClassifier;
  Fcity_region_Specified := True;
end;

function Address.city_region_Specified(Index: Integer): boolean;
begin
  Result := Fcity_region_Specified;
end;

procedure Address.Setstreet_type(Index: Integer; const AClassifier: Classifier);
begin
  Fstreet_type := AClassifier;
  Fstreet_type_Specified := True;
end;

function Address.street_type_Specified(Index: Integer): boolean;
begin
  Result := Fstreet_type_Specified;
end;

procedure Address.Setstreet(Index: Integer; const AClassifier: Classifier);
begin
  Fstreet := AClassifier;
  Fstreet_Specified := True;
end;

function Address.street_Specified(Index: Integer): boolean;
begin
  Result := Fstreet_Specified;
end;

procedure Address.Sethouse(Index: Integer; const AWideString: WideString);
begin
  Fhouse := AWideString;
  Fhouse_Specified := True;
end;

function Address.house_Specified(Index: Integer): boolean;
begin
  Result := Fhouse_Specified;
end;

procedure Address.Setbuilding(Index: Integer; const AWideString: WideString);
begin
  Fbuilding := AWideString;
  Fbuilding_Specified := True;
end;

function Address.building_Specified(Index: Integer): boolean;
begin
  Result := Fbuilding_Specified;
end;

procedure Address.Setflat(Index: Integer; const AWideString: WideString);
begin
  Fflat := AWideString;
  Fflat_Specified := True;
end;

function Address.flat_Specified(Index: Integer): boolean;
begin
  Result := Fflat_Specified;
end;

procedure Address.Setreg_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Freg_date := ATXSDate;
  Freg_date_Specified := True;
end;

function Address.reg_date_Specified(Index: Integer): boolean;
begin
  Result := Freg_date_Specified;
end;

procedure Address.Setreg_date_till(Index: Integer; const ATXSDate: TXSDate);
begin
  Freg_date_till := ATXSDate;
  Freg_date_till_Specified := True;
end;

function Address.reg_date_till_Specified(Index: Integer): boolean;
begin
  Result := Freg_date_till_Specified;
end;

procedure Address.Setsign_away(Index: Integer; const ABoolean: Boolean);
begin
  Fsign_away := ABoolean;
  Fsign_away_Specified := True;
end;

function Address.sign_away_Specified(Index: Integer): boolean;
begin
  Result := Fsign_away_Specified;
end;

procedure Address.SetaddrNum(Index: Integer; const ATXSDecimal: TXSDecimal);
begin
  FaddrNum := ATXSDecimal;
  FaddrNum_Specified := True;
end;

function Address.addrNum_Specified(Index: Integer): boolean;
begin
  Result := FaddrNum_Specified;
end;

procedure Address.SetateAddress(Index: Integer; const AWideString: WideString);
begin
  FateAddress := AWideString;
  FateAddress_Specified := True;
end;

function Address.ateAddress_Specified(Index: Integer): boolean;
begin
  Result := FateAddress_Specified;
end;

procedure Address.Setactive(Index: Integer; const ABoolean: Boolean);
begin
  Factive := ABoolean;
  Factive_Specified := True;
end;

function Address.active_Specified(Index: Integer): boolean;
begin
  Result := Factive_Specified;
end;

destructor Death.Destroy;
begin
  FreeAndNil(Faccess);
  FreeAndNil(Fdeath_cause);
  FreeAndNil(Fdecease_place);
  inherited Destroy;
end;

procedure Death.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function Death.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure Death.Setdeath_cause(Index: Integer; const AClassifier: Classifier);
begin
  Fdeath_cause := AClassifier;
  Fdeath_cause_Specified := True;
end;

function Death.death_cause_Specified(Index: Integer): boolean;
begin
  Result := Fdeath_cause_Specified;
end;

procedure Death.Setdeath_date(Index: Integer; const AWideString: WideString);
begin
  Fdeath_date := AWideString;
  Fdeath_date_Specified := True;
end;

function Death.death_date_Specified(Index: Integer): boolean;
begin
  Result := Fdeath_date_Specified;
end;

procedure Death.Setdecease_place(Index: Integer; const Adecease_place: decease_place);
begin
  Fdecease_place := Adecease_place;
  Fdecease_place_Specified := True;
end;

function Death.decease_place_Specified(Index: Integer): boolean;
begin
  Result := Fdecease_place_Specified;
end;

procedure Death.Setdeath_place(Index: Integer; const AWideString: WideString);
begin
  Fdeath_place := AWideString;
  Fdeath_place_Specified := True;
end;

function Death.death_place_Specified(Index: Integer): boolean;
begin
  Result := Fdeath_place_Specified;
end;

procedure Death.Setburial_place(Index: Integer; const AWideString: WideString);
begin
  Fburial_place := AWideString;
  Fburial_place_Specified := True;
end;

function Death.burial_place_Specified(Index: Integer): boolean;
begin
  Result := Fburial_place_Specified;
end;

procedure Death.Setactive(Index: Integer; const ABoolean: Boolean);
begin
  Factive := ABoolean;
  Factive_Specified := True;
end;

function Death.active_Specified(Index: Integer): boolean;
begin
  Result := Factive_Specified;
end;

destructor deathInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Fdeath_data);
  inherited Destroy;
end;

procedure deathInfo.Setdeath_data(Index: Integer; const ADeath: Death);
begin
  Fdeath_data := ADeath;
  Fdeath_data_Specified := True;
end;

function deathInfo.death_data_Specified(Index: Integer): boolean;
begin
  Result := Fdeath_data_Specified;
end;

procedure deathInfo.Setdocuments(Index: Integer; const Adocuments3: documents3);
begin
  Fdocuments := Adocuments3;
  Fdocuments_Specified := True;
end;

function deathInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor decease_place.Destroy;
begin
  FreeAndNil(Fcountry_d);
  FreeAndNil(Ftype_city_d);
  inherited Destroy;
end;

procedure decease_place.Setcountry_d(Index: Integer; const AClassifier: Classifier);
begin
  Fcountry_d := AClassifier;
  Fcountry_d_Specified := True;
end;

function decease_place.country_d_Specified(Index: Integer): boolean;
begin
  Result := Fcountry_d_Specified;
end;

procedure decease_place.Setarea_d(Index: Integer; const AWideString: WideString);
begin
  Farea_d := AWideString;
  Farea_d_Specified := True;
end;

function decease_place.area_d_Specified(Index: Integer): boolean;
begin
  Result := Farea_d_Specified;
end;

procedure decease_place.Setarea_d_bel(Index: Integer; const AWideString: WideString);
begin
  Farea_d_bel := AWideString;
  Farea_d_bel_Specified := True;
end;

function decease_place.area_d_bel_Specified(Index: Integer): boolean;
begin
  Result := Farea_d_bel_Specified;
end;

procedure decease_place.Setregion_d(Index: Integer; const AWideString: WideString);
begin
  Fregion_d := AWideString;
  Fregion_d_Specified := True;
end;

function decease_place.region_d_Specified(Index: Integer): boolean;
begin
  Result := Fregion_d_Specified;
end;

procedure decease_place.Setregion_d_bel(Index: Integer; const AWideString: WideString);
begin
  Fregion_d_bel := AWideString;
  Fregion_d_bel_Specified := True;
end;

function decease_place.region_d_bel_Specified(Index: Integer): boolean;
begin
  Result := Fregion_d_bel_Specified;
end;

procedure decease_place.Settype_city_d(Index: Integer; const AClassifier: Classifier);
begin
  Ftype_city_d := AClassifier;
  Ftype_city_d_Specified := True;
end;

function decease_place.type_city_d_Specified(Index: Integer): boolean;
begin
  Result := Ftype_city_d_Specified;
end;

procedure decease_place.Setcity_d(Index: Integer; const AWideString: WideString);
begin
  Fcity_d := AWideString;
  Fcity_d_Specified := True;
end;

function decease_place.city_d_Specified(Index: Integer): boolean;
begin
  Result := Fcity_d_Specified;
end;

procedure decease_place.Setcity_d_bel(Index: Integer; const AWideString: WideString);
begin
  Fcity_d_bel := AWideString;
  Fcity_d_bel_Specified := True;
end;

function decease_place.city_d_bel_Specified(Index: Integer): boolean;
begin
  Result := Fcity_d_bel_Specified;
end;

destructor burialData.Destroy;
begin
  FreeAndNil(Faccess);
  FreeAndNil(Fcountry);
  FreeAndNil(Farea);
  FreeAndNil(Fregion);
  FreeAndNil(Fsoviet);
  FreeAndNil(Fcity);
  FreeAndNil(Fburial_name);
  inherited Destroy;
end;

procedure burialData.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function burialData.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure burialData.Setcountry(Index: Integer; const AClassifier: Classifier);
begin
  Fcountry := AClassifier;
  Fcountry_Specified := True;
end;

function burialData.country_Specified(Index: Integer): boolean;
begin
  Result := Fcountry_Specified;
end;

procedure burialData.Setarea(Index: Integer; const AClassifier: Classifier);
begin
  Farea := AClassifier;
  Farea_Specified := True;
end;

function burialData.area_Specified(Index: Integer): boolean;
begin
  Result := Farea_Specified;
end;

procedure burialData.Setregion(Index: Integer; const AClassifier: Classifier);
begin
  Fregion := AClassifier;
  Fregion_Specified := True;
end;

function burialData.region_Specified(Index: Integer): boolean;
begin
  Result := Fregion_Specified;
end;

procedure burialData.Setsoviet(Index: Integer; const AClassifier: Classifier);
begin
  Fsoviet := AClassifier;
  Fsoviet_Specified := True;
end;

function burialData.soviet_Specified(Index: Integer): boolean;
begin
  Result := Fsoviet_Specified;
end;

procedure burialData.Setcity(Index: Integer; const AClassifier: Classifier);
begin
  Fcity := AClassifier;
  Fcity_Specified := True;
end;

function burialData.city_Specified(Index: Integer): boolean;
begin
  Result := Fcity_Specified;
end;

procedure burialData.Setburial_name(Index: Integer; const AClassifier: Classifier);
begin
  Fburial_name := AClassifier;
  Fburial_name_Specified := True;
end;

function burialData.burial_name_Specified(Index: Integer): boolean;
begin
  Result := Fburial_name_Specified;
end;

procedure burialData.Setsector(Index: Integer; const AWideString: WideString);
begin
  Fsector := AWideString;
  Fsector_Specified := True;
end;

function burialData.sector_Specified(Index: Integer): boolean;
begin
  Result := Fsector_Specified;
end;

procedure burialData.Setrow(Index: Integer; const AWideString: WideString);
begin
  Frow := AWideString;
  Frow_Specified := True;
end;

function burialData.row_Specified(Index: Integer): boolean;
begin
  Result := Frow_Specified;
end;

procedure burialData.Setplace(Index: Integer; const AWideString: WideString);
begin
  Fplace := AWideString;
  Fplace_Specified := True;
end;

function burialData.place_Specified(Index: Integer): boolean;
begin
  Result := Fplace_Specified;
end;

procedure burialData.Setgrave(Index: Integer; const AWideString: WideString);
begin
  Fgrave := AWideString;
  Fgrave_Specified := True;
end;

function burialData.grave_Specified(Index: Integer): boolean;
begin
  Result := Fgrave_Specified;
end;

procedure burialData.Setvault(Index: Integer; const AWideString: WideString);
begin
  Fvault := AWideString;
  Fvault_Specified := True;
end;

function burialData.vault_Specified(Index: Integer): boolean;
begin
  Result := Fvault_Specified;
end;

procedure burialData.Setwall_section(Index: Integer; const AWideString: WideString);
begin
  Fwall_section := AWideString;
  Fwall_section_Specified := True;
end;

function burialData.wall_section_Specified(Index: Integer): boolean;
begin
  Result := Fwall_section_Specified;
end;

procedure burialData.Setwall_box(Index: Integer; const AWideString: WideString);
begin
  Fwall_box := AWideString;
  Fwall_box_Specified := True;
end;

function burialData.wall_box_Specified(Index: Integer): boolean;
begin
  Result := Fwall_box_Specified;
end;

destructor burialDataInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Fburial_data);
  inherited Destroy;
end;

procedure burialDataInfo.Setburial_data(Index: Integer; const AburialData: burialData);
begin
  Fburial_data := AburialData;
  Fburial_data_Specified := True;
end;

function burialDataInfo.burial_data_Specified(Index: Integer): boolean;
begin
  Result := Fburial_data_Specified;
end;

procedure burialDataInfo.Setdocuments(Index: Integer; const Adocuments4: documents4);
begin
  Fdocuments := Adocuments4;
  Fdocuments_Specified := True;
end;

function burialDataInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor guardianshipInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Fguardian);
  FreeAndNil(Festablish_guardianship_date);
  FreeAndNil(Ftermination_guardianship_date);
  FreeAndNil(Fremove_guardian_date);
  FreeAndNil(Frelease_guardian_date);
  inherited Destroy;
end;

procedure guardianshipInfo.Setguardian(Index: Integer; const APersonalData: PersonalData);
begin
  Fguardian := APersonalData;
  Fguardian_Specified := True;
end;

function guardianshipInfo.guardian_Specified(Index: Integer): boolean;
begin
  Result := Fguardian_Specified;
end;

procedure guardianshipInfo.Setestablish_guardianship_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Festablish_guardianship_date := ATXSDate;
  Festablish_guardianship_date_Specified := True;
end;

function guardianshipInfo.establish_guardianship_date_Specified(Index: Integer): boolean;
begin
  Result := Festablish_guardianship_date_Specified;
end;

procedure guardianshipInfo.Settermination_guardianship_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Ftermination_guardianship_date := ATXSDate;
  Ftermination_guardianship_date_Specified := True;
end;

function guardianshipInfo.termination_guardianship_date_Specified(Index: Integer): boolean;
begin
  Result := Ftermination_guardianship_date_Specified;
end;

procedure guardianshipInfo.Setremove_guardian_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Fremove_guardian_date := ATXSDate;
  Fremove_guardian_date_Specified := True;
end;

function guardianshipInfo.remove_guardian_date_Specified(Index: Integer): boolean;
begin
  Result := Fremove_guardian_date_Specified;
end;

procedure guardianshipInfo.Setrelease_guardian_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Frelease_guardian_date := ATXSDate;
  Frelease_guardian_date_Specified := True;
end;

function guardianshipInfo.release_guardian_date_Specified(Index: Integer): boolean;
begin
  Result := Frelease_guardian_date_Specified;
end;

procedure guardianshipInfo.Setdocuments(Index: Integer; const Adocuments5: documents5);
begin
  Fdocuments := Adocuments5;
  Fdocuments_Specified := True;
end;

function guardianshipInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor trusteeshipInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Ftrustee);
  FreeAndNil(Festablish_trusteeship_date);
  FreeAndNil(Ftermination_trusteeship_date);
  FreeAndNil(Fremove_trustee_date);
  FreeAndNil(Frelease_trustee_date);
  inherited Destroy;
end;

procedure trusteeshipInfo.Settrustee(Index: Integer; const APersonalData: PersonalData);
begin
  Ftrustee := APersonalData;
  Ftrustee_Specified := True;
end;

function trusteeshipInfo.trustee_Specified(Index: Integer): boolean;
begin
  Result := Ftrustee_Specified;
end;

procedure trusteeshipInfo.Setestablish_trusteeship_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Festablish_trusteeship_date := ATXSDate;
  Festablish_trusteeship_date_Specified := True;
end;

function trusteeshipInfo.establish_trusteeship_date_Specified(Index: Integer): boolean;
begin
  Result := Festablish_trusteeship_date_Specified;
end;

procedure trusteeshipInfo.Settermination_trusteeship_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Ftermination_trusteeship_date := ATXSDate;
  Ftermination_trusteeship_date_Specified := True;
end;

function trusteeshipInfo.termination_trusteeship_date_Specified(Index: Integer): boolean;
begin
  Result := Ftermination_trusteeship_date_Specified;
end;

procedure trusteeshipInfo.Setremove_trustee_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Fremove_trustee_date := ATXSDate;
  Fremove_trustee_date_Specified := True;
end;

function trusteeshipInfo.remove_trustee_date_Specified(Index: Integer): boolean;
begin
  Result := Fremove_trustee_date_Specified;
end;

procedure trusteeshipInfo.Setrelease_trustee_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Frelease_trustee_date := ATXSDate;
  Frelease_trustee_date_Specified := True;
end;

function trusteeshipInfo.release_trustee_date_Specified(Index: Integer): boolean;
begin
  Result := Frelease_trustee_date_Specified;
end;

procedure trusteeshipInfo.Setdocuments(Index: Integer; const Adocuments6: documents6);
begin
  Fdocuments := Adocuments6;
  Fdocuments_Specified := True;
end;

function trusteeshipInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor parentRightsInfo.Destroy;
begin
  FreeAndNil(Fdeprivation_prnt_rights_date);
  FreeAndNil(Freturn_prnt_rights_date);
  FreeAndNil(Fchild_data);
  inherited Destroy;
end;

procedure parentRightsInfo.Setdeprivation_prnt_rights_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Fdeprivation_prnt_rights_date := ATXSDate;
  Fdeprivation_prnt_rights_date_Specified := True;
end;

function parentRightsInfo.deprivation_prnt_rights_date_Specified(Index: Integer): boolean;
begin
  Result := Fdeprivation_prnt_rights_date_Specified;
end;

procedure parentRightsInfo.Setreturn_prnt_rights_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Freturn_prnt_rights_date := ATXSDate;
  Freturn_prnt_rights_date_Specified := True;
end;

function parentRightsInfo.return_prnt_rights_date_Specified(Index: Integer): boolean;
begin
  Result := Freturn_prnt_rights_date_Specified;
end;

procedure parentRightsInfo.Setchild_data(Index: Integer; const APersonalData: PersonalData);
begin
  Fchild_data := APersonalData;
  Fchild_data_Specified := True;
end;

function parentRightsInfo.child_data_Specified(Index: Integer): boolean;
begin
  Result := Fchild_data_Specified;
end;

destructor familyInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Fperson_data);
  FreeAndNil(Fprnt_rights_info);
  inherited Destroy;
end;

procedure familyInfo.Setperson_data(Index: Integer; const APersonalData: PersonalData);
begin
  Fperson_data := APersonalData;
  Fperson_data_Specified := True;
end;

function familyInfo.person_data_Specified(Index: Integer): boolean;
begin
  Result := Fperson_data_Specified;
end;

procedure familyInfo.Setprnt_rights_info(Index: Integer; const AparentRightsInfo: parentRightsInfo);
begin
  Fprnt_rights_info := AparentRightsInfo;
  Fprnt_rights_info_Specified := True;
end;

function familyInfo.prnt_rights_info_Specified(Index: Integer): boolean;
begin
  Result := Fprnt_rights_info_Specified;
end;

procedure familyInfo.Setdocuments(Index: Integer; const Adocuments7: documents7);
begin
  Fdocuments := Adocuments7;
  Fdocuments_Specified := True;
end;

function familyInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor martialStatus.Destroy;
begin
  FreeAndNil(Fdate);
  FreeAndNil(Fregion);
  FreeAndNil(Fdvc_date);
  FreeAndNil(Fdvc_region);
  FreeAndNil(Finvalid_mrg_date);
  FreeAndNil(Finvalid_mrg_region);
  inherited Destroy;
end;

procedure martialStatus.Setdate(Index: Integer; const ATXSDate: TXSDate);
begin
  Fdate := ATXSDate;
  Fdate_Specified := True;
end;

function martialStatus.date_Specified(Index: Integer): boolean;
begin
  Result := Fdate_Specified;
end;

procedure martialStatus.Setregion(Index: Integer; const AClassifier: Classifier);
begin
  Fregion := AClassifier;
  Fregion_Specified := True;
end;

function martialStatus.region_Specified(Index: Integer): boolean;
begin
  Result := Fregion_Specified;
end;

procedure martialStatus.Setdvc_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Fdvc_date := ATXSDate;
  Fdvc_date_Specified := True;
end;

function martialStatus.dvc_date_Specified(Index: Integer): boolean;
begin
  Result := Fdvc_date_Specified;
end;

procedure martialStatus.Setdvc_region(Index: Integer; const AClassifier: Classifier);
begin
  Fdvc_region := AClassifier;
  Fdvc_region_Specified := True;
end;

function martialStatus.dvc_region_Specified(Index: Integer): boolean;
begin
  Result := Fdvc_region_Specified;
end;

procedure martialStatus.Setinvalid_mrg_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Finvalid_mrg_date := ATXSDate;
  Finvalid_mrg_date_Specified := True;
end;

function martialStatus.invalid_mrg_date_Specified(Index: Integer): boolean;
begin
  Result := Finvalid_mrg_date_Specified;
end;

procedure martialStatus.Setinvalid_mrg_region(Index: Integer; const AClassifier: Classifier);
begin
  Finvalid_mrg_region := AClassifier;
  Finvalid_mrg_region_Specified := True;
end;

function martialStatus.invalid_mrg_region_Specified(Index: Integer): boolean;
begin
  Result := Finvalid_mrg_region_Specified;
end;

destructor martialStatusInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Fcert_data);
  inherited Destroy;
end;

procedure martialStatusInfo.Setcert_data(Index: Integer; const AmartialStatus: martialStatus);
begin
  Fcert_data := AmartialStatus;
  Fcert_data_Specified := True;
end;

function martialStatusInfo.cert_data_Specified(Index: Integer): boolean;
begin
  Result := Fcert_data_Specified;
end;

procedure martialStatusInfo.Setdocuments(Index: Integer; const Adocuments8: documents8);
begin
  Fdocuments := Adocuments8;
  Fdocuments_Specified := True;
end;

function martialStatusInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor parentRightsData.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Fprnt_rights_info);
  inherited Destroy;
end;

procedure parentRightsData.Setprnt_rights_info(Index: Integer; const AparentRightsInfo: parentRightsInfo);
begin
  Fprnt_rights_info := AparentRightsInfo;
  Fprnt_rights_info_Specified := True;
end;

function parentRightsData.prnt_rights_info_Specified(Index: Integer): boolean;
begin
  Result := Fprnt_rights_info_Specified;
end;

procedure parentRightsData.Setdocuments(Index: Integer; const Adocuments9: documents9);
begin
  Fdocuments := Adocuments9;
  Fdocuments_Specified := True;
end;

function parentRightsData.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor educationInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Feducation_data);
  inherited Destroy;
end;

procedure educationInfo.Seteducation_data(Index: Integer; const AEducation: Education);
begin
  Feducation_data := AEducation;
  Feducation_data_Specified := True;
end;

function educationInfo.education_data_Specified(Index: Integer): boolean;
begin
  Result := Feducation_data_Specified;
end;

procedure educationInfo.Setdocuments(Index: Integer; const Adocuments10: documents10);
begin
  Fdocuments := Adocuments10;
  Fdocuments_Specified := True;
end;

function educationInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor Education.Destroy;
begin
  FreeAndNil(Faccess);
  FreeAndNil(Feducation_specialization);
  FreeAndNil(Feducation_department);
  FreeAndNil(Feducation_begin_data);
  FreeAndNil(Feducation_end_data);
  inherited Destroy;
end;

procedure Education.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function Education.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure Education.Seteducation_specialization(Index: Integer; const AClassifier: Classifier);
begin
  Feducation_specialization := AClassifier;
  Feducation_specialization_Specified := True;
end;

function Education.education_specialization_Specified(Index: Integer): boolean;
begin
  Result := Feducation_specialization_Specified;
end;

procedure Education.Seteducation_department(Index: Integer; const AClassifier: Classifier);
begin
  Feducation_department := AClassifier;
  Feducation_department_Specified := True;
end;

function Education.education_department_Specified(Index: Integer): boolean;
begin
  Result := Feducation_department_Specified;
end;

procedure Education.Seteducation_begin_data(Index: Integer; const ATXSDate: TXSDate);
begin
  Feducation_begin_data := ATXSDate;
  Feducation_begin_data_Specified := True;
end;

function Education.education_begin_data_Specified(Index: Integer): boolean;
begin
  Result := Feducation_begin_data_Specified;
end;

procedure Education.Seteducation_end_data(Index: Integer; const ATXSDate: TXSDate);
begin
  Feducation_end_data := ATXSDate;
  Feducation_end_data_Specified := True;
end;

function Education.education_end_data_Specified(Index: Integer): boolean;
begin
  Result := Feducation_end_data_Specified;
end;

procedure Education.Seteducation_record_number(Index: Integer; const AInt64: Int64);
begin
  Feducation_record_number := AInt64;
  Feducation_record_number_Specified := True;
end;

function Education.education_record_number_Specified(Index: Integer): boolean;
begin
  Result := Feducation_record_number_Specified;
end;

procedure Education.Setactive(Index: Integer; const ABoolean: Boolean);
begin
  Factive := ABoolean;
  Factive_Specified := True;
end;

function Education.active_Specified(Index: Integer): boolean;
begin
  Result := Factive_Specified;
end;

destructor ScienceRank.Destroy;
begin
  FreeAndNil(Faccess);
  FreeAndNil(Fscience_rank);
  FreeAndNil(Fscience_rank_date);
  inherited Destroy;
end;

procedure ScienceRank.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function ScienceRank.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure ScienceRank.Setscience_rank(Index: Integer; const AClassifier: Classifier);
begin
  Fscience_rank := AClassifier;
  Fscience_rank_Specified := True;
end;

function ScienceRank.science_rank_Specified(Index: Integer): boolean;
begin
  Result := Fscience_rank_Specified;
end;

procedure ScienceRank.Setscience_rank_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Fscience_rank_date := ATXSDate;
  Fscience_rank_date_Specified := True;
end;

function ScienceRank.science_rank_date_Specified(Index: Integer): boolean;
begin
  Result := Fscience_rank_date_Specified;
end;

procedure ScienceRank.Setscience_rank_number(Index: Integer; const AWideString: WideString);
begin
  Fscience_rank_number := AWideString;
  Fscience_rank_number_Specified := True;
end;

function ScienceRank.science_rank_number_Specified(Index: Integer): boolean;
begin
  Result := Fscience_rank_number_Specified;
end;

procedure ScienceRank.Setactive(Index: Integer; const ABoolean: Boolean);
begin
  Factive := ABoolean;
  Factive_Specified := True;
end;

function ScienceRank.active_Specified(Index: Integer): boolean;
begin
  Result := Factive_Specified;
end;

destructor scienceRankInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Fscience_rank_data);
  inherited Destroy;
end;

procedure scienceRankInfo.Setscience_rank_data(Index: Integer; const AScienceRank: ScienceRank);
begin
  Fscience_rank_data := AScienceRank;
  Fscience_rank_data_Specified := True;
end;

function scienceRankInfo.science_rank_data_Specified(Index: Integer): boolean;
begin
  Result := Fscience_rank_data_Specified;
end;

procedure scienceRankInfo.Setdocuments(Index: Integer; const Adocuments11: documents11);
begin
  Fdocuments := Adocuments11;
  Fdocuments_Specified := True;
end;

function scienceRankInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor ScienceDegree.Destroy;
begin
  FreeAndNil(Faccess);
  FreeAndNil(Fscience_degree);
  FreeAndNil(Fscience_degree_date);
  inherited Destroy;
end;

procedure ScienceDegree.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function ScienceDegree.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure ScienceDegree.Setscience_degree(Index: Integer; const AClassifier: Classifier);
begin
  Fscience_degree := AClassifier;
  Fscience_degree_Specified := True;
end;

function ScienceDegree.science_degree_Specified(Index: Integer): boolean;
begin
  Result := Fscience_degree_Specified;
end;

procedure ScienceDegree.Setscience_degree_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Fscience_degree_date := ATXSDate;
  Fscience_degree_date_Specified := True;
end;

function ScienceDegree.science_degree_date_Specified(Index: Integer): boolean;
begin
  Result := Fscience_degree_date_Specified;
end;

procedure ScienceDegree.Setscience_degree_number(Index: Integer; const AWideString: WideString);
begin
  Fscience_degree_number := AWideString;
  Fscience_degree_number_Specified := True;
end;

function ScienceDegree.science_degree_number_Specified(Index: Integer): boolean;
begin
  Result := Fscience_degree_number_Specified;
end;

procedure ScienceDegree.Setactive(Index: Integer; const ABoolean: Boolean);
begin
  Factive := ABoolean;
  Factive_Specified := True;
end;

function ScienceDegree.active_Specified(Index: Integer): boolean;
begin
  Result := Factive_Specified;
end;

destructor scienceDegreeInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Fscience_degree_data);
  inherited Destroy;
end;

procedure scienceDegreeInfo.Setscience_degree_data(Index: Integer; const AScienceDegree: ScienceDegree);
begin
  Fscience_degree_data := AScienceDegree;
  Fscience_degree_data_Specified := True;
end;

function scienceDegreeInfo.science_degree_data_Specified(Index: Integer): boolean;
begin
  Result := Fscience_degree_data_Specified;
end;

procedure scienceDegreeInfo.Setdocuments(Index: Integer; const Adocuments12: documents12);
begin
  Fdocuments := Adocuments12;
  Fdocuments_Specified := True;
end;

function scienceDegreeInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor employmentStatusInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Femployment_status_data);
  inherited Destroy;
end;

procedure employmentStatusInfo.Setemployment_status_data(Index: Integer; const AClassifier: Classifier);
begin
  Femployment_status_data := AClassifier;
  Femployment_status_data_Specified := True;
end;

function employmentStatusInfo.employment_status_data_Specified(Index: Integer): boolean;
begin
  Result := Femployment_status_data_Specified;
end;

procedure employmentStatusInfo.Setdocuments(Index: Integer; const Adocuments13: documents13);
begin
  Fdocuments := Adocuments13;
  Fdocuments_Specified := True;
end;

function employmentStatusInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor employmentInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Femployment_data);
  inherited Destroy;
end;

procedure employmentInfo.Setemployment_data(Index: Integer; const Afszn: fszn);
begin
  Femployment_data := Afszn;
  Femployment_data_Specified := True;
end;

function employmentInfo.employment_data_Specified(Index: Integer): boolean;
begin
  Result := Femployment_data_Specified;
end;

procedure employmentInfo.Setdocuments(Index: Integer; const Adocuments14: documents14);
begin
  Fdocuments := Adocuments14;
  Fdocuments_Specified := True;
end;

function employmentInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor fszn.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Femployment_periods)-1 do
    FreeAndNil(Femployment_periods[I]);
  SetLength(Femployment_periods, 0);
  FreeAndNil(Faccess);
  inherited Destroy;
end;

procedure fszn.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function fszn.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure fszn.Setemployment_organization(Index: Integer; const AWideString: WideString);
begin
  Femployment_organization := AWideString;
  Femployment_organization_Specified := True;
end;

function fszn.employment_organization_Specified(Index: Integer): boolean;
begin
  Result := Femployment_organization_Specified;
end;

procedure fszn.Setemployment_organization_name(Index: Integer; const AWideString: WideString);
begin
  Femployment_organization_name := AWideString;
  Femployment_organization_name_Specified := True;
end;

function fszn.employment_organization_name_Specified(Index: Integer): boolean;
begin
  Result := Femployment_organization_name_Specified;
end;

procedure fszn.Setemployment_periods(Index: Integer; const Aemployment_periods: employment_periods);
begin
  Femployment_periods := Aemployment_periods;
  Femployment_periods_Specified := True;
end;

function fszn.employment_periods_Specified(Index: Integer): boolean;
begin
  Result := Femployment_periods_Specified;
end;

procedure fszn.Setactive(Index: Integer; const AInteger: Integer);
begin
  Factive := AInteger;
  Factive_Specified := True;
end;

function fszn.active_Specified(Index: Integer): boolean;
begin
  Result := Factive_Specified;
end;

destructor employmentPeriod.Destroy;
begin
  FreeAndNil(Femployment_begin_date);
  FreeAndNil(Femployment_end_date);
  inherited Destroy;
end;

procedure employmentPeriod.Setemployment_begin_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Femployment_begin_date := ATXSDate;
  Femployment_begin_date_Specified := True;
end;

function employmentPeriod.employment_begin_date_Specified(Index: Integer): boolean;
begin
  Result := Femployment_begin_date_Specified;
end;

procedure employmentPeriod.Setemployment_end_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Femployment_end_date := ATXSDate;
  Femployment_end_date_Specified := True;
end;

function employmentPeriod.employment_end_date_Specified(Index: Integer): boolean;
begin
  Result := Femployment_end_date_Specified;
end;

destructor CourtList.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdeaths)-1 do
    FreeAndNil(Fdeaths[I]);
  SetLength(Fdeaths, 0);
  for I := 0 to Length(Fabsents)-1 do
    FreeAndNil(Fabsents[I]);
  SetLength(Fabsents, 0);
  for I := 0 to Length(Funefficients)-1 do
    FreeAndNil(Funefficients[I]);
  SetLength(Funefficients, 0);
  for I := 0 to Length(Frestrict_efficients)-1 do
    FreeAndNil(Frestrict_efficients[I]);
  SetLength(Frestrict_efficients, 0);
  inherited Destroy;
end;

procedure CourtList.Setdeaths(Index: Integer; const Adeaths2: deaths2);
begin
  Fdeaths := Adeaths2;
  Fdeaths_Specified := True;
end;

function CourtList.deaths_Specified(Index: Integer): boolean;
begin
  Result := Fdeaths_Specified;
end;

procedure CourtList.Setabsents(Index: Integer; const Aabsents: absents);
begin
  Fabsents := Aabsents;
  Fabsents_Specified := True;
end;

function CourtList.absents_Specified(Index: Integer): boolean;
begin
  Result := Fabsents_Specified;
end;

procedure CourtList.Setunefficients(Index: Integer; const Aunefficients: unefficients);
begin
  Funefficients := Aunefficients;
  Funefficients_Specified := True;
end;

function CourtList.unefficients_Specified(Index: Integer): boolean;
begin
  Result := Funefficients_Specified;
end;

procedure CourtList.Setrestrict_efficients(Index: Integer; const Arestrict_efficients: restrict_efficients);
begin
  Frestrict_efficients := Arestrict_efficients;
  Frestrict_efficients_Specified := True;
end;

function CourtList.restrict_efficients_Specified(Index: Integer): boolean;
begin
  Result := Frestrict_efficients_Specified;
end;

destructor courtDeathInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Fdeath_data);
  inherited Destroy;
end;

procedure courtDeathInfo.Setdeath_data(Index: Integer; const ACourtDeathData: CourtDeathData);
begin
  Fdeath_data := ACourtDeathData;
  Fdeath_data_Specified := True;
end;

function courtDeathInfo.death_data_Specified(Index: Integer): boolean;
begin
  Result := Fdeath_data_Specified;
end;

procedure courtDeathInfo.Setdocuments(Index: Integer; const Adocuments15: documents15);
begin
  Fdocuments := Adocuments15;
  Fdocuments_Specified := True;
end;

function courtDeathInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor courtDecision.Destroy;
begin
  FreeAndNil(Faccess);
  inherited Destroy;
end;

procedure courtDecision.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function courtDecision.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

destructor CourtDeathData.Destroy;
begin
  FreeAndNil(Fdeath_date);
  FreeAndNil(Fdeath_date_cancel);
  inherited Destroy;
end;

procedure CourtDeathData.Setdeath_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Fdeath_date := ATXSDate;
  Fdeath_date_Specified := True;
end;

function CourtDeathData.death_date_Specified(Index: Integer): boolean;
begin
  Result := Fdeath_date_Specified;
end;

procedure CourtDeathData.Setdeath_date_cancel(Index: Integer; const ATXSDate: TXSDate);
begin
  Fdeath_date_cancel := ATXSDate;
  Fdeath_date_cancel_Specified := True;
end;

function CourtDeathData.death_date_cancel_Specified(Index: Integer): boolean;
begin
  Result := Fdeath_date_cancel_Specified;
end;

destructor CourtAbsentData.Destroy;
begin
  FreeAndNil(Fabsent_date);
  FreeAndNil(Fabsent_date_cancel);
  inherited Destroy;
end;

procedure CourtAbsentData.Setabsent_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Fabsent_date := ATXSDate;
  Fabsent_date_Specified := True;
end;

function CourtAbsentData.absent_date_Specified(Index: Integer): boolean;
begin
  Result := Fabsent_date_Specified;
end;

procedure CourtAbsentData.Setabsent_date_cancel(Index: Integer; const ATXSDate: TXSDate);
begin
  Fabsent_date_cancel := ATXSDate;
  Fabsent_date_cancel_Specified := True;
end;

function CourtAbsentData.absent_date_cancel_Specified(Index: Integer): boolean;
begin
  Result := Fabsent_date_cancel_Specified;
end;

destructor courtAbsentInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Fabsent_data);
  inherited Destroy;
end;

procedure courtAbsentInfo.Setabsent_data(Index: Integer; const ACourtAbsentData: CourtAbsentData);
begin
  Fabsent_data := ACourtAbsentData;
  Fabsent_data_Specified := True;
end;

function courtAbsentInfo.absent_data_Specified(Index: Integer): boolean;
begin
  Result := Fabsent_data_Specified;
end;

procedure courtAbsentInfo.Setdocuments(Index: Integer; const Adocuments16: documents16);
begin
  Fdocuments := Adocuments16;
  Fdocuments_Specified := True;
end;

function courtAbsentInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor CourtUnefficientData.Destroy;
begin
  FreeAndNil(Funefficient_date);
  FreeAndNil(Funefficient_date_cancel);
  inherited Destroy;
end;

procedure CourtUnefficientData.Setunefficient_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Funefficient_date := ATXSDate;
  Funefficient_date_Specified := True;
end;

function CourtUnefficientData.unefficient_date_Specified(Index: Integer): boolean;
begin
  Result := Funefficient_date_Specified;
end;

procedure CourtUnefficientData.Setunefficient_date_cancel(Index: Integer; const ATXSDate: TXSDate);
begin
  Funefficient_date_cancel := ATXSDate;
  Funefficient_date_cancel_Specified := True;
end;

function CourtUnefficientData.unefficient_date_cancel_Specified(Index: Integer): boolean;
begin
  Result := Funefficient_date_cancel_Specified;
end;

destructor courtUnefficientInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Funefficient_data);
  inherited Destroy;
end;

procedure courtUnefficientInfo.Setunefficient_data(Index: Integer; const ACourtUnefficientData: CourtUnefficientData);
begin
  Funefficient_data := ACourtUnefficientData;
  Funefficient_data_Specified := True;
end;

function courtUnefficientInfo.unefficient_data_Specified(Index: Integer): boolean;
begin
  Result := Funefficient_data_Specified;
end;

procedure courtUnefficientInfo.Setdocuments(Index: Integer; const Adocuments17: documents17);
begin
  Fdocuments := Adocuments17;
  Fdocuments_Specified := True;
end;

function courtUnefficientInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor CourtRestrictEfficientData.Destroy;
begin
  FreeAndNil(Frestrict_unefficient_date);
  FreeAndNil(Frestrict_unefficient_date_cancel);
  inherited Destroy;
end;

procedure CourtRestrictEfficientData.Setrestrict_unefficient_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Frestrict_unefficient_date := ATXSDate;
  Frestrict_unefficient_date_Specified := True;
end;

function CourtRestrictEfficientData.restrict_unefficient_date_Specified(Index: Integer): boolean;
begin
  Result := Frestrict_unefficient_date_Specified;
end;

procedure CourtRestrictEfficientData.Setrestrict_unefficient_date_cancel(Index: Integer; const ATXSDate: TXSDate);
begin
  Frestrict_unefficient_date_cancel := ATXSDate;
  Frestrict_unefficient_date_cancel_Specified := True;
end;

function CourtRestrictEfficientData.restrict_unefficient_date_cancel_Specified(Index: Integer): boolean;
begin
  Result := Frestrict_unefficient_date_cancel_Specified;
end;

destructor courtRestrictEfficientInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Frestrict_efficient_data);
  inherited Destroy;
end;

procedure courtRestrictEfficientInfo.Setrestrict_efficient_data(Index: Integer; const ACourtRestrictEfficientData: CourtRestrictEfficientData);
begin
  Frestrict_efficient_data := ACourtRestrictEfficientData;
  Frestrict_efficient_data_Specified := True;
end;

function courtRestrictEfficientInfo.restrict_efficient_data_Specified(Index: Integer): boolean;
begin
  Result := Frestrict_efficient_data_Specified;
end;

procedure courtRestrictEfficientInfo.Setdocuments(Index: Integer; const Adocuments18: documents18);
begin
  Fdocuments := Adocuments18;
  Fdocuments_Specified := True;
end;

function courtRestrictEfficientInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor unemploymentData.Destroy;
begin
  FreeAndNil(Faccess);
  FreeAndNil(Funemployment_begin_data);
  FreeAndNil(Funemployment_end_data);
  inherited Destroy;
end;

procedure unemploymentData.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function unemploymentData.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure unemploymentData.Setunemployment_begin_data(Index: Integer; const ATXSDate: TXSDate);
begin
  Funemployment_begin_data := ATXSDate;
  Funemployment_begin_data_Specified := True;
end;

function unemploymentData.unemployment_begin_data_Specified(Index: Integer): boolean;
begin
  Result := Funemployment_begin_data_Specified;
end;

procedure unemploymentData.Setunemployment_end_data(Index: Integer; const ATXSDate: TXSDate);
begin
  Funemployment_end_data := ATXSDate;
  Funemployment_end_data_Specified := True;
end;

function unemploymentData.unemployment_end_data_Specified(Index: Integer): boolean;
begin
  Result := Funemployment_end_data_Specified;
end;

destructor unemploymentInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Funemplyment_data);
  inherited Destroy;
end;

procedure unemploymentInfo.Setunemplyment_data(Index: Integer; const AunemploymentData: unemploymentData);
begin
  Funemplyment_data := AunemploymentData;
  Funemplyment_data_Specified := True;
end;

function unemploymentInfo.unemplyment_data_Specified(Index: Integer): boolean;
begin
  Result := Funemplyment_data_Specified;
end;

procedure unemploymentInfo.Setdocuments(Index: Integer; const Adocuments19: documents19);
begin
  Fdocuments := Adocuments19;
  Fdocuments_Specified := True;
end;

function unemploymentInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor Pension.Destroy;
begin
  FreeAndNil(Faccess);
  FreeAndNil(Fpension_type);
  FreeAndNil(Fpension_awarding_date);
  FreeAndNil(Fpension_suspension_date);
  inherited Destroy;
end;

procedure Pension.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function Pension.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure Pension.Setpension_type(Index: Integer; const AClassifier: Classifier);
begin
  Fpension_type := AClassifier;
  Fpension_type_Specified := True;
end;

function Pension.pension_type_Specified(Index: Integer): boolean;
begin
  Result := Fpension_type_Specified;
end;

procedure Pension.Setpension_awarding_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Fpension_awarding_date := ATXSDate;
  Fpension_awarding_date_Specified := True;
end;

function Pension.pension_awarding_date_Specified(Index: Integer): boolean;
begin
  Result := Fpension_awarding_date_Specified;
end;

procedure Pension.Setpension_suspension_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Fpension_suspension_date := ATXSDate;
  Fpension_suspension_date_Specified := True;
end;

function Pension.pension_suspension_date_Specified(Index: Integer): boolean;
begin
  Result := Fpension_suspension_date_Specified;
end;

destructor pensionInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Fpension_data);
  inherited Destroy;
end;

procedure pensionInfo.Setpension_data(Index: Integer; const APension: Pension);
begin
  Fpension_data := APension;
  Fpension_data_Specified := True;
end;

function pensionInfo.pension_data_Specified(Index: Integer): boolean;
begin
  Result := Fpension_data_Specified;
end;

procedure pensionInfo.Setdocuments(Index: Integer; const Adocuments20: documents20);
begin
  Fdocuments := Adocuments20;
  Fdocuments_Specified := True;
end;

function pensionInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor salaryData.Destroy;
begin
  FreeAndNil(Faccess);
  FreeAndNil(Fsalary_awarding_date);
  FreeAndNil(Fsalary_suspension_date);
  inherited Destroy;
end;

procedure salaryData.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function salaryData.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure salaryData.Setsalary_awarding_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Fsalary_awarding_date := ATXSDate;
  Fsalary_awarding_date_Specified := True;
end;

function salaryData.salary_awarding_date_Specified(Index: Integer): boolean;
begin
  Result := Fsalary_awarding_date_Specified;
end;

procedure salaryData.Setsalary_suspension_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Fsalary_suspension_date := ATXSDate;
  Fsalary_suspension_date_Specified := True;
end;

function salaryData.salary_suspension_date_Specified(Index: Integer): boolean;
begin
  Result := Fsalary_suspension_date_Specified;
end;

destructor salaryInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Fsalary_data);
  inherited Destroy;
end;

procedure salaryInfo.Setsalary_data(Index: Integer; const AsalaryData: salaryData);
begin
  Fsalary_data := AsalaryData;
  Fsalary_data_Specified := True;
end;

function salaryInfo.salary_data_Specified(Index: Integer): boolean;
begin
  Result := Fsalary_data_Specified;
end;

procedure salaryInfo.Setdocuments(Index: Integer; const Adocuments21: documents21);
begin
  Fdocuments := Adocuments21;
  Fdocuments_Specified := True;
end;

function salaryInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor Insurance.Destroy;
begin
  FreeAndNil(Faccess);
  FreeAndNil(Finsurance_awarding_date);
  FreeAndNil(Finsurance_suspension_date);
  inherited Destroy;
end;

procedure Insurance.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function Insurance.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure Insurance.Setinsurance_awarding_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Finsurance_awarding_date := ATXSDate;
  Finsurance_awarding_date_Specified := True;
end;

function Insurance.insurance_awarding_date_Specified(Index: Integer): boolean;
begin
  Result := Finsurance_awarding_date_Specified;
end;

procedure Insurance.Setinsurance_suspension_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Finsurance_suspension_date := ATXSDate;
  Finsurance_suspension_date_Specified := True;
end;

function Insurance.insurance_suspension_date_Specified(Index: Integer): boolean;
begin
  Result := Finsurance_suspension_date_Specified;
end;

procedure Insurance.Setactive(Index: Integer; const ABoolean: Boolean);
begin
  Factive := ABoolean;
  Factive_Specified := True;
end;

function Insurance.active_Specified(Index: Integer): boolean;
begin
  Result := Factive_Specified;
end;

destructor insuranceInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Finsurance_data);
  inherited Destroy;
end;

procedure insuranceInfo.Setinsurance_data(Index: Integer; const AInsurance: Insurance);
begin
  Finsurance_data := AInsurance;
  Finsurance_data_Specified := True;
end;

function insuranceInfo.insurance_data_Specified(Index: Integer): boolean;
begin
  Result := Finsurance_data_Specified;
end;

procedure insuranceInfo.Setdocuments(Index: Integer; const Adocuments22: documents22);
begin
  Fdocuments := Adocuments22;
  Fdocuments_Specified := True;
end;

function insuranceInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor Tax.Destroy;
begin
  FreeAndNil(Faccess);
  FreeAndNil(Ftax_awarding_date);
  inherited Destroy;
end;

procedure Tax.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function Tax.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure Tax.Settax_awarding_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Ftax_awarding_date := ATXSDate;
  Ftax_awarding_date_Specified := True;
end;

function Tax.tax_awarding_date_Specified(Index: Integer): boolean;
begin
  Result := Ftax_awarding_date_Specified;
end;

procedure Tax.Settax_number(Index: Integer; const AWideString: WideString);
begin
  Ftax_number := AWideString;
  Ftax_number_Specified := True;
end;

function Tax.tax_number_Specified(Index: Integer): boolean;
begin
  Result := Ftax_number_Specified;
end;

procedure Tax.Settax_debt_data(Index: Integer; const AInteger: Integer);
begin
  Ftax_debt_data := AInteger;
  Ftax_debt_data_Specified := True;
end;

function Tax.tax_debt_data_Specified(Index: Integer): boolean;
begin
  Result := Ftax_debt_data_Specified;
end;

destructor taxInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Ftax_data);
  inherited Destroy;
end;

procedure taxInfo.Settax_data(Index: Integer; const ATax: Tax);
begin
  Ftax_data := ATax;
  Ftax_data_Specified := True;
end;

function taxInfo.tax_data_Specified(Index: Integer): boolean;
begin
  Result := Ftax_data_Specified;
end;

procedure taxInfo.Setdocuments(Index: Integer; const Adocuments23: documents23);
begin
  Fdocuments := Adocuments23;
  Fdocuments_Specified := True;
end;

function taxInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor Military.Destroy;
begin
  FreeAndNil(Faccess);
  FreeAndNil(Fmilitary_service_awarding_date);
  FreeAndNil(Fmilitary_service_suspension_date);
  inherited Destroy;
end;

procedure Military.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function Military.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure Military.Setmilitary_service_awarding_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Fmilitary_service_awarding_date := ATXSDate;
  Fmilitary_service_awarding_date_Specified := True;
end;

function Military.military_service_awarding_date_Specified(Index: Integer): boolean;
begin
  Result := Fmilitary_service_awarding_date_Specified;
end;

procedure Military.Setmilitary_service_suspension_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Fmilitary_service_suspension_date := ATXSDate;
  Fmilitary_service_suspension_date_Specified := True;
end;

function Military.military_service_suspension_date_Specified(Index: Integer): boolean;
begin
  Result := Fmilitary_service_suspension_date_Specified;
end;

destructor militaryInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Fmilitary_data);
  inherited Destroy;
end;

procedure militaryInfo.Setmilitary_data(Index: Integer; const AMilitary: Military);
begin
  Fmilitary_data := AMilitary;
  Fmilitary_data_Specified := True;
end;

function militaryInfo.military_data_Specified(Index: Integer): boolean;
begin
  Result := Fmilitary_data_Specified;
end;

procedure militaryInfo.Setdocuments(Index: Integer; const Adocuments24: documents24);
begin
  Fdocuments := Adocuments24;
  Fdocuments_Specified := True;
end;

function militaryInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor Disability.Destroy;
begin
  FreeAndNil(Faccess);
  FreeAndNil(Fdisability_group);
  FreeAndNil(Fdisability_date);
  FreeAndNil(Fdisability_term);
  FreeAndNil(Fdisability_cause);
  inherited Destroy;
end;

procedure Disability.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function Disability.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure Disability.Setdisability_group(Index: Integer; const AClassifier: Classifier);
begin
  Fdisability_group := AClassifier;
  Fdisability_group_Specified := True;
end;

function Disability.disability_group_Specified(Index: Integer): boolean;
begin
  Result := Fdisability_group_Specified;
end;

procedure Disability.Setdisability_date(Index: Integer; const ATXSDate: TXSDate);
begin
  Fdisability_date := ATXSDate;
  Fdisability_date_Specified := True;
end;

function Disability.disability_date_Specified(Index: Integer): boolean;
begin
  Result := Fdisability_date_Specified;
end;

procedure Disability.Setdisability_term(Index: Integer; const ATXSDate: TXSDate);
begin
  Fdisability_term := ATXSDate;
  Fdisability_term_Specified := True;
end;

function Disability.disability_term_Specified(Index: Integer): boolean;
begin
  Result := Fdisability_term_Specified;
end;

procedure Disability.Setdisability_cause(Index: Integer; const AClassifier: Classifier);
begin
  Fdisability_cause := AClassifier;
  Fdisability_cause_Specified := True;
end;

function Disability.disability_cause_Specified(Index: Integer): boolean;
begin
  Result := Fdisability_cause_Specified;
end;

procedure Disability.Setactive(Index: Integer; const ABoolean: Boolean);
begin
  Factive := ABoolean;
  Factive_Specified := True;
end;

function Disability.active_Specified(Index: Integer): boolean;
begin
  Result := Factive_Specified;
end;

destructor disabilityInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Fdisability_data);
  inherited Destroy;
end;

procedure disabilityInfo.Setdisability_data(Index: Integer; const ADisability: Disability);
begin
  Fdisability_data := ADisability;
  Fdisability_data_Specified := True;
end;

function disabilityInfo.disability_data_Specified(Index: Integer): boolean;
begin
  Result := Fdisability_data_Specified;
end;

procedure disabilityInfo.Setdocuments(Index: Integer; const Adocuments25: documents25);
begin
  Fdocuments := Adocuments25;
  Fdocuments_Specified := True;
end;

function disabilityInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor MessageCover.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fquery_params)-1 do
    FreeAndNil(Fquery_params[I]);
  SetLength(Fquery_params, 0);
  FreeAndNil(Fmessage_type);
  FreeAndNil(Fmessage_time);
  FreeAndNil(Fmessage_source);
  FreeAndNil(Fsystem_id);
  inherited Destroy;
end;

procedure MessageCover.Setparent_message_id(Index: Integer; const AWideString: WideString);
begin
  Fparent_message_id := AWideString;
  Fparent_message_id_Specified := True;
end;

function MessageCover.parent_message_id_Specified(Index: Integer): boolean;
begin
  Result := Fparent_message_id_Specified;
end;

procedure MessageCover.Setsystem_id(Index: Integer; const AClassifier: Classifier);
begin
  Fsystem_id := AClassifier;
  Fsystem_id_Specified := True;
end;

function MessageCover.system_id_Specified(Index: Integer): boolean;
begin
  Result := Fsystem_id_Specified;
end;

procedure MessageCover.Setquery_params(Index: Integer; const Aquery_params: query_params);
begin
  Fquery_params := Aquery_params;
  Fquery_params_Specified := True;
end;

function MessageCover.query_params_Specified(Index: Integer): boolean;
begin
  Result := Fquery_params_Specified;
end;

destructor QueryParam.Destroy;
begin
  FreeAndNil(Fparam_type);
  inherited Destroy;
end;

procedure QueryParam.Setparam_type(Index: Integer; const AClassifier: Classifier);
begin
  Fparam_type := AClassifier;
  Fparam_type_Specified := True;
end;

function QueryParam.param_type_Specified(Index: Integer): boolean;
begin
  Result := Fparam_type_Specified;
end;

procedure QueryParam.Setparam_value(Index: Integer; const AWideString: WideString);
begin
  Fparam_value := AWideString;
  Fparam_value_Specified := True;
end;

function QueryParam.param_value_Specified(Index: Integer): boolean;
begin
  Result := Fparam_value_Specified;
end;

destructor personalDataInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocuments)-1 do
    FreeAndNil(Fdocuments[I]);
  SetLength(Fdocuments, 0);
  FreeAndNil(Fpersonal_data);
  inherited Destroy;
end;

procedure personalDataInfo.Setpersonal_data(Index: Integer; const APersonalData: PersonalData);
begin
  Fpersonal_data := APersonalData;
  Fpersonal_data_Specified := True;
end;

function personalDataInfo.personal_data_Specified(Index: Integer): boolean;
begin
  Result := Fpersonal_data_Specified;
end;

procedure personalDataInfo.Setdocuments(Index: Integer; const Adocuments26: documents26);
begin
  Fdocuments := Adocuments26;
  Fdocuments_Specified := True;
end;

function personalDataInfo.documents_Specified(Index: Integer): boolean;
begin
  Result := Fdocuments_Specified;
end;

destructor LexemStatus.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Flexema)-1 do
    FreeAndNil(Flexema[I]);
  SetLength(Flexema, 0);
  inherited Destroy;
end;

procedure LexemStatus.Setlexema(Index: Integer; const ALangValueList: LangValueList);
begin
  Flexema := ALangValueList;
  Flexema_Specified := True;
end;

function LexemStatus.lexema_Specified(Index: Integer): boolean;
begin
  Result := Flexema_Specified;
end;

procedure LexemStatus.Setactive(Index: Integer; const ABoolean: Boolean);
begin
  Factive := ABoolean;
  Factive_Specified := True;
end;

function LexemStatus.active_Specified(Index: Integer): boolean;
begin
  Result := Factive_Specified;
end;

constructor RegisterResponse.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor RegisterResponse.Destroy;
begin
  FreeAndNil(Fcover);
  FreeAndNil(Fresponse);
  inherited Destroy;
end;

destructor ResponsePerson.Destroy;
begin
  FreeAndNil(Fdata);
  inherited Destroy;
end;

destructor WsError.Destroy;
begin
  FreeAndNil(Ferror_code);
  inherited Destroy;
end;

procedure WsError.Seterror_place(Index: Integer; const AWideString: WideString);
begin
  Ferror_place := AWideString;
  Ferror_place_Specified := True;
end;

function WsError.error_place_Specified(Index: Integer): boolean;
begin
  Result := Ferror_place_Specified;
end;

procedure WsError.Setwrong_value(Index: Integer; const AWideString: WideString);
begin
  Fwrong_value := AWideString;
  Fwrong_value_Specified := True;
end;

function WsError.wrong_value_Specified(Index: Integer): boolean;
begin
  Result := Fwrong_value_Specified;
end;

procedure WsError.Setcorrect_value(Index: Integer; const AWideString: WideString);
begin
  Fcorrect_value := AWideString;
  Fcorrect_value_Specified := True;
end;

function WsError.correct_value_Specified(Index: Integer): boolean;
begin
  Result := Fcorrect_value_Specified;
end;

procedure WsError.Setcheck_name(Index: Integer; const AWideString: WideString);
begin
  Fcheck_name := AWideString;
  Fcheck_name_Specified := True;
end;

function WsError.check_name_Specified(Index: Integer): boolean;
begin
  Result := Fcheck_name_Specified;
end;

procedure WsError.Setdescription(Index: Integer; const AWideString: WideString);
begin
  Fdescription := AWideString;
  Fdescription_Specified := True;
end;

function WsError.description_Specified(Index: Integer): boolean;
begin
  Result := Fdescription_Specified;
end;

procedure WsError.Setidentif(Index: Integer; const AWideString: WideString);
begin
  Fidentif := AWideString;
  Fidentif_Specified := True;
end;

function WsError.identif_Specified(Index: Integer): boolean;
begin
  Result := Fidentif_Specified;
end;

destructor WsException.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Ferror_list)-1 do
    FreeAndNil(Ferror_list[I]);
  SetLength(Ferror_list, 0);
  FreeAndNil(Fcover);
  inherited Destroy;
end;

procedure WsException.Seterror_list(Index: Integer; const AErrorList: ErrorList);
begin
  Ferror_list := AErrorList;
  Ferror_list_Specified := True;
end;

function WsException.error_list_Specified(Index: Integer): boolean;
begin
  Result := Ferror_list_Specified;
end;

constructor RegisterPersonListRequest.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor RegisterPersonListRequest.Destroy;
begin
  FreeAndNil(Fcover);
  FreeAndNil(Frequest);
  inherited Destroy;
end;

destructor PersonListRequest.Destroy;
begin
  FreeAndNil(Farea);
  FreeAndNil(Fregion);
  FreeAndNil(Fsoviet);
  FreeAndNil(Ftype_city);
  FreeAndNil(Fcity);
  FreeAndNil(Ftype_street);
  FreeAndNil(Fstreet);
  inherited Destroy;
end;

procedure PersonListRequest.Setsurname(Index: Integer; const AWideString: WideString);
begin
  Fsurname := AWideString;
  Fsurname_Specified := True;
end;

function PersonListRequest.surname_Specified(Index: Integer): boolean;
begin
  Result := Fsurname_Specified;
end;

procedure PersonListRequest.Setname_(Index: Integer; const AWideString: WideString);
begin
  Fname_ := AWideString;
  Fname__Specified := True;
end;

function PersonListRequest.name__Specified(Index: Integer): boolean;
begin
  Result := Fname__Specified;
end;

procedure PersonListRequest.Setsname(Index: Integer; const AWideString: WideString);
begin
  Fsname := AWideString;
  Fsname_Specified := True;
end;

function PersonListRequest.sname_Specified(Index: Integer): boolean;
begin
  Result := Fsname_Specified;
end;

procedure PersonListRequest.Setbdate(Index: Integer; const AWideString: WideString);
begin
  Fbdate := AWideString;
  Fbdate_Specified := True;
end;

function PersonListRequest.bdate_Specified(Index: Integer): boolean;
begin
  Result := Fbdate_Specified;
end;

procedure PersonListRequest.SetbdateTo(Index: Integer; const AWideString: WideString);
begin
  FbdateTo := AWideString;
  FbdateTo_Specified := True;
end;

function PersonListRequest.bdateTo_Specified(Index: Integer): boolean;
begin
  Result := FbdateTo_Specified;
end;

procedure PersonListRequest.Setidentif(Index: Integer; const AWideString: WideString);
begin
  Fidentif := AWideString;
  Fidentif_Specified := True;
end;

function PersonListRequest.identif_Specified(Index: Integer): boolean;
begin
  Result := Fidentif_Specified;
end;

procedure PersonListRequest.Setarrival(Index: Integer; const ABoolean: Boolean);
begin
  Farrival := ABoolean;
  Farrival_Specified := True;
end;

function PersonListRequest.arrival_Specified(Index: Integer): boolean;
begin
  Result := Farrival_Specified;
end;

procedure PersonListRequest.Setdeparture(Index: Integer; const ABoolean: Boolean);
begin
  Fdeparture := ABoolean;
  Fdeparture_Specified := True;
end;

function PersonListRequest.departure_Specified(Index: Integer): boolean;
begin
  Result := Fdeparture_Specified;
end;

procedure PersonListRequest.SetpermAddress(Index: Integer; const ABoolean: Boolean);
begin
  FpermAddress := ABoolean;
  FpermAddress_Specified := True;
end;

function PersonListRequest.permAddress_Specified(Index: Integer): boolean;
begin
  Result := FpermAddress_Specified;
end;

procedure PersonListRequest.SettempAddress(Index: Integer; const ABoolean: Boolean);
begin
  FtempAddress := ABoolean;
  FtempAddress_Specified := True;
end;

function PersonListRequest.tempAddress_Specified(Index: Integer): boolean;
begin
  Result := FtempAddress_Specified;
end;

procedure PersonListRequest.Setarea(Index: Integer; const AClassifier: Classifier);
begin
  Farea := AClassifier;
  Farea_Specified := True;
end;

function PersonListRequest.area_Specified(Index: Integer): boolean;
begin
  Result := Farea_Specified;
end;

procedure PersonListRequest.Setregion(Index: Integer; const AClassifier: Classifier);
begin
  Fregion := AClassifier;
  Fregion_Specified := True;
end;

function PersonListRequest.region_Specified(Index: Integer): boolean;
begin
  Result := Fregion_Specified;
end;

procedure PersonListRequest.Setsoviet(Index: Integer; const AClassifier: Classifier);
begin
  Fsoviet := AClassifier;
  Fsoviet_Specified := True;
end;

function PersonListRequest.soviet_Specified(Index: Integer): boolean;
begin
  Result := Fsoviet_Specified;
end;

procedure PersonListRequest.Settype_city(Index: Integer; const AClassifier: Classifier);
begin
  Ftype_city := AClassifier;
  Ftype_city_Specified := True;
end;

function PersonListRequest.type_city_Specified(Index: Integer): boolean;
begin
  Result := Ftype_city_Specified;
end;

procedure PersonListRequest.Setcity(Index: Integer; const AClassifier: Classifier);
begin
  Fcity := AClassifier;
  Fcity_Specified := True;
end;

function PersonListRequest.city_Specified(Index: Integer): boolean;
begin
  Result := Fcity_Specified;
end;

procedure PersonListRequest.Settype_street(Index: Integer; const AClassifier: Classifier);
begin
  Ftype_street := AClassifier;
  Ftype_street_Specified := True;
end;

function PersonListRequest.type_street_Specified(Index: Integer): boolean;
begin
  Result := Ftype_street_Specified;
end;

procedure PersonListRequest.Setstreet(Index: Integer; const AClassifier: Classifier);
begin
  Fstreet := AClassifier;
  Fstreet_Specified := True;
end;

function PersonListRequest.street_Specified(Index: Integer): boolean;
begin
  Result := Fstreet_Specified;
end;

procedure PersonListRequest.Sethouse(Index: Integer; const AWideString: WideString);
begin
  Fhouse := AWideString;
  Fhouse_Specified := True;
end;

function PersonListRequest.house_Specified(Index: Integer): boolean;
begin
  Result := Fhouse_Specified;
end;

procedure PersonListRequest.Setkorps(Index: Integer; const AWideString: WideString);
begin
  Fkorps := AWideString;
  Fkorps_Specified := True;
end;

function PersonListRequest.korps_Specified(Index: Integer): boolean;
begin
  Result := Fkorps_Specified;
end;

procedure PersonListRequest.Setapp(Index: Integer; const AWideString: WideString);
begin
  Fapp := AWideString;
  Fapp_Specified := True;
end;

function PersonListRequest.app_Specified(Index: Integer): boolean;
begin
  Result := Fapp_Specified;
end;

procedure PersonListRequest.Setquery_reason(Index: Integer; const AWideString: WideString);
begin
  Fquery_reason := AWideString;
  Fquery_reason_Specified := True;
end;

function PersonListRequest.query_reason_Specified(Index: Integer): boolean;
begin
  Result := Fquery_reason_Specified;
end;

procedure PersonListRequest.Setarchive(Index: Integer; const ABoolean: Boolean);
begin
  Farchive := ABoolean;
  Farchive_Specified := True;
end;

function PersonListRequest.archive_Specified(Index: Integer): boolean;
begin
  Result := Farchive_Specified;
end;

procedure PersonListRequest.Setcount(Index: Integer; const AInteger: Integer);
begin
  Fcount := AInteger;
  Fcount_Specified := True;
end;

function PersonListRequest.count_Specified(Index: Integer): boolean;
begin
  Result := Fcount_Specified;
end;

constructor RegisterRequest.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor RegisterRequest.Destroy;
begin
  FreeAndNil(Fcover);
  FreeAndNil(Frequest);
  inherited Destroy;
end;

destructor PersonRequest.Destroy;
begin
  FreeAndNil(Fdocument);
  inherited Destroy;
end;

destructor IdentifRequest.Destroy;
begin
  FreeAndNil(Fsex);
  inherited Destroy;
end;

constructor ClassifierChangeRequest.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor ClassifierChangeRequest.Destroy;
begin
  FreeAndNil(Fdate);
  inherited Destroy;
end;

constructor RegisterPersonIdentifRequest.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor RegisterPersonIdentifRequest.Destroy;
begin
  FreeAndNil(Fcover);
  FreeAndNil(Frequest);
  inherited Destroy;
end;

destructor History.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fpersonal_history)-1 do
    FreeAndNil(Fpersonal_history[I]);
  SetLength(Fpersonal_history, 0);
  for I := 0 to Length(Fnationality_data)-1 do
    FreeAndNil(Fnationality_data[I]);
  SetLength(Fnationality_data, 0);
  for I := 0 to Length(Fnationality)-1 do
    FreeAndNil(Fnationality[I]);
  SetLength(Fnationality, 0);
  for I := 0 to Length(Faddresses)-1 do
    FreeAndNil(Faddresses[I]);
  SetLength(Faddresses, 0);
  for I := 0 to Length(Ftemp_addresses)-1 do
    FreeAndNil(Ftemp_addresses[I]);
  SetLength(Ftemp_addresses, 0);
  for I := 0 to Length(Fdeaths)-1 do
    FreeAndNil(Fdeaths[I]);
  SetLength(Fdeaths, 0);
  for I := 0 to Length(Fburials)-1 do
    FreeAndNil(Fburials[I]);
  SetLength(Fburials, 0);
  for I := 0 to Length(Fguardianships)-1 do
    FreeAndNil(Fguardianships[I]);
  SetLength(Fguardianships, 0);
  for I := 0 to Length(Ftrusteeships)-1 do
    FreeAndNil(Ftrusteeships[I]);
  SetLength(Ftrusteeships, 0);
  for I := 0 to Length(Feducations)-1 do
    FreeAndNil(Feducations[I]);
  SetLength(Feducations, 0);
  for I := 0 to Length(FscienceRanks)-1 do
    FreeAndNil(FscienceRanks[I]);
  SetLength(FscienceRanks, 0);
  for I := 0 to Length(FscienceDegrees)-1 do
    FreeAndNil(FscienceDegrees[I]);
  SetLength(FscienceDegrees, 0);
  for I := 0 to Length(Femployments)-1 do
    FreeAndNil(Femployments[I]);
  SetLength(Femployments, 0);
  for I := 0 to Length(Fpensions)-1 do
    FreeAndNil(Fpensions[I]);
  SetLength(Fpensions, 0);
  for I := 0 to Length(Finsurances)-1 do
    FreeAndNil(Finsurances[I]);
  SetLength(Finsurances, 0);
  for I := 0 to Length(Ftaxies)-1 do
    FreeAndNil(Ftaxies[I]);
  SetLength(Ftaxies, 0);
  for I := 0 to Length(Fmilitaries)-1 do
    FreeAndNil(Fmilitaries[I]);
  SetLength(Fmilitaries, 0);
  for I := 0 to Length(Fdisabilities)-1 do
    FreeAndNil(Fdisabilities[I]);
  SetLength(Fdisabilities, 0);
  FreeAndNil(Ffamily);
  FreeAndNil(Femployment_status_info);
  FreeAndNil(Fcourts);
  FreeAndNil(Funemplyment_info);
  FreeAndNil(Fsalary_info);
  inherited Destroy;
end;

procedure History.Setpersonal_history(Index: Integer; const Apersonal_history: personal_history);
begin
  Fpersonal_history := Apersonal_history;
  Fpersonal_history_Specified := True;
end;

function History.personal_history_Specified(Index: Integer): boolean;
begin
  Result := Fpersonal_history_Specified;
end;

procedure History.Setnationality_data(Index: Integer; const AArray_Of_Citizenship: Array_Of_Citizenship);
begin
  Fnationality_data := AArray_Of_Citizenship;
  Fnationality_data_Specified := True;
end;

function History.nationality_data_Specified(Index: Integer): boolean;
begin
  Result := Fnationality_data_Specified;
end;

procedure History.Setnationality(Index: Integer; const Anationality3: nationality3);
begin
  Fnationality := Anationality3;
  Fnationality_Specified := True;
end;

function History.nationality_Specified(Index: Integer): boolean;
begin
  Result := Fnationality_Specified;
end;

procedure History.Setaddresses(Index: Integer; const Aaddresses: addresses);
begin
  Faddresses := Aaddresses;
  Faddresses_Specified := True;
end;

function History.addresses_Specified(Index: Integer): boolean;
begin
  Result := Faddresses_Specified;
end;

procedure History.Settemp_addresses(Index: Integer; const Atemp_addresses2: temp_addresses2);
begin
  Ftemp_addresses := Atemp_addresses2;
  Ftemp_addresses_Specified := True;
end;

function History.temp_addresses_Specified(Index: Integer): boolean;
begin
  Result := Ftemp_addresses_Specified;
end;

procedure History.Setdeaths(Index: Integer; const Adeaths3: deaths3);
begin
  Fdeaths := Adeaths3;
  Fdeaths_Specified := True;
end;

function History.deaths_Specified(Index: Integer): boolean;
begin
  Result := Fdeaths_Specified;
end;

procedure History.Setburials(Index: Integer; const Aburials2: burials2);
begin
  Fburials := Aburials2;
  Fburials_Specified := True;
end;

function History.burials_Specified(Index: Integer): boolean;
begin
  Result := Fburials_Specified;
end;

procedure History.Setguardianships(Index: Integer; const Aguardianships2: guardianships2);
begin
  Fguardianships := Aguardianships2;
  Fguardianships_Specified := True;
end;

function History.guardianships_Specified(Index: Integer): boolean;
begin
  Result := Fguardianships_Specified;
end;

procedure History.Settrusteeships(Index: Integer; const Atrusteeships2: trusteeships2);
begin
  Ftrusteeships := Atrusteeships2;
  Ftrusteeships_Specified := True;
end;

function History.trusteeships_Specified(Index: Integer): boolean;
begin
  Result := Ftrusteeships_Specified;
end;

procedure History.Setfamily(Index: Integer; const AFamilyDataHistory: FamilyDataHistory);
begin
  Ffamily := AFamilyDataHistory;
  Ffamily_Specified := True;
end;

function History.family_Specified(Index: Integer): boolean;
begin
  Result := Ffamily_Specified;
end;

procedure History.Seteducations(Index: Integer; const Aeducations2: educations2);
begin
  Feducations := Aeducations2;
  Feducations_Specified := True;
end;

function History.educations_Specified(Index: Integer): boolean;
begin
  Result := Feducations_Specified;
end;

procedure History.SetscienceRanks(Index: Integer; const AscienceRanks2: scienceRanks2);
begin
  FscienceRanks := AscienceRanks2;
  FscienceRanks_Specified := True;
end;

function History.scienceRanks_Specified(Index: Integer): boolean;
begin
  Result := FscienceRanks_Specified;
end;

procedure History.SetscienceDegrees(Index: Integer; const AscienceDegrees2: scienceDegrees2);
begin
  FscienceDegrees := AscienceDegrees2;
  FscienceDegrees_Specified := True;
end;

function History.scienceDegrees_Specified(Index: Integer): boolean;
begin
  Result := FscienceDegrees_Specified;
end;

procedure History.Setemployment_status_info(Index: Integer; const AemploymentStatusInfo: employmentStatusInfo);
begin
  Femployment_status_info := AemploymentStatusInfo;
  Femployment_status_info_Specified := True;
end;

function History.employment_status_info_Specified(Index: Integer): boolean;
begin
  Result := Femployment_status_info_Specified;
end;

procedure History.Setemployments(Index: Integer; const Aemployments2: employments2);
begin
  Femployments := Aemployments2;
  Femployments_Specified := True;
end;

function History.employments_Specified(Index: Integer): boolean;
begin
  Result := Femployments_Specified;
end;

procedure History.Setcourts(Index: Integer; const ACourtList: CourtList);
begin
  Fcourts := ACourtList;
  Fcourts_Specified := True;
end;

function History.courts_Specified(Index: Integer): boolean;
begin
  Result := Fcourts_Specified;
end;

procedure History.Setunemplyment_info(Index: Integer; const AunemploymentInfo: unemploymentInfo);
begin
  Funemplyment_info := AunemploymentInfo;
  Funemplyment_info_Specified := True;
end;

function History.unemplyment_info_Specified(Index: Integer): boolean;
begin
  Result := Funemplyment_info_Specified;
end;

procedure History.Setpensions(Index: Integer; const Apensions2: pensions2);
begin
  Fpensions := Apensions2;
  Fpensions_Specified := True;
end;

function History.pensions_Specified(Index: Integer): boolean;
begin
  Result := Fpensions_Specified;
end;

procedure History.Setsalary_info(Index: Integer; const AsalaryInfo: salaryInfo);
begin
  Fsalary_info := AsalaryInfo;
  Fsalary_info_Specified := True;
end;

function History.salary_info_Specified(Index: Integer): boolean;
begin
  Result := Fsalary_info_Specified;
end;

procedure History.Setinsurances(Index: Integer; const Ainsurances2: insurances2);
begin
  Finsurances := Ainsurances2;
  Finsurances_Specified := True;
end;

function History.insurances_Specified(Index: Integer): boolean;
begin
  Result := Finsurances_Specified;
end;

procedure History.Settaxies(Index: Integer; const Ataxies2: taxies2);
begin
  Ftaxies := Ataxies2;
  Ftaxies_Specified := True;
end;

function History.taxies_Specified(Index: Integer): boolean;
begin
  Result := Ftaxies_Specified;
end;

procedure History.Setmilitaries(Index: Integer; const Amilitaries2: militaries2);
begin
  Fmilitaries := Amilitaries2;
  Fmilitaries_Specified := True;
end;

function History.militaries_Specified(Index: Integer): boolean;
begin
  Result := Fmilitaries_Specified;
end;

procedure History.Setdisabilities(Index: Integer; const Adisabilities2: disabilities2);
begin
  Fdisabilities := Adisabilities2;
  Fdisabilities_Specified := True;
end;

function History.disabilities_Specified(Index: Integer): boolean;
begin
  Result := Fdisabilities_Specified;
end;

destructor PersonalData.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fdocument)-1 do
    FreeAndNil(Fdocument[I]);
  SetLength(Fdocument, 0);
  for I := 0 to Length(Fphoto)-1 do
    FreeAndNil(Fphoto[I]);
  SetLength(Fphoto, 0);
  for I := 0 to Length(Fnationality_data)-1 do
    FreeAndNil(Fnationality_data[I]);
  SetLength(Fnationality_data, 0);
  for I := 0 to Length(Fnationality)-1 do
    FreeAndNil(Fnationality[I]);
  SetLength(Fnationality, 0);
  for I := 0 to Length(Ftemp_addresses)-1 do
    FreeAndNil(Ftemp_addresses[I]);
  SetLength(Ftemp_addresses, 0);
  for I := 0 to Length(Fdeaths)-1 do
    FreeAndNil(Fdeaths[I]);
  SetLength(Fdeaths, 0);
  for I := 0 to Length(Fburials)-1 do
    FreeAndNil(Fburials[I]);
  SetLength(Fburials, 0);
  for I := 0 to Length(Fguardianships)-1 do
    FreeAndNil(Fguardianships[I]);
  SetLength(Fguardianships, 0);
  for I := 0 to Length(Ftrusteeships)-1 do
    FreeAndNil(Ftrusteeships[I]);
  SetLength(Ftrusteeships, 0);
  for I := 0 to Length(Feducations)-1 do
    FreeAndNil(Feducations[I]);
  SetLength(Feducations, 0);
  for I := 0 to Length(FscienceRanks)-1 do
    FreeAndNil(FscienceRanks[I]);
  SetLength(FscienceRanks, 0);
  for I := 0 to Length(FscienceDegrees)-1 do
    FreeAndNil(FscienceDegrees[I]);
  SetLength(FscienceDegrees, 0);
  for I := 0 to Length(Femployments)-1 do
    FreeAndNil(Femployments[I]);
  SetLength(Femployments, 0);
  for I := 0 to Length(Fpensions)-1 do
    FreeAndNil(Fpensions[I]);
  SetLength(Fpensions, 0);
  for I := 0 to Length(Finsurances)-1 do
    FreeAndNil(Finsurances[I]);
  SetLength(Finsurances, 0);
  for I := 0 to Length(Ftaxies)-1 do
    FreeAndNil(Ftaxies[I]);
  SetLength(Ftaxies, 0);
  for I := 0 to Length(Fmilitaries)-1 do
    FreeAndNil(Fmilitaries[I]);
  SetLength(Fmilitaries, 0);
  for I := 0 to Length(Fdisabilities)-1 do
    FreeAndNil(Fdisabilities[I]);
  SetLength(Fdisabilities, 0);
  FreeAndNil(Faccess);
  FreeAndNil(Fsex);
  FreeAndNil(Fbirth_place);
  FreeAndNil(Fcitizenship);
  FreeAndNil(Fstatus);
  FreeAndNil(Faddress);
  FreeAndNil(Ffamily);
  FreeAndNil(Femployment_status_info);
  FreeAndNil(Fcourts);
  FreeAndNil(Funemplyment_info);
  FreeAndNil(Fsalary_info);
  FreeAndNil(Fhistory);
  inherited Destroy;
end;

procedure PersonalData.Setaccess(Index: Integer; const AClassifier: Classifier);
begin
  Faccess := AClassifier;
  Faccess_Specified := True;
end;

function PersonalData.access_Specified(Index: Integer): boolean;
begin
  Result := Faccess_Specified;
end;

procedure PersonalData.Setidentif(Index: Integer; const AWideString: WideString);
begin
  Fidentif := AWideString;
  Fidentif_Specified := True;
end;

function PersonalData.identif_Specified(Index: Integer): boolean;
begin
  Result := Fidentif_Specified;
end;

procedure PersonalData.Setlast_name(Index: Integer; const AWideString: WideString);
begin
  Flast_name := AWideString;
  Flast_name_Specified := True;
end;

function PersonalData.last_name_Specified(Index: Integer): boolean;
begin
  Result := Flast_name_Specified;
end;

procedure PersonalData.Setlast_name_bel(Index: Integer; const AWideString: WideString);
begin
  Flast_name_bel := AWideString;
  Flast_name_bel_Specified := True;
end;

function PersonalData.last_name_bel_Specified(Index: Integer): boolean;
begin
  Result := Flast_name_bel_Specified;
end;

procedure PersonalData.Setlast_name_lat(Index: Integer; const AWideString: WideString);
begin
  Flast_name_lat := AWideString;
  Flast_name_lat_Specified := True;
end;

function PersonalData.last_name_lat_Specified(Index: Integer): boolean;
begin
  Result := Flast_name_lat_Specified;
end;

procedure PersonalData.Setname_(Index: Integer; const AWideString: WideString);
begin
  Fname_ := AWideString;
  Fname__Specified := True;
end;

function PersonalData.name__Specified(Index: Integer): boolean;
begin
  Result := Fname__Specified;
end;

procedure PersonalData.Setname_bel(Index: Integer; const AWideString: WideString);
begin
  Fname_bel := AWideString;
  Fname_bel_Specified := True;
end;

function PersonalData.name_bel_Specified(Index: Integer): boolean;
begin
  Result := Fname_bel_Specified;
end;

procedure PersonalData.Setname_lat(Index: Integer; const AWideString: WideString);
begin
  Fname_lat := AWideString;
  Fname_lat_Specified := True;
end;

function PersonalData.name_lat_Specified(Index: Integer): boolean;
begin
  Result := Fname_lat_Specified;
end;

procedure PersonalData.Setpatronymic(Index: Integer; const AWideString: WideString);
begin
  Fpatronymic := AWideString;
  Fpatronymic_Specified := True;
end;

function PersonalData.patronymic_Specified(Index: Integer): boolean;
begin
  Result := Fpatronymic_Specified;
end;

procedure PersonalData.Setpatronymic_bel(Index: Integer; const AWideString: WideString);
begin
  Fpatronymic_bel := AWideString;
  Fpatronymic_bel_Specified := True;
end;

function PersonalData.patronymic_bel_Specified(Index: Integer): boolean;
begin
  Result := Fpatronymic_bel_Specified;
end;

procedure PersonalData.Setpatronymic_lat(Index: Integer; const AWideString: WideString);
begin
  Fpatronymic_lat := AWideString;
  Fpatronymic_lat_Specified := True;
end;

function PersonalData.patronymic_lat_Specified(Index: Integer): boolean;
begin
  Result := Fpatronymic_lat_Specified;
end;

procedure PersonalData.Setsex(Index: Integer; const AClassifier: Classifier);
begin
  Fsex := AClassifier;
  Fsex_Specified := True;
end;

function PersonalData.sex_Specified(Index: Integer): boolean;
begin
  Result := Fsex_Specified;
end;

procedure PersonalData.Setbirth_day(Index: Integer; const AWideString: WideString);
begin
  Fbirth_day := AWideString;
  Fbirth_day_Specified := True;
end;

function PersonalData.birth_day_Specified(Index: Integer): boolean;
begin
  Result := Fbirth_day_Specified;
end;

procedure PersonalData.Setbirth_place(Index: Integer; const Abirth_place: birth_place);
begin
  Fbirth_place := Abirth_place;
  Fbirth_place_Specified := True;
end;

function PersonalData.birth_place_Specified(Index: Integer): boolean;
begin
  Result := Fbirth_place_Specified;
end;

procedure PersonalData.Setcitizenship(Index: Integer; const AClassifier: Classifier);
begin
  Fcitizenship := AClassifier;
  Fcitizenship_Specified := True;
end;

function PersonalData.citizenship_Specified(Index: Integer): boolean;
begin
  Result := Fcitizenship_Specified;
end;

procedure PersonalData.Setstatus(Index: Integer; const AClassifier: Classifier);
begin
  Fstatus := AClassifier;
  Fstatus_Specified := True;
end;

function PersonalData.status_Specified(Index: Integer): boolean;
begin
  Result := Fstatus_Specified;
end;

procedure PersonalData.Setdocument(Index: Integer; const AArray_Of_Document: Array_Of_Document);
begin
  Fdocument := AArray_Of_Document;
  Fdocument_Specified := True;
end;

function PersonalData.document_Specified(Index: Integer): boolean;
begin
  Result := Fdocument_Specified;
end;

procedure PersonalData.Setphoto(Index: Integer; const AArray_Of_photoInfo: Array_Of_photoInfo);
begin
  Fphoto := AArray_Of_photoInfo;
  Fphoto_Specified := True;
end;

function PersonalData.photo_Specified(Index: Integer): boolean;
begin
  Result := Fphoto_Specified;
end;

procedure PersonalData.Setnationality_data(Index: Integer; const AArray_Of_Citizenship: Array_Of_Citizenship);
begin
  Fnationality_data := AArray_Of_Citizenship;
  Fnationality_data_Specified := True;
end;

function PersonalData.nationality_data_Specified(Index: Integer): boolean;
begin
  Result := Fnationality_data_Specified;
end;

procedure PersonalData.Setnationality(Index: Integer; const Anationality: nationality);
begin
  Fnationality := Anationality;
  Fnationality_Specified := True;
end;

function PersonalData.nationality_Specified(Index: Integer): boolean;
begin
  Result := Fnationality_Specified;
end;

procedure PersonalData.Setaddress(Index: Integer; const AAddress: Address);
begin
  Faddress := AAddress;
  Faddress_Specified := True;
end;

function PersonalData.address_Specified(Index: Integer): boolean;
begin
  Result := Faddress_Specified;
end;

procedure PersonalData.Settemp_addresses(Index: Integer; const Atemp_addresses: temp_addresses);
begin
  Ftemp_addresses := Atemp_addresses;
  Ftemp_addresses_Specified := True;
end;

function PersonalData.temp_addresses_Specified(Index: Integer): boolean;
begin
  Result := Ftemp_addresses_Specified;
end;

procedure PersonalData.Setdeaths(Index: Integer; const Adeaths: deaths);
begin
  Fdeaths := Adeaths;
  Fdeaths_Specified := True;
end;

function PersonalData.deaths_Specified(Index: Integer): boolean;
begin
  Result := Fdeaths_Specified;
end;

procedure PersonalData.Setburials(Index: Integer; const Aburials: burials);
begin
  Fburials := Aburials;
  Fburials_Specified := True;
end;

function PersonalData.burials_Specified(Index: Integer): boolean;
begin
  Result := Fburials_Specified;
end;

procedure PersonalData.Setguardianships(Index: Integer; const Aguardianships: guardianships);
begin
  Fguardianships := Aguardianships;
  Fguardianships_Specified := True;
end;

function PersonalData.guardianships_Specified(Index: Integer): boolean;
begin
  Result := Fguardianships_Specified;
end;

procedure PersonalData.Settrusteeships(Index: Integer; const Atrusteeships: trusteeships);
begin
  Ftrusteeships := Atrusteeships;
  Ftrusteeships_Specified := True;
end;

function PersonalData.trusteeships_Specified(Index: Integer): boolean;
begin
  Result := Ftrusteeships_Specified;
end;

procedure PersonalData.Setfamily(Index: Integer; const AFamilyData: FamilyData);
begin
  Ffamily := AFamilyData;
  Ffamily_Specified := True;
end;

function PersonalData.family_Specified(Index: Integer): boolean;
begin
  Result := Ffamily_Specified;
end;

procedure PersonalData.Seteducations(Index: Integer; const Aeducations: educations);
begin
  Feducations := Aeducations;
  Feducations_Specified := True;
end;

function PersonalData.educations_Specified(Index: Integer): boolean;
begin
  Result := Feducations_Specified;
end;

procedure PersonalData.SetscienceRanks(Index: Integer; const AscienceRanks: scienceRanks);
begin
  FscienceRanks := AscienceRanks;
  FscienceRanks_Specified := True;
end;

function PersonalData.scienceRanks_Specified(Index: Integer): boolean;
begin
  Result := FscienceRanks_Specified;
end;

procedure PersonalData.SetscienceDegrees(Index: Integer; const AscienceDegrees: scienceDegrees);
begin
  FscienceDegrees := AscienceDegrees;
  FscienceDegrees_Specified := True;
end;

function PersonalData.scienceDegrees_Specified(Index: Integer): boolean;
begin
  Result := FscienceDegrees_Specified;
end;

procedure PersonalData.Setemployment_status_info(Index: Integer; const AemploymentStatusInfo: employmentStatusInfo);
begin
  Femployment_status_info := AemploymentStatusInfo;
  Femployment_status_info_Specified := True;
end;

function PersonalData.employment_status_info_Specified(Index: Integer): boolean;
begin
  Result := Femployment_status_info_Specified;
end;

procedure PersonalData.Setemployments(Index: Integer; const Aemployments: employments);
begin
  Femployments := Aemployments;
  Femployments_Specified := True;
end;

function PersonalData.employments_Specified(Index: Integer): boolean;
begin
  Result := Femployments_Specified;
end;

procedure PersonalData.Setcourts(Index: Integer; const ACourtList: CourtList);
begin
  Fcourts := ACourtList;
  Fcourts_Specified := True;
end;

function PersonalData.courts_Specified(Index: Integer): boolean;
begin
  Result := Fcourts_Specified;
end;

procedure PersonalData.Setunemplyment_info(Index: Integer; const AunemploymentInfo: unemploymentInfo);
begin
  Funemplyment_info := AunemploymentInfo;
  Funemplyment_info_Specified := True;
end;

function PersonalData.unemplyment_info_Specified(Index: Integer): boolean;
begin
  Result := Funemplyment_info_Specified;
end;

procedure PersonalData.Setpensions(Index: Integer; const Apensions: pensions);
begin
  Fpensions := Apensions;
  Fpensions_Specified := True;
end;

function PersonalData.pensions_Specified(Index: Integer): boolean;
begin
  Result := Fpensions_Specified;
end;

procedure PersonalData.Setsalary_info(Index: Integer; const AsalaryInfo: salaryInfo);
begin
  Fsalary_info := AsalaryInfo;
  Fsalary_info_Specified := True;
end;

function PersonalData.salary_info_Specified(Index: Integer): boolean;
begin
  Result := Fsalary_info_Specified;
end;

procedure PersonalData.Setinsurances(Index: Integer; const Ainsurances: insurances);
begin
  Finsurances := Ainsurances;
  Finsurances_Specified := True;
end;

function PersonalData.insurances_Specified(Index: Integer): boolean;
begin
  Result := Finsurances_Specified;
end;

procedure PersonalData.Settaxies(Index: Integer; const Ataxies: taxies);
begin
  Ftaxies := Ataxies;
  Ftaxies_Specified := True;
end;

function PersonalData.taxies_Specified(Index: Integer): boolean;
begin
  Result := Ftaxies_Specified;
end;

procedure PersonalData.Setmilitaries(Index: Integer; const Amilitaries: militaries);
begin
  Fmilitaries := Amilitaries;
  Fmilitaries_Specified := True;
end;

function PersonalData.militaries_Specified(Index: Integer): boolean;
begin
  Result := Fmilitaries_Specified;
end;

procedure PersonalData.Setdisabilities(Index: Integer; const Adisabilities: disabilities);
begin
  Fdisabilities := Adisabilities;
  Fdisabilities_Specified := True;
end;

function PersonalData.disabilities_Specified(Index: Integer): boolean;
begin
  Result := Fdisabilities_Specified;
end;

procedure PersonalData.Sethistory(Index: Integer; const AHistory: History);
begin
  Fhistory := AHistory;
  Fhistory_Specified := True;
end;

function PersonalData.history_Specified(Index: Integer): boolean;
begin
  Result := Fhistory_Specified;
end;

destructor FamilyDataHistory.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Ffather)-1 do
    FreeAndNil(Ffather[I]);
  SetLength(Ffather, 0);
  for I := 0 to Length(Fmather)-1 do
    FreeAndNil(Fmather[I]);
  SetLength(Fmather, 0);
  for I := 0 to Length(Fwife)-1 do
    FreeAndNil(Fwife[I]);
  SetLength(Fwife, 0);
  for I := 0 to Length(Fhusband)-1 do
    FreeAndNil(Fhusband[I]);
  SetLength(Fhusband, 0);
  for I := 0 to Length(Fchild)-1 do
    FreeAndNil(Fchild[I]);
  SetLength(Fchild, 0);
  for I := 0 to Length(Fprnt_rights)-1 do
    FreeAndNil(Fprnt_rights[I]);
  SetLength(Fprnt_rights, 0);
  inherited Destroy;
end;

procedure FamilyDataHistory.Setfather(Index: Integer; const AArray_Of_familyInfo: Array_Of_familyInfo);
begin
  Ffather := AArray_Of_familyInfo;
  Ffather_Specified := True;
end;

function FamilyDataHistory.father_Specified(Index: Integer): boolean;
begin
  Result := Ffather_Specified;
end;

procedure FamilyDataHistory.Setmather(Index: Integer; const AArray_Of_familyInfo: Array_Of_familyInfo);
begin
  Fmather := AArray_Of_familyInfo;
  Fmather_Specified := True;
end;

function FamilyDataHistory.mather_Specified(Index: Integer): boolean;
begin
  Result := Fmather_Specified;
end;

procedure FamilyDataHistory.Setwife(Index: Integer; const AArray_Of_familyInfo: Array_Of_familyInfo);
begin
  Fwife := AArray_Of_familyInfo;
  Fwife_Specified := True;
end;

function FamilyDataHistory.wife_Specified(Index: Integer): boolean;
begin
  Result := Fwife_Specified;
end;

procedure FamilyDataHistory.Sethusband(Index: Integer; const AArray_Of_familyInfo: Array_Of_familyInfo);
begin
  Fhusband := AArray_Of_familyInfo;
  Fhusband_Specified := True;
end;

function FamilyDataHistory.husband_Specified(Index: Integer): boolean;
begin
  Result := Fhusband_Specified;
end;

procedure FamilyDataHistory.Setchild(Index: Integer; const AArray_Of_familyInfo: Array_Of_familyInfo);
begin
  Fchild := AArray_Of_familyInfo;
  Fchild_Specified := True;
end;

function FamilyDataHistory.child_Specified(Index: Integer): boolean;
begin
  Result := Fchild_Specified;
end;

procedure FamilyDataHistory.Setprnt_rights(Index: Integer; const Aprnt_rights2: prnt_rights2);
begin
  Fprnt_rights := Aprnt_rights2;
  Fprnt_rights_Specified := True;
end;

function FamilyDataHistory.prnt_rights_Specified(Index: Integer): boolean;
begin
  Result := Fprnt_rights_Specified;
end;

destructor FamilyData.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fchild)-1 do
    FreeAndNil(Fchild[I]);
  SetLength(Fchild, 0);
  for I := 0 to Length(Fprnt_rights)-1 do
    FreeAndNil(Fprnt_rights[I]);
  SetLength(Fprnt_rights, 0);
  FreeAndNil(Ffather);
  FreeAndNil(Fmather);
  FreeAndNil(Fmartial_status);
  FreeAndNil(Fwife);
  FreeAndNil(Fhusband);
  inherited Destroy;
end;

procedure FamilyData.Setfather(Index: Integer; const AfamilyInfo: familyInfo);
begin
  Ffather := AfamilyInfo;
  Ffather_Specified := True;
end;

function FamilyData.father_Specified(Index: Integer): boolean;
begin
  Result := Ffather_Specified;
end;

procedure FamilyData.Setmather(Index: Integer; const AfamilyInfo: familyInfo);
begin
  Fmather := AfamilyInfo;
  Fmather_Specified := True;
end;

function FamilyData.mather_Specified(Index: Integer): boolean;
begin
  Result := Fmather_Specified;
end;

procedure FamilyData.Setmartial_status(Index: Integer; const AmartialStatusInfo: martialStatusInfo);
begin
  Fmartial_status := AmartialStatusInfo;
  Fmartial_status_Specified := True;
end;

function FamilyData.martial_status_Specified(Index: Integer): boolean;
begin
  Result := Fmartial_status_Specified;
end;

procedure FamilyData.Setwife(Index: Integer; const AfamilyInfo: familyInfo);
begin
  Fwife := AfamilyInfo;
  Fwife_Specified := True;
end;

function FamilyData.wife_Specified(Index: Integer): boolean;
begin
  Result := Fwife_Specified;
end;

procedure FamilyData.Sethusband(Index: Integer; const AfamilyInfo: familyInfo);
begin
  Fhusband := AfamilyInfo;
  Fhusband_Specified := True;
end;

function FamilyData.husband_Specified(Index: Integer): boolean;
begin
  Result := Fhusband_Specified;
end;

procedure FamilyData.Setchild(Index: Integer; const AArray_Of_familyInfo: Array_Of_familyInfo);
begin
  Fchild := AArray_Of_familyInfo;
  Fchild_Specified := True;
end;

function FamilyData.child_Specified(Index: Integer): boolean;
begin
  Result := Fchild_Specified;
end;

procedure FamilyData.Setprnt_rights(Index: Integer; const Aprnt_rights: prnt_rights);
begin
  Fprnt_rights := Aprnt_rights;
  Fprnt_rights_Specified := True;
end;

function FamilyData.prnt_rights_Specified(Index: Integer): boolean;
begin
  Result := Fprnt_rights_Specified;
end;

destructor ResponseData.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fpersonal_data)-1 do
    FreeAndNil(Fpersonal_data[I]);
  SetLength(Fpersonal_data, 0);
  for I := 0 to Length(Fidentif_number)-1 do
    FreeAndNil(Fidentif_number[I]);
  SetLength(Fidentif_number, 0);
  inherited Destroy;
end;

procedure ResponseData.Setpersonal_data(Index: Integer; const AArray_Of_ResponsePerson: Array_Of_ResponsePerson);
begin
  Fpersonal_data := AArray_Of_ResponsePerson;
  Fpersonal_data_Specified := True;
end;

function ResponseData.personal_data_Specified(Index: Integer): boolean;
begin
  Result := Fpersonal_data_Specified;
end;

procedure ResponseData.Setidentif_number(Index: Integer; const AArray_Of_ResponseIdentif: Array_Of_ResponseIdentif);
begin
  Fidentif_number := AArray_Of_ResponseIdentif;
  Fidentif_number_Specified := True;
end;

function ResponseData.identif_number_Specified(Index: Integer): boolean;
begin
  Result := Fidentif_number_Specified;
end;

destructor RequestData.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fperson_request)-1 do
    FreeAndNil(Fperson_request[I]);
  SetLength(Fperson_request, 0);
  for I := 0 to Length(Fidentif_request)-1 do
    FreeAndNil(Fidentif_request[I]);
  SetLength(Fidentif_request, 0);
  inherited Destroy;
end;

procedure RequestData.Setperson_request(Index: Integer; const AArray_Of_PersonRequest: Array_Of_PersonRequest);
begin
  Fperson_request := AArray_Of_PersonRequest;
  Fperson_request_Specified := True;
end;

function RequestData.person_request_Specified(Index: Integer): boolean;
begin
  Result := Fperson_request_Specified;
end;

procedure RequestData.Setidentif_request(Index: Integer; const AArray_Of_IdentifRequest: Array_Of_IdentifRequest);
begin
  Fidentif_request := AArray_Of_IdentifRequest;
  Fidentif_request_Specified := True;
end;

function RequestData.identif_request_Specified(Index: Integer): boolean;
begin
  Result := Fidentif_request_Specified;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(GisunCommonWs), 'http://gisun.agatsystem.by/common/ws/', 'UTF-8');
  InvRegistry.RegisterAllSOAPActions(TypeInfo(GisunCommonWs), '||urn:getPersonIdentif|urn:getPersonList|urn:getPersonalData');
  InvRegistry.RegisterInvokeOptions(TypeInfo(GisunCommonWs), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(GisunCommonWs), ioLiteral);    // vadim
  RemClassRegistry.RegisterXSInfo(TypeInfo(LangValueList), 'http://gisun.agatsystem.by/common/types/', 'LangValueList');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ClassifierList), 'http://gisun.agatsystem.by/common/types/', 'ClassifierList');
  RemClassRegistry.RegisterSerializeOptions(TypeInfo(ClassifierList), [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(Classifier, 'http://gisun.agatsystem.by/common/types/', 'Classifier');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(Classifier), 'type_', 'type');
  RemClassRegistry.RegisterXSClass(LangValue, 'http://gisun.agatsystem.by/common/types/', 'LangValue');
  RemClassRegistry.RegisterXSClass(Document, 'http://gisun.agatsystem.by/common/types/', 'Document');
  RemClassRegistry.RegisterXSClass(ActData, 'http://gisun.agatsystem.by/common/types/', 'ActData');
  RemClassRegistry.RegisterXSClass(birth_place, 'http://gisun.agatsystem.by/common/types/', 'birth_place');
  RemClassRegistry.RegisterXSClass(Citizenship, 'http://gisun.agatsystem.by/common/types/', 'Citizenship');
  RemClassRegistry.RegisterXSInfo(TypeInfo(nationality), 'http://gisun.agatsystem.by/common/types/', 'nationality');
  RemClassRegistry.RegisterXSInfo(TypeInfo(temp_addresses), 'http://gisun.agatsystem.by/common/types/', 'temp_addresses');
  RemClassRegistry.RegisterXSInfo(TypeInfo(deaths), 'http://gisun.agatsystem.by/common/types/', 'deaths');
  RemClassRegistry.RegisterXSInfo(TypeInfo(burials), 'http://gisun.agatsystem.by/common/types/', 'burials');
  RemClassRegistry.RegisterXSInfo(TypeInfo(guardianships), 'http://gisun.agatsystem.by/common/types/', 'guardianships');
  RemClassRegistry.RegisterXSInfo(TypeInfo(trusteeships), 'http://gisun.agatsystem.by/common/types/', 'trusteeships');
  RemClassRegistry.RegisterXSInfo(TypeInfo(educations), 'http://gisun.agatsystem.by/common/types/', 'educations');
  RemClassRegistry.RegisterXSInfo(TypeInfo(scienceRanks), 'http://gisun.agatsystem.by/common/types/', 'scienceRanks');
  RemClassRegistry.RegisterXSInfo(TypeInfo(scienceDegrees), 'http://gisun.agatsystem.by/common/types/', 'scienceDegrees');
  RemClassRegistry.RegisterXSInfo(TypeInfo(employments), 'http://gisun.agatsystem.by/common/types/', 'employments');
  RemClassRegistry.RegisterXSInfo(TypeInfo(pensions), 'http://gisun.agatsystem.by/common/types/', 'pensions');
  RemClassRegistry.RegisterXSInfo(TypeInfo(insurances), 'http://gisun.agatsystem.by/common/types/', 'insurances');
  RemClassRegistry.RegisterXSInfo(TypeInfo(taxies), 'http://gisun.agatsystem.by/common/types/', 'taxies');
  RemClassRegistry.RegisterXSInfo(TypeInfo(militaries), 'http://gisun.agatsystem.by/common/types/', 'militaries');
  RemClassRegistry.RegisterXSInfo(TypeInfo(disabilities), 'http://gisun.agatsystem.by/common/types/', 'disabilities');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents), 'http://gisun.agatsystem.by/common/types/', 'documents');
  RemClassRegistry.RegisterXSClass(photoInfo, 'http://gisun.agatsystem.by/common/types/', 'photoInfo');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents2), 'http://gisun.agatsystem.by/common/types/', 'documents2', 'documents');
  RemClassRegistry.RegisterXSClass(Nationality2, 'http://gisun.agatsystem.by/common/types/', 'Nationality2', 'Nationality');
  RemClassRegistry.RegisterXSClass(Address, 'http://gisun.agatsystem.by/common/types/', 'Address');
  RemClassRegistry.RegisterXSClass(Death, 'http://gisun.agatsystem.by/common/types/', 'Death');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents3), 'http://gisun.agatsystem.by/common/types/', 'documents3', 'documents');
  RemClassRegistry.RegisterXSClass(deathInfo, 'http://gisun.agatsystem.by/common/types/', 'deathInfo');
  RemClassRegistry.RegisterXSClass(decease_place, 'http://gisun.agatsystem.by/common/types/', 'decease_place');
  RemClassRegistry.RegisterXSClass(burialData, 'http://gisun.agatsystem.by/common/types/', 'burialData');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents4), 'http://gisun.agatsystem.by/common/types/', 'documents4', 'documents');
  RemClassRegistry.RegisterXSClass(burialDataInfo, 'http://gisun.agatsystem.by/common/types/', 'burialDataInfo');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents5), 'http://gisun.agatsystem.by/common/types/', 'documents5', 'documents');
  RemClassRegistry.RegisterXSClass(guardianshipInfo, 'http://gisun.agatsystem.by/common/types/', 'guardianshipInfo');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents6), 'http://gisun.agatsystem.by/common/types/', 'documents6', 'documents');
  RemClassRegistry.RegisterXSClass(trusteeshipInfo, 'http://gisun.agatsystem.by/common/types/', 'trusteeshipInfo');
  RemClassRegistry.RegisterXSInfo(TypeInfo(prnt_rights), 'http://gisun.agatsystem.by/common/types/', 'prnt_rights');
  RemClassRegistry.RegisterXSClass(parentRightsInfo, 'http://gisun.agatsystem.by/common/types/', 'parentRightsInfo');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents7), 'http://gisun.agatsystem.by/common/types/', 'documents7', 'documents');
  RemClassRegistry.RegisterXSClass(familyInfo, 'http://gisun.agatsystem.by/common/types/', 'familyInfo');
  RemClassRegistry.RegisterXSClass(martialStatus, 'http://gisun.agatsystem.by/common/types/', 'martialStatus');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents8), 'http://gisun.agatsystem.by/common/types/', 'documents8', 'documents');
  RemClassRegistry.RegisterXSClass(martialStatusInfo, 'http://gisun.agatsystem.by/common/types/', 'martialStatusInfo');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents9), 'http://gisun.agatsystem.by/common/types/', 'documents9', 'documents');
  RemClassRegistry.RegisterXSClass(parentRightsData, 'http://gisun.agatsystem.by/common/types/', 'parentRightsData');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents10), 'http://gisun.agatsystem.by/common/types/', 'documents10', 'documents');
  RemClassRegistry.RegisterXSClass(educationInfo, 'http://gisun.agatsystem.by/common/types/', 'educationInfo');
  RemClassRegistry.RegisterXSClass(Education, 'http://gisun.agatsystem.by/common/types/', 'Education');
  RemClassRegistry.RegisterXSClass(ScienceRank, 'http://gisun.agatsystem.by/common/types/', 'ScienceRank');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents11), 'http://gisun.agatsystem.by/common/types/', 'documents11', 'documents');
  RemClassRegistry.RegisterXSClass(scienceRankInfo, 'http://gisun.agatsystem.by/common/types/', 'scienceRankInfo');
  RemClassRegistry.RegisterXSClass(ScienceDegree, 'http://gisun.agatsystem.by/common/types/', 'ScienceDegree');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents12), 'http://gisun.agatsystem.by/common/types/', 'documents12', 'documents');
  RemClassRegistry.RegisterXSClass(scienceDegreeInfo, 'http://gisun.agatsystem.by/common/types/', 'scienceDegreeInfo');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents13), 'http://gisun.agatsystem.by/common/types/', 'documents13', 'documents');
  RemClassRegistry.RegisterXSClass(employmentStatusInfo, 'http://gisun.agatsystem.by/common/types/', 'employmentStatusInfo');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents14), 'http://gisun.agatsystem.by/common/types/', 'documents14', 'documents');
  RemClassRegistry.RegisterXSClass(employmentInfo, 'http://gisun.agatsystem.by/common/types/', 'employmentInfo');
  RemClassRegistry.RegisterXSInfo(TypeInfo(employment_periods), 'http://gisun.agatsystem.by/common/types/', 'employment_periods');
  RemClassRegistry.RegisterXSClass(fszn, 'http://gisun.agatsystem.by/common/types/', 'fszn');
  RemClassRegistry.RegisterXSClass(employmentPeriod, 'http://gisun.agatsystem.by/common/types/', 'employmentPeriod');
  RemClassRegistry.RegisterXSInfo(TypeInfo(deaths2), 'http://gisun.agatsystem.by/common/types/', 'deaths2', 'deaths');
  RemClassRegistry.RegisterXSInfo(TypeInfo(absents), 'http://gisun.agatsystem.by/common/types/', 'absents');
  RemClassRegistry.RegisterXSInfo(TypeInfo(unefficients), 'http://gisun.agatsystem.by/common/types/', 'unefficients');
  RemClassRegistry.RegisterXSInfo(TypeInfo(restrict_efficients), 'http://gisun.agatsystem.by/common/types/', 'restrict_efficients');
  RemClassRegistry.RegisterXSClass(CourtList, 'http://gisun.agatsystem.by/common/types/', 'CourtList');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents15), 'http://gisun.agatsystem.by/common/types/', 'documents15', 'documents');
  RemClassRegistry.RegisterXSClass(courtDeathInfo, 'http://gisun.agatsystem.by/common/types/', 'courtDeathInfo');
  RemClassRegistry.RegisterXSClass(courtDecision, 'http://gisun.agatsystem.by/common/types/', 'courtDecision');
  RemClassRegistry.RegisterXSClass(CourtDeathData, 'http://gisun.agatsystem.by/common/types/', 'CourtDeathData');
  RemClassRegistry.RegisterXSClass(CourtAbsentData, 'http://gisun.agatsystem.by/common/types/', 'CourtAbsentData');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents16), 'http://gisun.agatsystem.by/common/types/', 'documents16', 'documents');
  RemClassRegistry.RegisterXSClass(courtAbsentInfo, 'http://gisun.agatsystem.by/common/types/', 'courtAbsentInfo');
  RemClassRegistry.RegisterXSClass(CourtUnefficientData, 'http://gisun.agatsystem.by/common/types/', 'CourtUnefficientData');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents17), 'http://gisun.agatsystem.by/common/types/', 'documents17', 'documents');
  RemClassRegistry.RegisterXSClass(courtUnefficientInfo, 'http://gisun.agatsystem.by/common/types/', 'courtUnefficientInfo');
  RemClassRegistry.RegisterXSClass(CourtRestrictEfficientData, 'http://gisun.agatsystem.by/common/types/', 'CourtRestrictEfficientData');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents18), 'http://gisun.agatsystem.by/common/types/', 'documents18', 'documents');
  RemClassRegistry.RegisterXSClass(courtRestrictEfficientInfo, 'http://gisun.agatsystem.by/common/types/', 'courtRestrictEfficientInfo');
  RemClassRegistry.RegisterXSClass(unemploymentData, 'http://gisun.agatsystem.by/common/types/', 'unemploymentData');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents19), 'http://gisun.agatsystem.by/common/types/', 'documents19', 'documents');
  RemClassRegistry.RegisterXSClass(unemploymentInfo, 'http://gisun.agatsystem.by/common/types/', 'unemploymentInfo');
  RemClassRegistry.RegisterXSClass(Pension, 'http://gisun.agatsystem.by/common/types/', 'Pension');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents20), 'http://gisun.agatsystem.by/common/types/', 'documents20', 'documents');
  RemClassRegistry.RegisterXSClass(pensionInfo, 'http://gisun.agatsystem.by/common/types/', 'pensionInfo');
  RemClassRegistry.RegisterXSClass(salaryData, 'http://gisun.agatsystem.by/common/types/', 'salaryData');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents21), 'http://gisun.agatsystem.by/common/types/', 'documents21', 'documents');
  RemClassRegistry.RegisterXSClass(salaryInfo, 'http://gisun.agatsystem.by/common/types/', 'salaryInfo');
  RemClassRegistry.RegisterXSClass(Insurance, 'http://gisun.agatsystem.by/common/types/', 'Insurance');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents22), 'http://gisun.agatsystem.by/common/types/', 'documents22', 'documents');
  RemClassRegistry.RegisterXSClass(insuranceInfo, 'http://gisun.agatsystem.by/common/types/', 'insuranceInfo');
  RemClassRegistry.RegisterXSClass(Tax, 'http://gisun.agatsystem.by/common/types/', 'Tax');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents23), 'http://gisun.agatsystem.by/common/types/', 'documents23', 'documents');
  RemClassRegistry.RegisterXSClass(taxInfo, 'http://gisun.agatsystem.by/common/types/', 'taxInfo');
  RemClassRegistry.RegisterXSClass(Military, 'http://gisun.agatsystem.by/common/types/', 'Military');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents24), 'http://gisun.agatsystem.by/common/types/', 'documents24', 'documents');
  RemClassRegistry.RegisterXSClass(militaryInfo, 'http://gisun.agatsystem.by/common/types/', 'militaryInfo');
  RemClassRegistry.RegisterXSClass(Disability, 'http://gisun.agatsystem.by/common/types/', 'Disability');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents25), 'http://gisun.agatsystem.by/common/types/', 'documents25', 'documents');
  RemClassRegistry.RegisterXSClass(disabilityInfo, 'http://gisun.agatsystem.by/common/types/', 'disabilityInfo');
  RemClassRegistry.RegisterXSInfo(TypeInfo(query_params), 'http://gisun.agatsystem.by/common/types/', 'query_params');
  RemClassRegistry.RegisterXSClass(MessageCover, 'http://gisun.agatsystem.by/common/types/', 'MessageCover');
  RemClassRegistry.RegisterXSClass(QueryParam, 'http://gisun.agatsystem.by/common/types/', 'QueryParam');
  RemClassRegistry.RegisterXSInfo(TypeInfo(personal_history), 'http://gisun.agatsystem.by/common/ws/', 'personal_history');
  RemClassRegistry.RegisterXSInfo(TypeInfo(nationality3), 'http://gisun.agatsystem.by/common/ws/', 'nationality3', 'nationality');
  RemClassRegistry.RegisterXSInfo(TypeInfo(addresses), 'http://gisun.agatsystem.by/common/ws/', 'addresses');
  RemClassRegistry.RegisterXSInfo(TypeInfo(temp_addresses2), 'http://gisun.agatsystem.by/common/ws/', 'temp_addresses2', 'temp_addresses');
  RemClassRegistry.RegisterXSInfo(TypeInfo(deaths3), 'http://gisun.agatsystem.by/common/ws/', 'deaths3', 'deaths');
  RemClassRegistry.RegisterXSInfo(TypeInfo(burials2), 'http://gisun.agatsystem.by/common/ws/', 'burials2', 'burials');
  RemClassRegistry.RegisterXSInfo(TypeInfo(guardianships2), 'http://gisun.agatsystem.by/common/ws/', 'guardianships2', 'guardianships');
  RemClassRegistry.RegisterXSInfo(TypeInfo(trusteeships2), 'http://gisun.agatsystem.by/common/ws/', 'trusteeships2', 'trusteeships');
  RemClassRegistry.RegisterXSInfo(TypeInfo(educations2), 'http://gisun.agatsystem.by/common/ws/', 'educations2', 'educations');
  RemClassRegistry.RegisterXSInfo(TypeInfo(scienceRanks2), 'http://gisun.agatsystem.by/common/ws/', 'scienceRanks2', 'scienceRanks');
  RemClassRegistry.RegisterXSInfo(TypeInfo(scienceDegrees2), 'http://gisun.agatsystem.by/common/ws/', 'scienceDegrees2', 'scienceDegrees');
  RemClassRegistry.RegisterXSInfo(TypeInfo(employments2), 'http://gisun.agatsystem.by/common/ws/', 'employments2', 'employments');
  RemClassRegistry.RegisterXSInfo(TypeInfo(pensions2), 'http://gisun.agatsystem.by/common/ws/', 'pensions2', 'pensions');
  RemClassRegistry.RegisterXSInfo(TypeInfo(insurances2), 'http://gisun.agatsystem.by/common/ws/', 'insurances2', 'insurances');
  RemClassRegistry.RegisterXSInfo(TypeInfo(taxies2), 'http://gisun.agatsystem.by/common/ws/', 'taxies2', 'taxies');
  RemClassRegistry.RegisterXSInfo(TypeInfo(militaries2), 'http://gisun.agatsystem.by/common/ws/', 'militaries2', 'militaries');
  RemClassRegistry.RegisterXSInfo(TypeInfo(disabilities2), 'http://gisun.agatsystem.by/common/ws/', 'disabilities2', 'disabilities');
  RemClassRegistry.RegisterXSInfo(TypeInfo(documents26), 'http://gisun.agatsystem.by/common/ws/', 'documents26', 'documents');
  RemClassRegistry.RegisterXSClass(personalDataInfo, 'http://gisun.agatsystem.by/common/ws/', 'personalDataInfo');
  RemClassRegistry.RegisterXSInfo(TypeInfo(prnt_rights2), 'http://gisun.agatsystem.by/common/ws/', 'prnt_rights2', 'prnt_rights');
  RemClassRegistry.RegisterXSClass(LexemStatus, 'http://gisun.agatsystem.by/common/ws/', 'LexemStatus');
  RemClassRegistry.RegisterXSClass(RegisterResponse, 'http://gisun.agatsystem.by/common/ws/', 'RegisterResponse');
  RemClassRegistry.RegisterSerializeOptions(RegisterResponse, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(ResponsePerson, 'http://gisun.agatsystem.by/common/ws/', 'ResponsePerson');
  RemClassRegistry.RegisterXSClass(ResponseIdentif, 'http://gisun.agatsystem.by/common/ws/', 'ResponseIdentif');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ErrorList), 'http://gisun.agatsystem.by/common/ws/', 'ErrorList');
  RemClassRegistry.RegisterXSClass(WsError, 'http://gisun.agatsystem.by/common/ws/', 'WsError');
  RemClassRegistry.RegisterXSClass(WsException, 'http://gisun.agatsystem.by/common/ws/', 'WsException');
  RemClassRegistry.RegisterXSClass(RegisterPersonListRequest, 'http://gisun.agatsystem.by/common/ws/', 'RegisterPersonListRequest');
  RemClassRegistry.RegisterSerializeOptions(RegisterPersonListRequest, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(PersonListRequest, 'http://gisun.agatsystem.by/common/ws/', 'PersonListRequest');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(PersonListRequest), 'name_', 'name');
  RemClassRegistry.RegisterXSClass(RegisterRequest, 'http://gisun.agatsystem.by/common/ws/', 'RegisterRequest');
  RemClassRegistry.RegisterSerializeOptions(RegisterRequest, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(PersonRequest, 'http://gisun.agatsystem.by/common/ws/', 'PersonRequest');
  RemClassRegistry.RegisterXSClass(IdentifRequest, 'http://gisun.agatsystem.by/common/ws/', 'IdentifRequest');
  RemClassRegistry.RegisterXSInfo(TypeInfo(LexemStatusList), 'http://gisun.agatsystem.by/common/ws/', 'LexemStatusList');
  RemClassRegistry.RegisterSerializeOptions(TypeInfo(LexemStatusList), [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(ClassifierChangeRequest, 'http://gisun.agatsystem.by/common/ws/', 'ClassifierChangeRequest');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(ClassifierChangeRequest), 'type_', 'type');
  RemClassRegistry.RegisterSerializeOptions(ClassifierChangeRequest, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(RegisterPersonIdentifRequest, 'http://gisun.agatsystem.by/common/ws/', 'RegisterPersonIdentifRequest');
  RemClassRegistry.RegisterSerializeOptions(RegisterPersonIdentifRequest, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(PersonIdentifRequest, 'http://gisun.agatsystem.by/common/ws/', 'PersonIdentifRequest');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(PersonIdentifRequest), 'name_', 'name');
  RemClassRegistry.RegisterXSClass(classifier_change_request, 'http://gisun.agatsystem.by/common/ws/', 'classifier_change_request');
  RemClassRegistry.RegisterXSClass(exception, 'http://gisun.agatsystem.by/common/ws/', 'exception');
  RemClassRegistry.RegisterXSClass(getClassifierChange, 'http://gisun.agatsystem.by/common/ws/', 'getClassifierChange');
  RemClassRegistry.RegisterXSInfo(TypeInfo(getClassifierChangeResponse), 'http://gisun.agatsystem.by/common/ws/', 'getClassifierChangeResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(getLexemStatus), 'http://gisun.agatsystem.by/common/ws/', 'getLexemStatus');
  RemClassRegistry.RegisterXSInfo(TypeInfo(getLexemStatusResponse), 'http://gisun.agatsystem.by/common/ws/', 'getLexemStatusResponse');
  RemClassRegistry.RegisterXSClass(register_person_identif_request, 'http://gisun.agatsystem.by/common/ws/', 'register_person_identif_request');
  RemClassRegistry.RegisterXSClass(register_person_list_request, 'http://gisun.agatsystem.by/common/ws/', 'register_person_list_request');
  RemClassRegistry.RegisterXSClass(register_request, 'http://gisun.agatsystem.by/common/ws/', 'register_request');
  RemClassRegistry.RegisterXSClass(register_response, 'http://gisun.agatsystem.by/common/ws/', 'register_response');
  RemClassRegistry.RegisterXSClass(value, 'http://gisun.agatsystem.by/common/types/', 'value');
  RemClassRegistry.RegisterXSClass(classifier2, 'http://gisun.agatsystem.by/common/types/', 'classifier2', 'classifier');
  RemClassRegistry.RegisterXSClass(nationality_info, 'http://gisun.agatsystem.by/common/types/', 'nationality_info');
  RemClassRegistry.RegisterXSClass(temp_address, 'http://gisun.agatsystem.by/common/types/', 'temp_address');
  RemClassRegistry.RegisterXSClass(death2, 'http://gisun.agatsystem.by/common/types/', 'death2', 'death');
  RemClassRegistry.RegisterXSClass(burial_info, 'http://gisun.agatsystem.by/common/types/', 'burial_info');
  RemClassRegistry.RegisterXSClass(guardianship_info, 'http://gisun.agatsystem.by/common/types/', 'guardianship_info');
  RemClassRegistry.RegisterXSClass(trusteeship_info, 'http://gisun.agatsystem.by/common/types/', 'trusteeship_info');
  RemClassRegistry.RegisterXSClass(educations_info, 'http://gisun.agatsystem.by/common/types/', 'educations_info');
  RemClassRegistry.RegisterXSClass(science_ranks_info, 'http://gisun.agatsystem.by/common/types/', 'science_ranks_info');
  RemClassRegistry.RegisterXSClass(science_degrees_info, 'http://gisun.agatsystem.by/common/types/', 'science_degrees_info');
  RemClassRegistry.RegisterXSClass(employment_info, 'http://gisun.agatsystem.by/common/types/', 'employment_info');
  RemClassRegistry.RegisterXSClass(pensions_info, 'http://gisun.agatsystem.by/common/types/', 'pensions_info');
  RemClassRegistry.RegisterXSClass(insurances_info, 'http://gisun.agatsystem.by/common/types/', 'insurances_info');
  RemClassRegistry.RegisterXSClass(taxies_info, 'http://gisun.agatsystem.by/common/types/', 'taxies_info');
  RemClassRegistry.RegisterXSClass(militaries_info, 'http://gisun.agatsystem.by/common/types/', 'militaries_info');
  RemClassRegistry.RegisterXSClass(disability_info, 'http://gisun.agatsystem.by/common/types/', 'disability_info');
  RemClassRegistry.RegisterXSClass(document2, 'http://gisun.agatsystem.by/common/types/', 'document2', 'document');
  RemClassRegistry.RegisterXSClass(prnt_rights_data, 'http://gisun.agatsystem.by/common/types/', 'prnt_rights_data');
  RemClassRegistry.RegisterXSClass(employment_period, 'http://gisun.agatsystem.by/common/types/', 'employment_period');
  RemClassRegistry.RegisterXSClass(death_info, 'http://gisun.agatsystem.by/common/types/', 'death_info');
  RemClassRegistry.RegisterXSClass(absent_info, 'http://gisun.agatsystem.by/common/types/', 'absent_info');
  RemClassRegistry.RegisterXSClass(unefficient_info, 'http://gisun.agatsystem.by/common/types/', 'unefficient_info');
  RemClassRegistry.RegisterXSClass(restrict_efficient_info, 'http://gisun.agatsystem.by/common/types/', 'restrict_efficient_info');
  RemClassRegistry.RegisterXSClass(param, 'http://gisun.agatsystem.by/common/types/', 'param');
  RemClassRegistry.RegisterXSClass(personal_data_info, 'http://gisun.agatsystem.by/common/ws/', 'personal_data_info');
  RemClassRegistry.RegisterXSClass(address2, 'http://gisun.agatsystem.by/common/ws/', 'address2', 'address');
  RemClassRegistry.RegisterXSClass(error, 'http://gisun.agatsystem.by/common/ws/', 'error');
  RemClassRegistry.RegisterXSClass(lexemStatus2, 'http://gisun.agatsystem.by/common/ws/', 'lexemStatus2', 'lexemStatus');
  RemClassRegistry.RegisterXSInfo(TypeInfo(Array_Of_Document), 'http://gisun.agatsystem.by/common/types/', 'Array_Of_Document');
  RemClassRegistry.RegisterXSInfo(TypeInfo(Array_Of_photoInfo), 'http://gisun.agatsystem.by/common/types/', 'Array_Of_photoInfo');
  RemClassRegistry.RegisterXSInfo(TypeInfo(Array_Of_Citizenship), 'http://gisun.agatsystem.by/common/types/', 'Array_Of_Citizenship');
  RemClassRegistry.RegisterXSClass(History, 'http://gisun.agatsystem.by/common/ws/', 'History');
  RemClassRegistry.RegisterXSClass(PersonalData, 'http://gisun.agatsystem.by/common/types/', 'PersonalData');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(PersonalData), 'name_', 'name');
  RemClassRegistry.RegisterXSClass(personalData2, 'http://gisun.agatsystem.by/common/types/', 'personalData2', 'personalData');
  RemClassRegistry.RegisterXSInfo(TypeInfo(Array_Of_familyInfo), 'http://gisun.agatsystem.by/common/types/', 'Array_Of_familyInfo');
  RemClassRegistry.RegisterXSClass(FamilyDataHistory, 'http://gisun.agatsystem.by/common/ws/', 'FamilyDataHistory');
  RemClassRegistry.RegisterXSClass(FamilyData, 'http://gisun.agatsystem.by/common/types/', 'FamilyData');
  RemClassRegistry.RegisterXSInfo(TypeInfo(Array_Of_ResponsePerson), 'http://gisun.agatsystem.by/common/ws/', 'Array_Of_ResponsePerson');
  RemClassRegistry.RegisterXSInfo(TypeInfo(Array_Of_ResponseIdentif), 'http://gisun.agatsystem.by/common/ws/', 'Array_Of_ResponseIdentif');
  RemClassRegistry.RegisterXSClass(ResponseData, 'http://gisun.agatsystem.by/common/ws/', 'ResponseData');
  RemClassRegistry.RegisterXSInfo(TypeInfo(Array_Of_PersonRequest), 'http://gisun.agatsystem.by/common/ws/', 'Array_Of_PersonRequest');
  RemClassRegistry.RegisterXSInfo(TypeInfo(Array_Of_IdentifRequest), 'http://gisun.agatsystem.by/common/ws/', 'Array_Of_IdentifRequest');
  RemClassRegistry.RegisterXSClass(RequestData, 'http://gisun.agatsystem.by/common/ws/', 'RequestData');

end.