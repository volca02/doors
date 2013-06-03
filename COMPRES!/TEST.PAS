Uses CompSys,IBM_RAR,Crt;
Var RAR:PRAR;
    I:Integer;
    PS:^String;
    F:File;
Begin
RAR:=New(PRar,RarInit);
Rar^.Files:=Nil;
Rar^.WhereInFile:=0;
Rar^.FileName:=ParamStr(1);
Assign(F,Rar^.FileName);Reset(F,1);Rar^.FileSize:=Filesize(F);Close(F);
{Rar^.CheckProtection; }                 { Grab the info about        }
{Rar^.WriteHeader;  }                    { Write the header for the   }
                                               { found platform.            }
Rar^.LoadFiles;
Readkey;
For I:=0 To Rar^.Files^.Count-1 Do Begin PS:=Rar^.Files^.At(I);Writeln(PS^);End;
End.