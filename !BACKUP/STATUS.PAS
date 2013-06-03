unit Status;
{$V-}

interface

uses Drivers, Objects, Views, Dialogs, variable;

const
  cmUpdateGauge = 12000;
  cmResetGauge  = 12001;
  cmAddGauge    = 12002;
  cmUpdateFileInfo = 12003;

type

  PPercentGauge = ^TPercentGauge;
  TPercentGauge = object(TView)
    MaxValue: Longint;
    CurValue: Longint;
    constructor Init(var Bounds: TRect; AMaxValue: Longint);
    procedure Draw; virtual;
    procedure Update(Progress: Longint); virtual;
    procedure AddProgress(Progress: Longint);
    procedure HandleEvent(var Event: TEvent); virtual;
    function SolveForX(Y, Z: Longint): Integer;
    function SolveForY(X, Z: Longint): Integer;
  end;

  PBarGauge = ^TBarGauge;
  TBarGauge = object(TPercentGauge)
    procedure Draw; virtual;
  end;

  PFileInfo = ^TFileInfo;
  TFileInfo = Object(TView)
                Data:PFileRec;
                procedure CalcBounds(var Bounds: TRect;Delta : TPoint); virtual;
                constructor Init(var Bounds: TRect);
                procedure Draw; virtual;
                procedure HandleEvent(var Event: TEvent); virtual;
                destructor Done;virtual;
                private
                 Function GetText : String;Virtual;
              end;

   PColorStaticText = ^TColorStaticText;
   TColorStaticText = Object(TStaticText)
                        Attr : Byte;
                        constructor Init(var Bounds: TRect; AText: String;C : Byte);
                        Procedure Draw;Virtual;
                      end;

   PTeamStatus = ^TTeamStatus;
   TTeamStatus = Object (TView)
                   Position : Word;
                   Text     : PCollection;
                   constructor Init(var Bounds: TRect;Data : PCollection);
                   procedure Draw; virtual;
                 End;
implementation
Uses Base, Dos;

constructor TTeamStatus.Init;
begin
  inherited Init(Bounds);
  Text := Data;
  Position := 0;
end;

procedure TTeamStatus.Draw;
var
  B: TDrawBuffer;
  C: Word;
  S: ^string;
  X: string;
  I: Word;
begin
  For I:=Size.Y-1 DownTo 0 Do
    Begin
      C := GetColor(1);
      MoveChar(B, ' ', C, Size.X);
      WriteLine(0,I,Size.X,1,B);
      If (Text^.Count>0) And (Position-(Size.Y-I-1)<=(Text^.Count-1))
      And (Position-(Size.Y-I-1)>0) Then
        Begin
          S:=Text^.At(Position-(Size.Y-1-I));
          X:=S^;
          C:=Ord(X[1]);Delete(X,1,1);
          MoveStr(B, X, C);
          WriteLine((Size.X Div 2)-(Length(X) Div 2),I,Length(X),1,B);
        End;
    End;
end;

constructor TPercentGauge.Init(var Bounds: TRect; AMaxValue: Longint);
begin
  inherited Init(Bounds);
  EventMask := EventMask or evBroadcast;
  MaxValue := AMaxValue;
  CurValue := 0;
end;

procedure TPercentGauge.Draw;
var
  B: TDrawBuffer;
  C: Word;
  S: string[10];
  PercentDone: Longint;
begin
  C := GetColor(1);
  MoveChar(B, ' ', C, Size.X);
  PercentDone := SolveForY(CurValue, MaxValue);
  FormatStr(S, '%-3d%%', PercentDone);
  MoveStr(B, S, C);
  WriteLine(0,0,Size.X,Size.Y,B);
end;

procedure TPercentGauge.Update(Progress: Longint);
begin
  CurValue := Progress;
  DrawView;
end;

procedure TPercentGauge.AddProgress(Progress: Longint);
begin
  Update(Progress + CurValue);
end;

procedure TPercentGauge.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if Event.What = evBroadcast then
  begin
    case Event.Command of
      cmUpdateGauge :
        begin
          Update(Event.InfoLong);
        end;
      cmResetGauge:
        begin
          MaxValue := Event.InfoLong;
          Update(0);
        end;
      cmAddGauge:
        begin
          AddProgress(Event.InfoLong);
        end;
    end;
  end;
end;


function TPercentGauge.SolveForX(Y, Z: Longint): Integer;
begin
  SolveForX := Trunc( Z * (Y * 0.01) );
end;


function TPercentGauge.SolveForY(X, Z: Longint): Integer;
begin
  if Z = 0 then SolveForY := 0
  else SolveForY := Trunc( (X * 100) / Z );
end;


procedure TBarGauge.Draw;
var
  B: TDrawBuffer;
  C: Word;
  PercentDone: Longint;
  FillSize: Integer;
begin
  C := GetColor(1);
  MoveChar(B, #176, C, Size.X);
  PercentDone := SolveForY(CurValue, MaxValue);
  FillSize := SolveForX(PercentDone, Size.X);
  if FillSize > Size.X then FillSize := Size.X;
  MoveChar(B, #178, C, FillSize);
  WriteLine(0,0,Size.X,Size.Y,B);
end;

Constructor TFileInfo.Init;
Begin
   inherited Init(Bounds);
   EventMask := EventMask or evBroadcast;
   Data := Nil;
End;

destructor TFileInfo.Done;
Begin
  inherited Done;
End;

Procedure TFileInfo.Draw;
Var C : Word;
    B : TDrawBuffer;
Begin
  If Valid(0) Then Begin
                     C := GetColor(6);
                     MoveChar(B, #32, C, Size.X);
                     MoveStr(B,GetText,C);
                     WriteLine(0,0,Size.X,Size.Y,B);
                   End;
End;

Function TFileInfo.GetText;
Var X: PFileRec;
    Name : String [12];
    S: String;
    N : DateTime;
    Year         : String [4];
    Day, Month   : String [2];
    Hour, Min    : String [2];
Begin
  GetText := ''; If X=Nil Then Exit;
  X := Data;Name := X^.Name;
  S := KanonizeFile(Name,X^.Attr);
  S := S + FillToFront(IntToStr(X^.Size),10,#32);
  UnpackTime(X^.Time,N);
  Year := IntToStr(N.Year); Delete(Year,1,2);
  Day  := IntToStr(N.Day); Day := FillToFront(Day,2,'0');
  Month := IntToStr(N.Month); Month := FillToFront(Month,2,'0');
  Hour := IntToStr(N.Hour); Hour := FillToFront(Hour,2,'0');
  Min := IntToStr(N.Min); Min := FillToFront(Min,2,'0');
  S := S + #32 + Day + '.' + Month + '.' + Year + #32 + Hour + ':' + Min;
  If Data<> Nil Then  GetText:=S
   Else GetText := '';
End;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure TFileInfo.CalcBounds;
Begin
  GetBounds(Bounds);
  Bounds.A.Y := Bounds.A.Y + Delta.Y ;
  Bounds.B.Y := Bounds.B.Y + Delta.Y ;
  Bounds.B.X := Bounds.B.X + Delta.X ;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TFileInfo.HandleEvent;
Begin
 inherited HandleEvent(Event);
 If (Event.What = evCommand) and (Event.Command = cmUpdateFileInfo) Then
        begin
          Data := Event.InfoPtr;
          Draw;
        end;
End;

Constructor TColorStaticText.Init;
Begin
 inherited Init(Bounds,AText);
 Attr:=C;
End;

Procedure TColorStaticText.Draw;
var
  Color: Byte;
  Center: Boolean;
  I, J, L, P, Y: Integer;
  B: TDrawBuffer;
  S: String;
begin
  Color := Attr;
  GetText(S);
  L := Length(S);
  P := 1;
  Y := 0;
  Center := False;
  while Y < Size.Y do
  begin
    MoveChar(B, ' ', Color, Size.X);
    if P <= L then
    begin
      if S[P] = #3 then
      begin
        Center := True;
        Inc(P);
      end;
      I := P;
      repeat
        J := P;
        while (P <= L) and (S[P] = ' ') do Inc(P);
        while (P <= L) and (S[P] <> ' ') and (S[P] <> #13) do Inc(P);
      until (P > L) or (P >= I + Size.X) or (S[P] = #13);
      if P > I + Size.X then
        if J > I then P := J else P := I + Size.X;
      if Center then J := (Size.X - P + I) div 2 else J := 0;
      MoveBuf(B[J], S[I], Color, P - I);
      while (P <= L) and (S[P] = ' ') do Inc(P);
      if (P <= L) and (S[P] = #13) then
      begin
        Center := False;
        Inc(P);
        if (P <= L) and (S[P] = #10) then Inc(P);
      end;
    end;
    WriteLine(0, Y, Size.X, 1, B);
    Inc(Y);
  end;
end;

end.