{$F+,O+}
Unit FileFind;
INTERFACE
Uses Views, Objects, Drivers, Dialogs;
Type

     PSearchData = ^TSearchData;
     TSearchData = Record
                   Name : PString;
                   Attr: Byte;
                   Time: Longint;
                   Size: Longint;
                   Index : Word;
                  End;

     PData = ^TData;
     TData = Object(TCollection)
              Procedure FreeItem(Item: Pointer); virtual;
             End;
     PData2 = ^TData2;
     TData2 = Object(TSortedCollection)
              function Compare(Key1, Key2: Pointer): Integer; virtual;
              Procedure FreeItem(Item: Pointer); virtual;
             End;

   PFindDialog = ^TFindDialog;
   TFindDialog = Object(TDialog)
                  procedure HandleEvent(var Event: TEvent); virtual;
                 End;
   PNewListBox = ^TNewListBox;
   TNewListBox = Object(TListBox)
                  function GetText(Item: Integer; MaxLen: Integer): String; virtual;
                 End;

   PADVFINDData = ^TADVFINDData;
   TADVFINDData = record
               Data1                :  string[255];
               Data2                :  string[255];
               Data3                :  string[255];
               Data4                :  string[255];
               Data5                :  Word;
               Data6                :  Word;
           end;

    PFINDData = ^TFINDData;
    TFINDData = record
               Data1                :  string[255];
               TextData             :  string[255];
               Data4                :  string[255];
               Data5                :  Word;
           end;

Var X:TadvFindData;
    X1:TFindData;
    Files:PData2;
    Direct:PData;
    SwapData:PSearchData;
    Procedure Search2(Dir,Mask:String);
    Procedure Search(Dir,Mask:String);
    Procedure FindFile(Dir : String);

IMPLEMENTATION
Uses Base, Dos, App, Supply, Variable, NewViews;
VAR
  D    : PDialog;
  C    : PStaticText;
  Path : PStaticText;
  R    : TRect;

Procedure TData.FreeItem;
Var S:PString;
Begin
S:=Item;
If S<>Nil Then FreeMem(S,Length(S^)+1);
End;

function TData2.Compare;
Var Data1,Data2:PSearchData;
Begin
Compare:=0;
Data1:=Key1;Data2:=Key2;
If Data1^.Index>Data2^.Index Then Compare:=1
  Else If Data1^.Index<Data2^.Index Then Compare:=-1
   Else
Begin
If Data1^.Name^>Data2^.Name^ Then Compare:=1
  Else If Data1^.Name^<Data2^.Name^ Then Compare:=-1
End;

End;

Procedure TData2.FreeItem;
Var Data:PSearchData;
Begin
Data:=Item;
If (Data<>Nil) Then Begin
                     If Data^.Name<>Nil Then
                                   FreeMem(Data^.Name,Length(Data^.Name^)+1);
                     Dispose(Data);
                    End;
End;

Procedure Search2;
Begin
  R.Assign(0,0,60,5);
  D:=New(PDialog,Init(R,''));
  D^.Options:=SetBit(D^.Options,ofCentered);
  with D^ do
       begin
          R.Assign(1,2,Size.X,3);
          Path:=New(PStaticText,Init(R,''));
          Insert(Path);
          R.Assign(1,3,Size.X,4);
          C:=New(PStaticText,Init(R,'0'));
          Insert(C);
          SelectNext(False);
       end;
  Application^.InsertWindow(D);
  Search(Dir,Mask);
D^.Close;
End;

Procedure ChangeDialog(P:String;Num:Word);
Begin
D^.Close;
  R.Assign(0,0,Length(P)+7,5);
  D:=New(PDialog,Init(R,''));
  D^.Options:=SetBit(D^.Options,ofCentered);
  D^.Flags:=ClearBit(D^.Flags,wfClose);
  D^.Options:=ClearBit(D^.Options,ofFramed);
  with D^ do
       begin
          R.Assign(4,2,Size.X-1,3);
          Path:=New(PStaticText,Init(R,P));
          Insert(Path);
          {R.Assign(1,3,Size.X,4);
          C:=New(PStaticText,Init(R,IntToStr(Num)));
          Insert(C);}
          SelectNext(False);
       end;
  Application^.InsertWindow(D);
End;

Procedure Search;
var
  S : PString;
  DI: SearchRec;
  Index,I : Word;
begin
  Getmem(S,Length(Dir)+1);
  S^:=Dir;
  Direct^.Insert(S);Index:=Direct^.Count-1;
  FindFirst(Dir + '*.*', Directory, DI);
  while DosError = 0 do
  begin
    If (DI.Name<>'..') And (DI.Name<>'.') And
    ((DI.Attr And Directory)=Directory) Then Search(Dir+DI.Name+'\',Mask);
   FindNext(DI);
  End;
  FindFirst(Dir + Mask, Anyfile, DI);
  while DosError = 0 do
    Begin
     If ((DI.Attr And Directory)<>Directory) Then
       Begin
         New(SwapData);
         Getmem(SwapData^.Name,Length(DI.Name)+1);
         SwapData^.Name^:=DI.Name;
         SwapData^.Index:=Index;
         SwapData^.Size:=DI.Size;
         SwapData^.Time:=DI.Time;
         SwapData^.Attr:=DI.Attr;
         Files^.Insert(SwapData);
       End;
     FindNext(DI);
    End;
ChangeDialog(Dir,Files^.COunt);
End;

Function TNewListBox.GetText;
Var X : PSearchData;
    Dir : PString;
    S   : String;
Begin
X:=Files^.At(Item);Dir:=Direct^.At(X^.Index);
S:=FillToLength(TruncString('..',Dir^,39),41,' ');
S:= S + KanonizeFile(X^.Name^,X^.Attr) + '  ';
S:= S + IntToStr(X^.Size);
GetText:=S;
End;

function ADVFIND(var _Data : TADVFINDData; _SetData : Boolean): Word;
var
  D    : PDialog;
  C    : PView;
  L    : PLabel;
  R    : TRect;
  _DataPtr : PADVFINDData;
begin
  R.Assign(17,4,63,19);
  D:=New(PDialog,Init(R,'Roz¨¡©en‚'));
  with D^ do
       begin
          R.Assign(5,9,41,11);
          C:=New(PFramedView,Init(R));
          Insert(C);

          R.Assign(26,2,38,3);
          C:=New(PInputLine,Init(R,255));
          Insert(C);
          R.Assign(6,2,26,3);
          L:=New(PLabel,Init(R,'Soubory mlad¨¡ ne‘',C));
          Insert(L);

          R.Assign(26,3,38,4);
          C:=New(PInputLine,Init(R,255));
          Insert(C);
          R.Assign(6,3,26,4);
          L:=New(PLabel,Init(R,'Soubory star¨¡ ne‘',C));
          Insert(L);

          R.Assign(26,5,38,6);
          C:=New(PInputLine,Init(R,255));
          Insert(C);
          R.Assign(7,5,26,6);
          L:=New(PLabel,Init(R,'Soubory men¨¡ ne‘',C));
          Insert(L);

          R.Assign(26,6,38,7);
          C:=New(PInputLine,Init(R,255));
          Insert(C);
          R.Assign(7,6,26,7);
          L:=New(PLabel,Init(R,'Soubory vˆt¨¡ ne‘',C));
          Insert(L);

          R.Assign(13,8,33,9);
          C:=New(PStaticText,Init(R,' Soubory z atributy '));
          Insert(C);

          R.Assign(5,9,20,11);
          C:=New(PCheckBoxes,Init(R,
               NewSItem('Skryt‚',
               NewSItem('Syst‚mov‚',
               nil))));
          Insert(C);

          R.Assign(20,9,41,11);
          C:=New(PCheckBoxes,Init(R,
               NewSItem('Pouze pro ‡ten¡',
               NewSItem('Archivn¡',
               nil))));
          Insert(C);

          R.Assign(11,12,21,14);
          C:=New(PButton,Init(R,'~O~k',cmOk,bfNormal));
          Insert(C);

          R.Assign(24,12,34,14);
          C:=New(PButton,Init(R,'~Z~ru¨it',cmCancel,bfNormal));
          Insert(C);

          SelectNext(False);
       end;

   _DataPtr:=@_Data;
   if not _SetData then FillChar(_Data,SizeOf(_Data),0);
   ADVFIND:=Application^.ExecuteDialog(D,_DataPtr);
end;

function FIND(var _Data : TFINDData; _SetData : Boolean): Word;
var
  D    : PFindDialog;
  C    : PView;
  L    : PLabel;
  H    : PHistory;
  R    : TRect;
  Text,Text2 : PInputLine;
  DataPtr : PFINDData;
  S    : String;
begin
  R.Assign(18,3,62,22);
  D:=New(PFindDialog,Init(R,'Hled n¡'));
  with D^ do
       begin
          R.Assign(4,2,36,3);
          C:=New(PInputLine,Init(R,255));
          Insert(C);
          R.Assign(3,1,10,2);
          L:=New(PLabel,Init(R,'Maska',C));
          Insert(L);

          R.Assign(36,2,39,3);
          H:=New(PHistory,Init(R,PInputLine(C),HiSearchMask));
          Insert(H);

          R.Assign(4,5,36,6);
          Text:=New(PInputLine,Init(R,255));
          Insert(Text);
          R.Assign(3,4,17,5);
          L:=New(PLabel,Init(R,'Hledan˜ text',Text));
          Insert(L);
          R.Assign(36,5,39,6);
          H:=New(PHistory,Init(R,PInputLine(Text),HiSearchText));
          Insert(H);

          R.Assign(4,8,36,9);
          Text2:=New(PHexInputLine,Init(R,255,Text));
          Insert(Text2);
          R.Assign(3,7,33,8);
          L:=New(PLabel,Init(R,'Hledan˜ text (hexadecim lnˆ)',Text2));
          Insert(L);
          R.Assign(36,8,39,9);
          H:=New(PHistory,Init(R,PInputLine(Text2),HiSearchTextHex));
          Insert(H);

          R.Assign(4,11,36,12);
          C:=New(PInputLine,Init(R,255));
          Insert(C);
          R.Assign(3,10,12,11);
          L:=New(PLabel,Init(R,'Adres ©',C));
          Insert(L);
          R.Assign(36,11,39,12);
          H:=New(PHistory,Init(R,PInputLine(C),HiSearchDirectory));
          Insert(H);

          R.Assign(3,13,40,15);
          C:=New(PCheckBoxes,Init(R,
               NewSItem('Rozli¨ovat velk  a mal  p¡smen',
               NewSItem('Pouze aktualn¡ adres ©',
               nil))));
          Insert(C);

          R.Assign(3,16,16,18);
          C:=New(PButton,Init(R,'Roz¨¡©en‚',cmAdvanced,bfNormal));
          Insert(C);

          R.Assign(19,16,29,18);
          C:=New(PButton,Init(R,'~H~ledej',cmOk,bfNormal));
          Insert(C);

          R.Assign(31,16,41,18);
          C:=New(PButton,Init(R,'~Z~ru¨it',cmCancel,bfNormal));
          Insert(C);

          SelectNext(False);
       end;

   DataPtr:=@_Data;
   if not _SetData then FillChar(_Data,SizeOf(_Data),0);
   FIND:=Application^.Execview(D);
   Dispose(D,Done);
end;

procedure TFindDialog.HandleEvent;
Var Swap:TAdvFindData;
Begin
TDialog.HandleEvent(Event);Swap:=X;
If Event.What = EvCommand Then
Case Event.Command Of
 CmAdvanced : If AdvFind(Swap,True)=CmOK Then X:=Swap;
 End;
End;

function Seznam:Word;
var
  P    : Pview;
  D    : PDialog;
  C    : PNewListBox;
  SB   : PScrollBar;
  R    : TRect;
begin
  R.Assign(0,0,Application^.Size.X,Application^.Size.Y-1);
  D:=New(PDialog,Init(R,'Seznam Souboru'));
  D^.Options:=SetBit(D^.Options,ofPreProcess);
  D^.State:=ClearBit(D^.State,sfShadow);
  Application^.DisableCommands([CmNs]);
  with D^ do
       begin
          R.Assign(1,1,Size.X-1,2);
          P:=New(PStaticText,Init(R,
' Adresar                                  Jmeno    Ext  Velikost'));
          Insert(P);
          R.Assign(Size.X-2,2,Size.X-1,Size.Y-1);
          SB:=New(PScrollBar,Init(R));
          Insert(SB);
          R.Assign(1,2,Size.X-2,Size.Y-1);
          C:=New(PNewListBox,Init(R,1,SB));
          Insert(C);
          SelectNext(False);
       end;
   C^.SetRange(Files^.Count);
   Application^.ExecView(D);
   Application^.EnableCommands([CmNs]);
end;

Procedure FindFile;
VAr BAck:Word;
    OldStatus : Pointer;
Begin
OldStatus := StatusLine;
StatusLine := Nil;
Application^.DrawView;
FillChar(X,SizeOf(X),0);FillChar(X1,SizeOf(X1),0);
X1.Data4:= Dir;
Back:=Find(X1,True);
If Back=CmOk Then
Begin
Files:=New(PData2,Init(0,1));
Direct:=New(PData,Init(0,1));
Files^.Duplicates:=True;
Search2(UpString(X1.Data4),UpString(X1.Data1));
If Files^.Count>0 Then
Begin
Seznam;
End;
Files^.FreeAll;
Dispose(Files,Done);
Direct^.FreeAll;
Dispose(Direct,Done);
StatusLine := OldStatus;
End;
End;
End.