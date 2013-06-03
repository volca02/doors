Unit SetFont;
Interface

Procedure LoadFont;
Implementation
Uses Dos;
Type TFont=Array[1..4096] Of Byte;

{$F+,S-,W-}
Procedure LoadFont;
Const CFont : TFont = ({$I kamenic.inc});
Var   F     : File;
      R     : Registers;
Begin
R.Ax:=$1100;
R.bx:=$1000;
R.Bp:=Ofs(CFont);
R.Cx:=256;
R.Dx:=0;
R.es:=Seg(CFont);
Intr($10,R);
End;
{$F-,S+}

End.