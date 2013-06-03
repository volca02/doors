{$A-,B-,D+,E-,F-,I-,L-,N-,R-,S-,V-}
{$M 10000,0,60000}

Program DemoComp_OBJ;
Uses Dos,
     Crt,Overlay,
     CompSys;     { Kompresni unita }
{$I struct.pas}

Var CO      : CompressorType;                  { The "Work" object         }
    Search  : SearchRec;                       { For handeling Filespecs.  }
    Path    : PathStr;                         { The path to use           }
    Dum     : String[10];                      { A Dummy                   }
    IBMRec  : IBM;                             { IBM info record           }
    MACRec  : MAC;                             { MAC info record           }

Begin
ClrScr;
WriteLn('Skusebni dekompilacni program do doors');
WriteLn;
If ParamCount=0
   Then Begin
        WriteLn('Pouziti: DEMOCOMP <FileSpec>');
        WriteLn;
        Halt;
        End;

FSplit(ParamStr(1),Path,Dum,Dum);
FindFirst(ParamStr(1),AnyFile,Search);

While DosError=0 Do
 Begin
 If DetectCompressor(Path+Search.Name,CO)      { Find the compressor used   }
    Then Begin;
         WriteLn;
         CO^.CheckProtection;                  { Grab the info about        }
                                               { Security, version etc      }
         CO^.WriteHeader;                      { Write the header for the   }
                                               { found platform.            }
         CO^.FindFirstEntry;                   { Find the first file inside }
         While Not CO^.LastEntry Do            { The compressed file        }
          Begin
          CO^.PrintEntry;                      { Show the entry             }

          Case PlatformID(CO^.WhichPlatform) Of
           ID_IBM : CO^.ReturnEntry(IBMRec);
           ID_MAC : CO^.ReturnEntry(MACRec);
          End; {Mac}

          CO^.FindNextEntry;                   { Find the next entry        }
          End;
         End;
 FindNext(Search);
 End;
End.

