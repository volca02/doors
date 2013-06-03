Uses Dos,Crt;
Var R:Registers;
Begin
R.Ah:=$16;
Intr($2f,R);
Writeln(R.Al,'    ',R.Ah);
Readkey;
End.