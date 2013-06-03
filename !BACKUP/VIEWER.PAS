{$X+,F+,O+}

unit Viewer;

interface

uses Drivers, Objects, Memory, Views, Dialogs, Czech;

type

  PViewer = ^TViewer;
  TViewer = object(TScroller)
    Mode   : Byte;
    FileBuf: Pointer;
    BufSize: Word;
    MaxLines: Integer;
    constructor Init(var Bounds:TRect; AVScrollBar: PScrollBar;
      const Name: FNameStr);
    destructor Done; virtual;
    procedure Draw; virtual;
  end;

  PHexWindow = ^THexWindow;
  THexWindow = object(TDialog)
    Interior: PViewer;
    constructor Init(var Bounds: TRect; Filename: FNameStr);
    destructor Done; virtual;
    function GetPalette: PPalette; virtual;
  end;

Function HexViewer(Name : String):Word;
implementation

uses MessBox, App, Base, BitMap, Crt;

type
  String2 = String[2];

  PByteBuffer = ^TByteBuffer;
  TByteBuffer = array[0..$FFFE] of Byte;


Function HexViewer(Name : String):Word;
Var D : PDialog;
    R : TRect;
    ScrMode : Word;
Begin
 If UpString(GetExtension(Name)) = 'BMP' Then
   Begin
     ScrMode := ScreenMode;
     ViewBMP(Name);
     Readkey;
     SetVideoMode(ScrMode);
     LoadFont;
      Asm
        mov ah,10h
        mov al,3
        xor bl,bl
        int 10h
      End;
     Application^.Redraw;
   End
   Else Begin
          R.Assign(0,0,Application^.Size.X,Application^.Size.Y-1);
          D:=New(PHexWindow,Init(R,Name));
          D^.State:=ClearBit(D^.State,sfShadow);
          D^.Flags:=ClearBit(D^.Flags,wfMove);
          D^.Options:=SetBit(D^.Options,ofCentered);
          Application^.ExecView(D);
          Dispose(D,Done);
        End;
End;

{ Store hex characters directly into the string location pointed to by P }
{ No bounds checking done! }
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


{ THexViewer }

constructor TViewer.Init(var Bounds:TRect; AVScrollBar: PScrollBar;
  const Name: FNameStr);
var
  F: File;
  Result: Word;
  FSize : Longint;
  Msg: String;
  SaveMode : Byte;
begin
  inherited Init(Bounds, nil, AVScrollBar);
  GrowMode := gfGrowHiX + gfGrowHiY;
  Options := Options or ofTileable;
  FileBuf := nil;
  BufSize := 0;
  Mode    := 1;
  Msg := '';

  { open the file }

  SaveMode := FileMode;
  FileMode := 0;        { make sure we open as Read-Only }
  Assign(F, Name);
  {$I-}
  Reset(F,1);
  {$I+}
  FileMode := SaveMode;
  Result := IOResult;
  if Result = 0 then
  begin
    FSize := FileSize(F);

    if FSize > $FFFE then
    begin
      FSize := $FFFE;
      Msg := 'Soubor je vetsi nez 64k.  Vypis bude oriznut';
    end;

    if FSize > MaxAvail - LowMemSize then  { use standard safety size }
    begin
      FSize := MaxAvail - LowMemSize;
      if FSize > 0 then
        Msg := 'Malo volne pameti .  Vypis bude oriznut.'
      else Msg := 'Neni pamet';
    end;

    if FSize > 0 then
    begin
      GetMem(FileBuf, FSize);
      BlockRead(F, FileBuf^, FSize, Result);
      BufSize := FSize;
    end;

    Close(F);
  end
  else Msg := 'Nelze otevrit tento soubor !';

  { Display any message that was generated }
  if Msg <> '' then
    MessageBox(Msg, nil, mfInformation+mfOKButton);

  MaxLines := BufSize div 16;
  if BufSize mod 16 > 0 then Inc(MaxLines);
  SetLimit(0, MaxLines);
end;

destructor TViewer.Done;
begin
  if (BufSize > 0) and (FileBuf <> nil) then FreeMem(FileBuf, BufSize);
  inherited Done;
end;

procedure TViewer.Draw;
const
  VWidth = 78;      { total width of view }
  HStart = 13;      { starting column of hex dump }
  CStart = 62;      { starting column of character dump }
  LineChar = #32;   { vertical line character }
var
  B: TDrawBuffer;
  S: String;
  C: Word;
  Offset: Longint;
  Counter : Longint;
  x,y,z : Byte;
  i,byt: Byte;
  L: Longint;
begin
  C := GetColor(1);
  for y := 0 to Size.Y-1 do
  begin
  If Mode<>1 Then Begin
    FillChar(S[1], VWidth, 32);
    S[0] := Char(VWidth);
    MoveChar(B, #32, C, Size.X);
    Offset := (Delta.Y + Y) * 16;
    if (Delta.Y + Y) < MaxLines then
    begin
      L := (Delta.Y + Y) * 16;
      FormatStr(S, '%010x:', L);
      S[0] := Char(VWidth);
      i := HStart;
      for x := 0 to 15 do
      begin
        if Offset + x < BufSize then
        begin
          byt := PByteBuffer(FileBuf)^[Offset+x];
          AddHexByte(byt, @S[i]);
          S[CStart + x ] := Char(byt);
          Inc(i,3);
        end;
      end;
    end;
    S[CStart - 1] := LineChar;
    MoveStr(B, S, C);
    WriteLine(0,Y,Size.X,1,B);
     End
  Else Begin
        Counter := 0;
        Offset := 0; While Counter<Delta.Y+Y Do Begin
                                               If PByteBuffer(FileBuf)^[Offset] = 13 Then Inc(Counter);
                                               Inc(Offset);
                                              End;
        MoveChar(B, #32, C, Size.X);
        For X:=0 To Size.X Do Begin
                               If PByteBuffer(FileBuf)^[Offset+X] = 13 Then Break;
                               MoveChar(B[X],Chr(PByteBuffer(FileBuf)^[Offset+X]),C,1);
                              End;
        WriteBuf(0, Y, Size.X, 1,B);
       End;
  end;
end;


{ THexWindow }
constructor THexWindow.Init(var Bounds: TRect; Filename: FNameStr);
var
  R: TRect;
  SB: PScrollBar;
begin
  inherited Init(Bounds, Filename);
  GetExtent(R);
  SB := StandardScrollBar(sbVertical + sbHandleKeyboard);
  Insert(SB);
  R.Grow(-1,-1);
  Interior := New(PViewer, Init(R, SB, Filename));
  Insert(Interior);
end;

destructor THexWindow.Done;
begin
  if Interior <> nil then Dispose(Interior, Done);
  inherited Done;
end;

function THexWindow.GetPalette: PPalette;
const
  MyPal : String[Length(CGrayWindow)] = CBlueWindow;
begin
  GetPalette := @MyPal;
end;

end. { unit }
