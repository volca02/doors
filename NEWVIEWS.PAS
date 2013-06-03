unit NewViews;

{$F+,O+,S-,D-,Q-}

interface

uses Dos, Objects, Views, App, Dialogs, Drivers;

type
{����������������������������������������������������������������������������}
  LTpoint = Record
             X : Longint;
             Y : Longint;
            End;
{����������������������������������������������������������������������������}
  PLongScrollBar = ^TLongScrollBar;
  TLongScrollBar = object(TView)
    Value   : Longint;
    Min     : Longint;
    Max     : Longint;
    PgStep  : Longint;
    ArStep  : Longint;
    constructor Init(var Bounds: TRect);
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure ScrollDraw; virtual;
    function ScrollStep(Part: Longint): Longint; virtual;
    procedure SetParams(AValue, AMin, AMax, APgStep, AArStep: Longint);
    procedure SetRange(AMin, AMax: Longint);
    procedure SetStep(APgStep, AArStep: Longint);
    procedure SetValue(AValue: Longint);
    procedure Store(var S: TStream);
  private
    Chars: TScrollChars;
    procedure DrawPos(Pos: Longint);
    function GetPos: Longint;
    function GetSize: Longint;
  end;
{����������������������������������������������������������������������������}
  PDriveListBox = ^TDriveListBox;
  TDriveListBox = Object(TListBox)
                   constructor Init(var Bounds: TRect; ANumCols: Word; AScrollBar:PScrollBar);
                   procedure HandleEvent(var Event: TEvent); virtual;
                  End;
{����������������������������������������������������������������������������}
  PHexInputLine = ^THexInputLine;
  THexInputLine = Object (TInputLine)
                   Link : PInputLine;
                   function DataSize: Word; virtual;
                   procedure SetData(var Rec); virtual;
                   procedure GetData(var Rec); virtual;
                   constructor Init(var Bounds: TRect; AMaxLen: Integer;ALink :PView);
                   procedure HandleEvent( var Event : TEvent);Virtual;
                  End;
{����������������������������������������������������������������������������}
  PHeapView = ^THeapView;
  THeapView = object(TView)
    OldMem : LongInt;
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    procedure Update;
  end;
{����������������������������������������������������������������������������}
  PClockView = ^TClockView;
  TClockView = object(TView)
    Refresh: Byte;
    LastTime: DateTime;
    TimeStr: string[10];
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    function FormatTimeStr(H, M, S: Word): String; virtual;
    procedure Update; virtual;
  end;
{����������������������������������������������������������������������������}
  PCzechView = ^TCzechView;
  TCzechView = object(TView)
    Typ : string[2];
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    procedure Update; virtual;
  end;
{����������������������������������������������������������������������������}
implementation

uses Variable, Czech;
{����������������������������������������������������������������������������}
constructor TDriveListBox.Init;
Begin
  TListBox.Init(Bounds,ANumCols,AScrollBar);
End;
{����������������������������������������������������������������������������}
Procedure TDriveListBox.HandleEvent;
Var I : Integer;
    S : String;
Begin
  TListBox.HandleEvent(Event);
  If Event.What=evKeyDown Then
   Case Upcase(Event.CharCode) Of
    'A'..'Z' : Begin
                 For I:=0 To Range-1 Do
                  Begin
                   S:=GetText(I,1);
                   If Upcase(S[1])=Upcase(Event.CharCode) Then
                     Begin
                      FocusItem(I);
                      Event.What := EvCommand;Event.Command := CmOk;
                      PutEvent(Event);ClearEvent(Event);
                     End;
                  End;
               End;
    End;
End;
{����������������������������������������������������������������������������}
constructor THexInputLine.Init;
Begin
  TView.Init(Bounds);
  Link := PInputLine(Alink);
  State := State or sfCursorVis;
  Options := Options or (ofSelectable + ofFirstClick + ofVersion20);
  MaxLen := AMaxLen;
  Data := Link^.Data;
End;
{����������������������������������������������������������������������������}
function THexInputLine.DataSize;
Begin
 DataSize := 0;
End;
{����������������������������������������������������������������������������}
procedure THexInputLine.SetData;
Begin
End;
{����������������������������������������������������������������������������}
procedure THexInputLine.GetData;
Begin
End;
{����������������������������������������������������������������������������}
procedure THexInputLine.HandleEvent;
Begin
 Inherited HandleEvent (Event);
End;
{����������������������������������������������������������������������������}
constructor THeapView.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  OldMem := 0;
end;
{����������������������������������������������������������������������������}
procedure THeapView.Draw;
var
  S: String;
  B: TDrawBuffer;
  C: Byte;
begin
  OldMem := MemAvail;
  Str(OldMem:Size.X, S);
  C := GetColor(2);
  MoveChar(B, ' ', C, Size.X);
  MoveStr(B, S, C);
  WriteLine(0, 0, Size.X, 1, B);
end;
{����������������������������������������������������������������������������}
procedure THeapView.Update;
begin
  if (OldMem <> MemAvail) then DrawView;
end;
{����������������������������������������������������������������������������}
function LeadingZero(w: Word): String;
var s: String;
begin
  Str(w:0, s);
  LeadingZero := Copy('00', 1, 2 - Length(s)) + s;
end;
{����������������������������������������������������������������������������}
constructor TClockView.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  FillChar(LastTime, SizeOf(LastTime), #$FF);
  TimeStr := '';
  Refresh := 1;
end;
{����������������������������������������������������������������������������}
procedure TClockView.Draw;
var
  B: TDrawBuffer;
  C: Byte;
begin
  C := GetColor(2);
  MoveChar(B, ' ', C, Size.X);
  If Configuration.System.ShowClock Then MoveStr(B, TimeStr, C);
  WriteLine(0, 0, Size.X, 1, B);
end;
{����������������������������������������������������������������������������}
procedure TClockView.Update;
var
  h,m,s,hund: word;
begin
  GetTime(h,m,s,hund);
  if Abs(s - LastTime.sec) >= Refresh then
  begin
    with LastTime do
    begin
      Hour := h;
      Min := m;
      Sec := s;
    end;
    TimeStr := FormatTimeStr(h, m, s);
    DrawView;
  end;
end;
{����������������������������������������������������������������������������}
function TClockView.FormatTimeStr(H, M, S: Word): String;
begin
  FormatTimeStr := LeadingZero(h)+ ':'+ LeadingZero(m) +
    ':' + LeadingZero(s);
end;
{����������������������������������������������������������������������������}
constructor TCzechView.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
end;
{����������������������������������������������������������������������������}
procedure TCzechView.Draw;
var
  B: TDrawBuffer;
  C: Byte;
begin
  C := GetColor(2);
  MoveChar(B, ' ', C, Size.X);
  If Configuration.System.ShowCzechType Then MoveStr(B, Typ, C);
  WriteLine(0, 0, Size.X, 1, B);
end;
{����������������������������������������������������������������������������}
procedure TCzechView.Update;
var
  h,m,s,hund: word;
begin
    If KeyboardType Then Typ := 'CZ' Else Typ := 'EN';
    DrawView;
end;
{����������������������������������������������������������������������������}
constructor TLongScrollBar.Init(var Bounds: TRect);
const
  VChars: TScrollChars = (#30, #31, #177, #254, #178);
  HChars: TScrollChars = (#17, #16, #177, #254, #178);
Var   I : Integer;
begin
  TView.Init(Bounds);
  Value := 0;
  Min := 0;
  Max := 0;
  PgStep := 1;
  ArStep := 1;
  if Size.X = 1 then
  begin
    GrowMode := gfGrowLoX + gfGrowHiX + gfGrowHiY;
    Chars := VChars;
  end else
  begin
    GrowMode := gfGrowLoY + gfGrowHiX + gfGrowHiY;
    Chars := HChars;
  end;
end;
{����������������������������������������������������������������������������}
constructor TLongScrollBar.Load(var S: TStream);
begin
  TView.Load(S);
  S.Read(Value, SizeOf(Longint) * 5 + SizeOf(TScrollChars));
end;
{����������������������������������������������������������������������������}
procedure TLongScrollBar.Draw;
begin
  DrawPos(GetPos);
end;
{����������������������������������������������������������������������������}
procedure TLongScrollBar.DrawPos(Pos: Longint);
var
  S: Longint;
  B: TDrawBuffer;
begin
  S := GetSize - 1;
  MoveChar(B[0], Chars[0], GetColor(2), 1);
  if Max = Min then
    MoveChar(B[1], Chars[4], GetColor(1), S - 1)
  else
  begin
    MoveChar(B[1], Chars[2], GetColor(1), S - 1);
    MoveChar(B[Pos], Chars[3], GetColor(3), 1);
  end;
  MoveChar(B[S], Chars[1], GetColor(2), 1);
  WriteBuf(0, 0, Size.X, Size.Y, B);
end;
{����������������������������������������������������������������������������}
function TLongScrollBar.GetPalette: PPalette;
const
  P: String[Length(CScrollBar)] = CScrollBar;
begin
  GetPalette := @P;
end;
{����������������������������������������������������������������������������}
function TLongScrollBar.GetPos: Longint;
var
  R: Longint;
begin
  R := Max - Min;
  if R = 0 then
    GetPos := 1 else
    GetPos := LongDiv(LongMul(Value - Min, GetSize - 3) + R shr 1, R) + 1;
end;
{����������������������������������������������������������������������������}
function TLongScrollBar.GetSize: Longint;
var
  S: Longint;
begin
  if Size.X = 1 then S := Size.Y else S := Size.X;
  if S < 3 then GetSize := 3 else GetSize := S;
end;
{����������������������������������������������������������������������������}
procedure TLongScrollBar.HandleEvent(var Event: TEvent);
var
  Tracking: Boolean;
  I, P, S, ClickPart: Integer;
  Mouse: TPoint;
  Extent: TRect;

function GetPartCode: Integer;
var
  Mark, Part: Integer;
begin
  Part := -1;
  if Extent.Contains(Mouse) then
  begin
    if Size.X = 1 then Mark := Mouse.Y else Mark := Mouse.X;
    if Mark = P then Part := sbIndicator else
    begin
      if Mark < 1 then Part := sbLeftArrow else
        if Mark < P then Part := sbPageLeft else
          if Mark < S then Part := sbPageRight else
            Part := sbRightArrow;
      if Size.X = 1 then Inc(Part, 4);
    end;
  end;
  GetPartCode := Part;
end;

procedure Clicked;
begin
  Message(Owner, evBroadcast, cmScrollBarClicked, @Self);
end;

begin
  TView.HandleEvent(Event);
  case Event.What of
    evMouseDown:
      begin
        Clicked;
        MakeLocal(Event.Where, Mouse);
        GetExtent(Extent);
        Extent.Grow(1, 1);
        P := GetPos;
        S := GetSize - 1;
        ClickPart := GetPartCode;
        if ClickPart <> sbIndicator then
        begin
          repeat
            MakeLocal(Event.Where, Mouse);
            if GetPartCode = ClickPart then
              SetValue(Value + ScrollStep(ClickPart));
          until not MouseEvent(Event, evMouseAuto);
        end else
        begin
          repeat
            MakeLocal(Event.Where, Mouse);
            Tracking := Extent.Contains(Mouse);
            if Tracking then
            begin
              if Size.X = 1 then I := Mouse.Y else I := Mouse.X;
              if I <= 0 then I := 1;
              if I >= S then I := S - 1;
            end else I := GetPos;
            if I <> P then
            begin
              DrawPos(I);
              P := I;
            end;
          until not MouseEvent(Event, evMouseMove);
          if Tracking and (S > 2) then
          begin
            Dec(S, 2);
            SetValue(LongDiv(LongMul(P - 1, Max - Min) + S shr 1, S) + Min);
          end;
        end;
        ClearEvent(Event);
      end;
    evKeyDown:
      if State and sfVisible <> 0 then
      begin
        ClickPart := sbIndicator;
        if Size.Y = 1 then
          case CtrlToArrow(Event.KeyCode) of
            kbLeft: ClickPart := sbLeftArrow;
            kbRight: ClickPart := sbRightArrow;
            kbCtrlLeft: ClickPart := sbPageLeft;
            kbCtrlRight: ClickPart := sbPageRight;
            kbHome: I := Min;
            kbEnd: I := Max;
          else
            Exit;
          end
        else
          case CtrlToArrow(Event.KeyCode) of
            kbUp: ClickPart := sbUpArrow;
            kbDown: ClickPart := sbDownArrow;
            kbPgUp: ClickPart := sbPageUp;
            kbPgDn: ClickPart := sbPageDown;
            kbCtrlPgUp: I := Min;
            kbCtrlPgDn: I := Max;
          else
            Exit;
          end;
        Clicked;
        if ClickPart <> sbIndicator then I := Value + ScrollStep(ClickPart);
        SetValue(I);
        ClearEvent(Event);
      end;
  end;
end;
{����������������������������������������������������������������������������}
procedure TLongScrollBar.ScrollDraw;
begin
  Message(Owner, evBroadcast, cmScrollBarChanged, @Self);
end;
{����������������������������������������������������������������������������}
function TLongScrollBar.ScrollStep(Part: Longint): Longint;
var
  Step: Longint;
begin
  if Part and 2 = 0 then Step := ArStep else Step := PgStep;
  if Part and 1 = 0 then ScrollStep := -Step else ScrollStep := Step;
end;
{����������������������������������������������������������������������������}
procedure TLongScrollBar.SetParams(AValue, AMin, AMax, APgStep,
  AArStep: Longint);
var
  SValue: Longint;
begin

  if AMax < AMin then AMax := AMin;
  if AValue < AMin then AValue := AMin;
  if AValue > AMax then AValue := AMax;
  SValue := Value;
  if (SValue <> AValue) or (Min <> AMin) or (Max <> AMax) then
  begin
    Value := AValue;
    Min := AMin;
    Max := AMax;
    DrawView;
    if SValue <> AValue then ScrollDraw;
  end;
  PgStep := APgStep;
  ArStep := AArStep;
end;
{����������������������������������������������������������������������������}
procedure TLongScrollBar.SetRange(AMin, AMax: Longint);
begin
  SetParams(Value, AMin, AMax, PgStep, ArStep);
end;
{����������������������������������������������������������������������������}
procedure TLongScrollBar.SetStep(APgStep, AArStep: Longint);
begin
  SetParams(Value, Min, Max, APgStep, AArStep);
end;
{����������������������������������������������������������������������������}
procedure TLongScrollBar.SetValue(AValue: Longint);
begin
  SetParams(AValue, Min, Max, PgStep, ArStep);
end;
{����������������������������������������������������������������������������}
procedure TLongScrollBar.Store(var S: TStream);
begin
  TView.Store(S);
  S.Write(Value, SizeOf(Longint) * 5 + SizeOf(TScrollChars));
end;
{����������������������������������������������������������������������������}

end.