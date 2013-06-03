{********************************************************}
{**          Zdrojov˜ k¢d pro Menu Bar                 **}
{********************************************************}
{**     Copyright    DOORS MAKER'S                     **}
{**     Generoval    Petrik David                      **}
{********************************************************}
{**                  T V G e n                         **}
{********************************************************}

{************  Generov no v syntaxi TP 7.0  *************}

procedure TDoors.InitMenuBar;
var R : TRect;
begin
  GetExtent(R);
  R.B.Y:=R.A.Y+1;
  MenuBar:=New(PMenuBar,Init(R,NewMenu(
   NewSubMenu('~L~ev˜',hcLeft,NewMenu(
      NewItem('V~y~pnout/Zapnout','Ctrl-F1',kbCtrlF1,cmReverseLeft,hcShowHidePanel,
      NewLine(
      NewItem('Set©¡dˆn¡ podle ~j~m‚na','',kbNoKey,cmLeftSortByName,hcFileSort,
      NewItem('Set©¡dˆn¡ podle p©¡p~o~ny','',kbNoKey,cmLeftSortByExtension,hcFileSort,
      NewItem('Set©¡dˆn¡ podle ‡~a~su','',kbNoKey,cmLeftSortByTime,hcFileSort,
      NewItem('Set©¡dˆn¡ podle v~e~likosti','',kbNoKey,cmLeftSortBySize,hcFileSort,
      NewItem('~N~eset©¡dˆno','',kbNoKey,cmLeftUnsorted,hcFileSort,
      NewLine(
      NewItem('~V~˜bˆr disku','Alt-F1',kbAltF1,cmChooseDriveLeft,hcChooseDrive,
      NewItem('~Z~novu na‡ten¡ disku','Ctrl-R',kbNoKey,cmReReadLeft,hcFileSort,
  NIL))))))))))),
   NewSubMenu('S~o~ubor',hcFileMenu,NewMenu(
      NewItem('~P~rohl¡‘en¡','F3',kbF3,cmView,hcFileView,
      NewItem('~E~ditov n¡','F4',kbF4,cmEdit,hcFileEdit,
      NewItem('~K~op¡rov n¡','F5',kbF5,cmCopyFile,hcFileCopy,
      NewItem('P©e~j~menov n¡','F6',kbF6,cmMoveFile,hcFileRename,
      NewItem('~V~ytvo©en¡ adres ©e','F7',kbF7,cmMkDir,hcMkdir,
      NewItem('Vy~m~az n¡','F8',kbF8,cmDelete,hcFileDelete,
      NewItem('P©¡jem','F9',kbF9,cmNs,hcFileReceive,
      NewItem('~O~bnoven¡','',kbNoKey,cmNs,hcFileUndelete,
      NewItem('Porovn n¡','',kbNoKey,cmNs,hcFileCompare,
      NewItem('›ifrov n¡','',kbNoKey,cmNs,hcFileCrypt,
      NewItem('~A~tributy','Alt-A',kbCtrlA,cmSetAttr,hcFileAttribs,
      NewItem('P©evod n rodn¡ch znak–','',kbNoKey,cmNs,hcFileConvert,
      NewItem('~Z~ji¨tov n¡ velikosti','Alt-F6',kbAltF6,cmGetFileSize,hcFileGetSize,
      NewItem('~I~nformace o souboru','',kbNoKey,cmFileInformation,hcFileInformation,
      NewLine(
      NewItem('O p~r~ogramu','',kbNoKey,cmAbout,hcAbout,
      NewLine(
      NewItem('Kone~c~','Alt-X',kbAltX,cmQuit,hcFileExit,
  NIL))))))))))))))))))),
   NewSubMenu('~D~isk',hcDiskMenu,NewMenu(
      NewItem('~E~ditace','',kbNoKey,cmNs,hcDiskEdit,
      NewItem('~M~apa','',kbNoKey,cmNs,hcDiskMap,
      NewItem('~J~meno','',kbNoKey,cmDiskLabel,hcDiskName,
      NewItem('~I~nformace','',kbNoKey,cmNs,hcDiskInfo,
      NewItem('P~a~rkov n¡ disk–','',kbNoKey,cmDiskPark,hcDiskPark,
      NewLine(
      NewItem('~F~orm tovan¡ disket','',kbNoKey,cmNs,hcDiskFormat,
      NewItem('~K~op¡rov n¡ disket','',kbNoKey,cmNs,hcDiskCopy,
      NewItem('~P~orovn v n¡ disket','',kbNoKey,cmNs,hcDiskCompare,
  NIL)))))))))),
   NewSubMenu('~S~¡Ÿ',hcNetworkMenu,NewMenu(
      NewItem('~P~©ihl ¨en¡ u‘ivatel‚','',kbNoKey,cmUserList,hcUserList,
      NewItem('~O~dhl ¨en¡ od s¡tˆ','',kbNoKey,cmLogout,hcLogout,
      NewItem('~I~nfromace o servru','',kbNoKey,cmNs,hcNoContext,
      NewItem('~M~apovan¡ jednotek','',kbNoKey,cmNs,hcNoContext,
  NIL))))),
   NewSubMenu('Po~v~ely',hcPanelsMenu,NewMenu(
      NewItem('Z ~m~ˆna p~a~nel–','Ctrl-U',kbCtrlU,cmSwapPanels,hcNoContext,
      NewItem('~U~kryt¡/Zobrazen¡ panel£','Ctrl-O',kbCtrlO,cmShowHidePanels,hcNoContext,
      NewItem('~V~elikost/Um¡stˆn¡ panel£','Ctrl-F5',kbCtrlF5,cmResize,hcNoContext,
      NewLine(
      NewItem('~O~zna‡en¡ souboru','Ins',kbIns,cmSelectFile,hcNoContext,
      NewItem('Oz~n~a‡en¡ skupiny','›ediv‚ "+"',kbGrayPlus,cmSelectGroup,hcNoContext,
      NewItem('~Z~ru¨en¡ ozna‡en¡ skupiny','›ediv‚ "-"',kbGrayMinus,cmUnSelectGroup,hcNoContext,
      NewItem('~I~nverze ozna‡en¡','›ediv‚ "*"',kbGrayTimes,cmInversSelect,hcNoContext,
      NewLine(
      NewItem('Po~r~ovn n¡ adres ©–','Ctrl-C',kbCtrlC,cmCompareDirectories,hcCompareDirectories,
  NIL))))))))))),
   NewSubMenu('~N~ stroje',hcToolsMenu,NewMenu(
      NewItem('~K~alend ©','Alt-C',kbAltC,cmCalendar,hcToolsCalendar,
      NewItem('K~a~lkula‡ka','Alt-Q',kbAltQ,cmCalc,hcToolsCalc,
      NewItem('ASCII tabulka','Alt-A',kbAltA,cmASCIITable,hcToolsASCII,
      NewItem('~I~nformace o systemu','Alt-I',kbAltI,cmSystemInfo,hcToolsInfo,
      NewItem('Nale~z~en¡ souboru','Alt-F7',kbAltF7,cmFileFind,hcToolsFindFile,
      NewItem('~N~adbyte‡n‚ kopie','',kbNoKey,cmNs,hcToolsDupli,
      NewItem('~M~askov‚ p©¡kazy','',kbNoKey,cmNs,hcToolsMask,
      NewItem('~D~atum a ‡as','',kbNoKey,cmNs,hcToolsDateTime,
      NewItem('~O~vladace zarizeni','',kbNoKey,cmDrivers,hcDrivers,
      NewItem('R~e~zident¡ programy','Alt-F5',kbAltF5,cmTSRPrograms,hcTSRPrograms,
      NewItem('~R~ezidentni antiviry','',kbNoKey,cmAntivir,hcAntivirs,
      NewItem('~P~ou‘it‚ p©¡kazy','Alt-F8',kbAltF8,cmUsedCommands,hcUsedCommands,
      NewLine(
      NewItem('P©ehr va‡ ~C~D disk–','',kbNoKey,cmCdPlayer,hcCdPlayer,
  NIL))))))))))))))),
   NewSubMenu('Nas~t~aven¡',hcConfigurationMenu,NewMenu(
   NewSubMenu('Konfigurace',hcNoContext,NewMenu(
      NewItem('~P~o spu¨tˆn¡','',kbNoKey,cmNs,hcNoContext,
      NewItem('Potvrzen¡','',kbNoKey,cmConfirmation,hcConfirmation,
      NewItem('€e¨tina','',kbNoKey,cmNs,hcNoContext,
      NewLine(
      NewItem('›ifrovan¡','',kbNoKey,cmNs,hcNoContext,
      NewItem('›~e~t©i‡','',kbNoKey,cmSetScreenSaver,hcNoContext,
      NewItem('S¡Ÿ','',kbNoKey,cmNs,hcNoContext,
      NewLine(
      NewItem('E~d~itory/prohl¡‘e‡e','',kbNoKey,cmNs,hcNoContext,
  NIL)))))))))),
      NewItem('~S~yst‚m','',kbNoKey,cmConfigSystem,hcConfigSystem,
      NewItem('~M~y¨','',kbNoKey,cmMouse,hcMouse,
      NewItem('›~e~t©i‡','',kbNoKey,cmSetScreenSaver,hcSetScreenSaver,
      NewLine(
      NewItem('~K~l vesnice','',kbNoKey,cmNs,hcKeyboard,
      NewItem('~O~brazov˜ m¢d','Alt-F9',kbAltF9,cmNs,hcScreenMode,
      NewLine(
      NewItem('~B~arvy','',kbNoKey,cmColors,hcColor,
      NewItem('Pa~l~eta','',kbNoKey,cmPalette,hcPalette,
      NewLine(
      NewItem('~U~lo‘en¡ nastaven¡','Shift-F9',kbShiftF9,cmSaveConfiguration,hcSaveOption,
  NIL))))))))))))),
   NewSubMenu('~P~rav˜',hcRight,NewMenu(
      NewItem('V~y~pnout/Zapnout','Ctrl-F2',kbCtrlF2,cmReverseRight,hcShowHidePanel,
      NewLine(
      NewItem('Set©¡dˆn¡ podle ~j~m‚na','',kbNoKey,cmRightSortByName,hcFileSort,
      NewItem('Set©¡dˆn¡ podle p©¡p~o~ny','',kbNoKey,cmRightSortByExtension,hcFileSort,
      NewItem('Set©¡dˆn¡ podle ‡~a~su','',kbNoKey,cmRightSortByTime,hcFileSort,
      NewItem('Set©¡dˆn¡ podle v~e~likosti','',kbNoKey,cmRightSortBySize,hcFileSort,
      NewItem('~N~eset©¡dˆno','',kbNoKey,cmRightUnsorted,hcFileSort,
      NewLine(
      NewItem('~V~˜bˆr disku','Alt-F2',kbAltF2,cmChooseDriveRight,hcChooseDrive,
      NewItem('~Z~novu na‡ten¡ disku','Ctrl-R',kbNoKey,cmReReadRight,hcNoContext,
  NIL))))))))))),
  NIL)))))))))));
end;

{ ****** Konec souboru vytvo©en‚ho programem TVGen 2.01 ****** }
