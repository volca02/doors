{$A+,B-,D+,E+,F-,G-,I+,L-,N+,O-,P-,Q-,R-,S+,T-,V-,X+,Y-}
{$M 16384,65535,655360}
program DuplFile;
uses Dos,Crt;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function StrC(a,b:Byte):String;
var i:Byte;
    z:String;
begin
  z:='';
  for i:=1 to a do
    z:=z+Chr(b);
  StrC:=z;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function Tisic(a:LongInt):String;
var
  As,
    As1 : String;
  i  : ShortInt;
begin
  Str(a,As);
  As1:=As;
  i:=-1;
  while i+4<Length(As) do begin
    Inc(i,3);
    Insert('.',As1,Length(As)-i);
  end;
  Tisic:=As1;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
const
  Disk          : Char = 'C';
  ProtName      : PathStr = 'DUPLFILE.TXT';
  MaxRange      = 15000;
  Ano           = 'Ano';
  Ne            = 'Ne';

type
  PSoub = ^TSoub;
  TSoub = PathStr;
  TRange = 1..MaxRange;
var
  OldMem        : Longint;
  AktDisk       : Byte;
  AktDir        : String;
  R             : Registers;
  ScanDisk      : Byte;
  DirName       : PathStr;
  HlVn          : Integer;
  x,y           : Byte;
  ProtF         : Text;
  PocSoub       : Integer;
  PocAdr        : Integer;
  PocHide       : Integer;
  PocPryc       : Integer;
  PocUvol       : LongInt;
  PoleSoub      : array[TRange] of PSoub;
  Smazat        : Boolean;
  Zapis         : Boolean;

procedure Scan1Adresar; forward;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function CharDiskToNumDisk(CharDisk:Char):Byte;
begin
  CharDiskToNumDisk:=Ord(UpCase(CharDisk)) - Ord('A');
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function ZjistiAktDisk:Byte;
begin
  r.ah:=$19;
  MsDos(r);
  ZjistiAktDisk:=r.al;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure SetAktDisk(NumDisk:Byte);
begin
  r.ah:=$19;
  r.dl:=NumDisk;
  Intr($21,r);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure UvolniPamet;
var Ckl:TRange;
begin
  Ckl:=1;
  while PoleSoub[Ckl]<>nil do begin
    Dispose(POleSoub[Ckl]);
    PoleSoub[Ckl]:=nil;
    Inc(Ckl);
  end;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure PisInfo(Txt:String);
var
 x,y:Byte;
begin
  x:=WhereX;
  y:=WhereY;
  ClrEol;
  Write(Txt);
  GotoXY(X,Y);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure DalsiSoubor;
var
  MyRec : SearchRec;
  Navesti : Boolean;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure PrekrocOmez;
begin
  Writeln('Po‡et soubor– na disku je omezen na ',MaxRange);
  {$I-}
  Close(ProtF);
  Erase(ProtF);
  {$I+}
  UvolniPamet;
  Halt(2);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function FSize:String;
var
  Size : LongInt;
  SizeStr : String;
begin
  {$I-}
  Size:=MyRec.Size;
  Str(Size,SizeStr);
  {$I+}
  FSize:=SizeStr;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure GetFullName;
var
  PomDir        : PathStr;
  Ckl           : 1..8;
  P             : PathStr;
  D             : DirStr;
  N             : NameStr;
  E             : ExtStr;
begin
  FSplit(MyRec.Name,D,N,E);
  for Ckl:=Length(N)+1 to 8 do N:=N+#32;
  GetDir(ScanDisk+1,PomDir);
  if PomDir[Length(PomDir)]='\' then
    PomDir[0]:=Chr(Length(PomDir)-1);
  case Length(E) of
    0: E:='.   ';
    1: E:=E+'   ';
    2: E:=E+'  ';
    3: E:=E+' ';
  end;
  PoleSoub[PocSoub]^:=N+E+FSize+'\'+PomDir;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
begin
  FindFirst('*.*',$01+$02+$04+$08+$20,MyRec);
  while DosError=0 do begin
    Navesti:=MyRec.Attr and $08 = $08;
    if not Navesti then begin
      if MemAvail<SizeOf(PoleSoub[PocSoub]) then begin
        Writeln('Nedostatek pamˆti pro na‡ten¡ soubor– ...');
        Halt(3);
      end;
      if MyRec.Attr and $02 = $02 then Inc(PocHide);
      New(PoleSoub[PocSoub]);
      GetFullName;
      Inc(PocSoub);
      if PocSoub>MaxRange then PrekrocOmez;
    end;
    FindNext(MyRec);
  end;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure ProjdiSoubory;
begin
  Scan1Adresar;
  DalsiSoubor;
  ChDir('..');
  GetDir(0,DirName);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure Scan1Adresar;
var
  Rec:SearchRec;
begin
  FindFirst('*.*',AnyFile,Rec);
  while (DosError=0) do begin
    if (Rec.Attr=$10)or(Rec.Attr=$30)  then begin
      if (Rec.Name<>'.')and(Rec.Name<>'..')and(Rec.Attr=$10) then begin
        Inc(HlVn);
        ChDir(Rec.Name);
        GetDir(0,DirName);
        PisInfo(DirName);
        Inc(PocAdr);
        ProjdiSoubory;
        Dec(HlVn);
      end;
    end;
    FindNext(Rec);
  end;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function GetParams:Boolean;
var
  Ckl:Byte;
  Zn :String;
begin
  if ParamCount=0 then begin
    Writeln;
    GetParams:=True;
  end
  else
    begin
      Zn:=ParamStr(1);
      if Zn='/?' then begin
        ClrScr;
        Writeln;
        Writeln('The ECT DuplFile - Radek Janata  3/95');
        Writeln;
        Writeln('Program najde na disku v¨echny soubory a zjist¡ kter‚ tam jsou dvakr t,');
        Writeln('   t©ikr t,... atd. Na disku p©itom nech  pouze jeden soubor. Vyhled v ');
        Writeln('   pouze soubory, kter‚ maj¡ stejn‚ jm‚no (ne cestu) a stejnou velikost.');
        Writeln('   P©itom v¨echny soubory na disku zap¡¨e do souboru '+ProtName+',');
        Writeln('   kter˜ bude ulo‘en do ko©enov‚ho adres ©e prohled van‚ho disku. Impli.');
        Writeln('   citn¡ disk je C:.');
        Writeln('   Prohled vn˜ disk lze jednodu¨e zmˆnit, t¡m ‘e za jm‚no tohoto programu');
        Writeln('   nap¡¨eme jm‚no Disku (nap©.: A nebo A:). Budete-li cht¡t soubory, kter‚');
        Writeln('   jsou na prohled van‚m disku v¡ckr t smazat, tak za jm‚no tohoto disku');
        Writeln('   napi¨te p¡smeno "E" nebo "e". Na disku bude ponech n pouze jedna verze');
        Writeln('   souboru,a to ta s nejkrat¨¡ cestou ke ko©enov‚mu adres ©i. Seznam smazan˜ch');
        Writeln('   soubor– bude zaps n na konec souboru '+ProtName+'.');
        Writeln;
        Writeln('Pou‘it¡:');
        Writeln('  DUP.EXE /?        (tato n povˆda)');
        Writeln('  DUP.EXE [Disk]    (duplikace soubor– na "Disku" - jinak C:');
        Writeln('  DUP.EXE Disk E    (duplikovan0 soubory budou smaz ny)');
        Writeln;
        Write(' Stisknˆte libovolnou kl vesu '#17#13);
        ReadKey;
        Writeln;
        Writeln;
        GetParams:=False;
      end
      else
        begin
          Disk:=UpCase(Zn[1]);
          if not (Disk in ['A'..'Z']) then begin GetParamS:=False; end else begin end;
          if DiskSize(Ord(Disk)-64)=-1 then begin
            GetParams:=False;
            Writeln;
            Writeln('Disk '+Disk+': neexistuje...');
          end;
          if ParamCount=1 then begin Smazat:=False; end else begin end;
        end;
   begin
      if ParamCount=2 then begin
      Zn:=ParamStr(2);
      Zn:=UpCase(Zn[1]);
      if Zn='E' then Smazat:=True else Smazat:=False;
      GetParams:=True;
      end;
    end
  end;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure ObnovPuvStav;
begin
  {$I-}
  if Zapis then Close(ProtF);
  SetAktDisk(AktDisk);
  ChDir(AktDir);
  {$I+}
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure QuickSort(l,r: Integer);
var
  i,j : TRange;
  x,y : PathStr;
begin
  i:=l;
  j:=r;
  x:=PoleSoub[(l+r)div 2]^;
  repeat
    while PoleSoub[i]^ < x do Inc(i);
    while x < PoleSoub[j]^ do Dec(j);
    if i<=j then begin
      y:=PoleSoub[i]^;
      PoleSoub[i]^:=PoleSoub[j]^;
      PoleSoub[j]^:=y;
      Inc(i);
      Dec(j);
    end;
  until i>j;
  if l<j then QuickSort(l,j);
  if i<r then QuickSort(i,r);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure SortList;
begin
  if (PocSoub>1) then
    QuickSort(1,PocSoub);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function KolikDupl(Odkud:TRange):TRange;
var
  PocDupl,Start:TRange;
  f1,f2:PathStr;
  Poz:Byte;
begin
  Start:=Odkud;
  PocDupl:=Odkud;
  repeat
    f1:=PoleSoub[PocDupl]^;
    Poz:=Pos('\',f1);
    f1[0]:=Chr(Poz);
    f2:=PoleSoub[PocDupl+1]^;
    Poz:=Pos('\',f2);
    f2[0]:=Chr(Poz);
    Inc(PocDupl);
  until f1<>f2;
  KolikDupl:=PocDupl-Start;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure PisProtokol(NazSoub:PathStr);
begin
  PisInfo(NazSoub);
  if Zapis then Writeln(ProtF,#9,NazSoub);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure OdstranDupl;
var
  Ckl,Ckl1,PocDupl : TRange;
  f                : file;
  fn,fn1           : PathStr;
  Poz,PozT         : Byte;
  MyAttr           : SearchRec;
  a                : Char;
  ye               : Boolean;
  Ok               : Boolean;
begin
  Ckl:=1;
  while Ckl<PocSoub do begin
    PocDupl:=KolikDupl(Ckl);
    if PocDupl>1 then begin
      for Ckl1:=Ckl+1 to Ckl+PocDupl-1 do begin
        Poz:=Pos(#32,PoleSoub[Ckl1]^);
        PozT:=Pos('.',PoleSoub[Ckl1]^);
        fn:=Copy(PoleSoub[Ckl1]^,1,12);
        if (Poz>0) and (Poz<PozT) then begin
          fn:=Copy(PoleSoub[Ckl1]^,1,Poz-1);
          fn:=fn+Copy(PoleSoub[Ckl1]^,PozT,4);
        end;
        Poz:=Pos(#32,fn);
        if Poz>0 then
          fn:=Copy(fn,1,Poz-1);
        Poz:=Pos('\',PoleSoub[Ckl1]^);
        fn1:=Copy(PoleSoub[Ckl1]^,Poz+1,Length(PoleSoub[Ckl1]^)-Poz+1);
        fn1:=fn1+'\'+fn;
        FindFirst(fn1,AnyFile,MyAttr);

        if Smazat then begin
          Assign(f,fn1);
          FindFirst(fn1,AnyFile,MyAttr);
          ye:=True;
          if MyAttr.Attr and ReadOnly = ReadOnly then begin
            PisInfo(fn1);
            Writeln;
            Write('Soubor je chr nˆn proti z pisu. Smazat (A/N) ?');
            Ok:=False;

            repeat
              a:=ReadKey;
              case UpCAse(a) of
                'A' : begin Writeln(' ',Ano);ye:=True;Ok:=True;end;
                'N' : begin Dec(PocPryc);Writeln(' ',Ne);ye:=False;Ok:=True;end;
                #0  : ReadKey;
              end;
            until Ok;
          end;
          {$I-}
          if ye then begin
            SetFAttr(f,$20);
            Erase(f);
          end;
          {$I+}
        end;
        PisProtokol(fn1);
        Inc(PocPryc);
        Inc(PocUvol,MyAttr.Size);
      end;
      Inc(Ckl,PocDupl);
    end
    else Inc(Ckl);
  end;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure PisSeznam;
var b:String[10];
begin
  if Zapis then begin
    Writeln(ProtF,' Seznam soubor– na disku '+Disk+':');
    Writeln(ProtF, StrC(41,196));
    Writeln(ProtF,' €¡slo Soubor       Velikost  —pln  cesta');
    for HlVn:=1 to PocSoub do begin
      b:=Copy(PoleSoub[HlVn]^,13,(Pos('\',PoleSoub[HlVn]^))-13);
      Writeln(ProtF,HlVn:6,
                  #32,
                  Copy(PoleSoub[HlVn]^,1,12),
                  #32,
                  b,
                  StrC(10-Length(b),32),
                  Copy(PoleSoub[HlVn]^,14+Length(b),255)
                  );
    end;
    Writeln(ProtF);
  end;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
begin
  OldMem:=MemAvail;
  x:=WhereX;
  y:=WhereY;
  for HlVn:=1 to MaxRange do PoleSoub[HlVn]:=nil;
  HlVn:=0;
  PocSoub:=1;
  PocAdr:=1;
  PocHide:=0;
  PocPryc:=0;
  PocUvol:=0;
  AktDisk:=ZjistiAktDisk;
  GetDir(0,AktDir);
  if not GetParams then begin
    ObnovPuvStav;
    Halt(1);
  end;
  Writeln('Prob¡h  hled n¡ v¨ech soubor– na disku '+Disk+': ...');
  ScanDisk:=CharDiskToNumDisk(Disk);
  ChDir(Disk+':\');
  ProtName:=Disk+':\'+ProtName;
  Assign(ProtF,ProtName);
  {$I-}
  ReWrite(ProtF);
  {$I+}
  if IOResult>0 then
    Zapis:=False
  else
    Zapis:=True;

  GetDir(0,DirName);
  PisInfo(DirName);
  Scan1Adresar;
  DalsiSoubor;
  Dec(PocSoub);

  ClrEol;
  Writeln('Nalezeno: ..... celkem soubor–: ',PocSoub);
  Writeln('          ... skryt˜ch soubor–: ',PocHide);
  Writeln('          ........... adres ©–: ',PocAdr);
  Writeln;
  Write('Prob¡h  t©¡dˆn¡ n zv– soubor– ...'#13);
  SortList;
  ClrEol;
  Write('Prob¡h  z pis soubor– do souboru: ',ProtName,' ...'#13);
  PisSeznam;
  ClrEol;

  Writeln('Prob¡h  odstra¤ov n¡ duplicitn¡ch soubor– ...'#13);
  Writeln(ProtF,' Seznam odstranˆn˜ch soubor– na disku '+Disk+':');
  OdstranDupl;

  Writeln;
  Writeln;
  Writeln('Celkem odstranˆno: ',Tisic(PocPryc));
  Writeln('Celkem uvolnˆno:   ',Tisic(PocUvol),' Byt–');
  if not Smazat then begin
    Writeln;
    Writeln('V˜¨e uveden‚ soubory nebyly smaz ny.');
    Writeln('Program toti‘ nebyl spu¨tˆn s parametrem E');
  end;
  Writeln('Potrebna pamet :',OldMem-MemAvail);
  UvolniPamet;
  ObnovPuvStav;
  Writeln;
end.