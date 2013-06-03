Unit CD;
{ PAPRIKU (toze FARAONE):
Tag sem to skoro dodelal (necekane mala uprava, aby ten tvuj ovladac
hral), ten novej didn't work.
Previjeni: Udelal jsem ho po volitelnejch skocich - konstanta cskip
(v 1/75 sek)
}
interface {------------------------------------------------------------------}
uses crt; {!}
type
  tName = array [1..9] of char;
  tRED  = record  frms, sec, min, nothing : byte;
          end;
  Long32 = Longint;
const
  cskip    = 750; { 10 sekund }

var
  CDstatus  : record { status CD-Mechaniky}
                CDAudio : boolean; { zda umi prehravat CDAudio }
                CDOpen  : boolean; { dvirka otevrena }
                CDRed   : boolean; { podporuje RedBook }
                CDPlaying : boolean; { Prave Hrajeme }
                CDPaused  : boolean; { Prave Pauza }
                status    : longint;
              end;
  CDTime    : record
                cmd     : byte;
                ctrl    : byte;
                cdtrack : byte;
                index   : byte;
                tmin, tsec, tfrm : byte;
                nula    : byte;
                Dmin, Dsec, Dfrm : byte;
              end;
  CDBack    : word;
  CDTrack   : byte;
  CDMscdex  : boolean; { vysledek na kontrolu pritomnosti MSCDEX}
  CDName    : tName;
  CDErr     : byte;
  CDPaused  : boolean;
  CDlowestTrack, CDHighestTrack  : byte;
  CDTrackTab  : array[0..255] of tRED;
  CDTrackType : array[0..255] of byte; { bity 15,14,12 }
  { = 010 je datova stopa jinak:
      000 : dva audiokanaly bez preemfaze
      001 : dva audiokanaly s preemfazi
      100 : 2*000
      101 : 2*001 }

  Function CDChanged : boolean;
  Function REDtoHSG(var l)  : longint;
  Procedure CDPlay;
  Function CDPlaying  : boolean;
  Procedure CDStop;
  Procedure CDPause;     { zastav / pokracuj }
  Function CDGetHeadPosition  : longint; { HSG? T:0 TIME:0:0.0 je 0}
  Procedure CDInc;       { rychle dopredu - viz cskip }
  Procedure CDDec;       { rychle zpet }
  Procedure CDNextTrack; { Dalsi stopa }
  Procedure CDLastTrack; { Predchozi Stopa }
  Procedure CDEject;     { Posun supliku }
  Procedure CDCloseHandle; { zavre handle (na konci pouzivani) }
  Procedure CDLoadParams;  { aktualizuje informace o vlozenem CD }
  Procedure CDReadStatus;
  Procedure CDLoadTime;
  Procedure CDLoadTime1; { univerzalnejsi varianta - tu sem delal ja }
  Function  CDVolumeSize  : long32;{ vraci velikost svazku ve framech - HSG delka CD }
  Procedure HSGtoRED(cdv  : longint;var m);
  Procedure CDGetTotalTime(var m :tRED);
  Function  CDLabel : string; { vraci retezec oznacujici CD }
implementation {-------------------------------------------------------------}
type
  tCDHeader   = record
                    len  : byte;
                    unt  : byte;
                    cmd  : byte;
                    status  : word;
                    reserved : array[1..8] of byte;
                  end;
var
  CDNum  : word; { cislo jednotky CD-ROM }
  CDMCount : word; {pocet jednotek CDROM}
  CDHandle : word;

Procedure GetCDDriverName; {-----------------------------------------------}
{zjistuje jmeno ovladace CD-ROM (/dxx)}
var
  pntr   : pointer;
  drnum,
  x,y    : byte;
  labstr : ^tName;
  CDid   : word;
begin
  asm
    mov ah, 052h
    int 21h
    mov word ptr [pntr], bx
    mov word ptr [pntr+2], es
    mov cx, 22h
  @semka:
    inc word ptr pntr
    loop @semka
  end; { seznam seznamu }
  x:=0;
  repeat
    labstr:=Ptr(seg(pntr^),ofs(pntr^)+$0a);
    cdid  :=Word(Ptr(seg(pntr^),ofs(pntr^)+$04)^);
    if cdid and $C800=$C800 then
    begin
      cdid  :=byte(Ptr(seg(pntr^),ofs(pntr^)+$12)^);
      if cdid=0 then
      begin
        cdid:=byte(Ptr(seg(pntr^),ofs(pntr^)+$14)^)-1;
        if cdid=CDNum then
        begin
          cdid:=byte(Ptr(seg(pntr^),ofs(pntr^)+$15)^) and $FF;
          if cdid=CDMCount then
          begin
            labstr:=Ptr(seg(pntr^),ofs(pntr^)+$0A); { zjistime si jmeno ovladace }
            x:=1;
          end;
        end;
      end;
    end;
    pntr:=pointer(pntr^);
  until (ofs(pntr^)=$0FFFF) or (x=1);
  if x=0 then
  begin
    CDMscdex:=false;
    cdname:='--------'#0;
  end else
  begin
    CDMscdex:=true;
    cdname:=labstr^;
  end;
end; { -------------------------- GetCDDriverName -------------------------- }

Function CDGetHandle  : Byte;
var
  err  : byte;
begin
  asm
    mov ax, 03D22h { cteni a zapis, ostatni programy maji pristup }
    mov dx, offset CDname
    int 21h
    jc @chyba
    mov CDHandle, ax
    mov [err], 0
    jmp @ok
  @chyba:
    mov [err], al
  @ok:
  end;
  CDGetHandle:=err;
end;

Procedure CDCloseHandle; assembler;
asm
  mov ah, 3Eh
  mov bx, CDHandle
  int 21h
end;

Procedure SendToIOCTL(var data;cnt : word); assembler;
{ posle prikaz dos fn. 44 - IOCTL}
asm
    push ds
    mov [CDErr], 0
    mov ax, 4403h   { zapis do znak. zarizeni prez IOCTL}
    mov bx, [CDHandle]
    mov cx, cnt
    lds dx, [data]
    int 21h
    jnc @konec
    mov [CDErr], al
  @konec:
    pop ds
end;

Procedure GetFromIOCTL(var data;cnt : word); assembler;
{ posle prikaz dos fn. 44 - IOCTL}
asm
    push ds
    mov [CDErr], 0
    mov ax, 4402h   { zapis do znak. zarizeni prez IOCTL}
    mov bx, [CDHandle]
    mov cx, cnt
    lds dx, [data]
    int 21h
    jnc @konec
    mov [CDErr], al
  @konec:
    pop ds
end;

Procedure CDSendToDriver(var header); assembler;
{posle prez MSCDEX pozadavek driveru}
asm
  push es
  mov ax, 1510h
  mov cx, CDNum
  les bx, header
  int 2fh
  pop es
end;
{----------------------------------------------------------------------------}
Procedure CDReadStatus;
var
  status : record
              cmd     : byte;
              status  : longint;
           end;
begin
  status.cmd:=06;
  GetFromIOCTL(status,5);
  With status do
  begin
    CDStatus.CDAudio:=Boolean(Status and 16);
    CDStatus.CDOpen:=Boolean(Status and 1);
   { CDStatus.CDPlaying:=Boolean(Status and 1024);}
    CDStatus.CDRed:=Boolean(Status and 512);
    CDStatus.Status:=status;
  end;
end;
{----------------------------------------------------------------------------}
Function CDChanged : boolean;
var
  s  : record
              cmd     : byte;
              status  : byte;
            end;
begin
{  repeat}
    s.cmd:=$09;
    GetFromIOCTL(s,2);
{  until status<>0;}
  CDChanged:=(s.status=$FF);
  CDErr:=s.status;
end;

{----------------------------------------------------------------------------}
Procedure CDGetParams;
var ParH : Record
              cmd              : byte;
              lowest, highest  : byte;
              begsec           : long32;
            end;
begin
  Fillchar(Parh,0,sizeof(parh));
  ParH.cmd:=$0A;
  GetFromIOCTL(ParH,7);
  CDLowestTrack:=ParH.lowest;
  CDHighestTrack:=ParH.highest;
end;
{----------------------------------------------------------------------------}
Function REDtoHSG;
type ttime  = record frm, sec, min, no :  byte; end;
var t  : ^ttime;
    l1  : longint;
begin
  t:=@l;
  l1:=(longint(t^.frm)+75*longint(t^.sec)+4500*longint(t^.min)){-150};
  REDtoHSG:=l1;
end;
{----------------------------------------------------------------------------}
Procedure HSGtoRED;
var p : ^tRed;
begin
  p:=@m;
  {if cdv>=0 then}
  with p^ do
  begin
    min:=cdv div 4500;
    cdv:=cdv-(longint(min)*4500);
    sec:=cdv div 75;
    cdv:=cdv-sec*75;
    frms:=cdv;
    nothing:=0;
  end{ else Fillchar(p^,4,0)};
end;

{----------------------------------------------------------------------------}
Procedure CDGetTrackTab;
{ zjistuje pocatecni sektory stop }
var ParH : Record
              cmd              : byte;
              trknum           : byte;
              trkbegsec        : tRED;
              info             : word{byte ?};
            end;
      x,y  : byte;
begin
  parh.cmd:=$0B;
  for x:=CDLowestTrack to CDHighestTrack do
  begin
    parh.trknum:=x;
    GetFromIOCTL(ParH,7);
    CDTrackTab[x]:=ParH.TrkBegSec;
    CDTrackType[x]:=ParH.info and $80 shr 6
                   +ParH.info and $40 shr 5
                   +ParH.info and $10 shr 3;
  end;
 { readkey;}
  HSGtoRED(CDVolumesize+REDtoHSG(CDTrackTab[CDLowestTrack]),
           CDTrackTab[CDHighestTrack+1]);
end;
{----------------------------------------------------------------------------}
Procedure CDLoadParams;
begin
  CDGetParams;
  CDGetTrackTab;
end;
{----------------------------------------------------------------------------}
Procedure CDPlayFrom(var a : tred);
var PlayH : Record
              header   : tCDHeader;
              AdrStyle : byte; {00 sierra / 01 red book}
              begsec   : long32;
              numsec   : long32;
            end;
begin
  with PlayH do
  begin
    with header do
    begin
      cmd:=$84;
      len:=sizeof(PlayH);
    end;
    AdrStyle:=01;
    Move(a,begsec,4);
    numsec:=CDVolumeSize-REDtoHSG(a);
  end;
  CDSendToDriver(PlayH);
  CDBack:=PlayH.header.status;
  cdstatus.cdplaying:=((CDBack and $8000=0) and (CDBack and $100<>0));
  { z header.status se da precist, zda-li byla operace uspena - Viz sysman }
end;
{----------------------------------------------------------------------------}
Procedure CDPlay;
begin
  CDPlayFrom(CDTrackTab[CDTrack]);
end;
{----------------------------------------------------------------------------}
Function CDPlaying;
var a,b,c  : longint;
begin
  a:=CDGetHeadPosition;
  delay(600);
  b:=CDGetHeadPosition;
  delay(600);
  c:=CDGetHeadPosition;
  if c-a<75 then c:=a;
  CDPlaying:=(a<b) and (b<c);
end;
{----------------------------------------------------------------------------}
Procedure CDStop;
var StopH : tCDHeader;
begin
  StopH.cmd:=$85;
  StopH.len:=$0d;
  CDSendToDriver(StopH);
  CDBack:=StopH.status;
  cdstatus.cdplaying:=false;
end;
{----------------------------------------------------------------------------}
Procedure CDPause;
var
  h  : tcdheader;
begin
  if not cdstatus.cdpaused then
  begin
    CDStop;
    cdstatus.cdplaying:=true;
    cdstatus.cdpaused:=true;
  end else
  begin
    h.cmd:=$88;
    h.len:=sizeof(h);
    CDSendToDriver(h);
    CDBack:=H.status;
    cdstatus.cdplaying:=true;
    cdstatus.cdpaused:=false;
  end;
end;
{----------------------------------------------------------------------------}
Function CDBegining  : long32; {v HSG}
begin
  CDBegining:=REDtoHSG(CDTrackTab[CDLowesttrack]);
end;
{----------------------------------------------------------------------------}
Function CDGetHeadPosition  : longint;
var bafr : record
             cmd   : byte;
             adr   : byte;
             pos   : tred;
           end;
begin
  { precteme polohu hlavicky }
  Fillchar(bafr, sizeof(bafr),0);
  bafr.adr:=0; bafr.cmd:=1;
  GetFromIOCTL(bafr,6);
  CDGetHeadPosition:=long32(bafr.pos);
end;
{----------------------------------------------------------------------------}
Procedure CDInc;
var
  a    : tred;
  pos  : longint;
begin
  { a nastavime ji o kus dal }
  pos:=CDGetHeadPosition;
  HSGtoRED(CDBegining+pos+cskip,a);
  CDStop;
  CdPlayFrom(a);
end;
{----------------------------------------------------------------------------}
Procedure CDDec;
var
  a    : tred;
  pos  : longint;
begin
  { a nastavime ji o kus spatky }
  pos:=CDGetHeadPosition;
  HSGtoRED(CDBegining+pos-cskip,a);
  CDStop;
  CdPlayFrom(a);
end;
{----------------------------------------------------------------------------}
Procedure CDNextTrack;
var
  p  : boolean;
begin
  p:=false;
  if cdstatus.cdplaying then
  begin
    p:=true;
    CDStop;
  end;
  if cdtrack<cdhighesttrack then
  begin
    Inc(CDTrack);
    if p then CDPlay;
  end;
end;
{----------------------------------------------------------------------------}
Procedure CDLastTrack;
var
  p  : boolean;
begin
  p:=false;
  if cdstatus.cdplaying then
  begin
    p:=true;
    CDStop;
  end;
  if cdtrack>cdlowesttrack then
  begin
    Dec(CDTrack);
    if p then CDPlay;
  end;
end;

{----------------------------------------------------------------------------}
Procedure CDEject;
const
  Eject : array[0..1] of byte = ($05,00);
begin
  CDReadStatus;
  SendToIOCTL(Eject[byte(not cdstatus.cdopen)],1);
end;
{----------------------------------------------------------------------------}
Procedure CDLoadTime;
begin
  CDReadStatus;
  CDTime.cmd:=$0C;
  if cdstatus.cdplaying then GetFromIOCTL(CDTime,sizeof(CDtime))
  else with CDTime do
  begin
    index:=1; tmin:=0; tsec:=0;
    tfrm:=0; Dmin:=0; Dsec:=0; Dfrm:=0;
  end;
end;
{----------------------------------------------------------------------------}
Procedure CDLoadTime1;
{ tohle je moje varianta, ktera by mela pracovat vsude, ale neumi index }
var
  l,m  : longint;
  x  : byte;
  fuJ  : TRED;
begin
  CDReadStatus;
  l := CDGetHeadPosition;
  HSGtoRED(l,TRed(m));
{ Zapiseme si cas CD }
  with cdtime do
  begin DMin:=TRed(m).min; DSec:=TRed(m).sec; DFrm:=TRed(m).frms;
  end;
{ ok, ted proskenujeme, kolikata pisnicka to je }
  x:=0;
  m:=0;
  repeat
    inc(x);
    m:=REDtoHSG(CDTrackTab[x+1])-CDbegining;
  until (l<m) or (x>CDHighesttrack);
  if x>CDHighesttrack then
  begin
    cdhighesttrack:=0;
    cdlowesttrack:=0;
  end;
  l:=l+CDbegining-REDtoHSG(CDTrackTab[x]);
{ ok, Ted je v x cislo pisnicky a v l cas pisnicky v HSG }
  HSGtoRED(l,TRed(l));
  with cdtime do
  begin tMin:=TRed(l).min; tSec:=TRed(l).sec; tFrm:=TRed(l).frms;
  end;
  if cdstatus.cdplaying then cdtrack:=x;
end;

{----------------------------------------------------------------------------}
Function CDVolumeSize  : long32;
var
   size  : record
             fn  : byte;
             size : long32;
           end;
begin
  size.fn:=08;
  GetFromIOCTL(size,5);
  CDVolumeSize:=size.size;
end;
{----------------------------------------------------------------------------}
Procedure CDGetTotalTime;
var
  CDV  : longint;
begin
  cdv:=cdvolumesize;
  HSGtoRED(cdv,m);
end;
{----------------------------------------------------------------------------}
Function ToHex(l:longint; h : boolean):string;
{ tuhle funkci to chce povopravit aby vracela signed pouze kdyz je
arg<longint }
const
 table:array[0..15] of char=
       ('0','1','2','3','4','5','6','7','8','9',
        'A','B','C','D','E','F');
var
 str   : string;
 minus : boolean;
begin
 str:=''; if l<0 then minus:=true else minus:=false;
 if minus then l:=abs(l);
 repeat
  str:=table[l and $F]+str;
  l:=l shr 4;
 until l=0;
 if odd(length(str)) then str:='0'+str;
 if h then str:='0'+str+'h';
 if minus then str:='-'+str;
 ToHex:=str;
end;
{----------------------------------------------------------------------------}
Function  CDLabel;
{
Slepime to z CDVolumesize a CDTracks
}
var s,k : string[10];
    x   : byte;
begin
  {Str(Cdvolumesize:8,s);}
  s:='00000000';
  s:=ToHEX(Cdvolumesize,false);
  s[0]:=#8;
  for x:=1 to 8 do if not (s[x] in ['0'..'9','A'..'F']) then s[x]:='0';
  {Str(CDHighestTrack:2,k);}
  k:=ToHEX(CDHighestTrack, false);
  for x:=1 to 2 do if k[x]=' ' then s[x]:='0';
  CDlabel:=s+k;
end;
{ - - - - - M A I N - - - - }
var x  : byte;
begin
{  crt.clrscr;
  Writeln('ษออออออออออออออออออออออออออป');
  Writeln('บ  UNIT CD v1.00 by Volca  บ');
  Writeln('ศออออออออออออออออออออออออออผ');}
  asm {tady testuju pritomnost MSCDEX a cislo 1. jednotky }
    mov [CDMSCDEX], 0
    mov ax, 0DADAh
    push ax
    mov ax, 1100h
    int 2fh
    cmp al, 0FFh
    jne @netreba
    pop ax
    mov [CDMSCDEX], 1
    mov ax, 1500h
    xor bx, bx
    int 2fh
    mov CDnum, cx
    mov CDMCount, bx
   @netreba:
  end; {je-li instalovan MSCDEX?}
  GetCDdriverName;
{  if CDMSCDEX then Writeln('Pocet CD-ROM jednotek : ',CDMCount) else
                   Writeln('Nenalezen MSCDEX...');}
  for x:=1 to length(cdname) do cdname[x]:=upcase(cdname[x]);
  cdname[9]:=#0;
{  Write('Nazev ovlace CD-ROM : ', cdname);}
  CDGetHandle;
{  Writeln(' GETHANDLE : ', DosError[CDGetHandle]);}
{  cdhandle:=5;}
  { ZATIM }
  cdstatus.cdpaused:=false;
end.