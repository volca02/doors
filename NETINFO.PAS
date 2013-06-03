uses dos,Crt;
Type
    TServerTable = Record
                     Name : Array[1..48] Of Char;
                   End;

     PServersTable = ^TServersTable;
     TServersTable = Array [1..8] Of TServerTable;

Var  R : Registers;

    Vstup : Record
             Length:Word;
             Number:Byte;
            End;
    Vystup : Record
              Length : Word;
              Data   : Array[1..512]Of Char;
             End;

       I:Integer;
  Data : PServersTable;
begin

Clrscr;
Vstup.Length:=2;
Vstup.Number:=$C9;
Vystup.Length:=512;
R.DS:=Seg(Vstup);
R.Si:=Ofs(Vstup);
R.ES:=Seg(Vystup);
R.Di:=Ofs(Vystup);
R.AH:=$E3;
Intr($21,R);
I:=1;
While Vystup.Data[i]<>#0 Do Begin Write(Vystup.Data[I]);Inc(I);End;
Writeln;
While Vystup.Data[i+1]<>#0 Do Begin Write(Vystup.Data[I+1]);Inc(I);End;
writeln;
While Vystup.Data[i+2]<>#0 Do Begin Write(Vystup.Data[I+2]);Inc(I);End;
writeln;
While Vystup.Data[i+3]<>#0 Do Begin Write(Vystup.Data[I+3]);Inc(I);End;
R.Ah:=$Ef;
R.Al:=$04;
Msdos(R);
Data:=Ptr(R.Es,R.Si);
Writeln(#13#10,Data^[1].Name);Writeln(Data^[2].Name);
end.