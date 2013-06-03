{********************************************************}
{**          Zdrojov˜ k¢d pro Status Line              **}
{********************************************************}
{**     Copyright    DOORS MAKER'S                     **}
{**     Generoval    Petrik David                      **}
{********************************************************}
{**                  T V G e n                         **}
{********************************************************}

{************  Generov no v syntaxi TP 7.0  *************}

procedure TDoors.InitStatusLine;
var R : TRect;
begin
  GetExtent(R);
  R.A.Y:=R.B.Y-1;
  StatusLine:=New(PStatusLine,Init(R,
    NewStatusDef(0,$FFFA,
       NewStatusKey('~F3~ Viz',kbNoKey,cmView,
       NewStatusKey('~F4~ Edit',kbNoKey,cmEdit,
       NewStatusKey('~F5~ Kopie',kbF5,cmNs,
       NewStatusKey('~F6~ P©ejm',kbF6,cmNs,
       NewStatusKey('~F7~ MkDir',kbNoKey,cmMkdir,
       NewStatusKey('~F8~ V˜maz',kbNoKey,cmDelete,
       NewStatusKey('~F9~ P©¡jem',kbF9,cmNs,
       NewStatusKey('~F10~ Menu',kbF10,cmMenu,
   NIL)))))))),
    NewStatusDef($FFFD,$FFFF,
       NewStatusKey('~F2~ Ulo‘',KbF2,cmSave,
       NewStatusKey('~F6~ Nahradit',kbF6,cmReplace,
       NewStatusKey('~F7~ Naj¡t',kbF7,cmFind,
   NIL))),
    NewStatusDef($FFFB,$FFFD,
       NewStatusKey('~F4~ Zobrazovac¡ m¢d',kbF4,cmChangeMode,
       NewStatusKey('~F6~ Zv˜raz¤ov n¡',kbF6,cmColorMode,
       NewStatusKey('~F8~ Zalamov n¡',kbF8,cmLineMode,
       NewStatusKey('~F5~ Adresa',kbF5,cmChangeAddres,
   NIL)))),
   NIL)))));
end;

{ ****** Konec souboru vytvo©en‚ho programem TVGen 2.01 ****** }
