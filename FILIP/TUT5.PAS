{$X+} {$R-}
Uses Crt,graf, math;

CONST VGA = $a000;
      XSize = 16;
      YSize = 16;

TYPE
        Letter = Array[1..xsize,1..ysize] of Byte;
        Letters = Array[' '..']'] of Letter;

VAR Font : ^Letters;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
function Exist(FileName: string): Boolean;
    { Checks to see if filename exits or not }
var f: file;
begin
  {$I-}
  Assign(f, FileName);
  Reset(f);
  Close(f);
  {$I+}
  Exist := (IOResult = 0) and
   (FileName <> '');
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Setup;
  { This loads the font and the pallette }
VAR f:file;
    loop1:char;
    loop2,loop3:integer;
BEGIN
  getmem (font,sizeof (font^));
  If exist ('softrock.fnt') then BEGIN
    Assign (f,'softrock.fnt');
    reset (f,1);
    blockread (f,font^,sizeof (font^));
    close (f);
  END ELSE
  BEGIN
    Writeln ('Varovani: Nenalezen soubor softrock.fnt...');
    readkey;
    For loop1:=' ' to ']' do
      For loop2:=1 to 16 do
        for loop3:=1 to 16 do
          font^[loop1,loop2,loop3]:=loop2;
  END;
  S_320x200;
{  If exist ('pallette.col') then loadpal ('pallette.col');}
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
const
  slen =360;
  lift =127;
  mxy  =30;
  mxx  =319;
var
  SinT : array [0..slen-1] of shortint;
  field : PScreen;

Procedure MoveAndFade(var field); assembler;
asm
  push ds
  les di, field
  lds si, field
  add si, 320
  mov cx, 199
@loop1:
  mov bx, 320
@inner:
  lodsw
  cmp al, 2
  jna @ne1
  dec al
@ne1:  cmp ah, 2
  jna @ne
  dec ah
{  dec al}
@ne:
  stosw
  dec bx
  cmp bx, 0
  jnz @inner
  loop @loop1
  pop ds
end;

Procedure DoType(sx,sy:word; s: string; pos: word; kam:pscreen);
var x,y,z,q,u  : word;
    b          : byte;
begin
  z:=0;
  for y:=1 to length(s)*ysize-1 do
  begin
    z:=z+1;
    u:=q;
    q:=16+SinT[(z*2+pos*10) mod slen] div 8;
    for x:=ysize downto 1 do
    begin
      b:=Font^[upcase(s[z div 16+1]),z mod 16+1,x];
      if b>0 then
        fillchar(kam^[x+sy,y+sx+q],2,228+b);
    end;
  end;
end;

Procedure MainText (Msg : String;var pos: word);
  { This scrolls the string in MSG across the screen }
var x,y,z,q    : word;
    b          : byte;
Begin
  pos:=pos mod (16*length(msg));
  for y:=0 to 319 do
  begin
    z:=(pos+y) mod (16*length(msg));
    q:=100+SinT[(z+y) mod slen] shr 4;
    for x:=1 to ysize do
    begin
      b:=Font^[upcase(msg[z div 16+1]),z mod 16+1,x];
      if b>0 then virt^[x+q,y]:=b+210;
    end;
  end;
  inc(pos);
End;

var
  px,py,y  : word;

begin
  Setup;
  new(field); VCls(Field^);
  for px:=0 to slen-1 do SinT[px]:=Round(-lift*sin(px/(slen/2)*pi));
  for px:=0 to 255 do Setpal(px,px,Max(0,integer(px)-128)*2,0);
  px:=0; py:=0;
  fcol:=230;
  repeat
    For px:=1 to 318 do field^[199,px]:=
      (Field^[198,px]+Field^[198,px+1]+Field^[198,px-1]+Random(100)+155) shr 2;
    MoveAndFade(field^);
    MoveD(field^,virt^,63680);
    MainText  ( '                Tak je to konecne '+
                'tady! diskovy manazer Doors v1.00 '+
                'v plne verzi bude vypusten mezi '+
                'uzivatele zacatkem brezna! ... ..'+
                '... ...Maturita se blizi (UFF)',py);
    DoType(110,18,'DOORS',y,virt);
    inc(y); if y>=360 then y:=0;
{    retrace;}
    Flip;
    vcls(virt^);
  until keypressed;
  S_text;
  dispose(field);
  freemem (font, sizeof (font^));
  Writeln ('DOORS INVASION DEMO   (C) Volca 1998');
  Writeln ('Diky ASPHYXIA BBS za pismo a paletu...');
  Write   ('Hit any key to exit ...');
  Readkey;
end.
