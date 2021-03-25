// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://todes.by:8084/gisun/class/ws?wsdl
//  >Import : http://todes.by:8084/gisun/class/ws?wsdl:0
//  >Import : http://todes.by:8084/gisun/class/ws?xsd=1
//  >Import : http://todes.by:8084/gisun/class/ws?xsd=2
//  >Import : http://todes.by:8084/gisun/class/ws?xsd=3
//  >Import : http://todes.by:8084/gisun/class/ws?wsdl:1
//  >Import : http://todes.by:8084/gisun/class/ws?wsdl:2
//  >Import : http://todes.by:8084/gisun/class/ws?wsdl:3
//  >Import : http://todes.by:8084/gisun/class/ws?xsd=4
//  >Import : http://todes.by:8084/gisun/class/ws?wsdl:4
//  >Import : http://todes.by:8084/gisun/class/ws?xsd=5
// Encoding : UTF-8
// Version  : 1.0
// (11.07.2012 14:07:12 - - $Rev: 10138 $)
// ************************************************************************ //

unit wsClassif;

interface

//uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;  было
uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns, OPConvert;

const
  IS_OPTN = $0001;
  IS_UNBD = $0002;
  IS_UNQL = $0008;
  IS_ATTR = $0010;
  IS_TEXT = $0020;
  IS_REF  = $0080;


type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Borland types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:dateTime        - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:int             - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:integer         - "http://www.w3.org/2001/XMLSchema"[Gbl]

  MessageCover         = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  Classifier           = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  LangValue            = class;                 { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  WsException          = class;                 { "http://gisun.agatsystem.by/common/"[Flt][GblCplx] }
  WsError              = class;                 { "http://gisun.agatsystem.by/common/ws/"[GblCplx] }
  exception            = class;                 { "http://gisun.agatsystem.by/common/ws/"[Flt][GblElm] }
  ateCategory          = class;                 { "http://gisun.agatsystem.by/classif/ws/"[GblCplx] }
  ateObject            = class;                 { "http://gisun.agatsystem.by/classif/ws/"[GblCplx] }
  AteChanges           = class;                 { "http://gisun.agatsystem.by/classif/ws/"[Lit][GblCplx] }
  AteRequestData       = class;                 { "http://gisun.agatsystem.by/classif/ws/"[GblCplx] }
  AteRequest           = class;                 { "http://gisun.agatsystem.by/classif/ws/"[Lit][GblCplx] }
  ErrorListException   = class;                 { "http://gisun.agatsystem.by/classif/ws/"[Flt][GblCplx] }
  ClRequest            = class;                 { "http://gisun.agatsystem.by/classif/ws/"[Lit][GblCplx] }
  ClRequestData        = class;                 { "http://gisun.agatsystem.by/classif/ws/"[GblCplx] }
  ClChanges            = class;                 { "http://gisun.agatsystem.by/classif/ws/"[Lit][GblCplx] }
  AteInterval          = class;                 { "http://gisun.agatsystem.by/classif/ws/"[Lit][GblCplx] }
  AteIntervalData      = class;                 { "http://gisun.agatsystem.by/classif/ws/"[GblCplx] }
  ErrorListException2  = class;                 { "http://gisun.agatsystem.by/classif/ws/"[Flt][GblElm] }
  ateCategory2         = class;                 { "http://gisun.agatsystem.by/classif/ws/"[GblElm] }
  ateObject2           = class;                 { "http://gisun.agatsystem.by/classif/ws/"[GblElm] }
  ate_changes          = class;                 { "http://gisun.agatsystem.by/classif/types/"[Lit][GblElm] }
  ate_interval         = class;                 { "http://gisun.agatsystem.by/classif/types/"[Lit][GblElm] }
  ate_request          = class;                 { "http://gisun.agatsystem.by/classif/types/"[Lit][GblElm] }
  cl_changes           = class;                 { "http://gisun.agatsystem.by/classif/types/"[Lit][GblElm] }
  cl_request           = class;                 { "http://gisun.agatsystem.by/classif/types/"[Lit][GblElm] }
  value                = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  classifier2          = class;                 { "http://gisun.agatsystem.by/common/types/"[Alias] }
  error                = class;                 { "http://gisun.agatsystem.by/common/ws/"[Alias] }
  AteChangeData        = class;                 { "http://gisun.agatsystem.by/classif/ws/"[GblCplx] }



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
    procedure Setparent_message_id(Index: Integer; const AWideString: WideString);
    function  parent_message_id_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property message_id:        WideString   read Fmessage_id write Fmessage_id;
    property message_type:      Classifier   read Fmessage_type write Fmessage_type;
    property message_time:      TXSDateTime  read Fmessage_time write Fmessage_time;
    property message_source:    Classifier   read Fmessage_source write Fmessage_source;
    property parent_message_id: WideString   Index (IS_OPTN) read Fparent_message_id write Setparent_message_id stored parent_message_id_Specified;
  end;

  LangValueList = array of value;               { "http://gisun.agatsystem.by/common/types/"[GblCplx] }
  ClassifierList = array of classifier2;        { "http://gisun.agatsystem.by/common/types/"[GblCplx] }


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

  ErrorList  = array of error;                  { "http://gisun.agatsystem.by/common/ws/"[GblCplx] }


  // ************************************************************************ //
  // XML       : WsException, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/
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
    procedure Seterror_place(Index: Integer; const AWideString: WideString);
    function  error_place_Specified(Index: Integer): boolean;
    procedure Setwrong_value(Index: Integer; const AWideString: WideString);
    function  wrong_value_Specified(Index: Integer): boolean;
    procedure Setcorrect_value(Index: Integer; const AWideString: WideString);
    function  correct_value_Specified(Index: Integer): boolean;
    procedure Setcheck_name(Index: Integer; const AWideString: WideString);
    function  check_name_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property error_code:    Classifier  read Ferror_code write Ferror_code;
    property error_place:   WideString  Index (IS_OPTN) read Ferror_place write Seterror_place stored error_place_Specified;
    property wrong_value:   WideString  Index (IS_OPTN) read Fwrong_value write Setwrong_value stored wrong_value_Specified;
    property correct_value: WideString  Index (IS_OPTN) read Fcorrect_value write Setcorrect_value stored correct_value_Specified;
    property check_name:    WideString  Index (IS_OPTN) read Fcheck_name write Setcheck_name stored check_name_Specified;
  end;

  errorList2      =  type ErrorList;      { "http://gisun.agatsystem.by/common/ws/"[GblElm] }


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
  // XML       : ateCategory, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/classif/ws/
  // ************************************************************************ //
  ateCategory = class(TRemotable)
  private
    Fcategory: Int64;
    Fcategory_Specified: boolean;
    Ffront: Int64;
    Ffront_Specified: boolean;
    FnamecategoryBy: WideString;
    FnamecategoryBy_Specified: boolean;
    FnamecategoryRu: WideString;
    FnamecategoryRu_Specified: boolean;
    FshortnameBy: WideString;
    FshortnameBy_Specified: boolean;
    FshortnameRu: WideString;
    FshortnameRu_Specified: boolean;
    procedure Setcategory(Index: Integer; const AInt64: Int64);
    function  category_Specified(Index: Integer): boolean;
    procedure Setfront(Index: Integer; const AInt64: Int64);
    function  front_Specified(Index: Integer): boolean;
    procedure SetnamecategoryBy(Index: Integer; const AWideString: WideString);
    function  namecategoryBy_Specified(Index: Integer): boolean;
    procedure SetnamecategoryRu(Index: Integer; const AWideString: WideString);
    function  namecategoryRu_Specified(Index: Integer): boolean;
    procedure SetshortnameBy(Index: Integer; const AWideString: WideString);
    function  shortnameBy_Specified(Index: Integer): boolean;
    procedure SetshortnameRu(Index: Integer; const AWideString: WideString);
    function  shortnameRu_Specified(Index: Integer): boolean;
  published
    property category:       Int64       Index (IS_OPTN or IS_UNQL) read Fcategory write Setcategory stored category_Specified;
    property front:          Int64       Index (IS_OPTN or IS_UNQL) read Ffront write Setfront stored front_Specified;
    property namecategoryBy: WideString  Index (IS_OPTN or IS_UNQL) read FnamecategoryBy write SetnamecategoryBy stored namecategoryBy_Specified;
    property namecategoryRu: WideString  Index (IS_OPTN or IS_UNQL) read FnamecategoryRu write SetnamecategoryRu stored namecategoryRu_Specified;
    property shortnameBy:    WideString  Index (IS_OPTN or IS_UNQL) read FshortnameBy write SetshortnameBy stored shortnameBy_Specified;
    property shortnameRu:    WideString  Index (IS_OPTN or IS_UNQL) read FshortnameRu write SetshortnameRu stored shortnameRu_Specified;
  end;



  // ************************************************************************ //
  // XML       : ateObject, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/classif/ws/
  // ************************************************************************ //
  ateObject = class(TRemotable)
  private
    Fcategory: ateCategory;
    Fcategory_Specified: boolean;
    Fdatein: TXSDateTime;
    Fdatein_Specified: boolean;
    Fdateout: TXSDateTime;
    Fdateout_Specified: boolean;
    FnameobjectBy: WideString;
    FnameobjectBy_Specified: boolean;
    FnameobjectRu: WideString;
    FnameobjectRu_Specified: boolean;
    Fobjectnumber: Int64;
    Fobjectnumber_Specified: boolean;
    Fparentobjectnumber: Int64;
    Fparentobjectnumber_Specified: boolean;
    Fsoato: WideString;
    Fsoato_Specified: boolean;
    procedure Setcategory(Index: Integer; const AateCategory: ateCategory);
    function  category_Specified(Index: Integer): boolean;
    procedure Setdatein(Index: Integer; const ATXSDateTime: TXSDateTime);
    function  datein_Specified(Index: Integer): boolean;
    procedure Setdateout(Index: Integer; const ATXSDateTime: TXSDateTime);
    function  dateout_Specified(Index: Integer): boolean;
    procedure SetnameobjectBy(Index: Integer; const AWideString: WideString);
    function  nameobjectBy_Specified(Index: Integer): boolean;
    procedure SetnameobjectRu(Index: Integer; const AWideString: WideString);
    function  nameobjectRu_Specified(Index: Integer): boolean;
    procedure Setobjectnumber(Index: Integer; const AInt64: Int64);
    function  objectnumber_Specified(Index: Integer): boolean;
    procedure Setparentobjectnumber(Index: Integer; const AInt64: Int64);
    function  parentobjectnumber_Specified(Index: Integer): boolean;
    procedure Setsoato(Index: Integer; const AWideString: WideString);
    function  soato_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property category:           ateCategory  Index (IS_OPTN or IS_UNQL) read Fcategory write Setcategory stored category_Specified;
    property datein:             TXSDateTime  Index (IS_OPTN or IS_UNQL) read Fdatein write Setdatein stored datein_Specified;
    property dateout:            TXSDateTime  Index (IS_OPTN or IS_UNQL) read Fdateout write Setdateout stored dateout_Specified;
    property nameobjectBy:       WideString   Index (IS_OPTN or IS_UNQL) read FnameobjectBy write SetnameobjectBy stored nameobjectBy_Specified;
    property nameobjectRu:       WideString   Index (IS_OPTN or IS_UNQL) read FnameobjectRu write SetnameobjectRu stored nameobjectRu_Specified;
    property objectnumber:       Int64        Index (IS_OPTN or IS_UNQL) read Fobjectnumber write Setobjectnumber stored objectnumber_Specified;
    property parentobjectnumber: Int64        Index (IS_OPTN or IS_UNQL) read Fparentobjectnumber write Setparentobjectnumber stored parentobjectnumber_Specified;
    property soato:              WideString   Index (IS_OPTN or IS_UNQL) read Fsoato write Setsoato stored soato_Specified;
  end;



  // ************************************************************************ //
  // XML       : AteChanges, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/classif/ws/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  AteChanges = class(TRemotable)
  private
    Fcover: MessageCover;
    Fchanges: AteChangeData;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:   MessageCover   Index (IS_UNQL) read Fcover write Fcover;
    property changes: AteChangeData  Index (IS_UNQL) read Fchanges write Fchanges;
  end;



  // ************************************************************************ //
  // XML       : AteRequestData, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/classif/ws/
  // ************************************************************************ //
  AteRequestData = class(TRemotable)
  private
    Fdate_from: TXSDateTime;
    Fdate_from_Specified: boolean;
    procedure Setdate_from(Index: Integer; const ATXSDateTime: TXSDateTime);
    function  date_from_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property date_from: TXSDateTime  Index (IS_OPTN or IS_UNQL) read Fdate_from write Setdate_from stored date_from_Specified;
  end;



  // ************************************************************************ //
  // XML       : AteRequest, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/classif/ws/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  AteRequest = class(TRemotable)
  private
    Fcover: MessageCover;
    Frequest: AteRequestData;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:   MessageCover    Index (IS_UNQL) read Fcover write Fcover;
    property request: AteRequestData  Index (IS_UNQL) read Frequest write Frequest;
  end;



  // ************************************************************************ //
  // XML       : ErrorListException, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/classif/ws/
  // Info      : Fault
  // ************************************************************************ //
  ErrorListException = class(ERemotableException)
  private
    FerrorList: errorList2;
    FerrorList_Specified: boolean;
    Fmessage_: WideString;
    Fmessage__Specified: boolean;
    procedure SeterrorList(Index: Integer; const AerrorList2: errorList2);
    function  errorList_Specified(Index: Integer): boolean;
    procedure Setmessage_(Index: Integer; const AWideString: WideString);
    function  message__Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property errorList: errorList2  Index (IS_OPTN or IS_UNQL or IS_REF) read FerrorList write SeterrorList stored errorList_Specified;
    property message_:  WideString  Index (IS_OPTN or IS_UNQL) read Fmessage_ write Setmessage_ stored message__Specified;
  end;



  // ************************************************************************ //
  // XML       : ClRequest, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/classif/ws/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  ClRequest = class(TRemotable)
  private
    Fcover: MessageCover;
    Frequest: ClRequestData;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:   MessageCover   Index (IS_UNQL) read Fcover write Fcover;
    property request: ClRequestData  Index (IS_UNQL) read Frequest write Frequest;
  end;



  // ************************************************************************ //
  // XML       : ClRequestData, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/classif/ws/
  // ************************************************************************ //
  ClRequestData = class(TRemotable)
  private
    Fcl_type: Integer;
    Fcl_type_Specified: boolean;
    Fdate_from: TXSDateTime;
    Fdate_from_Specified: boolean;
    procedure Setcl_type(Index: Integer; const AInteger: Integer);
    function  cl_type_Specified(Index: Integer): boolean;
    procedure Setdate_from(Index: Integer; const ATXSDateTime: TXSDateTime);
    function  date_from_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property cl_type:   Integer      Index (IS_OPTN or IS_UNQL) read Fcl_type write Setcl_type stored cl_type_Specified;
    property date_from: TXSDateTime  Index (IS_OPTN or IS_UNQL) read Fdate_from write Setdate_from stored date_from_Specified;
  end;



  // ************************************************************************ //
  // XML       : ClChanges, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/classif/ws/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  ClChanges = class(TRemotable)
  private
    Fcover: MessageCover;
    Fchanges: ClassifierList;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:   MessageCover    Index (IS_UNQL) read Fcover write Fcover;
    property changes: ClassifierList  Index (IS_UNQL) read Fchanges write Fchanges;
  end;



  // ************************************************************************ //
  // XML       : AteInterval, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/classif/ws/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  AteInterval = class(TRemotable)
  private
    Fcover: MessageCover;
    Frequest: AteIntervalData;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:   MessageCover     Index (IS_UNQL) read Fcover write Fcover;
    property request: AteIntervalData  Index (IS_UNQL) read Frequest write Frequest;
  end;



  // ************************************************************************ //
  // XML       : AteIntervalData, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/classif/ws/
  // ************************************************************************ //
  AteIntervalData = class(TRemotable)
  private
    Fnumber_from: Int64;
    Fnumber_from_Specified: boolean;
    Fnumber_to: Int64;
    Fnumber_to_Specified: boolean;
    procedure Setnumber_from(Index: Integer; const AInt64: Int64);
    function  number_from_Specified(Index: Integer): boolean;
    procedure Setnumber_to(Index: Integer; const AInt64: Int64);
    function  number_to_Specified(Index: Integer): boolean;
  published
    property number_from: Int64  Index (IS_OPTN or IS_UNQL) read Fnumber_from write Setnumber_from stored number_from_Specified;
    property number_to:   Int64  Index (IS_OPTN or IS_UNQL) read Fnumber_to write Setnumber_to stored number_to_Specified;
  end;



  // ************************************************************************ //
  // XML       : ErrorListException, global, <element>
  // Namespace : http://gisun.agatsystem.by/classif/ws/
  // Info      : Fault
  // ************************************************************************ //
  ErrorListException2 = class(ErrorListException)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ateCategory, global, <element>
  // Namespace : http://gisun.agatsystem.by/classif/ws/
  // ************************************************************************ //
  ateCategory2 = class(ateCategory)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ateObject, global, <element>
  // Namespace : http://gisun.agatsystem.by/classif/ws/
  // ************************************************************************ //
  ateObject2 = class(ateObject)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ate_changes, global, <element>
  // Namespace : http://gisun.agatsystem.by/classif/types/
  // Info      : Wrapper
  // ************************************************************************ //
  ate_changes = class(AteChanges)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ate_interval, global, <element>
  // Namespace : http://gisun.agatsystem.by/classif/types/
  // Info      : Wrapper
  // ************************************************************************ //
  ate_interval = class(AteInterval)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ate_request, global, <element>
  // Namespace : http://gisun.agatsystem.by/classif/types/
  // Info      : Wrapper
  // ************************************************************************ //
  ate_request = class(AteRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : cl_changes, global, <element>
  // Namespace : http://gisun.agatsystem.by/classif/types/
  // Info      : Wrapper
  // ************************************************************************ //
  cl_changes = class(ClChanges)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : cl_request, global, <element>
  // Namespace : http://gisun.agatsystem.by/classif/types/
  // Info      : Wrapper
  // ************************************************************************ //
  cl_request = class(ClRequest)
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
  // XML       : error, alias
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // ************************************************************************ //
  error = class(WsError)
  private
  published
  end;

  Array_Of_ateObject = array of ateObject;      { "http://gisun.agatsystem.by/classif/ws/"[GblUbnd] }


  // ************************************************************************ //
  // XML       : AteChangeData, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/classif/ws/
  // ************************************************************************ //
  AteChangeData = class(TRemotable)
  private
    Fate_object: Array_Of_ateObject;
    Fate_object_Specified: boolean;
    Fmax_ate_number: Int64;
    Fmax_ate_number_Specified: boolean;
    procedure Setate_object(Index: Integer; const AArray_Of_ateObject: Array_Of_ateObject);
    function  ate_object_Specified(Index: Integer): boolean;
    procedure Setmax_ate_number(Index: Integer; const AInt64: Int64);
    function  max_ate_number_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property ate_object:     Array_Of_ateObject  Index (IS_OPTN or IS_UNBD or IS_UNQL) read Fate_object write Setate_object stored ate_object_Specified;
    property max_ate_number: Int64               Index (IS_OPTN or IS_UNQL) read Fmax_ate_number write Setmax_ate_number stored max_ate_number_Specified;
  end;


  // ************************************************************************ //
  // Namespace : http://gisun.agatsystem.by/classif/ws/
  // soapAction: urn:%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : wsBinding
  // service   : ws
  // port      : ws
  // URL       : http://todes.by:8084/gisun/class/ws
  // ************************************************************************ //
  ClassifWs = interface(IInvokable)
  ['{56F2A8AF-96FB-7277-958B-795879C7AB75}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  findAteChanges(const ateRequest: ate_request): ate_changes; stdcall;

    // Cannot unwrap:
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  findClChanges(const clRequest: cl_request): cl_changes; stdcall;

    // Cannot unwrap:
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  findAteInterval(const ateInterval: ate_interval): ate_changes; stdcall;
  end;

function GetClassifWs(Addr, Proxy: string; RIO: THTTPRIO): ClassifWs;
function GetClassifWs2(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): ClassifWs;
	
implementation
  uses SysUtils;

//------------------------------------------------------------------------------
function GetClassifWs(Addr, Proxy: string; RIO: THTTPRIO): ClassifWs;
begin
   Result := nil;
   if Addr<>'' then begin
      RIO.Converter.Options:=[soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soDocument, soDontSendEmptyNodes, soCacheMimeResponse, soLiteralParams, soUTF8EncodeXML];
      RIO.URL:=Addr;
      RIO.HTTPWebNode.Proxy:=Proxy;
      Result:=(RIO as ClassifWs);
   end;
end;

//------------------------------------------------------------------------------
function GetClassifWs2(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): ClassifWs;
{   // было
function GetClassifWs(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): ClassifWs;
}
const
  defWSDL = 'http://todes.by:8084/gisun/class/ws?wsdl';
  defURL  = 'http://todes.by:8084/gisun/class/ws';
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
    Result := (RIO as ClassifWs);
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

destructor MessageCover.Destroy;
begin
  FreeAndNil(Fmessage_type);
  FreeAndNil(Fmessage_time);
  FreeAndNil(Fmessage_source);
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

procedure ateCategory.Setcategory(Index: Integer; const AInt64: Int64);
begin
  Fcategory := AInt64;
  Fcategory_Specified := True;
end;

function ateCategory.category_Specified(Index: Integer): boolean;
begin
  Result := Fcategory_Specified;
end;

procedure ateCategory.Setfront(Index: Integer; const AInt64: Int64);
begin
  Ffront := AInt64;
  Ffront_Specified := True;
end;

function ateCategory.front_Specified(Index: Integer): boolean;
begin
  Result := Ffront_Specified;
end;

procedure ateCategory.SetnamecategoryBy(Index: Integer; const AWideString: WideString);
begin
  FnamecategoryBy := AWideString;
  FnamecategoryBy_Specified := True;
end;

function ateCategory.namecategoryBy_Specified(Index: Integer): boolean;
begin
  Result := FnamecategoryBy_Specified;
end;

procedure ateCategory.SetnamecategoryRu(Index: Integer; const AWideString: WideString);
begin
  FnamecategoryRu := AWideString;
  FnamecategoryRu_Specified := True;
end;

function ateCategory.namecategoryRu_Specified(Index: Integer): boolean;
begin
  Result := FnamecategoryRu_Specified;
end;

procedure ateCategory.SetshortnameBy(Index: Integer; const AWideString: WideString);
begin
  FshortnameBy := AWideString;
  FshortnameBy_Specified := True;
end;

function ateCategory.shortnameBy_Specified(Index: Integer): boolean;
begin
  Result := FshortnameBy_Specified;
end;

procedure ateCategory.SetshortnameRu(Index: Integer; const AWideString: WideString);
begin
  FshortnameRu := AWideString;
  FshortnameRu_Specified := True;
end;

function ateCategory.shortnameRu_Specified(Index: Integer): boolean;
begin
  Result := FshortnameRu_Specified;
end;

destructor ateObject.Destroy;
begin
  FreeAndNil(Fcategory);
  FreeAndNil(Fdatein);
  FreeAndNil(Fdateout);
  inherited Destroy;
end;

procedure ateObject.Setcategory(Index: Integer; const AateCategory: ateCategory);
begin
  Fcategory := AateCategory;
  Fcategory_Specified := True;
end;

function ateObject.category_Specified(Index: Integer): boolean;
begin
  Result := Fcategory_Specified;
end;

procedure ateObject.Setdatein(Index: Integer; const ATXSDateTime: TXSDateTime);
begin
  Fdatein := ATXSDateTime;
  Fdatein_Specified := True;
end;

function ateObject.datein_Specified(Index: Integer): boolean;
begin
  Result := Fdatein_Specified;
end;

procedure ateObject.Setdateout(Index: Integer; const ATXSDateTime: TXSDateTime);
begin
  Fdateout := ATXSDateTime;
  Fdateout_Specified := True;
end;

function ateObject.dateout_Specified(Index: Integer): boolean;
begin
  Result := Fdateout_Specified;
end;

procedure ateObject.SetnameobjectBy(Index: Integer; const AWideString: WideString);
begin
  FnameobjectBy := AWideString;
  FnameobjectBy_Specified := True;
end;

function ateObject.nameobjectBy_Specified(Index: Integer): boolean;
begin
  Result := FnameobjectBy_Specified;
end;

procedure ateObject.SetnameobjectRu(Index: Integer; const AWideString: WideString);
begin
  FnameobjectRu := AWideString;
  FnameobjectRu_Specified := True;
end;

function ateObject.nameobjectRu_Specified(Index: Integer): boolean;
begin
  Result := FnameobjectRu_Specified;
end;

procedure ateObject.Setobjectnumber(Index: Integer; const AInt64: Int64);
begin
  Fobjectnumber := AInt64;
  Fobjectnumber_Specified := True;
end;

function ateObject.objectnumber_Specified(Index: Integer): boolean;
begin
  Result := Fobjectnumber_Specified;
end;

procedure ateObject.Setparentobjectnumber(Index: Integer; const AInt64: Int64);
begin
  Fparentobjectnumber := AInt64;
  Fparentobjectnumber_Specified := True;
end;

function ateObject.parentobjectnumber_Specified(Index: Integer): boolean;
begin
  Result := Fparentobjectnumber_Specified;
end;

procedure ateObject.Setsoato(Index: Integer; const AWideString: WideString);
begin
  Fsoato := AWideString;
  Fsoato_Specified := True;
end;

function ateObject.soato_Specified(Index: Integer): boolean;
begin
  Result := Fsoato_Specified;
end;

constructor AteChanges.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor AteChanges.Destroy;
begin
  FreeAndNil(Fcover);
  FreeAndNil(Fchanges);
  inherited Destroy;
end;

destructor AteRequestData.Destroy;
begin
  FreeAndNil(Fdate_from);
  inherited Destroy;
end;

procedure AteRequestData.Setdate_from(Index: Integer; const ATXSDateTime: TXSDateTime);
begin
  Fdate_from := ATXSDateTime;
  Fdate_from_Specified := True;
end;

function AteRequestData.date_from_Specified(Index: Integer): boolean;
begin
  Result := Fdate_from_Specified;
end;

constructor AteRequest.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor AteRequest.Destroy;
begin
  FreeAndNil(Fcover);
  FreeAndNil(Frequest);
  inherited Destroy;
end;

destructor ErrorListException.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(FerrorList)-1 do
    FreeAndNil(FerrorList[I]);
  SetLength(FerrorList, 0);
  inherited Destroy;
end;

procedure ErrorListException.SeterrorList(Index: Integer; const AerrorList2: errorList2);
begin
  FerrorList := AerrorList2;
  FerrorList_Specified := True;
end;

function ErrorListException.errorList_Specified(Index: Integer): boolean;
begin
  Result := FerrorList_Specified;
end;

procedure ErrorListException.Setmessage_(Index: Integer; const AWideString: WideString);
begin
  Fmessage_ := AWideString;
  Fmessage__Specified := True;
end;

function ErrorListException.message__Specified(Index: Integer): boolean;
begin
  Result := Fmessage__Specified;
end;

constructor ClRequest.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor ClRequest.Destroy;
begin
  FreeAndNil(Fcover);
  FreeAndNil(Frequest);
  inherited Destroy;
end;

destructor ClRequestData.Destroy;
begin
  FreeAndNil(Fdate_from);
  inherited Destroy;
end;

procedure ClRequestData.Setcl_type(Index: Integer; const AInteger: Integer);
begin
  Fcl_type := AInteger;
  Fcl_type_Specified := True;
end;

function ClRequestData.cl_type_Specified(Index: Integer): boolean;
begin
  Result := Fcl_type_Specified;
end;

procedure ClRequestData.Setdate_from(Index: Integer; const ATXSDateTime: TXSDateTime);
begin
  Fdate_from := ATXSDateTime;
  Fdate_from_Specified := True;
end;

function ClRequestData.date_from_Specified(Index: Integer): boolean;
begin
  Result := Fdate_from_Specified;
end;

constructor ClChanges.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor ClChanges.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fchanges)-1 do
    FreeAndNil(Fchanges[I]);
  SetLength(Fchanges, 0);
  FreeAndNil(Fcover);
  inherited Destroy;
end;

constructor AteInterval.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor AteInterval.Destroy;
begin
  FreeAndNil(Fcover);
  FreeAndNil(Frequest);
  inherited Destroy;
end;

procedure AteIntervalData.Setnumber_from(Index: Integer; const AInt64: Int64);
begin
  Fnumber_from := AInt64;
  Fnumber_from_Specified := True;
end;

function AteIntervalData.number_from_Specified(Index: Integer): boolean;
begin
  Result := Fnumber_from_Specified;
end;

procedure AteIntervalData.Setnumber_to(Index: Integer; const AInt64: Int64);
begin
  Fnumber_to := AInt64;
  Fnumber_to_Specified := True;
end;

function AteIntervalData.number_to_Specified(Index: Integer): boolean;
begin
  Result := Fnumber_to_Specified;
end;

destructor AteChangeData.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fate_object)-1 do
    FreeAndNil(Fate_object[I]);
  SetLength(Fate_object, 0);
  inherited Destroy;
end;

procedure AteChangeData.Setate_object(Index: Integer; const AArray_Of_ateObject: Array_Of_ateObject);
begin
  Fate_object := AArray_Of_ateObject;
  Fate_object_Specified := True;
end;

function AteChangeData.ate_object_Specified(Index: Integer): boolean;
begin
  Result := Fate_object_Specified;
end;

procedure AteChangeData.Setmax_ate_number(Index: Integer; const AInt64: Int64);
begin
  Fmax_ate_number := AInt64;
  Fmax_ate_number_Specified := True;
end;

function AteChangeData.max_ate_number_Specified(Index: Integer): boolean;
begin
  Result := Fmax_ate_number_Specified;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(ClassifWs), 'http://gisun.agatsystem.by/classif/ws/', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(ClassifWs), 'urn:%operationName%');
  InvRegistry.RegisterInvokeOptions(TypeInfo(ClassifWs), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(ClassifWs), ioLiteral);
  RemClassRegistry.RegisterXSClass(MessageCover, 'http://gisun.agatsystem.by/common/types/', 'MessageCover');
  RemClassRegistry.RegisterXSInfo(TypeInfo(LangValueList), 'http://gisun.agatsystem.by/common/types/', 'LangValueList');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ClassifierList), 'http://gisun.agatsystem.by/common/types/', 'ClassifierList');
  RemClassRegistry.RegisterXSClass(Classifier, 'http://gisun.agatsystem.by/common/types/', 'Classifier');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(Classifier), 'type_', 'type');
  RemClassRegistry.RegisterXSClass(LangValue, 'http://gisun.agatsystem.by/common/types/', 'LangValue');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ErrorList), 'http://gisun.agatsystem.by/common/ws/', 'ErrorList');
  RemClassRegistry.RegisterXSClass(WsException, 'http://gisun.agatsystem.by/common/', 'WsException');
  RemClassRegistry.RegisterXSClass(WsError, 'http://gisun.agatsystem.by/common/ws/', 'WsError');
  RemClassRegistry.RegisterXSInfo(TypeInfo(errorList2), 'http://gisun.agatsystem.by/common/ws/', 'errorList2', 'errorList');
  RemClassRegistry.RegisterXSClass(exception, 'http://gisun.agatsystem.by/common/ws/', 'exception');
  RemClassRegistry.RegisterXSClass(ateCategory, 'http://gisun.agatsystem.by/classif/ws/', 'ateCategory');
  RemClassRegistry.RegisterXSClass(ateObject, 'http://gisun.agatsystem.by/classif/ws/', 'ateObject');
  RemClassRegistry.RegisterXSClass(AteChanges, 'http://gisun.agatsystem.by/classif/ws/', 'AteChanges');
  RemClassRegistry.RegisterSerializeOptions(AteChanges, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(AteRequestData, 'http://gisun.agatsystem.by/classif/ws/', 'AteRequestData');
  RemClassRegistry.RegisterXSClass(AteRequest, 'http://gisun.agatsystem.by/classif/ws/', 'AteRequest');
  RemClassRegistry.RegisterSerializeOptions(AteRequest, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(ErrorListException, 'http://gisun.agatsystem.by/classif/ws/', 'ErrorListException');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(ErrorListException), 'message_', 'message');
  RemClassRegistry.RegisterXSClass(ClRequest, 'http://gisun.agatsystem.by/classif/ws/', 'ClRequest');
  RemClassRegistry.RegisterSerializeOptions(ClRequest, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(ClRequestData, 'http://gisun.agatsystem.by/classif/ws/', 'ClRequestData');
  RemClassRegistry.RegisterXSClass(ClChanges, 'http://gisun.agatsystem.by/classif/ws/', 'ClChanges');
  RemClassRegistry.RegisterSerializeOptions(ClChanges, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(AteInterval, 'http://gisun.agatsystem.by/classif/ws/', 'AteInterval');
  RemClassRegistry.RegisterSerializeOptions(AteInterval, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(AteIntervalData, 'http://gisun.agatsystem.by/classif/ws/', 'AteIntervalData');
  RemClassRegistry.RegisterXSClass(ErrorListException2, 'http://gisun.agatsystem.by/classif/ws/', 'ErrorListException2', 'ErrorListException');
  RemClassRegistry.RegisterXSClass(ateCategory2, 'http://gisun.agatsystem.by/classif/ws/', 'ateCategory2', 'ateCategory');
  RemClassRegistry.RegisterXSClass(ateObject2, 'http://gisun.agatsystem.by/classif/ws/', 'ateObject2', 'ateObject');
  RemClassRegistry.RegisterXSClass(ate_changes, 'http://gisun.agatsystem.by/classif/types/', 'ate_changes');
  RemClassRegistry.RegisterXSClass(ate_interval, 'http://gisun.agatsystem.by/classif/types/', 'ate_interval');
  RemClassRegistry.RegisterXSClass(ate_request, 'http://gisun.agatsystem.by/classif/types/', 'ate_request');
  RemClassRegistry.RegisterXSClass(cl_changes, 'http://gisun.agatsystem.by/classif/types/', 'cl_changes');
  RemClassRegistry.RegisterXSClass(cl_request, 'http://gisun.agatsystem.by/classif/types/', 'cl_request');
  RemClassRegistry.RegisterXSClass(value, 'http://gisun.agatsystem.by/common/types/', 'value');
  RemClassRegistry.RegisterXSClass(classifier2, 'http://gisun.agatsystem.by/common/types/', 'classifier2', 'classifier');
  RemClassRegistry.RegisterXSClass(error, 'http://gisun.agatsystem.by/common/ws/', 'error');
  RemClassRegistry.RegisterXSInfo(TypeInfo(Array_Of_ateObject), 'http://gisun.agatsystem.by/classif/ws/', 'Array_Of_ateObject');
  RemClassRegistry.RegisterXSClass(AteChangeData, 'http://gisun.agatsystem.by/classif/ws/', 'AteChangeData');

end.