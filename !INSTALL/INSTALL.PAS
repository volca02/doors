Uses App, Dialogs, Views, Objects, Editors, Drivers, Dos, Reader, cRT, Gauges, MsgBox, SetFont;
Const CmChangeDir = 101;
Type
        Pviewer = ^TViewer;
        TViewer = object(TListViewer)
                    FileData : Array [0..200] Of PString;
                    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
                  End;

  PInstallBackGround = ^TInstallBackGround;
  TInstallBackGround = Object(TBackGround)
                      Procedure Draw;Virtual;
                     End;

  PInstallDesktop = ^TInstallDesktop;
  TInstallDesktop = Object(TDesktop)
                   Procedure InitBackground;virtual;
                  End;

   PInstallWizard = ^TInstallWizard;
   TInstallWizard = Object(TApplication)
                     Procedure InitStatusLine;virtual;
                     Procedure InitMenuBar;Virtual;
                     Procedure InitDesktop;Virtual;
                    End;
Type
    Pga         = PBarGauge;
    PNInputLine = ^TNInputLine;
    TNInputLine = Object(TInputLine)
                   procedure HandleEvent(var Event: TEvent); virtual;
                  End;

    PNDialog = ^TNDialog;
    TNDialog = Object(TDialog)
                   procedure HandleEvent(var Event: TEvent); virtual;
                  End;

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

Var Data : Record
            SerialNumber : String [15];
            OutDirectory : String;
           End;
    InstallHeader : TInstallHeader;
    AllStatus     : PBarGauge;
    Dx            : PDialog;
    Status        : PStaticText;
    FileStatus    : PBarGauge;
    Text          : PStaticText;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function TViewer.GetText;
Begin
Case Item Of
   0: GetText:='POZNMKY :';
   1: GetText:='ÄÄÄÄÄÄÄÄÄÄ';
   2: GetText:='  Firma  ş IMAGINE SOFTWARE  v m udˆl¡ licenci pouze';
   3: GetText:='  v p©¡padˆ, ‘e budete souhlasit s licen‡n¡mi podm¡nkami.';
   4: GetText:='  Pros¡me v s, aby jste si je pozornˆ p©e‡etli,';
   5: GetText:='  d©¡ve ne‘ budete pokra‡ovat v instalaci.';
   6: GetText:='  Jestli‘e s nimi nebudete souhlasit stisknˆte';
   7: GetText:='  tla‡¡tko [ Nesouhlas¡m ] a instalace bude ukon‡ena.';
   8: GetText:='';
   9: GetText:='LICENCE A ZRUKA :';
  10: GetText:='ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ';
  11: GetText:='  Tento program je majetkem firmy  ş IMAGINE SOFTWARE';
  12: GetText:='  a podl‚h  z konu o autorsk˜ch pr vech. Zat¡mco firma';
  13: GetText:='  ş IMAGINE SOFTWARE vlastn¡ tento program, vy dostanete';
  14: GetText:='  pr va na pou‘¡van¡ tohoto programu po souhlasu';
  15: GetText:='  s touto licenc¡.';
  16: GetText:='';
  17: GetText:='M¦’ETE :';
  18: GetText:='ÄÄÄÄÄÄÄÄ';
  19: GetText:='  1) Pou‘¡vat jednu kopii programu na jednom po‡¡ta‡i.';
  20: GetText:='  2) Vytvo©it jednu kopii programu pro archivn¡ £‡eli.';
  21: GetText:='  3) Po p¡semn‚m ozn men¡ firmˆ  ş IMAGINE SOFTWARE';
  22: GetText:='     p©ev‚st program na jinou osobu za p©edpokladu,';
  23: GetText:='     ‘e si nenech te ‘ dnou kopii a pokud p©evod';
  24: GetText:='     souhlas¡ z licen‡n¡mi podm¡nkami.';
  25: GetText:='  4) Pou‘¡t program v po‡¡ta‡ov‚ s¡ti, v p©¡padˆ';
  26: GetText:='     ‘e m te licenci programu pro ka‘d˜ po‡¡ta‡.';
  27: GetText:='';
  28: GetText:='NEM¦’ETE :';
  29: GetText:='ÄÄÄÄÄÄÄÄÄÄ';
  30: GetText:='   1) Pronaj¡mat program nebo jeho ‡ st.';
  31: GetText:='   2) Prov dˆt opak v˜roby programu ( Disassembler,';
  32: GetText:='      £pravu k¢du, zpˆtn˜ p©eklad ), pokou¨et se objevit';
  33: GetText:='      zdrojov˜ k¢d tohoto programu nebo vytvo©it program';
  34: GetText:='      odvozen˜ od tohoto.';
  35: GetText:='   3) Pou‘¡vat p©edchoz¡ verzi programu pokud jste';
  36: GetText:='      obdr‘eli upgrade programu.';
  37: GetText:='';
  38: GetText:='';
  39: GetText:='';
  40: GetText:='';
end;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function Licence:Word;
var
  D    : PDialog;
  C    : PViewer;
  F    : PView;
  R    : TRect;
begin
  R.Assign(0,0,60,20);
  D:=New(PDialog,Init(R,'Licen‡n¡ podm¡nky'));
  D^.Options:=D^.Options Or ofCentered;
  D^.Flags:=wfMove;
  with D^ do
       begin
          R.Assign(1,1,Size.X-1,Size.Y-4);
          C:=New(PViewer,Init(R,1,Nil,Nil));
          C^.Range:=41;
          Insert(C);
          R.Assign(1,Size.Y-3,(Size.X Div 2 )- 1,Size.Y - 1);
          F:=New(PButton,Init(R,'~S~ouhlas¡m',CmYes,bfDefault));
          Insert(F);
          R.Assign((Size.X Div 2 ) + 1,Size.Y-3,Size.X - 1,Size.Y - 1);
          F:=New(PButton,Init(R,'~N~esouhlas¡m',CmNo,bfNormal));
          Insert(F);
          SelectNext(False);
       end;
   Licence := Application^.ExecuteDialog(D,Nil);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function Install:Word;
var
  D    : PDialog;
  C    : PViewer;
  F    : PView;
  R    : TRect;
begin
  R.Assign(0,0,60,13);
  D:=New(PNDialog,Init(R,InstallHeader.ProgramName));
  D^.Options:=D^.Options Or ofCentered;
  D^.Flags:=wfMove;
  with D^ do
       begin
          R.Assign(18,2,35,3);
          F:=New(PInputLine,Init(R,15));
          Insert(F);

          R.Assign(1,2,17,3);
          F:=New(PLabel,Init(R,'S‚riov‚ ‡¡slo :',F));
          Insert(F);

          R.Assign(18,4,Size.X-1,5);
          Status:=New(PStaticText,Init(R,Data.OutDirectory));
          Insert(Status);

          R.Assign(1,4,17,5);
          F:=New(PLabel,Init(R,'Instalovat na:',F));
          Insert(F);

          R.Assign(1,Size.Y-3,16,Size.Y - 1);
          F:=New(PButton,Init(R,'~K~onec',CmCancel,bfNormal));
          Insert(F);

          R.Assign(Size.X-20,6,Size.X-2,8);
          F:=New(PButton,Init(R,'~Z~mˆ¤ adres ©',CmChangeDir,bfNormal));
          Insert(F);

          R.Assign(Size.X - 17,Size.Y-3,Size.X - 2,Size.Y - 1);
          F:=New(PButton,Init(R,'~D~al¨¡ >>',CmOk,bfDefault));
          Insert(F);
          SelectNext(False);
       end;
   Install := Application^.ExecuteDialog(D,@Data);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TInstallWizard.InitStatusLine;
Begin
  StatusLine:=Nil
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TInstallWizard.InitMenuBar;
Begin
  MenuBar:=Nil
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TInstallBackground.Draw;
Var
  B : TDrawBuffer;
  I : Integer;
  Color : Byte;
  ExtStr : String;
Begin
  Color:=$01;
  ExtStr:='';For I:=0 To Size.X Do ExtStr:=ExtStr+#32;
  For I:=0 To Size.Y Do
   Case I Of
   0: WriteStr(0,I,ExtStr,Color);
   1: WriteStr(0,I,ExtStr,Color);
   2: WriteStr(0,I,ExtStr,Color);
   3: WriteStr(0,I,ExtStr,Color);
   4: WriteStr(0,I,ExtStr,Color);
   5: WriteStr(0,I,'           _/_/_/_/_/                                                           ',Color);
   6: WriteStr(0,I,'              _/                                                                ',Color);
   7: WriteStr(0,I,'             _/                            _/                 _/  _/            ',Color);
   8: WriteStr(0,I,'            _/       _/         _/_/_/  _/_/_/               _/  _/             ',Color);
   9: WriteStr(0,I,'           _/       _/_/_/    _/         _/    _/_/_/       _/  _/              ',Color);
  10: WriteStr(0,I,'          _/       _/    _/    _/_/_/   _/    _/    _/     _/  _/               ',Color);
  11: WriteStr(0,I,'         _/       _/    _/         _/  _/    _/    _/_/   _/  _/                ',Color);
  12: WriteStr(0,I,'    _/_/_/_/_/   _/    _/    _/_/_/   _/      _/_/_/ _/  _/  _/                 ',Color);
  13: WriteStr(0,I,ExtStr,Color);
  14: WriteStr(0,I,'                         Instalacni program ver 2.0  - David Petrik             ',Color);
  15..100: WriteStr(0,I,ExtStr,Color);
 End;
  WriteLine(0,I,Size.X, I+1, B);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TInstallDesktop.InitBackground;
Var
  R: TRect;
Begin
  GetExtent(R);
  Background:=New(PInstallBackground, Init(R, #176));
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TInstallWizard.InitDesktop;
var
  R: TRect;
Begin
  GetExtent(R);
  Desktop:=New(PInstallDesktop, Init(R));
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
If Path[2]=':' Then Begin Disk:=Copy(Path,1,2);Delete(Path,1,2);End;
If Path[1]='\' Then Begin Disk:=Disk+'\';Delete(Path,1,1);End;
{$I-}
Chdir(Disk);
If Ioresult<>0 Then Begin CreateDirectory:=False;Exit;End;
{$I+}
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
     If Ioresult<>0 Then Begin Chdir(OldDirectory);CreateDirectory:=False;Exit;End;
     Chdir(AktualPath);
    End;
 Delete(Path,1,I);
 AktualPath:=AktualPath+'\';
 End;
Chdir(OldDirectory);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Type
    PBufer                          = ^TBufer;
    TBufer                          = Array[1..$FFFF] Of Byte;

Var FromF, ToF                      : File;
    OldDir                          : String;
    NumRead, NumWritten, BlockSize  : Word;
    Counter, FilSize                : Longint;
    Bufer                           : PBufer;
    FileHeader                      : TFileHeader;
    I, Z                            : Word;
    ID                              : ^String;
    InstallWizard                   : TInstallWizard;
    OldPosition                     : Longint;
    MaxBytes                        : Longint;
    WriteBytes                      : Longint;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TNInputLine.HandleEvent;
Begin
 TInputLine.HandleEvent(Event);
 If (Event.What=evKeyDown) and (Event.KeyCode=kbEnter) Then
   Begin
    ClearEvent(Event);
    Message(Dx,evCommand,cmOk,Nil);
   End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function InputLine(R:TRect;S:String):String;
Var  C : Pview;
Begin
  Dx:=New(PDialog,Init(R,''));
  Dx^.State:=Dx^.State Xor sfShadow;
  R.Assign(0,0,Dx^.Size.X,Dx^.Size.Y);
  C:=New(PNInputLine,Init(R,Dx^.Size.X-2));
  Dx^.Insert(C);
  Application^.ExecuteDialog(Dx,@S);
  InputLine:=S;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TNDialog.HandleEvent;
Var R:Trect;
Begin
  R.Assign(Origin.X+17,4+OriGin.Y,OriGin.X+58,Origin.Y+5);
  TDialog.HandleEvent(Event);
  If (Event.What=evCommand) and (Event.Command=cmChangeDir) Then
    Begin
      DisposeStr(Status^.Text);
      Status^.Text:=NewStr(InputLine(R,Data.OutDirectory));
      Data.OutDirectory:=Status^.Text^;
      Status^.Draw;
    End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure CreateInfo;
Var R  : Trect;
    C  : Pview;
    D  : PDialog;
Begin
 R.Assign(0,0,50,11);
 D:=New(PDialog,Init(R,'Instalace programu'));
 D^.Options:=D^.Options Or ofCentered;
 D^.Flags:=0;
 With D^ Do Begin
             R.Assign(2,2,Size.X-1,3);
             Text:=New(PStaticText,Init(R,'Vytv ©¡m adres © ...'));
             Insert(Text);

             R.Assign(2,6,Size.X-1,7);
             C:=New(PStaticText,Init(R,'Celkem nainstalov no :'));
             Insert(C);

             R.Assign(2,4,Size.X-2,5);
             FileStatus:=New(PBarGauge,Init(r,0));
             Insert(FileStatus);

             R.Assign(2,8,50-2,9);
             AllStatus:=New(PBarGauge,Init(r,0));
             Insert(AllStatus);

             SelectNext(False);
            End;
 Application^.InsertWindow(D);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure MSGToDOS(MSG : String;H:Word);
Begin
 TextColor(15);
 Write(MSG);TextColor(7);Writeln('');
 Dispose(Bufer);
 Chdir(OldDir);
 Halt(H);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure MSGToTV(MSG : String);
Begin
  MessageBox(MSG,Nil,mfError+MfOkButton);
  InstallWizard.Done;
  Chdir(OldDir);
  Halt(3);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
  LoadFont;                               { Nahraj font z Cestinou           }
  GetDir(0,OldDir);                       { Uloz aktualni adresar            }
  New(Bufer);
  Assign(FromF,'A:\INSTDATA.!!!');
  {$I-}
  Reset(FromF, 1);
  {$I+}
  If IOResult<>0 Then
    MSGToDOS('V mechanice a: nen¡ instala‡n¡ disketa [PROGRAM UKON€EN]',1);
  BlockRead(FromF,InstallHeader,SizeOf(InstallHeader));
  ReadSector(0,80,1);
  Id:=Ptr(Seg(SectorData),Ofs(SectorData));
  If ID^<>InstallHeader.Identifikation Then
    Begin
      Close(FromF);
      MSGToDOS('Neautorizovan  kopie originaln¡ diskety !!!!',2);
    End;
  With InstallHeader Do
    Begin
      Data.OutDirectory := OutDirectory;Data.SerialNumber:='';
        For I:=1 To Length(SerialNumber) Do SerialNumber[I]:=Chr(Ord(SerialNumber[I]) Xor Ord(Identifikation[I]));
{!!!!}Data.SerialNumber := SerialNumber; {Tento radek v orig. verzi vyhodit}
    End;

  InstallWizard.Init;
  If (Licence=CmYes) And (Install=CmOk) Then
    Begin
      If InstallHeader.SerialNumber<>Data.SerialNumber
        Then MsgToTV(#3+'›patn‚ s‚riov‚ ‡¡slo instalace bude ukon‡ena');
       {$I-}
       If Not CreateDirectory(Data.OutDirectory)
         Then MsgToTV(#3+'Nelze vytvo©it adres ©'+#13#3+'instalace bude ukon‡ena');
       If Data.OutDirectory[Length(Data.OutDirectory)]='\'
         Then Delete(Data.OutDirectory,Length(Data.OutDirectory),1);
        ChDir(Data.OutDirectory);
        {$I+}
        If IOResult <> 0 then MsgToTV(#3+'Nelze zmenit cestu'+#13#3+'instalace bude ukon‡ena');
        CreateInfo;
          {Najdi celkovou velikost souboru}
            OldPosition:=FilePos(FromF);MaxBytes:=0;
            Repeat
              BlockRead(FromF, FileHeader, SizeOf(FileHeader));
              Seek(FromF,FilePos(FromF)+FileHeader.FileSize);
              MaxBytes:=MaxBytes + FileHeader.FileSize;
            Until FilePos(FromF)=FileSize(FromF);
            Seek(FromF,OldPosition);
          {ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
            WriteBytes := 0;
            AllStatus^.Update(0,WriteBytes);
          Repeat
            FileStatus^.Update(0,0);
            Counter:=0;
            BlockRead(FromF, FileHeader, SizeOf(FileHeader));
            DisposeStr(Text^.Text);
            Text^.Text:=NewStr('Instaluji soubor : ' + FileHeader.FileName);
            Text^.Draw;
            Assign(ToF,FileHeader.FileName);
            {$I-}
            Rewrite(ToF,1);
            If Ioresult<>0 Then Begin
                                  Close(FromF);
                                  Dispose(Bufer);
                                  MsgToTV(#3+'Nelze zalo‘it soubor'+#13#3+'instalace bude ukon‡ena');
                                End;
            {$I+}
            Filsize:=FileHeader.FileSize;
              repeat
                BlockSize:=SizeOf(Bufer^);
                If BlockSize>FileHeader.FileSize Then BlockSize:=FileHeader.FileSize;
                Dec(FileHeader.FileSize,BlockSize);
                BlockRead(FromF, Bufer^,BlockSize, NumRead);
                 (* Kodovaci smycka*)
                 Z:=0;For I:=1 To Numread Do
                   Begin
                     Inc(Z);
                     Bufer^[I]:=Bufer^[I] Xor Ord(InstallHeader.Identifikation[Z]);
                     If Z=Length(InstallHeader.Identifikation) Then Z:=0;
                   End;
                 (* konec kodovaci smycky *)
                BlockWrite(ToF, Bufer^, NumRead, NumWritten);
                Counter:=Counter+BlockSize;
                FileStatus^.Update(Counter,FilSize);
                WriteBytes:=WriteBytes + BlockSize;
               AllStatus^.Update(WriteBytes,MaxBytes);
              until (FileHeader.FileSize = 0) or (NumWritten <> NumRead);
            Close(ToF);
          Until FilePos(FromF)=FileSize(FromF);
    MessageBox(#13#3+'Instalace byla £spe¨nˆ dokon‡ena',nil,mfInformation+mfOkButton);
    End;
  InstallWizard.Done;
  Close(FromF);
  Dispose(Bufer);
  Chdir(OldDir);
End.