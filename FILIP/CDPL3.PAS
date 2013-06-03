uses cd,crt;
const cx=45;
      cy=10;
Procedure Controlls;
begin
  gotoxy(cx,cy);
  Write('Ovladani na numericke klavesnici');
  gotoxy(cx,cy+1);
  Write(' þ  º  '+#16);
  gotoxy(cx,cy+2);
  Write('³'#17'     '#16'³');
  gotoxy(cx,cy+3);
  Write(#17#17'  '#24'  '#16#16);
end;
function I2S(I: Longint): String;
var
  S  : string[11];
  x  : byte;
begin
  Str(I, S);
  if odd(length(s)) then s:='0'+s;
  I2S := S;
end;

Procedure TimeWrite(var l);
type
  time = record
            frm,sec, min  : byte;
         end;
var
  t  : ^time;
  s  : string;
begin
  t:=@l;
  s:=I2S(t^.min)+':'+I2S(t^.sec){$IFDEF FRAMES}+'.'+I2S(t^.frm){$ENDIF};
  Write(s);
end;

var
  ch  : char;
  l   : longint;
  b   : byte;
  cdv : longint;
  m   : tRED;
begin
 clrscr;
 b:=0;
 textattr:=07;
 CDLoadParams;
 cdstatus.cdplaying:=cdplaying;
 Controlls;
 repeat
   if cdtrack=0 then cdtrack:=1;
   if keypressed then ch:=upcase(readkey) else ch:='`';
   if ch='9' then if CDTrackType[cdtrack]=0 then CDPlay;
   if ch='8' then CDPause;
   if ch='7' then CDStop;
   if ch='6' then CDNextTrack;
   if ch='4' then CDLastTrack;
   if ch='3' then CDInc;
   if ch='2' then CDEject;
   if ch='1' then CDDec;
   CDReadStatus;
   if not cdstatus.cdopen then
   begin
     CDLoadtime1;
     Gotoxy(1,10);
     if cdchanged then
     begin
       clrscr;
       CDLoadParams;
       cdstatus.cdplaying:=false;
       cdstatus.cdpaused:=false;
       cdtrack:=CDLowestTrack;
     end;
     gotoxy (1,1); textattr:=2;
     case cdstatus.cdplaying of
        false:  Write('þ');
        true: if not cdstatus.cdpaused then Write(#16) else Write('º');
     end;
     textattr:=7;
     Write(' ',I2S(cdtrack));
     Gotoxy(1,2);
     Write('Cas: ');
     textattr:=3;
     if cdstatus.cdplaying then
         Write(I2S(Cdtime.tmin),':',I2S(Cdtime.tsec),'.',I2S(CDTime.tfrm))
         else
         Write('00:00.00');
     textattr:=7;
     if cdtrack<>0 then
     begin
       Write(' z ');
       textattr:=3;
       HSGtoRED(REDtoHSG(CDTrackTab[CDTrack+1])-
                REDtoHSG(CDTrackTab[CDTrack]),m);
       TimeWrite(m); Write(' ');
     end;
     textattr:=7;
     gotoxy (1,3); Write('Celkova delka CD: ');
     textattr:=4;
     CDGetTotalTime(m); TimeWrite(m);
     textattr:=7;
     Gotoxy(1,4); Write('Oznaceni CD : ');
     textattr:=5;
     Write(CDlabel:10);
     textattr:=7;
     Gotoxy(1,5); Write('Nazev CD    : ');
     { vypis nazvu CD }
     textattr:=5;
     if CDLabel= '0417ED000E' then Write('Romeo & Julie,  Sergej Prokofjev');
     if CDLabel= '04F992000D' then Write('Trainspotting                   ');
     if CDLabel= '02D4DD0007' then Write('Oxygene 7-13                    ');
     {}
     textattr:=7;
     gotoxy (1,6); Writeln('Stopy ',cdlowesttrack:3,' - ',cdhighesttrack:3);
     for b:=cdlowesttrack to cdhighesttrack do
     begin
       if cdtrack=b then textattr:=1 else textattr:=7;
       Write(I2S(b),' t:',cdtracktype[b]:3,' ');
       HSGtoRED(REDtoHSG(CDTrackTab[b+1])-
                REDtoHSG(CDTrackTab[b]),m);
       TimeWrite(m);
       Writeln;
     end;
     {if b<cdtime.tfrm then b:=cdtime.tfrm;}
     if cdvolumesize=0 then Write('No CD') else Write('CD in');
   end;
 until ch=#27;
 CDCloseHandle;
end.