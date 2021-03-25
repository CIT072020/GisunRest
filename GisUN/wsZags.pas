unit wsZags;
interface
uses
   InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns, OPConvert, wsGisun;

const
  IS_OPTN = $0001;
  IS_UNBD = $0002;
  IS_NLBL = $0004;
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
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:int             - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:dateTime        - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:date            - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:base64Binary    - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:integer         - "http://www.w3.org/2001/XMLSchema"[Gbl]

  WsReturnCode         = class;                 { "http://gisun.agatsystem.by/common/ws/"[Lit][GblCplx] }
  ActReason            = class;                 { "http://gisun.agatsystem.by/zags/types/"[GblCplx] }
  adoption_act         = class;                 { "http://gisun.agatsystem.by/zags/types/"[Lit][GblElm] }
  adp_cert_data        = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  adp_child            = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  before_adp_child     = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  after_adp_child      = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  marriage             = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  affiliation_act      = class;                 { "http://gisun.agatsystem.by/zags/types/"[Lit][GblElm] }
  aff_cert_data        = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  aff_person           = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  birth_act            = class;                 { "http://gisun.agatsystem.by/zags/types/"[Lit][GblElm] }
  birth_cert_data      = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  decease_act          = class;                 { "http://gisun.agatsystem.by/zags/types/"[Lit][GblElm] }
  dcs_cert_data        = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  divorce_act          = class;                 { "http://gisun.agatsystem.by/zags/types/"[Lit][GblElm] }
  dvc_cert_data        = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  wife                 = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  husband              = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  marriage_act         = class;                 { "http://gisun.agatsystem.by/zags/types/"[Lit][GblElm] }
  mrg_cert_data        = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  bride                = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  bridegroom           = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  name_change_act      = class;                 { "http://gisun.agatsystem.by/zags/types/"[Lit][GblElm] }
  cng_cert_data        = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  person               = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  reconstructed_birth_act = class;              { "http://gisun.agatsystem.by/zags/types/"[Lit][GblElm] }
  rcn_birth_cert_data  = class;                 { "http://gisun.agatsystem.by/zags/types/"[Cplx] }
  return_code2         = class;                 { "http://gisun.agatsystem.by/zags/types/"[Lit][GblElm] }
  children             = class;                 { "http://gisun.agatsystem.by/zags/types/"[Alias] }

  { "http://gisun.agatsystem.by/zags/types/"[GblSmpl] }
  ///Признак заключения брака
  MarrFlag = (
     ///Брак между усыновителями
     adoptiveParentsMarr,
     ///Брак между родителем и усыновителем
     parentAndAdoptiveMarr
  );

  { "http://gisun.agatsystem.by/zags/types/"[GblSmpl] }
  ///Записываются ли усыновители родителями ребёнка
  ParentsFlag = (
     ///Да
     yes,
     ///Нет
     no
  );


  // ************************************************************************ //
  // XML       : WsReturnCode, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/common/ws/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  ///Возвращаемые веб-сервисом данные
  WsReturnCode = class(TRemotable)
  private
    ///Системная информация
    Fcover: MessageCover;
    ///Сведения об ошибках
    Ferror_list: ErrorList;
    Ferror_list_Specified: boolean;
    procedure Seterror_list(Index: Integer; const AErrorList: ErrorList);
    function  error_list_Specified(Index: Integer): boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:      MessageCover  read Fcover write Fcover;
    property error_list: ErrorList     Index (IS_OPTN) read Ferror_list write Seterror_list stored error_list_Specified;
  end;


  ///Список детей
  ChildList  = array of children;               { "http://gisun.agatsystem.by/zags/types/"[GblCplx] }


  // ************************************************************************ //
  // XML       : ActReason, global, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Основание записи акта
  ActReason = class(TRemotable)
  private
    ///Наименование суда
    Fcourt_name: WideString;
    Fcourt_name_Specified: boolean;
    ///Дата судебного решения
    Fcourt_decision_date: WideString;
    Fcourt_decision_date_Specified: boolean;
    ///Комментарий к основанию записи акта
    Fcomment: WideString;
    Fcomment_Specified: boolean;
    procedure Setcourt_name(Index: Integer; const AWideString: WideString);
    function  court_name_Specified(Index: Integer): boolean;
    procedure Setcourt_decision_date(Index: Integer; const AWideString: WideString);
    function  court_decision_date_Specified(Index: Integer): boolean;
    procedure Setcomment(Index: Integer; const AWideString: WideString);
    function  comment_Specified(Index: Integer): boolean;
  published
    property court_name:          WideString  Index (IS_OPTN) read Fcourt_name write Setcourt_name stored court_name_Specified;
    property court_decision_date: WideString  Index (IS_OPTN) read Fcourt_decision_date write Setcourt_decision_date stored court_decision_date_Specified;
    property comment:             WideString  Index (IS_OPTN) read Fcomment write Setcomment stored comment_Specified;
  end;



  // ************************************************************************ //
  // XML       : birth_act, global, <element>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  ///Запись акта о рождении
  birth_act = class(TRemotable)
  private
    ///Системная информация
    Fcover: MessageCover;
    ///Акт о рождении
    Fbirth_cert_data: birth_cert_data;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:           MessageCover     read Fcover write Fcover;
    property birth_cert_data: birth_cert_data  read Fbirth_cert_data write Fbirth_cert_data;
  end;



  // ************************************************************************ //
  // XML       : birth_cert_data, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  birth_cert_data = class(TRemotable)
  private
    ///Персональные данные ребёнка
    Fchild_data: PersonalData;
    ///Персональные данные матери
    Fmother_data: PersonalData;
    ///Персональные данные отца
    Ffather_data: PersonalData;
    ///Основание записи сведений об отце (свидетельство о заключении брака)
    Fmarriage_cert: ActData;
    Fmarriage_cert_Specified: boolean;
    ///Информация об актовой записи
    Fbirth_act_data: ActData;
    ///Информация о печатном документе
    Fbirth_certificate_data: Document;
    procedure Setmarriage_cert(Index: Integer; const AActData: ActData);
    function  marriage_cert_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property child_data:             PersonalData  read Fchild_data write Fchild_data;
    property mother_data:            PersonalData  read Fmother_data write Fmother_data;
    property father_data:            PersonalData  read Ffather_data write Ffather_data;
    property marriage_cert:          ActData       Index (IS_OPTN) read Fmarriage_cert write Setmarriage_cert stored marriage_cert_Specified;
    property birth_act_data:         ActData       read Fbirth_act_data write Fbirth_act_data;
    property birth_certificate_data: Document      read Fbirth_certificate_data write Fbirth_certificate_data;
  end;



  // ************************************************************************ //
  // XML       : reconstructed_birth_act, global, <element>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  ///Восстановленная запись акта о рождении
  reconstructed_birth_act = class(TRemotable)
  private
    ///Системная информация
    Fcover: MessageCover;
    ///Восстановленный акт о рождении
    Frcn_birth_cert_data: rcn_birth_cert_data;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:               MessageCover         read Fcover write Fcover;
    property rcn_birth_cert_data: rcn_birth_cert_data  read Frcn_birth_cert_data write Frcn_birth_cert_data;
  end;



  // ************************************************************************ //
  // XML       : rcn_birth_cert_data, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Восстановленный акт о рождении
  rcn_birth_cert_data = class(TRemotable)
  private
    ///Персональные данные ребёнка
    Fchild_data: PersonalData;
    ///Персональные данные матери
    Fmother_data: PersonalData;
    ///Персональные данные отца
    Ffather_data: PersonalData;
    ///Основание восстановление записи - решение суда
    Fcourt_decision: ActReason;
    ///Информация об актовой записи
    Frcn_birth_act_data: ActData;
    ///Информация о печатном документе
    Frcn_birth_certificate_data: Document;
  public
    destructor Destroy; override;
  published
    property child_data:                 PersonalData  read Fchild_data write Fchild_data;
    property mother_data:                PersonalData  read Fmother_data write Fmother_data;
    property father_data:                PersonalData  read Ffather_data write Ffather_data;
    property court_decision:             ActReason     read Fcourt_decision write Fcourt_decision;
    property rcn_birth_act_data:         ActData       read Frcn_birth_act_data write Frcn_birth_act_data;
    property rcn_birth_certificate_data: Document      read Frcn_birth_certificate_data write Frcn_birth_certificate_data;
  end;



  // ************************************************************************ //
  // XML       : marriage_act, global, <element>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  ///Запись акта о заключении брака
  marriage_act = class(TRemotable)
  private
    ///Системная информация
    Fcover: MessageCover;
    ///Акт о заключении брака
    Fmrg_cert_data: mrg_cert_data;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:         MessageCover   read Fcover write Fcover;
    property mrg_cert_data: mrg_cert_data  read Fmrg_cert_data write Fmrg_cert_data;
  end;



  // ************************************************************************ //
  // XML       : bride, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Информация о невесте
  bride = class(TRemotable)
  private
    ///Персональные данные невесты
    Fbride_data: PersonalData;
    ///Фамилия до заключения брака
    Fold_last_name: WideString;
  public
    destructor Destroy; override;
  published
    property bride_data:    PersonalData  read Fbride_data write Fbride_data;
    property old_last_name: WideString    read Fold_last_name write Fold_last_name;
  end;



  // ************************************************************************ //
  // XML       : bridegroom, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Информация о женихе
  bridegroom = class(TRemotable)
  private
    ///Персональные данные жениха
    Fbridegroom_data: PersonalData;
    ///Фамилия до заключения брака
    Fold_last_name: WideString;
  public
    destructor Destroy; override;
  published
    property bridegroom_data: PersonalData  read Fbridegroom_data write Fbridegroom_data;
    property old_last_name:   WideString    read Fold_last_name write Fold_last_name;
  end;


  // ************************************************************************ //
  // XML       : divorce_act, global, <element>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  ///Запись акта о расторжении брака
  divorce_act = class(TRemotable)
  private
    ///Системная информация
    Fcover: MessageCover;
    ///Акт о расторжении брака
    Fdvc_cert_data: dvc_cert_data;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:         MessageCover   read Fcover write Fcover;
    property dvc_cert_data: dvc_cert_data  read Fdvc_cert_data write Fdvc_cert_data;
  end;



  // ************************************************************************ //
  // XML       : wife, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Информация о жене
  wife = class(TRemotable)
  private
    ///Персональные данные жены
    Fwife_data: PersonalData;
    ///Фамилия до расторжения брака
    Fold_last_name: WideString;
  public
    destructor Destroy; override;
  published
    property wife_data:     PersonalData  read Fwife_data write Fwife_data;
    property old_last_name: WideString    read Fold_last_name write Fold_last_name;
  end;



  // ************************************************************************ //
  // XML       : husband, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Информация о муже
  husband = class(TRemotable)
  private
    ///Персональные данные мужа
    Fhusband_data: PersonalData;
    ///Фамилия до расторжения брака
    Fold_last_name: WideString;
  public
    destructor Destroy; override;
  published
    property husband_data:  PersonalData  read Fhusband_data write Fhusband_data;
    property old_last_name: WideString    read Fold_last_name write Fold_last_name;
  end;



  // ************************************************************************ //
  // XML       : adoption_act, global, <element>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  ///Запись акта об усыновлении (удочерении)
  adoption_act = class(TRemotable)
  private
    ///Системная информация
    Fcover: MessageCover;
    ///Акт об усыновлении (удочерении)
    Fadp_cert_data: adp_cert_data;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:         MessageCover   read Fcover write Fcover;
    property adp_cert_data: adp_cert_data  read Fadp_cert_data write Fadp_cert_data;
  end;



  // ************************************************************************ //
  // XML       : adp_cert_data, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Акт об усыновлении (удочерении)
  adp_cert_data = class(TRemotable)
  private
    ///Сведения об усыновляемом (??? нет комментария)
    Fadp_child: adp_child;
    ///Персональные данные матери
    Fmother_data: PersonalData;
    ///Персональные данные отца
    Ffather_data: PersonalData;
    ///Персональные данные усыновительницы
    Fadp_mother_data: PersonalData;
    Fadp_mother_data_Specified: boolean;
    ///Персональные данные усыновителя
    Fadp_father_data: PersonalData;
    Fadp_father_data_Specified: boolean;
    ///Сведения о регистрации заключения брака
    Fmarriage: marriage;
    Fmarriage_Specified: boolean;
    ///Основание записи акта об усыновлении (удочерении) - решение суда
    Fcourt_decision: ActReason;
    ///Записываются ли усыновители родителями ребёнка
    Fparents_flag: ParentsFlag;
    ///Информация об актовой записи
    Fadp_act_data: ActData;
    ///Информация о печатном документе
    Fadp_certificate_data: Document;
    procedure Setadp_mother_data(Index: Integer; const APersonalData: PersonalData);
    function  adp_mother_data_Specified(Index: Integer): boolean;
    procedure Setadp_father_data(Index: Integer; const APersonalData: PersonalData);
    function  adp_father_data_Specified(Index: Integer): boolean;
    procedure Setmarriage(Index: Integer; const Amarriage: marriage);
    function  marriage_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property adp_child:            adp_child     read Fadp_child write Fadp_child;
    property mother_data:          PersonalData  read Fmother_data write Fmother_data;
    property father_data:          PersonalData  read Ffather_data write Ffather_data;
    property adp_mother_data:      PersonalData  Index (IS_OPTN) read Fadp_mother_data write Setadp_mother_data stored adp_mother_data_Specified;
    property adp_father_data:      PersonalData  Index (IS_OPTN) read Fadp_father_data write Setadp_father_data stored adp_father_data_Specified;
    property marriage:             marriage      Index (IS_OPTN) read Fmarriage write Setmarriage stored marriage_Specified;
    property court_decision:       ActReason     read Fcourt_decision write Fcourt_decision;
    property parents_flag:         ParentsFlag   read Fparents_flag write Fparents_flag;
    property adp_act_data:         ActData       read Fadp_act_data write Fadp_act_data;
    property adp_certificate_data: Document      read Fadp_certificate_data write Fadp_certificate_data;
  end;



  // ************************************************************************ //
  // XML       : adp_child, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Сведения об усыновляемом
  adp_child = class(TRemotable)
  private
    ///Идентификационный номер усыновляемого
    Fidentif: WideString;
    ///Сведения об усыновляемом до усыновления
    Fbefore_adp_child: before_adp_child;
    ///Сведения об усыновляемом после усыновления
    Fafter_adp_child: after_adp_child;
  public
    destructor Destroy; override;
  published
    property identif:          WideString        read Fidentif write Fidentif;
    property before_adp_child: before_adp_child  read Fbefore_adp_child write Fbefore_adp_child;
    property after_adp_child:  after_adp_child   read Fafter_adp_child write Fafter_adp_child;
  end;



  // ************************************************************************ //
  // XML       : before_adp_child, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Сведения об усыновляемом до усыновления
  before_adp_child = class(TRemotable)
  private
    ///Персональные данные усыновляемого до усыновления
    Fbefore_adp_child_data: PersonalData;
    ///Информация об акте о рождении (до усыновления)
    Fbefore_adp_birth_act_data: ActData;
  public
    destructor Destroy; override;
  published
    property before_adp_child_data:     PersonalData  read Fbefore_adp_child_data write Fbefore_adp_child_data;
    property before_adp_birth_act_data: ActData       read Fbefore_adp_birth_act_data write Fbefore_adp_birth_act_data;
  end;



  // ************************************************************************ //
  // XML       : after_adp_child, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Сведения об усыновляемом после усыновления
  after_adp_child = class(TRemotable)
  private
    ///Персональные данные усыновляемого после усыновления
    Fafter_adp_child_data: PersonalData;
    ///Информация об акте о рождении (после усыновления)
    Fafter_adp_birth_act_data: ActData;
  public
    destructor Destroy; override;
  published
    property after_adp_child_data:     PersonalData  read Fafter_adp_child_data write Fafter_adp_child_data;
    property after_adp_birth_act_data: ActData       read Fafter_adp_birth_act_data write Fafter_adp_birth_act_data;
  end;



  // ************************************************************************ //
  // XML       : marriage, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Сведения о регистрации заключения брака
  marriage = class(TRemotable)
  private
    ///Признак заключения брака
    Fmrg_flag: MarrFlag;
    ///Информация об акте о заключении брака
    Fmrg_cert_data: ActData;
  public
    destructor Destroy; override;
  published
    property mrg_flag:      MarrFlag  read Fmrg_flag write Fmrg_flag;
    property mrg_cert_data: ActData   read Fmrg_cert_data write Fmrg_cert_data;
  end;



  // ************************************************************************ //
  // XML       : affiliation_act, global, <element>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  ///Запись акта об установлении отцовства
  affiliation_act = class(TRemotable)
  private
    ///Системная информация
    Fcover: MessageCover;
    ///Акт об установлении отцовства
    Faff_cert_data: aff_cert_data;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:         MessageCover   read Fcover write Fcover;
    property aff_cert_data: aff_cert_data  read Faff_cert_data write Faff_cert_data;
  end;



  // ************************************************************************ //
  // XML       : aff_cert_data, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Акт об установлении отцовства
  aff_cert_data = class(TRemotable)
  private
    ///Сведения о лице, в отношении которого устанавливается отцовство
    Faff_person: aff_person;
    ///Персональные данные матери
    Fmother_data: PersonalData;
    ///Персональные данные отца
    Ffather_data: PersonalData;
    ///Основание записи акта об установлении отцовства - решение суда
    Fcourt_decision: ActReason;
    ///Информация об актовой записи
    Faff_act_data: ActData;
    ///Информация о печатном документе (свидетельство для матери)
    Faff_mother_certificate_data: Document;
    Faff_mother_certificate_data_Specified: boolean;
    ///Информация о печатном документе (свидетельство для отца)
    Faff_father_certificate_data: Document;
    Faff_father_certificate_data_Specified: boolean;
    procedure Setaff_mother_certificate_data(Index: Integer; const ADocument: Document);
    function  aff_mother_certificate_data_Specified(Index: Integer): boolean;
    procedure Setaff_father_certificate_data(Index: Integer; const ADocument: Document);
    function  aff_father_certificate_data_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property aff_person:                  aff_person    read Faff_person write Faff_person;
    property mother_data:                 PersonalData  read Fmother_data write Fmother_data;
    property father_data:                 PersonalData  read Ffather_data write Ffather_data;
    property court_decision:              ActReason     read Fcourt_decision write Fcourt_decision;
    property aff_act_data:                ActData       read Faff_act_data write Faff_act_data;
    property aff_mother_certificate_data: Document      Index (IS_OPTN) read Faff_mother_certificate_data write Setaff_mother_certificate_data stored aff_mother_certificate_data_Specified;
    property aff_father_certificate_data: Document      Index (IS_OPTN) read Faff_father_certificate_data write Setaff_father_certificate_data stored aff_father_certificate_data_Specified;
  end;



  // ************************************************************************ //
  // XML       : aff_person, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Сведения о лице, в отношении которого устанавливается отцовство
  aff_person = class(TRemotable)
  private
    ///Информация об акте о рождении
    Fbirth_act_data: ActData;
    ///Персональные данные лица до установления отцовства
    Fbefore_aff_person_data: PersonalData;
    ///Персональные данные лица после установления отцовства
    Fafter_aff_person_data: PersonalData;
  public
    destructor Destroy; override;
  published
    property birth_act_data:         ActData       read Fbirth_act_data write Fbirth_act_data;
    property before_aff_person_data: PersonalData  read Fbefore_aff_person_data write Fbefore_aff_person_data;
    property after_aff_person_data:  PersonalData  read Fafter_aff_person_data write Fafter_aff_person_data;
  end;



  // ************************************************************************ //
  // XML       : decease_act, global, <element>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  ///Запись акта о смерти
  decease_act = class(TRemotable)
  private
    ///Системная информация
    Fcover: MessageCover;
    ///Акт о смерти
    Fdcs_cert_data: dcs_cert_data;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:         MessageCover   read Fcover write Fcover;
    property dcs_cert_data: dcs_cert_data  read Fdcs_cert_data write Fdcs_cert_data;
  end;



  // ************************************************************************ //
  // XML       : dcs_cert_data, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Акт о смерти
  dcs_cert_data = class(TRemotable)
  private
    ///Персональные данные умершего
    Fperson_data: PersonalData;
    ///Информация о смерти
    Fdecease_data: Death;
    ///Документ, подтверждающий факт смерти
    Freason: WideString;
    ///Информация об актовой записи
    Fdcs_act_data: ActData;
    ///Информация о печатном документе
    Fdcs_certificate_data: Document;
  public
    destructor Destroy; override;
  published
    property person_data:          PersonalData  read Fperson_data write Fperson_data;
    property decease_data:         Death         read Fdecease_data write Fdecease_data;
    property reason:               WideString    read Freason write Freason;
    property dcs_act_data:         ActData       read Fdcs_act_data write Fdcs_act_data;
    property dcs_certificate_data: Document      read Fdcs_certificate_data write Fdcs_certificate_data;
  end;



  // ************************************************************************ //
  // XML       : name_change_act, global, <element>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  ///Запись акта о перемене имени
  name_change_act = class(TRemotable)
  private
    ///Системная информация
    Fcover: MessageCover;
    ///Акт о перемене имени
    Fcng_cert_data: cng_cert_data;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property cover:         MessageCover   read Fcover write Fcover;
    property cng_cert_data: cng_cert_data  read Fcng_cert_data write Fcng_cert_data;
  end;



  // ************************************************************************ //
  // XML       : person, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Персональные данные лица
  person = class(TRemotable)
  private
    ///Персональные данные лица
    Fperson_data: PersonalData;
    ///Фамилия до перемены имени
    Fold_last_name: WideString;
    ///Имя до перемены имени
    Fold_name: WideString;
    ///Отчество до перемены имени
    Fold_patronymic: WideString;
    ///Информация об акте о рождении
    Fbirth_act_data: ActData;
  public
    destructor Destroy; override;
  published
    property person_data:    PersonalData  read Fperson_data write Fperson_data;
    property old_last_name:  WideString    read Fold_last_name write Fold_last_name;
    property old_name:       WideString    read Fold_name write Fold_name;
    property old_patronymic: WideString    read Fold_patronymic write Fold_patronymic;
    property birth_act_data: ActData       read Fbirth_act_data write Fbirth_act_data;
  end;



  // ************************************************************************ //
  // XML       : return_code, global, <element>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // Info      : Wrapper
  // ************************************************************************ //
  return_code2 = class(WsReturnCode)
  private
  published
  end;


  // ************************************************************************ //
  // XML       : children, alias
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Информация о ребёнке
  children = class(PersonalData)
  private
  published
  end;


  // ************************************************************************ //
  // XML       : mrg_cert_data, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Акт о заключении брака
  mrg_cert_data = class(TRemotable)
  private
    ///Информация о невесте
    Fbride: bride;
    ///Информация о женихе
    Fbridegroom: bridegroom;
    ///Сведения о совместных детях, не достигших 18 лет
    Fjoint_child: ChildList;
    Fjoint_child_Specified: boolean;
    ///Информация об актовой записи
    Fmrg_act_data: ActData;
    ///Информация о печатном документе
    Fmrg_certificate_data: Document;
    procedure Setjoint_child(Index: Integer; const AChildList: ChildList);
    function  joint_child_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property bride:                bride       read Fbride write Fbride;
    property bridegroom:           bridegroom  read Fbridegroom write Fbridegroom;
    property joint_child:          ChildList   Index (IS_OPTN) read Fjoint_child write Setjoint_child stored joint_child_Specified;
    property mrg_act_data:         ActData     read Fmrg_act_data write Fmrg_act_data;
    property mrg_certificate_data: Document    read Fmrg_certificate_data write Fmrg_certificate_data;
  end;

  // ************************************************************************ //
  // XML       : dvc_cert_data, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Акт о расторжении брака
  dvc_cert_data = class(TRemotable)
  private
    ///Информация о жене
    Fwife: wife;
    ///Информация о муже
    Fhusband: husband;
    ///Информация об акте о регистрации брака
    Fmrg_act_data: ActData;
    ///Сведения о совместных детях, не достигших 18 лет
    Fjoint_child: ChildList;
    Fjoint_child_Specified: boolean;
    ///Основание записи акта о расторжении брака  - решение суда
    Fcourt_decision: ActReason;
    ///Информация об актовой записи
    Fdvc_act_data: ActData;
    ///Информация о печатном документе (свидетельство для бывшей жены)
    Fdvc_wm_certificate_data: Document;
    ///Информация о печатном документе (свидетельство для бывшего мужа)
    Fdvc_mn_certificate_data: Document;
    procedure Setjoint_child(Index: Integer; const AChildList: ChildList);
    function  joint_child_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property wife:                    wife       read Fwife write Fwife;
    property husband:                 husband    read Fhusband write Fhusband;
    property mrg_act_data:            ActData    read Fmrg_act_data write Fmrg_act_data;
    property joint_child:             ChildList  Index (IS_OPTN) read Fjoint_child write Setjoint_child stored joint_child_Specified;
    property court_decision:          ActReason  read Fcourt_decision write Fcourt_decision;
    property dvc_act_data:            ActData    read Fdvc_act_data write Fdvc_act_data;
    property dvc_wm_certificate_data: Document   read Fdvc_wm_certificate_data write Fdvc_wm_certificate_data;
    property dvc_mn_certificate_data: Document   read Fdvc_mn_certificate_data write Fdvc_mn_certificate_data;
  end;


  // ************************************************************************ //
  // XML       : cng_cert_data, <complexType>
  // Namespace : http://gisun.agatsystem.by/zags/types/
  // ************************************************************************ //
  ///Акт о перемене имени
  cng_cert_data = class(TRemotable)
  private
    ///Персональные данные лица
    Fperson: person;
    ///Сведения о детях, не достигших 18 лет
    Fjoint_child: ChildList;
    Fjoint_child_Specified: boolean;
    ///Основание записи акта о перемене имени
    Freason: WideString;
    ///Информация об актовой записи
    Fcng_act_data: ActData;
    ///Информация о печатном документе
    Fcng_certificate_data: Document;
    procedure Setjoint_child(Index: Integer; const AChildList: ChildList);
    function  joint_child_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property person:               person      read Fperson write Fperson;
    property joint_child:          ChildList   Index (IS_OPTN) read Fjoint_child write Setjoint_child stored joint_child_Specified;
    property reason:               WideString  read Freason write Freason;
    property cng_act_data:         ActData     read Fcng_act_data write Fcng_act_data;
    property cng_certificate_data: Document    read Fcng_certificate_data write Fcng_certificate_data;
  end;


  // ************************************************************************ //
  // Namespace : http://gisun.agatsystem.by/zags/ws/
  // soapAction: urn:%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : ZagsSOAPBinding
  // service   : ZagsWs
  // port      : ws
  // URL       : http://agat-system.by:4569/gisun/zags/ws
  // ************************************************************************ //
  ZagsWS = interface(IInvokable)
  ['{01659ED2-D4AF-DBD4-24D1-FFBAF83FF81D}']
    ///регистрация рождения
    function  postBirthCertificate(const birthActRequest: birth_act): return_code2; stdcall;
    ///??? восстановление актовой записи о рождении
    function  postReconstBirthCertificate(const rcnBirthActRequest: reconstructed_birth_act): return_code2; stdcall;
    ///регистрация брака
    function  postMarriageCertificate(const mrgActRequest: marriage_act): return_code2; stdcall;
    ///расторжение брака
    function  postDivorceCertificate(const dvcActRequest: divorce_act): return_code2; stdcall;
    ///усыновление
    function  postAdoptionCertificate(const adpActRequest: adoption_act): return_code2; stdcall;
    ///установление отцовства
    function  postAffiliationCertificate(const affActRequest: affiliation_act): return_code2; stdcall;
    ///умирание
    function  postDeceaseCertificate(const dcsActRequest: decease_act): return_code2; stdcall;
    ///перемена имени
    function  postNameChangeCertificate(const cngActRequest: name_change_act): return_code2; stdcall;
  end;

function GetZagsWS(Addr, Proxy: string; RIO: THTTPRIO): ZagsWS;

implementation
  uses SysUtils;

function GetZagsWS(Addr, Proxy: string; RIO: THTTPRIO): ZagsWS;
begin
   Result := nil;
   if Addr<>'' then begin
      RIO.Converter.Options:=[soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soDocument, soDontSendEmptyNodes, soCacheMimeResponse, soLiteralParams, soUTF8EncodeXML];
      RIO.URL:=Addr;
      RIO.HTTPWebNode.Proxy:=Proxy;
      Result:=(RIO as ZagsWS);
   end;
end;

constructor WsReturnCode.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor WsReturnCode.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Ferror_list)-1 do
    FreeAndNil(Ferror_list[I]);
  SetLength(Ferror_list, 0);
  FreeAndNil(Fcover);
  inherited Destroy;
end;

procedure WsReturnCode.Seterror_list(Index: Integer; const AErrorList: ErrorList);
begin
  Ferror_list := AErrorList;
  Ferror_list_Specified := True;
end;

function WsReturnCode.error_list_Specified(Index: Integer): boolean;
begin
  Result := Ferror_list_Specified;
end;

procedure ActReason.Setcourt_name(Index: Integer; const AWideString: WideString);
begin
  Fcourt_name := AWideString;
  Fcourt_name_Specified := True;
end;

function ActReason.court_name_Specified(Index: Integer): boolean;
begin
  Result := Fcourt_name_Specified;
end;

procedure ActReason.Setcourt_decision_date(Index: Integer; const AWideString: WideString);
begin
  Fcourt_decision_date := AWideString;
  Fcourt_decision_date_Specified := True;
end;

function ActReason.court_decision_date_Specified(Index: Integer): boolean;
begin
  Result := Fcourt_decision_date_Specified;
end;

procedure ActReason.Setcomment(Index: Integer; const AWideString: WideString);
begin
  Fcomment := AWideString;
  Fcomment_Specified := True;
end;

function ActReason.comment_Specified(Index: Integer): boolean;
begin
  Result := Fcomment_Specified;
end;

constructor birth_act.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor birth_act.Destroy;
begin
  FreeAndNil(Fcover);
  FreeAndNil(Fbirth_cert_data);
  inherited Destroy;
end;

destructor birth_cert_data.Destroy;
begin
  FreeAndNil(Fchild_data);
  FreeAndNil(Fmother_data);
  FreeAndNil(Ffather_data);
  FreeAndNil(Fmarriage_cert);
  FreeAndNil(Fbirth_act_data);
  FreeAndNil(Fbirth_certificate_data);
  inherited Destroy;
end;

procedure birth_cert_data.Setmarriage_cert(Index: Integer; const AActData: ActData);
begin
  Fmarriage_cert := AActData;
  Fmarriage_cert_Specified := True;
end;

function birth_cert_data.marriage_cert_Specified(Index: Integer): boolean;
begin
  Result := Fmarriage_cert_Specified;
end;

constructor reconstructed_birth_act.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor reconstructed_birth_act.Destroy;
begin
  FreeAndNil(Fcover);
  FreeAndNil(Frcn_birth_cert_data);
  inherited Destroy;
end;

destructor rcn_birth_cert_data.Destroy;
begin
  FreeAndNil(Fchild_data);
  FreeAndNil(Fmother_data);
  FreeAndNil(Ffather_data);
  FreeAndNil(Fcourt_decision);
  FreeAndNil(Frcn_birth_act_data);
  FreeAndNil(Frcn_birth_certificate_data);
  inherited Destroy;
end;

constructor marriage_act.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor marriage_act.Destroy;
begin
  FreeAndNil(Fcover);
  FreeAndNil(Fmrg_cert_data);
  inherited Destroy;
end;

destructor bride.Destroy;
begin
  FreeAndNil(Fbride_data);
  inherited Destroy;
end;

destructor bridegroom.Destroy;
begin
  FreeAndNil(Fbridegroom_data);
  inherited Destroy;
end;

constructor divorce_act.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor divorce_act.Destroy;
begin
  FreeAndNil(Fcover);
  FreeAndNil(Fdvc_cert_data);
  inherited Destroy;
end;

destructor wife.Destroy;
begin
  FreeAndNil(Fwife_data);
  inherited Destroy;
end;

destructor husband.Destroy;
begin
  FreeAndNil(Fhusband_data);
  inherited Destroy;
end;

constructor adoption_act.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor adoption_act.Destroy;
begin
  FreeAndNil(Fcover);
  FreeAndNil(Fadp_cert_data);
  inherited Destroy;
end;

destructor adp_cert_data.Destroy;
begin
  FreeAndNil(Fadp_child);
  FreeAndNil(Fmother_data);
  FreeAndNil(Ffather_data);
  FreeAndNil(Fadp_mother_data);
  FreeAndNil(Fadp_father_data);
  FreeAndNil(Fmarriage);
  FreeAndNil(Fcourt_decision);
  FreeAndNil(Fadp_act_data);
  FreeAndNil(Fadp_certificate_data);
  inherited Destroy;
end;

procedure adp_cert_data.Setadp_mother_data(Index: Integer; const APersonalData: PersonalData);
begin
  Fadp_mother_data := APersonalData;
  Fadp_mother_data_Specified := True;
end;

function adp_cert_data.adp_mother_data_Specified(Index: Integer): boolean;
begin
  Result := Fadp_mother_data_Specified;
end;

procedure adp_cert_data.Setadp_father_data(Index: Integer; const APersonalData: PersonalData);
begin
  Fadp_father_data := APersonalData;
  Fadp_father_data_Specified := True;
end;

function adp_cert_data.adp_father_data_Specified(Index: Integer): boolean;
begin
  Result := Fadp_father_data_Specified;
end;

procedure adp_cert_data.Setmarriage(Index: Integer; const Amarriage: marriage);
begin
  Fmarriage := Amarriage;
  Fmarriage_Specified := True;
end;

function adp_cert_data.marriage_Specified(Index: Integer): boolean;
begin
  Result := Fmarriage_Specified;
end;

destructor adp_child.Destroy;
begin
  FreeAndNil(Fbefore_adp_child);
  FreeAndNil(Fafter_adp_child);
  inherited Destroy;
end;

destructor before_adp_child.Destroy;
begin
  FreeAndNil(Fbefore_adp_child_data);
  FreeAndNil(Fbefore_adp_birth_act_data);
  inherited Destroy;
end;

destructor after_adp_child.Destroy;
begin
  FreeAndNil(Fafter_adp_child_data);
  FreeAndNil(Fafter_adp_birth_act_data);
  inherited Destroy;
end;

destructor marriage.Destroy;
begin
  FreeAndNil(Fmrg_cert_data);
  inherited Destroy;
end;

constructor affiliation_act.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor affiliation_act.Destroy;
begin
  FreeAndNil(Fcover);
  FreeAndNil(Faff_cert_data);
  inherited Destroy;
end;

destructor aff_cert_data.Destroy;
begin
  FreeAndNil(Faff_person);
  FreeAndNil(Fmother_data);
  FreeAndNil(Ffather_data);
  FreeAndNil(Fcourt_decision);
  FreeAndNil(Faff_act_data);
  FreeAndNil(Faff_mother_certificate_data);
          FreeAndNil(Faff_father_certificate_data);
  inherited Destroy;
end;

procedure aff_cert_data.Setaff_mother_certificate_data(Index: Integer; const ADocument: Document);
begin
  Faff_mother_certificate_data := ADocument;
  Faff_mother_certificate_data_Specified := True;
end;

function aff_cert_data.aff_mother_certificate_data_Specified(Index: Integer): boolean;
begin
  Result := Faff_mother_certificate_data_Specified;
end;

procedure aff_cert_data.Setaff_father_certificate_data(Index: Integer; const ADocument: Document);
begin
  Faff_father_certificate_data := ADocument;
  Faff_father_certificate_data_Specified := True;
end;

function aff_cert_data.aff_father_certificate_data_Specified(Index: Integer): boolean;
begin
  Result := Faff_father_certificate_data_Specified;
end;

destructor aff_person.Destroy;
begin
  FreeAndNil(Fbirth_act_data);
  FreeAndNil(Fbefore_aff_person_data);
  FreeAndNil(Fafter_aff_person_data);
  inherited Destroy;
end;

constructor decease_act.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor decease_act.Destroy;
begin
  FreeAndNil(Fcover);
  FreeAndNil(Fdcs_cert_data);
  inherited Destroy;
end;

destructor dcs_cert_data.Destroy;
begin
  FreeAndNil(Fperson_data);
  FreeAndNil(Fdecease_data);
  FreeAndNil(Fdcs_act_data);
  FreeAndNil(Fdcs_certificate_data);
  inherited Destroy;
end;

constructor name_change_act.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor name_change_act.Destroy;
begin
  FreeAndNil(Fcover);
  FreeAndNil(Fcng_cert_data);
  inherited Destroy;
end;

destructor person.Destroy;
begin
  FreeAndNil(Fperson_data);
  FreeAndNil(Fbirth_act_data);
  inherited Destroy;
end;

destructor mrg_cert_data.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fjoint_child)-1 do
    FreeAndNil(Fjoint_child[I]);
  SetLength(Fjoint_child, 0);
  FreeAndNil(Fbride);
  FreeAndNil(Fbridegroom);
  FreeAndNil(Fmrg_act_data);
  FreeAndNil(Fmrg_certificate_data);
  inherited Destroy;
end;

procedure mrg_cert_data.Setjoint_child(Index: Integer; const AChildList: ChildList);
begin
  Fjoint_child := AChildList;
  Fjoint_child_Specified := True;
end;

function mrg_cert_data.joint_child_Specified(Index: Integer): boolean;
begin
  Result := Fjoint_child_Specified;
end;

destructor dvc_cert_data.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fjoint_child)-1 do
    FreeAndNil(Fjoint_child[I]);
  SetLength(Fjoint_child, 0);
  FreeAndNil(Fwife);
  FreeAndNil(Fhusband);
  FreeAndNil(Fmrg_act_data);
  FreeAndNil(Fcourt_decision);
  FreeAndNil(Fdvc_act_data);
  FreeAndNil(Fdvc_wm_certificate_data);
  FreeAndNil(Fdvc_mn_certificate_data);
  inherited Destroy;
end;

procedure dvc_cert_data.Setjoint_child(Index: Integer; const AChildList: ChildList);
begin
  Fjoint_child := AChildList;
  Fjoint_child_Specified := True;
end;

function dvc_cert_data.joint_child_Specified(Index: Integer): boolean;
begin
  Result := Fjoint_child_Specified;
end;

destructor cng_cert_data.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fjoint_child)-1 do
    FreeAndNil(Fjoint_child[I]);
  SetLength(Fjoint_child, 0);
  FreeAndNil(Fperson);
  FreeAndNil(Fcng_act_data);
  FreeAndNil(Fcng_certificate_data);
  inherited Destroy;
end;

procedure cng_cert_data.Setjoint_child(Index: Integer; const AChildList: ChildList);
begin
  Fjoint_child := AChildList;
  Fjoint_child_Specified := True;
end;

function cng_cert_data.joint_child_Specified(Index: Integer): boolean;
begin
  Result := Fjoint_child_Specified;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(ZagsWS), 'http://gisun.agatsystem.by/zags/ws/', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(ZagsWS), 'urn:%operationName%');
  InvRegistry.RegisterInvokeOptions(TypeInfo(ZagsWS), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(ZagsWS), ioLiteral);
  RemClassRegistry.RegisterXSClass(WsReturnCode, 'http://gisun.agatsystem.by/common/ws/', 'WsReturnCode');
  RemClassRegistry.RegisterSerializeOptions(WsReturnCode, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(ChildList), 'http://gisun.agatsystem.by/zags/types/', 'ChildList');
  RemClassRegistry.RegisterXSClass(ActReason, 'http://gisun.agatsystem.by/zags/types/', 'ActReason');
  RemClassRegistry.RegisterXSInfo(TypeInfo(MarrFlag), 'http://gisun.agatsystem.by/zags/types/', 'MarrFlag');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ParentsFlag), 'http://gisun.agatsystem.by/zags/types/', 'ParentsFlag');
  RemClassRegistry.RegisterXSClass(birth_act, 'http://gisun.agatsystem.by/zags/types/', 'birth_act');
  RemClassRegistry.RegisterSerializeOptions(birth_act, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(birth_cert_data, 'http://gisun.agatsystem.by/zags/types/', 'birth_cert_data');
  RemClassRegistry.RegisterXSClass(reconstructed_birth_act, 'http://gisun.agatsystem.by/zags/types/', 'reconstructed_birth_act');
  RemClassRegistry.RegisterSerializeOptions(reconstructed_birth_act, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(rcn_birth_cert_data, 'http://gisun.agatsystem.by/zags/types/', 'rcn_birth_cert_data');
  RemClassRegistry.RegisterXSClass(marriage_act, 'http://gisun.agatsystem.by/zags/types/', 'marriage_act');
  RemClassRegistry.RegisterSerializeOptions(marriage_act, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(bride, 'http://gisun.agatsystem.by/zags/types/', 'bride');
  RemClassRegistry.RegisterXSClass(bridegroom, 'http://gisun.agatsystem.by/zags/types/', 'bridegroom');
  RemClassRegistry.RegisterXSClass(divorce_act, 'http://gisun.agatsystem.by/zags/types/', 'divorce_act');
  RemClassRegistry.RegisterSerializeOptions(divorce_act, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(wife, 'http://gisun.agatsystem.by/zags/types/', 'wife');
  RemClassRegistry.RegisterXSClass(husband, 'http://gisun.agatsystem.by/zags/types/', 'husband');
  RemClassRegistry.RegisterXSClass(adoption_act, 'http://gisun.agatsystem.by/zags/types/', 'adoption_act');
  RemClassRegistry.RegisterSerializeOptions(adoption_act, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(adp_cert_data, 'http://gisun.agatsystem.by/zags/types/', 'adp_cert_data');
  RemClassRegistry.RegisterXSClass(adp_child, 'http://gisun.agatsystem.by/zags/types/', 'adp_child');
  RemClassRegistry.RegisterXSClass(before_adp_child, 'http://gisun.agatsystem.by/zags/types/', 'before_adp_child');
  RemClassRegistry.RegisterXSClass(after_adp_child, 'http://gisun.agatsystem.by/zags/types/', 'after_adp_child');
  RemClassRegistry.RegisterXSClass(marriage, 'http://gisun.agatsystem.by/zags/types/', 'marriage');
  RemClassRegistry.RegisterXSClass(affiliation_act, 'http://gisun.agatsystem.by/zags/types/', 'affiliation_act');
  RemClassRegistry.RegisterSerializeOptions(affiliation_act, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(aff_cert_data, 'http://gisun.agatsystem.by/zags/types/', 'aff_cert_data');
  RemClassRegistry.RegisterXSClass(aff_person, 'http://gisun.agatsystem.by/zags/types/', 'aff_person');
  RemClassRegistry.RegisterXSClass(decease_act, 'http://gisun.agatsystem.by/zags/types/', 'decease_act');
  RemClassRegistry.RegisterSerializeOptions(decease_act, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(dcs_cert_data, 'http://gisun.agatsystem.by/zags/types/', 'dcs_cert_data');
  RemClassRegistry.RegisterXSClass(name_change_act, 'http://gisun.agatsystem.by/zags/types/', 'name_change_act');
  RemClassRegistry.RegisterSerializeOptions(name_change_act, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(person, 'http://gisun.agatsystem.by/zags/types/', 'person');
  RemClassRegistry.RegisterXSClass(return_code2, 'http://gisun.agatsystem.by/zags/types/', 'return_code2', 'return_code');
  RemClassRegistry.RegisterXSClass(children, 'http://gisun.agatsystem.by/zags/types/', 'children');
  RemClassRegistry.RegisterXSClass(mrg_cert_data, 'http://gisun.agatsystem.by/zags/types/', 'mrg_cert_data');
  RemClassRegistry.RegisterXSClass(dvc_cert_data, 'http://gisun.agatsystem.by/zags/types/', 'dvc_cert_data');
  RemClassRegistry.RegisterXSClass(cng_cert_data, 'http://gisun.agatsystem.by/zags/types/', 'cng_cert_data');

end.