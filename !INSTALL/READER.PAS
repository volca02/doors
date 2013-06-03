Unit Reader;
Interface
Uses Dos;
  Const Error:Boolean=False;
  Var SectorData:Array[1..512] Of Byte;
  Procedure ReadSector(Hlava,Stopa,Sector:Byte);
  Procedure WriteSector(Hlava,Stopa,Sector:Byte);
Implementation
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure ReadSector;
Var R:Registers;
Begin
Error:=False;
R.Ah:=$02;
R.Al:=1;
R.Dl:=$0;
R.Dh:=Hlava;
R.Ch:=Stopa;
R.Cl:=Sector;
R.Es:=Seg(SectorData);
R.Bx:=Ofs(SectorData);
Intr($13,R);
 If R.Flags And Fcarry =Fcarry Then Error:=True;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure WriteSector;
Var R:Registers;
Begin
Error:=False;
R.Ah:=$03;
R.Al:=1;
R.Dl:=$0;
R.Dh:=Hlava;
R.Ch:=Stopa;
R.Cl:=Sector;
R.Es:=Seg(SectorData);
R.Bx:=Ofs(SectorData);
Intr($13,R);
 If R.Flags And Fcarry =Fcarry Then Error:=True;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
End.