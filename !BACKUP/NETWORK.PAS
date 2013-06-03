{$O+,F-}
Unit NetWork;
Interface
Uses Objects, Dialogs, Views, Drivers, Base, Dos, App, Variable, MessBox;
  function UserList : Word;
  procedure Log_Out;
{$I INC\Novell.inc}
 Var Data       : PCollection;
 Const
       SendName = True;
Type
    PNewDialog = ^TNewDialog;
    TNewDialog = Object(TDialog)
                   procedure HandleEvent(var Event: TEvent); virtual;
                 End;

   PNListBOx = ^TNListBOx;
   tNListBox = OBJEct(TListViewer)
                function GetText(Item: Integer; MaxLen: Integer): String; virtual;
                procedure HandleEvent(var Event: TEvent); virtual;
                function IsSelected(Item: Integer): Boolean; virtual;
               eND;
   PDRIVERData = ^TDRIVERData;
   TDRIVERData = record
               Data1                :  PCollection;
               Data2                :  integer;
           end;

   PUserCollection = ^TUserCollection;
   TUserCollection = Object (TSortedCollection)
                      function Compare(Key1, Key2: Pointer): Integer; virtual;
                      procedure FreeItem(Item: Pointer); virtual;
                     End;
Var Users : PUserCollection;
    P : PNListBox;

Function TUserCollection.Compare;
Var K1,K2:PUserRec;
Begin
 K1:=Key1;K2:=Key2;
 If K1^.Name>K2^.Name Then Compare:=1
  Else If K1^.Name<K2^.Name Then Compare:=-1
   Else Compare := 0;
End;

procedure TUserCollection.FreeItem;
Var X:PUserRec;
Begin
 X:=Item;Dispose(X);
End;

procedure TNewDialog.HandleEvent;
Var Swap : PView;
Begin
  If (Event.What=evKeyDown) and (Event.KeyCode=kbEnter) Then Message(@Self,evCommand,CmOk,nil);
  TDialog.HandleEvent(Event);
End;

function TNListBox.IsSelected;
Var N : PUserRec;
Begin
N := Users^.At(Item);
IsSelected:= N^.Selected;
End;

Procedure TNListBox.HandleEvent;
Const Searched : Boolean = False;
Var N:PuserRec;
    retcode: integer;
    Message : String;
    I : Integer;
    Tecka : Integer;
    Ident : String;
    Confirm : Word;
Begin
If (Event.What=evKeyDown) and(Event.KeyCode=kbIns) Then
  Begin
   N := Users^.At(Focused);
   N^.Selected := N^.Selected Xor True;
   If (Focused<>(Range-1)) Then FocusItem(Focused+1);
   Draw;
  End;
If (Event.What=evCommand) and (Event.Command=CmSend) Then
  Begin
    N:=Users^.At(Focused);
    Message := '';
    Confirm := InputBox('Posilani zprav','Zadejte text zpravy :',Message,80,hiSendMessage);
    If (Message<>'') And (Confirm=CmOk) Then
      Begin
        Ident := Whoami;
        Tecka := Pos('.',Ident);
        If Tecka>0 Then Delete(Ident,Tecka,Length(Ident)-Tecka+1);
        If SendName Then Message := '['+ Ident +']:'+Message;
        For I:=1 To Users^.Count-1 Do
          Begin
            N:=Users^.At(I);
            If N^.Selected Then
             Begin
               Send_Message_to_Station(N^.Connection,Message,retcode);
               Searched:=True;
             End;
          End;
        N:=Users^.At(Focused);
        If Not Searched Then Send_Message_to_Station(N^.Connection,Message,retcode);
      End;
    ClearEvent(Event);
  End;
TListViewer.HandleEvent(Event);
End;

Function TNListBOx.GetText;
Var X:PUserRec;
    OutStr : String;
Begin
  X := Users^.At(Item);
  OutStr := FillToLength(IntToStr(X^.Connection),4,' ');
  OutStr := OutStr + FillToLength(X^.Name,25,' ');
  OutStr := OutStr + FillToLength(X^.HexId,10,' ');
  OutStr := OutStr + FillToLength(X^.Datetime,10,' ');

  Gettext := OutStr;
End;

function UserList : Word;
var
  D    : PDialog;
  C    : PView;
  SB   : PScrollBar;
  R    : TRect;
begin
  Users:=New(PUserCollection,Init(0,1));
  GetUserList(Users^);
  If Users^.Count<>0 Then
  Begin
  R.Assign(0,0,58,Application^.Size.Y-4);
  D:=New(PDialog,Init(R,'Seznam prihlasenych uzivatelu'));
  with D^ do
       begin
          Options:=Options or ofCentered;
          R.Assign(1,2,Size.X-1,Size.Y-4);
          P:=New(PNListBox,Init(R,1,nil,nil));
          P^.Range:=Users^.Count;
          Insert(P);

          R.Assign(2,1,Size.X-1,2);
          C:=New(PStaticText,Init(R,'      Jmeno uzivatele         Adresa     Datum a cas'));
          Insert(C);

          R.Assign((Size.X Div 2)+11,Size.Y-3,(Size.X Div 2)+21,Size.Y-1);
          C:=New(PButton,Init(R,'~O~k',cmOk,bfNormal));
          Insert(C);

          R.Assign((Size.X Div 2)-21,Size.Y-3,(Size.X Div 2)-1,Size.Y-1);
          C:=New(PButton,Init(R,'~P~oslat zpravu',cmSend,bfNormal));
          Insert(C);

          SelectNext(False);
       end;
   UserList:=Application^.ExecuteDialog(D,Nil);
   End
     Else If Whoami='' Then MessageBox(#3+'Bohuzel nejste prihlasen k siti',nil,mfOkButton + mfInformation)
      Else MessageBox(#3+'Nelze nacist prihlasene uzivatele',nil,mfOkButton + mfInformation);
  Dispose(Users,Done);
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Log_out;
Begin
 If Whoami <> '' Then Begin
                       Logout;
                       MessageBox(#3+'Prave jste byl odhlasen od vsech servru',nil,mfOkButton + mfInformation);
                      End
   Else MessageBox(#3+'Bohuzel nejste prihlasen k siti',nil,mfOkButton + mfInformation)
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}


End.