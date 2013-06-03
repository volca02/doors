Uses LongName;
Var LongNames : PLongNames;
Begin
 LongNames := New(PLongNames,Init);
 LongNames^.ReadDirectory('C:\',True);
 Dispose(LongNames,Done);
End.