{$O+,F+}
Unit Files;
Interface
Uses Objects;
function MakeDirectory:Word;
Procedure DeleteFiles(Data : PCollection;Focused : Word);
Function SetAttributs(Data : PCollection;Focused : Word): Boolean;
Implementation
Uses Dialogs, Views, App, DrsHelp, Base, MessBox, Variable, Dos;
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
Procedure DeleteDirectory(DirName :String;Select : Boolean);
Begin
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure DeleteFile(FileName :String;Select : Boolean);
Var F           : File;
    Attr        : Word;
    Confirm     : Word;
Begin
 Assign(F,FileName);
 GetFAttr(F,Attr);
 If DosError<>0 Then  Begin
 Confirm := MessageBox(#3'Soubor "' + FileName + '" '+
                          #13#3'Nelze smazat !!!!!!',Nil,
                          mfError + mfOkButton);
                       Exit;
                      End;

 SetFAttr(F,0);
 If (Attr And ReadOnly)= ReadOnly Then
    Confirm := MessageBox(#3'Soubor "' + FileName + '" je pouze pro cteni'+
                          #13#3'opravdu ho chcete smazat',Nil,
                          mfConfirmation + mfYesButton + mfNoButton);
 {$I-}
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
Procedure DeleteFiles(Data : PCollection;Focused : Word);
Var Select : Boolean;
    Number : Word;
    F      : PFileRec;
    Confirm : Word;
    I      : Word;
    FocusedName : String;
    FileType    : String;
    R           : Trect;
Begin
  If Data^.Count=0 Then Exit;Select := False;Number := 0;
  For I:=1 To Data^.Count-1 Do
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
  If (F^.Attr And Directory)= Directory Then FileType :='adresar'
    Else FileType := 'soubor';
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
     If F^.Attr = Directory Then DeleteDirectory(F^.Name,Select)
       Else DeleteFile(F^.Name,Select);
    End;
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