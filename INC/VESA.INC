const
  BPP2NIBBLE   : array[1..6] of longint=(1,2,3,4,5,6); {BPP shr 2}
type
  PColor = ^TColor;
  TColor = Longint;
  tRIBuffer = record
                ResAttrib        : word;
                AttribA, AttribB : byte;
                Granulity, size  : word; { v KB (*1024) }
                segA, segB       : Word;
                position         : Procedure;
                BPerLine         : word; { docela uzitecna vec }
                ResX, ResY       : word;
                CharX, CharY  : byte;
                MemLevels     : byte;
                BPP           : byte; { 4, 8, 16, 24 }
                banks         : byte; { 0? }
                MModel        : byte; { pamet. model }
                BSize         : byte; { velikost banky }
                SPages        : byte; { pocet obr. stran }
                fuj           : array[1..226] of byte;
              end;
var
  VesaVer : word; {hi.low}
  back    : word; { po navratu z Fce obsahuje v idealnim pripade 004F}
  SuppRes : pointer; { ukazatel na podporovane rozliseni, konec FFFF}
  activepage : word;
  SetPage    : Procedure;
  ActiveM    : TRIBuffer;
  BackDraw   : boolean;
  Pixelsize  : byte;
  Vbafr : record
            VESA : Array [1..4] of char; {'VESA'}
            vv   : word; { Verze }
            oem  : pointer;
            sch  : longint;
            rsl  : pointer;
            res  : array[1..238] of byte;
         end;

procedure Setpal(c:byte;r,g,b:byte); assembler;
asm
  mov dx,$3C8
  mov al,c
  out dx,al
  inc dx
  mov al,r
  shr al,2
  out dx,al
  mov al,g
  shr al,2
  out dx,al
  mov al,b
  shr al,2
  out dx,al
end;

Function  DetectVESA  : boolean;
{ Zjisti pritomnost a verzi VESY }
begin
  asm
    mov di, offset [Vbafr]
    mov ax, seg [Vbafr]
    mov es, ax
    mov ax, 4F00h
    int 10h
    mov [back], ax
  end;
  VesaVer:=Vbafr.vv;
  suppres:=Vbafr.rsl;
{  Writeln(Vbafr.vesa,',',back);}
  detectvesa:=Vbafr.Vesa='VESA';
end;

Procedure GetResolutionInfo(res  : word; var buf  : tRIBuffer);
{ Zjistuje informace o REZIMU }
begin
  asm
    push es
    mov cx, res
    les di, [buf]
    mov ax, 4F01h
    int 10h
    mov [back], ax
    pop es
  end;
end;

Function  SetResolution(res  : word) : boolean;
{ Nastavi Rozliseni (videomode) }
begin
  asm
    mov bx, res
    mov ax, 4F02h
    int 10h
    mov [back], ax
  end;
  GetResolutionInfo(res, ActiveM);
  Activepage:=0;
  Setpage:=ActiveM.position;
  Pixelsize:=BPP2Nibble[ActiveM.BPP shr 2] shr 1;
  if back=$4F then
  asm
    mov ax, 4f05h
    xor dx, dx
    xor bx, bx
    int 10h
    mov [back], ax
  end;
end;

Function  GetResolutionNumber(x,y : word; bpp : byte ) : word;
{ Vraci cislo rozliseni ktery se da pouzit
  FFFF = rozliseni nenalezeno }
var
  p  : ^word;
  b  : boolean;
  i  : tRIBuffer;
begin
  p:=suppres;
  repeat
    GetResolutioninfo(p^,i);
    b:=((i.resx>=x) and (i.resy>=y) and (i.bpp=bpp) and
    (i.resattrib and $18=$18));
    if not b then
    asm inc word ptr p
        inc word ptr p
    end;
  until (p^=$FFFF) or b;
  GetResolutionNumber:=p^;
end;

Procedure DrawPixel(x,y:word; color : tColor);
{ vykreslovani }
var
  pos  : longint;
  w    : word;
begin
  if activem.bpp>=8 then
  begin
    pos := BPP2Nibble[ActiveM.BPP shr 2] shr 1*X;
    pos := pos + longint(ActiveM.Bperline)*Y;
    w   := pos div (longint(ActiveM.granulity) shl 10);
    pos := pos mod (longint(ActiveM.granulity) shl 10);
    if w<>activepage then
    begin
      asm
        mov ax, 4f05h
        mov dx, w
        xor bx, bx
        call Activem.Position
        mov [back], ax
      end;
      activepage:=w;
    end;
    Move(color,Mem[Activem.SegA:pos],Pixelsize);
  end else
  begin { predpokladejme ze tedy 4 }
    pos := BPP2Nibble[ActiveM.BPP shr 2]*(X div 2)
           +longint(ActiveM.Bperline)*Y;
    w   := pos div (longint(ActiveM.granulity)*1024);
    pos := pos mod (longint(ActiveM.granulity)*1024);
    if w<>activepage then
    begin
      asm
        mov ax, 4f05h
        mov dx, w
        xor bx, bx
        call Activem.Position
        mov [back], ax
      end;
      activepage:=w;
    end;
    case x and 1 of
          0: Mem[Activem.SegA:pos]:=Mem[Activem.SegA:pos] and $F0+color and $F;
          1: Mem[Activem.SegA:pos]:=Mem[Activem.SegA:pos] and $F+color and $F shl 4;
    end;
  end;
end;

Procedure SetBits(x,y:word; color : tColor);
{ vykreslovani }
var
  pos  : longint;
  w    : word;
begin
  pos := BPP2Nibble[ActiveM.BPP shr 2] shr 1*X+longint(ActiveM.Bperline)*Y;
  w   := pos div (longint(ActiveM.granulity)*1024);
  pos := pos mod (longint(ActiveM.granulity)*1024);
  if w<>activepage then
  begin
    asm
      mov ax, 4f05h
      mov dx, w
      xor bx, bx
      call Activem.Position
      mov [back], ax
    end;
    activepage:=w;
  end;
  Move(color,Mem[Activem.SegA:pos],Pixelsize);
end;