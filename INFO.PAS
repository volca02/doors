{$O+,F+}
Unit Info;
Interface
Type
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
     TChmosInfo = Record
                   POSTStatus      : Byte;
                   ShutDownStatus  : Byte;
                   FloppyType      : Byte;
                   HardDiskType    : Byte;
                   ByteVybaveni    : Byte;
                   BaseMemory      : Word;
                   ExtendetMemory  : Word;
                   HardDisk0Type   : Byte;
                   HardDisk1Type   : Byte;
                   CRC             : Word;
                   StoletiBCD      : Byte;
                  End;
    TBiosInfo   = Record
                   COM1            : Word;
                   COM2            : Word;
                   COM3            : Word;
                   COM4            : Word;
                   LPT1            : Word;
                   LPT2            : Word;
                   LPT3            : Word;
                   LPT4            : Word;
                   Perifery        : Word;
                   InfraConectError: Byte;
                   Memory          : Word;
                   Reserved        : Word;
                   KeyboardFlags   : Word;
                   AltInput        : Byte;
                   StartBuferAdress: Word;
                   EndBuferAdress  : Word;
                   KeyboardBuffer  : Array [1..20] Of Char;
                   RekalibrFloppy  : Byte;
                   FloppyMotorRun  : Byte;
                   TimeToOffMotor  : Byte;
                   ErrorFloppyStatus : Byte;
                   FloppyControlerInfo : Array [1..7] Of Byte;
                   ActiveVideoMode : Byte;
                 End;
Var ChmosInfo : TChmosInfo;
Const ProcesorType   : Array[0..8] Of String[11] =
                     ('8086/88','80186','NEC V20/V30','80286','80386SX',
                      '80386DX','80486SX','80486DX','Pentium');

      CoprocesorType : Array[0..8] Of String[16] =
                     ('Bez koprocesoru.','8087','80287','80387','80487',
                      '80587','emul쟴or 80287','emul쟴or 80387',
                      'emul쟴or 80487');
      FloppyType : Array[0..4] Of String[5] =
                     ('Zadna','360K','1.2M','720K','1.44M');

Function GetTimer          : Longint;
Procedure GetCHMOSInfo;
Function GetEmsSize        : String;
Function GetXmsSize        : String;
Function GetDOSVersion     : String;
Function GetFloppyType     : String;
Function GetProcesorType   : word;
Function GetProcesorMode   : boolean;
Function GetCoprocesorType : word;
Function GetVideoCardType  : String;
Function GetMouseType      : String;
Function GetBiosDate       : String;
Function GetAdlib          : string;
Function GetSB             : string;
Function GetNovell         : string;
Function GetCDROM          : string;
Function GetHardDiskSize   : string;
Implementation
{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
Uses Base;
Function GetProcesorType : word;External;
Function GetProcesorMode : boolean;External;
Function GetCoprocesorType : word;External;
{$L CPU.OBJ}
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function GetHardDiskSize   : string;
Var Heads    : Byte;
    Cylindrs : Byte;
    Sektors  : Byte;
    HorBits  : Word;
Begin
 asm
 mov ah,08h
 mov dl,80h
 int 13h
 mov Heads,Dh
 mov Cylindrs,Ch
 mov Sektors,Cl
 end;
HorBits:=(Sektors And $C0);
HorBits:=HorBits Shl 2;
HorBits:=HorBits + Cylindrs;
Sektors:= (Sektors And $3f);
GetHardDiskSize:=
   IntToStr((Longint(Sektors)*Longint(HorBits)*Longint(Heads)*512) Div (1024*1024));
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function GetTimer;
Var Lo , Hi : Word;
    X : Longint;
Begin
  Asm
    mov ah,00h
    int 1ah
    mov Lo,dx
    mov Hi,cx
  End;
 X:=(LongInt(Hi)*$10000)+Lo;
 GetTimer := X;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function GetMouseType : String;
Const MouseType : Array [1..5] Of String = ('PS/2','seriova','InPort','PS/2','HP');
Const Ok           : Boolean = True;
Var   Buttons      : Byte;
      VerHi, VerLo : Byte;
      Typ, IRQ     : Byte;
Begin
 Asm
 mov ax,0011h
 int 33h
 mov buttons,bl
 cmp ax,0ffffh
 je @Good
 mov ok,false
@Good:
 mov ax,0024h
 int 33h
 mov VerHi,Bh
 mov VerLo,Bl
 mov typ,ch
 mov irq,cl
 cmp ax,0ffffh
 jne @Good2
 mov ok,false
@Good2:
 End;
If Ok Then GetMouseType:=MouseType[Typ] + ', '+
                         Chr(Buttons+48) + ' - tlacitkova, verze '+
           Char(verhi shr 4+48) +Char(verhi and $f+48)+'.'
          +Char(verlo shr 4+48) +Char(verlo and $f+48)
 Else GetMouseType:='Microsoft mouse';
End;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function GetDOSVersion;
var
 verze  : word;
 s      : string[5];
begin
  asm
           mov ah, 30h
           int 21h
           mov verze, ax
           cmp al, 0
           jne @dal
           mov verze, 0100h
     @dal: cmp cx, 0
           je @end
           mov verze, 200h
     @end:
  end;
  s:= Char(verze and $FF div 10+48) +Char(verze and $FF mod 10+48)+'.'
     +Char(verze shr 8 div 10+48)+Char(verze shr 8 mod 10+48);
  if s[1]='0' then s:=copy(s,2,length(s)-1);
  Getdosversion:=s;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function GetVesaInfo(var buffer):Boolean;
Const Ok : Boolean = True;
begin
  asm
    les di, [buffer]
    mov ax, 4F00h
    int 10h
    cmp ax, 4fh
    jne @chyba
    jmp @end
  @chyba:
    mov ok,false
  @end:
  end;
 GetVesaInfo:=Ok;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function GetVideoCardType;
Var VesaRec : Record
               VESA        : array[1..4] of char;
               VerHi,VerLo : Byte;
               OEMname     : PChar;
               Reserved    : array [1..246] of byte;
              End;

Begin
  With VesaRec Do
  Begin
    If GetVesaInfo(VesaRec) Then
            GetVideoCardType:= 'VESA '+ Chr(VerLo+48) + '.'
                                      + Chr(VerHi+48) + ', '+
                                        StrPas(OEMName)
       else GetVideoCardType:='';
                End;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function GetFloppyType : String;
Var Temp : Byte;
    Out  : String;
Begin
 GetChmosInfo;Out:='';
 Temp:=ChmosInfo.FloppyType;
 Out:=FloppyType[(Temp Shr 4) And $0F];
 If (Temp And $0F)<>0 Then Out:=Out+' + ' + FloppyType[Temp And $0F];
 GetFloppyType:=Out;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function ReadCHMOS(RelAddr:Byte):Byte;
 Var RportVar:Byte;
Begin
 Asm
  mov al,RelAddr
  out 70h,al
  xor cx,cx
  in al,71h
  mov RportVar,al
 End;
 ReadCHMOS:=RportVar;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure GetCHMOSInfo;
Begin
 With ChmosInfo Do
  Begin
    POSTStatus:=ReadCHMOS($0E);
    ShutDownStatus:=ReadCHMOS($0F);
    FloppyType:=ReadCHMOS($10);
    HardDiskType:=ReadCHMOS($12);
    ByteVybaveni:=ReadCHMOS($14);
    BaseMemory:=ReadCHMOS($15) + (ReadCHMOS($16)*256);
    ExtendetMemory:=ReadCHMOS($17) + (ReadCHMOS($18)*256);
    HardDisk0Type:=ReadCHMOS($19);
    HardDisk1Type:=ReadCHMOS($1A);
    CRC:=(ReadCHMOS($2E)*256) + ReadCHMOS($2F);
    StoletiBCD:=ReadCHMOS($32);
  End;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function GetBiosDate;
var
  s  : string[8];
begin
  Move(Ptr($F000,$FFF5)^,s[1],8);
  s[0]:=#8;
  GetBIOSDate:=s;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
{ ADLIB }
const cNotInstall = '-';
      cPort       = 'Port=';
var  AdADR, AdDAT : word;
Procedure WriteAdlib(fce :byte; data : byte); Assembler;
asm
    mov al,fce
    mov dx,AdADR
    out dx,al
    mov cx,7
@A: in al,dx
    loop @A
    mov dx,AdDAT
    mov al,data
    out dx,al
    mov cx,30
@B: in al,dx
    loop @B
end;
{-------------------}
Procedure ResetAdlib;
var x  : byte;
begin
  WriteAdlib(1,0);
  WriteAdlib(8,0);
  for x:=0 to 63 do WriteAdlib($0A0+x,0);
  WriteAdlib($0BD,$FF);
  for x:=0 to 32 do WriteAdlib($040+x,63);
end;
{-----------------------}
Function ReadStatus:byte;
begin
 readstatus:=port[AdADR];
end;
{----------------------------}
Function DetectAdlib : boolean;
var
 a,b  : byte;
begin
  WriteAdlib($04,$60); { odmaskujeme casovace 1 a 2}
  WriteAdlib($04,$80); { znulujeme vlajky }
  a:=readstatus;       { status? mel by bejt 0}
  WriteAdlib($02,$FF); { preteceni? }
  WriteAdlib($04,$21); { spustime 1. casovac a druhej zamaskujem }
  asm                  { pockame na preteceni}
          mov dx,388
          mov cx,80
  @semka: in al,dx
          loop @semka
  end;
  b:=readstatus;      { status? mel by bejt 11000000b }
  WriteAdlib($04,$60);{ reset obou timeru }
  a:=a AND $0E0;
  b:=b AND $0E0;
  if (a=0) and (b=$0C0) then DetectAdlib:=true else
                             DetectAdlib:=false;
end;
{----------------------------}
Function GetAdlib;
var
  s  : string;
begin
  adadr:=$388;
  adDAT:=$389;
  if Detectadlib then s:=cPort+DectoHex(AdADR)+'h' else s:=cNotInstall;
  GetAdlib:=s;
end;
{----------------------------}
Function GetSB;
var
  s    : string;
  port : word;
begin
  s:=cNotInstall;
  for port:=$21 to $24 do
  begin
    adAdr:=port shl 4;
    adDAT:=port shl 4+1;
    if Detectadlib then s:=cPort+DectoHex(port)+'0h';
  end;
  GetSB:=s;
  adadr:=$388;
  adDAT:=$389;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function GetEmsSize;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function Installed : Boolean;
Const EMSDriverInfo : Pointer = Ptr(0,$019c);
    CompareStr : Array [1 ..8] Of Char = ('E','M','M','X','X','X','X','0');
Type
    TData = Array[1..8] Of Char;
Var Address : ^Pointer;
    Data    : ^TData;
Begin
  Address :=  EMSDriverInfo;
  Data := Ptr(Seg(Address^^),$0A);
  If CompareStr=Data^ Then Installed := True
    Else Installed := False;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function MaxAvail : Word ;Assembler;
Asm
  mov ah,42h
  int 67h
  mov ax,dx
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Begin
  GetEmsSize:='컴컴';
  If Installed Then GetEmsSize := Thousand(Longint(MaxAvail * 16)) + ' Kb';
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function GetXmsSize;
Const XmsError : Byte = 0;
      XmsAddr  : Pointer = Nil;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function Installed : Boolean;
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
 Installed := ( HiMemSeg<>0 );
 XMSAddr:= Ptr( HiMemSeg, HiMemOfs );
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function MaxAvail : Word;
  Begin
   XMSError:= 0;
   MaxAvail:= 0;
    Asm
     Mov AH,8;
     Call XMSAddr;
     Or AX,AX;
     JNZ @1;
     Mov XMSError,BL;  { Nastaven� kodu chyby }
     XOr DX,DX;
    @1:
     Mov @Result,DX;       { AX = velikost max. bloku XMS }
    End;
End;

Begin
 GetXmsSize:='컴컴';
 If Not Installed Then Exit;
 GetXmsSize := (Thousand(Longint(MaxAvail)) + ' Kb');
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function GetNovell;
Begin
  if NovellInstaled then GetNovell:='Nalezen' else GetNovell:='Nenalezen';
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function GetCDROM;
const
  sklontab:array[0..2] of string[2]=('ka','ky','ek');
var
 mah  : word;
begin
  asm
    mov ax, 1500h
    xor bx, bx
    int 2fh
    mov [mah], bx
  end;
  if mah>0 then GetCDROM:=InttoStr(mah)+' jednot'+SklonTab[byte(mah>1)+byte(mah>4)]
           else GetCDROM:='Nenalezena';
end;

End.