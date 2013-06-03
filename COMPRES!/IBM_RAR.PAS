{$O+,F+}
Unit IBM_RAR;
Interface
Uses BSC;

Type TRAR = Object(TCompressor)
       Constructor RARInit;
       Procedure FindFirstEntry;   Virtual;
       Procedure FindNextEntry;    Virtual;
       Procedure LoadFiles;        Virtual;
       Procedure CheckProtection;  Virtual;
       Function IsThisTypeFile(Var B ;Size : Word):Boolean; Virtual;
     End; {Object}

     PRAR = ^TRAR;

Implementation
Uses Objects;
Const RARMethodes : Array[$30..$35] of String[10] =
                    ( 'Storing   ',
                      'Fastest   ',
                      'Fast      ',
                      'Normal    ',
                      'Good      ',
                      'Best      '
                      );



Type HeaderType   = Record
       CRC        : Word;
       Typ        : Byte;
       Flags      : Word;
       Size       : Word;
     End;

     ArcHeader    = Record
      Res1        : Word;
      Res2        : LongInt;
     End;

     FileHeader   = Record
      PackSize    : LongInt;
      UnpSize     : LongInt;
      HostOS      : Byte;
      CRClo       : Word;
      CRChi       : Word;
      FileDate    : LongInt;
      UnpVer      : Byte;
      Methode     : Byte;
      NameSize    : Word;
      Attr        : LongInt;
     End;

     CommHeader   = Record
      UnpSize     : Word;
      UnpVer      : Byte;
      Methode     : Byte;
      CommCrc     : Word;
     End;
     NameBuffer   = Array[1..255] of Char;

Var F        : File;
    Header   : HeaderType;
    ArchHead : ArcHeader;
    CommHead : CommHeader;
    FileHead : FileHeader;
    AName    : NameBuffer;

Constructor TRAR.RARInit;
Begin
Init;
Platform:=ID_IBM;
CompressorType:='RAR';
CompressorName:='RAR';
Magic:=RAR_Type;  { A unique number within the toolbox }
End;



Procedure TRAR.FindFirstEntry;
Var  Stop     : Boolean;
     AddSize  : LongInt;
Begin

SetFileMode(ReadOnly+ShareDenyNone);
Assign(F,FileName);
Reset(F,1);

Stop:=False;
Repeat
 Seek(F,WhereInFile);
 BlockRead(F,Header,SizeOf(Header),RR);
 If RR<>SizeOf(Header)
    Then Begin
         Close(F);
         LastEntry:=True;
         ResetFileMode;
         Exit;
         End;

 If (Header.Typ=$74)
    Then WhereInFile:=WhereInFile+Header.Size
    Else Begin
         If (Header.Flags And $8000) = 0
            Then WhereInFile:=WhereInFile+Header.Size
            Else Begin
                 BlockRead(F,AddSize,4,RR);
                 WhereInFile:=WhereInFile+Header.Size+AddSize;
                 End;
         End;

 Case Header.Typ of
   $73 : Begin
         SolidArchive  := IsBitSet(Header.Flags,$0008);
         ProtectedFile := IsBitSet(Header.Flags,$0020);
         Locked        := IsBitSet(Header.Flags,$0004);
         If FileExtra<>''
             Then Dec(FileExtra[0],2);
         End;
   $74 : Begin
         BlockRead(F,FileHead,SizeOf(FileHead),RR);
         Stop:=True;
         WhereInFile:=WhereInFile+FileHead.PackSize;
         If Not BeQuick
            Then Begin
                 With IBM(Entry) Do
                  Begin
                  Fillchar(AName,SizeOf(AName),#00);
                  BlockRead(F,AName,FileHead.NameSize,RR);
                  FileName       :=Asciiz2String(AName);
                  ContainsPaths  :=Pos('/',FileName)>0;
                  OriginalSize   :=FileHead.UnpSize;
                  CompressedSize :=FileHead.PackSize;
                  If (FileHead.Attr And $10)=$10
                     Then CompressionName:='<DIR>     '
                     Else CompressionName:=RARMethodes[FileHead.Methode];
                  FileCRC:=HexWord(FileHead.CRChi)+HexWord(FileHead.CRClo);
                  FileDate:=TimeStamp(FileHead.FileDate);
                  If ProtectedFile
                     Then SaveID:='-SE'
                     Else SaveID:='';
                  End;
                 End;
         UnpackVersion:=FileHead.UnpVer;
         HasPassword:=IsBitSet(Header.Flags,$0004);
         End;

End; {Case}

Until Stop;
Close(F);
ResetFileMode;
End;

Procedure TRAR.FindNextEntry;
Var HeaderID : LongInt;
    ExtraTag : Word;
    Stop     : Boolean;
    AddSize  : LongInt;
Begin
SetFileMode(ReadOnly+ShareDenyNone);
Assign(F,FileName);
Reset(F,1);
Seek(F,WhereInFile);

Stop:=False;
Repeat
 Seek(F,WhereInFile);
 BlockRead(F,Header,SizeOf(Header),RR);
 If RR<>SizeOf(Header)
    Then Begin
         Close(F);
         LastEntry:=True;
         ResetFileMode;
         Exit;
         End;

 If (Header.Typ=$74)
    Then WhereInFile:=WhereInFile+Header.Size
    Else Begin
         If (Header.Flags And $8000) = 0
            Then WhereInFile:=WhereInFile+Header.Size
            Else Begin
                 BlockRead(F,AddSize,4,RR);
                 WhereInFile:=WhereInFile+Header.Size+AddSize;
                 End;
         End;


 If Header.Typ=$74
    Then Begin
         BlockRead(F,FileHead,SizeOf(FileHead),RR);
         Stop:=True;
         WhereInFile:=WhereInFile+FileHead.PackSize;
         If Not BeQuick
            Then Begin
                 With IBM(Entry) Do
                  Begin
                  Fillchar(AName,SizeOf(AName),#00);
                  BlockRead(F,AName,FileHead.NameSize,RR);
                  FileName       :=Asciiz2String(AName);
                  ContainsPaths  :=(Pos('/',FileName)>0) or
                                   (Pos('\',FileName)>0);
                  OriginalSize   :=FileHead.UnpSize;
                  CompressedSize :=FileHead.PackSize;
                  If (FileHead.Attr And $10)=$10
                     Then CompressionName:='<DIR>     '
                     Else CompressionName:=RARMethodes[FileHead.Methode];
                  FileCRC:=HexWord(FileHead.CRChi)+HexWord(FileHead.CRClo);
                  {FileCRC:=HexLong(FileHead.FCRC);}
                  FileDate:=TimeStamp(FileHead.FileDate);
                  If ProtectedFile
                     Then SaveID:='-SE'
                     Else SaveID:='';
                  If FileHead.UnpVer>UnpackVersion
                     Then UnpackVersion:=FileHead.UnpVer;
                  End;
                 End;
         HasPassword:=IsBitSet(Header.Flags,$0004);
         If FileHead.UnpVer>UnpackVersion
            Then UnpackVersion:=FileHead.UnpVer;
         End;
Until Stop;

Close(F);
ResetFileMode;
End;

Procedure TRAR.LoadFiles;
Var PS:^String;
Begin
If Files=Nil Then Files:=New(PStringCollection,Init(0,1));
If (Files<>Nil) And (Files^.Count<>0) Then Files^.DeleteAll; {POZOR !!!!}
FindFirstEntry;                   { Find the first file inside }
While Not LastEntry Do            { The compressed file        }
          Begin
          New(PS);PS^:=IBM(Entry).Filename;
          Files^.Insert(PS);
          FindNextEntry;                   { Find the next entry        }
          Write(#13,'Files :',Files^.Count,'Percent :',Trunc(WhereInFile/FileSize*100));
          End;

End;

Procedure TRAR.CheckProtection;
Var Old : LongInt;
Begin
Old:=WhereInFile;
BeQuick:=True;

FindFirstEntry;
While Not LastEntry Do
 FindNextEntry;

BeQuick:=False;
WhereInFile:=Old;
LastEntry:=False;
End;

Function TRAR.IsThisTypeFile(Var B ;Size : Word):Boolean;
Begin
RARInit;  { Reinit the current object }
IsThisTypeFile:=True;
WhereInFile:=0;

With HeaderType(B) Do
 If (CRC=$6152)   And
    (Typ=$72)     And
    (Flags=$1A21) And
    (Size=$007)
    Then Exit;

If IsExeFile(B)
   Then Begin
        SelfExtractor:=True;
        If SearchBuffer(B,Size,6000,7500,#$52#$61#$72#$21#$1A#$07#$00,WhereInFile)
           Then Exit;
        If SearchBuffer(B,Size,9000,9500,#$52#$61#$72#$21#$1A#$07#$00,WhereInFile)
           Then Exit;
        End;

IsThisTypeFile:=False;
End;

End.

