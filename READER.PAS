Unit Reader;
Interface
Uses Dos;
  Type
        PBootSector = ^TBootSector;
        TBootSector = Record
                         Jump                     : Array [1..3] Of Byte;
                         OEM                      : Array [1..8] Of Char;
                         BytesPerSector           : Word;
                         SectorsPerCluster        : Byte;
                         ReservedSectors          : Word;
                         NumberOfFAT              : Byte;
                         RootDirectoryEnteries    : Word;
                         TotalSectors             : Word;
                         MediaDescription         : Byte;
                         SectorsPerFAT            : Word;
                         SectorsPerCylinder       : Word;
                         NumberOfHead             : Word;
                         NumberOfHidenSectors     : Word;

                         NumberOfSpecHidenSectors : Word;
                         BigTotalNumberOfSectors  : Longint;
                         FhyzicDriveNumber        : Word;
                         ExtendetSignature        : Byte;
                         SerialNumber             : Array[1..4] Of Byte;
                         VolumeLabel              : Array[1..12] Of Char;
                         FileSystemId             : Array[1..8] Of Char;
                         OtherData              : Array [1..449] Of Byte;
                       End;

  Const Error:Boolean=False;
  Procedure DOSReadSector(Log:Longint;Drive:Byte;Buffer:Pointer);
  Procedure DOSWriteSector(Log:Longint;Drive:Byte;Buffer:Pointer);
  Procedure ReadSector(P:Pointer;Drive,Hlava,Stopa,Sector:Byte;Pocet:Byte);
  Procedure WriteSector(P:Pointer;Drive,Hlava,Stopa,Sector:Byte;Pocet:Byte);
Implementation
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure DOSReadSector;
Var S,O,SekLo,SekHi:Word;
Begin
 O:=Ofs(Buffer^);S:=Seg(Buffer^);SekLo:=(Log And $FFFF);
 SekHi:=(Log Div $10000);
 Asm
Jmp @Break
@SektorLo:  dw  0
@SektorHi:  dw  0
@Pocet:     dw  0
@Offset:    dw  0
@Segment:   dw  0
@Break:
  push ds
  push ax
  push bx
  push cx
  mov ax,SekLo
  mov Word Ptr [@sektorLo],ax
  mov ax,SekHi
  mov Word Ptr [@sektorHi],ax
  mov ax,1
  mov Word Ptr [@Pocet],ax
  mov ax,O
  mov Word Ptr [@Offset],ax
  mov ax,S
  mov Word Ptr [@Segment],ax
  mov ax,Seg @SektorLo
  mov ds,ax
  mov cx,-1
  mov al,Drive
  mov bx,Offset @SektorLO
  int 25h
  pop bx
  jnc @NoError
  mov Error,True
 @NoError:
  pop cx
  pop bx
  pop ax
  pop ds
 End;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure DOSWriteSector;
Var S,O,SekLo,SekHi:Word;
Begin
 O:=Ofs(Buffer^);S:=Seg(Buffer^);SekLo:=(Log And $FFFF);
 SekHi:=(Log Div $10000);
 Asm
Jmp @Break
@SektorLo:  dw  0
@SektorHi:  dw  0
@Pocet:     dw  0
@Offset:    dw  0
@Segment:   dw  0
@Break:
  push ds
  push ax
  push bx
  push cx
  mov ax,SekLo
  mov Word Ptr [@sektorLo],ax
  mov ax,SekHi
  mov Word Ptr [@sektorHi],ax
  mov ax,1
  mov Word Ptr [@Pocet],ax
  mov ax,O
  mov Word Ptr [@Offset],ax
  mov ax,S
  mov Word Ptr [@Segment],ax
  mov ax,Seg @SektorLo
  mov ds,ax
  mov cx,-1
  mov al,Drive
  mov bx,Offset @SektorLO
  int 25h
  pop bx
  jnc @NoError
  mov Error,True
 @NoError:
  pop cx
  pop bx
  pop ax
  pop ds
 End;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure ReadSector;
Var R:Registers;
Begin
Error:=False;
R.Ah:=$02;
R.Al:=Pocet;
R.Dl:=Drive;
R.Dh:=Hlava;
R.Ch:=Stopa;
R.Cl:=Sector;
R.Es:=Seg(P^);
R.Bx:=Ofs(P^);
Intr($13,R);
 If R.Flags And Fcarry =Fcarry Then Error:=True;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure WriteSector;
Var R:Registers;
Begin
Error:=False;
R.Ah:=$03;
R.Al:=Pocet;
R.Dl:=Drive;
R.Dh:=Hlava;
R.Ch:=Stopa;
R.Cl:=Sector;
R.Es:=Seg(P^);
R.Bx:=Ofs(P^);
Intr($13,R);
 If R.Flags And Fcarry =Fcarry Then Error:=True;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
End.