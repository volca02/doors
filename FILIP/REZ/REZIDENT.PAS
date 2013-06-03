uses dialogs, views, objects, app, drivers, crt, supply, msgbox, base;
type
     tMCB  = record
               typ  : char; {M,Z}
               Own  : word; { 0 = sam sebe }
               siz  : word; { *16 bajtu }
             end;

   PPROGData = ^TPROGData;
   TPROGData = record
               Data1                :  PCollection;
               Data2                :  integer;
           end;
   PProgramListViewer = ^TProgramListViewer;
   TProgramListViewer = Object(TListViewer)
                         function GetText(Item: Integer; MaxLen: Integer): String; virtual;
                       End;

var
  g     : TPROGData;

Function TProgramListViewer.GetText;
const
  beg = $8;
Var Driver : ^tMCB;
    d      : tMCB;
    S      : String;
    I      : Byte;
    po     : String[8];
Begin
  Driver:=g.data1^.At(Item);S:='';
  d:=driver^;
  if d.own=0 then d.own:=SEG(driver^);
  d.own:=d.own-1;
  i:=beg;
  repeat
    s:=s+CHR(MEM[D.own:i]);
    inc(i);
  until (MEM[D.own:i]<=32) or (i>=beg+8);
  if item=0 then s:='1. MCB';
  po:=DECtoHEX(driver^.own);
  s:=FilltoLength(s,8,' ');
  s:=s+FilltoFront(FilltoFront(po,4,'0'),7,' ');
  po:=DECtoHEX(driver^.siz);
  s:=s+' '+FilltoFront(FilltoFront(po,4,'0'),9,' ');
  po:=DECtoHEX(SEG(driver^));
  s:=s+FilltoFront(FilltoFront(po,4,'0'),9,' ');
  s:=s+FilltoFront(D.typ,5,' ');
{  s[0]:=#8;}
  GetText:=S;
End;

function PROG(var _Data : TPROGData; _SetData : Boolean): Word;
var
  D    : PDialog;
  C    : pview;
  P    : PProgramListViewer;
  SB   : PScrollBar;
  R    : TRect;
  _DataPtr : PPROGData;
begin
  R.Assign(8,1,57,20);
  D:=New(PDialog,Init(R,'Vypis MCB'));
  with D^ do
       begin
          R.Assign(45,3,46,18);
          SB:=New(PScrollBar,Init(R));
          Insert(SB);
          R.Assign(3,3,45,18);
          P:=New(PProgramListViewer,Init(R,1,nil,nil));
          P^.Range:=_data.data1^.Count;
          Insert(P);

          R.Assign(4,2,47,3);
          C:=New(PStaticText,Init(R,'Jmeno  Vlastnik  Velikost  Segment  Typ'));
          Insert(C);

          SelectNext(False);
       end;

   _DataPtr:=@_Data;
   if not _SetData then FillChar(_Data,SizeOf(_Data),0);
   PROG:=Application^.ExecuteDialog(D,_DataPtr);
end;

Function GetAdress  : Word;
var
   x  : Word;
   w  : Word;
begin
  asm
    mov ah, 52h
    int 21h
    mov ax, es:[bx+$0FFFE]
    mov x, ax
  end;
  getadress:=x;
end;

var
  p     : ^tmcb;
  q     : tmcb;
  fajl  : string;
  f     : file;
  i,o   : array [0..255] of char;
  num,x,pr : byte;
  moje  : tapplication;

begin
  moje.init;
  g.data1:=new(PCollection,init(0,1));
  p:=Ptr(getadress,0);
  repeat
    p:=ptr(seg(p^)+1+p^.siz,0);
    g.data1^.insert(p);
  until p^.typ<>'M';
  p:=ptr(seg(p^)+1+p^.siz,0);
  Prog(g,true);
  dispose(g.data1);
  moje.done;
end.
