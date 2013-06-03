CODE     segment word public

ASSUME   cs:code

PUBLIC   GetProcesorType, GetProcesorMode, GetCoprocesorType

CPU8086    = 0         ; 8086/88
CPU80186   = 1         ; 80186
CPUV20     = 2         ; NEC V20/V30 
CPU80286   = 3         ; 80286
CPU80386SX = 4         ; 80386
CPU80386DX = 5         ; 80386
CPU80486SX = 6         ; 80486
CPU80486DX = 7         ; 80486
CPU80586   = 8         ; Pentium

FPUNONE    = 0         ; bez koprocesoru
FPU8087    = 1         ; 8087
FPU80287   = 2         ; 80287
FPU80387   = 3         ; 80387
FPU80487   = 4         ; 80487
FPU80587   = 5         ; Pentium
EMU80287   = 6         ; emulator 80287
EMU80387   = 7         ; emulator 80387
EMU80487   = 8         ; emulator 80487

 .386p

GetProcesorType PROC FAR
        push ebx ecx edx edi esp
        mov  ax,CPU80186
        push sp
        pop  bx
        cmp  bx,sp
        je   CPU286
        mov  cl,32
        shl  bx,cl
        jnz  CPUKonec
        xor  al,al
        mov  al,40h
        mul  al
        mov  ax,CPU8086
        jnz  CPUKonec
        mov  ax,CPUV20
        jmp  CPUKonec
CPU286:
        mov  ax,0f000h
        push ax
        popf

        pushf
        pop  ax
        and  ax,0f000h
        jnz  CPU386
        mov  ax,CPU80286
        jmp  CPUKonec
CPU386: 
         mov bx,sp
         and sp,not 3
         pushfd
         pop eax
         mov ecx,eax
         xor eax,40000h
         push eax
         popfd
         pushfd
         pop eax
         mov sp,bx
         xor eax,ecx
         jnz  CPU486  ;jnz
         jmp  CPU3SXDX
CPU486: 
        pushfd
        pop  eax
        mov  ecx,eax
        or   eax,200000h
        push eax
        popfd
        pushfd
        pop  eax
        xor  eax,ecx
        jnz  CPU586
        mov  ax,CPU80486SX
        jmp  CPU4SXDX
CPU586: 
        mov  eax,1
        db   0Fh,0A2h
        and  eax,0F00h
        shr  eax,8
        cmp  al,5
        mov  ax,CPU80486SX
        jl   CPU4SXDX
        mov  ax,CPU80586
        jmp  CPUKonec
CPU3SXDX:
        mov  eax,12345678
        mov  edx,0
        mov  edi,0
        pushad
        popad
        mov  ecx,[edx+edi]
        cmp  eax,12345678
        mov  ax,CPU80386SX
        je   CPUKonec
        mov  ax, CPU80386DX
        jmp  CPUKonec
CPU4SXDX:
        smsw bx
        and  bx,02h
        jnz   CPUKonec
        mov  ax,CPU80486DX
CPUKonec:
         pop  esp edi edx ecx ebx
         ret
GetProcesorType ENDP

GetProcesorMode PROC FAR
        smsw ax
        and  ax,01h
        jz   P1
        mov  al, 0ffh
        jmp  P2
P1:     mov  al,00h
P2:     ret 
GetProcesorMode ENDP

fpu_cw dw ?
fpu_sw dw ?

GetCoprocesorType PROC FAR
        push bx cx dx
        mov  [fpu_cw],0
        cli
        fninit
        mov  cx,2
        loop $
        fnstcw [fpu_cw]
        mov  cx, 14h
        loop $
        sti
        mov  ax,[fpu_cw]
        and  ax,0f3fh
        cmp  ax,033fh
        mov  bx,FPUNONE
        jne  FPUKonec
        call GetProcesorType
        mov  dx,ax
        cmp  dx,CPU80286
        jge  FPU287
        mov  bx,FPU8087
        jmp  FPUKonec
FPU287:
        smsw ax
        test al,4
        mov  cx,0
        jz   Dal
        mov  cx,4
Dal:    cmp  dx,CPU80386SX
        jge  FPU387
        mov  bx, FPU80287
        jmp  FPUKonec
FPU387:
        cmp  dx,CPU80486SX
        jge  FPU487
        fld1
        fldz
        fdiv
        fld1
        fchs
        fldz
        fdiv
        fcompp
        fstsw [fpu_sw]
        mov  ax,[fpu_sw]
        and  ah,41h
        cmp  ah,40h
        mov  bx,FPU80287
        je   FPUKonec
        mov  bx,FPU80387
        jmp  FPUKonec
FPU487: 
        mov  bx,FPU80487
        cmp  dx,CPU80586
        jl   FPUKonec
        mov  bx,FPU80587
FPUKonec:
        mov  ax,bx
        add  ax,cx
        pop  dx cx bx
        ret
GetCoprocesorType ENDP

CODE ENDS
     END
