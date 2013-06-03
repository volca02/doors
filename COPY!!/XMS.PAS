Unit XMS;

Interface
 Var
   XMSError: Byte;
   XMSAddr : Pointer;
   IsXMS   : Boolean;

  Function XMSDriverLoaded: Boolean;
  Function XMSMemAvail    : Word;
  Function XMSMaxAvail    : Word;
  Function XMSAllocateBlock( SizeKB: Word ): Word;
  Function XMSReleaseBlock( Handle: Word ): Boolean;
  Function XMSStoreData( Addr     : Pointer;
                         Size     : LongInt;
                         XMSHandle: Word;
                         XMSOffset: LongInt ): Boolean;
  Function XMSGetData( XMSHandle: Word;
                       XMSOffset: LongInt;
                       Size     : LongInt;
                       Addr     : Pointer ): Boolean;

Implementation

 Type
  XMSMoveStruct = Record
   MoveLen: LongInt; { Bytes }
   Case Integer of
    0: ( SHandle: Word;    { Konven‡n¡ pamˆŸ = 0 }
         SPtr   : Pointer; { Zdroj. adr. }
         XMSHndl: Word;    { p©¡st. ‡¡slo }
         XMSOffs: LongInt; { 32-bit offs pro XMS }
       );
    1: ( XMSH   : Word;    { p©¡st. ‡¡slo XMS }
         XMSOfs : LongInt; { 32-bit offs pro XMS }
         DHandle: Word;    { p©¡st. ‡¡slo XMS, 0=konv. }
         DPtr   : Pointer; { Adr. v konv. }
       );
  end;

 Var
  MoveParms: XMSMoveStruct;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

 Function XMSDriverLoaded; { Test ovlada‡e, nastav¡ XMSAddr vst. bodu }
  Const
   HiMemSeg: Word = 0;
   HiMemOfs: Word = 0;
  Begin
   XMSError:= 0;
   Asm
    Mov AX, $4300;
    Int $2F;
    Cmp AL,$80;
    JNE @1;
    Mov AX,$4310;
    Int $2F;
    Mov HiMemOfs,BX;
    Mov HiMemSeg,ES;
   @1:
   End;
   XMSDriverLoaded:= ( HiMemSeg<>0 );
   XMSAddr:= Ptr( HiMemSeg, HiMemOfs );
  End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

 Function XMSMemAvail; { Velikost pamˆti XMS }
  Begin
   XMSError:= 0;
   XMSMemAvail:= 0;
   If IsXMS then Begin
    Asm
     Mov AH,8;
     Call XMSAddr;
     Or AX,AX;
     JNZ @1;
     Mov XMSError,BL;  { Nastaven¡ kodu chyby }
     XOr DX,DX;
    @1:
     Mov @Result,DX;       { DX = velikost pamˆti XMS }
    End;
   end;
  End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

 Function XMSMaxAvail; { Velikost nejvˆt¨¡ho souvisl. bloku pamˆti XMS }
  Begin
   XMSError:= 0;
   XMSMaxAvail:= 0;
   If IsXMS then Begin
    Asm
     Mov AH,8;
     Call XMSAddr;
     Or AX,AX;
     JNZ @1;
     Mov XMSError,BL;  { Nastaven¡ kodu chyby }
     XOr DX,DX;
    @1:
     Mov @Result,AX;       { AX = velikost max. bloku XMS }
    End;
   end;
  End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

 Function XMSAllocateBlock; { Vymez¡ blok XMS, vrac¡ p©¡st. ‡¡slo }
  Begin
   XMSError:= 0;
   XMSAllocateBlock:= 0;
   If IsXMS then Begin
    Asm
     Mov AH,9;
     Mov DX,SizeKB;
     Call XMSAddr;
     Or AX,AX;
     JNZ @1;
     Mov XMSError,BL;  { Nastaven¡ kodu chyby }
     XOr DX,DX;
    @1:
     Mov @Result,DX;       { DX = p©¡st. ‡¡slo }
    End;
   end;
  End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

 Function XMSReleaseBlock; { Uvoln¡ blok XMS, vstup p©¡st. ‡¡s., vystup True }
  Var
   OK: Word;
  Begin
   XMSError:= 0;
   XMSReleaseBlock:= False;
   If IsXMS then Begin
    Asm
     Mov AH,$0A;
     Mov DX,Handle;
     Call XMSAddr;
     Or AX,AX;
     JNZ @1;
     Mov XMSError,BL;  { Nastaven¡ kodu chyby }
     XOr DX,DX;
    @1:
     Mov OK,AX;
    End;
    XMSReleaseBlock:= ( OK<>0 );

   end;
  End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

 Function XMSStoreData; { P¨esun dat do pamˆti XMS}
                        {  Data mus¨ b˜t vymezena }
                        {  Addr = adresa v konv. pamˆti. }
                        {  Size = d‚lka v Bytech }
                        {  XMSHandle = p©¡st ‡. }
                        {  XMSOffset = 32bit c¡l. offs. v XMS }
  Var
   Status: Word;
  Begin
   XMSError:= 0;
   XMSStoreData:= False;
   If IsXMS then Begin
    With MoveParms do Begin
     MoveLen:= Size;
     SHandle:= 0;
     SPtr   := Addr;
     XMSHndl:= XMSHandle;
     XMSOffs:= XMSOffset;
    end;
    Asm
     Mov AH,$0B;
     Mov SI, Offset MoveParms;
     Call XMSAddr;
     Mov Status,AX;
     Or AX,AX;
     Jnz @1;
     Mov XMSError,BL;
    @1:
    End;
    XMSStoreData:= ( Status<>0 );
   end;
  End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

 Function XMSGetData; { P¨esun dat z pamˆti XMS}
                      {  Data mus¨ b˜t vymezena a presunuta do XMS}
                      {  XMSHandle = p©¡st ‡. }
                      {  XMSOffset = 32bit c¡l. offs. v XMS }
                      {  Addr = adresa v konv. pamˆti. }
                      {  Size = d‚lka v Bytech }
  Var
   Status: Word;
  Begin
   XMSError:= 0;
   XMSGetData:= False;
   If IsXMS then Begin
    With MoveParms do Begin
     MoveLen:= Size;
     XMSH   := XMSHandle;
     XMSOfs := XMSOffset;
     DHandle:= 0;
     DPtr   := Addr;
    end;
    Asm
     Mov AH,$0B;
     Mov SI, Offset MoveParms;
     Call XMSAddr;
     Mov Status,AX;
     Or AX,AX;
     Jnz @1;
     Mov XMSError,BL;
    @1:
    End;
    XMSGetData:= ( Status<>0 );
   end;
  End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

 Begin
  XMSAddr := Nil;
  XMSError:= 0;
  IsXMS   := XMSDriverLoaded;
 End.