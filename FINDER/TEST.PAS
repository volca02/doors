Unit FileFind;
INTERFACE
Uses Views, Dialogs, Objects, Supply, App, Drivers, Finder;
const
  ADVFINDCommandOrigin                    =   200;
  cmAdvanced                              =   100;
type
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
               Data2                :  string[255];
               Data3                :  string[255];
               Data4                :  string[255];
               Data5                :  Word;
           end;
Var X:TadvFindData;
    X1:TFindData;
IMPLEMENTATION
Function TNewListBox.GetText;
Var X : PSearchData;
    Dir : PString;
Begin
X:=Files^.At(Item);Dir:=Direct^.At(X^.Index);
GetText:=Dir^+ X^.Name^;
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
  _DataPtr : PFINDData;
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
          H:=New(PHistory,Init(R,PInputLine(C),1));
          Insert(H);

          R.Assign(4,5,36,6);
          C:=New(PInputLine,Init(R,255));
          Insert(C);
          R.Assign(3,4,17,5);
          L:=New(PLabel,Init(R,'Hledan˜ text',C));
          Insert(L);
          R.Assign(36,5,39,6);
          H:=New(PHistory,Init(R,PInputLine(C),2));
          Insert(H);

          R.Assign(4,8,36,9);
          C:=New(PInputLine,Init(R,255));
          Insert(C);
          R.Assign(3,7,33,8);
          L:=New(PLabel,Init(R,'Hledan˜ text (hexadecim lnˆ)',C));
          Insert(L);
          R.Assign(36,8,39,9);
          H:=New(PHistory,Init(R,PInputLine(C),3));
          Insert(H);

          R.Assign(4,11,36,12);
          C:=New(PInputLine,Init(R,255));
          Insert(C);
          R.Assign(3,10,12,11);
          L:=New(PLabel,Init(R,'Adres ©',C));
          Insert(L);
          R.Assign(36,11,39,12);
          H:=New(PHistory,Init(R,PInputLine(C),4));
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

   _DataPtr:=@_Data;
   if not _SetData then FillChar(_Data,SizeOf(_Data),0);
   FIND:=Application^.ExecuteDialog(D,_DataPtr);
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
  D    : PDialog;
  C    : PNewListBox;
  SB   : PScrollBar;
  R    : TRect;
begin
  R.Assign(0,0,80,23);
  D:=New(PDialog,Init(R,'Seznam Souboru'));
  with D^ do
       begin
          R.Assign(78,1,79,22);
          SB:=New(PScrollBar,Init(R));
          Insert(SB);
          R.Assign(1,1,78,22);
          C:=New(PNewListBox,Init(R,1,SB));
          Insert(C);
          SelectNext(False);
       end;
   C^.SetRange(Files^.Count);
   SEZNAM:=Application^.ExecuteDialog(D,Nil);
end;

Procedure RunFindDialog;
VAr BAck:Word;
Begin
FillChar(X,SizeOf(X),0);FillChar(X1,SizeOf(X1),0);
Back:=Find(X1,True);
If Back=CmOk Then
Begin
Files:=New(PData2,Init(0,1));
Direct:=New(PData,Init(0,1));
Files^.Duplicates:=True;
Search2(X1.Data4,X1.Data1);
If Files^.Count>0 Then Seznam;
Files^.FreeAll;
Dispose(Files,Done);
Direct^.FreeAll;
Dispose(Direct,Done);
End;
End;
End.