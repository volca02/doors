{$F+,O+}
Unit Options;
Interface
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Uses ColorSel, Objects, Dialogs, Views, App, Memory, Drivers, DrsHelp;
const
  CClickTester = #7#8;
type
  PClickTester = ^TClickTester;
  TClickTester = object(TStaticText)
    Clicked: Boolean;
    constructor Init(var Bounds: TRect; AText: String);
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Draw; virtual;
  end;

  { TMouseDialog }

  PMouseDialog = ^TMouseDialog;
  TMouseDialog = object(TDialog)
    MouseScrollBar: PScrollBar;
    OldDelay: Word;
  end;

  PSetSaverDialog = ^TSetSaverDialog;
  TSetSaverDialog = Object(TDialog)
                     Procedure HandleEvent(Var Event : Tevent);Virtual;
                    End;
   PMode = ^TMode;
   TMode = Record
               Data1                :  Word;
               Data2                :  Word;
            end;

Procedure SaveConfiguration;
Procedure SaveSwapConfiguration;
Procedure SetScreenSaver;
Procedure SetConfirmation;
Procedure SetMouse;
Procedure SetSystem;
Procedure ChangeColors;
Procedure SetVideoMode;
Procedure SetPalette;

Implementation
Uses Variable, Base, MessBox, ScrSav, Supply;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SaveConfiguration;
Var F : File;
    PalS : PStream;
Begin
  Assign(F,GetStartupPath + ConfigurationFileName);
  {$I-}
  Rewrite(F,1);
  {$I+}
  If Ioresult<>0 Then Exit;
  BlockWrite(F,Configuration,SizeOf(Configuration));
  Close(F);
  MessageBox(#3'Nastaveni bylo ulozeno do souboru'+ #13 +
             #3 + GetStartupPath + ConfigurationFileName ,Nil,mfInformation+mfOkButton);

  PalS:= New(PBufStream,Init(GetStartupPath+'drs.pal',stCreate,1024));
  Pals^.WriteStr(@Application^.GetPalette^);
  Dispose(Pals,Done);
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SaveSwapConfiguration;
Var F : File;
    PalS : PStream;
Begin
  Assign(F,GetStartupPath + SwapCfgFileName);
  {$I-}
  Rewrite(F,1);
  {$I+}
  If Ioresult<>0 Then Exit;
  BlockWrite(F,Configuration,SizeOf(Configuration));
  Close(F);
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TSetSaverDialog.HandleEvent;
Var
  ScrDat : Record
            Typ   : Word;
            Mouse : Word;
            Time  : String[2];
           End;
Begin
Inherited HandleEvent(Event);
If (Event.What = evCommand) And (Event.Command = CmTestSaver) Then
  Begin
    GetData(ScrDat);
    Configuration.ScreenSaver.Typ := ScrDat.Typ;
    RunScreenSaver;
    ClearEvent(Event);
  End;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetSystem;
Const  Clock      = 1;
       Keyboard   = 2;
       Hidden     = 4;
       LongNames  = 8;
       Attributs  = 16;
       Verify     = 32;
       ChangeSize = 64;
Type
   TSystemData = record
               Config          :  Word;
               HistSize        :  string[2];
           end;
Var
  D    : PDialog;
  C    : PView;
  L    : PLabel;
  R    : TRect;
  SyStemData : TSystemData;
  Confirm    : Word;
begin
  R.Assign(5,4,75,19);
  D:=New(PDialog,Init(R,'Nastaven� syst굆u'));
  D^.Options := SetBit(D^.Options,ofCentered);
  with D^ do
       begin
          R.Assign(23,12,33,14);
          C:=New(PButton,Init(R,'~O~k',cmOk,bfDefault));
          Insert(C);

          R.Assign(34,12,44,14);
          C:=New(PButton,Init(R,'~Z~ru쮑t',cmCancel,bfNormal));
          Insert(C);

          R.Assign(3,2,Size.X-3,Size.Y-6);
          C:=New(PCheckBoxes,Init(R,
               NewSItem('Zobrazovat hodiny',
               NewSItem('Zobrazovat typ kl쟶esnice',
               NewSItem('Zobrazovat skryt� soubory',
               NewSItem('Zobrazovat dlouh� jm굈a soubor�',
               NewSItem('Mazat atribut pouze pro 뇍eni p쯫 kop죚ov쟮� z CD-ROM',
               NewSItem('Verifikace z쟰isu na disk',
               NewSItem('Mo몁ost m늧it velikost a um죛t늧� panel�',
               nil)))))))));
          Insert(C);

          R.Assign(60,10,64,11);
          C:=New(PInputLine,Init(R,2));
          Insert(C);
          R.Assign(2,10,60,11);
          L:=New(PLabel,Init(R,'Velikost pameti pro historii vstupn죅h 찤dek (1-10 Kb) :',C));
          Insert(L);

          SelectNext(False);
       end;

   SystemData.HistSize := IntToStr(Configuration.System.HistSize);
   With Configuration.System Do With SystemData Do
    Begin
     Config := 0;
     If ShowClock Then Config := SetBit( Config, Clock);
     If ShowCzechType Then Config := SetBit( Config, KeyBoard);
     If ShowHiddenFiles Then Config := SetBit( Config, Hidden);
     If VerifyWrite     Then Config := SetBit( Config, Verify);
     If Resize          Then Config := SetBit( Config, ChangeSize);
     If ShowLongNames   Then Config := SetBit( Config, LongNames);
    End;
   Confirm:=Application^.ExecuteDialog(D,@SystemData);
   If Confirm<>CmOk Then Exit;
   Configuration.System.HistSize := StrToInt(SystemData.HistSize);
   With Configuration.System Do If (HistSize<1) Or (HistSize>10) Then HistSize := 1;
   With Configuration.System Do With SystemData Do
    Begin
     ShowClock := ((Config And Clock) = Clock);
     ShowCzechType := ((Config And KeyBoard) = KeyBoard);
     ShowHiddenFiles := ((Config And Hidden) = Hidden);
     ShowLongNames := ((Config And LongNames) = LongNames);
     VerifyWrite := ((Config And Verify) = Verify);
     Resize      := ((Config And ChangeSize) = ChangeSize);
     SetVerify(VerifyWrite);
    End;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetScreenSaver;
var
  ScrDat : Record
            Typ   : Word;
            Mouse : Word;
            Time  : String[2];
           End;
  D    : PSetSaverDialog;
  C    : PView;
  L    : PLabel;
  R    : TRect;
  St   : Word;
begin
  R.Assign(15,0,64,13);
  D:=New(PSetSaverDialog,Init(R,'Nastaven� 쮍t쯫놽 obrazovky'));
  D^.Options := SetBit(D^.Options,ofCentered);
  with D^ do
       begin
          R.Assign(2,3,24,7);
          C:=New(PRadioButtons,Init(R,
               NewSItem('Pr뻦et vesm죚em',
               NewSItem('N쟰isy',
               NewSItem('Vypnuti monitoru',
               NewSItem('Zadny',
               nil))))));
          Insert(C);

          R.Assign(1,2,14,3);
          L:=New(PLabel,Init(R,'Typ 쮍t쯫놽',C));
          Insert(L);

          R.Assign(2,8,33,9);
          C:=New(PCheckBoxes,Init(R,
               NewSItem('쌷t쯫� lze spou쮝늯 myÆ',
               nil)));
          Insert(C);

          R.Assign(34,10,38,11);
          C:=New(PInputLine,Init(R,2));
          Insert(C);

          R.Assign(2,10,33,11);
          L:=New(PLabel,Init(R,'Automaticke spousteni (min) :',C));
          Insert(L);

          R.Assign(36,2,46,4);
          C:=New(PButton,Init(R,'~O~k',cmOk,bfDefault));
          Insert(C);

          R.Assign(36,4,46,6);
          C:=New(PButton,Init(R,'~T~est',cmTestSaver,bfNormal));
          Insert(C);

          R.Assign(36,6,46,8);
          C:=New(PButton,Init(R,'~Z~ru쮑t',cmCancel,bfNormal));
          Insert(C);

          SelectNext(False);
       end;

   ScrDat.Typ  := Configuration.ScreenSaver.Typ;
   ScrDat.Time := IntToStr(Configuration.ScreenSaver.Interval);
   If Configuration.ScreenSaver.Mouse Then ScrDat.Mouse:=1
     Else ScrDat.Mouse:=0;
   St := Application^.ExecuteDialog(D,@ScrDat);
   If St = CmCancel Then Exit;
   Configuration.ScreenSaver.Typ := ScrDat.Typ;
   Configuration.ScreenSaver.Interval := StrToInt(ScrDat.Time);
   If ScrDat.Mouse= 1 Then Configuration.ScreenSaver.Mouse := True
     Else Configuration.ScreenSaver.Mouse := False;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetConfirmation;
var
  D    : PDialog;
  C    : PView;
  L    : PLabel;
  R    : TRect;
begin
  R.Assign(17,5,63,17);
  D:=New(PDialog,Init(R,'Potvrzen�'));
  with D^ do
       begin
          R.Assign(4,3,43,7);
          C:=New(PFramedView,Init(R));
          Insert(C);

          R.Assign(5,3,42,7);
          C:=New(PCheckBoxes,Init(R,
               NewSItem('Maz쟮� nepr쟺dn쁟h adres젵�',
               NewSItem('Maz쟮� soubor� pouze pro 뇍en�',
               NewSItem('Uzav쯥n� CD p쯥hr쟶a놽',
               NewSItem('Ukon놽n� programu',
               nil))))));
          Insert(C);
          R.Assign(4,2,25,3);
          L:=New(PLabel,Init(R,'Cht죜 potvrzen� p쯫',C));
          Insert(L);

          R.Assign(12,9,22,11);
          C:=New(PButton,Init(R,'~O~k',cmOk,bfDefault));
          Insert(C);

          R.Assign(25,9,35,11);
          C:=New(PButton,Init(R,'~Z~ru쮑t',cmCancel,bfNormal));
          Insert(C);

          SelectNext(False);
       end;

   Application^.ExecuteDialog(D,Nil);
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure ChangeColors;
Var BD : PColorDialog;
Begin
BD:=New(PColorDialog,Init('',
          ColorGroup('Nab죆ka',MenuColorItems(Nil),
          ColorGroup('Dialogy',DialogColorItems(dpGrayDialog,Nil),
          ColorGroup('Okna',WindowColorItems(wpBlueWindow,Nil),
          ColorGroup('N쟰ov늕a',  ColorItem('Pasivn� r쟭',            128,
                                  ColorItem('Pasivn� n쟺ev',          129,
                                  ColorItem('Ikona r쟭u',             130,
                                  ColorItem('Str쟮ka rol. li쮝y    ', 131,
                                  ColorItem('Rolovac� li쮝a',         132,
                                  ColorItem('Normaln� text',          133,
                                  ColorItem('Vybran� text',           134,
                                  Nil))))))),
          ColorGroup('Panely',    ColorItem('Panel normaln�',         144,
                                  ColorItem('Panel vybran�',          145,
                                  ColorItem('Ikona Ramu',             146,
                                  ColorItem('Stranka rol.li쮝y',      147,
                                  ColorItem('Rolovac� li쮝a',         148,
                                  ColorItem('Popis',                  149,
                                  ColorItem('Soub. v aktiv. panelu',  136,
                                  ColorItem('Soub. v neakt. panelu',  137,
                                  ColorItem('Kurzor',                 138,
                                  ColorItem('Ozna놽n� adres젵e',      141,
                                  ColorItem('Ozna놽n� soubory',       139,
                                  ColorItem('D늢죅� 뇿ra',            140,
                                  ColorItem('Kurzor na vyb. soub.',   142,
                                  ColorItem('Kurzor na vyb. adres.',  143,
                                  Nil)))))))))))))),
          ColorGroup('Editor',    ColorItem('R쟭',                    157,
                                  ColorItem('Ikona r쟭u',             158,
                                  ColorItem('Str쟮ka rol. li쮝y',     159,
                                  ColorItem('Rolovac� li쮝a',         160,
                                  Nil)))),
          ColorGroup('Prohl죷e�', ColorItem('R쟭',                    164,
                                  ColorItem('Ikona r쟭u',             166,
                                  ColorItem('Str쟮ka rol. li쮝y',     167,
                                  ColorItem('Rolovac� li쮝a',         168,
                                  ColorItem('Norm쟫n� text',          169,
                                  ColorItem('Symboly',                172,
                                  ColorItem('Cislice a retezce',      170,
                                  ColorItem('Komentare',              171,
                                  Nil)))))))),
          ColorGroup('Pækazov� 찤dka',
                                  ColorItem('Text',                   152,
                                  ColorItem('쌻pka',                  155,
                                  Nil)),
          nil))))))))));
Application^.ExecuteDialog(BD,Application^.GetPalette);
Application^.Redraw;
Configuration.Colors := PString(Application^.GetPalette)^;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetPalette;
Var D : PPaletteDialog;
    Colors : TColors;

Procedure GetColors(var Colors  : tcolors);
Var C : Word;
    R, G, B : Byte;
begin
 For C:=0 To 15 Do Begin
                     Base.GetPal(C,r,g,b);
                     Colors[C].r:=r;
                     Colors[C].g:=g;
                     Colors[C].b:=b;
                    End;
end;
Var Data : TPaleteRec;
Begin
 GetColors(Colors);
 D := New(PPaletteDialog,Init(Colors));
 Data.Colors := Colors;
 If Not Configuration.Palette.BackPalette Then Data.BackPalette := 0
  Else Data.BackPalette := 1;
 Application^.ExecuteDialog(D,@Data);
 Configuration.Palette.Colors := Data.Colors;
 Configuration.Palette.Change := True;
 If Data.BackPalette = 0 Then Configuration.Palette.BackPalette := False
   Else Configuration.Palette.BackPalette := True;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
function CreateModeDialog(var _Data : TMode; _SetData : Boolean): Word;
var
  D    : PDialog;
  C    : PView;
  R    : TRect;
  _DataPtr : PMode;
begin
  R.Assign(29,6,53,16);
  D:=New(PDialog,Init(R,'Obrazovy mod'));
  with D^ do
       begin
          R.Assign(1,7,11,9);
          C:=New(PButton,Init(R,'~O~k',cmOk,bfNormal));
          Insert(C);

          R.Assign(12,7,22,9);
          C:=New(PButton,Init(R,'~Z~rusit',cmCancel,bfNormal));
          Insert(C);

          R.Assign(1,1,23,4);
          C:=New(PRadioButtons,Init(R,
               NewSItem('Barevn�',
               NewSItem('�ernob죐�',
               NewSItem('Monochromatick�',
               nil)))));
          Insert(C);

          R.Assign(3,5,21,6);
          C:=New(PCheckBoxes,Init(R,
               NewSItem('43/50 찤dek',
               nil)));
          Insert(C);

          SelectNext(False);
       end;

   _DataPtr:=@_Data;
   if not _SetData then FillChar(_Data,SizeOf(_Data),0);
   CreateModeDialog:=Application^.ExecuteDialog(D,_DataPtr);
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetVideoMode;
Const CColor = $01;
      CBlackWhite = $02;
      CMonochrome = $04;
Var Mode : TMode;
    M    : Word;
Begin
If CreateModeDialog(Mode,False) <> cmOk Then Exit;
Case Mode.Data1 Of
 0 : M:= smCO80;
 1 : M:= smBW80;
 2 : M:= smMono;
Else M := smCO80;
End;
If Mode.Data2=1 Then M:=M or smFont8x8;
Application^.SetScreenMode(M);
Asm
mov ah,10h
mov al,3
xor bl,bl
int 10h
End;
Application^.Redraw;
Writeln(Mode.Data1);
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
constructor TClickTester.Init(var Bounds: TRect; AText: String);
begin
  inherited Init(Bounds, AText);
  Clicked := False;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
function TClickTester.GetPalette: PPalette;
const
  P: String[Length(CClickTester)] = CClickTester;
begin
  GetPalette := @P;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure TClickTester.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evMouseDown) then
  begin
    if Event.Double then
    begin
      Clicked := not Clicked;
      DrawView;
    end;
    ClearEvent(Event);
  end;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure TClickTester.Draw;
var
  B: TDrawBuffer;
  C: Byte;
begin
  if Clicked then C := GetColor(2)
  else C := GetColor(1);
  MoveChar(B, ' ', C, Size.X);
  MoveStr(B, Text^, C);
  WriteLine(0, 0, Size.X, 1, B);
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetMouse;
var
  R: TRect;
  D: PDialog;
  S: PScrollBar;
  Data : Record
          MouseReverse : Word;
         End;
begin
  R.Assign(0, 0, 34, 12);
  D:=New(PDialog,Init(R, 'Nastaven� my쮑'));
   With D^ Do Begin
               Options := Options or ofCentered;
               HelpCtx := hcMouse;

               R.Assign(3, 4, 30, 5);
               S := New(PScrollBar, Init(R));
               S^.SetParams(1, 1, 20, 20, 1);
               S^.Options := S^.Options or ofSelectable;
               S^.SetValue(DoubleDelay);
               Insert(S);

               R.Assign(2, 2, 21, 3);
               Insert(New(PLabel, Init(R, '~D~vojit� kliknut�', S)));

               R.Assign(3, 3, 30, 4);
               Insert(New(PClickTester, Init(R, 'Pomal�    St쯥dn�    Rychl�')));

               R.Assign(3, 6, 30, 7);
               Insert(New(PCheckBoxes, Init(R,
               NewSItem('~O~to놽n� tla눀tka my쮑', nil))));

               R.Assign(9, 9, 19, 11);
               Insert(New(PButton, Init(R, '~O~k', cmOk, bfDefault)));
               Inc(R.A.X, 12); Inc(R.B.X, 12);
               Insert(New(PButton, Init(R, '~Z~ru쮑t', cmCancel, bfNormal)));

               SelectNext(False);
               End;
Data.MouseReverse:=0;
If Configuration.Mouse.Reverse Then Data.MouseReverse := 1 Else Data.MouseReverse:=0;
Application^.ExecuteDialog(D,@Data);
If Data.MouseReverse=1 Then Configuration.Mouse.Reverse := True
  Else Configuration.Mouse.Reverse := False;
MouseReverse := Configuration.Mouse.Reverse;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
End.