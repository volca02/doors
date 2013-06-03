{$O+,F+}
Unit Tools;
Interface
Uses Views, Objects, Drivers, Dialogs, Status;
const
   AsciiTableCommandBase: Word = 910;
   Index : Byte = 0;

   BlockDriver = $8000;

   DaysInMonth: array[1..12] of Byte =
     (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

   MonthStr: array[1..12] of string[10] =
     ('Leden     ',
      'Unor      ',
      'Brezen    ',
      'Duben     ',
      'Kveten    ',
      'Cerven    ',
      'Cervenec  ',
      'Srpen     ',
      'Zari      ',
      'Rijen     ',
      'Listopad  ',
      'Prosinec  ');

 Function CDPlayer     : Word;
 Function SysInfo      : Word;
 Function About        : Word;
 Function Calendar     : Word;
 Function Calc         : Word;
 Function ASCIITable   : Word;
 Function DriversList  : Word;
 Function UsedCommands : String;
 procedure RegisterCalendar;
 procedure RegisterCalc;

Type
   PHead  = ^THead;
   THead  = Record
              Next : PHead;
              DevAttr:Word;
              Strategy:Word;
              Interupt:Word;
              Name : Array [1..8] Of Char;
             End;

  TCalcState = (csFirst, csValid, csError);

  PDriversListViewer = ^TDriversListViewer;
  TDriversListViewer = Object(TListViewer)
                         function GetText(Item: Integer; MaxLen: Integer): String; virtual;
                       End;

  PTeamCollection = ^TTeamCollection;
  TTeamCollection = Object(TCollection)
                      procedure FreeItem(Item: Pointer); virtual;
                    End;

  PTeamDialog = ^TTeamDialog;
  TTeamDialog = Object(TDialog)
                  procedure HandleEvent(var Event: TEvent); virtual;
                End;

  PScrollDialog = ^TScrollDialog;
  TScrollDialog = Object(TDialog)
                    Status : PTeamStatus;
                    procedure HandleEvent(var Event: TEvent); virtual;
                  End;

  PTable = ^TTable;
  TTable = object(TView)
    Index : Byte;
    procedure Draw; virtual;
    procedure GetData(var Rec);Virtual;
    procedure SetData(var Rec);Virtual;
    procedure HandleEvent(var Event:TEvent); virtual;
  end;

  PReport = ^TReport;
  TReport = object(TView)
    ASCIIChar: LongInt;
    procedure Draw; virtual;
    procedure HandleEvent(var Event:TEvent); virtual;
  end;

  PCalcDisplay = ^TCalcDisplay;
  TCalcDisplay = object(TView)
    Status: TCalcState;
    Number: string[15];
    Sign: Char;
    Operator: Char;
    Operand: Real;
    constructor Init(var Bounds: TRect);
    constructor Load(var S: TStream);
    procedure CalcKey(Key: Char);
    procedure Clear;
    procedure Draw; virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
  end;


 PCalendarView = ^TCalendarView;
 TCalendarView = object(TView)
   Year, Month, Days: Word;
   CurYear, CurMonth, CurDay : Word;
   constructor Init(Bounds: TRect);
   constructor Load(var S: TStream);
   procedure HandleEvent(var Event: TEvent); virtual;
   procedure Draw; virtual;
   procedure Store(var S: TStream);
 end;

const
  RCalendarView: TStreamRec = (
     ObjType: 10020;
     VmtLink: Ofs(TypeOf(TCalendarView)^);
     Load:    @TCalendarView.Load;
     Store:   @TCalendarView.Store
  );

   RCalcDisplay: TStreamRec = (
     ObjType: 10040;
     VmtLink: Ofs(TypeOf(TCalcDisplay)^);
     Load:    @TCalcDisplay.Load;
     Store:   @TCalcDisplay.Store
  );

Implementation
  Uses Info, Supply, App, Base, Dos, DRSHelp, Variable, HistList, Crt, MessBox;
{$I INC\CD.INC}
Type
     PStrCollection = ^TStrCollection;
     TStrCollection = Object(TCollection)
                        Procedure FreeItem(Item : Pointer);Virtual;
                      End;

     PSongCollection = ^TSongCollection;
     TSongCollection = Object(TCollection)
                        procedure PutItem(var S: TStream; Item: Pointer); virtual;
                        procedure FreeItem(Item : Pointer);virtual;
                        function GetItem(var S: TStream): Pointer; virtual;
                       End;

     PCD          = ^TCD;
     TCD          = Record
                     DiskLabel : PString;
                     Name  : PString;
                     Songs   : PSongCollection;
                    End;

     PSongListBox = ^TSongListBox;
     TSongListBox = Object (TListBox)
                     function GetText(Item: Integer; MaxLen: Integer): String; virtual;
                     procedure HandleEvent(var Event: TEvent); virtual;
                    End;

     PCatalog     = ^TCatalog;
     TCatalog     = Object (TCollection)
                     Procedure FreeItem(Item : Pointer);Virtual;
                     procedure PutItem(var S: TStream; Item: Pointer); virtual;
                     function GetItem(var S: TStream): Pointer; virtual;
                    End;
     PCdDialog      = ^TCdDialog;
     TCDDialog      = Object(TDialog)
                       Catalog : PCatalog;
                       Data : PCollection;
                       Time, TotalTime : PStaticText;
                       Track, NumberOfTrack : PStaticText;
                       CDName, SongName : PStaticText ;
                       constructor Init(var Bounds: TRect; ATitle: TTitleStr);
                       Procedure HandleEvent (var Event : TEvent);Virtual;
                       Procedure RedrawInfo;
                       Function SearchDiskName : String;
                       Function SearchSongName (Tr : Byte ) : String;
                       Destructor Done;Virtual;
                      End;
Var Drvs : PCollection;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function TSongListBox.GetText;
Var Str : PString;
Begin
 GetText :='';
 If List^.Count-1<Item Then Exit;
 Str := PString(List^.At(Item));
 If Str<>Nil Then GetText := IntToStr(Item+1) + ': ' + Str^
  Else GetText := IntToStr(Item+1) + ':';
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TSongListBox.HandleEvent;
Var S: PString;
    Str : String;
Begin
  TListBox.HandleEvent(Event);
  If List^.Count-1<Focused Then Exit;
  Case Event.What Of
   evCommand : Case Event.Command Of
                cmEdit : Begin
                           S:= List^.At(Focused);
                           If S<>Nil Then Str := S^ Else Str:='';
                           InputBox('Jmena pisnicek','Zadejte jmeno pisnicky :',Str,255,HiSongName);
                           List^.AtDelete(Focused);
                           If S<>Nil Then DisposeStr(S);
                           S:=NewStr(Str);
                           List^.AtInsert(Focused,S);
                           DrawView;
                         End
               End
  End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function TSongCollection.GetItem;
Begin
 GetItem := Nil;
 If S.Status = stOk Then GetItem := S.ReadStr;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TSongCollection.PutItem;
Begin
 If S.Status = stOk Then S.WriteStr(PString(Item));
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function TCatalog.GetItem;
Var CD : PCD;
Begin
 New(CD);
 Cd^.Name := Nil; CD^.DiskLabel := Nil; Cd^.Songs := Nil;
 If S.Status = stOk Then CD^.DiskLabel:=S.ReadStr;
 If S.Status = stOk Then CD^.Name:=S.ReadStr;
 If S.Status = stOk Then CD^.Songs := New(PSongCollection,Init(0,1));
 If S.Status = stOk Then CD^.Songs^.Load(S);
 GetItem := CD;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TCatalog.PutItem;
Begin
 If Item <> Nil Then Begin
                       S.WriteStr(PCD(Item)^.DiskLabel);
                       S.WriteStr(PCD(Item)^.Name);
                       PCD(Item)^.Songs^.Store(S);
                     End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TSongCollection.FreeItem;
Begin
 If Item<>nil Then DisposeStr(PString(Item));
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TCatalog.FreeItem;
Var CD : PCd;
Begin
  If Item=Nil Then Exit;
  CD:=Item;
  If CD^.Songs<>Nil Then Dispose(CD^.Songs,Done);
  If CD^.Name<>Nil Then DisposeStr(CD^.Name);
  If CD^.DiskLabel<>Nil Then DisposeStr(CD^.DiskLabel);
  Dispose(CD);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure SongEditor(Var Catalog : PCatalog);
var
  D    : PDialog;
  C    : PView;
  L    : PLabel;
  SB   : PScrollBar;
  R    : TRect;
  H    : PHistory;
  I    : Integer;
  Data : record
          Name               :  string[40];
          Songs              :  PCollection;
          Count              :  integer;
         end;

  CD   : PCD;
  Search : Boolean;
begin
  If (CdHigHestTrack = 0) Or (CdHigHestTrack>100) Then Exit;
  If Catalog = Nil Then Catalog:= New(PCatalog,Init(0,1));
  Search := False;
  For I:=0 To Catalog^.Count-1 Do
    Begin
      Cd := Catalog^.At(I);
      If CD^.DiskLabel^ = CDLabel Then Begin Search := True;Break;End;
    End;
  If Not Search Then Begin
                       New (CD);
                       Cd^.Name := Nil;
                       CD^.DiskLabel := NewStr(CdLabel);
                       Cd^.Songs := New(PSongCollection,Init(0,1));
                       For I:=1 To CdHigHestTrack Do
                        CD^.Songs^.Insert(Nil);
                     End;
  If Cd^.Name<> Nil Then Data.Name := Cd^.Name^
    Else Data.Name:='';
  Data.Songs := CD^.Songs;
  Data.Count := CD^.Songs^.Count;
  R.Assign(14,2,66,21);
  D:=New(PDialog,Init(R,'Editor CD'));
  with D^ do
       begin
          R.Assign(3,2,35,3);
          C:=New(PInputLine,Init(R,40));
          Insert(C);

          R.Assign(2,1,14,2);
          L:=New(PLabel,Init(R,'Jm‚no CD :',C));
          Insert(L);

          R.Assign(35,2,38,3);
          H:=New(PHistory,Init(R,PInputLine(C),HiCDDiskName));
          Insert(H);

          R.Assign(37,4,38,17);
          SB:=New(PScrollBar,Init(R));
          Insert(SB);

          R.Assign(3,4,37,17);
          C:=New(PSongListBox,Init(R,1,SB));
          Insert(C);

          R.Assign(39,2,49,4);
          C:=New(PButton,Init(R,'~O~k',cmOk,BfNormal));
          Insert(C);

          R.Assign(39,4,49,6);
          C:=New(PButton,Init(R,'~E~dituj',cmEdit,bfDefault));
          Insert(C);

          SelectNext(False);
       end;

   Application^.ExecuteDialog(D,@Data);
   If Cd^.Name<>Nil Then DisposeStr(Cd^.Name);
   CD^.Name := NewStr(Data.Name);
   If Not Search Then Catalog^.Insert(CD);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function I2S(I: Longint): String;
var
  S  : string[11];
  x  : byte;
begin
  Str(I, S);
  if odd(length(s)) then s:='0'+s;
  I2S := S;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function ConvertTime(var l) : String;
type
  time = record
            frm,sec, min  : byte;
         end;
var
  t  : ^time;
begin
  t:=@l;
  ConvertTime:=I2S(t^.min)+':'+I2S(t^.sec){$IFDEF FRAMES}+'.'+I2S(t^.frm){$ENDIF};
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
constructor TCDDialog.Init;
Var S: PBufStream;
Begin
 TDialog.Init(Bounds,ATitle);
 Catalog := New(PCatalog,Init(0,1));
 S:=New(PBufStream,Init(GetStartupPath + CDNamesFile,StOpenRead,2048));
 If S^.Status = StOk Then Catalog^.Load(S^);
 Dispose(S,Done);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Destructor TCDDialog.Done;
Var S: PBufStream;
Begin
 If Catalog <> Nil Then Begin
                         S:=New(PBufStream,Init(GetStartupPath + CDNamesFile,StCreate,2048));
                         If S^.Status = StOk Then Catalog^.Store(S^);
                         Dispose(S,Done);
                        End;
 If Catalog<>Nil Then Dispose(Catalog,Done);
 TDialog.Done;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function TCDDialog.SearchDiskName;
Var Cd : PCd;
    I  : Integer;
Begin
 SearchDiskName := '';
 If Catalog = Nil Then Exit;
 For I:=0 To Catalog^.Count-1 Do
   Begin
    CD := Catalog^.At(I);
    If (CD^.DiskLabel^=CDLabel) And (CD^.Name<>Nil) Then Begin SearchDiskName:= Cd^.Name^;Exit;End;
   End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function TCDDialog.SearchSongName;
Var I : Integer;
    Cd : PCd;
Begin
  SearchSongName := '';
  If CdTrackType[Tr] = 2 Then Begin
                                SearchSongName := 'Datova stopa nelze prehrat !';
                                Exit;
                              End;
  If Catalog = Nil Then Exit;
  If Tr < 1 Then Tr := 1;
  For I:=0 To Catalog^.Count-1 Do
   Begin
    CD := Catalog^.At(I);
    If (CD^.DiskLabel^=CDLabel) Then
     Begin
       If (CD^.Songs^.Count-1) < (Tr-1) Then Exit;
       If CD^.Songs^.At(Tr-1) <> Nil Then
         SearchSongName := PString(CD^.Songs^.At(Tr-1))^;
     End;
   End;

End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TCdDialog.RedrawInfo;
Var M : TRed;
Begin
 CdReadStatus;CDLoadTime1;
 If (CdStatus.CDOpen) or (CdVolumeSize=0)  Then
   DisableCommands([CmPlay,CmNext,CmLast,CmQuickNext,CmQuickLast,CmPause,CmStop,CmEditCDName])
  Else If CDTrackType[CDTrack]=2 Then
   Begin
     EnableCommands([CmNext,CmLast]);
     DisableCommands([CmPlay,CmQuickNext,CmQuickLast,CmPause,CmStop,CmEditCDName])
   End
     Else EnableCommands([CmPlay,CmNext,CmLast,CmQuickNext,CmQuickLast,CmPause,CmStop,CmEditCDName]);
 If (Not CdStatus.CDOpen) And (CDVolumeSize <> 0)Then
   Begin
    if CDchanged then
     begin
       CDLoadParams;
       cdstatus.cdplaying:=cdPlaying;
       cdstatus.cdpaused:=false;
       cdtrack:=CDLowestTrack;
     end;
    If (Not CdStatus.CdPaused) And (CdStatus.CdPlaying) Then
     Begin
      HSGtoRED(REDtoHSG(CDTrackTab[CDTrack+1])-
               REDtoHSG(CDTrackTab[CDTrack]),m);
      DisposeStr(Time^.Text);
      Time^.Text:=NewStr('€as : ' + I2S(Cdtime.tmin) +
                         ':' + I2S(Cdtime.tsec) + '.' + I2S(CDTime.tfrm) +
                         ' / ' + ConvertTime(m));
      Time^.DrawView;
     End;
     CDGetTotalTime(m);

     DisposeStr(TotalTime^.Text);
     TotalTime^.Text := NewStr('Celkov  d‚lka CD : ' + ConvertTime(m));
     TotalTime^.DrawView;

     DisposeStr(Track^.Text);
     Track^.Text := NewStr('Stopa : ' + I2S(cdtrack));
     Track^.DrawView;

     DisposeStr(NumberOfTrack^.Text);
     NumberOfTrack^.Text := NewStr('Po‡et stop :' + IntToStr(cdhighesttrack));
     NumberOfTrack^.DrawView;

     DisposeStr(CDName^.Text);
     CDName^.Text := NewStr('N zev CD : ' + SearchDiskName);
     CDName^.DrawView;

     DisposeStr(SongName^.Text);
     SongName^.Text := NewStr(#13#3 + SearchSongName(CDTrack));
     SongName^.DrawView;
   End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TCdDialog.HandleEvent;
Begin
 TDialog.HandleEvent(Event);
 Case Event.What Of
  EvCommand : Case Event.Command Of
               CmPlay      : CDPlay;
               CmNext      : CDNextTrack;
               CmLast      : CDLastTrack;
               CmStop      : CDStop;
               CmOpen      : CDEject;
               CmQuickLast : CDDec;
               CmQuickNext : CDInc;
               CmPause     : CDPause;
               CmEditCDName: SongEditor(Catalog);
              End;
 End;
 If Event.What= evNothing Then ReDrawInfo;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function CDPlayer;
var
  D    : PCDDialog;
  C    : PView;
  R    : TRect;
begin
  R.Assign(9,4,70,18);
  If Not MSCDECKInstalled Then
    Begin
      MessageBox('Nelze nalezt MSCDEX.EXE',Nil,mfError+mfOkButton);
      Exit;
    End;
  GetCDdriverName;
  CDGetHandle;
  CDLoadParams;
  cdstatus.cdplaying:=cdplaying;
  D:=New(PCDDialog,Init(R,'P©ehrava‡ CD'));
  D^.Options := SetBit(D^.Options,ofCentered);
  with D^ do
       begin
          R.Assign(4,2,57,8);
          C:=New(PFramedView,Init(R));
          Insert(C);

          R.Assign(10,9,16,11);
          C:=New(PButton,Init(R,'<<',cmQuickLast,bfNormal));
          Insert(C);

          R.Assign(25,9,31,11);
          C:=New(PButton,Init(R,'>>',cmQuickNext,bfNormal));
          Insert(C);

          R.Assign(16,9,25,11);
          C:=New(PButton,Init(R,'>',cmPlay,bfNormal));
          Insert(C);

          R.Assign(2,9,10,11);
          C:=New(PButton,Init(R,'|<<',cmLast,bfNormal));
          Insert(C);

          R.Assign(31,9,39,11);
          C:=New(PButton,Init(R,'>>|',cmNext,bfNormal));
          Insert(C);

          R.Assign(39,9,44,11);
          C:=New(PButton,Init(R,'ş',cmStop,bfNormal));
          Insert(C);

          R.Assign(44,9,51,11);
          C:=New(PButton,Init(R,'||',cmPause,bfNormal));
          Insert(C);

          R.Assign(51,9,58,11);
          C:=New(PButton,Init(R,#24,cmOpen,bfNormal));
          Insert(C);

          R.Assign(20,11,30,13);
          C:=New(PButton,Init(R,'~O~k',cmOk,bfDefault));
          Insert(C);

          R.Assign(30,11,42,13);
          C:=New(PButton,Init(R,'~N~ zev CD',cmEditCDName,bfNormal));
          Insert(C);

          R.Assign(6,2,Size.X-4,3);
          CdName:=New(PStaticText,Init(R,''));
          Insert(CdName);

          R.Assign(6,3,18,4);
          Track:=New(PStaticText,Init(R,''));
          Insert(Track);

          R.Assign(30,3,Size.X-4,4);
          NumberOfTrack:=New(PStaticText,Init(R,''));
          Insert(NumberOfTrack);

          R.Assign(6,4,Size.X-4,5);
          TotalTime:=New(PStaticText,Init(R,''));
          Insert(TotalTime);

          R.Assign(6,5,Size.X-4,6);
          Time:=New(PStaticText,Init(R,''));
          Insert(Time);

          R.Assign(6,6,Size.X - 5,8);
          SongName:=New(PStaticText,Init(R,''));
          Insert(SongName);
       end;

   CdPlayer:=Application^.ExecuteDialog(D,Nil);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TStrCollection.FreeItem;
Begin
  DisposeStr(Item);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function UsedCommands;
var
  DialogData : record
                 CommandList   :  PCollection;
                 Focused       :  integer;
               end;
  CommandList: PStrCollection;
  R          : Trect;
  D          : PDialog;
  C          : PView;
  SB         : PScrollBar;
  LBox       : PListBox;
  I          : Integer;
begin
  CommandList := New(PStrCollection, Init(0,1));
  For I:=0 To HistoryCount(HiCommandLine)-1 Do
    CommandList^.Insert(NewStr(HistoryStr(HiCommandLine,I)));
  R.Assign(0,0,70,20);
  D:=New(PDialog,Init(R,'Pouzite prikazy'));
  D^.Options := SetBit(D^.Options,ofCentered);
  with D^ do
       begin

          R.Assign(Size.X-4,2,Size.X-3,Size.Y-4);
          SB:=New(PScrollBar,Init(R));
          Insert(SB);

          R.Assign(3,2,Size.X-4,Size.Y-4);
          LBox:=New(PListBox,Init(R,1,SB));
          Insert(LBox);

          R.Assign(8,Size.Y-3,18,Size.Y-1);
          C:=New(PButton,Init(R,'~A~no',cmYes,bfDefault));
          Insert(C);
          Inc(R.A.X,10);Inc(R.B.X,10);
          C:=New(PButton,Init(R,'~Z~ru¨it',cmCancel,bfNormal));
          Insert(C);

          SelectNext(False);
       end;
   DialogData.CommandList:=CommandList;
   DialogData.Focused:=0;
   Application^.ExecuteDialog(D,@DialogData);
   Dispose(CommandList,Done);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function About: Word;
var
  D    : PDialog;
  C    : PView;
  R    : TRect;
  _DataPtr : Pointer;
begin
  R.Assign(10,1,69,22);
  D:=New(PTeamDialog,Init(R,'Informace o programu'));
  D^.Options:=SetBit(D^.Options,ofCentered);
  with D^ do
       begin
          R.Assign((Size.X Div 2)-13,18,(Size.X Div 2) - 3,20);
          C:=New(PButton,Init(R,'~O~k',cmOk,bfNormal));
          Insert(C);

          R.Assign((Size.X Div 2)-2,18,(Size.X Div 2) + 12,20);
          C:=New(PButton,Init(R,'~P~odekovani',cmThanks,bfNormal));
          Insert(C);

          R.Assign(26,1,33,2);
          C:=New(PStaticText,Init(R,'DOORS !'));
          Insert(C);

          R.Assign(22,3,37,4);
          C:=New(PStaticText,Init(R,Version));
          Insert(C);

          R.Assign(15,5,50,6);
          C:=New(PStaticText,Init(R,'exkluzivnˆ pro SP›E, Pardubice'));
          Insert(C);

          R.Assign(25,7,35,8);
          C:=New(PStaticText,Init(R,'vytvo©ily :'));
          Insert(C);

          R.Assign(11,9,23,10);
          C:=New(PStaticText,Init(R,'DAVID PETR‹K'));
          Insert(C);

          R.Assign(33,9,47,10);
          C:=New(PStaticText,Init(R,'FILIP VOLEJNIK'));
          Insert(C);

          R.Assign(10,10,24,11);
          C:=New(PStaticText,Init(R,'Bro‘¡kova 1405'));
          Insert(C);

          R.Assign(8,11,25,12);
          C:=New(PStaticText,Init(R,'Hradec Kr lov‚ 12'));
          Insert(C);

          R.Assign(14,12,20,13);
          C:=New(PStaticText,Init(R,'500 12'));
          Insert(C);

          R.Assign(32,10,49,11);
          C:=New(PStaticText,Init(R,'€.S.L. Arm dy 659'));
          Insert(C);

          R.Assign(36,11,45,12);
          C:=New(PStaticText,Init(R,'Chrudim 4'));
          Insert(C);

          R.Assign(37,12,43,13);
          C:=New(PStaticText,Init(R,'53 701'));
          Insert(C);

          R.Assign(4,14,55,15);
          C:=New(PStaticText,Init(R,#3'Program je vyroben pro ucebni ucely'));
          Insert(C);

          R.Assign(14,16,48,17);
          C:=New(PStaticText,Init(R,'Dod veme na v¨ech medi¡ch mimo ZIP'));
          Insert(C);

          SelectNext(False);
       end;

   _DataPtr:=NIL;
   Application^.ExecView(D);
   D^.Owner:=Application;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function SysInfo;
var
  D       : PDialog;
  C       : PView;
  R       : TRect;
  DataPtr : Pointer;
begin
  GetCHMOSInfo;
  R.Assign(2,1,77,21);
  D:=New(PDialog,Init(R,'Systemove informace'));
  with D^ do
       begin
          R.Assign(35,9,72,16);
          C:=New(PFramedView,Init(R));
          Insert(C);

          R.Assign(3,13,32,16);
          C:=New(PFramedView,Init(R));
          Insert(C);

          R.Assign(3,9,32,11);
          C:=New(PFramedView,Init(R));
          Insert(C);

          R.Assign(3,2,72,7);
          C:=New(PFramedView,Init(R));
          Insert(C);

          R.Assign(4,1,13,2);
          C:=New(PStaticText,Init(R,' Pocitac '));
          Insert(C);

          R.Assign(11,2,Size.X-3,3);
          C:=New(PStaticText,Init(R,'BIOS : '+'AMI'+' '+GetBiosDate));
          Insert(C);

          R.Assign(7,3,Size.X-3,4);
          C:=New(PStaticText,Init(R,'Procesor : ' + ProcesorType[GetProcesorType]));
          Insert(C);

          R.Assign(5,4,Size.X-3,5);
          C:=New(PStaticText,Init(R,'Koprocesor : ' + CoprocesorType[GetCoprocesorType]));
          Insert(C);

          R.Assign(4,5,Size.X-3,6);
          C:=New(PStaticText,Init(R,'Video karta : '+ GetVideoCardType));
          Insert(C);

          R.Assign(12,6,Size.X-3,7);
          C:=New(PStaticText,Init(R,'Mys : '+ GetMouseType));
          Insert(C);

          R.Assign(4,8,10,9);
          C:=New(PStaticText,Init(R,' Disk '));
          Insert(C);

          R.Assign(4,9,32,10);
          C:=New(PStaticText,Init(R,'Pevny disk : ' + GetHardDiskSize + ' MB'));
          Insert(C);

          R.Assign(5,10,29,11);
          C:=New(PStaticText,Init(R,'Mechanika : ' + GetFloppyType));
          Insert(C);

          R.Assign(4,12,10,13);
          C:=New(PStaticText,Init(R,' Pamet '));
          Insert(C);

          R.Assign(11,13,21,14);
          C:=New(PStaticText,Init(R,'DOS : '+
                      IntToStr(CHMOSInfo.BaseMemory)+'K'));
          Insert(C);

          R.Assign(6,14,26,15);
          C:=New(PStaticText,Init(R,'Extended : ' + GetXmsSize));
          Insert(C);

          R.Assign(6,15,26,16);
          C:=New(PStaticText,Init(R,'Expanded : ' + GetEmsSize));
          Insert(C);

          R.Assign(36,8,45,9);
          C:=New(PStaticText,Init(R,' Ostatni '));
          Insert(C);

          R.Assign(38,9,55,10);
          C:=New(PStaticText,Init(R,'Seriove porty : '));
          Insert(C);

          R.Assign(36,10,56,11);
          C:=New(PStaticText,Init(R,'Paralerni porty : '));
          Insert(C);

          R.Assign(36,11,64,12);
          C:=New(PStaticText,Init(R,'Operacni system : DOS '+GetDOSVersion));
          Insert(C);

          R.Assign(40,12,71,13);
          C:=New(PStaticText,Init(R,'ADLIB karta : '+GetAdlib));
          Insert(C);
          R.Assign(38,13,71,14);
          C:=New(PStaticText,Init(R,'Sound blaster : '+GetSB));
          Insert(C);
          R.Assign(41,14,71,15);
          C:=New(PStaticText,Init(R,'Novell IPX : '+GetNovell));
          Insert(C);
          R.Assign(46,15,71,16);
          C:=New(PStaticText,Init(R,'CDROM : '+GetCDROM));
          Insert(C);

          R.Assign(32,17,42,19);
          C:=New(PButton,Init(R,'~O~k',cmOk,bfNormal + bfNormal));
          Insert(C);

          SelectNext(False);
       end;

   DataPtr:=Nil;
   SysInfo:=Application^.ExecuteDialog(D,DataPtr);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function Calendar;
var
  R : TRect;
  D : PDialog;
begin
Application^.HelpCtx:=hcToolsCalendar;
  R.Assign(1, 1, 23, 11);
  D:=New(PDialog,Init(R,'Kalendar'));
  D^.Options:=SetBit(D^.Options,ofCentered);
  With D^ Do begin
               GetExtent(R);
               R.Grow(-1, -1);
               Insert(New(PCalendarView, Init(R)));
             end;
  Calendar:=Application^.ExecuteDialog(D,nil);
Application^.HelpCtx:=hcNoContext;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function Calc;
const
  KeyChar: array[0..19] of Char = 'C'#27'%'#241'789/456*123-0.=+';
var
  I : Integer;
  D : PDialog;
  P : PView;
  R : TRect;
begin
Application^.HelpCtx:=hcToolsCalc;
  R.Assign(5, 3, 29, 18);
  D:=New(PDialog,Init(R, 'Kalkulacka'));
  D^.Options :=SetBit(D^.Options,ofFirstClick+ofCentered);
  With D^ Do Begin
               for I := 0 to 19 do
                 begin
                   R.A.X := (I mod 4) * 5 + 2;
                   R.A.Y := (I div 4) * 2 + 4;
                   R.B.X := R.A.X + 5;
                   R.B.Y := R.A.Y + 2;
                   P := New(PButton, Init(R, KeyChar[I], cmCalcButton,
                     bfNormal + bfBroadcast));
                   P^.Options := P^.Options and not ofSelectable;
                   Insert(P);
                 end;
               R.Assign(3, 2, 21, 3);
               Insert(New(PCalcDisplay, Init(R)));
             End;
 Calc:=Application^.ExecuteDialog(D,Nil);
 Application^.HelpCtx:=hcNoContext;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TTeamCollection.FreeItem(Item: Pointer);
Begin
If Item<>Nil Then DisposeStr(Item);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TScrollDialog.HandleEvent;
Var OldTimer : Longint;
    AktualTimer : Longint;
    CloseDialog : Boolean;
    DoEvent : Boolean;
Begin
OldTimer :=GetTimer;
While (Event.What<>evCommand) And ((Event.Command<>cmClose) And (Event.Command<>CmCancel)) Do
  Begin
   AktualTimer := GetTimer;
   If (AktualTimer > (OldTimer + 7)) Then
     With Status^ Do Begin
                       Inc(Position);
                       If (Position>Text^.Count+Size.Y-1) Then Position:=0;
                       Draw;
                       OldTimer :=GetTimer;
                     End;
    GetKeyEvent(Event);
    If Event.What=evNothing Then GetMouseEvent(Event);
    TDialog.HandleEvent(Event);
  End;
TDialog.HandleEvent(Event);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TTeamDialog.HandleEvent;
Var D : PScrollDialog;
    R : Trect;
    Text : PTeamCollection;
Begin
TDialog.HandleEvent(Event);
If (Event.What=evCommand) and (Event.Command=cmThanks)
  Then Begin
         Text := New(PTeamCollection,Init(0,1));
         Text^.Insert(NewStr(#$70));
         Text^.Insert(NewStr(#$74 + 'T©¡dˆ 4.C SP›E Pardubice'));
         Text^.Insert(NewStr(#$74 + 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'));
         Text^.Insert(NewStr(#$70 + 'Balcar Jan'));Text^.Insert(NewStr(#$70 + 'Be‡ k Jakub'));
         Text^.Insert(NewStr(#$70 + 'Dole‘al Ale¨'));Text^.Insert(NewStr(#$70 + 'Hete¨ Petr'));
         Text^.Insert(NewStr(#$70 + 'Hu¨ek Filip'));Text^.Insert(NewStr(#$70 + 'Kaplan Ludˆk'));
         Text^.Insert(NewStr(#$70 + 'Kulh nek Tom ¨'));Text^.Insert(NewStr(#$70 + 'Kop ‡ek Ludˆk'));
         Text^.Insert(NewStr(#$70 + 'Laiver Ale¨'));Text^.Insert(NewStr(#$70 + 'Mach Zdenˆk'));
         Text^.Insert(NewStr(#$70 + 'Marek Martin'));Text^.Insert(NewStr(#$70 + 'Marek Radim'));
         Text^.Insert(NewStr(#$70 + 'Munia Marek'));Text^.Insert(NewStr(#$70 + 'Pavel Luk ›'));
         Text^.Insert(NewStr(#$70 + 'Pilgr Ale¨'));Text^.Insert(NewStr(#$70 + 'S dovsk˜ Michal'));
         Text^.Insert(NewStr(#$70 + 'Sodomka Franti¨ek'));Text^.Insert(NewStr(#$70 + 'Svoboda Luk ¨'));
         Text^.Insert(NewStr(#$70 + 'Lisi‡an Ren‚'));Text^.Insert(NewStr(#$70 + '’ƒ rsk˜ Jakub'));
         Text^.Insert(NewStr(#$70));
         Text^.Insert(NewStr(#$74 + 'U‡itel–m'));
         Text^.Insert(NewStr(#$74 + 'ÄÄÄÄÄÄÄÄ'));
         Text^.Insert(NewStr(#$70 + 'Ing. Zdenˆk ›ilar'));Text^.Insert(NewStr(#$70 + 'p. Milan €ernoch'));
         Text^.Insert(NewStr(#$70 + 'RNDr. Zde¤ka Kle‡kov '));Text^.Insert(NewStr(#$70 + 'Ing. Miroslav €ep‡ ©'));
         Text^.Insert(NewStr(#$70 + 'p. Ivo Jech'));Text^.Insert(NewStr(#$70 + 'Ing. V clav Hrube¨'));
         Text^.Insert(NewStr(#$70 + 'p. Ji©¡ Je‘ek'));Text^.Insert(NewStr(#$70 + 'Ing. Vlastislav Kazda'));
         Text^.Insert(NewStr(#$70 + 'p. Milan ›tver k'));
         Text^.Insert(NewStr(#$70));
         Text^.Insert(NewStr(#$74 + 'Kamar d–m'));
         Text^.Insert(NewStr(#$74 + 'ÄÄÄÄÄÄÄÄÄ'));
         Text^.Insert(NewStr(#$70 + 'Janata Radek & Katka Markov '));
         Text^.Insert(NewStr(#$70 + 'Ors g Rudolf'));Text^.Insert(NewStr(#$70 + '€es k Ji©¡'));
         Text^.Insert(NewStr(#$70 + '›r mek Petr'));Text^.Insert(NewStr(#$70 + 'Jana & Jitka Ruzi‡kov '));
         Text^.Insert(NewStr(#$70 + 'Roman Bˆlonoh˜ & Katka Hu¨kov '));
         Text^.Insert(NewStr(#$70 + 'Tom ¨ Moser'));Text^.Insert(NewStr(#$70 + 'Petr Vojtˆ¨ek'));
         Text^.Insert(NewStr(#$70 + 'Jana Vav©¡‡kov '));Text^.Insert(NewStr(#$70 + 'Ji©ina Rackov '));
         Text^.Insert(NewStr(#$70 + 'Jana Vojtˆ¨kov '));Text^.Insert(NewStr(#$70 + 'Jana Fidrmucov '));
         Text^.Insert(NewStr(#$70 + '›pa‡ek Zdenˆk'));Text^.Insert(NewStr(#$70 + 'Gr‚ta & Martin Novotn˜'));
         Text^.Insert(NewStr(#$70));
         Text^.Insert(NewStr(#$74 + 'Janu Lev¡nsk‚mu  -  Firmˆ ERKO s.r.o'));
         Text^.Insert(NewStr(#$70));
         Text^.Insert(NewStr(#$74 + 'Firmˆ Progrestisk Hradec Kr lov‚'));
         Text^.Insert(NewStr(#$70));
         Text^.Insert(NewStr(#$74 + 'Mˆstsk‚mu Domu Dˆt¡ a Ml de‘e v Hradci Kr lov‚'));
         Text^.Insert(NewStr(#$70));Text^.Insert(NewStr(#$70));
         Text^.Insert(NewStr(#$71 + 'Firma  ş Imagine software dˆkuje'));
         Text^.Insert(NewStr(#$71 + 'v¨em lidem na svˆtˆ'));
         R.Assign(Origin.X,Origin.Y,Origin.X+Size.X,Origin.Y+Size.Y);
         D := New(PScrollDialog,Init(R,'Specialni podekovani'));
         With D^ Do Begin
                     R.Assign(1,1,Size.X-1,Size.Y-1);
                     Status:=New(PTeamStatus,Init(R,Text));
                     Insert(Status);
                    End;
         Application^.ExecView(D);
         Dispose(Text,Done);
       End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ TCalendarView }
constructor TCalendarView.Init(Bounds: TRect);
var
  H: Word;
begin
  inherited Init(Bounds);
  Options := Options or ofSelectable;
  EventMask := EventMask or evMouseAuto;
  GetDate(CurYear, CurMonth, CurDay, H);
  Year := CurYear;
  Month := CurMonth;
  DrawView;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
constructor TCalendarView.Load(var S: TStream);
var
  H: Word;
begin
  inherited Load(S);
  GetDate(CurYear, CurMonth, CurDay, H);
  S.Read(Year, SizeOf(Year));
  S.Read(Month, SizeOf(Month));
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function DayOfWeek(Day, Month, Year: Integer) : Integer;
var
  century, yr, dw: Integer;
begin
  if Month < 3 then
  begin
    Inc(Month, 10);
    Dec(Year);
  end
  else
     Dec(Month, 2);
  century := Year div 100;
  yr := year mod 100;
  dw := (((26 * month - 2) div 10) + day + yr + (yr div 4) +
    (century div 4) - (2 * century)) mod 7;
  if dw < 0 then DayOfWeek := dw + 7
  else DayOfWeek := dw;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TCalendarView.Draw;
const
  Width = 20;
var
  i, j, DayOf, CurDays: Integer;
  S: String;
  B: array[0..Width] of Word;
  Color, BoldColor, SpecialColor: Byte;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function Num2Str(I: Integer): String;
var
  S:String;
begin
  Str(i:2, S);
  Num2Str := S;
end;

begin
  Color:= GetColor(6);
  BoldColor:= GetColor(7);
  DayOf := DayOfWeek(1, Month, Year);
  Days := DaysInMonth[Month] + Byte((Year mod 4 = 0) and (Month = 2));
  Str(Year:4, S);
  MoveChar(B, ' ', Color, Width);
  MoveStr(B, MonthStr[Month] + S+' '#30'  '#31, Color);
  WriteLine(0, 0, Width, 1, B);
  MoveChar(B, ' ', Color, Width);
  MoveStr(B, 'Ne Po Ut St Ct Pa So', Color);
  WriteLine(0, 1, Width, 1, B);
  CurDays := 1 - DayOf;
  for i := 1 to 6 do
  begin
    MoveChar(B, ' ', Color, Width);
    for j := 0 to 6 do
    begin
      if (CurDays < 1) or (CurDays > Days) then
        MoveStr(B[J * 3], '   ', Color)
      else
        { if it is the current day }
        if (Year = CurYear) and (Month = CurMonth) and
          (CurDays = CurDay) then
          MoveStr(B[J * 3], Num2Str(CurDays), BoldColor)
        else
          MoveStr(B[J * 3], Num2Str(CurDays), Color);
      Inc(CurDays);
    end;
    WriteLine(0, i + 1, Width, 1, B);
  end;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TCalendarView.HandleEvent(var Event: TEvent);
var
  Point:TPoint;
  SelectDay: Word;
begin
  inherited HandleEvent(Event);
  if (State and sfSelected <> 0) then
  begin
    if Event.What and (evMouseDown + evMouseAuto) <> 0 then
    begin
      MakeLocal(Event.Where, Point);
      if ((Point.X = 15) and (Point.Y = 0)) then
      begin
        Inc(Month);
        if Month > 12 then
        begin
          Inc(Year);
          Month := 1;
        end;
        DrawView;
      end;
      if ((Point.X = 18) and (Point.Y = 0)) then
      begin
        Dec(Month);
        if Month < 1 then
        begin
          Dec(Year);
          Month := 12;
        end;
        DrawView;
      end;
    end
    else if Event.What = evKeyDown then
    begin
      if (Lo(Event.KeyCode) = byte('+')) or (Event.KeyCode = kbDown) then
      begin
        Inc(Month);
        if Month > 12 then
        begin
          Inc(Year);
          Month := 1;
        end;
      end;
      if (Lo(Event.KeyCode) = Byte('-')) or (Event.KeyCode = kbUp) then
      begin
        Dec(Month);
        if Month < 1 then
        begin
          Dec(Year);
          Month := 12;
        end;
      end;
      DrawView;
    end;
  end;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TCalendarView.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(Year, SizeOf(Year));
  S.Write(Month, SizeOf(Month));
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure RegisterCalendar;
begin
  RegisterType(RCalendarView);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
constructor TCalcDisplay.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  Options := Options or ofSelectable;
  EventMask := evKeyDown + evBroadcast;
  Clear;
end;

constructor TCalcDisplay.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(Status, SizeOf(Status) + SizeOf(Number) + SizeOf(Sign) +
    SizeOf(Operator) + SizeOf(Operand));
end;

procedure TCalcDisplay.CalcKey(Key: Char);
var
  R: Real;

procedure Error;
begin
  Status := csError;
  Number := 'Error';
  Sign := ' ';
end;

procedure SetDisplay(R: Real);
var
  S: string[63];
begin
  Str(R: 0: 10, S);
  if S[1] <> '-' then Sign := ' ' else
  begin
    Delete(S, 1, 1);
    Sign := '-';
  end;
  if Length(S) > 15 + 1 + 10 then Error
  else
  begin
    while S[Length(S)] = '0' do Dec(S[0]);
    if S[Length(S)] = '.' then Dec(S[0]);
    Number := S;
  end;
end;

procedure GetDisplay(var R: Real);
var
  E: Integer;
begin
  Val(Sign + Number, R, E);
end;

procedure CheckFirst;
begin
  if Status = csFirst then
  begin
    Status := csValid;
    Number := '0';
    Sign := ' ';
  end;
end;

begin
  Key := UpCase(Key);
  if (Status = csError) and (Key <> 'C') then Key := ' ';
  case Key of
    '0'..'9':
      begin
        CheckFirst;
        if Number = '0' then Number := '';
        Number := Number + Key;
      end;
    '.':
      begin
        CheckFirst;
        if Pos('.', Number) = 0 then Number := Number + '.';
      end;
    #8, #27:
      begin
        CheckFirst;
        if Length(Number) = 1 then Number := '0' else Dec(Number[0]);
      end;
    '_', #241:
      if Sign = ' ' then Sign := '-' else Sign := ' ';
    '+', '-', '*', '/', '=', '%', #13:
      begin
        if Status = csValid then
        begin
          Status := csFirst;
          GetDisplay(R);
          if Key = '%' then
            case Operator of
              '+', '-': R := Operand * R / 100;
              '*', '/': R := R / 100;
            end;
          case Operator of
            '+': SetDisplay(Operand + R);
            '-': SetDisplay(Operand - R);
            '*': SetDisplay(Operand * R);
            '/': if R = 0 then Error else SetDisplay(Operand / R);
          end;
        end;
        Operator := Key;
        GetDisplay(Operand);
      end;
    'C':
      Clear;
  end;
  DrawView;
end;

procedure TCalcDisplay.Clear;
begin
  Status := csFirst;
  Number := '0';
  Sign := ' ';
  Operator := '=';
end;

procedure TCalcDisplay.Draw;
var
  Color: Byte;
  I: Integer;
  B: TDrawBuffer;
begin
  Color := GetColor(1);
  I := Size.X - Length(Number) - 2;
  MoveChar(B, ' ', Color, Size.X);
  MoveChar(B[I], Sign, Color, 1);
  MoveStr(B[I + 1], Number, Color);
  WriteBuf(0, 0, Size.X, 1, B);
end;

function TCalcDisplay.GetPalette: PPalette;
const
  P: string[1] = #19;
begin
  GetPalette := @P;
end;

procedure TCalcDisplay.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  case Event.What of
    evKeyDown:
      begin
        CalcKey(Event.CharCode);
        ClearEvent(Event);
      end;
    evBroadcast:
      if Event.Command = cmCalcButton then
      begin
        CalcKey(PButton(Event.InfoPtr)^.Title^[1]);
        ClearEvent(Event);
      end;
  end;
end;

procedure TCalcDisplay.Store(var S: TStream);
begin
  TView.Store(S);
  S.Write(Status, SizeOf(Status) + SizeOf(Number) + SizeOf(Sign) +
    SizeOf(Operator) + SizeOf(Operand));
end;

{ TCalculator }

procedure RegisterCalc;
begin
  RegisterType(RCalcDisplay);
end;

procedure TTable.Draw;
var
  Buf   : TDrawBuffer;
  X, Y  : Integer;
  Color,Color2 : Byte;
  I     : Byte;
begin
  I:=0;
  Color := GetColor(6);
  Color2 := GetColor(5);
  for Y := 0 to Size.Y - 1 do
  begin
    MoveChar(Buf, ' ', Color, Size.X);
    For X:=1 To Size.X Do
       If ((X+1) Mod 2) = 0 Then
         Begin
           If X<Size.X Then Begin
                              If I = Index Then
                                Begin
                                  MoveChar(Buf[x-1], #32,Color2, 1);
                                  MoveChar(Buf[x], Chr(I),Color2, 1);
                                  MoveChar(Buf[x+1], #32,Color2, 1);
                                End
                                Else MoveChar(Buf[x], Chr(I),Color, 1);
                              Inc(I);
                            End;
         End;
     WriteLine(0, y, Size.X, 1, Buf);
  end;
end;

procedure TTable.GetData;
Begin
 Move(Index,Rec,1);
End;

procedure TTable.SetData;
Begin
 Move(Rec,Index,1);
End;

procedure TTable.HandleEvent(var Event:TEvent);
var
  CurrentSpot: TPoint;

procedure CharFocused;
begin
  Draw;
  Message(Owner, evBroadcast, AsciiTableCommandBase + cmCharacterFocused,
  Pointer(Index));
end;

begin
  inherited HandleEvent(Event);
  if Event.What = evMouseDown then
  begin
    repeat
      if MouseInView(Event.Where) then
      begin
        MakeLocal(Event.Where, CurrentSpot);
        Index := (CurrentSpot.Y * (Size.X Div 2)) + ((CurrentSpot.X-1) Div 2);
        CharFocused;
      end;
    until not MouseEvent(Event, evMouseMove);
    ClearEvent(Event);
  end
  else if Event.What = evKeyDown then
    Begin
      case Event.KeyCode of
        kbHome : Index := 0;
        kbEnd  : Index := 255;
        kbUp   : Dec(Index,(Size.X) Div 2);
        kbDown : Inc(Index,(Size.X) Div 2);
        kbLeft : Dec(Index);
        kbRight: Inc(Index);
        KbEnter: Message(Owner,evCommand,cmOK,nil);
        Else Exit;
      end;
      CharFocused;
      ClearEvent(Event);
    End;
end;

{ TReport }


procedure TReport.Draw;
var
  Buf: TDrawBuffer;
begin
  MoveChar(Buf,#32,$0F,Size.X);
  MoveStr(Buf[1],FillToFront(IntToStr(ASCIIChar),3,#32),$0F);
  MoveStr(Buf[5],'Dek ³',$07);
  MoveStr(Buf[11],FillToFront(DecToHex(ASCIIChar),2,'0'),$0F);
  MoveStr(Buf[14],'Hex ³',$07);
  MoveStr(Buf[20],FillToFront(DecToBin(ASCIIChar),8,'0'),$0F);
  MoveStr(Buf[29],'Bin',$07);

  WriteBuf(0,0,Size.X,1,Buf);
end;

procedure TReport.HandleEvent(var Event: TEvent);
var
  Table: PTable;
begin
  inherited HandleEvent(Event);
  if Event.What = evBroadcast then
    if Event.Command = AsciiTableCommandBase + cmCharacterFocused then
    begin
      ASCIIChar := Event.InfoLong;
      DrawView;
    end;
end;


Function ASCIITable:Word;
var
  R: TRect;
  Control: PVIew;
  D : PDialog;
  Event : TEvent;
  S     : Word;
  Ch    : Char;
begin
  R.Assign(0, 0, 35, 19);
  D:=New(PDialog,Init(R, 'ASCII tabulka'));
  D^.Options:=SetBit(D^.Options,ofCentered);
  With D^ Do Begin
               R.Grow(-1,-1);
               R.B.Y := R.A.Y + 1;
               Control := New(PReport, Init(R));
               with Control^ do
                 begin
                   EventMask := EventMask or evBroadcast;
                 end;
               Insert(Control);

               GetExtent(R);
               R.Grow(-1,-1);
               R.A.Y := R.A.Y + 1;
               R.A.X := 1;
               Control := New(PTable, Init(R));
                with Control^ do
                 begin
                   Options := Options or ofSelectable;
                 end;
               Insert(Control);
               Control^.Select;
             End;
  Ch := #0;
  D^.SetData(Ch);
  If Application^.ExecView(D)<> CmOk Then Exit;
  D^.GetData(Ch);
  Dispose(D,Done);
  If Ch>#31 Then Begin
                  Event.What := evKeyDown;Event.CharCode:=Ch;
                  Application^.PutEvent(Event);
                 End;
end;

function TDriversListViewer.GetText;
Var Driver : PHead;
    S      : String;
    I      : Byte;
    Name   : String[8];
Begin
  Driver:=Drvs^.At(Item);S:='';Name:='';
  S:=FillToFront(DecToHex(LongInt(Seg(Driver^)) shl 4+Ofs(Driver^)),6,'0');
  S:=S + '  ';
  If (Driver^.DevAttr And BlockDriver) <> BlockDriver Then
     Name:='A: -> ' + Chr($41+Ord(Driver^.Name[1])) + ':'
       Else For I:=1 To 8 Do Name:=Name+Driver^.Name[I];
  S:=S + Name;
  S:=S + '  ' + FillToLength(DecToHex(Driver^.DevAttr),4,'0');
  S:=S + '  ' + FillToLength(DecToHex(Driver^.Strategy),4,'0');
  S:=S + '  ' + FillToLength(DecToHex(Driver^.Interupt),4,'0');
  GetText:=S;
End;

Function DriversList;
Var D : PDialog;
    R : TRect;
    P : PDriversListViewer;
    V : PView;
    Reg : Registers;
    Head : PHead;
Begin
  Drvs:=New(PCollection,Init(0,1));
  Reg.Ah:=$52;
  Msdos(Reg);
  Head:=Ptr(Reg.es,Reg.bx+$22);
  While Ofs(Head^.Next^)<>$FFFF Do
    Begin Drvs^.Insert(Head);Head:=Head^.Next;End;
  R.Assign(0,0,38,20);
  D:=New(PDialog,Init(R,'Ovladace zarizeni'));
  D^.Options:=SetBit(D^.Options,ofCentered);
  With D^ Do Begin
               R.Assign(1,1,Size.X-1,2);
               V:=New(PstaticText,Init(R,' Adresa  Jmeno     Attr  Stra  Int'));
               Insert(V);

               R.Assign(1,2,Size.X-1,Size.Y-1);
               P:=New(PDriversListViewer,Init(R,1,nil,nil));
               P^.Range:=Drvs^.Count;
               Insert(P);
             End;
  DriversList:=Application^.ExecuteDialog(D,Nil);
  Dispose(Drvs);
End;

End.