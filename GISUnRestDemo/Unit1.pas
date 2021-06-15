unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, DateUtils,
  nativexml,
  superdate, superobject,
  StdCtrls, Mask,
  DBCtrlsEh,
  DB, Grids, DBGridEh,
  adsdata, adsfunc, adstable, adscnnct,
  HTTPSend,
  ssl_openssl, ssl_openssl_lib,
  funcpr,
  mRegInt,
  uGisun,
  uROCExchg,
  uRestClient,
  uRegIntX;

type
  TForm1 = class(TForm)
    edMemo: TMemo;
    gdIDs: TDBGridEh;
    DataSource1: TDataSource;
    gdDocs: TDBGridEh;
    dsDocs: TDataSource;
    gdChild: TDBGridEh;
    dsChild: TDataSource;
    btnGetDocs: TButton;
    dtBegin: TDBDateTimeEditEh;
    dtEnd: TDBDateTimeEditEh;
    edOrgan: TDBEditEh;
    edFirst: TDBEditEh;
    edCount: TDBEditEh;
    btnPostDoc: TButton;
    btnGetActual: TButton;
    lstINs: TListBox;
    edtIN: TDBEditEh;
    btnGetNSI: TButton;
    lblSSovCode: TLabel;
    lblIndNum: TLabel;
    edNsiType: TDBEditEh;
    lblNsiType: TLabel;
    gdNsi: TDBGridEh;
    dsNsi: TDataSource;
    edNsiCode: TDBEditEh;
    cbSrcPost: TDBComboBoxEh;
    cnctNsi: TAdsConnection;
    cbAdsCvrt: TDBCheckBoxEh;
    cbESTP: TDBCheckBoxEh;
    cbClearLog: TDBCheckBoxEh;
    lblFirst: TLabel;
    lblCount: TLabel;
    lblDepartFromDate: TLabel;
    lblINs: TLabel;
    lblDSD: TLabel;
    lblChilds: TLabel;
    lblNSI: TLabel;
    btnGetUN: TButton;
    btnGetPersData: TButton;
    btnPostMarr: TButton;
    procedure btnGetActualClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnGetDocsClick(Sender: TObject);
    procedure btnGetNSIClick(Sender: TObject);
    procedure btnGetPersDataClick(Sender: TObject);
    procedure btnGetUNClick(Sender: TObject);
    procedure btnPostDocClick(Sender: TObject);
    procedure btnPostMarrClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
  Form1: TForm1;
  RegInt : TRegIntX;
  BlackBox : TROCExchg;
  // для отладки POST
  //GETRes : TResultHTTP;

implementation

uses
  kbmMemTable,
  SasaINiFile,
  uAvest,
  uROCService,
  fPIN4Av;

{$R *.dfm}


procedure Create4UN;
var
  Ini : TSasaIniFile;
begin
  Ini := TSasaIniFile.Create(UN_INI_NAME);
  RegInt := TRegIntX.Create('1', Ini);
  RegInt.ReadMetaInfo(UN_IN_FILES, UN_OUT_FILES);
end;



procedure TForm1.FormCreate(Sender: TObject);
begin
  ShowM := edMemo;
  edOrgan.Text  := '26';
//  dtBegin.Value := StrToDate('01.01.2021');
//  dtEnd.Value   := StrToDate('10.01.2021');
  dtBegin.Value := StrToDate('09.10.2020');
  dtEnd.Value   := StrToDate('01.01.2021');
  edFirst.Text  := '0';
  edCount.Text  := '10';
  cbSrcPost.ItemIndex := 0;

  BlackBox := TROCExchg.Create('..\..\Lais7\Service\' + INI_NAME);
  Self.Caption := 'Обмен с адресом: ' + BlackBox.Host.URL;
  Create4UN;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
end;


// Уехавшие из Sys_Organ
procedure TForm1.btnGetDocsClick(Sender: TObject);
var
  First, Count : Integer;
  D1, D2: TDateTime;
  P: TParsGet;
begin
  D1 := dtBegin.Value;
  D2 := dtEnd.Value;
  try
    First := Integer(edFirst.Value);
    except
    First := 0;
      end;

  try
    Count := Integer(edCount.Value);
    except
    Count := 0;
      end;

  if (First = 0) AND (Count = 0) then
    BlackBox.ResHTTP := BlackBox.GetDeparted(D1, D2, edOrgan.Text)
  else begin
    P := TParsGet.Create(D1, D2, edOrgan.Text);
    P.First := First;
    P.Count := Count;
    BlackBox.ResHTTP := BlackBox.GetDeparted(P);
  end;
  //GETRes := BlackBox.ResHTTP;
  ShowDeb(IntToStr(BlackBox.ResHTTP.ResCode) + ' ' + BlackBox.ResHTTP.ResMsg, cbClearLog.Checked);

  if (BlackBox.ResHTTP.INs.RecordCount > 0) then begin
    DataSource1.DataSet := BlackBox.ResHTTP.INs;
    dsDocs.DataSet := BlackBox.ResHTTP.Docs;
    dsChild.DataSet := BlackBox.ResHTTP.Child;
    BlackBox.ResHTTP.INs.First;
    while (NOT BlackBox.ResHTTP.INs.Eof) do begin
      if (BlackBox.ResHTTP.INs.Bof) then
        lstINs.Clear;
      lstINs.Items.Add(BlackBox.ResHTTP.INs.FieldValues['IDENTIF']);
      BlackBox.ResHTTP.INs.Next;
    end;

  end;

end;


// Актуальные установочные данные для ИН
procedure TForm1.btnGetActualClick(Sender: TObject);
var
  i: Integer;
  IndNums: TStringList;
  P: TParsGet;
begin
  if (lstINs.SelCount > 0) then begin
    if (lstINs.SelCount = 1) then
      // Выбран единственный - передается строка
      BlackBox.ResHTTP := BlackBox.GetActualReg(lstINs.Items[lstINs.ItemIndex])
    else begin
      // Выбрано несколько - передается список
      IndNums := TStringList.Create;
      for i := 1 to lstINs.SelCount do begin
        if (lstINs.Selected[i]) then
          IndNums.Add(lstINs.Items[i]);
      end;
      BlackBox.ResHTTP := BlackBox.GetActualReg(IndNums);
    end;
  end
  else
      // Ничего не выбрано, берем из TextBox
    BlackBox.ResHTTP := BlackBox.GetActualReg(edtIN.Text);
  ShowDeb(IntToStr(BlackBox.ResHTTP.ResCode) + ' ' + BlackBox.ResHTTP.ResMsg, cbClearLog.Checked);
  if (Assigned(BlackBox.ResHTTP)) then begin
    dsDocs.DataSet := BlackBox.ResHTTP.Docs;
    dsChild.DataSet := BlackBox.ResHTTP.Child;
  end;

end;

// Сохранить PIN
function SetAvestPass(Avest: TAvest): Boolean;
var
  sPin: string;
begin
  Result := False;
  if (Length(Avest.Password) = 0)
    OR (Avest.hDefSession = nil) then begin
    // Подключаться еще не пытались, нужен PIN
    fPINGet := TfPINGet.Create(nil);
    try
      if (fPINGet.ShowModal = mrOk) then begin
        fPINGet.SetResult(sPin);
        if (Length(sPin) > 0) then begin
          Avest.SetLoginParams(sPin, '');
          Result := True;
        end;
      end;
    finally
      fPINGet.Free;
      fPINGet := nil;
    end;
  end
  else
    Result := True;
end;


// Записать Актуальные установочные данные для ИН
procedure TForm1.btnPostDocClick(Sender: TObject);
const
  exmSign = 'amlsnandwkn&@871099udlaukbdeslfug12p91883y1hpd91h';
  exmSert = '109uu21nu0t17togdy70-fuib';
var
  iSrc: Integer;
  PPost: TParsPost;
  Res: TResultHTTP;
begin
  //edMemo.Clear;
  PPost := TParsPost.Create(exmSign, exmSert);
  iSrc := cbSrcPost.ItemIndex;
  if (cbSrcPost.ItemIndex in [0..1]) then begin
    // из MemTable
    PPost.JSONSrc := '';
    PPost.Docs := BlackBox.ResHTTP.Docs;
    PPost.Child := BlackBox.ResHTTP.Child;
    if (cbSrcPost.ItemIndex = 0) then
    // передача только текущей
      LeaveOnly1(dsDocs.DataSet);
  end
  else begin
    // из JSON-файла
    PPost.JSONSrc := cbSrcPost.Items[cbSrcPost.ItemIndex];
    //PPost.Docs := nil;
  end;

  BlackBox.Secure.SignPost := cbESTP.Checked;
  if (BlackBox.Secure.SignPost = True) then
    if (SetAvestPass(BlackBox.Secure.Avest) = False) then
      Exit;

  BlackBox.Secure.Avest.Debug := True;
  BlackBox.ResHTTP := BlackBox.PostRegDocs(PPost);
  ShowDeb(IntToStr(BlackBox.ResHTTP.ResCode) + ' ' + BlackBox.ResHTTP.ResMsg, cbClearLog.Checked);

end;


// Справочник ROC
procedure TForm1.btnGetNSIClick(Sender: TObject);
var
  ValidPars: Boolean;
  NsiCode, NsiType: integer;
  Path2Nsi : string;
  ParsNsi : TParsNsi;
begin
  try
    NsiType := StrToInt(edNsiType.Text);
    if (Length(edNsiCode.Text) > 0) then
      // только один элемент справочника
      NsiCode := StrToInt(edNsiCode.Text)
    else
      NsiCode := 0;
    ValidPars := True;
  except
    ValidPars := False;
  end;
  if (ValidPars = True) then begin
      cnctNsi.IsConnected := False;
      cnctNsi.ConnectPath := IncludeTrailingBackslash(BlackBox.Meta.ReadString(SCT_ADMIN, 'ADSPATH', '.'));
    ParsNsi := TParsNsi.Create(NsiType, cnctNsi);
    ParsNsi.ADSCopy := cbAdsCvrt.Checked;
    ParsNsi.NsiCode := NsiCode;
    BlackBox.ResHTTP := BlackBox.GetNSI(ParsNsi);
    if (BlackBox.ResHTTP.ResCode = 0) then begin
      dsNsi.DataSet := BlackBox.ResHTTP.Nsi;
      BlackBox.ResHTTP.Nsi.First;
    end;
    ShowDeb(IntToStr(BlackBox.ResHTTP.ResCode) + ' ' + BlackBox.ResHTTP.ResMsg, cbClearLog.Checked);
  end;
end;

// GET Personal Data
procedure TForm1.btnGetPersDataClick(Sender: TObject);
var
  i : Integer;
  s : string;
  dsOut,
  dsErr,
  d : TDataSet;
  r : TRestResponse;
begin
  d := RegInt.CreateInputTable(akGetPersonalData, opGet);
  d.Append;
  d['IS_PERSON']  := True;
  d['IDENTIF']    := '7120691A001PB3';
  d['REQUEST_ID'] := NewGUID;
  d.Post;
  d.Append;
  d['IS_PERSON']  := True;
  d['IDENTIF']    := '7146694A001PB8';
  d['REQUEST_ID'] := NewGUID;
  d.Post;
  d.Append;
  d['IS_PERSON']  := False;
  d['POL']        := 'F';
  d['DATER']      := '20010511';
  d['REQUEST_ID'] := NewGUID;
  d.Post;
  d.Append;
  d['IS_PERSON']  := False;
  d['POL']        := 'M';
  d['DATER']      := '20020612';
  d['REQUEST_ID'] := NewGUID;
  d.Post;
  r := RegInt.Get(akGetPersonalData, QUERY_INFO, d, dsOut, dsErr);
end;

// GET IN by FIO
procedure TForm1.btnGetUNClick(Sender: TObject);
var
  i : Integer;
  s : string;
  dsOut,
  dsErr,
  d : TDataSet;
  r : TRestResponse;
begin
  d := RegInt.CreateInputTable(akGetPersonIdentif, opGet);
  d.Append;
  d['FAMILIA'] := 'ИВАНОВ';
  d['NAME']    := 'ИВАН';
  d['OTCH']    := 'ИВАНОВИЧ';
  d['DATER']   := '20120511';
  d.Post;
  r := RegInt.Get(akGetPersonIdentif, QUERY_INFO, d, dsOut, dsErr);
end;

procedure TForm1.btnPostMarrClick(Sender: TObject);
var
  i : Integer;
  s : string;
  dsOut,
  dsErr,
  d : TDataSet;
  r : TRestResponse;
begin
  d := RegInt.CreateInputTable(akMarriage, opPost);
  d.Append;

  d['ONA_IDENTIF'] := '7172252A001PB3';
  d['ONA_FAMILIA'] := 'СТАНКЕВИЧ';
  d['ONA_NAME'] := 'СВЕТЛАНА';
  d['ONA_OTCH'] := 'ПЕТРОВНА';
  d['ONA_DATER']   := '20120511';

  d['ON_IDENTIF'] := '3010182A132PB7';
  d['ON_FAMILIA'] := 'ЮРЧЕНКО';
  d['ON_NAME'] := 'НИКОЛАЙ';
  d['ON_OTCH'] := 'НИКОЛАЕВИЧ';
  d['ON_DATER']   := '20120511';

  d['ACT_TIP']       := '0300';
  d['ACT_ORGAN']     := '617';
  d['ACT_ORGAN_LEX'] := 'ЗАГС районный';
  d['ACT_DATE']      := StrToDate('08.08.2013');
  d['ACT_NOMER']     := '12';

  d['DOC_TIP']       := '54100006';
  d['DOC_ORGAN']     := '617';
  d['DOC_DATE']      := StrToDate('11.08.2013');
  d['DOC_SERIA']     := 'I-АЛ';
  d['DOC_NOMER']     := '0221734';

  d.Post;
  s := NewGUID;
  r := RegInt.Post(s, akMarriage, '0300', d, dsErr);
end;


//
end.


