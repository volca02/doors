Uses Reader,Crt;
Type
    PBuffer=^TBuffer;
    TBuffer=Array[1..512] Of Char;
Var Buffer:PBuffer;
    I:Integer;
Begin
Clrscr;
New(Buffer);
DosReadSector($FFA0000,2,Buffer);
For I:=1 To 512 Do If Ord(Buffer^[I])>32 Then Write(Buffer^[I])
   Else Write('.');
If Error Then Write(#7);
Dispose(Buffer);

End.