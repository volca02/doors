uses crt;
const dob = 60;
type  tvideo  =array[0..24,1..80,0..1] of char;
var
  vi  : tvideo absolute $B800:0000;
  rad : byte;

Procedure Nul;
begin
  rad:=0;
end;

Procedure Col;
var
 a  : byte;
begin
  for rad:=0 to 24 do
    for a:=1 to 80 do vi[rad,a,1]:=#23;
  for rad:=2 to 12 do
    for a:=16 to 69 do vi[rad,a,1]:=#31;
end;

Procedure Col1;
var
 a  : byte;
begin
  for rad:=0 to 24 do
    for a:=1 to 80 do vi[rad,a,1]:=#23;
  for rad:=7 to 18 do
    for a:=4 to 28 do vi[rad,a,1]:=#31;
end;

Procedure Wr(st:string);
var
 a  : byte;
begin
  for a:=1 to length(st) do vi[rad,a,0]:=st[a];
  inc(rad);
end;

Procedure Wrx(y,x,c:byte;ch:char);
begin
  vi[y-1,x,0]:=ch;
  vi[y-1,x,1]:=chr(c+16);
end;

Procedure Wrp(y,x,c:byte;ch:char);
begin
  vi[y-1,x,0]:=ch;
  vi[y-1,x,1]:=chr(c+16);
  delay(dob);
end;

Procedure Wrath(y,x:byte;s:string);
var
  a  : byte;
begin
  for a:=1 to length(s) do
  begin
    vi[y-1,x+a,0]:=s[a];
    vi[y-1,x+a,1]:=#31;
  end;
end;

Procedure Wratl(y,x:byte;s:string);
var
  a  : byte;
begin
  for a:=1 to length(s) do
  begin
    vi[y-1,x+a,0]:=s[a];
    vi[y-1,x+a,1]:=#23;
  end;
end;

Procedure Ramecek;
begin
  Col; Nul;
  Wr('ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป');
  Wr('บ                                                                              บ');
  Wr('บ               ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ (R)          บ');
  Wr('บ                 ÜÜÜÜÜ                               Ü   Ü                    บ');
  Wr('บ                Û     Û Û                    Û       Û   Û  Û                 บ');
  Wr('บ                Û       Û       ÜÜÜÜ   ÜÜÜÜ  Û   Ü   Û   Û ÜÛÜ                บ');
  Wr('บ                Û       ÛÜÜÜÜ  Û    Û Û    ฿ Û Ü฿     ฿Û฿   Û                 บ');
  Wr('บ                Û       Û    Û Û฿฿฿฿  Û      ÛÛ        Û    Û                 บ');
  Wr('บ                Û     Û Û    Û Û    Ü Û    Ü Û ฿Ü      Û    Û                 บ');
  Wr('บ                 ฿฿฿฿฿  ฿    ฿  ฿฿฿฿   ฿฿฿฿  ฿   ฿   ฿฿฿฿฿  ฿                 บ');
  Wr('บ               ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿              บ');
  Wr('บ               P C   D I A G N O S T I C         S O F T W A R E              บ');
  Wr('บ                                                                              บ');
  Wr('บ                                                                              บ');
  Wr('บ                                                                              บ');
  Wr('บ                                                                              บ');
  Wr('บ                                                                              บ');
  Wr('บ                           Serial Number: XX-XXXXXX                           บ');
  Wr('บ                                                                              บ');
  Wr('บ     COPYRIGHT (c) 1988, 1989, 1990 FlintStone Institute of Black Magic       บ');
  Wr('บ                             ALL RIGHTS RESERVED.                             บ');
  Wr('บ ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ บ');
  Wr('บ                                                                              บ');
  Wr('บ                                                                              บ');
  Wr('ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ');
end;

Procedure Ramecek1;
begin
  Col1; Nul;
  Wr('ษอ Check๛It 3.0 อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป');
  Wr('บ                                                                              บ');
  Wr('บ                                L O A D I N G                                 บ');
  Wr('บ                                =============                                 บ');
  Wr('บ                                                                              บ');
  Wr('บ                     INVESTIGATING SYSTEM CONFIGURATION.                      บ');
  Wr('บ                           ฺฤฟ                                                บ');
  Wr('บ                           ณ ณ Check for Active Viruses                       บ');
  Wr('บ                           รฤด                                                บ');
  Wr('บ                           ณ ณ Determine Procesor cooler type                 บ');
  Wr('บ                           รฤด                                                บ');
  Wr('บ                           ณ ณ Determine System Components                    บ');
  Wr('บ                           รฤด                                                บ');
  Wr('บ                           ณ ณ Look for RAM (Base, Extended, Expanded)        บ');
  Wr('บ                           รฤด                                                บ');
  Wr('บ                           ณ ณ Look for Brain                                 บ');
  Wr('บ                           รฤด                                                บ');
  Wr('บ                           ณ ณ Look for Stupidity                             บ');
  Wr('บ                           ภฤู                                                บ');
  Wr('บ ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ บ');
  Wr('บ                                                                              บ');
  Wr('บ                                                                              บ');
  Wr('บ ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ บ');
  Wr('บ                                                                              บ');
  Wr('ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ');
end;

Procedure Skrt;
begin
{ zaskrt }
  Wrp(10,43,4,'Û'); Wrx(11,44,4,'Û'); Wrp(11,45,4,'Û'); Wrx(12,45,4,'Û');
  Wrp(12,46,4,'Û'); Wrx(13,46,4,'Û'); Wrp(13,47,4,'Û'); Wrx(12,47,4,'Û');
  Wrp(12,48,4,'Û'); Wrx(11,48,4,'Û'); Wrp(11,49,4,'Û'); Wrx(10,49,4,'Û');
  Wrx(10,50,4,'Û'); Wrp(10,51,15,'฿'); Wrx(09,50,4,'Û'); Wrp(09,51,4,'Û');
  Wrx(08,51,4,'Û'); Wrp(08,52,4,'Û'); Wrx(07,52,4,'Û'); Wrp(07,53,4,'Û');
  Wrx(06,53,4,'Û'); Wrp(06,54,4,'Û'); Wrx(05,54,4,'Û'); Wrp(05,55,4,'Û');
  Wrp(04,56,4,'Û'); Wrp(03,57,4,'Û');
{ xx xxxx Press}
  Wrath(15,40,'xx'); Delay(dob*2);
  Wrath(16,39,'xxx'); Delay(dob*2);
  Wrath(23,28,'Press Key <~> to Continue');
end;

function IntToStr(I: Longint): String;
var
  S: string[11];
begin
  Str(I:2, S);
  IntToStr := S;
end;

Procedure Tb(y,x:byte; text:string);
var
 a,b :  byte;
begin
  b:=x-length(text)-2;
  for a:=b to x-1 do
  begin
    Wrx(y-1,a,7 ,'ฤ');
    Wrx(y+1,a,7 ,'ฤ'); {ณ ฟ ภ ฤ ู ฺ}
  end;
  Wrx(y,x,7,'ณ');
  Wrx(y,b-1,7,'ณ');
  Wrx(y-1,x,7,'ฟ');
  Wrx(y+1,x,7,'ู');
  Wrx(y-1,b-1,7,'ฺ');
  Wrx(y+1,b-1,7,'ภ');
  Wratl(y,b,text);
end;

Procedure DelTb(y,x:byte; text:string);
var
 a,b :  byte;
begin
  b:=x-length(text)-2;
  for a:=b to x-1 do
  begin
    Wrx(y-1,a,7 ,' ');
    Wrx(y+1,a,7 ,' '); {ณ ฟ ภ ฤ ู ฺ}
  end;
  Wrx(y,x,7,' ');
  Wrx(y,b-1,7,' ');
  Wrx(y-1,x,7,' ');
  Wrx(y+1,x,7,' ');
  Wrx(y-1,b-1,7,' ');
  Wrx(y+1,b-1,7,' ');
  for a:=0 to length(text) do Wratl(y,b+a,' ');
end;

Procedure Loader;
var
  pass  : byte;
begin
  Tb(08,27,'Processing...');  Delay(1000); Deltb(08,27,'Processing...');
  Wrx(8,30,15 ,'๛');   Wrath(8,22,'Found');
  for pass:=1 to 10 do
  begin
     Tb(10,27,'Step '+inttostr(pass)+' of 10');
     Delay(300);
 end; DelTb(10,27,'Step 10 of 10');
  Wrx(10,30,15,'๛');   Wrath(10,24,'Fan');
  for pass:=1 to 10 do
  begin
     Tb(12,27,'Pass '+inttostr(pass)+' of 10');
     Delay(100);
  end; DelTb(12,27,'Pass 10 of 10');
  Wrx(12,30,15 ,'๛');  Wrath(12,19,'Complete');
  Tb(14,27,'Searching...'); Delay(1800);
  DelTb(14,27,'Searching...');  Wrx(14,30,15 ,'๛');  Wrath(14,20,'Missing');
  Delay(800 );
  Wrx(16,30,15 ,'๛');  Wrath(16,20,'Missing');
  Delay(1800);
  Wrx(18,30,15 ,'๛');  Wrath(18,20,'Present');
  Wratl(21,3,'System Configuration Checks Complete.');
  Wrath(24,28,'Press Any Key to Continue');
end;

Procedure Intro;
begin
  Ramecek;  Skrt;   Readkey;
  Ramecek1; Loader; Readkey;
end;

begin
  Intro; textattr:=7; Clrscr;
end.