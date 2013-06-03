{$O+,F+}
Unit Disk;
Interface
Procedure  DiskLabel(Drv : Char);
Procedure  DiskPark;
Implementation
Uses Dialogs, Views, Objects, App, Reader, DrsHelp, MessBox;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure DiskPark;
Var MaxHard : Byte;
Begin
  Asm
   mov ah,08h
   mov dl,80h
   int 13h
   mov MaxHard,Dl
   Cmp Dl,2
   Jne @No_2
   mov dl,81h
   mov ah,19h
   int 13h
   @No_2:
   mov dl,80h
   mov ah,19h
   int 13h
  End;
MessageBox('Vsechny pevne disky zaparkovany ('+Chr(MaxHard+48)+')',Nil,mfInformation+mfOkButton);
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure  DiskLabel(Drv : Char);
var
  D    : PDialog;
  C    : PView;
  L    : PLabel;
  R    : TRect;
  DiskLabel : String[11];
  Status : Word;
  Message : String [30];
  BootSector : TBootSector;
  I          : Byte;
begin
  Application^.HelpCtx := hcDiskName;
  R.Assign(23,7,56,15);
  D:=New(PDialog,Init(R,'Jm굈o disku'));
  with D^ do
       begin
          R.Assign(4,5,14,7);
          C:=New(PButton,Init(R,'~A~no',cmYes,bfNormal));
          Insert(C);

          R.Assign(17,5,27,7);
          C:=New(PButton,Init(R,'~N~e',cmNo,bfNormal));
          Insert(C);

          R.Assign(3,3,30,4);
          C:=New(PInputLine,Init(R,12));
          Insert(C);
          R.Assign(2,2,29,3);
          Message :='Zadejte jm굈o pro disk X:';
          Message[Length(Message)-1]:=Drv;
          L:=New(PLabel,Init(R,Message,C));
          Insert(L);

          SelectNext(True);
       end;
   DosReadSector(0,Ord(Drv)-Ord('A'),@BootSector);
   For I:=1 To 12 Do DiskLabel[I]:=BootSector.VolumeLabel[I];
   DiskLabel[0] := #12;
   C^.Select;
   Status:=Application^.ExecuteDialog(D,@DiskLabel);
   Application^.HelpCtx := hcNocontext;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
End.