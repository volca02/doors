unit NewViews;

{$F+,O+,S-,D-,Q-}

interface

uses Dos, Objects, Views, App, Dialogs, Drivers;

type
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
end.