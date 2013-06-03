{$F+,O+}
Unit Antivirs;
Interface
 Procedure SearchAntivir;
Implementation
Uses App, Dialogs, Views, Objects, Supply, Dos, Drivers, MessBox, DrsHelp;
Const
      MaskMonitors    = $07;
      MaskTests1      = $07;
      MaskOther1      = $03;
      MaskOther2      = $3F;
   Type

    PNewCheckBoxes = ^TNewCheckBoxes;
    TNewCheckBoxes = Object(TCheckBoxes)
                       procedure HandleEvent(var Event: TEvent); virtual;
                     End;

    PDriverHead = ^TDriverHead;
    TDriverHead = Record
               Offset    : Word;
               Segment   : Word;
               DevAttr   : Word;
               Strategy  : Word;
               Interupt  : Word;
               Name      : Array [1..8] Of Char;
              End;

   PAVGData = ^TAVGData;
   TAVGData = record
               Control              :  Word;
               Test                 :  Word;
               Other                :  Word;
           end;

   PVSAFEData = ^TVSAFEData;
   TVSAFEData = record
                 Data               :  Word;
                end;

Function VsafeInit:Boolean;assembler;
asm
mov ax,0FA03h
mov dx,05945h
int 16h
mov al,false
cmp di,17753
jne @end
mov al,true
@end:
End;

Function GetVSAFEData:Byte;assembler;
asm
mov ax,0FA02h
mov dx,05945h
mov bl,0h
int 16h
mov ax,0FA02h
mov dx,05945h
mov bl,Cl
push cx
int 16h
pop cx
mov al,cl
end;

Procedure SetVSAFEData(Data : Byte);assembler;
asm
mov ax,0FA02h
mov dx,05945h
mov bl,Data
int 16h
end;

procedure TNewCheckBoxes.HandleEvent;
begin
  If (Event.What=evCommand) And
   (Event.Command=CmClose) or (Event.Command=CmCancel)
     Then Event.Command:=CmOk;
  TCheckBoxes.HandleEvent(Event);
end;

function SETAVG(var _Data : TAVGData; _SetData : Boolean): Word;
var
  D    : PDialog;
  C    : PView;
  R    : TRect;
  _DataPtr : PAVGData;
begin
  R.Assign(1,0,77,22);
  D:=New(PDialog,Init(R,'Nastaven¡ rezidentniho driveru AVG - 5.0'));
  D^.Options:=(D^.Options Or ofCentered);
  with D^ do
       begin
          R.Assign(3,12,72,20);
          C:=New(PFramedView,Init(R));
          Insert(C);

          R.Assign(3,7,72,10);
          C:=New(PFramedView,Init(R));
          Insert(C);

          R.Assign(3,2,72,5);
          C:=New(PFramedView,Init(R));
          Insert(C);

          R.Assign(4,1,18,2);
          C:=New(PStaticText,Init(R,' Monitorovan¡ '));
          Insert(C);

          R.Assign(4,2,71,5);
          C:=New(PNewCheckBoxes,Init(R,
               NewSItem('Kontrola z pisu do syst‚mov˜ch oblasti',
               NewSItem('Kontrola otev©en¡ EXE/COM souboru pro zapis',
               NewSItem('Kontrola p©ejmenov n¡ EXE/COM souboru',
               nil)))));
          Insert(C);

          R.Assign(4,6,11,7);
          C:=New(PStaticText,Init(R,' Testy '));
          Insert(C);

          R.Assign(4,7,71,10);
          C:=New(PNewCheckBoxes,Init(R,
               NewSItem('Antivyrov˜ test spou¨tˆn˜ch souboru',
               NewSItem('Antivirov˜ test otev¡ran˜ch souboru',
               NewSItem('Antivirov˜ test boot sektoru disket',
               nil)))));
          Insert(C);

          R.Assign(4,11,13,12);
          C:=New(PStaticText,Init(R,' Ostatn¡ '));
          Insert(C);

          R.Assign(4,12,71,20);
          C:=New(PNewCheckBoxes,Init(R,
               NewSItem('Kontrola diskety po stisku CTRL-ALT-DEL',
               NewSItem('Hl ¨en¡ o prob¡haj¡cich testech',
               NewSItem('Zvukov  signalizace',
               NewSItem('Test pameti pri inicializaci',
               NewSItem('Hl ¨en¡ na obrazovku i v grafickem rezimu',
               NewSItem('Alokace XMS pameti pro ulozeni dat driveru',
               NewSItem('Nastaven¡ nov˜ch obluh po inicializaci site',
               NewSItem('Kontrola tunelovan¡ vektor– INT 13 a INT 21',
               nil))))))))));
          Insert(C);

          SelectNext(False);
       end;

   _DataPtr:=@_Data;
   if not _SetData then FillChar(_Data,SizeOf(_Data),0);
   SETAVG:=Application^.ExecuteDialog(D,_DataPtr);
end;

function SetVSAFE(var _Data : TVSAFEData; _SetData : Boolean): Word;
var
  D    : PDialog;
  C    : PView;
  R    : TRect;
  _DataPtr : PVSAFEData;
begin
  R.Assign(14,6,66,16);
  D:=New(PDialog,Init(R,'VSAFE antivirus'));
  with D^ do
       begin
          R.Assign(2,1,50,9);
          C:=New(PNewCheckBoxes,Init(R,
               NewSItem('Ochrana proti formatovan¡',
               NewSItem('Ochrana proti rezidentum',
               NewSItem('Generalni ochrana proti zapisu',
               NewSItem('Kontrola spustitelnych souboru',
               NewSItem('Ochrana proti Boot sectorovym ',
               NewSItem('Ochrana boot sectoru hardisku',
               NewSItem('Ochrana boot sektoru diskety',
               NewSItem('Ochrana zapisu do spustitelnyc',
               nil))))))))));
          Insert(C);

          SelectNext(False);
       end;
   _DataPtr:=@_Data;
   if not _SetData then FillChar(_Data,SizeOf(_Data),0);
   SetVSAFE:=Application^.ExecuteDialog(D,_DataPtr);
end;

Procedure SearchAntivir;
Const AVG          : Array [1..8] Of Char = ('A','V','G','S','Y','S','5','0');
Const AVGSearched  : Boolean              = False;
      Searched     : Boolean              = False;
Type  SwapType     = Array [1..$40] Of Byte;
Var   R            : Registers;
      P            : Pointer;
      Head         : PDriverHead;
      AVGData1     : ^Byte;
      AVGData2     : ^Byte;
      SwapData     : ^SwapType;
      AvgData      : PAVGData;
      VSAFEData    : PVSAFEData;
Begin
  Application^.HelpCtx:=hcAntivirs;
  AVGSearched := False;
  R.Ah:=$52;
  Msdos(R);
  Head:=Ptr(R.es,R.bx+$22);
    While Head^.Offset<>$ffff Do Begin
                                  If Head^.Name = AVG Then
                                    Begin
                                      AVGSearched:=True;
                                      SwapData:=@Head^;
                                      AVGData1:=@SwapData^[$3F];
                                      AVGData2:=@SwapData^[$40];
                                    End;
                                  Head:=Ptr(Head^.Segment,Head^.Offset);
                                 End;
  If AvgSearched Then Begin
                       New(AvgData);
                       AvgData^.Control:=AvgData1^ And MaskMonitors;
                       AvgData^.Test  := ((AvgData1^ shr 3) And MaskTests1);
                       AvgData^.Other := ((AvgData1^ shr 6) And MaskOther1) or
                                      ((AvgData2^ and MaskOther2) shl 2);
                       SetAvg(AvgData^,True);
                       AVGData1^:= (AvgData^.Control) or (AvgData^.Test Shl 3) or
                                 ((AvgData^.Other and MaskOther1) shl 6);
                       AVGData2^:= ((AvgData^.Other shr 2) and MaskOther2);
                       Dispose(AvgData);
                       Searched := True;
                      End;
  If VSAFEInit Then Begin
                      New(VSAFEData);
                      VSAFEData^.Data:=GetVsafeData;
                      SetVsafe(VSAFEData^,True);
                      SetVsafeData(VSAFEData^.Data);
                      Dispose(VSAFEData);
                      Searched := True;
                    End;

If Not Searched Then
   MessageBox(#3+'Nenalezen zadny antivirus ',nil,mfOkButton + mfInformation);
    Application^.HelpCtx:=hcNoContext;
End;

End.