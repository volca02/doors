Uses App , Gauges, Dialogs, Views, Objects,Crt;
Var X:TApplication;
  D    : PDialog;
  C    : PBarGauge;
  R    : TRect;
  _DataPtr : Pointer;
  I:Integer;

function About: Word;
begin
  R.Assign(0,0,50,9);
  D:=New(PDialog,Init(R,'Kpirovani Souboru'));
  D^.Options:=(D^.Options Or ofCentered);
  with D^ do
       begin
          R.Assign(1,1,Size.X-1,2);
          C:=New(PBarGauge,Init(R,100));
          Insert(C);
          SelectNext(False);
       end;

   _DataPtr:=NIL;
   Application^.InsertWindow(D);
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}

Begin
X.Init;
About;
For I:=1 To 100 Do
Begin
C^.UpDate(I);
Delay(10);
End;
X.Run;
X.Done;
End.