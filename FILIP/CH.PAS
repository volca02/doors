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
  Wr('浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融');
  Wr('�                                                                              �');
  Wr('�               樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛� (R)          �');
  Wr('�                 樛樛�                               �   �                    �');
  Wr('�                �     � �                    �       �   �  �                 �');
  Wr('�                �       �       樛樛   樛樛  �   �   �   � 樂�                �');
  Wr('�                �       桀樛�  �    � �    � � 槹     炳�   �                 �');
  Wr('�                �       �    � 桎烝�  �      栩        �    �                 �');
  Wr('�                �     � �    � �    � �    � � 炮      �    �                 �');
  Wr('�                 烝烝�  �    �  烝烝   烝烝  �   �   烝烝�  �                 �');
  Wr('�               烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�              �');
  Wr('�               P C   D I A G N O S T I C         S O F T W A R E              �');
  Wr('�                                                                              �');
  Wr('�                                                                              �');
  Wr('�                                                                              �');
  Wr('�                                                                              �');
  Wr('�                                                                              �');
  Wr('�                           Serial Number: XX-XXXXXX                           �');
  Wr('�                                                                              �');
  Wr('�     COPYRIGHT (c) 1988, 1989, 1990 FlintStone Institute of Black Magic       �');
  Wr('�                             ALL RIGHTS RESERVED.                             �');
  Wr('� 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳 �');
  Wr('�                                                                              �');
  Wr('�                                                                              �');
  Wr('藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕');
end;

Procedure Ramecek1;
begin
  Col1; Nul;
  Wr('浜 Check�It 3.0 様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融');
  Wr('�                                                                              �');
  Wr('�                                L O A D I N G                                 �');
  Wr('�                                =============                                 �');
  Wr('�                                                                              �');
  Wr('�                     INVESTIGATING SYSTEM CONFIGURATION.                      �');
  Wr('�                           敖�                                                �');
  Wr('�                           � � Check for Active Viruses                       �');
  Wr('�                           団�                                                �');
  Wr('�                           � � Determine Procesor cooler type                 �');
  Wr('�                           団�                                                �');
  Wr('�                           � � Determine System Components                    �');
  Wr('�                           団�                                                �');
  Wr('�                           � � Look for RAM (Base, Extended, Expanded)        �');
  Wr('�                           団�                                                �');
  Wr('�                           � � Look for Brain                                 �');
  Wr('�                           団�                                                �');
  Wr('�                           � � Look for Stupidity                             �');
  Wr('�                           青�                                                �');
  Wr('� 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳 �');
  Wr('�                                                                              �');
  Wr('�                                                                              �');
  Wr('� 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳 �');
  Wr('�                                                                              �');
  Wr('藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕');
end;

Procedure Skrt;
begin
{ zaskrt }
  Wrp(10,43,4,'�'); Wrx(11,44,4,'�'); Wrp(11,45,4,'�'); Wrx(12,45,4,'�');
  Wrp(12,46,4,'�'); Wrx(13,46,4,'�'); Wrp(13,47,4,'�'); Wrx(12,47,4,'�');
  Wrp(12,48,4,'�'); Wrx(11,48,4,'�'); Wrp(11,49,4,'�'); Wrx(10,49,4,'�');
  Wrx(10,50,4,'�'); Wrp(10,51,15,'�'); Wrx(09,50,4,'�'); Wrp(09,51,4,'�');
  Wrx(08,51,4,'�'); Wrp(08,52,4,'�'); Wrx(07,52,4,'�'); Wrp(07,53,4,'�');
  Wrx(06,53,4,'�'); Wrp(06,54,4,'�'); Wrx(05,54,4,'�'); Wrp(05,55,4,'�');
  Wrp(04,56,4,'�'); Wrp(03,57,4,'�');
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
    Wrx(y-1,a,7 ,'�');
    Wrx(y+1,a,7 ,'�'); {� � � � � �}
  end;
  Wrx(y,x,7,'�');
  Wrx(y,b-1,7,'�');
  Wrx(y-1,x,7,'�');
  Wrx(y+1,x,7,'�');
  Wrx(y-1,b-1,7,'�');
  Wrx(y+1,b-1,7,'�');
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
    Wrx(y+1,a,7 ,' '); {� � � � � �}
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
  Wrx(8,30,15 ,'�');   Wrath(8,22,'Found');
  for pass:=1 to 10 do
  begin
     Tb(10,27,'Step '+inttostr(pass)+' of 10');
     Delay(300);
 end; DelTb(10,27,'Step 10 of 10');
  Wrx(10,30,15,'�');   Wrath(10,24,'Fan');
  for pass:=1 to 10 do
  begin
     Tb(12,27,'Pass '+inttostr(pass)+' of 10');
     Delay(100);
  end; DelTb(12,27,'Pass 10 of 10');
  Wrx(12,30,15 ,'�');  Wrath(12,19,'Complete');
  Tb(14,27,'Searching...'); Delay(1800);
  DelTb(14,27,'Searching...');  Wrx(14,30,15 ,'�');  Wrath(14,20,'Missing');
  Delay(800 );
  Wrx(16,30,15 ,'�');  Wrath(16,20,'Missing');
  Delay(1800);
  Wrx(18,30,15 ,'�');  Wrath(18,20,'Present');
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