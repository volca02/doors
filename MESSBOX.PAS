unit MessBox;

{$O+,F+,X+,I-,S-}

interface

uses Objects, Dialogs;
type
    PInfoDialog = ^TInfoDialog;
    TInfoDialog = Object(TDialog)
                   Text : PStaticText;
                   procedure ChangeBounds(var Bounds: TRect); virtual;
                   Procedure Update ( S : String);
                  End;
const

{ Message box classes }

  mfWarning      = $0000;       { Display a Warning box }
  mfError        = $0001;       { Dispaly a Error box }
  mfInformation  = $0002;       { Display an Information Box }
  mfConfirmation = $0003;       { Display a Confirmation Box }

  mfInsertInApp  = $0080;       { Insert message box into application }
                                { instead of the Desktop }

{ Message box button flags }

  mfYesButton    = $0100;       { Put a Yes button into the dialog }
  mfNoButton     = $0200;       { Put a No button into the dialog }
  mfOKButton     = $0400;       { Put an OK button into the dialog }
  mfCancelButton = $0800;       { Put a Cancel button into the dialog }

  mfYesNoCancel  = mfYesButton + mfNoButton + mfCancelButton;
                                { Standard Yes, No, Cancel dialog }
  mfOKCancel     = mfOKButton + mfCancelButton;
                                { Standard OK, Cancel dialog }

{ MessageBox displays the given string in a standard sized      }
{ dialog box. Before the dialog is displayed the Msg and Params }
{ are passed to FormatStr.  The resulting string is displayed   }
{ as a TStaticText view in the dialog.                          }

function MessageBox(const Msg: String; Params: Pointer;
  AOptions: Word): Word;

function InfoBox(ATitle, S : String): PInfoDialog;

{ MessageBoxRec allows the specification of a TRect for the     }
{ message box to occupy.                                        }

function MessageBoxRect(var R: TRect; const Msg: String; Params: Pointer;
  AOptions: Word): Word;

{ InputBox displays a simple dialog that allows the user to     }
{ type in a string.                                             }

function InputBox(const Title, ALabel: String; var S: String;
  Limit: Byte; HiNumber : Word): Word;

{ InputBoxRect is like InputBox but allows the specification of }
{ a rectangle.                                                  }

function InputBoxRect(var Bounds: TRect; const Title, ALabel: String;
  var S: String;  Limit: Byte; HiNumber : Word): Word;

implementation

uses Drivers, Views,  App;

function MessageBox(const Msg: String; Params: Pointer;
  AOptions: Word): Word;
var
  R: TRect;
  X : Word;
  Y : Word;
  Counter : Word;
  I : Integer;
begin
 Counter := 0;X:= 0;Y := 0;
 For I:=1 To Length(Msg) Do
   Begin
    If Counter > X Then X:=Counter;
    If Msg[I]=#13 Then Begin
                        Counter:=0;
                        Inc(Y)
                       End;
   If (Msg[I]<>#3) And (Msg[I]<>#13) Then Inc(Counter);
   End;
  R.Assign(0, 0, X + 6, Y + 7);
  if AOptions and mfInsertInApp = 0 then
    R.Move((Desktop^.Size.X - R.B.X) div 2, (Desktop^.Size.Y - R.B.Y) div 2)
  else R.Move((Application^.Size.X - R.B.X) div 2, (Application^.Size.Y - R.B.Y) div 2);
  MessageBox := MessageBoxRect(R, Msg, Params, AOptions);
end;

function InfoBox;
var
  R: TRect;
  X : Word;
  Y : Word;
  Counter : Word;
  I : Integer;
  D : PInfoDialog;
  C : PView;
begin
 Counter := 0;X:= 0;Y := 0;
 For I:=1 To Length(S) Do
   Begin
    If S[I]=#13 Then Begin
                        Counter:=0;
                        Inc(Y)
                       End;
   If (S[I]<>#3) And (S[I]<>#13) Then Inc(Counter);
   If Counter > X Then X:=Counter;
   End;
  If X<Length(ATitle) Then X := Length(ATitle);
  R.Assign(0, 0, X + 10, Y + 5);
  R.Move((Application^.Size.X - R.B.X) div 2, (Application^.Size.Y - R.B.Y) div 2);
  D := New(PInfoDialog,Init(R,ATitle));
  D^.State := sfVisible + sfShadow;
  D^.Flags := 0;
  D^.Options := OfFramed + OfCentered;
  With D^ Do Begin
              R.Assign(2,2,Size.X-2,Size.Y-2);
              Text := New(PStaticText,Init(R,S));
              Insert(Text);
             End;
  Application^.InsertWindow(PWindow(D));
  InfoBox := D;
end;

function MessageBoxRect(var R: TRect; const Msg: String; Params: Pointer;
  AOptions: Word): Word;
const
  ButtonName: array[0..3] of string[6] =
    ('~A~no', '~N~e', 'O~K~', '~Z~rusit');
  Commands: array[0..3] of word =
    (cmYes, cmNo, cmOK, cmCancel);
  Titles: array[0..3] of string[11] =
    ('Varovani','Chyba','Informace','Potvrzeni');
var
  I, X, ButtonCount: Integer;
  Dialog: PDialog;
  Control: PView;
  ButtonList: array[0..4] of PView;
  S: String;
begin
  Dialog := New(PDialog,
    Init(R, Titles[AOptions and $3]));
  with Dialog^ do
  begin
    R.Assign(3, 2, Size.X - 2, Size.Y - 3);
    FormatStr(S, Msg, Params^);
    Control := New(PStaticText, Init(R, S));
    Insert(Control);
    X := -2;
    ButtonCount := 0;
    for I := 0 to 3 do
      if AOptions and ($0100 shl I) <> 0 then
      begin
        R.Assign(0, 0, 10, 2);
        Control := New(PButton, Init(R, ButtonName[I], Commands[i],
          bfNormal));
        Inc(X, Control^.Size.X + 2);
        ButtonList[ButtonCount] := Control;
        Inc(ButtonCount);
      end;
    X := (Size.X - X) shr 1;
    for I := 0 to ButtonCount - 1 do
    begin
      Control := ButtonList[I];
      Insert(Control);
      Control^.MoveTo(X, Size.Y - 3);
      Inc(X, Control^.Size.X + 2);
    end;
    SelectNext(False);
  end;
  Dialog^.HelpCtx := Application^.HelpCtx;
  if AOptions and mfInsertInApp = 0 then
    MessageBoxRect := DeskTop^.ExecView(Dialog)
  else MessageBoxRect := Application^.ExecView(Dialog);
  Dispose(Dialog, Done);
end;

function InputBox(const Title, ALabel: String; var S: String;
  Limit: Byte; HiNumber : Word): Word;
var
  R: TRect;
  Len : Byte;
begin
  If Length(ALabel)>Length(Title) Then Len := Length(ALabel)
    Else Len := Length(Title);
  R.Assign(0, 0, Len + 13, 8);
  R.Move((Application^.Size.X - R.B.X) div 2, (Application^.Size.Y - R.B.Y) div 2);
  InputBox := InputBoxRect(R, Title, ALabel, S, Limit, HiNumber);
end;

function InputBoxRect(var Bounds: TRect; const Title, ALabel: String;
  var S: String;  Limit: Byte; HiNumber : Word): Word;
var
  Dialog: PDialog;
  Control: PView;
  R: TRect;
  C: Word;
  H : Phistory;
  Half : Word;
begin
  Dialog := New(PDialog, Init(Bounds, Title));
  with Dialog^ do
  begin
    R.Assign(4 , 3, Size.X - 6, 4);
    Control := New(PInputLine, Init(R, Limit));
    Insert(Control);

    R.Assign(Size.X-6, 3 ,Size.X-3, 4);
    H:=New(PHistory,Init(R,PInputLine(Control),HiNumber));
    Insert(H);

    R.Assign(3, 2, 4 + CStrLen(ALabel), 3);
    Insert(New(PLabel, Init(R, ALabel, Control)));

    Half := Size.X Div 2;
    R.Assign(Half-12, Size.Y - 3, Half-2, Size.Y - 1);
    Insert(New(PButton, Init(R, '~A~no', cmOk, bfDefault)));
    Inc(R.A.X, 12); Inc(R.B.X, 12);
    Insert(New(PButton, Init(R, '~Z~rusit', cmCancel, bfNormal)));
    Inc(R.A.X, 12); Inc(R.B.X, 12);
    SelectNext(False);
  end;
  Dialog^.SetData(S);
  C := Application^.ExecView(Dialog);
  if C <> cmCancel then Dialog^.GetData(S);
  Dispose(Dialog, Done);
  InputBoxRect := C;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TInfoDialog.ChangeBounds;
Begin
 SetBounds(Bounds);
 Origin.X := (Owner^.Size.X - Size.X) div 2;
 Origin.Y := (Owner^.Size.Y - Size.Y) div 2;
 Application^.DrawView;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TInfoDialog.Update;
Var Counter,I,X,Y : Word;
    R : Trect;
Begin
  Counter := 0;X:= 0;Y := 0;
  For I:=1 To Length(S) Do
   Begin
    If S[I]=#13 Then Begin
                        Counter:=0;
                        Inc(Y)
                       End;
   If (S[I]<>#3) And (S[I]<>#13) Then Inc(Counter);
   If Counter > X Then X:=Counter;
   End;
  R.Assign(0, 0, X + 10, Y + 5);
  Options := OfFramed + OfCentered;
  If Text^.Text<>Nil Then DisposeStr(Text^.Text);
  Text^.Text := NewStr(S);
  ChangeBounds(R);
  Text^.Draw;
  Draw;
  Application^.ReDraw;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
end.
