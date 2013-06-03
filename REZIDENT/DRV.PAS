Program Drivers;
Uses Dos,Crt,Base;

Const  BlockDriver = $8000;
Type

   PMCB  = ^TMCB;
   TMCB  = Record
              Typ : Byte;
              PSP : Word;
              Size : Word;
             End;
   PPSPData = Array[1..$8000] Of Char;
Var R:Registers;
    MCB : PMCB;
    U : ^Word;
    PSPData : Pointer;
    Env : ^PPSpData;
    I,X : Word;
Begin
Clrscr;
R.Ah:=$52;
Msdos(R);
U:=Ptr(R.es,R.bx-2);
MCB:=Ptr(U^,0);
IF MCB^.Typ<>Ord('M') Then Writeln(#7+'CHYBA NENI TO MCB Block');
U:=Ptr(MCB^.PSP,$2c);Env:=Ptr(U^,0);
I:=1;
While (Env^[I]<>#0) And (Env^[I+1]<>#0) And (Env^[I+2]<>#0) And (Env^[I+3]<>#1) Do Inc(I);
Inc (I,4);X:=I;
While Env^[I]<>#0 Do Begin Write(Env^[I]);Inc(I);End;
While (Env^[I]<>#0) And (Env^[I+1]<>#0) And (Env^[I+2]<>#0) And (Env^[I+3]<>#1) Do Inc(I);
Inc (I,4);X:=I;
While Env^[I]<>#0 Do Begin Write(Env^[I]);Inc(I);End;
While (Env^[I]<>#0) And (Env^[I+1]<>#0) And (Env^[I+2]<>#0) And (Env^[I+3]<>#1) Do Inc(I);
Inc (I,4);X:=I;
While Env^[I]<>#0 Do Begin Write(Env^[I]);Inc(I);End;
While (Env^[I]<>#0) And (Env^[I+1]<>#0) And (Env^[I+2]<>#0) And (Env^[I+3]<>#1) Do Inc(I);
Inc (I,4);X:=I;
While Env^[I]<>#0 Do Begin Write(Env^[I]);Inc(I);End;
While (Env^[I]<>#0) And (Env^[I+1]<>#0) And (Env^[I+2]<>#0) And (Env^[I+3]<>#1) Do Inc(I);
Inc (I,4);X:=I;
While Env^[I]<>#0 Do Begin Write(Env^[I]);Inc(I);End;
While (Env^[I]<>#0) And (Env^[I+1]<>#0) And (Env^[I+2]<>#0) And (Env^[I+3]<>#1) Do Inc(I);
Inc (I,4);X:=I;
While Env^[I]<>#0 Do Begin Write(Env^[I]);Inc(I);End;
End.