unit ToAsm;
interface
{uses math,crt;}
{$DEFINE HEXA}
Procedure Decode  (p:pointer; var output : string; var addto:byte);
Function  ToHex   (l:longint;h : boolean)  : string; { prevede cislo na formatovany retezec}
Procedure IncPtr  (var p; n  : byte); { zvysuje pointer o n (v bajtech)}
Function  ZeroFill (s:string; n: byte)  : string; { doplni string o 0 na zacatek }

var
  ASMfilepos : longint;
  expand    : boolean;
  jmp       : boolean; { nastaveno po Decode, pokud instrukce meni IP}
  jmpAddr   : longint; { vraci pokud je to instrukce skoku offset
                         (zacatek souboru je 0) - pro relativni adresu
                         odecti filepos}
implementation {@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@}
uses Base;
const
  npref  = 13;
  Cprefix : array [1..npref] of byte=
         ($F3,$F2,$F1,$F0,$2E,$36,$3E,$26,$64,$65,$66,$67,$0F);
  PrefStr : array [1..npref] of string[6]=
         ('REP ','REPZ ','REPNZ ','LOCK '
          ,'CS:','SS:','DS:','ES:','FS:','GS:','','','');

  tabscale : array [0..3] of string[2]=('','*2','*4','*8');
  regz     : array [1..3,0..7] of string[3] =
     (('AL','CL','DL','BL','AH','CH','DH','BH'),
      ('AX','CX','DX','BX','SP','BP','SI','DI'),
      ('EAX','ECX','EDX','EBX','ESP','EBP','ESI','EDI'));
  SegRegz  : array [0..7] of string [2]=
      ('ES','CS','SS','DS','FS','GS','??','??');
  tab16 : array [0..7] of string[7] =
      ('[BX+SI]','[BX+DI]','[BP+SI]','[BP+DI]','[SI]','[DI]','[BP]','[BX]');
  tab32 : array [0..7] of string[5] =
      ('[EAX]','[ECX]','[EDX]','[EBX]','!SIB!','[EBP]','[ESI]','[EDI]');

  nm2r = 10;
  txtm2r : array [1..nm2r] of string[5]=
       ('ADD ','ADC ','AND ','XOR ',
        'TEST ','OR ','SBB ','SUB ',
        'CMP ','MOV ');

  c16bitm2r : array [1..nm2r] of byte =
       ($01,$11,$21,$31,$85,$09,$19,$29,$39,$89);
  c8bitm2r  : array [1..nm2r] of byte =
       ($00,$10,$20,$30,$84,$08,$18,$28,$38,$88);

  NR2M = 10;
  txtr2m : array [1..Nr2m] of string[5]=
       ('ADD ','ADC ','AND ','XOR ',
        'XCHG ','OR ','SBB ','SUB ',
        'CMP ','MOV ');
  c16bitr2m : array [1..Nr2m] of byte =
       ($03,$13,$23,$33,$87,$0B,$1B,$2B,$3B,$8B);
  c8bitr2m  : array [1..Nr2m] of byte =
       ($02,$12,$22,$32,$86,$0A,$1A,$2A,$3A,$8A);

  nno  = 100;
  NoOpe  : array [1..nno] of byte =
      ($06,$07,$16,$17,$27,$37,$40,$41,$42,$43,$44,$45,$46,$47,
       $50,$51,$52,$53,$54,$55,$56,$57,$60,$61,$90,$91,$92,$93,  {28}
       $94,$95,$96,$97,$A4,$A5,$A6,$A7,$C3,$F4,$F5, {39}
       $0E,$1E,$1F, {}
       $2F,$3F,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,$58,$59,$5A,$5B,
       $5C,$5D,$5E,$5F,$6C,$6D,$6E,$6F,$98,$99,$9B,$9C,$9D,$9E,$9F,
       $AA,$AB,$AC,$AD,$AE,$AF,$C9,$CB,$CC,$CE,$CF,$D8,$D9,$DA,
       $DB,$DC,$DD,$DE,$DF,$EC,$ED,$EE,$EF,$F8,$F9,$FA,$FB,$FC,
       $FD);

  TxtNoOpe : array [1..nno] of string[10]=
  ('PUSH ES','POP ES','PUSH SS','POP SS','DAA','AAA','INC AX',
   'INC CX','INC DX','INC BX','INC SP','INC BP','INC SI','INC DI',
   'PUSH AX','PUSH CX','PUSH DX','PUSH BX','PUSH SP','PUSH BP','PUSH SI',
   'PUSH DI','PUSHA','POPA','NOP','XCHG AX,CX','XCHG AX,DX','XCHG AX,BX',
   'XCHG AX,SP','XCHG AX,BP','XCHG AX,SI','XCHG AX,DI','MOVSB','MOVSW',
   'CMPSB','CMPSW','RET','HALT','CMC','PUSH CS','PUSH DS','POP DS','DAS',
   'AAS','DEC AX','DEC CX','DEC DX','DEC BX','DEC SP','DEC BP',
   'DEC SI','DEC DI','POP AX','POP CX','POP DX','POP BX','POP SP',
   'POP BP','POP SI','POP DI','INSB','INSW','OUTSB','OUTSB',
   'CBW','CWD','WAIT','PUSHF','POPF','SAHF','LAHF','STOSB','STOSW',
   'LODSB','LODSW','SCASB','SCASW',{C9}'LEAVE','RET','INT 3',
   'INTO','IRET','ESC 0','ESC 1','ESC 2','ESC 3','ESC 4','ESC 5','ESC 6',
   'ESC 7','IN AL, DX','IN AX, DX','OUT DX, AL','OUT DX, AX','CLC','STC',
   'CLI','STI','CLD','STD');

   TxtNoOpeD : array [1..nno] of string[10]=
  ('PUSH ES','POP ES','PUSH SS','POP SS','DAA','AAA','INC EAX',
   'INC ECX','INC EDX','INC EBX','INC ESP','INC EBP','INC ESI','INC EDI',
   'PUSH EAX','PUSH ECX','PUSH EDX','PUSH EBX','PUSH ESP','PUSH EBP','PUSH ESI',
   'PUSH EDI','PUSHAD','POPAD','NOP','XCHG EAX,ECX','XCHG EAX,EDX','XCHG EAX,EBX',
   'XCHG EAX,ESP','XCHG EAX,EBP','XCHG EAX,ESI','XCHG EAX,EDI','MOVSB','MOVSD',
   'CMPSB','CMPSD','RET','HALT','CMC','PUSH CS','PUSH DS','POP DS','DAS',
   'AAS','DEC EAX','DEC ECX','DEC EDX','DEC EBX','DEC ESP','DEC EBP',
   'DEC ESI','DEC EDI','POP EAX','POP ECX','POP EDX','POP EBX','POP ESP',
   'POP EBP','POP ESI','POP EDI','INSB','INSD','OUTSB','OUTSD',
   'CBW','CWD','WAIT','PUSHFD','POPFD','SAHF','LAHF','STOSB','STOSD',
   'LODSB','LODSD','SCASB','SCASD',{C9}'LEAVE','RET','INT 3',
   'INTO','IRET','ESC 0','ESC 1','ESC 2','ESC 3','ESC 4','ESC 5','ESC 6',
   'ESC 7','IN AL, DX','IN EAX, DX','OUT DX, AL','OUT DX, EAX','CLC','STC',
   'CLI','STI','CLD','STD');

  NbyteOpe = 23;
  NbyteOpeNoComma = NbyteOpe-1; { prvni bez ","}
  ByteOpe : array [1..NByteOpe] of byte=
  ($04,$14,$24,$34,$B0, $B1,$B2,$B3,$B4, $B5,$B6,$B7,$E4, $E5,$E6,$E7,$0C,
   $1C,$2C,$3C, $A8,{ a bez carky:} $6A, $CD);
  TxtByteOpe  : array [1..NByteOpe] of string[7]=
  ('ADD AL','ADC AL','AND AL','XOR AL','MOV AL','MOV CL',
   'MOV DL','MOV BL','MOV AH','MOV CH','MOV DH','MOV BH',
   'IN AL','IN AX' ,'OUT AL','OUT AX','OR AL','SBB AL',
   'SUB AL','CMP AL','TEST AL','PUSH ','INT ');

  NWordOpe = 20;
  NWordOpeNoComma = NWordOpe;
  WordOpe : array [1..NWordOpe] of byte=
  ($05,$15,$25,$35, $B8,$B9,$BA,$BB, $BC,$BD,$BE,$BF, $C2,$CA,
   $0D,$1D,$2D,$3D, $A9,$68);
  TxtWordOpe  : array [1..NWordOpe] of string[7]=
  ('ADD AX','ADC AX','AND AX','XOR AX','MOV AX','MOV CX','MOV DX',
   'MOV BX','MOV SP','MOV BP','MOV SI','MOV DI', 'RET ','RET ',
   'OR AX' ,'SBB AX','SUB AX','CMP AX','TEST AX','PUSH ');
  TxtWordOpeD  : array [1..NWordOpe] of string[8]=
  ('ADD EAX','ADC EAX','AND EAX','XOR EAX','MOV EAX','MOV ECX','MOV EDX',
   'MOV EBX','MOV ESP','MOV EBP','MOV ESI','MOV EDI', 'RET ','RET ',
   'OR EAX' ,'SBB EAX','SUB EAX','CMP EAX','TEST EAX','PUSH ');

  NJmpS = 21;
  JmpS : array [1..NJmps] of byte=
  ($70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7A,$7B,$7C,$7D,$7E,$7F,
   $EB,$E0,$E1,$E2,$E3);
  TxtJmpS  : array [1..NJmps] of string[7]=
  ('JO ','JNO ','JB ','JAE ','JE ','JNE ','JNA ','JA ','JS '
  ,'JNS ','JP ','JNP ','JL ','JNL ','JLE ','JNLE ','JMPS ',
  'LOOPNE ','LOOPE ','LOOP ', 'JCXZ ');

  NJmpN = 2;
  JmpN : array [1..NJmpN] of byte=
  ($E8,$E9);
  TxtJmpN  : array [1..NJmpN] of string[7]=
  ('CALL ','JMP ');

  nNO2B = 8;
  NoOpe2Byte: array [1..nNO2B] of byte=($D8,$D9,$DA,
       $DB,$DC,$DD,$DE,$DF);

  Shift : array [0..3] of string[3]=('ROL','ROR','SHL','SHR');
  Arop  : array [0..3] of string[3]=('ADD','OR','AND','CMP');
  grp12 : array [0..3] of string[3]=('DIV','DIV','MUL','MUL');
  grp23 : array [0..3] of string[3]=('INC','INC','DEC','DEC');

{  NOneOpe = ;
  OneOpe = array [1..NOneOpe] of byte =
   ($,$,$,$,);
  TxtOneOpe}
var
  inArr    : byte;
  getread  : word;
  ope      : byte;
  segreg   : boolean;

Function  ZeroFill (s:string; n: byte)  : string;
var
  st  : string;
  x   : byte;
begin
  st:=s;
  if n>length(st) then
    for x:=1 to n-length(s) do st:='0'+st;
  ZeroFill:=st;
end;

Procedure IncPtr(var p; n  : byte);
begin
  asm
      les di, p
      mov cl, n
      xor ch, ch
   @l: inc word ptr es:[di]
      loop @l
      mov word ptr p, di
      mov word ptr [p+2], es
  end;
end;
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
Function InNoOpe2Byte(p  : Byte) : boolean;
var
  a,b  : byte;
begin b:=0;
  for a:=1 to nNO2B do
  begin
    if NoOpe2Byte[a]=p then b:=a;
  end;
  inarr:=b;
  InNoOpe2Byte:=(b<>0);
end;

{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
Function InC16BitM2R(p  : Byte) : boolean;
var
  a,b  : byte;
begin b:=0;
  for a:=1 to nm2r do
  begin
    if C16BitM2R[a]=p then b:=a;
  end;
  inarr:=b;
  InC16BitM2R:=(b<>0);
end;
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
Function InC8BitM2R(p  : Byte) : boolean;
var
  a,b  : byte;
begin b:=0;
  for a:=1 to NM2R do
  begin
    if C8BitM2R[a]=p then b:=a;
  end;
  inarr:=b;
  InC8BitM2R:=(b<>0);
end;
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
Function InC16BitR2M(p  : Byte) : boolean;
var
  a,b  : byte;
begin b:=0;
  for a:=1 to NR2M do
  begin
    if C16BitR2M[a]=p then b:=a;
  end;
  inarr:=b;
  InC16BitR2M:=(b<>0);
end;
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
Function InC8BitR2M(p  : Byte) : boolean;
var
  a,b  : byte;
begin b:=0;
  for a:=1 to NR2M do
  begin
    if C8BitR2M[a]=p then b:=a;
  end;
  inarr:=b;
  InC8BitR2M:=(b<>0);
end;
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
Function InNoOpe(p  : Byte) : boolean;
var
  a,b  : byte;
begin b:=0;
  for a:=1 to nno do
  begin
    if noope[a]=p then b:=a;
  end;
  inarr:=b;
  InNoOpe:=(b<>0);
end;
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
Function InByteOpe(p  : Byte) : boolean;
var
  a,b  : byte;
begin b:=0;
  for a:=1 to NByteOpe do
  begin
    if ByteOpe[a]=p then b:=a;
  end;
  inarr:=b;
  InByteOpe:=(b<>0);
end;

{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
Function InWordOpe(p  : Byte) : boolean;
var
  a,b  : byte;
begin b:=0;
  for a:=1 to NWordOpe do
  begin
    if WordOpe[a]=p then b:=a;
  end;
  inarr:=b;
  InWordOpe:=(b<>0);
end;
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
Function InJmpS(p  : Byte) : boolean;
var
  a,b  : byte;
begin b:=0;
  for a:=1 to NJmpS do
  begin
    if JmpS[a]=p then b:=a;
  end;
  inarr:=b;
  InJmpS:=(b<>0);
end;
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
Function InJmpN(p  : Byte) : boolean;
var
  a,b  : byte;
begin b:=0;
  for a:=1 to NJmpN do
  begin
    if JmpN[a]=p then b:=a;
  end;
  inarr:=b;
  InJmpN:=(b<>0);
end;

{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
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

{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

Function GetBits(from  : byte; lowbit, nbit : byte):byte;
{
  protlacenim byte skrze tuto fci. dostaneme fragment
  od low bitu nahoru v poctu nbit
}
const filter : array [0..8] of byte = (0,1,3,7,15,31,63,127,255);
begin
  GetBits:= (from shr lowbit) and filter[nbit];
end;
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

Procedure GetParams( where:pointer; itype: byte; var o1, o2 : string; addch:boolean; prefix: byte);
{
  where je pocatek instrukce (pokud je prefix, tak za nim)
  itype  je z  [byte, dword] (1..2)
  o1, o2 jsou parametry
  ( nektery instrukce si to prohazujou )
  o2  : registr
  o1  : R/M
  addch : zmena velikosti adresy (z 16 na 32 bitu)
}
var
  ModRM  : ^byte;
  SIB    : ^byte;
  SIBp   : boolean;
  pWord  : ^word;
  pByte  : ^byte;
  pShort : ^shortint;
  plong  : ^longint;
  md, reg, rm : byte;
  SS, Index, Base : byte;
begin
  getread:=0;
  o1:=''; o2:='';
  {asm inc word ptr where end;}
  inc(itype,byte(expand));
  IncPtr(where,1);
  ModRM:= where;
  Md := GetBits(ModRM^,6,2);
  reg:= GetBits(ModRM^,3,3);
  rm := GetBits(ModRM^,0,3);
  ope := ModRM^;
  if segreg then o2:=SegRegz[reg] else o2 := regz[itype, reg];
  if not AddCh then
  begin
    if MD=0 then
    begin
      if RM=6 then { je to primej word }
      begin
        pWord := Where;  IncPtr(pWord,1);
        o1:=ToHex(pWord^, true); getread:=2;
        o1:='['+o1+']';
      end else o1:=tab16[RM];
    end else
    if MD=1 then
    begin
      o1:=tab16[RM]; getread:=1;
      pShort := Where; IncPtr(pShort,1);
      o1:=o1+'['+ToHex(pShort^, true)+']';
    end else
    if MD=2 then
    begin
      o1:=tab16[RM]; getread:=2;
      pWord := Where; IncPtr(pWord,1);
      o1:=o1+'['+ToHex(pWord^,true)+']';
    end;
    if MD=3 then o1:=regz[itype,RM];
  end else
  begin  { je to 32 bit!}
    SIBp:=false;
    if (RM=4) and (MD<3) then { rozlozime si SIB }
    begin
      SIBp:=true;
      SIB:=where;
      asm
        Inc word ptr SIB
{        Inc word ptr SIB}
      end;
      SS    := GetBits(sib^,6,2);
      Base  := GetBits(sib^,3,3);
      Index := GetBits(sib^,0,3);
    end;
    { svihneme si disp.! }
    if MD=1 then { mame disp8 }
    begin
      pByte:=Where; getread:=1;
      IncPtr(pByte, 2 + byte(SIBp));
      o1:='['+tohex(pbyte^,true)+']';
    end;
    if (MD=2) then { mame disp32 }
    begin
      pLong:=Where; getread:=4;
      IncPtr(pLong,2 + byte(SIBp));
      o1:='['+tohex(pLong^,true)+']';
    end;
    { tak... uff ted si tam dame [EBP] a index }
    if (MD in [1,2]) and SIBp then
         o1:='['+regz[3,index]+']'+'['+regz[3,base]+']'+TabScale[ss]+o1 else
    if (md=0) and SIBp then
    begin
      if base<>5 then o1:=TabScale[ss]+'['+regz[3,base]+']'+o1;
      o1:='['+regz[3,index]+']'+o1;
    end;
    if MD=3 then o1:=regz[3,RM]; { je to jasne! }
  end;
  if prefix in [5..npref] then o1:=PrefStr[prefix]+o1;
{  case itype+byte(addch) of
    1:  o1:='b,'+o1;
    2:  o1:='w,'+o1;
    3:  o1:='d,'+o1;
  end;}
end;

{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

Procedure Decode(p:pointer; var output : string; var addto:byte);
var
  pByte : ^byte;
  pShort: ^shortint;
  pWord : ^word;
  pInt  : ^Integer;
  pLong : ^longint;
  a,b,c   :  byte;
  par1, par2 : string[20];
begin
  output:=''; addto:=0; segreg:=false; jmp:=false; expand:=false;
  { vyresime, jestli instrukce nema prefix }
  pByte:=p; c:=0;
  repeat
    b:=0;
    for a:=1 to npref do
    begin
      if CPrefix[a]=pbyte^ then b:=a;
    end;
    if b<>0 then
    begin
      if b in [1..4] then output:=PrefStr[b];
      IncPtr(p,1);
      pbyte:=p;
      Inc(addto);
    end;
    if b<>0 then if CPrefix[b]=$66 then expand:=true;
    if b<>0 then c:=b;
  until b=0;
  { jedeme dal }
  if b=0 then b:=c;
  if b=$66 then b:=0;
  if b<>0 then a:=CPrefix[b] else a:=0;
  if InC16BitM2R(pByte^) then
  begin
    output:=output+txtM2R[inArr];
    GetParams(p,2, par1, par2, (a=$67), b);
    output:=output+par1+', '+par2;
    Inc(addto,2+GetRead);
  end else
  if InC8BitM2R(pByte^) then
  begin
    output:=output+TxtM2R[inArr];
    GetParams( p, 1, par1, par2, (a=$67), b);
    output:=output+par1+', '+par2;
    Inc(addto,2+GetRead);
  end else
  if InC16BitR2M(pByte^) then
  begin
    output:=output+txtR2M[inArr];
    GetParams(p,2, par1, par2, (a=$67), b);
    output:=output+par2+', ';
    output:=output+par1;
    Inc(addto,2+GetRead);
  end else
  if InC8BitR2M(pByte^) then
  begin
    output:=output+TxtR2M[inArr];
    GetParams( p, 1, par1, par2, (a=$67), b);
    output:=output+par2+', ';
    output:=output+par1;
    Inc(addto,2+GetRead);
  end else
  if InNoOpe(pByte^) then
  begin
    if expand then output:=output+TxtNoOpeD[inArr]
              else output:=output+TxtNoOpe[inArr];
    if InNoOpe2Byte(pByte^) then Inc(addto,1);
    Inc(addto,1);
  end else
  if InByteOpe(pByte^) then
  begin
    output:=output+TxtByteOpe[inArr];
    IncPtr(pByte,1);
    if InArr<NbyteOpeNoComma then output:=output+', ';
    output:=output+ToHex(pByte^,true);
    Inc(addto,2);
  end else
  if InWordOpe(pByte^) then
  begin
    case expand of
       false:
         begin
           output:=output+TxtWordOpe[inArr];
           pWord:=@pByte^;
           IncPtr(pWord,1);
           if InArr<NWordOpeNoComma then output:=output+', ';
           output:=output+ToHex(pWord^,true);
           Inc(addto,3);
        end;
      true:
        begin
          output:=output+TxtWordOpeD[inArr];
          pLong:=@pByte^;
          IncPtr(pLong,1);
          if InArr<NWordOpeNoComma then output:=output+', ';
          output:=output+ToHex(pLong^,true);
          Inc(addto,5);
        end;
    end;
  end else
  if InJmpS(pByte^) then { jmp short }
  begin
    jmp:=true;
    output:=output+TxtJmpS[inArr];
    pShort:=@pByte^;
    IncPtr(pShort,1);
    Inc(addto,2);
    jmpaddr:=ASMFilepos+pShort^+addto;
    output:=output+ZeroFill(ToHex(ASMFilepos+pShort^+addto,true),9);
  end else
  if InJmpN(pByte^) then { jmp near apod }
  begin
    jmp:=true;
    output:=output+TxtJmpN[inArr];
    pInt:=@pByte^;
    IncPtr(pInt,1);
    Inc(addto,3);
    jmpaddr:=ASMFilepos+pInt^+addto;
    output:=output+ZeroFill(ToHex(addto+ASMfilepos+pInt^,true),9);
  end else
  if pByte^ in [$C0..$C1,$D0..$D3] then {!! rotace !!-----------}
  begin
    GetParams( p, 1+byte(odd(pByte^)), par1, par2, (a=$67), b);
    ope:=GetBits(ope,5,1) shl 1+GetBits(ope,3,1);
    output:=output+shift[ope]+' '+par1;
    Inc(Addto, 2+getread);
    case pByte^ of
       $C0,$C1  :
         begin { im8 }
           IncPtr(pByte,2+getread);
           output:=output+', '+toHex(pbyte^,true);
           Inc(Addto, 1);
         end;
       $D0,$D1  : output:=output+', 1';
       $D2,$D3  : output:=output+', CL';
      end;
  end else
  if pByte^=$8C then
  begin
    Inc(addto,1);
    segreg:=true;
    GetParams(p,2, par1, par2, false, b);
    output:='MOV '+par1+', '+par2;
    Inc(addto,1+Getread);
  end
  else
  if pByte^=$8E then
  begin
    Inc(addto,1);
    segreg:=true;
    GetParams(p,2, par1, par2, false, b);
    output:='MOV '+par2+', '+par1;
    Inc(addto,1+Getread);
  end else
  if pByte^ in [$A0..$A3] then
  begin
    Inc(addto,3);
    pWord:=@pByte^;
    incptr(pword,1);
    case pByte^ of
          $A0: output:='MOV AL, ['+toHex(pword^,true)+']';
          $A1: output:='MOV AX, ['+toHex(pword^,true)+']';
          $A2: output:='MOV ['+toHex(pword^,true)+'], AL';
          $A3: output:='MOV ['+toHex(pword^,true)+'], AX';
    end;
  end else
  if pByte^ in [$80..$83] then { AROP }
  begin
    GetParams( p, 1+byte(odd(pByte^)), par1, par2, (a=$67), b);
    ope:=GetBits(ope,5,1) shl 1+GetBits(ope,3,1); { 01 nevym co je }
    output:=output+arop[ope]+' '+par1;
    Inc(Addto, 2+getread);
    case pByte^ of
       $80,$82,$83  :
         begin { im8 }
           IncPtr(pByte,2+getread);
           output:=output+', '+toHex(pbyte^,true);
           Inc(Addto, 1);
         end;
       $81  :
         begin { im16 }
           pWord:=@pByte^; IncPtr(pWord,2+getread);
           output:=output+', '+toHex(pWord^,true);
           Inc(Addto, 2);
         end;
      end;
  end else
  if pByte^ in [$69,$6B] then { imul }
  begin
    GetParams( p, 1+byte(odd(pByte^)), par1, par2, (a=$67), b);
    output:=output+'IMUL'+par1;
    Inc(Addto, 2+getread);
    case pByte^ of
       $69  :
         begin { im8 }
           IncPtr(pByte,2);
           output:=output+', '+toHex(pbyte^,true);
           Inc(Addto, 1);
         end;
       $6B  :
         begin { im16 }
           IncPtr(pByte,2); pWord:=@pByte^;
           output:=output+', '+toHex(pWord^,true);
           Inc(Addto, 2);
         end;
      end
  end else
  if pbyte^ in [$FE,$FF] then { GRP2, GRP3 }
  begin
    GetParams( p, 1+byte(odd(pByte^)), par1, par2, (a=$67), b);
    ope:=GetBits(ope,3,1) shl 1+GetBits(ope,2,1); { 03 nevym co je }
    output:=output+grp23[ope]+' '+par1;
    Inc(Addto, 2+getread);
  end else
  if pbyte^ in [$F6,$F7] then { GRP1, GRP2 }
  begin
    GetParams( p, 1+byte(odd(pByte^)), par1, par2, (a=$67), b);
    ope:=GetBits(ope,3,1) shl 1+GetBits(ope,2,1); { 03 nevym co je }
    output:=output+grp12[ope]+' '+par1;
    Inc(Addto, 2+getread);
  end else
  if pbyte^=$63 then { arpl }
  begin
    GetParams( p, 1+byte(odd(pByte^)), par1, par2, (a=$67), b);
    output:=output+'ARPL '+par1+', '+par2;
    Inc(Addto, 2+getread);
  end else
  if pByte^ in [$C6,$C7] then { MOV mem, imxx }
  begin
    GetParams( p, 1+byte(odd(pByte^)), par1, par2, (a=$67), b);
    output:=output+'MOV '+par1;
    Inc(Addto, 2+getread);
    case pByte^ of
       $C6  :
         begin { im8 }
           IncPtr(pByte,2+getread);
           output:=output+', '+toHex(pbyte^,true);
           Inc(Addto, 1);
         end;
       $C7  :
         begin { im16 }
           IncPtr(pByte,2+getread); pWord:=@pByte^;
           output:=output+', '+toHex(pWord^,true);
           Inc(Addto, 2);
         end;
      end
  end else
  if pbyte^ in [$EA,$9A] then {dva prime params. jmp far}
  begin
    case pbyte^ of
         $EA  : output:=output+'JMP ';
         $9A  : output:=output+'CALL ';
    end;
    pword:=@pbyte^;
    incptr(pword,1);
    output:=output+FilltoFront(ToHex(pword^, false),4,'0')+':';
    incptr(pword,2);
    output:=output+FilltoFront(ToHex(pword^, false),4,'0');
    Inc(addto,4);
  end else
  if pbyte^=$C8 then { enter }
  begin
    output:=output+'ENTER ';
    pword:=@pbyte^;
    incptr(pword,1);
    output:=output+FilltoFront(ToHex(pword^, false),4,'0')+',';
    incptr(pbyte,3);
    output:=output+FilltoFront(ToHex(pbyte^, false),2,'0');
    Inc(addto,3);
  end else
  begin
    output:=output+'DB '+ToHex(pByte^,true);
    inc(addto,1);
    {crt.sound(300);
    crt.delay(100);
    crt.nosound;}
  end;
end;

begin
end.

Dodelat:
 ENTER a podobne vyjimky (2 prime parametry)
 { kupodivu dva prefixy (REP STOSD, MOVSD 66 + dalsi )}