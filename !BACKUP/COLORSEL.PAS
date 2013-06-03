unit ColorSel;

{$O+,F+,X+,I-,S-}

interface

uses Objects, Drivers, Views, Dialogs, Variable;

const
  cmColorForegroundChanged = 71;
  cmColorBackgroundChanged = 72;
  cmColorSet               = 73;
  cmNewColorItem           = 74;
  cmNewColorIndex          = 75;
  cmSaveColorIndex         = 76;

type

  { TColorItem }

  PColorItem = ^TColorItem;
  TColorItem = record
    Name: PString;
    Index: Byte;
    Next: PColorItem;
  end;

  { TColorGroup }

  PColorGroup = ^TColorGroup;
  TColorGroup = record
    Name:  PString;
    Index: Byte;
    Items: PColorItem;
    Next:  PColorGroup;
  end;

  { TColorIndexes }

  PColorIndex = ^TColorIndex;
  TColorIndex = record
    GroupIndex: byte;
    ColorSize: byte;
    ColorIndex: array[0..255] of byte;
  end;

  { TColorSelector }

  TColorSel = (csBackground, csForeground);

  PColorSelector = ^TColorSelector;
  TColorSelector = object(TView)
    Color: Byte;
    SelType: TColorSel;
    constructor Init(var Bounds: TRect; ASelType: TColorSel);
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
  end;

  { TMonoSelector }

  PMonoSelector = ^TMonoSelector;
  TMonoSelector = object(TCluster)
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function Mark(Item: Integer): Boolean; virtual;
    procedure NewColor;
    procedure Press(Item: Integer); virtual;
    procedure MovedTo(Item: Integer); virtual;
  end;

  { TColorDisplay }

  PColorDisplay = ^TColorDisplay;
  TColorDisplay = object(TView)
    Color: ^Byte;
    Text: PString;
    constructor Init(var Bounds: TRect; AText: PString);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SetColor(var AColor: Byte); virtual;
    procedure Store(var S: TStream);
  end;

  { TColorGroupList }

  PColorGroupList = ^TColorGroupList;
  TColorGroupList = object(TListViewer)
    Groups: PColorGroup;
    constructor Init(var Bounds: TRect; AScrollBar: PScrollBar;
      AGroups: PColorGroup);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure FocusItem(Item: Integer); virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    procedure SetGroupIndex(GroupNum, ItemNum: Byte);
    function GetGroup(GroupNum: Byte): PColorGroup;
    function GetGroupIndex(GroupNum: Byte): Byte;
    function GetNumGroups: byte;
  end;

  { TColorItemList }

  PColorItemList = ^TColorItemList;
  TColorItemList = object(TListViewer)
    Items: PColorItem;
    constructor Init(var Bounds: TRect; AScrollBar: PScrollBar;
      AItems: PColorItem);
    procedure FocusItem(Item: Integer); virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  { TColorDialog }

  PColorDialog = ^TColorDialog;
  TColorDialog = object(TDialog)
    GroupIndex: byte;
    Display: PColorDisplay;
    Groups: PColorGroupList;
    ForLabel: PLabel;
    ForSel: PColorSelector;
    BakLabel: PLabel;
    BakSel: PColorSelector;
    MonoLabel: PLabel;
    MonoSel: PMonoSelector;
    Pal: TPalette;
    constructor Init(APalette: TPalette; AGroups: PColorGroup);
    constructor Load(var S: TStream);
    function DataSize: Word; virtual;
    procedure GetData(var Rec); virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream);
    procedure GetIndexes(var Colors: PColorIndex);
    procedure SetIndexes(var Colors: PColorIndex);
  end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  TPaleteRec     = Record
                    Colors      : TColors;
                    BackPalette : Word;
                   End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  PPaletteDialog = ^TPaletteDialog;
  TPaletteDialog = object(TDialog)
    Red        : PScrollBar;
    Green      : PScrollBar;
    Blue       : PScrollBar;
    Selector   : PColorSelector;
    Colors     : TColors;
    Color      : Byte;
    Check      : PCheckBoxes;
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    constructor Init(AColors : TColors);
    procedure HandleEvent(var Event: TEvent); virtual;
  end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
const
  ColorIndexes: PColorIndex = nil;


procedure StoreIndexes(var S: TStream);
procedure LoadIndexes(var S: TStream);


function ColorItem(const Name: String; Index: Byte;
  Next: PColorItem): PColorItem;
function ColorGroup(const Name: String; Items: PColorItem;
  Next: PColorGroup): PColorGroup;


function DesktopColorItems(const Next: PColorItem): PColorItem;
function MenuColorItems(const Next: PColorItem): PColorItem;
function DialogColorItems(Palette: Word; const Next: PColorItem): PColorItem;
function WindowColorItems(Palette: Word; const Next: PColorItem): PColorItem;

{ ColorSel registration procedure }

procedure RegisterColorSel;

{ Stream registration records }

const
  RColorSelector: TStreamRec = (
     ObjType: 21;
     VmtLink: Ofs(TypeOf(TColorSelector)^);
     Load:    @TColorSelector.Load;
     Store:   @TColorSelector.Store
  );

const
  RMonoSelector: TStreamRec = (
     ObjType: 22;
     VmtLink: Ofs(TypeOf(TMonoSelector)^);
     Load:    @TMonoSelector.Load;
     Store:   @TMonoSelector.Store
  );

const
  RColorDisplay: TStreamRec = (
     ObjType: 23;
     VmtLink: Ofs(TypeOf(TColorDisplay)^);
     Load:    @TColorDisplay.Load;
     Store:   @TColorDisplay.Store
  );

const
  RColorGroupList: TStreamRec = (
     ObjType: 24;
     VmtLink: Ofs(TypeOf(TColorGroupList)^);
     Load:    @TColorGroupList.Load;
     Store:   @TColorGroupList.Store
  );

const
  RColorItemList: TStreamRec = (
     ObjType: 25;
     VmtLink: Ofs(TypeOf(TColorItemList)^);
     Load:    @TColorItemList.Load;
     Store:   @TColorItemList.Store
  );

const
  RColorDialog: TStreamRec = (
     ObjType: 26;
     VmtLink: Ofs(TypeOf(TColorDialog)^);
     Load:    @TColorDialog.Load;
     Store:   @TColorDialog.Store
  );

implementation

Uses Base, App;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
constructor TColorSelector.Init(var Bounds: TRect; ASelType: TColorSel);
begin
  TView.Init(Bounds);
  Options := Options or (ofSelectable + ofFirstClick + ofFramed);
  EventMask := EventMask or evBroadcast;
  SelType := ASelType;
  Color := 0;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
constructor TColorSelector.Load(var S: TStream);
begin
  TView.Load(S);
  S.Read(Color, SizeOf(Byte) + SizeOf(TColorSel));
end;

procedure TColorSelector.Draw;
var
  B: TDrawBuffer;
  C, I, J: Integer;
begin
  MoveChar(B, ' ', $70, Size.X);
  for I := 0 to Size.Y do
  begin
    if I < 4 then
      for J := 0 to 3 do
      begin
        C := I * 4 + J;
        MoveChar(B[ J*3 ], #219, C, 3);
        if C = Byte(Color) then
        begin
          WordRec(B[ J*3+1 ]).Lo := 8;
          if C = 0 then WordRec(B[ J*3+1 ]).Hi := $70;
        end;
      end;
    WriteLine(0, I, Size.X, 1, B);
  end;
end;

procedure TColorSelector.HandleEvent(var Event: TEvent);
const
  Width = 4;
var
  MaxCol: Byte;
  Mouse: TPoint;
  OldColor: Byte;

procedure ColorChanged;
var
  Msg: Integer;
begin
  if SelType = csForeground then
    Msg := cmColorForegroundChanged else
    Msg := cmColorBackgroundChanged;
  Message(Owner, evBroadcast, Msg, Pointer(Color));
end;

begin
  TView.HandleEvent(Event);
  case Event.What of
    evMouseDown:
      begin
        OldColor := Color;
        repeat
          if MouseInView(Event.Where) then
          begin
            MakeLocal(Event.Where, Mouse);
            Color := Mouse.Y * 4 + Mouse.X div 3;
          end
          else
            Color := OldColor;
          ColorChanged;
          DrawView;
        until not MouseEvent(Event, evMouseMove);
      end;
    evKeyDown:
      begin
        MaxCol := 15;
        case CtrlToArrow(Event.KeyCode) of
          kbLeft:
            if Color > 0 then
              Dec(Color) else
              Color := MaxCol;
          kbRight:
            if Color < MaxCol then
              Inc(Color) else
              Color := 0;
          kbUp:
            if Color > Width - 1 then
              Dec(Color, Width) else
              if Color = 0 then
                Color := MaxCol else
                Inc(Color, MaxCol - Width);
          kbDown:
            if Color < MaxCol - (Width - 1) then
              Inc(Color, Width) else
              if Color = MaxCol then
                Color := 0 else
                Dec(Color, MaxCol - Width);
        else
          Exit;
        end;
      end;
    evBroadcast:
      if Event.Command = cmColorSet then
      begin
        if SelType = csBackground then
          Color := Event.InfoByte shr 4 else
          Color := Event.InfoByte and $0F;
        DrawView;
        Exit;
      end else Exit;
  else
    Exit;
  end;
  DrawView;
  ColorChanged;
  ClearEvent(Event);
end;

procedure TColorSelector.Store(var S: TStream);
begin
  TView.Store(S);
  S.Write(Color, SizeOf(Byte) + SizeOf(TColorSel));
end;

{ TMonoSelector }

const
  MonoColors: array[0..4] of Byte = ($07, $0F, $01, $70, $09);

constructor TMonoSelector.Init(var Bounds: TRect);
begin
  TCluster.Init(Bounds,
    NewSItem('Normal',
    NewSItem('Highlight',
    NewSItem('Underline',
    NewSItem('Inverse', nil)))));
  EventMask := EventMask or evBroadcast;
end;

procedure TMonoSelector.Draw;
const
  Button = ' ( ) ';
begin
  DrawBox(Button, #7);
end;

procedure TMonoSelector.HandleEvent(var Event: TEvent);
begin
  TCluster.HandleEvent(Event);
  if (Event.What = evBroadcast) and (Event.Command = cmColorSet) then
  begin
    Value := Event.InfoByte;
    DrawView;
  end;
end;

function TMonoSelector.Mark(Item: Integer): Boolean;
begin
  Mark := MonoColors[Item] = Value;
end;

procedure TMonoSelector.NewColor;
begin
  Message(Owner, evBroadcast, cmColorForegroundChanged,
    Pointer(Value and $0F));
  Message(Owner, evBroadcast, cmColorBackgroundChanged,
    Pointer((Value shr 4) and $0F));
end;

procedure TMonoSelector.Press(Item: Integer);
begin
  Value := MonoColors[Item];
  NewColor;
end;

procedure TMonoSelector.MovedTo(Item: Integer);
begin
  Value := MonoColors[Item];
  NewColor;
end;

{ TColorDisplay }

constructor TColorDisplay.Init(var Bounds: TRect; AText: PString);
begin
  TView.Init(Bounds);
  EventMask := EventMask or evBroadcast;
  Text := AText;
  Color := nil;
end;

constructor TColorDisplay.Load(var S: TStream);
begin
  TView.Load(S);
  Text := S.ReadStr;
end;

destructor TColorDisplay.Done;
begin
  DisposeStr(Text);
  TView.Done;
end;

procedure TColorDisplay.Draw;
var
  B: TDrawBuffer;
  I: Integer;
  C: Byte;
begin
  C := Color^;
  if C = 0 then C := ErrorAttr;
  for I := 0 to Size.X div Length(Text^) do
    MoveStr(B[I*Length(Text^)], Text^, C);
  WriteLine(0, 0, Size.X, Size.Y, B);
end;

procedure TColorDisplay.HandleEvent(var Event: TEvent);
begin
  TView.HandleEvent(Event);
  case Event.What of
    evBroadcast:
      case Event.Command of
        cmColorBackgroundChanged:
          begin
            Color^ := (Color^ and $0F) or (Event.InfoByte shl 4 and $F0);
            DrawView;
          end;
        cmColorForegroundChanged:
          begin
            Color^ := (Color^ and $F0) or (Event.InfoByte and $0F);
            DrawView;
          end;
      end;
  end;
end;

procedure TColorDisplay.SetColor(var AColor: Byte);
begin
  Color := @AColor;
  Message(Owner, evBroadcast, cmColorSet, Pointer(Color^));
  DrawView;
end;

procedure TColorDisplay.Store(var S: TStream);
begin
  TView.Store(S);
  S.WriteStr(Text);
end;

{ TColorGroupList }

constructor TColorGroupList.Init(var Bounds: TRect; AScrollBar: PScrollBar;
  AGroups: PColorGroup);
var
  I: Integer;
begin
  TListViewer.Init(Bounds, 1, nil, AScrollBar);
  Groups := AGroups;
  I := 0;
  while AGroups <> nil do
  begin
    AGroups := AGroups^.Next;
    Inc(I);
  end;
  SetRange(I);
end;

constructor TColorGroupList.Load(var S: TStream);

function ReadItems: PColorItem;
var
  Itms:  PColorItem;
  CurItm: ^PColorItem;
  Count, I: Integer;
begin
  S.Read(Count, SizeOf(Integer));
  Itms := nil;
  CurItm := @Itms;
  for I := 1 to Count do
  begin
    New(CurItm^);
    with CurItm^^ do
    begin
      Name := S.ReadStr;
      S.Read(Index, SizeOf(Byte));
    end;
    CurItm := @CurItm^^.Next;
  end;
  CurItm^ := nil;
  ReadItems := Itms;
end;

function ReadGroups: PColorGroup;
var
  Grps:  PColorGroup;
  CurGrp: ^PColorGroup;
  Count, I: Integer;
begin
  S.Read(Count, SizeOf(Integer));
  Grps := nil;
  CurGrp := @Grps;
  for I := 1 to Count do
  begin
    New(CurGrp^);
    with CurGrp^^ do
    begin
      Name := S.ReadStr;
      Items := ReadItems;
    end;
    CurGrp := @CurGrp^^.Next;
  end;
  CurGrp^ := nil;
  ReadGroups := Grps;
end;

begin
  TListViewer.Load(S);
  Groups := ReadGroups;
end;

destructor TColorGroupList.Done;

procedure FreeItems(CurITem: PColorItem);
var
  P: PColorItem;
begin
  while CurItem <> nil do
  begin
    P := CurItem;
    DisposeStr(CurItem^.Name);
    CurItem := CurItem^.Next;
    Dispose(P);
  end;
end;

procedure FreeGroups(CurGroup: PColorGroup);
var
  P: PColorGroup;
begin
  while CurGroup <> nil do
  begin
    P := CurGroup;
    FreeItems(CurGroup^.Items);
    DisposeStr(CurGroup^.Name);
    CurGroup := CurGroup^.Next;
    Dispose(P);
  end
end;

begin
  TListViewer.Done;
  FreeGroups(Groups);
end;

procedure TColorGroupList.FocusItem(Item: Integer);
var
  CurGroup: PColorGroup;
begin
  TListViewer.FocusItem(Item);
  CurGroup := Groups;
  while Item > 0 do
  begin
    CurGroup := CurGroup^.Next;
    Dec(Item);
  end;
  Message(Owner, evBroadcast, cmNewColorItem, CurGroup);
end;

function TColorGroupList.GetText(Item: Integer; MaxLen: Integer): String;
var
  CurGroup: PColorGroup;
  I: Integer;
begin
  CurGroup := Groups;
  while Item > 0 do
  begin
    CurGroup := CurGroup^.Next;
    Dec(Item);
  end;
  GetText := CurGroup^.Name^;
end;

procedure TColorGroupList.Store(var S: TStream);

procedure WriteItems(Items: PColorItem);
var
  CurItm: PColorItem;
  Count: Integer;
begin
  Count := 0;
  CurItm := Items;
  while CurItm <> nil do
  begin
    CurItm := CurItm^.Next;
    Inc(Count);
  end;
  S.Write(Count, SizeOf(Integer));
  CurItm := Items;
  while CurItm <> nil do
  begin
    with CurItm^ do
    begin
      S.WriteStr(Name);
      S.Write(Index, SizeOf(Byte));
    end;
    CurItm := CurItm^.Next;
  end;
end;

procedure WriteGroups(Groups: PColorGroup);
var
  CurGrp: PColorGroup;
  Count: Integer;
begin
  Count := 0;
  CurGrp := Groups;
  while CurGrp <> nil do
  begin
    CurGrp := CurGrp^.Next;
    Inc(Count);
  end;
  S.Write(Count, SizeOf(Integer));
  CurGrp := Groups;
  while CurGrp <> nil do
  begin
    with CurGrp^ do
    begin
      S.WriteStr(Name);
      WriteItems(Items);
    end;
    CurGrp := CurGrp^.Next;
  end;
end;

begin
  TListViewer.Store(S);
  WriteGroups(Groups);
end;

procedure TColorGroupList.HandleEvent(var Event: TEvent);
begin
  TListViewer.HandleEvent(Event);
  if Event.What = evBroadcast then
    if Event.Command = cmSaveColorIndex then
      SetGroupIndex(Focused, Event.InfoByte);
end;

procedure TColorGroupList.SetGroupIndex(GroupNum, ItemNum: Byte);
var
  Group: PColorGroup;
begin
  Group := GetGroup(GroupNum);
  if Group <> nil then
    Group^.Index := ItemNum;
end;

function TColorGroupList.GetGroupIndex(GroupNum: Byte): byte;
var
  Group: PColorGroup;
begin
  Group := GetGroup(GroupNum);
  if Group <> nil then
    GetGroupIndex := Group^.Index
  else
    GetGroupIndex := 0;
end;

function TColorGroupList.GetGroup(GroupNum: Byte): PColorGroup;
var
  Group: PColorGroup;
begin
  Group := Groups;
  while GroupNum > 0 do
  begin
    Group := Group^.Next;
    Dec(GroupNum);
  end;
  GetGroup := Group;
end;

function TColorGroupList.GetNumGroups: byte;
var
  Index: byte;
  Group: PColorGroup;
begin
  Index := 0;
  Group := Groups;
  while Group <> nil do
  begin
    Inc(Index);
    Group := Group^.Next;
  end;
  GetNumGroups := Index;
end;

{ TColorItemList }

constructor TColorItemList.Init(var Bounds: TRect; AScrollBar: PScrollBar;
  AItems: PColorItem);
var
  I: Integer;
begin
  TListViewer.Init(Bounds, 1, nil, AScrollBar);
  EventMask := EventMask or evBroadcast;
  Items := AItems;
  I := 0;
  while AItems <> nil do
  begin
    AItems := AItems^.Next;
    Inc(I);
  end;
  SetRange(I);
end;

procedure TColorItemList.FocusItem(Item: Integer);
var
  CurItem: PColorItem;
begin
  TListViewer.FocusItem(Item);
  Message(Owner, evBroadcast, cmSaveColorIndex, Pointer(Item));
  CurItem := Items;
  while Item > 0 do
  begin
    CurItem := CurItem^.Next;
    Dec(Item);
  end;
  Message(Owner, evBroadcast, cmNewColorIndex, Pointer(CurItem^.Index));
end;

function TColorItemList.GetText(Item: Integer; MaxLen: Integer): String;
var
  CurItem: PColorItem;
begin
  CurItem := Items;
  while Item > 0 do
  begin
    CurItem := CurItem^.Next;
    Dec(Item);
  end;
  GetText := CurItem^.Name^;
end;

procedure TColorItemList.HandleEvent(var Event: TEvent);
var
  CurItem: PColorItem;
  Group: PColorGroup;
  I: Integer;
begin
  TListViewer.HandleEvent(Event);
  if Event.What = evBroadcast then
  case Event.Command of
    cmNewColorItem:
      begin
        Group := Event.InfoPtr;
        Items := Group^.Items;
        CurItem := Items;
        I := 0;
        while CurItem <> nil do
        begin
          CurItem := CurItem^.Next;
          Inc(I);
        end;
        SetRange(I);
        FocusItem(Group^.Index);
        DrawView;
      end;
  end;
end;

{ TColorDialog }

constructor TColorDialog.Init(APalette: TPalette; AGroups: PColorGroup);
var
  R: TRect;
  P: PView;
begin
  R.Assign(0, 0, 65, 19);
  TDialog.Init(R, 'Barvy');
  Options := Options or ofCentered;
  Pal := APalette;

  R.Assign(22, 3, 23, 14);
  P := New(PScrollBar, Init(R));
  Insert(P);
  R.Assign(3, 3, 22, 14);
  Groups := New(PColorGroupList, Init(R, PScrollBar(P), AGroups));
  Insert(Groups);
  R.Assign(2, 2, 12, 3);
  Insert(New(PLabel, Init(R, '~S~kupiny', Groups)));

  R.Assign(47, 3, 48, 14);
  P := New(PScrollBar, Init(R));
  Insert(P);
  R.Assign(24, 3, 47, 14);
  P := New(PColorItemList, Init(R, PScrollBar(P), AGroups^.Items));
  Insert(P);
  R.Assign(24, 2, 35, 3);
  Insert(New(PLabel, Init(R, '~P~olo‘ky', P)));

  R.Assign(50, 3, 62, 7);
  ForSel := New(PColorSelector, Init(R, csForeground));
  Insert(ForSel);
  Dec(R.A.Y); R.B.Y := R.A.Y+1;
  ForLabel := New(PLabel, Init(R, '~P~op©ed¡', ForSel));
  Insert(ForLabel);

  Inc(R.A.Y, 7); Inc(R.B.Y,10);
  BakSel := New(PColorSelector, Init(R, csBackGround));
  Insert(BakSel);
  Dec(R.A.Y); R.B.Y := R.A.Y+1;
  BakLabel := New(PLabel, Init(R, '~P~ozad¡', BakSel));
  Insert(BakLabel);

  Dec(R.A.X); Inc(R.B.X); Inc(R.A.Y, 6); Inc(R.B.Y, 6);
  Display := New(PColorDisplay, Init(R, NewStr('Text ')));
  Insert(Display);

  R.Assign(44, 3, 59, 8);
  MonoSel := New(PMonoSelector, Init(R));
  MonoSel^.Hide;
  Insert(MonoSel);
  R.Assign(43, 2, 49, 3);
  MonoLabel := New(PLabel, Init(R, '~B~arvy', MonoSel));
  MonoLabel^.Hide;
  Insert(MonoLabel);

  if (AGroups <> nil) and (AGroups^.Items <> nil) then
    Display^.SetColor(Byte(Pal[AGroups^.Items^.Index]));

  R.Assign(36, 16, 46, 18);
  P := New(PButton, Init(R, 'O~K~', cmOk, bfDefault));
  Insert(P);
  R.Assign(48, 16, 58, 18);
  P := New(PButton, Init(R, 'Zru¨it', cmCancel, bfNormal));
  Insert(P);
  SelectNext(False);
end;

constructor TColorDialog.Load(var S: TStream);
var
  Len: Byte;
begin
  TDialog.Load(S);
  GetSubViewPtr(S, Display);
  GetSubViewPtr(S, Groups);
  GetSubViewPtr(S, ForLabel);
  GetSubViewPtr(S, ForSel);
  GetSubViewPtr(S, BakLabel);
  GetSubViewPtr(S, BakSel);
  GetSubViewPtr(S, MonoLabel);
  GetSubViewPtr(S, MonoSel);
  S.Read(Len, SizeOf(Byte));
  S.Read(Pal[1], Len);
  Pal[0] := Char(Len);
end;

procedure TColorDialog.HandleEvent(var Event: TEvent);
var
  C: Byte;
  ItemList: PColorItemList;
begin
  if Event.What = evBroadcast then
    if Event.Command = cmNewColorItem then
      GroupIndex := Groups^.Focused;
  TDialog.HandleEvent(Event);
  if Event.What = evBroadcast then
    if Event.Command = cmNewColorIndex then
      Display^.SetColor(Byte(Pal[Event.InfoByte]));
end;

procedure TColorDialog.Store(var S: TStream);
begin
  TDialog.Store(S);
  PutSubViewPtr(S, Display);
  PutSubViewPtr(S, Groups);
  PutSubViewPtr(S, ForLabel);
  PutSubViewPtr(S, ForSel);
  PutSubViewPtr(S, BakLabel);
  PutSubViewPtr(S, BakSel);
  PutSubViewPtr(S, MonoLabel);
  PutSubViewPtr(S, MonoSel);
  S.Write(Pal, Length(Pal)+1);
end;

function TColorDialog.DataSize: Word;
begin
  DataSize := SizeOf(TPalette);
end;

procedure TColorDialog.GetData(var Rec);
begin
  GetIndexes(ColorIndexes);
  String(Rec) := Pal;
end;

procedure TColorDialog.SetData(var Rec);
{var
  Item: PColorItem;
  Index: byte;}
begin
  Pal := String(Rec);
  SetIndexes(ColorIndexes);
{  Display^.SetColor(Byte(Pal[Groups^.GetGroupIndex(GroupIndex)]));}
  Groups^.FocusItem(GroupIndex);
  if ShowMarkers then
  begin
    ForLabel^.Hide;
    ForSel^.Hide;
    BakLabel^.Hide;
    BakSel^.Hide;
    MonoLabel^.Show;
    MonoSel^.Show;
  end;
  Groups^.Select;
end;

procedure TColorDialog.SetIndexes(var Colors: PColorIndex);
var
  NumGroups, Index: byte;
begin
  NumGroups := Groups^.GetNumGroups;
  if (Colors <> nil) and (Colors^.ColorSize <> NumGroups) then
  begin
    FreeMem(Colors, 2 + Colors^.ColorSize);
    Colors := nil;
  end;
  if Colors = nil then
  begin
    GetMem(Colors, 2 + NumGroups);
    fillchar(Colors^, 2 + NumGroups, 0);
    Colors^.ColorSize := NumGroups;
  end;
  for Index := 0 to NumGroups - 1 do
    Groups^.SetGroupIndex(Index, Colors^.ColorIndex[Index]);
  GroupIndex := Colors^.GroupIndex;
end;

procedure TColorDialog.GetIndexes(var Colors: PColorIndex);
var
  NumGroups, Index: Byte;
begin
  NumGroups := Groups^.GetNumGroups;
  if Colors = nil then
  begin
    GetMem(Colors, 2 + NumGroups);
    fillchar(Colors^, 2 + NumGroups, 0);
    Colors^.ColorSize := NumGroups;
  end;
  Colors^.GroupIndex := GroupIndex;
  for Index := 0 to NumGroups - 1 do
    Colors^.ColorIndex[Index] := Groups^.GetGroupIndex(Index);
end;

{ Load and Store Palette routines }

procedure LoadIndexes(var S: TStream);
var
  ColorSize: byte;
begin
  S.Read(ColorSize, sizeof(ColorSize));
  if ColorSize > 0 then
  begin
    if ColorIndexes <> nil then
      FreeMem(ColorIndexes, 2 + ColorIndexes^.ColorSize);
    getmem(ColorIndexes, ColorSize);
    S.Read(ColorIndexes^, ColorSize);
  end;
end;

procedure StoreIndexes(var S: TStream);
var
  ColorSize: byte;
begin
  if ColorIndexes <> nil then
    ColorSize := 2 + ColorIndexes^.ColorSize
  else
    ColorSize := 0;
  S.Write(ColorSize, sizeof(ColorSize));
  if ColorSize > 0 then
    S.Write(ColorIndexes^, ColorSize);
end;

{ -- Color list building routines -- }

function ColorItem(const Name: String; Index: Byte;
  Next: PColorItem): PColorItem;
var
  Item: PColorItem;
begin
  New(Item);
  Item^.Name := NewStr(Name);
  Item^.Index := Index;
  Item^.Next := Next;
  ColorItem := Item;
end;

function ColorGroup(const Name: String; Items: PColorItem;
  Next: PColorGroup): PColorGroup;
var
  Group: PColorGroup;
begin
  New(Group);
  Group^.Name := NewStr(Name);
  Group^.Items := Items;
  Group^.Next := Next;
  ColorGroup := Group;
end;

{ Standard color items functions }

function DesktopColorItems(const Next: PColorItem): PColorItem;
begin
  DesktopColorItems :=
    ColorItem('Color',             1,
    Next);
end;

function MenuColorItems(const Next: PColorItem): PColorItem;
begin
  MenuColorItems :=
    ColorItem('Text norm ln¡',            2,
    ColorItem('Text zak zan˜',          3,
    ColorItem('Text zkr cen‚ volby',          4,
    ColorItem('Vybran  norm ln¡',          5,
    ColorItem('Vybran  zak zan ', 6,
    ColorItem('Vybran  zkr cen  volba', 7,
    Next))))));
end;

function DialogColorItems(Palette: Word; const Next: PColorItem): PColorItem;
const
  COffset: array[dpBlueDialog..dpGrayDialog] of Byte =
    (64, 96, 32);
  var
    Offset: Byte;
begin
  Offset := COffset[Palette];
  DialogColorItems :=
    ColorItem('R me‡ek a pozad¡',  Offset + 1,
    ColorItem('Ikony v r me‡ku',   Offset + 2,
    ColorItem('Str nka rolovac¡ li¨ty',   Offset + 3,
    ColorItem('¡zen¡ rolovac¡ li¨ty',  Offset + 4,
    ColorItem('Informa‡n¡ text',   Offset + 5,

    ColorItem('N vˆ¨t¡ implicitnˆ',Offset + 6,
    ColorItem('N vˆ¨t¡ vybran‚',   Offset + 7,
    ColorItem('N vˆ¨t¡ kl vesa',   Offset + 8,

    ColorItem('Tla‡¡tko norm ln¡', Offset + 9,
    ColorItem('Tla‡¡tko p©ednostn¡',    Offset + 10,
    ColorItem('Tla‡¡tko vybran‚',   Offset + 11,
    ColorItem('Tla‡¡tko zak zan‚',   Offset + 12,
    ColorItem('Zkr cen  volba tla‡.',   Offset + 13,
    ColorItem('St¡n tla‡¡tka',     Offset + 14,

    ColorItem('Skupina norm ln¡',    Offset + 15,
    ColorItem('Skupina vybran ',  Offset + 16,
    ColorItem('Zkr cen  volba skup.',  Offset + 17,

    ColorItem('Vstupn¡ © dek norm.',      Offset + 18,
    ColorItem('Vstupn¡ © dek vybr.',    Offset + 19,
    ColorItem('›ipky vstupn¡ho © dku',       Offset + 20,

    ColorItem('Tla‡¡tko historie',    Offset + 21,
    ColorItem('Historie',     Offset + 22,
    ColorItem('Rolov tko historie',  Offset + 23,
    ColorItem('Ikony rol. historie', Offset + 24,

    ColorItem('Seznam norm ln¡',       Offset + 25,
    ColorItem('Kurzor seznamu',      Offset + 26,
    ColorItem('Seznam vybran˜',     Offset + 27,
    ColorItem('Dˆl¡c¡ ‡ ra seznamu',      Offset + 28,

    ColorItem('Informa‡n¡ panel',  Offset + 29,
    Next)))))))))))))))))))))))))))));
end;

function WindowColorItems(Palette: Word;
  const Next: PColorItem): PColorItem;
const
  COffset: array[wpBlueWindow..wpGrayWindow] of Byte =
    (8, 16, 24);
var
  Offset: Word;
begin
  Offset := COffset[Palette];
  WindowColorItems :=
    ColorItem('Pasivn¡ r m',     Offset + 0,
    ColorItem('Frame active',      Offset + 1,
    ColorItem('Ikony r mu',       Offset + 2,
    ColorItem('Str nka rolovac¡ li¨ty',   Offset + 3,
    ColorItem('Ikony posuvn¡ku',  Offset + 4,
    ColorItem('Norm ln¡ text pos.',       Offset + 5,
    Next))))));
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure RegisterColorSel;
begin
  RegisterType(RColorSelector);
  RegisterType(RMonoSelector);
  RegisterType(RColorDisplay);
  RegisterType(RColorGroupList);
  RegisterType(RColorItemList);
  RegisterType(RColorDialog);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure TPaletteDialog.HandleEvent;
Var C: Byte;
Begin
 TDialog.HandleEvent(Event);
 If Event.What=evBroadcast Then
 case Event.Command of
        cmScrollBarChanged:
          begin
           Colors[Color].R:=Red^.Value;
           Colors[Color].G:=Green^.Value;
           Colors[Color].B:=Blue^.Value;
           SetPal(Color,Red^.Value,Green^.Value,Blue^.Value);
          End;
        cmColorForegroundChanged:
          begin
            Color := Event.InfoByte;
            Red^.Value := Colors[Color].R;
            Green^.Value := Colors[Color].G;
            Blue^.Value := Colors[Color].B;
            DrawView;Red^.DrawView;Green^.DrawView;Blue^.DrawView;
          end;
      end;
  If (Event.What=evCommand) And (Event.Command = CmDefaultColors) Then
    Begin
      Colors := DefaultColors;
      For C:= 0 To 15 Do SetPal(C,Colors[C].R, Colors[C].G, Colors[C].B);
      Red^.Value := Colors[Color].R;
      Green^.Value := Colors[Color].G;
      Blue^.Value := Colors[Color].B;
      DrawView;Red^.DrawView;Green^.DrawView;Blue^.DrawView;
    End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Constructor TPaletteDialog.Init;
Var R : TRect;
    P : PView;
Begin
  R . Assign(0,0,70,13);
  TDialog.Init(R,'Nastaven¡ palety');
  Options := SetBit(Options,OfCentered);
  Colors := AColors;Color := 0;
  R.Assign(2, 2, 14, 6);
  Selector := New(PColorSelector, Init(R, csForeground));
  Insert(Selector);

  R.Assign(16, 2, Size.X -2, 3);
  Red := New(PScrollBar, Init(R));
  Red^.SetParams(Colors[Color].R,0,255,1,1);
  Insert(Red);
  Dec(R.A.Y);Dec(R.B.Y);
  Insert(New(PLabel, Init(R, '~€~erven ', Red)));

  Inc(R.A.Y, 3);Inc(R.B.Y, 3);
  Green := New(PScrollBar, Init(R));
  Green^.SetParams(Colors[Color].G,0,255,1,1);
  Insert(Green);
  Dec(R.A.Y);Dec(R.B.Y);
  Insert(New(PLabel, Init(R, '~Z~elen ', Green)));

  Inc(R.A.Y, 3);Inc(R.B.Y, 3);
  Blue := New(PScrollBar, Init(R));
  Blue^.SetParams(Colors[Color].B,0,255,1,1);
  Insert(Blue);
  Dec(R.A.Y);Dec(R.B.Y);
  Insert(New(PLabel, Init(R, '~M~odr ', Blue)));

  R.Assign(2,Size.Y-5,26,Size.Y-4);
  Check:=New(PCheckBoxes,Init(R,NewSItem('Vracet zpet paletu',nil)));
  Insert(Check);

  R.Assign(Size.X-35, Size.Y-3,Size.X -21,Size.Y -1);
  P := New(PButton, Init(R, '~S~tandart', cmDefaultColors, bfDefault));
  Insert(P);

  R.Assign(Size.X-21, Size.Y-3,Size.X -11,Size.Y -1);
  P := New(PButton, Init(R, 'O~K~', cmOk, bfDefault));
  Insert(P);
  R.Assign(Size.X-11, Size.Y-3,Size.X -2,Size.Y -1);
  P := New(PButton, Init(R, '~Z~ru¨it', cmCancel, bfNormal));
  Insert(P);

  SelectNext(False);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPaletteDialog.SetData;
Begin
 Colors := TPaleteRec(Rec).Colors;
 Check^.Value := TPaleteRec(Rec).BackPalette;;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TPaletteDialog.GetData;
Begin
 TPaleteRec(Rec).Colors := Colors;
 TPaleteRec(Rec).BackPalette := Check^.Value;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
end.
