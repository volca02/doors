{$X+,F+,O+}

unit Viewer;

interface

uses Drivers, Objects, Memory, Views, Dialogs, Czech, Variable, NewViews;

type
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
  PViewer = ^TViewer;
  TViewer = object(TView)
    F            : file;
    GoEnd        : Boolean;
    Allocated    : word;
    ActualPos    : Longint;
    Buffer       : Pointer;
    Mode         : Byte;
    EndStyle     : boolean; { zalamovani }
    txtL         : longint; { konec 1. ho radku (i s pripadnym 10 - tj. 13 10) }
    txtP         : longint; { konec stranky (to sou zdrzovacky!) }
    asmL         : longint; { totez plati pro assembler }
    asmP         : longint; {  }
    ModeChanged  : boolean;
    BufSize      : Longint;
    Offset       : Longint;
    jmpnum       : byte;
    ColorEnabled : boolean;
    addrjmp      : array [1..25] of longint;
    constructor Init(var Bounds: TRect;Const Name : String);
    constructor Load(var S: TStream);
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure ScrollTo(X, Y: Longint);
    procedure SetLimit(X, Y: Longint);
    procedure Store(var S: TStream);
    procedure Draw;Virtual;
    Destructor Done;Virtual;
    procedure NajdiLastEnter;
    procedure EnterDoEnd;
    Procedure OneAsmBack;
    Procedure NextAsm;
    Procedure OneAsmLineUp;
    { Funkce pro nacitani}
    Procedure InitBuffer;
    Procedure BufferRead(Var Buf;Count:Word;Pos:Longint);
    Procedure DoneBuffer;
  end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
  PViewerWindow = ^TViewerWindow;
  TViewerWindow = object(TDialog)
    Interior: PViewer;
    constructor Init(var Bounds: TRect; Filename: FNameStr);
    function GetHelpCtx: Word; virtual;
    destructor Done; virtual;
    function GetPalette: PPalette; virtual;
  end;

Function FileViewer(Name : String)  : Word;
implementation

uses MessBox, App, Base, BitMap, Crt, DrsHelp, ToAsm, Tools, Dos;
Const AsmBack = 4;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function Min(a,b : longint)  : longint;
begin
  if a>b then Min:=b else Min:=a;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function Max(a,b : longint)  : longint;
begin
  if a>b then Max:=a else max:=b;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function FileViewer(Name : String):Word;
Var D       : PDialog;
    R       : TRect;
    ScrMode : Word;
    E       : String;
    Ext     : String [3];
Begin
 Ext := UpString(GetExtension(Name));
 If (Ext = 'BMP') or (Ext = 'PCX') Then
   Begin
     ScrMode := ScreenMode;
     DoneMemory;
     DoneVideo;
     DoneEvents;
     DoneSysError;

     If Ext = 'BMP' Then E :=ViewBMP(Name)
      Else E := ViewPCX(Name);
     If E ='' Then Readkey;
      SetVideoMode(ScrMode);
      InitMemory;
      InitVideo;
      InitEvents;
      InitSysError;
      LoadFont;
      Asm
        mov ah,10h
        mov al,3
        xor bl,bl
        int 10h
      End;
     Application^.Redraw;
     If E<>'' Then MessageBox(Error,Nil,mfError+mfOkButton);
   End
   Else Begin
          R.Assign(0,0,Application^.Size.X,Application^.Size.Y-1);
          D:=New(PViewerWindow,Init(R,Name));
          D^.State:=ClearBit(D^.State,sfShadow);
          D^.Flags:=ClearBit(D^.Flags,wfMove);
          D^.Options:=SetBit(D^.Options,ofCentered);
          Application^.ExecView(D);
          Dispose(D,Done);
          Application^.HelpCtx := hcNoContext;
        End;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure AddHexByte(B: Byte; P: Pointer);
const
  HexChars : array[0..15] of char = '0123456789ABCDEF';
type
  P2Char = ^T2Char;
  T2Char = array[0..1] of Char;
begin
  P2Char(P)^[0] := HexChars[ (B and $F0) shr 4 ];
  P2Char(P)^[1] := HexChars[ B and $0F ];
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TViewer.InitBuffer;
Begin
 Allocated := $FFF;
 If Allocated > MemAvail Then Allocated := MemAvail;
 if allocated > BufSize then allocated := BufSize;
 GetMem(Buffer,Allocated);
 ActualPos := 0;
 Seek(F,ActualPos);
 BlockRead(F,Buffer^,Allocated)
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TViewer.BufferRead;
type tarray  = array [0..$FFFE] of byte;
Var Event : TEvent;
Begin
 If (Pos>(ActualPos+Allocated)) or (pos<Actualpos) Then
 Begin
   actualpos:=pos-allocated div 2;
   actualpos:=Max(actualpos,0);
   actualpos:=Min(actualpos,BufSize-allocated);
   {$I-}
   seek(f, actualpos);
   if ioresult<>0 then Begin
                        Write(#7#7#7#7);
                       End;
   {$I-} Blockread(f, buffer^, allocated); {$I+}
   if ioresult<>0 then Begin
                        Write(#7#7#7#7);
                       End;
 End;
 pos:=pos-actualpos;
 Move(TArray(buffer^)[pos],buf,count);
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TViewer.DoneBuffer;
Begin
 If Buffer <>Nil Then FreeMem(Buffer,Allocated);
 Buffer := Nil;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
constructor TViewer.Init;
var
  Result    : Word;
  FSize     : Longint;
  Msg       : String;
  SaveMode  : Byte;
  instr     : string;
  s         : Byte;
begin
  TView.Init(Bounds);
  Options := Options or ofSelectable;
  EventMask := EventMask or evBroadcast;
  GrowMode := gfGrowHiX + gfGrowHiY;
  Options := Options or ofTileable;
  {Nastaveni prepinacu a podobne}
  Mode    := 0;
  EndStyle := true;
  ColorEnabled := false;
  ModeChanged:=true;
  Msg := '';
  GoEnd := False;
  { open the file }
  SaveMode := FileMode;
  FileMode := 0;
  Assign(F, Name);
  {$I-}
  Reset(F,1);
  {$I+}
  FileMode := SaveMode;
  Result := IOResult;
  if Result = 0 then
  begin
    BufSize := FileSize(F);
    InitBuffer;
  End
  else Begin
        Msg := 'Nelze otevrit tento soubor !';
        MessageBox(Msg, nil, mfInformation+mfOKButton);
        GoEnd := True;
        Exit;
       End;
  SetLimit(Size.X, BufSize);
  ScrollTo(0,0);
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
destructor TViewer.Done;
Var S : ^FileRec;
begin
  If Buffer <>Nil Then DoneBuffer;
  S := @F;
  If Not ((S^.Mode And fmClosed) = FmClosed) Then close(f);
  inherited Done;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TViewer.EnterDoEnd;
var
  byt  : byte;
  q    : byte;
begin
   Q:=0;
   While (Offset<BufSize) and (q<size.y) Do
    Begin
       Inc(q); byt:=0; Inc(offset);
       while (byt<>13) and (offset>0) and (Offset<Bufsize)do
       begin
        BufferRead(byt,1,offset);
        Inc(offset);
       end;
     end;
     for byt:=1 to size.y-q do NajdiLastEnter;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TViewer.NajdiLastEnter;
var
  byt  : byte;
  q    : byte;
begin
   for q:=1 to 2 do
   begin
     byt:=0; Dec(offset);
     while (byt<>13) and (offset>0) do
     begin
       BufferRead(byt,1,offset);
       dec(offset);
     end;
   end;
   if byt=13 then
   begin
     inc(offset,2);
     BufferRead(byt,1,offset);
     if byt=10 then inc(offset);
   end;
   if offset<0 then offset:=0;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TViewer.OneAsmBack;
var
  byt  : byte;
  s    : string;
  data : array [1..16] of byte;
  x, moznost  : byte;
begin
  x:=0; moznost:=1;
  while (x<16) and (offset>x) do
  begin
    inc(x);
    BufferRead(Data, Min(Max(0,bufsize-(offset-x) ),16), Max(offset-x,0) );
    Decode(@data,s,byt);
    if (byt=x) then moznost:=x;
    if x>offset then x:=offset;
    asmL:=moznost;
  end;
  offset:=Min(Max(offset-moznost,0),bufsize-1);
  if offset=0 then asmL:=0;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TViewer.NextAsm;
var
  byt  : byte;
  s    : string;
  data : array [1..16] of byte;
begin
  BufferRead(Data, Min(Max(0,bufsize-offset ),16), Max(offset,0) );
  Decode(@data,s,byt);
  offset:=Min(Max(offset+byt,0),bufsize-1);
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TViewer.OneAsmLineUp;
var
  byt  : byte;
  oldoffset : longint;
  I         : Word;
  Data      : Array[1..16] Of Byte;
  Instr     : String;
begin
  if offset>0 then
  begin
    oldoffset:=offset;
    For I:=1 To AsmBack Do OneAsmBack;
    Byt:=0;
    While Offset<OldOffset Do
    Begin
      fillchar(data,sizeof(data),0);
      BufferRead(Data, Min(16,bufsize-offset),Max(Offset,0));
      Decode(@Data,Instr,Byt);
      inc(offset, byt);
    End;
    dec(offset, byt);
    if (oldoffset=offset) then OneAsmBack;
  end;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure TViewer.HandleEvent;
var
  oldoffset : longint;
  Addres    : String;
  IAddres   : Longint;
  RetCode   : Integer;
  byt       : byte;
Begin
  If GoEnd Then PDialog(Owner)^.EndModal(CmCancel);
  TView.HandleEvent(Event);
  Case Event.What Of
    EvCommand: Case Event.Command Of
                CmChangeAddres : Begin
                                  Addres := '';
                                  InputBox('Zmena adresy','Zadej adresu (HEX)',Addres,15,HiChangeAddres);
                                  HexVal(Addres,IAddres,RetCode);
                                  If (RetCode<>0) Or (IAddres>Bufsize)
                                     Or (IAddres<0) Then
                                  MessageBox('Spatne zadani adresy',Nil,
                                       MfError+mfOkButton+mfInsertInApp)
                                  Else Offset := IAddres;
                                  DrawView;
                                 End;
                CmColorMode  : Begin
                                 ColorEnabled:= Not ColorEnabled;
                                 DrawView;
                               End;
                CmChangeMode : begin
                                 ModeChanged := true;
                                 Inc(mode);
                                 if mode>2 then mode:=0;
                                 DrawView;
                               End;
                CmLineMode   : begin
                                 Endstyle:=not endstyle;
                                 DrawView;
                               End;

               End;
    EvKeyDown:
               Begin
               Case Event.Keycode Of
                 KbAltA : ASCIITable;
                 KbUp   : Begin
                            Case Mode Of
                              1: If Offset >= 16 Then Dec(Offset,16)
                                   Else Offset := 0;
                              0: begin
                                   NajdiLastEnter;
                                   drawview;
                                 end;
                              2: OneAsmLineUp;
                            End;
                           ScrollTo(0,Offset);
                           DrawView;
                          End;
                 KbDown : Begin
                            Case Mode Of
                              0: begin
                                  offset:=offset+TxtL;
                                 { enterdoend;}
                              end;
                              1: If Offset < Max(BufSize-Size.Y*16,0) Then
                                       Inc(Offset,16);
                              2 : Begin
                                   If Offset < BufSize Then
                                      Offset := Offset + AsmL;
                                  End;
                            End;
                           ScrollTo(0,Offset);
                           DrawView;
                          End;
                 KbPgUp :  Begin
                            Case Mode Of
                              0: for byt:=1 to size.y-1 do NajdiLastEnter;
                              1: If Offset >= ((Size.Y-1)*16) Then
                                       Dec(Offset,(Size.Y-1)*16)
                                  Else Offset := 0;
                              2: For Byt:=1 to size.y-1 do OneAsmLineUp;
                            End;
                           ScrollTo(0,Offset);
                           DrawView;
                          End;
                 KbPgDn :  Begin
                            Case Mode Of
                               0:
                                 begin
                                   offset:=offset+TxtP;
                                   EnterDoEnd;
                                 end;
                               1: Begin
                                    If Offset < Max(BufSize-(Size.Y)*16,0) Then
                                         Inc(Offset,16*(Size.Y-1));
                                    If (Offset + Size.Y * 16) > BufSize Then
                                    Offset := Max(BufSize-(Size.Y * 16),0);
                                    if offset and $F<>0 then
                                      offset:=offset+$10-(Offset and $F);
                                   end;
                              2: Offset := Offset + AsmP;
                            End;
                           ScrollTo(0,Offset);
                           DrawView;
                          End;

               End;
               If Upcase(Event.CharCode) In ['1'..Chr(jmpnum+ord('0')-1)] Then
                Begin
                  oldoffset:=offset;
                  offset:=addrjmp[Ord(Event.CharCode)-ord('0')];
                  if offset>bufsize then
                  begin
                    offset:=oldoffset;
                    Write(#7);
                  end;
                  DrawView;
                End;
               End;
  End;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure TViewer.Draw;
const
  HStart   = 11;     { starting column of hex dump }
  CStart   = 63;    { starting column of character dump }
var
  Data      : Array[1..16] Of Byte;
  B         : TDrawBuffer;
  S,s1      : String;
  C,C2,C3,C4   : Word; { normalni, retezce a cisla, komentare }
  Counter   : Longint;
  x,y,z     : Byte;
  i,byt     : Byte;
  L         : Longint;
  roffset   : word;
  NextLine  : boolean;
  instr     : string;
  a         : byte;
  n         : Byte;
  oldroffset  : longint;
  uv, num, comment   : boolean;

begin
  C := GetColor(1);  C2 := GetColor(2);  C3 := GetColor(3); C4 := GetColor(4);
  roffset:=0; jmpnum:=1; comment:=false;
  For y := 0 to Size.Y-1 do
   Begin
    Case Mode Of
     1 : Begin
          MoveChar(B, #32, C, Size.X);
          if Offset + (Y * 16) < BufSize then
            begin
              L := Offset + Y * 16;      {Vypocet offsetu pro zobrazeni}
              FormatStr(S, '%08x ', L);  {Formatovani}
              MoveCStr(B[0],S,C);
              i := HStart;S:='';
              for x := 0 to 15 do
               begin
                 roffset:=x + y * 16;
                 if Offset + Roffset < BufSize then
                 begin
                   S:=S + '   ';
                   BufferRead(byt,1, Offset+Roffset);
                   AddHexByte(byt, @S[Length(S)-2]);
                   MoveChar(B[CStart + x-1], Char(byt), C2, 1);
                   if (x+1) mod 4=0 then S := S + ' ';
                 end;
               end;
               MoveCStr(B[HStart-1],S,C);
            end;
          WriteLine(0,Y,Size.X,1,B);
         End;
     0 : Begin  { TXT }
          MoveChar(B, #32, C, Size.X);
          nextline:=false; a:=0; uv := false; num:=false;
          Txtp:=Roffset;
          For X:=0 To Size.X-1 Do
          if (offset+ROffset)<BufSize then
          Begin
            BufferRead(byt,1,Offset+ROffset);
            If byt = 13 Then
            begin
              inc(roffset);
              BufferRead(byt,1,Offset+ROffset);
              if byt = 10 then
              begin
                inc(roffset);
                BufferRead(byt,1,Offset+ROffset);
              end;
              nextline:=true;
              Break;
            end;
            if byt=ord('{') then comment:=true else
            if byt=ord('}') then comment:=false else
            if byt=Ord('''') then uv:=not uv else
            if Chr(byt) in ['+','-','*','/','(',')',';','=',',','.',':','^','@']
                          then num:=true
                          else num:=false;

            uv:=uv and ColorEnabled;
            num:=num and ColorEnabled;
            comment:=comment and ColorEnabled;
            if byt = 9 Then
            begin
              n:=Roundup(x+a+1,8)-1;
              a:=n-x;
            end else
            if x+a<size.x then
            if (comment) or ((ord('}')=byt) and colorenabled) then
                       MoveChar(B[X+a],Char(byt),C3,1) else
            if (uv) or ((ord('''')=byt) and colorenabled) then
                       MoveChar(B[X+a],Char(byt),C2,1)
                  else
            if num then MoveChar(B[X+a],Char(byt),C4,1)
                  else MoveChar(B[X+a],Char(byt),C,1);
            if x+a<size.x then inc(roffset);
         End;
         WriteBuf(0, Y, Size.X, 1,B);
         if (offset+ROffset)<BufSize then
         if endstyle then
          if not nextline then
          while not nextline do
          begin
            BufferRead(byt,1,Offset+ROffset);
            If Byt = 13 Then
            begin
              inc(roffset);
              if offset+roffset>bufsize then
              begin
                nextline:=true;
                break;
              end;
              BufferRead(byt,1,Offset+ROffset);
              if Byt = 10 then inc(roffset);
              if offset+roffset>bufsize then
              begin
                nextline:=true;
                break;
              end;
              BufferRead(byt,1,Offset+ROffset);
              nextline:=true;
              Break;
            end;
            inc(roffset);
            if offset+roffset>=BufSize then nextline:=true;
          end;
          if y=0 then TxtL:=roffset;
       End;
     2: Begin
          MoveChar(B, #32, C, Size.X);
          If (offset+ROffset)<BufSize then
          Begin
          AsmP :=ROffset;
          l:=offset+roffset;
          oldroffset:=roffset;
          asmfilepos:=l;
          FillChar(Data,SizeOf(Data),0);
          BufferRead(Data,Min(Max(0,bufsize-(offset+roffset)),16),
                          offset+roffset);
          Decode(@Data,instr, a);
          Inc(roffset,a);
          FormatStr(S, '%010x ', L);
          FillChar(s1[1], 15, #32); s1[0]:=#15;
          for x:=1 to a do
               AddHexByte(Data[x], @S1[x*2]);
          if jmp then
          begin
            instr:=instr+' ;';
            instr:=Filltolength(instr,25,'-')+'('+ToHex(jmpnum,false)+')';
            addrjmp[jmpnum]:=jmpaddr;
            inc(jmpnum);
          end;
          instr:=S+FilltoLength(s1,15,' ')+instr;
          for x:=1 to length(instr) do
            MoveChar(B[X],instr[x],C,1);
            if y=0 then AsmL:=roffset;
          End;
          WriteBuf(0, Y, Size.X, 1,B);
        End;
    End;
   End;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
constructor TViewerWindow.Init(var Bounds: TRect; Filename: FNameStr);
var
  R: TRect;
  HorizontalSB, VerticalSB : PLongScrollBar;
begin
  inherited Init(Bounds, Filename);
  GetExtent(R);
  R.Grow(-1,-1);
  Interior := New(PViewer, Init(R,  Filename));
  Insert(Interior);
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
destructor TViewerWindow.Done;
begin
  if Interior <> nil then Dispose(Interior, Done);
  inherited Done;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
function TViewerWindow.GetHelpCtx: Word;
Begin
 GetHelpCtx := hcFileView;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
function TViewerWindow.GetPalette: PPalette;
Const CNColor     = #164#165#166#167#168#169#170#171#172;
      P: string[Length(CNColor)] = CNColor;
Begin
  GetPalette := @P;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
constructor TViewer.Load(var S: TStream);
begin
  TView.Load(S);
  S.Read(Offset, SizeOf(Longint));
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
function TViewer.GetPalette: PPalette;
Const CNColor     = #6#7#8#9;
      P: string[Length(CNColor)] = CNColor;
begin
  GetPalette := @P;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure TViewer.ScrollTo(X, Y: Longint);
begin
  Offset := Y;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure TViewer.SetLimit(X, Y: Longint);
begin
  Offset := Y ;
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure TViewer.Store(var S: TStream);
begin
  TView.Store(S);
  S.Write(Offset, SizeOf(Longint));
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
end. { unit }
