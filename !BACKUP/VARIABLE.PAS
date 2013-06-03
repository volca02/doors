Unit Variable;
Interface
Uses Objects;
Const Starting : Boolean = True;

Const
      KbCtrlLom             = $2B1C;    KbCtrlRightBracket    = $1B1D;
      KbCtrlLeftBracket     = $1A1B;    KbCtrlR               = $1312;
      KbCtrlO               = $180F;    kbGrayTimes           = $372A;
      KbCtrlU               = $1615;    KbCtrlE               = $1205;
      KbCtrlC               = $2E03;    KbCtrlA               = $1E01;

Const
      HelpFileName          : String[12] = 'DRS.HLP';
      PaletteFileName       : String[12] = 'DRS.PAL';
      ConfigurationFileName : String[12] = 'DRS.CFG';
      SwapCfgFileName       : String[12] = '$DRS$.CFG';
      HistoryFileName       : String[12] = 'DRS.HIS';
      CDNamesFile           : String[12] = 'DRS.CD';

      HeapSize              = 150 * (1024 div 16);

      Version         = 'Verze 1.02 beta';

      CPanelColor     = #$1B#$1B#$B0#$1E#$1B#$1A#$0E#$0A;
      CPWindowColor   = #$1B#$B0#$1C#$1B#$1B#$17#$1B#$1B;
      CCommandLine    = #$07#$07#$70#$03;
      CEditorColor    = #$1B#$1F#$1F#$1F#$1F#$1E#$1F#$1F;

Const
      {Prikazy}
      CmNs                 = 100;
      CmSystemInfo         = 101;
      CmAbout              = 102;
      CmColors             = 103;
      CmVideoMode          = 104;
      CmFileFind           = 105;
      CmMouse              = 106;
      CmAdvanced           = 107;
      CmFileCopy           = 108;
      CmAntivir            = 109;
      CmCalendar           = 110;
      CmASCIITable         = 111;
      CmCalc               = 112;
      CmDrivers            = 113;
      CmView               = 114;
      CmUserList           = 115;
      CmCalcButton         = 116;
      CmSend               = 117;
      CmDrawLFN            = 118;
      CmThanks             = 119;
      CmMkDir              = 120;
      CmConfigSystem       = 121;
      CmChooseDriveLeft    = 122;
      CmChooseDriveRight   = 123;
      CmDiskLabel          = 124;
      CmReverseLeft        = 125;
      CmReverseRight       = 126;
      CmReReadLeft         = 127;
      CmReReadRight        = 128;
      CmShowHidePanels     = 129;
      cmSelectFile         = 131;
      cmSelectGroup        = 132;
      cmUnSelectGroup      = 133;
      cmInversSelect       = 134;
      cmCompareDirectories = 135;
      cmSwapPanels         = 136;
      cmSetScreenSaver     = 137;
      cmTestSaver          = 138;
      cmDiskPark           = 139;
      cmSaveConfiguration  = 140;
      cmDelete             = 141;
      CmCharacterFocused   = 142;
      cmUsedCommands	   = 143;
      cmLeftSortByName     = 144;
      cmLeftSortByExtension = 145;
      cmLeftSortByTime     = 146;
      cmLeftSortBySize     = 147;
      cmLeftUnSorted       = 148;
      cmRightSortByName     = 149;
      cmRightSortByExtension = 150;
      cmRightSortByTime     = 151;
      cmRightSortBySize     = 152;
      cmRightUnSorted       = 153;
      cmLogout              = 154;
      CmEdit                = 155;
      CmConfirmation        = 156;
      CmSetAttr             = 157;
      cmQuickLast           = 158;
      cmQuickNext           = 159;
      cmPlay                = 160;
      cmLast                = 161;
      cmNext                = 162;
      cmStop                = 163;
      cmPause               = 164;
      cmOpen                = 165;
      cmCDPlayer            = 166;
      CmEditCDName          = 167;
      CmTSRPrograms         = 168;
      cmPalette             = 169;
      CmDefaultColors       = 170;

      { Historie prikazu }
      HiSelectGroup        = 1;
      HiMkDir              = 2;
      HiCommandLine        = 3;
      HiSendMessage        = 4;
      HiSearchText         = 5;
      HiSearchTextHex      = 6;
      HiSearchDirectory    = 7;
      HiSearchMask         = 8;
      HiSongName           = 8;
      HiCDDiskName         = 9;

Type
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
  Tcolor  = record
              r,g,b  : byte;
            end;
  PColors = ^TColors;
  TColors = array [0..15] of TColor;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
    PVideoRam = ^TVideoRam;
    TVideoRam = Array[1..50,1..80] Of Word;

    PFileRec = ^TFileRec;
    TFileRec = Record
                 Name : String[12];
                 Attr : Byte;
                 Time : Longint;
                 Size : Longint;
                 Selected : Boolean;
               End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
   TPaletteCfg    = Record
                     BackPalette : Boolean;
                     Colors      : TColors;
                     Change      : Boolean;
                    End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
   TScreenSaver   = Record
                     Typ      : Byte;
                     Mouse    : Boolean;
                     Interval : Byte;
                    End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
   TSystem        = Record
                      ShowClock       : Boolean;
                      ShowCzechType   : Boolean;
                      ShowLongNames   : Boolean;
                      VerifyWrite     : Boolean;
                      ClearReadOnly   : Boolean;
                      ShowHiddenFiles : Boolean;
                      HistSize        : Byte;
                      Resize          : Boolean;
                    End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
   PPanelData     = ^TPanelData;
   TPanelData     = Record
                      AktualDirectory : String [100];
                      Visible         : Boolean;
                      Selected        : Boolean;
                      SortType        : Byte;
                      Origin          : TPoint;
                      Size            : TPoint;
                    End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
   TMouse         = Record
                     Reverse          : Boolean;
                    End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
   TConfiguration = Record
                      ScreenSaver : TScreenSaver;
                      System      : TSystem;
                      LeftPanel   : TPanelData;
                      RightPanel  : TPanelData;
                      Mouse       : TMouse;
                      Palette     : TPaletteCfg;
                      Colors      : String;
                   End;
Var VideoPamet    : TVideoRam;
    Configuration : TConfiguration;
    OldColors     : TColors;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
const
  DefaultColors : TColors=
{00}    ((R:0;g:0;b:00),
{01}     (R:0;g:0;b:168),
{02}     (R:0;g:168;b:0),
{03}     (R:0;g:168;b:168),
{04}     (R:168;g:0;b:0),
{05}     (R:168;g:0;b:168),
{06}     (R:168;g:168;b:0),
{07}     (R:168;g:168;b:168),
{08}     (R:0;g:0;b:84),
{09}     (R:0;g:0;b:252),
{10}     (R:0;g:168;b:84),
{11}     (R:0;g:168;b:252),
{12}     (R:168;g:0;b:84),
{13}     (R:168;g:0;b:252),
{14}     (R:168;g:168;b:84),
{15}     (R:168;g:168;b:252));
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Implementation
Uses Base;
Var  F  : File;
     Error : Boolean;
     RunFirst : Word;
Begin
  FillChar(Configuration,SizeOf(Configuration),0);
  Asm
    mov Error,0
    mov ax,9900h
    Int 2fh
    cmp bx,'DO'
    Jne @Er
    cmp dx,'OR'
    Jne @Er
    Jmp @AsmEnd
    @Er:
     mov Error,1
    @AsmEnd:
     mov RunFirst,Ax
  end;
If Starting Then
If (Not Error) And (RunFirst=1) Then
      Begin
         Assign(F,GetStartupPath + SwapCfgFileName);
                   {$I-}
                   Reset(F,1);
                   If IoResult = 0 Then Begin
                                         If FileSize(F)=SizeOf(Configuration) Then
                                           BlockRead(F,Configuration,SizeOf(Configuration));
                                         Close(F);
                                        End;
                   Erase(F);
                   {$I+}
      End
Else  Begin
           Assign(F,GetStartupPath + ConfigurationFileName);
                   {$I-}
                   Reset(F,1);
                   If IoResult = 0 Then Begin
                                         If FileSize(F)=SizeOf(Configuration) Then
                                           BlockRead(F,Configuration,SizeOf(Configuration));
                                         Close(F);
                                        End;
                   {$I+}
                 End;

Starting := False;
End.