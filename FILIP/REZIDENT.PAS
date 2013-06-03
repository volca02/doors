Uses App, Views, Objects, Dialogs, Dos, Base;
Type
  PTSRRec = ^TTSRRec;
  TTSRRec = Record
                 Addres    : Word;
                 Typ       : Char;
                 Size      : Longint;
                 Owner     : Word;
                 Name      : PString;
                 DataTyp   : PString;
                 Parametrs : PString;
                End;
  PTSRCollection = ^TTSRCollection;
  TTSRCollection = Object(TCollection)
                    procedure FreeItem(Item: Pointer); virtual;
                   End;
  PTSRListViewer = ^TTSRListViewer;
  TTSRListViewer = Object(TListViewer)
                         function GetText(Item: Integer; MaxLen: Integer): String; virtual;
                       End;

Var A: TApplication;
    TSRs : PCollection;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TTSRCollection.FreeItem;
begin
 if item<>Nil Then Begin
                    If PTSRRec(Item)^.Name <> Nil
                      Then DisposeStr(PTSRRec(Item)^.Name);
                    If PTSRRec(Item)^.DataTyp <> Nil
                      Then DisposeStr(PTSRRec(Item)^.DataTyp);
                    If PTSRRec(Item)^.Parametrs <> Nil
                      Then DisposeStr(PTSRRec(Item)^.Parametrs);
                    Dispose(PTSRRec(Item));
                   End;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
function TTSRListViewer.GetText;
Var S : String;
    Prog : PTSRRec;
Begin
  Prog := TSRs^.At(Item);S:='';
  S:=S + FillToFront(DecToHex(Prog^.Addres),4,'0');
  S:=S + #32 + FillToFront(Thousand(Prog^.Size),10,#32);
  If Prog^.Name<>Nil Then S:=S + #32 + FillToLength(Prog^.Name^,12,#32)
    Else S:=S + FillToLength('',13,#32);
  If Prog^.DataTyp<> Nil Then
    S:=S + #32 + FillToLength(Prog^.DataTyp^,15,#32);
  If Prog^.Parametrs<> Nil Then
    S:=S + #32 + Prog^.Parametrs^;
  GetText:=S;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function TSRList:Word;
Var D        : PDialog;
    R        : TRect;
    P        : PTSRListViewer;
    V        : PView;
    I        : Byte;
    Prog     : PTsrRec;
    N        : String;
    C        : Word;
    Number   : Byte;
    GoodName : Boolean;
    MainRec  : PTSRRec;
    Rec      : PTSrRec;
Begin
  TSRs:=New(PTSRCollection,Init(0,1));
   asm
    mov ax,5200h
    int 21h
    mov ax,word ptr es:[bx+0FFFEh]
    inc ax
    mov C,ax
   end;
  While char(mem[C:0])<>'Z' Do
    begin
      New(Prog);TSRs^.Insert(Prog);
      Prog^.Typ     := Char(mem[C:0]);
      Prog^.Size    := longint(memw[C:3]) shl 4;
      Prog^.Owner   := memw[C:1];
      Prog^.Addres  := C;
      Prog^.Name    := Nil;
      Prog^.DataTyp    := Nil;
      Prog^.Parametrs  := Nil;
      C := C + memw[C:03]+1;
    end;
  For I:=0 To TSRs^.Count-1 Do
    With PTSRRec(TSRs^.At(I))^ Do
       If Typ in ['D','I','M','Z'] Then
         Begin
          N := '';
          For C:=8 To 15 Do Begin
                             If mem[Addres:C] = 0 Then Break;
                             N := N + Chr(mem[Addres:C])
                            End;
          GoodName := True;
          For C:= 1 To Length(N) Do If N[C]<#32 Then GoodName := False;
          If Not GoodName Then N := '';
          If Owner <> 0 Then Name := NewStr(N)
            Else Begin Name:= Nil;DataTyp := NewStr('Voln  pamˆŸ');End;
        End;

   For I:=0 To TSRs^.Count-1 Do {Slouceni vlasniku }
    Begin
     MainRec := TSRs^.At(I);
     If MemW[MainRec^.Addres:$10] = $20CD Then
      For C:=0 To TSRs^.Count-1 Do
        Begin
         Rec:= TSRs^.At(C);
         If (MainRec^.Owner = Rec^.Owner) And (I<>C) Then
          Begin
           If Rec^.Name <> Nil Then Begin DisposeStr(Rec^.Name);Rec^.Name :=Nil; End;
           If MainRec^.Name<>Nil Then
             Begin
              If memW[MainRec^.Addres+1:$2C] = Rec^.Addres+1 Then
                If Rec^.DataTyp = Nil Then Rec^.DataTyp := NewStr('Prost©ed¡ DOSU');
              Rec^.Name := NewStr(MainRec^.Name^);
             End;
          End;
        End;
    End;

    For I:=0 To TSRs^.Count-1 Do {Nastaveni typu dat}
     Begin
      MainRec := TSRs^.At(I);
      If MainRec^.DataTyp=Nil Then
        Case MainRec^.Typ Of
         'D': MainRec^.DataTyp := NewStr('Ovlada‡ za©¡zen¡');
         'I': MainRec^.DataTyp := NewStr('Install');
          Else If (MemW[MainRec^.Addres:$10] = $20CD) Then
                 MainRec^.DataTyp := NewStr('Program')
                  Else MainRec^.DataTyp := NewStr('Data');
        End;
     End;

    For I:=0 To TSRs^.Count-1 Do {Zjisteni parametru}
     Begin
      MainRec := TSRs^.At(I);
      If ((MainRec^.Typ='M') Or (MainRec^.Typ='Z')) And
          (MemW[MainRec^.Addres:$10] = $20CD) Then
          Begin
           N:='';
           Number := mem[MainRec^.Addres+1:$80];
           For C:=1 To Number Do N:=N + Char(mem[MainRec^.Addres+1:$80+C]);
           MainRec^.Parametrs := NewStr(N)
          End;
     End;

  R.Assign(0,0,76,20);
  D:=New(PDialog,Init(R,'Rezidentni programy'));
  D^.Options := SetBit(D^.Options,ofCentered);
  With D^ Do Begin
               R.Assign(1,1,Size.X-1,2);
               V:=New(PstaticText,Init(R,'Segment Velikost Jmeno        Typ              Parametry'));
               Insert(V);

               R.Assign(1,2,Size.X-1,Size.Y-4);
               P:=New(PTSRListViewer,Init(R,1,nil,nil));
               P^.Range:=TSRs^.Count;
               Insert(P);

               R.Assign((Size.X Div 2)-5,Size.Y-3,(Size.X Div 2)+5,Size.Y-1);
               V:=New(PButton,Init(R,'~O~k',CmOk,bfDefault));
               Insert(V);

               SelectNext(False);
             End;
  TSRList:=Application^.ExecuteDialog(D,Nil);
  Dispose(TSRs,Done);
End;

Begin
 A.Init;
 TSRList;
 A.Done;
End.