Uses App , Gauges, Dialogs, Views, Objects,Crt;
Var X:TApplication;
Type
    TFileCopy = Object(TView)
                ReadGauge, WriteGauge : PBarGauge;
                Procedure Copy(S1,S2:String);
               End;
Procedure TFileCopy.Copy;
Type
    PCopyBuffer = ^TCopyBuffer;
    TCopyBuffer = Array[1..$FFFF] Of Byte;
Const Two : Boolean = False;
Var
  D    : PDialog;
  C    : PBarGauge;
  R    : TRect;
  _DataPtr : Pointer;
  I:Integer;
  FromF, ToF: file;
  NumRead, NumWritten: Word;
  Buffer : PCopyBuffer;
  BUffer2 : PCopyBuffer;

begin
  R.Assign(0,0,40,9);
  D:=New(PDialog,Init(R,'Kopirovani Souboru'));
  D^.Options:=(D^.Options Or ofCentered);
  with D^ do
       begin
          R.Assign(1,1,Size.X-1,2);
          ReadGauge:=New(PBarGauge,Init(R,100));
          Insert(ReadGauge);
          R.Assign(1,3,Size.X-1,4);
          WriteGauge:=New(PBarGauge,Init(R,100));
          Insert(WriteGauge);

          SelectNext(False);
       end;
   _DataPtr:=NIL;
   Application^.InsertWindow(D);
New(Buffer);New(Buffer2);
  Assign(FromF, S1);   { Otevıi vstupn¡ soubor }
  Reset(FromF, 1);              { Velikost z znamu = 1 }
  Assign(ToF, S2);     { Otevıi vìstupn¡ soubor }
  Rewrite(ToF, 1);              { Velikost z znamu = 1 }
  ReadGauge^.MaxValue:=FileSize(FromF);
  WriteGauge^.MaxValue:=FileSize(FromF);
  repeat
    Two:=False;
    BlockRead(FromF, Buffer^, SizeOf(Buffer^), NumRead);
    ReadGauge^.AddProgress(Numread);
    If Numread=SizeOf(Buffer^) Then
    Begin BlockRead(FromF, Buffer2^, SizeOf(Buffer2^), NumRead);
    Two:=True;
    ReadGauge^.AddProgress(Numread);
    End;
    If Not Two Then Begin
                     BlockWrite(ToF, Buffer^, NumRead, NumWritten);
                     WriteGauge^.AddProgress(NumWritten);
                    End
    Else Begin
         BlockWrite(ToF, Buffer^, SizeOf(Buffer^), NumWritten);
         WriteGauge^.AddProgress(NumWritten);
         BlockWrite(ToF, Buffer2^, NumRead, NumWritten);
         WriteGauge^.AddProgress(NumWritten);
         End;
  until (NumRead = 0) or (NumWritten <> NumRead);
  Close(FromF);
  Close(ToF);
D^.Close;
Dispose(Buffer);Dispose(Buffer2);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Var C:TFileCopy;
Begin
X.Init;
C.Copy('AKTUAL.RAR','D:\!!.$$$');
X.Run;
X.Done;
End.