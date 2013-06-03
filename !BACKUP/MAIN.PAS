Unit Main;
Interface
Uses App, Objects, Drivers, Views, Variable, Dialogs, FileFind, FileCopy
   , Status, Viewer, ScrSav, Memory, HistList, Network, LongName, Czech
   , Disk, NewViews, Editor, Supply;
Const
  fmCloseClicked   = $0001;
  fmZoomClicked    = $0002;
Type
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  PCommandLine     = ^TCommandLine;
  TCommandLine     = Object(TInputLine)
                      AktualDirectory : PString;
                      OldCommand      : Word;
                      Constructor Init(var Bounds: TRect; AMaxLen: Integer);
                      Procedure NewText(S:String);
                      Procedure AddText(S:String);
                      Procedure AddParametr(S:String);
                      Procedure RunProgram(Name:String);
                      Procedure Draw; virtual;
                      Procedure ShowCursor;
                      Procedure HandleEvent(var Event: TEvent); virtual;
                      Function GetPalette:PPalette;virtual;
                      Destructor Done;Virtual;
                       Private
                        Function CanScroll(Delta: Integer): Boolean;
                     End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  PFiles           = ^TFiles;
  TFiles           = Object(TSortedCollection)
                      Function Compare(Key1, Key2: Pointer): Integer; virtual;
                      Procedure ReadDirectory(Dir: String); virtual;
                      Procedure FreeItem(Item: Pointer); virtual;
                     End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  PDoorsBackGround = ^TDoorsBackGround;
  TDoorsBackGround = Object(TBackGround)
                      Procedure Draw;Virtual;
                      Destructor Done;virtual;
                     End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  PDoorsDesktop    = ^TDoorsDesktop;
  TDoorsDesktop    = Object(TDesktop)
                      Procedure InitBackground;virtual;
                     End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  PFileBox         = ^TFileBox;
  TFileBox         = Object(TListBox)
                      Files : PFiles;
                      procedure CalcBounds(var Bounds: TRect;Delta : TPoint); virtual;
                      Constructor Init(var Bounds: TRect; ANumCols: Word; AScrollBar:PScrollBar;PD:PPanelData);
                      Procedure ChangeDirectory(Dir:String;SetDir : Boolean);
                      Procedure Draw;Virtual;
                      Procedure HandleEvent(var Event: TEvent); virtual;
                      Procedure FocusItem(Item: Integer);Virtual;
                      Function GetPalette : PPalette;virtual;
                      Function IsSelected (Item : Integer ):Boolean;Virtual;
                      Function GetText(Item: Integer; MaxLen: Integer): String; virtual;
                      Destructor Done;virtual;
                       Private
                        Procedure FocusItemNum(Item: Integer);
                     End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  PPanelWindow     = ^TPanelWindow;
  TPanelWindow     = Object(TWindow)
                      LongNames : PLongNames;
                      Procedure InitFrame;virtual;
                      procedure ChangeBounds(var Bounds: TRect); virtual;
                      procedure SizeLimits(var Min,Max: TPoint); virtual;
                      Procedure HandleEvent(var Event: TEvent); virtual;
                      Procedure WriteLongName(S:String);Virtual;
                      Function GetTitle(MaxSize: Integer): TTitleStr; virtual;
                      Function GetPalette:PPalette;Virtual;
                      Destructor Done;virtual;
                     End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
   PNewFrame       = ^TNewFrame;
   TNewFrame       = Object(TFrame)
                      Constructor Init(var Bounds: TRect);
                      Procedure Draw; virtual;
                       Private
                        FrameMode: Word;
                        Procedure FrameLine(var FrameBuf; Y, N: Integer; Color: Byte);
                     End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
   PPanel          = ^TPanel;
   TPanel          = Object
                       PanelData       : PPanelData;
                       AktualDirectory : PString;
                       NextPanel       : PPanel;
                       Window          : PPanelWindow;
                       FileInfo        : PFileInfo;
                       ListBox         : PFileBox;
                       Selected        : Longint;
                       SelBytes        : Longint;
                       Visible         : Boolean;
                       isSelected      : Boolean;
                      Constructor Init;
                      Function GetAktualDrive      : Char;
                      Function GetFocusedFile      : String;
                      Function GetFocused          : String;
                      Procedure Select; Virtual;
                      Procedure SetAktualDir(Dir:String);
                      Procedure CompareDirectories;
                      Procedure Reread;
                      Procedure Create(PData : PPanelData;Rect : TRect);
                      Procedure Hide;
                      Procedure Show;
                      Procedure ReversVisible;
                      Procedure InversSelect;
                      Procedure ChooseDrive(Typ : Boolean);
                      Procedure SelectGroup;
                      Procedure UnSelectGroup;
                      Destructor Done; Virtual;
                     End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
    PPanelInfo     = ^TPanelInfo;
    TPanelInfo     = Object(TStaticText)
                      procedure CalcBounds(var Bounds: TRect; Delta: TPoint); virtual;
                      procedure ChangeBounds(var Bounds: TRect); virtual;
                     End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
    TDoors         = Object(TApplication)
                      Clock        : PClockView;
                      KeyboardType : PCzechView;
                      OldTimer : Longint;
                      Akction  : Boolean;
                      Constructor Init;
                      Function GetPalette:PPalette;virtual;
                      Procedure GetEvent(Var Event: Tevent);Virtual;
                      Procedure InitMenuBar;Virtual;
                      Procedure InitStatusLine;Virtual;
                      Procedure InitDesktop;Virtual;
                      Procedure Idle;Virtual;
                      Destructor Done;Virtual;
                     End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Var AktivePanel : PPanel;
    LeftPanel   : PPanel;
    RightPanel  : PPanel;
    CommandLine : PCommandLine;
    OldX,OldY   : Byte;
    LongNames   : PLongNames;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Implementation
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Uses HelpFile, MessBox, Tools, Menus, DrsHelp, Dos, Base, Options, Validate
     , Crt, Antivirs, Files;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure GetVram;
 Var Uk : PVideoRam;
Begin
  Uk:=Ptr(SegB800,0);
  Move(Uk^,VideoPamet,SizeOf(VideoPamet));
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure GetBack;
 Var Uk : PVideoRam;
Begin
  Uk:=Ptr(SegB800,0);
  Move(VideoPamet,UK^,SizeOf(VideoPamet));
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{****************************************************************************}
{                           OBJEKT - BACKGROUND                              }
{****************************************************************************}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TDoorsBackground.Draw;
Var
  B: TDrawBuffer;
  I,Z: Byte;
Begin
  I:=0;
  For I:=0 To Size.Y Do Begin
                          For Z:=1 To 80 Do B[Z-1]:=VideoPamet[I+2,Z];
                          WriteLine(0, I,Size.X, I+1, B);
                         End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{****************************************************************************}
{                             OBJEKT - DESKTOP                               }
{****************************************************************************}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TDoorsDesktop.InitBackground;
Var
  R: TRect;
Begin
  GetExtent(R);
  Background:=New(PDoorsBackground, Init(R, #176));
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{****************************************************************************}
{                              OBJEKT - DOORS                                }
{****************************************************************************}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Constructor TDoors.Init;
  Var Hist    : PStream;
      R,LR,RR : Trect;
      Od, I   : Byte;

Begin
  GetColors(OldColors);
  If Configuration.Palette.Change Then
    SetColors(Configuration.Palette.Colors);
  SetVerify(Configuration.System.VerifyWrite);
  Akction := False;
  OldTimer := GetTimer;
  IF WhereY>23 Then Od :=WhereY-23
    Else Od:=0;
  If Od<>0 Then For I:=1 To Od Do Writeln;
  GetVram;OldX:=WhereX;OldY:=WhereY;
  {Inicializace cestiny}
  Czech.SetCzech(0);
  LoadFont;
  {Inicializace aplikace}
  InitKeyBoard;
  {Inicializace pameti}
  MaxHeapSize := HeapSize;
  InitMemory;
  InitVideo;
  InitEvents;
  InitSysError;
  With Configuration.SyStem Do
    If (HistSize >10) Or (HistSize <1) Then HistSize:=1;
  HistorySize := Configuration.System.HistSize * 1024;
  InitHistory;
  TProgram.Init;
  New(LongNames,Init);
  {Nahrani hystorie prikazu }
  Hist:=New(PBufStream , Init(GetStartupPath + HistoryFileName,stOpenRead,1024));
  If Hist^.Status = stOk Then LoadHistory(Hist^);
  Dispose(Hist,Done);
  {Zakazani prikazu }
  If Not NovellInstaled Then Disablecommands([CmUserList,CmLogout{,CmResize}]);
  Disablecommands([CmNs]);
  {Konec Inicializace aplikace}
  GetExtent(R);
  R.A.X := R.B.X - 9; R.B.Y := R.A.Y + 1;
  Clock := New(PClockView, Init(R));
  Insert(Clock);
  R.A.X := R.A.X - 3;R.B.X := R.A.X + 3;
  KeyBoardType := New(PCzechView, Init(R));
  Insert(KeyBoardType);
  {Inicializace Helpu}
  RegisterHelpFile;
  {Vlozeni prikazove radky}
  R.Assign(0,Size.Y-2,Size.X,Size.Y-1);
  CommandLine:=New(PCommandLine,Init(R,255));
  Insert(CommandLine);
  RightPanel:=Nil;LeftPanel:=Nil;
  {Vlozeni leveho panelu}
  RR.Assign(Size.X div 2,0,Size.X,Size.Y-3);
  RightPanel:=New(PPanel,Init);
  {Vlozeni praveho panelu}
  LR.Assign(0,0,Size.X div 2,Size.Y-3);
  LeftPanel:=New(PPanel,Init);
  {Nastaveni ukzatelu v panelech}
  LeftPanel^.NextPanel:=RightPanel;
  RightPanel^.NextPanel:=LeftPanel;
  If Configuration.LeftPanel.Selected Then
    Begin
      LeftPanel^.Create(@Configuration.LeftPanel,LR);
      RightPanel^.Create(@Configuration.RightPanel,RR);
    End Else Begin
              RightPanel^.Create(@Configuration.RightPanel,RR);
              LeftPanel^.Create(@Configuration.LeftPanel,LR);
             End;
  Redraw; {Prekresleni aplikace}
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TDoors.InitDesktop;
var
  R: TRect;
Begin
  If Length(Configuration.Colors)<>0 Then
      Application^.GetPalette^:=Configuration.Colors;
  GetExtent(R);
  Inc(R.A.Y);
  Dec(R.B.Y,2);
  Desktop:=New(PDoorsDesktop, Init(R));
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{$I INC\MENU.INC}    (* Vlozeni menu *)
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{$I INC\STATUS.INC}  (* Vlozeni status line *)
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TDoors.Idle;
Var Timer : Longint;
Begin
 Inherited Idle;
 Clock^.Update;
 KeyboardType^.Update;
 If OldTimer = 0 Then OldTimer := GetTimer;
 If Akction Then Begin OldTimer := GetTimer; Akction := False;End;
 Timer := GetTimer;
 If (Configuration.ScreenSaver.Interval<>0) And
   (Timer>(OldTimer + (Configuration.ScreenSaver.Interval*1092)))
   Then Begin RunScreenSaver;OldTimer := GetTimer;Akction := False;End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function TDoors.GetPalette : PPalette;
Const                 {128}       {136}                    {145}
  CNewColor = CAppColor + CHelpColor + CPanelColor + CpWindowColor
            + CCommandLine + CEditorColor;
  CNewBlackWhite = CAppBlackWhite + CHelpBlackWhite + CPanelColor
                 + CpWindowColor + CCommandLine + CEditorColor;
  CNewMonochrome = CAppMonochrome + CHelpMonochrome + CPanelColor + CCommandLine
                 + CpWindowColor + CCommandLine + CEditorColor;
  P: Array[apColor..apMonochrome] Of String[Length(CNewColor)] =
                        (CNewColor,CNewBlackWhite,CNewMonoChrome);
Begin
  GetPalette:=@P[AppPalette];
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TDoors.GetEvent(Var Event:TEvent);
Var   W          : PWindow;
      HFile      : PHelpFile;
      HelpStrm   : PDosStream;
      SwpPanel   : PPanel;
      LeftBounds : Trect;
      RightBounds: TRect;
      ShiftState : ^Byte;
Const
      HelpInUse  : Boolean = False;
      KeySet     : Boolean = False;
Begin
 TApplication.GetEvent(Event);
 If Event.What<>evNothing Then
       Akction := True ;
 If (((Event.What = evKeyDown) and (Event.KeyCode = kbF1))
  Or ((Event.What = evCommand) and (Event.Command=CmHelp)))
  And (Not HelpInUse) Then
    Begin
      HelpInUse := True;
      HelpStrm  := New(PDosStream,Init(GetStartupPath + HelpFileName,stOpenRead));
      HFile := New(PHelpFile, Init(HelpStrm));
      If HelpStrm^.Status<>stOk Then
        Begin
          MessageBox('Nemohu otevrit soubor s~helpy.',Nil,mfError+mfOkButton);
          Dispose(HFile,Done);
        End
          Else Begin
                 W:=New(PHelpWindow,Init(HFile,GetHelpCtx));
                 If ValidView(W)<>Nil Then Begin
                                             ExecView(W);
                                             Dispose(W,Done);
                                           End;
                 ClearEvent(Event);
               End;
      HelpInUse:=False;
    End;
 If (Event.What=evCommand) Then
   Case Event.Command Of
    CmNs               : MessageBox('Tato funkce neni jeste k dispozici',Nil,mfError+mfOkButton);
    CmQuit             : If MessageBox('Opravdu chcete ukocit diskovy manager DOORS',
                                       Nil,mfConfirmation+mfYesButton+mfNoButton) <>CmYes Then ClearEvent(Event);
    CmSystemInfo       : SysInfo;
    CmAbout            : About;
    CmColors           : ChangeColors;
    CmVideoMode        : SetVideoMode;
    CmFileFind         : FindFile(AktivePanel^.AktualDirectory^);
    CmMouse            : SetMouse;
    CmAntivir          : SearchAntivir;
    CmCalendar         : Calendar;
    CmCalc             : Calc;
    CmASCIITable       : ASCIITable;
    CmDrivers          : DriversList;
    CmTSRPrograms      : TSRList;
    CmCDPlayer         : CDPlayer;
    CmDiskPark         : DiskPark;
    CmUserList         : UserList;
    CmLogout           : Log_Out;
    CmSetScreenSaver   : SetScreenSaver;
    CmConfirmation     : SetConfirmation;
    CmConfigSystem     : SetSystem;
    CmPalette          : SetPalette;
    CmDelete           : Begin
                           DeleteFiles(AktivePanel^.ListBox^.Files,AktivePanel^.ListBox^.Focused);
                           ClearEvent(Event);
                           AktivePanel^.Reread;
                         End;
    CmSetAttr           : Begin
                           If SetAttributs(AktivePanel^.ListBox^.Files,AktivePanel^.ListBox^.Focused)
                             Then AktivePanel^.Reread;
                           ClearEvent(Event);
                         End;

    CmMkDir            : Begin
                           MakeDirectory;
                           AktivePanel^.Reread;
                           ClearEvent(Event);
                         End;
    cmLeftSortByName   : Begin
                          Configuration.LeftPanel.SortType := 0;
                          LeftPanel^.ReRead;
                         End;
    cmLeftSortByExtension : Begin
                             Configuration.LeftPanel.SortType := 1;
                             LeftPanel^.ReRead;
                            End;
    cmLeftSortByTime   : Begin
                          Configuration.LeftPanel.SortType := 2;
                          LeftPanel^.ReRead;
                         End;
    cmLeftSortBySize   : Begin
                          Configuration.LeftPanel.SortType := 3;
                          LeftPanel^.ReRead;
                         End;
    cmLeftUnsorted     : Begin
                          Configuration.LeftPanel.SortType := 4;
                          LeftPanel^.ReRead;
                         End;
    cmRightSortByName   : Begin
                           Configuration.RightPanel.SortType := 0;
                           RightPanel^.ReRead;
                          End;
    cmRightSortByExtension : Begin
                              Configuration.RightPanel.SortType := 1;
                              RightPanel^.ReRead;
                             End;
    cmRightSortByTime   : Begin
                           Configuration.RightPanel.SortType := 2;
                           RightPanel^.ReRead;
                          End;
    cmRightSortBySize   : Begin
                           Configuration.RightPanel.SortType := 3;
                           RightPanel^.ReRead;
                          End;
    cmRightUnsorted     : Begin
                           Configuration.RightPanel.SortType := 4;
                           RightPanel^.ReRead;
                          End;
    cmChooseDriveLeft  : LeftPanel^.ChooseDrive(True);
    cmChooseDriveRight : RightPanel^.ChooseDrive(True);
    CmReverseLeft      : LeftPanel^.ReversVisible;
    CmReverseRight     : RightPanel^.ReversVisible;
    cmReReadLeft       : LeftPanel^.ReRead;
    cmReReadRight      : RightPanel^.ReRead;
    cmDiskLabel        : DiskLabel(AktivePanel^.GetAktualDrive);
    cmShowHidePanels   : Begin End;
    cmSaveConfiguration: SaveConfiguration;
    cmUsedCommands     : UsedCommands;
    cmSwapPanels       : Begin
                          LeftPanel^.Window^.GetBounds(LeftBounds);
                          RightPanel^.Window^.GetBounds(RightBounds);
                          SwpPanel:=LeftPanel;LeftPanel:=RightPanel;
                          RightPanel:=SwpPanel;
                          LeftPanel^.Window^.ChangeBounds(LeftBounds);
                          RightPanel^.Window^.ChangeBounds(RightBounds);
                          LeftPanel^.Window^.DrawView;
                          RightPanel^.Window^.DrawView;
                         End;

  End;
  If (Event.What=evMouseMove) And (Configuration.ScreenSaver.Mouse) And
   (Event.Where.X=79) And (Event.Where.Y=0) Then RunScreenSaver;
  ShiftState :=Ptr(Seg0040,$17);

  if (ShiftState^ and kbAltShift <> 0 ) and
     (ShiftState^ and kbLeftShift <>0 ) Then
    Begin
     If Not KeySet Then InvertKeyBoardType;
     KeySet := True;
    End
  Else KeySet := False;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Destructor TDoors.Done;
Var Hist : PStream;
Begin
  Dispose(LongNames,Done);
  Hist:=New(PBufStream , Init(GetStartupPath + HistoryFileName,stCreate,1024));
  If Hist^.Status = stOk Then StoreHistory(Hist^);;
  Dispose(Hist,Done);
 If AktivePanel^.NextPanel<>Nil Then Dispose(AktivePanel^.NextPanel,Done);
 If AktivePanel<>Nil Then Dispose(AktivePanel,Done);
 TApplication.Done;
 GotoXY(OldX,OldY);
 GetBack;
 DoneKeyBoard;
 If (Configuration.Palette.Change) And
   (Not Configuration.Palette.BackPalette) Then SetColors(OldColors);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{****************************************************************************}
{                              OBJEKT - PANEL                                }
{****************************************************************************}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Constructor TPanel.Init;
Begin
 Window := Nil; ListBox := Nil;SelBytes:=0; Selected:=0;Visible:= True;
 IsSelected := True;
 NextPanel:=Nil;
 PanelData:=Nil;
 New(AktualDirectory);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPanel.SelectGroup;
var
  D      : PDialog;
  C      : PView;
  L      : PLabel;
  R      : TRect;
  Mask   : String;
  St     : Word;
  I      : Word;
  F      : PFileRec;
  H      : PHistory;
begin
  If ListBox^.Files^.Count=0 Then Exit;
  R.Assign(20,6,50,14);
  D:=New(PDialog,Init(R,'Ozna‡it soubory'));
  D^.Options := SetBit(D^.Options,ofCentered);
  with D^ do
       begin
          R.Assign(3,3,25,4);
          C:=New(PInputLine,Init(R,255));
          Insert(C);

          R.Assign(25,3,28,4);
          H:=New(PHistory,Init(R,PInputLine(C),HiSelectGroup));
          Insert(H);

          R.Assign(2,2,20,3);
          L:=New(PLabel,Init(R,'Souborov  maska:',C));
          Insert(L);

          R.Assign(3,5,13,7);
          C:=New(PButton,Init(R,'~A~no',cmOk,bfDefault));
          Insert(C);

          R.Assign(14,5,24,7);
          C:=New(PButton,Init(R,'~Z~ru¨it',cmCancel,bfNormal));
          Insert(C);

          SelectNext(False);
       end;
  If HistoryCount(HiSelectGroup)<>0 Then
     Mask := HistoryStr(hiSelectGroup,0)
       Else Mask:='*.*';
  St := Application^.ExecuteDialog(D,@Mask);
  If St <> CmOk Then Exit;
  For I:=0 To ListBox^.Files^.Count-1 Do
    Begin
      F := ListBox^.Files^.At(I);
      If ((F^.Attr And Directory) <> Directory) And
          (Not F^.Selected) And FileMask(F^.Name,Mask) Then
        Begin
         F^.Selected := True;
         Inc(Selected);
         Inc(SelBytes,F^.Size);
        End;
    End;
  Window^.DrawView;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function CompareType(Data : Pointer): Word;
var
  D    : PDialog;
  C    : PView;
  L    : PLabel;
  R    : TRect;
begin
  R.Assign(17,5,63,18);
  D:=New(PDialog,Init(R,'Porovn n¡ adres ©–'));
  D^.Options := SetBit( D^.Options, OfCentered);
  with D^ do
       begin
          R.Assign(3,8,30,10);
          C:=New(PFramedView,Init(R));
          Insert(C);

          R.Assign(3,3,30,6);
          C:=New(PFramedView,Init(R));
          Insert(C);

          R.Assign(33,3,43,5);
          C:=New(PButton,Init(R,'~O~k',cmOk,bfDefault));
          Insert(C);

          R.Assign(33,5,43,7);
          C:=New(PButton,Init(R,'~Z~ru¨it',cmCancel,bfNormal));
          Insert(C);

          R.Assign(4,3,29,6);
          C:=New(PCheckBoxes,Init(R,
               NewSItem('porovnat velikost',
               NewSItem('porovanat ‡as',
               NewSItem('porovanat atributy',
               nil)))));
          Insert(C);
          R.Assign(3,2,14,3);
          L:=New(PLabel,Init(R,'Nastaven¡',C));
          Insert(L);

          R.Assign(4,8,29,10);
          C:=New(PRadioButtons,Init(R,
               NewSItem('Ozna‡en¡',
               NewSItem('Zru¨en¡ ozna‡en¡',
               nil))));
          Insert(C);
          R.Assign(3,7,15,8);
          L:=New(PLabel,Init(R,'Typ v˜bˆru',C));
          Insert(L);

          SelectNext(False);
       end;
   CompareType:=Application^.ExecuteDialog(D,Data);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPanel.CompareDirectories;
Var I, Z   : Word;
    S1, S2 : PFileRec;
    Search : Boolean;
    Data   : Record
              Options   : Word;
              Selection : Word;
             End;
   Searched : Boolean;
   D        : PInfoDialog;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure SelectFile (Panel:PPanel; F : PFileRec);
Begin
  If F^.Selected Then Exit;
  F^.Selected := True;
  Inc(Panel^.Selected);
  Inc(Panel^.SelBytes,F^.Size);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure UnSelectFile (Panel:PPanel;F : PFileRec);
Begin
  If Not F^.Selected Then Exit;
  F^.Selected := False;
  Dec(Panel^.Selected);
  Dec(Panel^.SelBytes,F^.Size);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
  Searched := False; If Not NextPanel^.Visible Then Exit;
  Data.Options := 3;Data.Selection := 0;
  If CompareType(@Data)<> CmOk Then Exit;
  D := InfoBox('',#3'Porovnavam adresare ...');
  {Oznaceni prvniho panelu}
  For I:=1 To ListBox^.Files^.Count-1 Do
   Begin
      S1:= ListBox^.Files^.At(I);Search := False;
      If (S1^.Attr And Directory)<>Directory Then
        Begin
          For Z:=1 To NextPanel^.ListBox^.Files^.Count-1 Do
            Begin
              S2:= NextPanel^.ListBox^.Files^.At(Z);
              If S1^.Name=S2^.Name Then
                Begin
                 Search := True;
                 With Data Do Begin
                                If ((Options And $1) = $1) And (S1^.Size<>S2^.Size) Then Search:= False;
                                If ((Options And $2) = $2) And (S1^.Time<>S2^.Time) Then Search:= False;
                                If ((Options And $4) = $4) And (S1^.Attr<>S2^.Attr) Then Search:= False;
                              End;
                End;
            End;
          If Not Search Then Searched := True;
          If Search = False Then If (Data.Selection = 0) Then SelectFile(@Self,S1)
                                   Else UnSelectFile(@Self,S1);
        End;
   End;
  {OZnaceni Druheho panelu}
  For I:=1 To NextPanel^.ListBox^.Files^.Count-1 Do
   Begin
      S1:= NextPanel^.ListBox^.Files^.At(I);Search := False;
      If (S1^.Attr And Directory)<>Directory Then
        Begin
          For Z:=1 To ListBox^.Files^.Count-1 Do
            Begin
              S2:= ListBox^.Files^.At(Z);
              If S1^.Name=S2^.Name Then
                Begin
                 Search := True;
                 With Data Do Begin
                                If ((Options And $1) = $1) And (S1^.Size<>S2^.Size) Then Search:= False;
                                If ((Options And $2) = $2) And (S1^.Time<>S2^.Time) Then Search:= False;
                                If ((Options And $4) = $4) And (S1^.Attr<>S2^.Attr) Then Search:= False;
                              End;
                End;
            End;
          If Not Search Then Searched := True;
          If Search = False Then If (Data.Selection = 0) Then SelectFile(NextPanel,S1)
                                   Else UnSelectFile(NextPanel,S1);
        End;
   End;
 D^.Close;
 Window^.Draw;NextPanel^.Window^.Draw;
 If Not Searched Then MessageBox('Adresare vypadaji jako totozne',Nil,mfInformation+mfOkButton);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPanel.UnSelectGroup;
var
  D      : PDialog;
  C      : PView;
  L      : PLabel;
  R      : TRect;
  Mask   : String;
  St     : Word;
  I      : Word;
  F      : PFileRec;
  H      : PHistory;
begin
  If ListBox^.Files^.Count = 0 Then Exit;
  R.Assign(20,6,50,14);
  D:=New(PDialog,Init(R,'Zrusit ozna‡eni'));
  D^.Options := SetBit(D^.Options,ofCentered);
  with D^ do
       begin
          R.Assign(3,3,25,4);
          C:=New(PInputLine,Init(R,255));
          Insert(C);

          R.Assign(25,3,28,4);
          H:=New(PHistory,Init(R,PInputLine(C),HiSelectGroup));
          Insert(H);

          R.Assign(2,2,20,3);
          L:=New(PLabel,Init(R,'Souborov  maska:',C));
          Insert(L);

          R.Assign(3,5,13,7);
          C:=New(PButton,Init(R,'~A~no',cmOk,bfDefault));
          Insert(C);

          R.Assign(14,5,24,7);
          C:=New(PButton,Init(R,'~Z~ru¨it',cmCancel,bfNormal));
          Insert(C);

          SelectNext(False);
       end;
  If HistoryCount(HiSelectGroup)<>0 Then
     Mask := HistoryStr(hiSelectGroup,0)
       Else Mask:='*.*';
  St := Application^.ExecuteDialog(D,@Mask);
  If St <> CmOk Then Exit;
  For I:=0 To ListBox^.Files^.Count-1 Do
    Begin
      F := ListBox^.Files^.At(I);
      If ((F^.Attr And Directory) <> Directory) And
          (F^.Selected) And FileMask(F^.Name,Mask) Then
        Begin
         F^.Selected := False;
         Dec(Selected);
         Dec(SelBytes,F^.Size);
        End;
    End;
  Window^.DrawView;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPanel.InversSelect;
Var I : Word;
    F : PFileRec;
Begin
  If ListBox^.Files^.Count = 0 Then Exit;
  For I:=0 To ListBox^.Files^.Count-1 Do
    Begin
      F := ListBox^.Files^.At(I);
      If (F^.Attr And Directory) <> Directory Then
        Begin
          If F^.Selected Then Begin
                               Dec(Selected);
                               Dec(SelBytes,F^.Size);
                               F^.Selected := False;
                              End
            Else Begin
                   Inc(Selected);
                   Inc(SelBytes,F^.Size);
                   F^.Selected := True;
                 End;
        End;
    End;
  Window^.Frame^.DrawView;
  ListBox^.Draw;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPanel.ReversVisible;
Begin
 If Visible Then Hide
   Else Show;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPanel.Hide;
Begin
 If Window <> Nil Then
  Begin
   If (Window^.State And SfSelected) = sfSelected Then NextPanel^.Select;
   Window^.Hide;
   Visible := False;
   PanelData^.Visible := Visible;
  End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPanel.Show;
Begin
 If Window <> Nil Then
   Begin
    Window^.Show;
    Visible := True;
    PanelData^.Visible := Visible;
    If (Not NextPanel^.Visible) Then Select;
   End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Destructor TPanel.Done;
Begin
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPanel.Select;
Begin
 DosError := 0;
 If (Window<>Nil) And (Visible) Then Begin
                      AktivePanel := @Self;
                      {$I-}
                      Chdir(AktualDirectory^);
                      If (DosError<>0) or (Ioresult<>0) Then
                        Begin
                         ChooseDrive(True);
                         Chdir(AktualDirectory^);
                        End;
                      {$I+}
                      If Configuration.System.ShowLongNames Then
                        LongNames^.ReadDirectory(AktualDirectory^,True);
                      Window^.Select;
                      SetAktualDir(AktualDirectory^);
                      IsSelected := True;
                      NextPanel^.IsSelected := False;
                      PanelData^.Selected := True;
                      If NextPanel^.PanelData<>Nil Then
                          NextPanel^.PanelData^.Selected := False;
                     End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function TPanel.GetAktualDrive;
Begin
 GetAktualDrive := AktualDirectory^[1];
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function TPanel.GetFocusedFile;
Var X : PFileRec;
Begin
   GetFocusedFile:='';
   If ListBox^.Files^.Count = 0 Then Exit;
   X:=ListBox^.Files^.At(ListBox^.Focused);
   If (X^.Attr And Directory)<>Directory Then GetFocusedFile:=X^.Name
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function TPanel.GetFocused;
Var X : PFileRec;
Begin
   GetFocused:='';
   If ListBox^.Files^.Count = 0 Then Exit;
   X:=ListBox^.Files^.At(ListBox^.Focused);
   GetFocused:=X^.Name;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPanel.Reread;
Begin
  ListBox^.ChangeDirectory(AktualDirectory^,True);
  If ListBox^.Focused>ListBox^.Range-1 Then ListBox^.Focused := ListBox^.Range-1;
  ListBox^.Draw;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPanel.ChooseDrive;
var
  DialogData : record
                 DriveList                :  PCollection;
                 Focused                  :  integer;
               end;

  DriveList  : PStringCollection;
  Drive      : Char;
  S          : String;
  R          : Trect;
  D          : PDialog;
  C          : PView;
  SB         : PScrollBar;
  DriveBox   : PDriveListBox;
  HorniRoh   : TPoint;
  DolniRoh   : TPoint;
  DriveName  : PString;
  SetDir     : Boolean;
  Rect       : TRect;
begin
  Window^.GetBounds(Rect);
  If AktivePanel=@Self Then SetDir :=True
    Else SetDir := False;
  If Typ = False Then SetDir := True;
  DriveList := New(PStringCollection, Init(0,1));
  for Drive := 'A' to 'Z' do
  begin
    if DriveValid(Drive) then
    begin
      S := Drive + ':';
      DriveList^.Insert(NewStr(S));
    end;
  end;
  if DriveList^.Count = 0 then
  begin
    Dispose(DriveList, Done);
    DriveList := nil;
  end;
  HorniRoh.X:=(Rect.A.X+((Rect.B.X-Rect.A.X) Div 2))-10;
  HorniRoh.Y:=(Rect.A.Y+((Rect.B.Y-Rect.A.Y) Div 2))-6;
  DolniRoh.X:=HorniRoh.X + 21;
  DolniRoh.Y:=HorniRoh.Y + 13;
  R.Assign(HorniRoh.X,HorniRoh.Y,DolniRoh.X,DolniRoh.Y);
  D:=New(PDialog,Init(R,'V˜bˆr disku'));
  with D^ do
       begin
          R.Assign(7,2,8,11);
          SB:=New(PScrollBar,Init(R));
          Insert(SB);

          R.Assign(3,2,7,11);
          DriveBox := New(PDriveListBox,Init(R,1,SB));
          Insert(DriveBox);

          R.Assign(8,2,18,4);
          C:=New(PButton,Init(R,'Ano',cmOk,bfDefault));
          Insert(C);

          R.Assign(8,4,18,6);
          C:=New(PButton,Init(R,'Zru¨it',cmCancel,bfNormal));
          Insert(C);

          SelectNext(False);
       end;
   DialogData.DriveList:=DriveList;
   DialogData.Focused:=0;
   DriveBox^.Focused:=0;
   If Application^.ExecuteDialog(D,@DialogData)=CmOk
    Then Begin
           DriveName := DriveList^.At(DialogData.Focused);
           If PPanel(@Self)^.AktualDirectory^[1]<>DriveName^[1] Then
             Begin
               ListBox^.ChangeDirectory(DriveName^,SetDir);
               ListBox^.FocusItem(0);
               ListBox^.Draw;
             End
           Else Begin
                  ListBox^.ChangeDirectory(DriveName^,SetDir);
                  ListBox^.Draw;
                End;
          End;
   Dispose(DriveList,Done);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPanel.SetAktualDir;
Begin
  AktualDirectory^:=Dir;
  Window^.Frame^.Draw;
  If @Self=AktivePanel Then CommandLine^.AktualDirectory^:=Dir;CommandLine^.Draw;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPanel.Create;
Var S   : PScrollBar;
    C   : PView;
    Rect1:TRect;
    Rect2:Trect;
    Min, Max : TPoint;
Begin
 PanelData := PData;
 AktivePanel:=@Self;SelBytes:=0;Selected:=0;
 Window:=New(PPanelWindow,Init(Rect,'',0));
 With Window^ Do Begin
                   If Configuration.System.Resize Then Flags := wfGrow + wfMove
                     Else Flags := 0;
                   Options:=ofSelectable + ofTopSelect ;
                   State:=0;
                   DragMode := dmLimitHiY + dmLimitLoY + dmDragGrow;
                 End;
 Rect1.Assign(Window^.Size.X-1,2,Window^.Size.X,Window^.Size.Y-3);
 S:=New(PScrollBar,Init(Rect1));
 Rect1.Assign(1,2,Window^.Size.X-1,Window^.Size.Y-3);
 Rect2.Assign(1,Window^.Size.Y-2,Window^.Size.X-1,Window^.Size.Y-1);
 FileInfo:=New(PFileInfo,Init(Rect2));
 FileInfo^.Options:=SetBit(FileInfo^.Options,ofFramed);
 ListBox:=New(PFileBox);
 ListBox^.Init(Rect1,3,S,PanelData);
 ListBox^.Options:=ofSelectable + ofFirstClick;
 Application^.InsertWindow(Window);
 With Window^ Do Begin
                 Insert(FileInfo);
                 Rect1.Assign(1,1,Size.X-1,2);
                 C:=New(PPanelInfo,Init(Rect1,' Jm‚no   Ext  Jm‚no   Ext  Jm‚no   Ext'));
                 Insert(C);
                 Insert(ListBox);
                 Insert(S);
                End;
 If (PanelData^.Size.X<>0) And (PanelData^.Size.Y<>0) And (Configuration.System.Resize)
   Then Begin
          Window^.SizeLimits(Min, Max);
          If (PanelData^.Size.X<Min.X) Or (PanelData^.Size.X>Max.X) Then PanelData^.Size.X:=Max.X;
          If (PanelData^.Size.Y<Min.Y) Or (PanelData^.Size.Y>Max.Y) Then PanelData^.Size.Y:=Max.Y;
          With PanelData^ Do
            Rect2.Assign(Origin.X,Origin.Y,Origin.X+Size.X,Origin.Y+Size.Y);
          Window^.ChangeBounds(Rect2);
        End;
 If PanelData^.Selected Then Select
  Else NextPanel^.Select;
 If PanelData^.Visible Then Show
   Else Hide;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function TFileBox.GetPalette;
Const CFileBox     = #9#10#11#12#13#14#15#16;
      P: string[Length(CFileBox)] = CFileBox;
Begin
  GetPalette := @P;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Constructor TFileBox.Init;
Var S:String;
    X: Pointer;
Begin
 TListBox.Init(Bounds,ANumCols,AScrollBar);
 Files:=New(PFiles,Init(0,1));
 If PD^.Selected  Then GetDir(0,S)
  Else S:=PD^.AktualDirectory;
 ChangeDirectory(S,true);
 If Files^.Count <>0 Then Files^.At(Focused)
   Else X:=Nil;
 Message(AKtivePanel^.FileInfo,evCommand,cmUpdateFileInfo,X);
 If VScrollBar<>Nil Then VScrollBar^.Max:=Files^.Count;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Destructor TFileBox.Done;
Begin
  {LongName.FreeMemory;}
  TListBox.Done;
  Dispose(Files,Done);
{  Dispose(AktivePanel^.ListBox^.AktualDir);}
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function TFileBox.GetText;
Var F : PFileRec;
    P:PathStr;Dir:DirStr;Name:NameStr;Ext:ExtStr;
    C : Char;
Begin
 GetText := '';
 If Files^.Count = 0 Then Exit;
 If (Item>Files^.Count-1) Then Item:= Files^.Count - 1;
 F:=Files^.At(Item);
 GetText:=KanonizeFile(F^.Name,F^.Attr);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function TFileBox.IsSelected;
Var F : PFileRec;
Begin
 IsSelected := False;If Files^.Count = 0 Then Exit;
 F:=Files^.At(Item);
 IsSelected:=F^.Selected;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TFiles.FreeItem;
Var F :  PFileRec;
Begin
  Dispose(PFileRec(Item));
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function TFiles.Compare;
Var File1,File2:PFileRec;
    FileType1,FileType2:Boolean;
    Name1, Name2 : String[12];
    Sort  : Word;
Begin
  If LeftPanel^.ListBox^.Files = @Self Then Sort := Configuration.LeftPanel.SortType
    Else Sort := Configuration.RightPanel.SortType;
  File1:=Key1;File2:=Key2;
  Filetype1:=((File1^.Attr and Directory) = Directory);
  Filetype2:=((File2^.Attr and Directory) = Directory);
  Case Sort Of
    0  : Begin
             If ((Filetype1) And (Filetype2)) or
                ((Not Filetype1) And (Not Filetype2))
                Then If File1^.Name>File2^.Name Then Compare:=1
                Else IF File1^.Name=File2^.Name Then Compare:=0
                       Else Compare:=-1
                       Else If Filetype1 Then Compare:=-1 Else Compare:=1;
               If File1^.Name='..' Then Compare:=-1;
               If File2^.Name='..' Then Compare:=1;
         End;
    1  : Begin
          Name1 := GetExtension(File1^.Name) + GetName(File1^.Name);
          Name2 := GetExtension(File2^.Name) + GetName(File2^.Name);
              If ((Filetype1) And (Filetype2)) or
                ((Not Filetype1) And (Not Filetype2))
                Then If Name1>Name2 Then Compare:=1
                Else IF Name1=Name2 Then Compare:=0
                  Else Compare:=-1
                       Else If Filetype1 Then Compare:=-1 Else Compare:=1;
                If File1^.Name='..' Then Compare:=-1;
                If File2^.Name='..' Then Compare:=1;
         End;
    2  : Begin
           If ((Filetype1) And (Filetype2)) or
                ((Not Filetype1) And (Not Filetype2))
                Then If File1^.Time>File2^.Time Then Compare:=1
                Else IF File1^.Time=File2^.Time Then Compare:=0
                 Else Compare:=-1 Else If Filetype1 Then Compare:=-1 Else Compare:=1;
              If File1^.Name='..' Then Compare:=-1;
              If File2^.Name='..' Then Compare:=1;
         End;
    3  : Begin
             If ((Filetype1) And (Filetype2)) or
                ((Not Filetype1) And (Not Filetype2))
                Then If File1^.Size>File2^.Size Then Compare:=1
                Else IF File1^.Size=File2^.Size Then Compare:=0
                 Else Compare:=-1 Else If Filetype1 Then Compare:=-1 Else Compare:=1;
              If File1^.Name='..' Then Compare:=-1;
              If File2^.Name='..' Then Compare:=1;
         End;
    Else Begin
           Compare := -1;
         End;
   End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TFiles.ReadDirectory;
Var
  DirItem : SearchRec;
  Attr    : Word;
  F       : PFileRec;
Begin
  FreeAll;
  Duplicates := True;
  If (Dir[Length(Dir)]<>':') And (Dir[Length(Dir)]<>'\') Then Dir:=Dir+'\';
  Attr := AnyFile - VolumeId;
  If Not Configuration.System.ShowHiddenFiles Then Attr := Attr - Hidden;
  FindFirst(Dir + '*.*', Attr, DirItem);
  while DosError = 0 do
  With DirItem Do begin
    If (DirItem.Name<>'.') and ((Dir[Length(Dir)-1] <> ':') or (DirItem.Name<>'..'))
    Then Begin
          F:= New(PFileRec);
          F^.Name:=Name;F^.Attr:=Attr;F^.Time:=Time;F^.Size:=Size;
          F^.Selected:=False;
           If (F^.Attr And Directory) = Directory Then F^.Name:=UpString(F^.Name)
             Else F^.Name:=DownString(F^.Name);
          Insert(F);
      End;
  FindNext(DirItem);
  end;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TFileBox.FocusItemNum(Item: Integer);
begin
  if Item < 0 then Item := 0
  else if (Item >= Range) and (Range > 0) then Item := Range-1;
  if Range <> 0 then FocusItem(Item);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TFileBox.FocusItem;
begin
  Focused := Item;
  if VScrollBar <> nil then VScrollBar^.SetValue(Item);
  if Item < TopItem then
    if NumCols = 1 then TopItem := Item
    else TopItem := Item
  else if Item >= TopItem + (Size.Y*NumCols) then
    if NumCols = 1 then TopItem := Item - Size.Y + 1
    else TopItem := TopItem +(Item - (TopItem+Size.Y*NumCols-1));
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function SearchItem(S: String;Files : PCollection;var I : Integer) : Boolean;
Var F : PFileRec;
    Z : Word;
Begin
  SearchItem := False;
  If Files^.Count=0 Then Exit;
  For Z:=1 To Files^.Count-1 Do
    Begin
      F:=Files^.At(Z);
      If UpString(F^.Name) = UpString(S) Then Begin
                                               SearchItem:= True;
                                               I := Z;
                                               Break;
                                              End;
    End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TFileBox.CalcBounds;
Var XSize : Byte;
Begin
  GetBounds(Bounds);
  Bounds.B.Y := Bounds.B.Y + Delta.Y ;
  Bounds.B.X := Bounds.B.X + Delta.X ;
  XSize := Bounds.B.X - Bounds.A.X;
  NumCols := (XSize + 1) Div 13;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TFileBox.HandleEvent;
Const Change:Boolean=False;
Var F         : PFileRec;
    STR       : String;
    X         : PFileRec;
    S         : String;
    AktualDir : String;
    Name      : String;
const
  MouseAutosToSkip = 4;
  SelectMode       : Boolean = False;
  SelectType       : Boolean = False;
var
  Mouse: TPoint;
  ColWidth: Word;
  OldItem, NewItem: Integer;
  Count: Word;
begin
  TView.HandleEvent(Event);
  If (Event.What=evKeyDown) Or
        (Event.Buttons<>0) Then Change:=True;
  If (Event.What = EvMouseDown) And (Event.Double) And (Event.Buttons=1)
     And (Files^.Count<>0) Then
    Begin
      F:=Files^.At(Focused);
      If (F^.Attr and Directory) = Directory Then
        Begin
          ChangeDirectory(F^.Name,true);
          TopItem:=0;FocusItem(0);
          If VScrollBar<>Nil Then VScrollBar^.Max:=Files^.Count;
          Draw;
        End
         Else If Base.Executable(F^.Name) Then CommandLine^.RunProgram(F^.Name);
    End;
  if (Event.What = evMouseDown) and (not Event.Double) then
  begin
    ColWidth := Size.X div NumCols + 1;
    OldItem := Focused;
    MakeLocal(Event.Where, Mouse);
    if MouseInView(Event.Where) then
      NewItem := Mouse.Y + (Size.Y * (Mouse.X div ColWidth)) + TopItem
    else NewItem := OldItem;
    Count := 0;
    repeat
      if NewItem <> OldItem then
      begin
        FocusItemNum(NewItem);
        DrawView;
      end;
      OldItem := NewItem;
      MakeLocal(Event.Where, Mouse);
      if MouseInView(Event.Where) then
        NewItem := Mouse.Y + (Size.Y * (Mouse.X div ColWidth)) + TopItem
      else
      begin
        if NumCols = 1 then
        begin
          if Event.What = evMouseAuto then Inc(Count);
          if Count = MouseAutosToSkip then
          begin
            Count := 0;
            if Mouse.Y < 0 then NewItem := Focused-1
            else if Mouse.Y >= Size.Y then NewItem := Focused+1;
          end;
        end
        else
        begin
          if Event.What = evMouseAuto then Inc(Count);
          if Count = MouseAutosToSkip then
          begin
            Count := 0;
            if Mouse.X < 0 then NewItem := Focused-Size.Y
            else if Mouse.X >= Size.X then NewItem := Focused+Size.Y
            else if Mouse.Y < 0 then
              NewItem := Focused - Focused mod Size.Y
            else if Mouse.Y > Size.Y then
              NewItem := Focused - Focused mod Size.Y + Size.Y - 1;
          end
        end;
      end;

    If (SelectMode) And (Files^.Count<>0) Then
                     Begin
                       F:=Files^.At(Focused);
                       If F^.Name<>'..' Then
                       Begin
                       If (SelectType) And (Not F^.Selected) Then
                                     Begin
                                       Inc(AktivePanel^.Selected);
                                       Inc(AktivePanel^.SelBytes,F^.Size);
                                     End
                                      Else If (Not SelectType) And (F^.Selected) Then
                                           Begin
                                             Dec(AktivePanel^.Selected);
                                             Dec(AktivePanel^.SelBytes,F^.Size);
                                           End;
                       F^.Selected := SelectType;
                       AktivePanel^.Window^.Frame^.Draw;
                       End;
                     End
     Else If (Event.Buttons=2) And (Files^.Count<>0) Then Begin
                                   F:=Files^.At(Focused);
                                   If F^.Name<>'..' Then
                                   Begin
                                   SelectMode := True;
                                   SelectType:=Not F^.Selected;
                                   If (SelectType) And (Not F^.Selected) Then
                                     Begin
                                       Inc(AktivePanel^.Selected);
                                       Inc(AktivePanel^.SelBytes,F^.Size);
                                     End
                                      Else If (Not SelectType) And (F^.Selected) Then
                                           Begin
                                             Dec(AktivePanel^.Selected);
                                             Dec(AktivePanel^.SelBytes,F^.Size);
                                           End;
                                   F^.Selected := SelectType;
                                   AktivePanel^.Window^.Frame^.Draw;
                                   End;
                                 End;

    until not MouseEvent(Event, evMouseMove + evMouseAuto);
    SelectMode:=False;
    FocusItemNum(NewItem);
    DrawView;
    if Event.Double and (Range > Focused) then SelectItem(Focused);
    ClearEvent(Event);
  end
  else if Event.What = evKeyDown then
  begin
    if (Event.CharCode = ' ') and (Focused < Range) then
    begin
      SelectItem(Focused);
      NewItem := Focused;
    end
    else case CtrlToArrow(Event.KeyCode) of
       KbEnter : If Files^.Count<>0 Then
                 Begin
                   F:=Files^.At(Focused);
                   If (F^.Attr and Directory) = Directory Then
                     Begin
                       AktualDir := CommandLine^.AktualDirectory^;
                       Name := F^.Name;
                       ChangeDirectory(Name,true);
                       If Name='..' Then
                        Begin
                         If (Not SearchItem(GetLastDirInPath(AktualDir),Files,NewItem)) Then NewItem:=0;
                        End
                        Else NewItem:=0;
                        TopItem:=0;
                       If VScrollBar<>Nil Then VScrollBar^.Max:=Files^.Count;
                      End
                    Else If Base.Executable(F^.Name) Then CommandLine^.RunProgram(F^.Name);
                   End;
      kbUp: NewItem := Focused - 1;
      kbDown: NewItem := Focused + 1;
      kbRight: if NumCols > 1 then NewItem := Focused + Size.Y else Exit;
      kbLeft: if NumCols > 1 then NewItem := Focused - Size.Y else Exit;
      kbPgDn: NewItem := Focused + Size.Y * NumCols;
      kbPgUp: NewItem := Focused - Size.Y * NumCols;
      kbHome: NewItem := TopItem;
      kbEnd: NewItem := TopItem + (Size.Y * NumCols) - 1;
      kbCtrlPgDn: NewItem := Range - 1;
      kbCtrlPgUp: NewItem := 0;
    else
      Exit;
    end;
    FocusItemNum(NewItem);
    DrawView;
    ClearEvent(Event);
  end else
  If Event.What = evCommand Then
    Begin
      Case Event.Command Of
        cmCompareDirectories : AktivePanel^.CompareDirectories;
        cmInversSelect  : AktivePanel^.InversSelect;
        CmSelectGroup   : AktivePanel^.SelectGroup;
        cmUnselectGroup : AktivePanel^.UnSelectGroup;
        cmSelectFile: If Files^.Count<>0 Then
                   Begin
                   F:=Files^.At(Focused);
                   If F^.Name<>'..'Then
                     Begin
                       If F^.Selected Then Begin
                                             Dec(AktivePanel^.Selected);
                                             Dec(AktivePanel^.SelBytes,F^.Size);
                                           End
                         Else Begin
                                Inc(AktivePanel^.Selected);
                                Inc(AktivePanel^.SelBytes,F^.Size);
                              End;
                       F^.Selected:=Not F^.Selected;
                       AktivePanel^.Window^.Frame^.Draw;
                     End;
                   NewItem:=Focused;
                   If (NewItem<>(Range-1)) Then Inc(NewItem);
                     FocusItemNum(NewItem);
                     DrawView;
                     ClearEvent(Event);
                End;
               End;
    End
   Else if Event.What = evBroadcast then
    if Options and ofSelectable <> 0 then
      if (Event.Command = cmScrollBarClicked) and
         ((Event.InfoPtr = HScrollBar) or (Event.InfoPtr = VScrollBar)) then
        Select
      else if (Event.Command = cmScrollBarChanged) then
      begin
        if (VScrollBar = Event.InfoPtr) then
        begin
          FocusItemNum(VScrollBar^.Value);
          DrawView;
        end else if (HScrollBar = Event.InfoPtr) then DrawView;
      end;
If (Change) Then  Begin
                     X := Nil;
                     If Files^.Count<>0 Then X := Files^.At(Focused);
                     Message(Owner,evCommand,cmDrawLFN,X);
                     If LeftPanel^.Window=Pointer(Owner) Then
                       Message(LeftPanel^.FileInfo,evCommand,cmUpdateFileInfo,X)
                        Else Message(RightPanel^.FileInfo,evCommand,cmUpdateFileInfo,X)
                   End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TFileBox.ChangeDirectory;
Var D2,D  : String;
    Di : SearchRec;
    Aktual : PPanel;
    OldDir : String;
Begin
 If SetDir = False Then GetDir(0,OldDir);
 If LeftPanel^.ListBox=@Self Then Aktual:= LeftPanel
   Else Aktual:= RightPanel;
 {$I-}
  DosError:=0;If Ioresult<>0 Then;
  ChDir(Dir);
  If (DosError<>0) Or (Ioresult<>0) Then Aktual^.ChooseDrive(False)
  Else Begin
    GetDir(0,D);
 {$I+}
  If DosError<>0 Then Begin
                       {ChDir(OldDir);}
                       Aktual^.ChooseDrive(False);
                      End
    Else Begin
           D2:=D;
           If (D2[Length(D2)]<>':') And (D2[Length(D2)]<>'\') Then D2:=D2+'\';
           FindFirst(D2 + '*.*', AnyFile, Di);
           If (DosError<>18) And (DosError<>0) Then Aktual^.ChooseDrive(False)
             Else Begin
                    Files^.ReadDirectory(D);
                    Aktual^.SetAktualDir(D);
                    Aktual^.Selected:=0;Aktual^.SelBytes:=0;
                    Aktual^.Window^.Frame^.Draw;
                    Range:=Files^.Count;
                    LongNames^.ReadDirectory(D,True);
                    Aktual^.PanelData^.AktualDirectory := D;
                  End;
         End;
       End;
  If SetDir = False Then Begin
                          {$I-}
                          DosError:=0;
                          ChDir(OldDir);
                          If (DosError<>0) or (IoResult<>0) Then Aktual^.ChooseDrive(False)
                          {$I+}
                         End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Destructor TDoorsBackGround.Done;
Begin
 TBackGround.Done;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TFileBox.Draw;
var
  I, J, Item: Integer;
  NormalColor, FocusedColor, FocusSelFile, FocusSelAddr,
  SelectedFileColor, SelectedAddrColor, Color: Word;
  ColWidth, CurCol, Indent: Integer;
  B: TDrawBuffer;
  Text: String;
  SCOff: Byte;
  F : PFileRec;
  S  : String;
begin
  if State and (sfSelected + sfActive) = (sfSelected + sfActive) then
  begin
    NormalColor := GetColor(1);
    SelectedFileColor := GetColor(4);
    SelectedAddrColor := GetColor(6);
    FocusedColor := GetColor(3);
    FocusSelFile := GetColor(7);
    FocusSelAddr := GetColor(8);
  end else
  begin
    NormalColor := GetColor(2);
    SelectedFileColor := GetColor(4);
    SelectedAddrColor := GetColor(6);
  end;
  if HScrollBar <> nil then Indent := HScrollBar^.Value
  else Indent := 0;
  ColWidth := Size.X div NumCols + 1;
  for I := 0 to Size.Y - 1 do
  begin
    for J := 0 to NumCols-1 do
    begin
      Item := J*Size.Y  + I + TopItem;
      CurCol := J*ColWidth;
      if (State and (sfSelected + sfActive) = (sfSelected + sfActive)) and
        (Focused = Item) and (Range > 0) then
      begin
        Color := FocusedColor;
        If IsSelected(Item) Then
         Begin
           F := Files^.At(Item);
           If (F^.Attr And Directory)=Directory Then Color:=FocusSelAddr
             Else Color := FocusSelFile;
         End;
        SetCursor(CurCol+1,I);
        SCOff := 0;
      end
      else if (Item < Range) and IsSelected(Item) then
      begin
        F  := Files^.At(Item);
        If (F^.Attr And Directory)=Directory Then Color:=SelectedAddrColor
         Else Color := SelectedFileColor;
        SCOff := 2;
      end
      else
      begin
        Color := NormalColor;
        SCOff := 4;
      end;
      MoveChar(B[CurCol], ' ', Color, ColWidth);
      if Item < Range then
      begin
        Text := GetText(Item, ColWidth + Indent);
        Text := Copy(Text,Indent,ColWidth);
        MoveStr(B[CurCol{+1}], Text, Color);
        if ShowMarkers then
        begin
          WordRec(B[CurCol]).Lo := Byte(SpecialChars[SCOff]);
          WordRec(B[CurCol+ColWidth-2]).Lo := Byte(SpecialChars[SCOff+1]);
        end;
      end;
      MoveChar(B[CurCol+ColWidth-1], #179, GetColor(5), 1);
    end;
    WriteLine(0, I, Size.X, 1, B);
  end;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{****************************************************************************}
{                            OBJEKT - PANELWINDOW                            }
{****************************************************************************}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPanelWindow.InitFrame;
Var
  R: TRect;
Begin
  GetExtent(R);
  Frame := New(PNewFrame, Init(R));
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function TPanelWindow.GetPalette;
Const CPanelWindow = #136#137#138#139#140#141#142#143;
      CBWindow     = #144#145#146#147#148#149#150#151;
      P: string[Length(CBWindow+CPanelWindow)] = CBWindow + CPanelWindow;
Begin
  GetPalette := @P;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function TPanelWindow.GetTitle;
Var S : String;
    Panel : PPanel;
Begin
  If (AktivePanel^.NextPanel<>Nil) And (AktivePanel^.NextPanel^.Window=@Self)
    Then Panel:=AktivePanel^.NextPanel Else Panel:=AktivePanel;
  S:= Panel^.AktualDirectory^;
  If Length(S) > MaxSize Then Begin
                                System.Delete(S,1,Length(S)-MaxSize+2);
                                S:='..'+S;
                              End;
  GetTitle:=S;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPanelWindow.HandleEvent;
Var SaveState   : Word;
Const Saved     : Boolean = False;
Var   X         : PFileRec;
Begin
Case Event.What Of
  EvKeyDown :
    Case Event.KeyCode Of
      KbCtrlR : AktivePanel^.ReRead;
      KbCtrlLom :
        Begin
         If Length(AktivePanel^.AktualDirectory^)>3 Then
             With AktivePanel^ Do
               Begin
                 ListBox^.ChangeDirectory('\',true);
                 ListBox^.FocusItem(0);
                 ListBox^.Draw;
               End
        End;
      KbCtrlRightBracket : CommandLine^.AddParametr(RightPanel^.AktualDirectory^);
      KbCtrlLeftBracket  : CommandLine^.AddParametr(LeftPanel^.AktualDirectory^);
      KbCtrlEnter :        CommandLine^.AddParametr(AktivePanel^.GetFocused);
      KbTab :
        Begin
          AktivePanel^.NextPanel^.Select;ClearEvent(Event);
        End;
    End;
  EvMouseDown : If AktivePanel^.Window<>@Self Then
                  Begin
                    AktivePanel:=AktivePanel^.NextPanel;
                    AktivePanel^.Select;
                  End;
  evCommand :
    Case Event.Command Of
      CmView       : If AktivePanel^.GetFocusedFile<>'' Then HexViewer(AktivePanel^.GetFocusedFile);
      CmEdit       : If AktivePanel^.GetFocusedFile<>'' Then EditFile(AktivePanel^.GetFocusedFile);
      CmDrawLFN    : Begin
                       X:=Event.InfoPtr;
                       If Configuration.System.ShowLongNames Then
                         WriteLongName(LongNames^.GetLongName(X^.Name));
                       ClearEvent(Event);
                     End;

      End;
  End;
  TWindow.HandleEvent(Event);
{  CommandLine^.ShowCursor;}
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPanelWindow.WriteLongName;
Var B  : TDrawBuffer;
    Color : Word;
    LFN : String;
Begin
  Color := GetColor(1);
  If S<>'' Then
    Begin
      LFN:='[' + S + ']';
      If Length(LFN)>Size.X-3 Then LFN[0]:=Chr((Size.X-3));
      MoveStr(B,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ',Color);
      MoveStr(B,LFN,Color);
      WriteBuf(1,Size.Y-3,Size.X-3,1,B);
    End
  Else Begin
         MoveStr(B,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ',Color);
         WriteBuf(1,Size.Y-3,Size.X-2,1,B);
       End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TPanelWindow.ChangeBounds;
Var Panel : PPanel;
Begin
 If (AktivePanel^.NextPanel<>Nil) And (AktivePanel^.NextPanel^.Window=@Self)
    Then Panel:=AktivePanel^.NextPanel Else Panel:=AktivePanel;
 Inherited ChangeBounds(Bounds);
 Panel^.PanelData^.Origin := Origin;
 Panel^.PanelData^.Size := Size;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPanelWindow.SizeLimits(var Min,Max: TPoint);
Begin
 Inherited SizeLimits(Min,Max);
 Max.X := Desktop^.Size.X; Max.Y:= Desktop^.Size.Y;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Destructor TPanelWindow.Done;
Begin
 TWindow.Done;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
constructor TNewFrame.Init(var Bounds: TRect);
begin
  TView.Init(Bounds);
  GrowMode := gfGrowHiX + gfGrowHiY;
  EventMask := EventMask or evBroadcast;
end;

procedure TnewFrame.FrameLine(var FrameBuf; Y, N: Integer;
  Color: Byte); assembler;
const
  InitFrame: array[0..17] of Byte =
    ($06, $0A, $0C, $05, $00, $05, $03, $0A, $09,
     $16, $1A, $1C, $15, $00, $15, $13, $1A, $19);
  FrameChars: array[0..31] of Char =
    '   À ³ÚÃ ÙÄÁ¿´ÂÅ   À ³ÚÃ ÙÄÁ¿´Â ';
var
  FrameMask: array[0..MaxViewWidth-1] of Byte;
asm
        LES     BX,Self
        MOV     DX,ES:[BX].TFrame.Size.X
        MOV     CX,DX
        DEC     CX
        DEC     CX
        MOV     SI,OFFSET InitFrame
        ADD     SI,N
        LEA     DI,FrameMask
        PUSH    SS
        POP     ES
        CLD
        MOVSB
        LODSB
        REP     STOSB
        MOVSB
        LES     BX,Self
        LES     BX,ES:[BX].TFrame.Owner
        LES     BX,ES:[BX].TGroup.Last
        DEC     DX
@1:     LES     BX,ES:[BX].TView.Next
        CMP     BX,WORD PTR Self[0]
        JNE     @2
        MOV     AX,ES
        CMP     AX,WORD PTR Self[2]
        JE      @10
@2:     TEST    ES:[BX].TView.Options,ofFramed
        JE      @1
        TEST    ES:[BX].TView.State,sfVisible
        JE      @1
        MOV     AX,Y
        SUB     AX,ES:[BX].TView.Origin.Y
        JL      @3
        CMP     AX,ES:[BX].TView.Size.Y
        JG      @1
        MOV     AX,0005H
        JL      @4
        MOV     AX,0A03H
        JMP     @4
@3:     INC     AX
        JNE     @1
        MOV     AX,0A06H
@4:     MOV     SI,ES:[BX].TView.Origin.X
        MOV     DI,ES:[BX].TView.Size.X
        ADD     DI,SI
        CMP     SI,1
        JG      @5
        MOV     SI,1
@5:     CMP     DI,DX
        JL      @6
        MOV     DI,DX
@6:     CMP     SI,DI
        JGE     @1
        OR      BYTE PTR FrameMask[SI-1],AL
        XOR     AL,AH
        OR      BYTE PTR FrameMask[DI],AL
        OR      AH,AH
        JE      @1
        MOV     CX,DI
        SUB     CX,SI
@8:     OR      BYTE PTR FrameMask[SI],AH
        INC     SI
        LOOP    @8
        JMP     @1
@10:    INC     DX
        MOV     AH,Color
        MOV     BX,OFFSET FrameChars
        MOV     CX,DX
        LEA     SI,FrameMask
        LES     DI,FrameBuf
@11:    SEGSS   LODSB
        XLAT
        STOSW
        LOOP    @11
end;

procedure TnewFrame.Draw;
var
  CFrame, CTitle: Word;
  F, I, L, Width: Integer;
  B: TDrawBuffer;
  Title: TTitleStr;
  Min, Max: TPoint;
  S : String [40];
  SelSize : String [12];
  Selected : String [10];
  Panel : PPanel;
  X : PFileRec;
begin
  if State and sfDragging <> 0 then
  begin
    CFrame := $0505;
    CTitle := $0001;
    F := 0;
  end else if State and sfActive = 0 then
  begin
    CFrame := $0001;
    CTitle := $0001;
    F := 0;
  end else
  begin
    CFrame := $0501;
    CTitle := $0003;
    F := 9;
  end;
  CFrame := GetColor(CFrame);
  CTitle := GetColor(CTitle);
  Width := Size.X;
  L := Width - 10;
  if PWindow(Owner)^.Flags and (wfClose+wfZoom) <> 0 then Dec(L,6);
  FrameLine(B, 0, F, Byte(CFrame));
  if (PWindow(Owner)^.Number <> wnNoNumber) and
     (PWindow(Owner)^.Number < 10) then
  begin
    Dec(L,4);
    if PWindow(Owner)^.Flags and wfZoom <> 0 then I := 7
    else I := 3;
    WordRec(B[Width - I]).Lo := PWindow(Owner)^.Number + $30;
  end;
  if Owner <> nil then Title := PWindow(Owner)^.GetTitle(L)
  else Title := '';
  if Title <> '' then
  begin
    L := Length(Title);
    if L > Width - 10 then L := Width - 10;
    if L < 0 then L := 0;
    I := (Width - L) shr 1;
    MoveChar(B[I - 1], ' ', CTitle, 1);
    MoveBuf(B[I], Title[1], CTitle, L);
    MoveChar(B[I + L], ' ', CTitle, 1);
  end;
  if State and sfActive <> 0 then
  begin
    if PWindow(Owner)^.Flags and wfClose <> 0 then
      if FrameMode and fmCloseClicked = 0 then
        MoveCStr(B[2], '[~ş~]', CFrame)
      else MoveCStr(B[2], '[~'#15'~]', CFrame);
    if PWindow(Owner)^.Flags and wfZoom <> 0 then
    begin
      MoveCStr(B[Width - 5], '[~'#24'~]', CFrame);
      Owner^.SizeLimits(Min, Max);
      if FrameMode and fmZoomClicked <> 0 then
        WordRec(B[Width - 4]).Lo := 15
      else if Longint(Owner^.Size) = Longint(Max) then
        WordRec(B[Width - 4]).Lo := 18;
    end;
  end;
  WriteLine(0, 0, Size.X, 1, B);
  for I := 1 to Size.Y - 2 do
  begin
    FrameLine(B, I, F + 3, Byte(CFrame));
    WriteLine(0, I, Size.X, 1, B);
  end;
  FrameLine(B, Size.Y - 1, F + 6, Byte(CFrame));
  if State and sfActive <> 0 then
    if PWindow(Owner)^.Flags and wfGrow <> 0 then
      MoveCStr(B[Width - 1], '~'#18'~', CFrame);
  WriteLine(0, Size.Y - 1, Size.X, 1, B);

 If (AktivePanel^.Window^.Frame=@Self) Or (AktivePanel^.NextPanel=Nil) Then Panel:=AktivePanel
   Else Panel:=AktivePanel^.NextPanel;
 If Panel^.Selected>0 Then
   Begin
     MoveStr(B,'[',CFrame);
     SelSize := Thousand(Panel^.SelBytes) + ' B';
     Selected := IntToStr(Panel^.Selected);
     S:=SelSize + ' v ' + Selected+' oznac.';
     MoveStr(B[1],S,(Cframe and $F0) or $0D);
     MoveStr(B[1+Length(S)],']',CFrame);
     WriteBuf(1,Size.Y-1,2+Length(S),1,B);
   End;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{****************************************************************************}
{                            OBJEKT  - COMMANDLINE                           }
{****************************************************************************}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
constructor TCommandLine.Init;
Begin
  TInputLine.Init(Bounds,AMaxLen);
  Options:=ClearBit(Options,ofSelectable);
  Options:=SetBit(Options,ofPreProcess);
  SetValidator(Nil);
  New(AktualDirectory);
  AktualDirectory^:='';OldCommand := 0;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TCommandLine.ShowCursor;
Var OldState : Word;
Begin
  OldState := State;
  State := SetBit(State,sfSelected + sfFocused);
  SetState(sfCursorVis, True);
  State := OldState;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TCommandLine.NewText;
Begin
  DisposeStr(Data);
  Data:= NewStr(S);
  CurPos := Length(S);
  Draw;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TCommandLine.AddParametr;
Begin
  Data^:= Data^ + S + #32;
  Inc(CurPos,Length(S) + 1);
  Draw;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TCommandLine.AddText;
Begin
  Data^:=Data^+S;
  Inc(CurPos,Length(S));
  Draw;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function TCommandLine.GetPalette;
Const CFileBox = #152#153#154#155;
      P: string[Length(CFileBox)] = CFileBox;
Begin
  GetPalette := @P;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function TCommandLine.CanScroll(Delta: Integer): Boolean;
begin
  if Delta < 0 then
    CanScroll := FirstPos > 0 else
  if Delta > 0 then
    CanScroll := (Length(AktualDirectory^)+3+Length(Data^)) - (FirstPos)> Size.X else
    CanScroll := False;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TCommandLine.Draw;
var
  Color: Byte;
  L, R: Integer;
  B: TDrawBuffer;
  OldFirstPos : Integer;
  OldState : Word;
begin
  OldFirstPos:=FirstPos;
  If CurPos > (Size.X-Length(AktualDirectory^)-3) Then
      FirstPos:=CurPos - (Size.X-Length(AktualDirectory^)-3);
  State:=SetBit(State,SfVisible+SfCursorVis+SfFocused);
  Color := GetColor(1);
  MoveChar(B,' ',Color,Size.X);
  MoveStr(B,AktualDirectory^ + '>', Color);
  MoveStr(B[Length(AktualDirectory^) + 1], Copy(Data^,
           FirstPos + 1, Size.X - 3 - Length(AktualDirectory^)), Color);
  if CanScroll(1) then MoveChar(B[Size.X - 1], #16, GetColor(4), 1);
  if CanScroll(-1) then MoveChar(B[Length(AktualDirectory^)+1], #17, GetColor(4), 1);
  WriteLine(0, 0, Size.X, Size.Y, B);
  OldState := State;
  State:= State Or (SfSelected + SfFocused);
  SetCursor(CurPos - FirstPos + 1 + Length(AktualDirectory^), 0);
  State := OldState;
  State:=ClearBit(State,SfFocused);
  FirstPos:=OldFirstPos;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TCommandLine.HandleEvent;
Const Clear : Boolean = True;
Var I : Integer;
{ÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure DeleteSelect;
begin
  if SelStart <> SelEnd then
  begin
    Delete(Data^, SelStart + 1, SelEnd - SelStart);
    CurPos := SelStart;
  end;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄ}
begin
Clear:=True;
  TView.HandleEvent(Event);
    case Event.What of
      evKeyDown:
        begin
          case Event.KeyCode of
            kbCtrlE     : Begin
                           If Length(Data^)=0 Then OldCommand := 0;
                           If OldCommand<HistoryCount(HiCommandLine) Then
                           NewText(HistoryStr(HiCommandLine,OldCommand));
                           Inc(OldCommand);
                          End;
            KbGrayTimes : Clear := False;
            KbGrayPlus  : Clear := False;
            KbGrayMinus : Clear := False;
            kbEnter:
              if Length(Data^)<>0 Then RunProgram(Data^) else Clear:=False;
            kbLeft:
              if (GetShiftState and $03<>0) and (CurPos > 0) then Dec(CurPos)
                else Clear:=False;
            kbRight:
              if (GetShiftState and $03<>0) and (CurPos < Length(Data^)) then Inc(CurPos)
                else Clear:=False;
            kbLeft:
              if (CurPos > 0) and (GetShiftState and $03<>0) then Dec(CurPos);
            kbRight:
              if (CurPos < Length(Data^)) and (GetShiftState and $03<>0) then Inc(CurPos);
            kbBack:
              if CurPos > 0 then
              begin
                Delete(Data^, CurPos, 1);
                Dec(CurPos);
                if FirstPos > 0 then Dec(FirstPos);
              end;
            kbDel:
              if CurPos < Length(Data^) then
              begin
                SelStart := CurPos;
                SelEnd := CurPos + 1;
                DeleteSelect;
              end;
          else
            case Event.CharCode of
              ' '..#255:
                begin
                    if Length(Data^) < MaxLen then
                    begin
                      if FirstPos > CurPos  then FirstPos := CurPos;
                      Inc(CurPos);
                      Insert(Event.CharCode, Data^, CurPos);
                    end;
                end;
              ^Y:
                begin
                  Data^ := '';
                  CurPos := 0;
                end;
            else
              Exit;
            end
          end;
            SelStart := CurPos;
            SelEnd := CurPos;
            if FirstPos > CurPos  then FirstPos := CurPos;
            I := CurPos - (Size.X + 2);
            if FirstPos < I then FirstPos := I;
            DrawView;
            If Clear Then ClearEvent(Event);
        end;
    end;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TCommandLine.RunProgram;
Var Str : PString;
    S, O : Word;
    Error : Boolean;
    Path : String;
    NoRun : Boolean;
    I     : Integer;
Begin
  NoRun := True;For I:=1 To Length(Name) Do
    If Name[I]<>#32 Then NoRun := False;
  If NoRun Then Exit;
  Asm
    mov Error,0
    mov ax,9900h
    Int 2fh
    cmp bx,'DO'
    Jne @Er
    cmp dx,'OR'
    Jne @Er
    mov ax,9901h
    Int 2fh
    Mov O,bx
    Mov S,es
    Jmp @AsmEnd
    @Er:
     mov Error,1
    @AsmEnd:
  end;
  Str:=Ptr( S , O);
  Str^:=Name;
  Path := AktualDirectory^ + '>';
  HistoryAdd(hiCommandLine,Name);
  Application^.Done;
  SaveSwapConfiguration;
  Writeln(Path + Name);
  If Not Error  Then Halt(1) else
    Begin Writeln('Chyba spou¨ten¡ programu !!');Halt(0);End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Destructor TCommandLine.Done;
Begin
  Dispose(AktualDirectory);
  TInputLine.Done;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TPanelInfo.CalcBounds;
Begin
  GetBounds(Bounds);
  Bounds.B.X := Bounds.B.X + Delta.X ;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TPanelInfo.ChangeBounds;
Var NumCols  : Integer;
    ColWidth : Integer;
    S        : String;
    C,W      : Integer;
Begin
  Inherited ChangeBounds(Bounds);
  If Text<>Nil Then DisposeStr(Text);
  NumCols := (Size.X + 1) Div 13;
  ColWidth := Size.X div NumCols + 1;
  S:='';
  For C:= 1 To NumCols Do
  For W:= 1 To ColWidth Do Begin
                          If W=1 Then S := S + ' Jm‚no   Ext';
                          If W>12 Then S := S + #32;
                          End;

  Text := NewStr(S);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

End.