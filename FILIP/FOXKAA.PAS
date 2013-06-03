Program foxpro;
uses crt;
const
  roz=4;
  roy=2;
type
  TPole = object
            pole   : array [1..12,1..12] of byte; {4x4 = 16 policek - mezera}
            mx,my  : byte;
            ox,oy  : byte;
            Procedure Make;
            Procedure Move(Way  : Char); {HKMP}
            Procedure Display;
            Procedure Save;
            Procedure Load;
            Function  Check :boolean;
            Procedure Init;
            Procedure Run;
          end;
{----------------------------------------------------------------------------}
Procedure TPole.Save;
var
  f  : file;
begin
  Assign(f,'pole.dat');
  rewrite(f,1);
  Blockwrite(f,pole,sizeof(pole));
  Blockwrite(f,mx,1);
  Blockwrite(f,my,1);
  Blockwrite(f,ox,1);
  Blockwrite(f,oy,1);
  Close(f);
end;

Procedure TPole.Load;
var
  f  : file;
begin
  Assign(f,'pole.dat');
  {$I-} reset(f,1); {$I+}
  if ioresult=0 then
  begin
    Blockread(f,pole,sizeof(pole));
    Blockread(f,mx,1);
    Blockread(f,my,1);
    Blockread(f,ox,1);
    Blockread(f,oy,1);
    Close(f);
    clrscr;
    display;
  end;
end;

Procedure TPole.Move;
var
 s        : byte;
 bx,by    : byte;
 movable  : boolean;
begin
  movable:=false; bx:=ox; by:=oy;
  case Way of
      'P': if oy>1 then begin movable:=true; dec(oy); end;
      'M': if ox>1 then begin movable:=true; dec(ox); end;
      'K': if ox<mx then begin movable:=true; inc(ox); end;
      'H': if oy<my then begin movable:=true; inc(oy); end;
  end;
  if movable then
  begin
    s:=pole[ox,oy];
    Pole[ox,oy]:=0;
    Pole[bx,by]:=s;
  end;
end;

Procedure TPole.Display;
var
  x,y  : byte;
begin
  Gotoxy(1,20);
  if check then
  begin
    Writeln('YES!!');
    Textattr:=15;
  end else Writeln('     ');
  for x:=1 to mx do
    for y:=1 to my do begin Gotoxy(x*roz,y*roy); Write('   '); end;
  for x:=1 to mx do
    for y:=1 to my do
    begin
      Gotoxy(x*roz,y*roy); textattr:=7;
      if pole[x,y]=(mx*my+1)-((x+mx*(y-1)) mod (mx*my)) then textattr:=9;
      if pole[x,y]=1+(x+mx*(y-1)) mod (mx*my) then textattr:=2;
      if pole[x,y]+1=(x+mx*(y-1)) then textattr:=2;
      if pole[x,y]=(x+mx*(y-1)) mod (mx*my) then textattr:=14;
      textattr:=textattr+16;
      if pole[x,y]<>0 then Write(pole[x,y]:3);
    end;
  textattr:=7;
end;

Procedure TPole.Make;
const
  smer : array[0..3] of char = ('P','M','K','H');
var
 a      : array[0..144] of boolean;
 x,y,z  : word;
begin
{  for x:=1 to mx do
    for y:=1 to my do pole[x,y]:=0;
  For x:=0 to (mx*my-1) do a[x]:=false;}
  for x:=1 to mx do
    for y:=1 to my do
      pole[x,y]:=(x+mx*(y-1)) mod (mx*my);
  ox:=mx; oy:=my;
  for x:=1 to mx*my*10 do
    move(Smer[random(4)]);
end;


Function TPole.Check:boolean;
var
  x,y  : byte;
  jeto : boolean;
begin jeto:=true;
  for x:=1 to mx do
    for y:=1 to my do if pole[x,y]<>(x+mx*(y-1)) mod (mx*my) then
             jeto:=false;
  Check:=jeto;
end;
{----------------------------------------------------------------------------}
Procedure TPole.Init;
begin
  Randomize; mx:=4; my:=4;
  Clrscr;
  Make;
  Display;
end;
{------------------}
Procedure TPole.Run;
var
  ch  : char;
begin
  repeat
    ch:=upcase(readkey);
    if ch=#32 then
    begin
      Make;
      Display;
    end;
    if ch='S' then Save;
    if ch='X' then Load;
    if ch in ['O','K','L',';'] then
    begin
      case ch of
           'O': if my>2 then dec(my);
           'L': if my<12 then inc(my);
           'K': if mx>2 then dec(mx);
           ';': if mx<12 then inc(mx);
      end;
      Make; ClrScr;
      Display;
    end;
    if ch=#0 then
    begin
      ch:=readkey;
      Move(ch);
      Display;
    end;
  until ch=#27;
end;
{----------------------------------------------------------------------------}
var
  gamesa  : TPole;
begin
  Gamesa.Init;
  Gamesa.Run;
  clrscr;
  Writeln('Made by Volca 1998');
  Writeln('zmena velikosti pole: <O><K><L><;>');
  Writeln('< > rozmichani');
  Writeln('<S> zapis nadisk');
  Writeln('<X> vyvolani z disku');
  Writeln('vsechny vygenerovane varianty jdou slozit, coz zajistuje michaci algoritmus.');
end.