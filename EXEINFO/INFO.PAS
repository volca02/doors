Var F: File;
    Header:Word;
    HeaderStart: Longint;
    NumberOfItem:Word;
    TabOdkaz,TabJmen,I:Word;
    Data:String[12];
    Index:Word;
Procedure DosMsg(S:String);
Begin
Writeln(S);Halt(1);
End;

Begin
Writeln('INFo Master VrSiON 1..00');
If ParamCount<>1 Then Dosmsg('Spatne parametry');
Assign(F,ParamStr(1));
Reset(F,1);
BlockRead(F,Header,SizeOf(Header));
If Header<>$5A4D Then Dosmsg('Neni to exe soubour');
Seek(F,$18);
BlockRead(F,Header,SizeOf(Header));
If Header<$40 Then Dosmsg('Neni to soubor pro microsoft windows');
Seek(F,$3C);
BlockRead(F,HeaderStart,SizeOf(HeaderStart));
Seek(F,HeaderStart);
BlockRead(F,Header,SizeOf(Header));
If Header<>$454E Then Dosmsg('Neni to soubor pro microsoft windows');
Seek(F,HeaderStart+$1E);
BlockRead(F,NumberOfItem,SizeOf(NumberOfItem));
Writeln('Pocet odkazu :',NumberOfItem);
Seek(F,HeaderStart+$28);
BlockRead(F,TabOdkaz,SizeOf(TabOdkaz));
Seek(F,HeaderStart+$2A);
BlockRead(F,TabJmen,SizeOf(TabJmen));
For I:=1 To NumberOfItem Do
 Begin
  Seek(F,HeaderStart+TabOdkaz+(I-1)*2);BlockRead(F,Index,SizeOf(Index));
  Seek(F,HeaderStart+TabJmen+Index);BlockRead(F,Data,SizeOf(Data));
  Writeln(Data);
 End;
Close(F);
End.