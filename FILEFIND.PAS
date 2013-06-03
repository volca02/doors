{$F+,O+}
Unit FileFind;
INTERFACE
Uses Views, Objects, Drivers, Dialogs;
Type

     PSearchRec = ^TSearchRec;
     TSearchRec = Record
                   Name  : PString;
                   Time  : Longint;
                   Size  : Longint;
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
               Attr                 :  Word;
           end;

    PFindData = ^TFindData;
    TFindData = record
               Mask                 :  string[255];
               TextData             :  string[255];
               Data4                :  string[255];
               Typ                  :  Word;
           end;

Var AdvFindData : TAdvFindData;
    FindData    : TFindData;
    Files       : PData2;
    Direct      : PData;
    SwapData    : PSearchRec;
    Procedure Search(Dir,Mask:String);
    Procedure FindFile;

IMPLEMENTATION
Uses Base, Dos, App, Supply, Variable, NewViews, MessBox;
VAR
  D    : PDialog;
  C    : PStaticText;
  Path : PStaticText;
  R    : TRect;
  DI   : PInfoDialog;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TData.FreeItem;
Begin
  If Item<>Nil Then DisposeStr(PString(Item));;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TData2.FreeItem;
Begin
 If Item=Nil Then Exit;
 If PSearchRec(Item)^.Name <> Nil Then DisposeStr(PSearchRec(Item)^.Name);
 Dispose(PSearchRec(Item));
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function TData2.Compare;
Var Data1,Data2 : PSearchRec;
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
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure Search;
var
  S        : PString;
  D        : SearchRec;
  Index, I : Word;
begin
  If Di = Nil Then Di := InfoBox('Vyhledavani souboru',Dir);
  If MemAvail<5000 Then Exit;
  S := NewStr(Dir);
  Direct^.Insert(S);Index:=Direct^.Count-1;
  If (FindData.Typ And $2)<>$2 Then
    Begin
      FindFirst(Dir + '*.*', Directory, D);
      while DosError = 0 do
        begin
          If (D.Name<>'..') And (D.Name<>'.') And
          ((D.Attr And Directory)=Directory) Then Search(Dir+D.Name+'\',Mask);
          FindNext(D);
        End;
     End;
   FindFirst(Dir + Mask, Anyfile, D);
      while DosError = 0 do
        Begin
         If ((D.Attr And Directory)<>Directory) Then
          Begin
            New(SwapData);
            SwapData^.Name := NewStr(D.Name);
            SwapData^.Index:=Index;
            SwapData^.Size:=D.Size;
            SwapData^.Time:=D.Time;
            Files^.Insert(SwapData);
          End;
     FindNext(D);
    End;
Di^.Update(Dir);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function TNewListBox.GetText;
Var X : PSearchRec;
    Dir : PString;
    S   : String;
Begin
 GetText := '';
 X:=Files^.At(Item);Dir:=Direct^.At(X^.Index);
 S:=FillToLength(TruncString('..',Dir^,39),41,' ');
 S:= S + KanonizeFile(X^.Name^,0) + '  ';
 S:= S + IntToStr(X^.Size);
 GetText:=S;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function AdvancetSearch: Word;
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

          R.Assign(5,9,41,11);
          C:=New(PCheckBoxes,Init(R,
               NewSItem('Skryt‚',
               NewSItem('Syst‚mov‚',
               NewSItem('Pouze pro ‡ten¡',
               NewSItem('Archivn¡',
               nil))))));
          Insert(C);

          R.Assign(11,12,21,14);
          C:=New(PButton,Init(R,'~O~k',cmOk,bfNormal));
          Insert(C);

          R.Assign(24,12,34,14);
          C:=New(PButton,Init(R,'~Z~ru¨it',cmCancel,bfNormal));
          Insert(C);

          SelectNext(False);
       end;

   D^.SetData(AdvFindData);
   AdvancetSearch:=Application^.ExecView(D);
   D^.GetData(AdvFindData);
   Dispose(D,Done);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function CreateFindDialog  : Word;
var
  D    : PFindDialog;
  C    : PView;
  L    : PLabel;
  H    : PHistory;
  R    : TRect;
  Text,Text2 : PInputLine;
  DataPtr : PFindData;
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

         { R.Assign(4,8,36,9);
          Text2:=New(PHexInputLine,Init(R,255,Text));
          Insert(Text2);
          R.Assign(3,7,33,8);
          L:=New(PLabel,Init(R,'Hledan˜ text (hexadecim lnˆ)',Text2));
          Insert(L);
          R.Assign(36,8,39,9);
          H:=New(PHistory,Init(R,PInputLine(Text2),HiSearchTextHex));
          Insert(H);}

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
               NewSItem('Rozli¨ovat velk  a mal  p¡smena',
               NewSItem('Pouze aktualn¡ adres ©',
               nil))));
          Insert(C);

          R.Assign(3,16,16,18);
          C:=New(PButton,Init(R,'Roz¨¡©en‚',cmAdvanced,bfNormal));
          Insert(C);

          R.Assign(19,16,29,18);
          C:=New(PButton,Init(R,'~O~k',cmOk,bfDefault));
          Insert(C);

          R.Assign(31,16,41,18);
          C:=New(PButton,Init(R,'~Z~ru¨it',cmCancel,bfNormal));
          Insert(C);

          SelectNext(False);
       end;

   D^.SetData(FindData);
   CreateFindDialog:=Application^.Execview(D);
   D^.GetData(FindData);
   Dispose(D,Done);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TFindDialog.HandleEvent;
Var Swap:TAdvFindData;
Begin
TDialog.HandleEvent(Event);Swap:=AdvFindData;
If Event.What = EvCommand Then
Case Event.Command Of
 CmAdvanced : If AdvancetSearch=CmOK Then AdvFindData:=Swap;
 End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
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
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure FindFile;
Var Confirm : Word;
Begin
 FillChar(AdvFindData,SizeOf(AdvFindData),0);FillChar(FindData,SizeOf(FindData),0);
 GetDir(0,FindData.Data4);
 If FindData.Data4[Length(FindData.Data4)]<>'\' Then
    FindData.Data4 := FindData.Data4 +'\';
 FindData.Mask := '*.*';
 Confirm:=CreateFindDialog;
 If Confirm=CmOk Then
  Begin
    Files:=New(PData2,Init(0,1));
    Direct:=New(PData,Init(0,1));
    Files^.Duplicates:=True;Di:=Nil;
    Search(UpString(FindData.Data4),UpString(FindData.Mask));
    If Files^.Count>0 Then Seznam
     Else MessageBox('Nenalezeny zadne soubory',Nil,MfError + mfOkButton);
    Dispose(Files,Done);
    Dispose(Direct,Done);
  End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
End.