Uses Objects,Dos, Base;
Type
  PFileRec = ^TFileRec;
  TFileRec = Record
                 Name : String[12];
                 Attr : Byte;
                 Time : Longint;
                 Size : Longint;
                 Selected : Boolean;
               End;

  PFiles           = ^TFiles;
  TFiles           = Object(TSortedCollection)
                      Function Compare(Key1, Key2: Pointer): Integer; virtual;
                      Procedure ReadDirectory(Dir: String); virtual;
                      Procedure FreeItem(Item: Pointer); virtual;
                     End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TFiles.FreeItem;
Var F :  PFileRec;
Begin
  F := Item;
  If Item <> Nil Then Dispose(F);
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
function TFiles.Compare;
Begin
  Compare := -1;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TFiles.ReadDirectory;
Var
  DirItem : SearchRec;
  Attr    : Word;
  F       : PFileRec;
  OldMemAvail : Longint;
Begin
  FreeAll;
  Duplicates := True;
  If (Dir[Length(Dir)]<>':') And (Dir[Length(Dir)]<>'\') Then Dir:=Dir+'\';
  Attr := AnyFile - VolumeId;
  FindFirst(Dir + '*.*', Attr, DirItem);
  while DosError = 0 do
  With DirItem Do begin
    If (DirItem.Name<>'.') and ((Dir[Length(Dir)-1] <> ':') or (DirItem.Name<>'..'))
    Then Begin
          F:= New(PFileRec);
          F^.Name:=Name;F^.Attr:=Attr;F^.Time:=Time;F^.Size:=Size;
          F^.Selected:=False;
           If (F^.Attr And Directory) = Directory Then F^.Name:=UpString(F^.Name)
             Else F^.Name:=DownString(F^.Name);
          Insert(F);
      End;
  FindNext(DirItem);
  end;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Var Files : PFiles;
    OldMem : Longint;
Begin
Writeln('Spusteini ------------------');
OldMem := MemAvail; Writeln(MemAvail);
Files:= New(PFiles,Init(0,1));
Writeln(OldMem - MemAvail);
Files^.ReadDirectory('C:\Windows\');
Writeln(OldMem - MemAvail);
Files^.ReadDirectory('C:\Windows\');
Writeln(OldMem - MemAvail);
Files^.ReadDirectory('C:\Windows\');
Writeln(OldMem - MemAvail);
Files^.ReadDirectory('C:\Windows\');
Writeln(OldMem - MemAvail);
Files^.ReadDirectory('C:\Windows\');
Dispose(Files,Done);
Writeln(OldMem - MemAvail);
End.