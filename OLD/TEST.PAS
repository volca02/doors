Uses Strings,Crt;

function DriveValid(Drive: Char): Boolean; assembler;
asm
	MOV	AH,19H
        INT	21H
        MOV	BL,AL
 	MOV	DL,Drive
        SUB	DL,'A'
        MOV	AH,0EH
        INT	21H
        MOV	AH,19H
        INT	21H
        MOV	CX,0
        CMP	AL,DL
	JNE	@@1
        MOV	CX,1
	MOV	DL,BL
        MOV	AH,0EH
        INT	21H
@@1:	XCHG	AX,CX
end;

function GetRedirEntry(Entry: Word; Local, Net: Pointer): Boolean; assembler;
asm
        PUSH    DS
        LDS     SI,Local
        LES     DI,Net
        MOV     AX,5F02h
        MOV     BX,Entry
        INT     21h
        POP     DS
        SBB     AL,AL
        INC     AL
end;

function SetRedirEntry(Local, Net: Pointer): Boolean; assembler;
asm
        PUSH    DS
        LDS     SI,Local
        LES     DI,Net
        MOV     AX,5F03h
        MOV     BL,4
        MOV     CX,0
        INT     21h
        POP     DS
        SBB     AL,AL
        INC     AL
end;

function DelRedirEntry(Local:Pointer): Boolean; assembler;
asm
        PUSH    DS
        LDS     SI,Local
        MOV     AX,5F04h
        INT     21h
        POP     DS
        SBB     AL,AL
        INC     AL
end;

Procedure  RedirDeviceList;
var
  P: PChar;
  I: Word;
  LocalName: array[0..15] of char;
  NetworkName: array[0..127] of char;
 begin
 {$IFNDEF DPMI}
  for I := 0 to 99 do
  begin
    if GetRedirEntry(I, @LocalName, @NetworkName) then
      if (LocalName[0] in ['D'..'Z']) and (LocalName[1] = ':') then
              Writeln(LocalName[0],' - ',StrPas(@NetworkName[2]))
    else Break;
  end;
 {$ENDIF}
end;

Procedure Map(Drive:Char;NewMap:String);
Var LocalName:PChar;
    NetworkName:String;
Begin
 StrPCopy(LocalName,Drive+':');
 DelRedirEntry(LocalName);
 NetWorkName:=NewMap + #0#0#0;
 SetReDirEntry(LocalName,@NetworkName[1]);
End;

Begin
Clrscr;
If ParamStr(1)<>'' Then Map('F',ParamStr(1));
RedirDeviceList;
End.