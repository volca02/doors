{$M 16384,0,655360}
UNIT FINDER;
Interface
Uses Objects, Dos, Crt, App,Views,dIALOGS;
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

Var Files:PData2;
    Direct:PData;
    SwapData:PSearchData;
    Procedure Search2(Dir,Mask:String);
    Procedure Search(Dir,Mask:String);
Implementation
Uses Base;
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

(*Var S:PString;
I:Integer;
OldMem:Longint;
Dir:PString;
Begin
Clrscr;
Files:=New(PData2,Init(0,1));
Direct:=New(PData,Init(0,1));
Files^.Duplicates:=True;
OldMem:=MemAvail;
Search('C:\work\','*.exe');
Writeln('Zabrano pameti :',OldMem-MemAvail);
Writeln('Nalezeno souboru :',Files^.Count);
Readln;
For I:=0 To Files^.Count-1 Do
  Begin
    SwapData:=Files^.At(I);
    Dir:=Direct^.At(SwapData^.Index);
    S:=SwapData^.Name;
    Writeln(Dir^+S^);
    If (I mod 23)=0 Then Begin Writeln('[MORE]');Readkey;End;
  End;
Readln;
Files^.FreeAll;
Dispose(Files,Done);
Direct^.FreeAll;
Dispose(Direct,Done);*)
End.
