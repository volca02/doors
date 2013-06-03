Uses App,Objects,Dialogs,Views;
Var Ap:TApplication;
    Data:PCollection;
type
   PNListBOx = ^TNListBOx;
   tNListBox = OBJEct(TListBox)
               function GetText(Item: Integer; MaxLen: Integer): String; virtual;
               eND;
   PDRIVERData = ^TDRIVERData;
   TDRIVERData = record
               Data1                :  PCollection;
               Data2                :  integer;
           end;

Procedure LoadDrivers;
Begin
End;
function TNListBOx.GetText;
Begin
End;
function DRIVER(var _Data : TDRIVERData; _SetData : Boolean): Word;
var
  D    : PDialog;
  C    : PView;
  SB   : PScrollBar;
  R    : TRect;
  _DataPtr : PDRIVERData;
begin
  R.Assign(23,0,54,22);
  D:=New(PDialog,Init(R,'Ovladace'));
  with D^ do
       begin
          R.Assign(29,2,30,18);
          SB:=New(PScrollBar,Init(R));
          Insert(SB);
          R.Assign(1,2,29,18);
          C:=New(PListBox,Init(R,1,SB));
          Insert(C);

          R.Assign(2,1,16,2);
          C:=New(PStaticText,Init(R,'Adresa   Nazev'));
          Insert(C);

          R.Assign(10,19,20,21);
          C:=New(PButton,Init(R,'~O~k',cmOk,bfNormal));
          Insert(C);

          SelectNext(False);
       end;

   _DataPtr:=@_Data;
   if not _SetData then FillChar(_Data,SizeOf(_Data),0);
   DRIVER:=Application^.ExecuteDialog(D,_DataPtr);
end;

Begin
Ap.Init;
Ap.Run;
Ap.Done;
End.