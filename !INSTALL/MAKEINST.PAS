Unit  MakeInst;
Interface
   Procedure MakeInstallDiskete(Path,ProgName,OutDir:String);
Implementation
 Uses Dos,Crt,Reader,Control;
Type
    TInstallHeader = Record
                      ProgramName  : String[40];
                      OutDirectory : String[80];
                      Identifikation : String[100];
                      SerialNumber  : String [20];
                     End;
    TFileHeader    = Record
                      FileName:String[12];
                      FileSize:Longint;
                     End;

Function GenerateSerialNumber(Str:String):String;
Type  TNumbers = Array[0..9] Of Char;
      TChars   = Array[0..24] Of Char;

Const Numbers : TNumbers = ('0','1','2','3','4','5','6','7','8','9');
      Chars   : TChars   = ('A','B','C','D','E','F','G','H','I','J','K','L',
                            'M','N','O','P','Q','R','S','T','U','V','X','Y','Z');

Var         I : Byte;

Begin
 Randomize;
 For I:=1 To Length(Str) Do
  If (Str[I]='C') or (Str[I]='c') Then Str[I]:=Numbers[Random(SizeOf(Numbers))]
   Else If (Str[I]='Z') or (Str[I]='z') Then Str[I]:=Chars[Random(SizeOf(Chars))];
 GenerateSerialNumber := Str;
End;

Procedure CreateDirectory(Path:String);
 Var      Disk             : String[3];
          OldDirectory     : String;
          CreateDir        : String;
          I                : Integer;
          AktualPath       : String;
Begin
GetDir(0,OldDirectory);
If Path[2]=':' Then Begin Disk:=Copy(Path,1,2);Delete(Path,1,2);End;
If Path[1]='\' Then Begin Disk:=Disk+'\';Delete(Path,1,1);End;
Chdir(Disk);
AktualPath:=Disk;
While Length(Path)<>0 Do
 Begin
 I:=1;CreateDir:='';
 While (Path[I]<>'\') And (I<>Length(Path)+1) Do Begin CreateDir:=CreateDir+Path[I];Inc(I);End;
 AktualPath:=AktualPath+Createdir;
 {$I-}
 Chdir(AktualPath);
 {$I+}
 If Ioresult<>0 Then
    Begin
     {$I-}
     MkDir(AktualPAth);
     {$I+}
     If Ioresult<>0 Then Begin Chdir(OldDirectory);Writeln('Nelze vytvorit adresar');Halt(5);End;
     Chdir(AktualPath);
    End;
 Delete(Path,1,I);
 AktualPath:=AktualPath+'\';
 End;
Chdir(OldDirectory);
End;

Procedure MakeInstallDiskete;
Type TBufer=Array[1..$FFFF] Of Byte;
Var DirInfo:SearchRec;
    FromF,ToF:File;
    OldDir:String;
    NumRead,NumWritten:Word;
    Counter:Longint;
    Bufer:^TBufer;
    FileHeader:TFileHeader;
    InstallHeader:TInstallHeader;
    I  ,Z : Word;
    Id :^String;
Const SecData : Array[1..512] Of Byte = ({$I Boot.Inc});
Begin
  Randomize;
  With InstallHeader Do
    Begin
      Identifikation[0]:=#100;{Nahodny vyber kodu}
      OutDirectory:=OutDir;
      SerialNumber:=GenerateSerialNumber('CCZZ-ZCCC-CZCCZ');
      InstallHeader.ProgramName:=ProgName;
        For I:=1 To Length(Identifikation) Do Identifikation[I]:=Chr(Random(256));
        For I:=1 To Length(SerialNumber) Do SerialNumber[I]:=
                         Chr(Ord(SerialNumber[I]) Xor Ord(Identifikation[I]));
    End;
  ID:=Ptr(Seg(SectorData),Ofs(SectorData));
  ID^:=InstallHeader.Identifikation;
  WriteSector(0,80,1);
    If Error Then Begin Writeln('Disketu je treba preformatovat');Halt(3);End;
  ReadSector(0,80,1);
    If Error Then Begin Writeln('Nelze cist ze sektoru');Halt(3);End;
  ID:=Ptr(Seg(SectorData),Ofs(SectorData));
    If ID^<>InstallHeader.Identifikation Then
    Begin Writeln('Nelze cist ze sektoru');Halt(3);End;
For I:=1 To 512 Do SectorData[I]:=SecData[I];
WriteSector(0,0,1);
New(Bufer);
Assign(ToF,'A:\INSTDATA.!!!');     { Otevýi vìstupn¡ soubor }
Rewrite(ToF, 1);              { Velikost z znamu = 1 }
BlockWrite(Tof,InstallHeader,SizeOf(InstallHeader));
GetDir(0,OldDir);
{$I-}
If Path[Length(Path)]='\' Then Delete(Path,Length(Path),I);
ChDir(Path);
if IOResult <> 0 then  Begin
Writeln('Adres r nenalezen (',Path,')');Chdir(OldDir);Halt(1);End;
{$I+}
FindFirst('*.*', Archive, DirInfo);
while DosError = 0 do
begin
Counter:=0;
Assign(FromF, DirInfo.Name);   { Otevýi vstupn¡ soubor }
Reset(FromF, 1);
Write(#13#10'Zabaluji program :',DirInfo.Name);
Write('      Velikost ', FileSize(FromF), ' bajtu...  :');
FileHeader.FileName:=DirInfo.Name;
FileHeader.FileSize:=FileSize(FromF);
BlockWrite(ToF, FileHeader, SizeOf(FileHeader));
repeat
  BlockRead(FromF, Bufer^, SizeOf(Bufer^), NumRead);
   (* Kodovaci smycka*)
   Z:=0;For I:=1 To Numread Do
   Begin
     Inc(Z);
     Bufer^[I]:=Bufer^[I] Xor Ord(InstallHeader.Identifikation[Z]);
     If Z=Length(InstallHeader.Identifikation) Then Z:=0;
   End;
  (* konec kodovaci smycky *)
  BlockWrite(ToF, Bufer^, NumRead, NumWritten);
Counter:=Counter+NumWritten;
Write((Counter / FileSize(FromF)*100):3:0,' %',#8#8#8#8#8);
until (NumRead = 0) or (NumWritten <> NumRead);
Close(FromF);
FindNext(DirInfo);
end;
Close(ToF);
Chdir(OldDir);
Dispose(Bufer);
End;

End.