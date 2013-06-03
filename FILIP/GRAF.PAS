Unit graf;
interface
{Definice compileru:}
{$DEFINE BIGPAL} {bigpal defined ==> paleta 256 urovni, jinak 64}
const
 minx=0;
 miny=0;
 maxx=319;
 maxy=199;

type
 vyrez   = array [0..15,0..15] of byte;
 tcolor  = record
             r,g,b  : byte;
           end;
 tscreen = array[0..199,0..319] of byte;
 pscreen = ^tscreen;
 pal     = array [0..255] of tcolor;
var
 Is320   : boolean;
 Gscreen : pscreen;
 virt    : pscreen;
 Sint    : array[0..255] of byte;
 Cost    : array[0..255] of byte;
 Tmp     : array[1..3] of byte;
 fontseg,fontoff : word;
 fcol    : byte;
 FADod,
 FADdo   : byte;

Procedure S_320x200;
Procedure S_Text;
Procedure SetVirtual;
Procedure SetDirect;
procedure Retrace;
procedure Setborder(col:byte);
procedure Cls;
procedure VCls(var screen);
procedure horline(xb,xe,y:integer; c:byte;var kam);
procedure polygon( x1,y1, x2,y2, x3,y3, x4,y4 :integer; c:byte; var kam);
procedure Setpal(c:byte;r,g,b:byte);
procedure Getpal(c:byte;var r,g,b:byte);
procedure SetAllPal(p  : pal);
Procedure TotalBlack;
procedure flip;
procedure getfont(var fseg,fofs:word);
procedure writetxt(var kam; x,y:integer; txt:string);
Procedure FadeOut;
Procedure LightOut;
Procedure MoveD(var src,dest;count:word);
Procedure Draw(x,y:integer; co: vyrez);
Procedure DrawM(x,y:integer; var co: vyrez; ne : byte);

implementation

procedure getDfont; assembler; asm push bp
  mov ax,1130h; mov bh,6; int 10h; mov fontseg,es; mov fontoff,bp; pop bp end;
Procedure S_320x200;{ assembler;}

begin
  if memavail<64000 then
  begin
    Writeln('Not enough memory to execute program, exiting...');
    Halt;
  end;
  SetVirtual;
  asm
    mov ax,0013h
    int 10h
  end;
  GetDfont; fcol:=15; Is320:=true;
end;

Procedure S_Text;
begin
  asm
    mov ax,0003h
    int 10h
  end;
  Is320:=false;
  if virt<>gscreen then Freemem(virt,64000);
end;

Procedure SetVirtual;
begin
  if virt=gscreen then
  begin
    getmem(virt,64000);
    Vcls(virt^);
  end;
end;

Procedure SetDirect;
begin
  if virt<>nil then Freemem(virt,64000);
  virt:=gscreen;
end;

procedure retrace; assembler;
asm
        mov dx,3dah
@vert1: in al,dx
        test al,8
        jz @vert1
@vert2: in al,dx
        test al,8
        jnz @vert2
end;

procedure setborder(col:byte); assembler;
asm
  xor ch,ch
  mov cl,1
  mov dx,3dah
  in al,dx
  mov dx,3c0h
  mov al,11h+32
  out dx,al
  mov al,col
  out dx,al
end;

procedure cls; assembler;
asm
  mov ax,$a000
  mov es,ax
  xor di,di
  xor ax,ax
  mov cx,320*200/2
  rep stosw
end;

procedure VCls(var screen); assembler;
asm
  les di,[screen]
  mov cx,32000{320*200/2}
  xor ax,ax
  rep stosw
end;

procedure horline(xb,xe,y:integer; c:byte;var kam); assembler;
asm
  mov bx,xb
  mov cx,xe
  cmp bx,cx
  jb @skip
  xchg bx,cx
 @skip:
  inc cx
  sub cx,bx
  les di,kam
  mov ax,y
  {nasobeni 320= x shl 6 + x shl 8 (320=64+320)}
  shl ax,6
  add di,ax
  shl ax,2
  add di,ax
  add di,bx
  shr cx,1
  mov al,c
  mov ah,al
  jnc @skip2
  stosb
 @skip2:
  mov ah,al
  rep stosw
 @out:
end;

function MaxI(A,B:Integer):Integer;
inline(
$58/                       {pop   ax       }
$5B/                       {pop   bx       }
$3B/$C3/                   {cmp   ax,bx    }
$7F/$01/                   {jg    +1       }
$93);                      {xchg  ax,bx    }
function MinI(A,B:Integer):Integer;
inline(
$58/                       {pop   ax       }
$5B/                       {pop   bx       }
$3B/$C3/                   {cmp   ax,bx    }
$7C/$01/                   {jl    +1       }
$93);                      {xchg  ax,bx    }
function InRangeI(value,min,max:integer):integer;
inline(
$59/                       {pop   cx  max  }
$5B/                       {pop   bx  min  }
$58/                       {pop   ax  val  }
$3B/$C3/                   {cmp   ax,bx    }
$7F/$03/                   {jg    +3       }
$93/                       {xchg  ax,bx    }
$Eb/$05/                   {jmp   +5       }
$3B/$C1/                   {cmp   ax,cx    }
$7C/$01/                   {jl    +1       }
$91);                      {xchg  ax,cx    }

procedure polygon( x1,y1, x2,y2, x3,y3, x4,y4 :integer; c:byte; var kam);
var pos:array[0..199,0..1] of integer;
  xdiv1,xdiv2,xdiv3,xdiv4:integer;
  ydiv1,ydiv2,ydiv3,ydiv4:integer;
  dir1,dir2,dir3,dir4:byte;
  ly,gy,y,tmp,step:integer;
begin
  { determine highest and lowest point + vertical window checking }
  ly:=MaxI(MinI(MinI(MinI(y1,y2),y3),y4),miny);
  gy:=MinI(MaxI(MaxI(MaxI(y1,y2),y3),y4),maxy);

  if ly>maxy then exit;
  if gy<miny then exit;

  { check directions (-1=down, 1=up) and calculate constants }
  dir1:=byte(y1<y2); xdiv1:=x2-x1; ydiv1:=y2-y1;
  dir2:=byte(y2<y3); xdiv2:=x3-x2; ydiv2:=y3-y2;
  dir3:=byte(y3<y4); xdiv3:=x4-x3; ydiv3:=y4-y3;
  dir4:=byte(y4<y1); xdiv4:=x1-x4; ydiv4:=y1-y4;

  y:=y1;
  step:=dir1*2-1;
  if y1<>y2 then begin
    repeat
      if InRangeI(y,ly,gy)=y then begin
        tmp:=xdiv1*(y-y1) div ydiv1+x1;
        pos[y,dir1]:=InRangeI(tmp,minx,maxx);
      end;
      inc(y,step);
    until y=y2+step;
  end
  else begin
    if (y>=ly) and (y<=gy) then begin
      pos[y,dir1]:=InRangeI(x1,minx,maxx);
    end;
  end;

  y:=y2;
  step:=dir2*2-1;
  if y2<>y3 then begin
    repeat
      if InRangeI(y,ly,gy)=y then begin
        tmp:=xdiv2*(y-y2) div ydiv2+x2;
        pos[y,dir2]:=InRangeI(tmp,minx,maxx);
      end;
      inc(y,step);
    until y=y3+step;
  end
  else begin
    if (y>=ly) and (y<=gy) then begin
      pos[y,dir2]:=InRangeI(x2,minx,maxx);
    end;
  end;

  y:=y3;
  step:=dir3*2-1;
  if y3<>y4 then begin
    repeat
      if InRangeI(y,ly,gy)=y then begin
        tmp:=xdiv3*(y-y3) div ydiv3+x3;
        pos[y,dir3]:=InRangeI(tmp,minx,maxx);
      end;
      inc(y,step);
    until y=y4+step;
  end
  else begin
    if (y>=ly) and (y<=gy) then begin
      pos[y,dir3]:=InRangeI(x3,minx,maxx);
    end;
  end;

  y:=y4;
  step:=dir4*2-1;
  if y4<>y1 then begin
    repeat
      if InRangeI(y,ly,gy)=y then begin
        tmp:=xdiv4*(y-y4) div ydiv4+x4;
        pos[y,dir4]:=InRangeI(tmp,minx,maxx);
      end;
      inc(y,step);
    until y=y1+step;
  end
  else begin
    if (y>=ly) and (y<=gy) then begin
      pos[y,dir4]:=InRangeI(x4,minx,maxx);
    end;
  end;

  for y:=ly to gy do horline(pos[y,0],pos[y,1],y,c,kam);
end;

procedure Setpal; assembler;
asm
  mov dx,$3C8
  mov al,c
  out dx,al
  inc dx
  mov al,r
{$IFDEF BIGPAL}
  shr al,2
{$ENDIF}
  out dx,al
  mov al,g
{$IFDEF BIGPAL}
  shr al,2
{$ENDIF}
  out dx,al
  mov al,b
{$IFDEF BIGPAL}
  shr al,2
{$ENDIF}
  out dx,al
end;

procedure Getpal;
var
 tr,tg,tb:byte;
begin
  asm
    mov dx,$3C7
    mov al,c
    out dx,al
    inc dx
    mov cx, 10
@L1: loop @L1
    in  al,dx
{$IFDEF BIGPAL}
    shl al,2
{$ENDIF}
    mov tr,al
    in  al,dx
{$IFDEF BIGPAL}
    shl al,2
{$ENDIF}
    mov tg,al
    in  al,dx
{$IFDEF BIGPAL}
    shl al,2
{$ENDIF}
    mov tb,al
  end;
  r:=tr; g:=tg; b:=tb;
end;

Procedure SetAllPal(p  : pal);
var
  x  : byte;
begin
  for x:=0 to 255 do SetPal(x,p[x].r,p[x].g,p[x].b);
end;

Procedure TotalBlack;
var
  x  : byte;
begin
  for x:=0 to 255 do SetPal(x,0,0,0);
end;

{$F+}
Procedure MoveD(var src,dest;count:word); external;
{$L kopy.obj}
{$F-}

Procedure Flip;
begin
{  Gscreen^:=virt^;}
  if virt<>gscreen then MoveD(Virt^,Gscreen^,64000);
end;

procedure getfont;
var
 sg,off : word;
begin
  asm
    push bp; push es
    mov ax , 1130h
    xor bx , bx
    mov bh , 1
    int 10h
    mov sg , es
    mov off, bp
    pop es; pop bp
  end;
  fseg:=sg; fofs:=off;
end;

procedure writetxt;
var i,j,k : byte;
    pism  : byte;
    levo,
    pravo : integer;
begin
  if length(txt)<>0 then
  for i:=0 to length(txt)-1 do
  begin
    pism:=ord(txt[i+1]);
    levo:=-(x+i*8);
    if levo<0 then levo:=0;
    pravo:=319-(x+i*8);
    if pravo>7 then pravo:=7;
    for j:=0 to 15 do
      for k:=levo to pravo do
      if ((mem[fontseg:fontoff+pism*16+j] shl k) and 128) <> 0 then
      begin
 {       mem[seg(kam):ofs(kam)+(y+j+1)*320+(i*8)+x+k+1] :=0;{ stin}
         mem[seg(kam):ofs(kam)+word(y+j)*320+(i*8)+x+k]     :=fcol{+j+k};
      end;
  end;
end;

Procedure FadeOut;
var
 x      : byte;
 r,g,b  : byte;
begin
  r:=0; g:=0; b:=0;
  for x:=FADod to FADdo do
  begin
    GetPal(x,r,g,b);
    if r>0 then dec(r);
    if g>0 then dec(g);
    if b>0 then dec(b);
    SetPal(x,r,g,b);
  end;
end;

Procedure LightOut;
var
 x      : byte;
 r,g,b  : byte;
begin
  r:=255; g:=255; b:=255;
  for x:=FADod to FADdo do
  begin
    GetPal(x,r,g,b);
    if r<255 then inc(r);
    if g<255 then inc(g);
    if b<255 then inc(b);
    SetPal(x,r,g,b);
  end;
end;

Procedure Draw(x,y:integer; co: vyrez);
var
  x1 : integer;
  yx, ym : integer;
begin
  ym:=0; yx:=15;
  if y<0 then ym:=-y;
  if y>199-16 then yx:=199-y;
  if x<320-15 then
  for x1:=ym to yx do moved(co[x1],virt^[x1+y,x],16);
end;

Procedure DrawM(x,y:integer; var co: vyrez; ne : byte); {assembler;}
var
  posy,postx  : word;
begin
  postx:=0;
  if y<0 then
  begin
    posy:=-y;
    postx:=posy;
    y:=0;
  end else
  if y>199-15 then
  begin
    posy:=y-(199-15);
  end else posy:=0;
  if posy<15 then
  asm
    push ds
    push si
    les di, [virt]
    add di, [x]
    mov ax, [y]
    mov bx, ax
    shl ax, 6
    add di, ax
    shl ax, 2
    add di, ax
    lds si, [co]
    cld
    mov cx, 16
    sub cx, [posy]
    mov ax, postx
    shl ax, 4
    add si, ax
   @l1:
    push cx
    mov cx, 16
   @l2:
    mov al, [ne]
    cmp ds:[si], al
    je @no
    movsb
    jmp @dal
   @no:
    inc si
    inc di
   @dal:
    loop @l2
    pop cx
    add di, 304
    loop @l1
    pop si
    pop ds
  end;
end;

begin
 GScreen:=ptr(segA000,0000); virt:=gscreen;
 FADod:=0; FADdo:=255; Is320:=false;
end.