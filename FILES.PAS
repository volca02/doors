{$O+,F+}
Unit Files;
Interface
Uses Objects;
function MakeDirectory  : Word;
Function CopyFiles(Data  : PCollection;Focused   : Word; Where  : string):Boolean;
Function MoveFiles(Data  : PCollection;Focused   : Word; Where  : string):Boolean;
Procedure DeleteFiles(Data  : PCollection;Focused   : Word);
Function SetAttributs(Data  : PCollection;Focused   : Word)  : Boolean;
Function GetFileSize(Data   : PCollection;Focused   : Word)  : Boolean;
Function FileInformation(Data : PCollection;Focused : Word)  : Boolean;
Implementation
Uses Dialogs, Views, App, DrsHelp, Base, MessBox, Variable, Dos, Drivers;
Type
    PConfirmDialog = ^TConfirmDialog;
    TConfirmDialog = Object(TDialog)
                      procedure HandleEvent(var Event: TEvent); virtual;
                     End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function IsDirectory(s  : string) : boolean;
var back  : string;
begin
 GetDir(0,back);
 {$I-} Chdir(s); {$I+}
 IsDirectory:=(ioresult=0);
 ChDir(back);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function IsFile(s  : string) : boolean;
var
  f  : file;
begin
 FileMode := 0;  { Nastavit p©¡stup k souboru na "jen ‡ten¡". }
 Assign(f,s);
 {$I-} Reset(f); {$I+}
 if ioresult=0 then
 begin
   Close(f);
   IsFile:=true;
 end else IsFile:=false;
 FileMode := 2;  { Nastavit p©¡stup k souboru na "jen ‡ten¡". }
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure CopyFile(s1, s2  : string;Mode : Boolean);
const cLimit=$FFF0;
var
  d        : pinfodialog;
  f,  f1   : file;
  bafr     : pointer;
  l        : longint;
  w        : word;
  CSize    : Word;
begin
  assign(f, s1);
  assign(f1, s2);
  If IsFile(S2) And mode Then Begin
                               if Messagebox('Soubor "'+s2+'" jiz existuje, prepsat?',nil,mfError+mfYesButton
                                +MfNoButton)<>cmYes then exit;
                               Erase(F1);
                              End;
  If Mode Then {$I-} Rename(f,S2); {$I+}
  If (Ioresult<>$0) or not mode then
  Begin
    GetFAttr(f,w);
    FileMode := 0;  { Nastavit p©¡stup k souboru na "jen ‡ten¡". }
    {$I-} Reset(f,1); {$I+}
    if ioresult<>0 then
    begin
      Messagebox('Chyba pri otevirani vstupniho souboru '+#13#3+'"'+s1+'"!',nil,mfError+mfOkButton);
      exit;
    end;
    if isFile(s2) then
    if Messagebox('Soubor "'+s2+'" jiz existuje, prepsat?',nil,mfError+mfYesButton
                  +MfNoButton)<>cmYes then Begin Close(F);exit;End;
    D := InfoBox('Kopirovani souboru',#3'Kopiruji sobor "'+s1+'"'+#13+#3+'do'
                  +#13#3+'"'+s2+'"');
    FileMode := 2;  { Nastavit p©¡stup k souboru na "jen ‡ten¡". }
    {$I-} rewrite(f1,1); {$I+}
    if ioresult<>0 then
    begin
      Messagebox('Chyba pri otevirani vystupniho souboru '+#13#3+'"'+s2+'"!',nil,mfError+mfOkButton);
      d^.close;
      Close(F);
      exit;
    end;
    If MemAvail<500 THen Halt(0);
    If MemAvail<cLimit Then CSize:= MemAvail - 500
     Else CSize:= cLimit;
    getmem(bafr, Csize);

    repeat
       l:=filesize(f)-filepos(f);
       if l>csize then l:=csize;
       {$I-} blockread(f,bafr^,l); {$I+}
       if ioresult<>0 then
       begin
         Messagebox('Chyba pri cteni ze souboru "'+s1+'"!',nil,mfError+mfOkButton);
         Freemem(bafr, csize);
         d^.close;
         Close(F);
         exit;
       end;
       {$I-} blockwrite(f1,bafr^,l); {$I+}
       if ioresult<>0 then
       begin
         Messagebox('Chyba pri zapisu do souboru "'+s2+'"!',nil,mfError+mfOkButton);
         Freemem(bafr, csize);
         d^.close;
         Close(F);
         exit;
       end;
    until l=0;
    close(f1);
    SetFAttr(f1,w);
    close(f);
    If Mode Then
    begin
      SetFAttr(f,0);
      {$I-} Erase(f); {$I+}
      if IOResult<>0 then MessageBox('Soubor "'+s1+'" nelze smazat!',nil,mfError+mfOkButton);
    end;
    Freemem(bafr, csize);
    d^.close;
  End;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
var
   s        : string;
Procedure CopyDirectory(o1, o2  : string;Mode : Boolean);
{
podminky: jsme v adresari, ktery obsahuje o1
}
var
  Dirinfo  : SearchRec;
begin
  GetDir(0,s);
  Messagebox(o1+#13#3+o2+#13#3+s,nil,mfinformation+mfokbutton);
  chdir(o1);
  if ioresult<>0 then Messagebox('Chyba!'#13#3'(Pri chdir)',nil,mferror+mfokbutton);
  if not IsDirectory(o2) then {$I-} MKDir(o2) {$I+};
  if ioresult<>0 then Messagebox('Chyba!'#13#3'(Pri mkdir)',nil,mferror+mfokbutton);
  FindFirst('*.*', anyfile-volumeid, DirInfo);
  while DosError = 0 do
  begin
    if (dirinfo.name[1]<>'.') then
    if (dirinfo.attr and directory=directory) then
       CopyDirectory(dirinfo.name, o2+'\'+dirinfo.name,Mode) else
       CopyFile(dirinfo.name, o2+'\'+dirinfo.name,Mode);

    FindNext(DirInfo);
  end;
  {$I-} chdir('..');
        if IOResult<>0 then ; { jsme v korenaci }
        If Mode Then RmDir(O1);
  {$I+} if IOResult<>0 then ; { jsme v korenaci }
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function CopyFiles;
var
   F          : pfilerec;
   sta        : word;
   i          : integer;
   select     : boolean;
   makedir    : boolean;
   s          : string;
   OldDir     : String;
   w1         : string;
Begin
  If Data^.Count=0 Then Exit;
  Select := False;
  For I:=0 To Data^.Count-1 Do
  With Data^ Do
  Begin
    F:= At(I);
    If F^.Selected Then Select := True;
  End;
  f:=data^.At(Focused);
  if not select and (F^.Name='..') then Exit;
  GetDir(0,OldDir);
  Sta := InputBox('Kopirovani souboru','Zadejte jm‚no ciloveho adres ©e',Where,255,hiCopyFile);
 { Messagebox('KAM = '+where,nil,mfOkbutton+MfInformation);}
  w1:=where;
  if sta<>cmOk then Exit;
  if select then
   For I:=0 To Data^.Count-1 Do
   begin { oznacene }
   f:=data^.At(I);
   where:=w1;
   If (F^.Name<>'..') And (F^.Selected) Then
    Begin
    if (f^.attr and Directory)>0 then
       begin { kopie adresare }
         if not isFile(f^.name) then
         begin
           getdir(0,s);
           if IsDirectory(where) then where:=where+'\'+f^.name;
           CopyDirectory(f^.name,where,False);
           chdir(s);
         end Else Messagebox('Nelze kopirovat adresar do souboru!',nil,mfError+mfOkButton);
       end else
       begin { kopie souboru }
         getdir(0,s);
         if IsDirectory(where) then where:=where+'\'+f^.name;
{         chdir(s);}
         CopyFile(f^.name,where,False);
         chdir(s);
         getdir(0,s);
       end;
   End;
  end else

  begin { aktivni }
    f:=data^.At(Focused);
    if f^.attr and Directory>0 then
       begin { kopie adresare }
         if not isFile(f^.name) then
         begin
           getdir(0,s);
           if IsDirectory(where) then where:=where+'\'+f^.name;
           CopyDirectory(f^.name,where,False);
           chdir(s);
         end Else Messagebox('Nelze kopirovat adresar do souboru!',nil,mfError+mfOkButton);
       end else
       begin { kopie souboru }
         getdir(0,s);
         if IsDirectory(where) then where:=where+'\'+f^.name;
{         chdir(s);}
         CopyFile(f^.name,where,False);
         chdir(s);
         getdir(0,s);
       end;
  end;
 ChDir(OldDir);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function MoveFiles;
var
   F          : pfilerec;
   sta        : word;
   i          : integer;
   select     : boolean;
   makedir    : boolean;
   s          : string;
   OldDir     : String;
   w1         : string;
Begin
  If Data^.Count=0 Then Exit;
  Select := False;
  For I:=0 To Data^.Count-1 Do
  With Data^ Do
  Begin
    F:= At(I);
    If F^.Selected Then Select := True;
  End;
  f:=data^.At(Focused);
  if not select and (F^.Name='..') then Exit;
  GetDir(0,OldDir);
  Sta := InputBox('Presouvani souboru','Zadejte jm‚no ciloveho adres ©e',Where,255,hiCopyFile);
 { Messagebox('KAM = '+where,nil,mfOkbutton+MfInformation);}
  w1:=where;
  if sta<>cmOk then Exit;
  if select then
   For I:=0 To Data^.Count-1 Do
   begin { oznacene }
   f:=data^.At(I);
   where:=w1;
   If (F^.Name<>'..') And (F^.Selected) Then
    Begin
    if (f^.attr and Directory)>0 then
       begin { kopie adresare }
         if not isFile(f^.name) then
         begin
           getdir(0,s);
           if IsDirectory(where) then where:=where+'\'+f^.name;
           CopyDirectory(f^.name,where,True);
           chdir(s);
         end Else Messagebox('Nelze presouvat adresar do souboru!',nil,mfError+mfOkButton);
       end else
       begin { kopie souboru }
         getdir(0,s);
         if IsDirectory(where) then where:=where+'\'+f^.name;
{         chdir(s);}
         CopyFile(f^.name,where,True);
         chdir(s);
         getdir(0,s);
       end;
   End;
  end else

  begin { aktivni }
    f:=data^.At(Focused);
    if f^.attr and Directory>0 then
       begin { kopie adresare }
         if not isFile(f^.name) then
         begin
           getdir(0,s);
           if IsDirectory(where) then where:=where+'\'+f^.name;
           CopyDirectory(f^.name,where,True);
           chdir(s);
         end Else Messagebox('Nelze presouvat adresar do souboru!',nil,mfError+mfOkButton);
       end else
       begin { kopie souboru }
         getdir(0,s);
         if IsDirectory(where) then where:=where+'\'+f^.name;
{         chdir(s);}
         CopyFile(f^.name,where,True);
         chdir(s);
         getdir(0,s);
       end;
  end;
 ChDir(OldDir);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function FileInformation;
const cEntr = #13#10;
      cStrUnknown = 'Neznamy typ souboru.';
      cHMt = 'Hudebni modul typu ';
      cNS  = 'Nazev skladby : ';
      cPICt = 'Obrazek typu ';

Var F   : PFileRec;
    fil : file;
    Ext : String[3];
    S   : String;

Procedure Otevri(s  : string);
begin
  Assign(fil,s);
  {$I-} reset(fil,1); {$I+}
  if ioresult<>0 then {Chyba}WRiteLN('Soubor nejni...');
end;

Procedure Zavri;
begin
  {$I-} Close(fil); {$I+}
  if ioresult<>0 then ;
end;

Function NactiW  : word;
var
   w  : word;
begin
  {$I-} Blockread(fil,w,2); {$I+}
  if ioresult<>0 then {Chyba};
  nactiW:=w;
end;

Function NactiB  : byte;
var
   w  : byte;
begin
  {$I-} Blockread(fil,w,1); {$I+}
  if ioresult<>0 then {Chyba};
  nactiB:=w;
end;

Function NactiL  : longint;
var
   w  : longint;
begin
  {$I-} Blockread(fil,w,4); {$I+}
  if ioresult<>0 then {Chyba};
  nactiL:=w;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure Nacti(var a; velikost  : word);
begin
  {$I-} Blockread(fil,a,velikost); {$I+}
  if ioresult<>0 then {Chyba};
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function PCXi(fn  : string)  : string;
var   w, v, a, b  : word;
      s           : string;
begin
  Otevri(fn);
  w:=nactiW;
  if w and $FF=$0A then
  begin
    w:=nactiW;
    s:=cpict+'PCX'+cEntr+'komprimovany    : ';
    if w and $FF00 shr 8=01 then s:=s+'pcx run length'
                            else s:=s+'neznamou metodou';
    s:=s+centr+'Barevna hloubka : '+IntToStr(W and $FF)+' (BPP)'+cEntr;
    w:=nactiW; v:=nactiW;
    a:=nactiW; b:=nactiW;
    s:=s+'Rozmery         : '+IntToStr(a-w)+'x'+IntToStr(b-v);
  end else s:=cStrUnknown;
  zavri;
  Pcxi:=s;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function GIFi(fn  : string)  : string;
var
  b     : byte;
  a     : array [1..6] of char;
  s     : string;
begin
  Otevri(fn);
  Nacti(a,6);
  if (a='GIF87a') or (a='GIF89a') then
  begin
    s:=cPICt+'GIF';
    s:=s+cEntr+'Rozmery          : '+IntToStr(NactiW)+'x'+IntToStr(NactiW);
    b:=nactiB and $7;
    s:=s+cEntr+'Barevna hloubka  : '+IntToStr(b+1)+' (BPP)';
  end else s:=cStrUnknown;
  zavri;
  GIFi:=s;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function PNGi(fn  : string)  : string;
var
  b     : byte;
  a     : array [1..8] of char;
  s     : string;
  X,Y   : longint;
  ax    : array [1..4] of byte absolute x;
  ay    : array [1..4] of byte absolute y;
begin
  Otevri(fn);
  Nacti(a,8);
  if (a=#137#80#78#71#13#10#26#10) then
  begin
    s:=cPICt+'PNG';
    NACTI(A,8);
    x:=NactiL;
    b:=ax[4]; ax[4]:=ax[1]; ax[1]:=b; b:=ax[3]; ax[3]:=ax[2]; ax[2]:=b;
    y:=NactiL;
    b:=ay[4]; ay[4]:=ay[1]; ay[1]:=b; b:=ay[3]; ay[3]:=ay[2]; ay[2]:=b;
    s:=s+cEntr+'Rozmery          : '+IntToStr(X)+'x'+IntToStr(Y);
    s:=s+cEntr+'Barevna hloubka  : '+IntToStr(Nactib)+' (BPP)';
  end else s:=cStrUnknown;
  zavri;
  PNGi:=s;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function FLIi(fn  : string)  : string;
var
  s     : string;
begin
  Otevri(fn);
  Nactil;
  if NactiW=$AF11 then
  begin
    s:='Animace typu FLI';
    s:=s+cEntr+'Pocet snimku     : '+IntToStr(NactiW);
    s:=s+cEntr+'Rozmery          : '+IntToStr(NactiW)+'x'+IntToStr(NactiW);
    s:=s+cEntr+'Barevna hloubka  : '+IntToStr(NactiB)+' (BPP)';
  end else s:=cStrUnknown;
  zavri;
  FLIi:=s;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function Convert(a  : string)  : string;
var
  s  : string;
  x  : byte;
begin
  s:=a;
  a:=a+#0;
  s[0]:=chr(pos(#0,a));
  convert:=s;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function XMi(fn  : string)  : string;
var
  s     : string;
  a     : string[20];
begin
  Otevri(fn);
  Nacti(a,17);
  if a='Extended module: ' then
  begin
    s:=cHMt+'XM'+cEntr;
    Nacti(a[1],20);
    s:=s+cNS+Convert(a)+cEntr;
  end else s:=cStrUnknown;
  zavri;
  XMi:=s;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function S3Mi(fn  : string)  : string;
var
  s     : string;
  a     : string[20];
  b     : array [0..4] of char;
begin
  Otevri(fn);
  Nacti(a[1],20);
  s:=cNS+Convert(a);
  NactiW;
  Nacti(b,4);
  if b<>'SCRM' then s:=cHMt+'S3M'+cEntr+s else s:=cStrUnknown;
  zavri;
  S3Mi:=s;
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function EXEi(Name : String) : String;
Var
    Header,Header2      : Word;
    HeaderStart         : Longint;
    NumberOfItem        : Word;
    TabOdkaz,TabJmen,I  : Word;
    Data                : String[12];
    Index               : Word;
    S,Ext               : String;
Begin
  Exei:= 'Neznamy typ souboru';
  Otevri(name);
  header:=Nactiw;
  If Header<>$5A4D Then Begin Zavri; Exit; End;
  Ext := UpString(GetExtension(Name));
  S := 'Spustitelny soubor';
  Seek(Fil,$18);
  Header:=nactiw;
  Seek(Fil,$3C);
  HeaderStart:=nactiL; {Druheho}
  Seek(Fil,HeaderStart);
  Header2:=nactiw;
  If (Header=$40) And (Header2=$454E) Then
   Begin
    If Ext='EXE' Then S:='Spustitelny soubor pro Microsoft Windows'
     Else S:='Knihovna pro Microsoft Windows';
    Seek(Fil,HeaderStart+$1E);
    NumberOfItem:=nactiw;
    S:= S + #13'Pocet pripojenych knihoven : ' + IntToStr(NumberOfItem);
    Seek(Fil,HeaderStart+$28);
    TabOdkaz:=nactiw;
    Seek(Fil,HeaderStart+$2A);
    TabJmen:=nactiw;
    iF NumberOfItem<15 Then
    For I:=1 To NumberOfItem Do
     Begin
      Seek(Fil,HeaderStart+TabOdkaz+(I-1)*2); Index:=nactiw;
      Seek(Fil,HeaderStart+TabJmen+Index); Nacti(Data,SizeOf(Data));
      S:=S+#13+Data;
     End;
    Exei := S;
    Zavri;
  End
  Else Begin {Soubor je dosovsky}
           Seek(Fil,$0A);
           header:=nactiw; {Nelezeni prvniho kontrolniho bytu}
           S := S + #13'Minimalni potrebna pamet : ' + Thousand(Header*16);
           header:=nactiw;
           S := S + #13'Maximalni potrebna pamet : ' + Thousand(Longint(Header)*16);
           Seek(Fil,$12);
           header:=nactiw;
           S := S + #13'Kontrolni soucet : ' + FillToFront(DecToHex(Header),4,'0');
           header2:=nactiw;
           header:=nactiw;
           S := S + #13'CS:IP : ' + FillToFront(DecToHex(Header),4,'0') + ':' +
                                    FillToFront(DecToHex(Header2),4,'0');
           Exei := S;
           Zavri;
       End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
 If Data^.Count=0 Then Exit;
 F := Data^.At(Focused);
 Ext := UpString(GetExtension(F^.Name));
 if ext='PCX' then s:=PCXi(f^.name) else
 if ext='GIF' then s:=GIFi(f^.name) else
 if ext='FLI' then s:=FLIi(f^.name) else
 if ext='S3M' then s:=S3Mi(f^.name) else
 if ext='PNG' then s:=PNGi(f^.name) else
 if ext='XM' then s:=XMi(f^.name) else
 If (Ext='EXE') or (Ext='DLL') or (Ext='DRV') or (Ext='SYS') or (Ext='FON')
   or (Ext='VXD') or (Ext='SCR') or (Ext='OCX') Then S:=EXEi (F^.Name)
   Else S:='Neznamy typ souboru';
 MessageBox(S,Nil,mfInformation + mfOkButton);
 FileInformation:=False;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TConfirmDialog.HandleEvent;
Begin
 TDialog.HandleEvent(Event);
 If Event.What = EvCommand Then
 Case Event.Command Of
  cmAll,cmNothing:
          if State and sfModal <> 0 then
          begin
            EndModal(Event.Command);
            ClearEvent(Event);
          end;
 End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function GetClusterSize : Longint;
Var SectorPerCluster : Byte;
    SectorSize       : Word;
Begin
 Asm
  push ds
  Mov ah,1Bh
  int 21h
  mov SectorSize,CX
  mov SectorPerCluster,Al
  pop ds
 End;
 GetClusterSize := (SectorPerCluster * SectorSize);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function GetFileSize;
Const Text = #3 + 'Zjistuji velikost ...' + #13;
Var Select : Boolean;
     I      : Integer;
     F      : PFileRec;
     D      : PInfoDialog;
     Size,Size2 : Longint;
     Typ    : String[10];
     CSize  : Longint;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure GetDirectorySize(s  : string; var l,l2:longint);
var
  DirInfo  : SearchRec;
  x        : byte;
{  OlDir    : String;}
begin
  {$I-} CHDIR(S); {$I+}
  if ioresult<>0 then Exit;
  FindFirst('*.*', $FFFF, DirInfo);
  while DosError = 0 do
  begin
    if dirinfo.name[1]<>'.' then
    begin
      if dirinfo.attr and directory=Directory then
      GetDirectorySize(dirinfo.name,l,l2) else
      l  := l + DirInfo.size;
      l2 := l2 + RoundUp(DirInfo.Size, CSize);
    end;
    FindNext(DirInfo);
  end;
  {$I-} CHDIR('..'); {$I+}
  if ioresult<>0 then ;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
  CSize := GetClusterSize;
  If Data^.Count=0 Then Exit;
  Select := False;
  For I:=0 To Data^.Count-1 Do
    With Data^ Do  Begin
                     F:= At(I);
                     If F^.Selected Then Select := True;
                   End;
  Size := 0; Size2 := 0;
  If Select Then
  Begin
   D := InfoBox('Zjistovani velikosti',Text);
   For I:=0 To Data^.Count-1 Do
   With Data^ Do
    Begin
     F:= At(I);
     If F^.Selected Then Begin
                          D^.Update(Text + #3+F^.Name);
                          If (F^.Attr And Directory)= Directory Then
                            GetDirectorySize(F^.name, Size, Size2)
                           Else
                           begin
                              Size :=Size + F^.Size;
                              Size2 :=Size2 + RoundUp(F^.Size, csize);
                           end;
                         End;
    End;
   D^.Close;
   MessageBox(#3'Oznacene soubory/adresare' + #13#3'maji celkovou velikost'+
               #13#3+Thousand(Size)+ ' Bajtu'+#13#3'zabiraji vsak celkem'+
               #13#3+Thousand(Size2)+' Bajtu',Nil,mfInformation + mfOkButton);
  End
  Else Begin
        Typ := 'Soubor ';
        F :=Data^.At(Focused);
        If (Not Select) And ((F^.Attr And Directory)= Directory)
             And (F^.Name = '..') Then Exit;
        D := InfoBox('Zjistovani velikosti',Text);
        D^.Update(Text + #3+F^.Name);
        If (F^.Attr And Directory)= Directory Then
           Begin
             Typ := 'Adresar ';
             GetDirectorySize(F^.name, Size,Size2);
           End
          Else
          begin
            Size :=Size + F^.Size;
            Size2 :=Size2 + RoundUp(F^.Size, csize);
          end;
        D^.Close;
        MessageBox(#3+ Typ + '"'+ f^.name+'"'+ #13#3'ma celkovou velikost'+
               #13#3+Thousand(Size)+ ' Bajtu'+#13#3'zabira vsak celkem'+
               #13#3+Thousand(Size2)+' Bajtu' ,Nil,mfInformation + mfOkButton);
       End;
  GetFileSize := False;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function SetAttributs;
Const SetArchive    = 1;
      SetReadOnly   = 2;
      SetHidden     = 4;
      SetSystem     = 8;
      ClearArchive  = 16;
      ClearReadOnly = 32;
      ClearHidden   = 64;
      ClearSystem   = 128;
Var
   SelectData : record
                 Attr   :  Word;
                 Time   :  string[8];
                 Date   :  string[10];
                end;
   S            : File;
   Select       : Boolean;
   I            : Word;
   F            : PFileRec;
   D            : PInfoDialog;
   SetAttr      : Word;
   ClearAttr    : Word;
   FileAttr     : Word;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function SelectSetAttr : Word;
var
  D    : PDialog;
  C    : PView;
  L    : PLabel;
  R    : TRect;

begin
  SetAttributs:=False;
  R.Assign(10,6,69,17);
  D:=New(PDialog,Init(R,'Nastaven¡ atribut–'));
  with D^ do
       begin
          R.Assign(3,3,42,7);
          C:=New(PCheckBoxes,Init(R,
               NewSItem(' ',
               NewSItem(' ',
               NewSItem(' ',
               NewSItem(' ',
               NewSItem('~A~ : soubor k archivaci',
               NewSItem('~R~ : soubor pouze pro ‡ten¡',
               NewSItem('~H~ : skryt˜ soubor',
               NewSItem('~S~ : syst‚mov˜ soubor',
               nil))))))))));
          Insert(C);

          R.Assign(44,3,55,4);
          C:=New(PInputLine,Init(R,8));
          Insert(C);
          R.Assign(43,2,56,3);
          L:=New(PLabel,Init(R,'€as (H:M:S)',C));
          Insert(L);

          R.Assign(44,6,57,7);
          C:=New(PInputLine,Init(R,10));
          Insert(C);
          R.Assign(43,5,58,6);
          L:=New(PLabel,Init(R,'Datum (D-M-R)',C));
          Insert(L);

          R.Assign(2,8,12,10);
          C:=New(PButton,Init(R,'~O~k',cmOk,bfDefault));
          Insert(C);

          R.Assign(14,8,24,10);
          C:=New(PButton,Init(R,'~Z~ru¨it',cmCancel,bfNormal));
          Insert(C);

          R.Assign(4,2,10,3);
          C:=New(PStaticText,Init(R,'Nastav'));
          Insert(C);

          R.Assign(11,2,16,3);
          C:=New(PStaticText,Init(R,'Vyma‘'));
          Insert(C);

          SelectNext(False);
       end;

   SelectSetAttr:=Application^.ExecuteDialog(D,@SelectData);

end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
  If Data^.Count=0 Then Exit;
  Select := False;
  For I:=1 To Data^.Count-1 Do
    With Data^ Do  Begin
                     F:= At(I);
                     If F^.Selected Then Select := True;
                   End;

If Select Then With SelectData Do
                Begin
                  Attr := 0; Time :='';Date :='';
                  If SelectSetAttr<>CmOk Then Exit;
                  D := InfoBox('Nastavovani atributu','');
                  SetAttr := 0; ClearAttr := 0;
                  If (Attr and SetArchive) = Archive Then SetAttr := SetBit(SetAttr,Archive);
                  If (Attr and SetHidden) = SetHidden Then SetAttr := SetBit(SetAttr,Hidden);
                  If (Attr and SetReadOnly) = SetReadOnly Then SetAttr := SetBit(SetAttr,ReadOnly);
                  If (Attr and SetSystem) = SetSystem Then SetAttr := SetBit(SetAttr,SysFile);
                  If (Attr and ClearArchive) = ClearArchive Then ClearAttr := SetBit(ClearAttr,Archive);
                  If (Attr and ClearHidden) = ClearHidden Then ClearAttr := SetBit(ClearAttr,Hidden);
                  If (Attr and ClearReadOnly) = ClearReadOnly Then ClearAttr := SetBit(ClearAttr,ReadOnly);
                  If (Attr and ClearSystem) = ClearSystem Then ClearAttr := SetBit(ClearAttr,SysFile);

                    For I:=1 To Data^.Count-1 Do
                    With Data^ Do
                      Begin
                        F:= At(I);
                        If F^.Selected Then
                         With SelectData Do
                         Begin
                           Assign(S,F^.Name);
                           GetFAttr(S,FileAttr);
                           FileAttr := SetBit(FileAttr,SetAttr);
                           FileAttr := ClearBit(FileAttr,ClearAttr);
                           SetFAttr(S,FileAttr);
                           D^.Update(#3+F^.Name);
                         End;
                      End;
                  D^.Close;
                End;
SetAttributs := True;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure DeleteFiles(Data : PCollection;Focused : Word);
Const All     : Boolean = False;
      Nothing : Boolean = False;
      Cancel  : Boolean = False;
Var Select : Boolean;
    Number : Word;
    F      : PFileRec;
    Confirm : Word;
    I      : Word;
    D      : PInfoDialog;
    FocusedName : String;
    FileType    : String;
    R           : Trect;
    Fi          : File;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function ConfirmRO(S:String): Word;
var
  D    : PDialog;
  C    : PView;
  R    : TRect;
  _DataPtr : Pointer;
begin
  R.Assign(11,7,68,16);
  D:=New(PConfirmDialog,Init(R,'Upozornˆn¡'));
  with D^ do
       begin
          R.Assign(2,2,Size.X-2,3);
          C:=New(PStaticText,Init(R,#3'Soubor '+S+' je chr ¤en proti z pisu'));
          Insert(C);

          R.Assign(17,4,44,5);
          C:=New(PStaticText,Init(R,'Opravdu jej chcete smazat ?'));
          Insert(C);

          R.Assign(2,6,12,8);
          C:=New(PButton,Init(R,'~A~no',cmYes,bfNormal));
          Insert(C);

          R.Assign(12,6,22,8);
          C:=New(PButton,Init(R,'~N~e',cmNo,bfNormal));
          Insert(C);

          R.Assign(22,6,33,8);
          C:=New(PButton,Init(R,'~V~¨echny',cmAll,bfNormal));
          Insert(C);

          R.Assign(33,6,44,8);
          C:=New(PButton,Init(R,'’ ~d~n‚',cmNothing,bfNormal));
          Insert(C);

          R.Assign(44,6,55,8);
          C:=New(PButton,Init(R,'~Z~ru¨it',cmCancel,bfNormal));
          Insert(C);

          SelectNext(False);
       end;

   _DataPtr:=NIL;
   ConfirmRo:=Application^.ExecuteDialog(D,_DataPtr);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function DeleteDirectory(DirName :String) : Boolean;
var
  DirInfo  : SearchRec;
  x        : byte;
begin
  DeleteDirectory := True;
  D^.Update(#3'Mazu adresar'#13#3 + FExpand(DirName));
  {$I-} CHDIR(DirName); {$I+}
  if ioresult<>0 then Exit;
  FindFirst('*.*', AnyFile, DirInfo);
  while DosError = 0 do
  begin
    if dirinfo.name[1]<>'.' then
    begin
      if (dirinfo.attr and directory)=Directory then
       Begin
        If Not DeleteDirectory(dirinfo.name) Then Begin
                                                   ChDir('..');
                                                   DeleteDirectory := False;
                                                  End;
       End
       Else Begin
            Assign(Fi,DirInfo.Name);
            SetFAttr(Fi,0);
            {$I-} Erase(Fi); {$I+}
           End;
    end;
    FindNext(DirInfo);
  end;
  {$I-} CHDIR('..'); {$I+}
  if ioresult<>0 then ;
  {$I-}
   RmDir(DirName);
   If Ioresult<>0 Then DeleteDirectory := False
    Else D^.Update(#3'Mazu adresar'#13#3 + FExpand(DirName));
  {$I+}
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure DeleteFile(FileName :String;Select : Boolean);
Var F           : File;
    Attr        : Word;
    Confirm     : Word;
Begin
 Assign(F,FileName);
 GetFAttr(F,Attr);
 If DosError<>0 Then  Begin
  MessageBox(#3'Soubor "' + FileName + '" '+
                          #13#3'Nelze smazat !!!!!!',Nil,
                          mfError + mfOkButton);
                       Exit;
                      End;

 If ((Attr And ReadOnly)= ReadOnly) Then
  Begin
   If (Not Nothing) and (Not All) Then
    Begin
     If Not Select Then
     Confirm := MessageBox(#3'Soubor "' + FileName + '" je pouze pro cteni'+
                           #13#3'opravdu ho chcete smazat',Nil,
                           mfConfirmation + mfYesButton + mfNoButton)
       Else Confirm := ConfirmRO(FileName);
     If Confirm=CmAll Then All:=True;
     If Confirm=CmNothing Then Nothing:=True;
     If Confirm=CmCancel Then Cancel:=True;
    End;
    If Nothing Then Confirm:=cmNothing;
    If All Then Confirm:=cmAll;
    If (Confirm = CmNo) or (Confirm = CmCancel) or (Confirm = CmNothing)Then Exit;
  End;
 SetFAttr(F,0);
 {$I-}
 iF d<>Nil Then D^.Update(#3'Mazu soubor'#13#3+Filename);
 Erase(F);
 If DosError<>0 Then  Begin
 Confirm := MessageBox(#3'Soubor "' + FileName + '" '+
                          #13#3'Nelze smazat !!!!!!',Nil,
                          mfError + mfOkButton);
                       Exit;
                      End;

 {$I+}
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
  All := False;Nothing := False;Cancel := False;
  If Data^.Count=0 Then Exit;Select := False;Number := 0;
  For I:=0 To Data^.Count-1 Do
    With Data^ Do  Begin
                     F:= At(I);
                     If F^.Selected Then Begin
                                           Select := True;
                                           Inc(Number);
                                         End;
                   End;
  F := Data^.At(Focused);
  FocusedName :=F^.Name;
  If (Not Select) And ((F^.Attr And Directory)= Directory)
             And (F^.Name = '..') Then Exit;
  FileType := 'soubor';
  If (F^.Attr And Directory)= Directory Then FileType :='adresar';
  Write(#7);
  If Select Then Begin
    Confirm := MessageBox(#3'Jsou oznaceny ' + IntToStr(Number) + ' soubory (adresare)'+
                          #13#3'opravdu je chcete vymazat',Nil,
                          mfConfirmation + mfYesButton + mfNoButton);
   If Confirm <>CmYes Then Exit;
                  End
   Else
    Confirm := MessageBox(#3'Opravdu chcete vymazat ' + FileType +
                          #13#3 + FocusedName,Nil,
                          mfConfirmation + mfYesButton + mfNoButton);
    If Confirm <>CmYes Then Exit;
  If Not Select Then
    Begin
     If F^.Attr = Directory Then
      Begin
        D := InfoBox('Mazani',#3'Mazu adresar'#13#3+F^.Name);
        DeleteDirectory(F^.Name)
      End
         Else Begin
             D := InfoBox('Mazani',#3'Mazu soubor'#13#3+F^.Name);
             DeleteFile(F^.Name,Select);
            End;
     D^.Close;
    End
 Else Begin
       D := InfoBox('Mazani',#3'Mazu soubor'#13#3);
       For I:=0 To Data^.Count-1 Do
        Begin
         F:=Data^.At(I);
         If F^.Selected Then
           Begin
            If F^.Attr = Directory Then
            Begin
             DeleteDirectory(F^.Name)
            End
              Else Begin
                    DeleteFile(F^.Name,Select);
                    If Cancel Then Break;
                   End;
           End;
        End;
       D^.Close;
      End
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function CreateDirectory(Path:String):Boolean;
 Var      Disk             : String[3];
          OldDirectory     : String;
          CreateDir        : String;
          I                : Integer;
          AktualPath       : String;
Begin
CreateDirectory:=True;
GetDir(0,OldDirectory);
Disk := '';
If Path[2]=':' Then Begin Disk:=Copy(Path,1,2);Delete(Path,1,2);End;
If Path[1]='\' Then Begin Disk:=Disk+'\';Delete(Path,1,1);End;
If Disk<>'' Then Begin
                   Chdir(Disk);
                   AktualPath:=Disk;
                 End;
While Length(Path)<>0 Do
 Begin
 I:=1;CreateDir:='';
 While (Path[I]<>'\') And (I<>Length(Path)+1) Do Begin CreateDir:=CreateDir+Path[I];Inc(I);End;
 AktualPath:=Createdir;
 {$I-}
 Chdir(AktualPath);
 {$I+}
 If Ioresult<>0 Then
    Begin
     {$I-}
     MkDir(AktualPAth);
     {$I+}
     If Ioresult<>0 Then Begin Chdir(OldDirectory);CreateDirectory:=False;Exit;End;
     Chdir(AktualPath);
    End;
 Delete(Path,1,I);
 AktualPath:=AktualPath+'\';
 End;
Chdir(OldDirectory);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function MakeDirectory;
var
  D    : PDialog;
  C    : PView;
  L    : PLabel;
  R    : TRect;
  Sta  : Word;
  DirectoryName : String;
begin
  Application^.HelpCtx:=hcMkdir;
  FillChar(DirectoryName,SizeOf(DirectoryName),0);
  Sta := InputBox('Vytvo©en¡ adres ©e','Zadejte jm‚no nov‚ho adres ©e',DirectoryName,255,hiMkDir);
  If Sta <> CmOk Then Exit;
  CreateDirectory(DirectoryName);
  Application^.HelpCtx:=hcNoContext;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
End.