Unit EMS;
Interface
Var
            Error              : Byte;
            Procedure SaveStatus( Handle : Word );
            Procedure RestoreStatus( Handle : Word );
            Function MaxAvail  : Word;
            Function Avail     : Word;
            Function Installed : Boolean;
            Function GetStatus : Word;
            Procedure Map(Handle:Word;Fyzic : Byte;Logic:Word);
            Function OpenHandle(Size :Word): Word;
            Function GetDataPointer : Pointer;
            Procedure CloseHandle( Handle : Word);
Implementation
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function MaxAvail;Assembler;
Asm
  mov ah,42h
  int 67h
  mov ax,dx
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function Avail;Assembler;
Asm
  mov ah,42h
  int 67h
  mov ax,bx
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function OpenHandle;Assembler;
Asm
  mov ah,43h
  mov bx,Size
  int 67h
  mov Error,Ah
  mov ax,dx
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure CloseHandle;Assembler;
Asm
  mov ah,45h
  mov dx,handle
  int 67h
  mov Error,Ah
  mov ax,dx
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function Installed;
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
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function GetStatus;Assembler;
Asm
  mov ah,40h
  int 67h
  mov al,ah
  xor ah,ah
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function GetDataPointer;Assembler;
Asm
  mov ah,41h
  int 67h
  mov Error,Ah
  mov dx,bx
  xor ax,ax
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Map;Assembler;
Asm
  mov ah,44h
  mov al,fyzic
  mov bx,logic
  mov dx,handle
  int 67h
  mov Error,Ah
  xor ax,ax
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SaveStatus;Assembler;
Asm
  mov ah,47h
  mov dx,handle
  int 67h
  mov Error,Ah
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure RestoreStatus;Assembler;
Asm
  mov ah,48h
  mov dx,handle
  int 67h
  mov Error,Ah
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
End.