unit NewViews;

{$F+,O+,S-,D-,Q-}

interface

uses Dos, Objects, Views, App, Dialogs, Drivers;

type
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  PDriveListBox = ^TDriveListBox;
  TDriveListBox = Object(TListBox)
                   constructor Init(var Bounds: TRect; ANumCols: Word; AScrollBar:PScrollBar);
                   procedure HandleEvent(var Event: TEvent); virtual;
                  End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  PHexInputLine = ^THexInputLine;
  THexInputLine = Object (TInputLine)
                   Link : PInputLine;
                   constructor Init(var Bounds: TRect; AMaxLen: Integer;ALink :PView);
                   procedure HandleEvent( var Event : TEvent);Virtual;
                  End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  PHeapView = ^THeapView;
  THeapView = object(TView)
    OldMem : LongInt;
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    procedure Update;
  end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
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
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  PCzechView = ^TCzechView;
  TCzechView = object(TView)
    Typ : string[2];
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    procedure Update; virtual;
  end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
implementation

uses Variable, Czech;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
constructor TDriveListBox.Init;
Begin
  TListBox.Init(Bounds,ANumCols,AScrollBar);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
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
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
constructor THexInputLine.Init;
Begin
  TView.Init(Bounds);
  Link := PInputLine(Alink);
  State := State or sfCursorVis;
  Options := Options or (ofSelectable + ofFirstClick + ofVersion20);
  MaxLen := AMaxLen;
  Data := Link^.Data;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure THexInputLine.HandleEvent;
Begin
 Inherited HandleEvent (Event);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
constructor THeapView.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  OldMem := 0;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
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
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure THeapView.Update;
begin
  if (OldMem <> MemAvail) then DrawView;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function LeadingZero(w: Word): String;
var s: String;
begin
  Str(w:0, s);
  LeadingZero := Copy('00', 1, 2 - Length(s)) + s;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
constructor TClockView.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  FillChar(LastTime, SizeOf(LastTime), #$FF);
  TimeStr := '';
  Refresh := 1;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
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
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
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
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function TClockView.FormatTimeStr(H, M, S: Word): String;
begin
  FormatTimeStr := LeadingZero(h)+ ':'+ LeadingZero(m) +
    ':' + LeadingZero(s);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
constructor TCzechView.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
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
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TCzechView.Update;
var
  h,m,s,hund: word;
begin
    If KeyboardType Then Typ := 'CZ' Else Typ := 'EN';
    DrawView;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
end.
