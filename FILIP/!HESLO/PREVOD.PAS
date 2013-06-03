uses dialogs, views, objects, app, drivers, crt, supply, msgbox, base;
const
  PREVODCommandOrigin                     =   200;
  cmAutoDetect                            = PREVODCommandOrigin;

type
   PPREVODData = ^TPREVODData;
   TPREVODData = record
               Data1                :  Word;
               Data2                :  Word;
           end;
   tmydialog = object (tdialog)
                      procedure Handleevent(var event : TEvent); virtual;
                    end;
   pmydialog = ^tmydialog;

const chnum=86;
  CTab  : array [1..chnum,1..4] of char = { doplnit o ascii bez carek}
    ((#128,#172,#172,'C'), (#129,#129,#129,'u'), (#130,#130,#130,'e'),
     (#131,#212,#212,'d'), (#132,#132,#131,'a'), (#133,#210,#216,'D'),
     (#134,#155,#155,'T'), (#135,#159,#159,'c'), (#136,#216,#216,'e'),
     (#137,#183,#183,'E'), (#138,#145,#145,'L'), (#139,#214,#214,'I'),
     (#140,#150,#150,'l'), (#141,#146,#146,'l'), (#142,#142,#142,'A'),
     (#143,#181,#181,'A'),

     (#144,#144,#144,'E'), (#145,#167,#167,'z'), (#146,#166,#166,'Z'),
     (#147,#147,#147,'o'), (#148,#148,#148,'o'), (#149,#162,#224,'O'),
     (#150,#133,#133,'u'), (#151,#233,#233,'U'), (#152,#236,#236,'y'),
     (#153,#153,#153,'O'), (#154,#154,#154,'U'), (#155,#230,#230,'S'),
     (#156,#149,#149,'L'), (#157,#237,#237,'Y'), (#158,#252,#252,'R'),
     (#159,#156,#156,'t'),

     (#160,#160,#160,'a'), (#161,#161,#161,'i'), (#162,#162,#162,'o'),
     (#163,#163,#163,'u'), (#164,#229,#229,'n'), (#165,#213,#213,'N'),
     (#166,#222,#222,'U'), (#167,#226,#226,'O'), (#168,#231,#231,'s'),
     (#169,#253,#253,'r'), (#170,#234,#234,'r'), (#171,#232,#232,'R'),
     (#172,#135,#135,'c'), (#000,#128,#128,'C'), (#000,#131,#131,'a'),
     (#000,#134,#134,'c'),

     (#000,#136,#136,'l'), (#000,#137,#137,'e'), (#000,#138,#138,'O'),
     (#000,#139,#139,'o'), (#000,#140,#140,'i'), (#000,#141,#141,'Z'),
     (#000,#150,#150,'C'), (#000,#151,#150,'S'), (#000,#152,#151,'s'),
     (#000,#157,#157,'L'), (#000,#164,#164,'A'), (#000,#165,#165,'a'),
     (#000,#168,#168,'E'), (#000,#169,#169,'e'), (#000,#171,#171,'z'),
     (#000,#173,#173,'s'),

     (#000,#182,#182,'A'), (#000,#184,#184,'S'), (#000,#189,#189,'Z'),
     (#000,#190,#190,'z'), (#000,#198,#198,'A'), (#000,#199,#199,'a'),
     (#000,#215,#215,'I'), (#000,#227,#227,'N'), (#000,#208,#208,'d'),
     (#000,#209,#209,'D'), (#000,#228,#228,'n'), (#000,#235,#235,'U'),
     (#000,#238,#238,'t'), (#000,#251,#251,'u'), (#000,#211,#211,'E'),
     (#000,#221,#221,'T'),

     (#000,#239,#239,' '), (#000,#243,#243,' '), (#000,#244,#244,' '),
     (#000,#241,#241,' '), (#000,#249,#249,' '), (#000,#250,#250,' '));

var moje  : tapplication;

procedure tmydialog.HandleEvent;
begin
 if (event.command=cmAutoDetect) then
  begin
    ;
  end else inherited handleevent(event);
end;

function PREVOD(var _Data : TPREVODData; _SetData : Boolean;
                    fname : string): Word;
var
  D    : PMyDialog;
  C    : PView;
  R    : TRect;
  _DataPtr : PPREVODData;
begin
  R.Assign(8,4,58,17);
  D:=New(PMyDialog,Init(R,'P©evod n rodn¡ch znak–'));
  with D^ do
       begin
          R.Assign(26,5,47,9);
          C:=New(PFramedView,Init(R));
          Insert(C);

          R.Assign(3,5,24,11);
          C:=New(PFramedView,Init(R));
          Insert(C);

          R.Assign(3,5,24,8);
          C:=New(PRadioButtons,Init(R,
               NewSItem('K¢d ~K~amenick˜ch',
               NewSItem('~L~atin2',
               NewSItem('~E~ECS (Windows)',
               nil)))));
          Insert(C);

          R.Assign(4,4,22,5);
          C:=New(PStaticText,Init(R,' P–vodn¡ k¢dov n¡ '));
          Insert(C);

          R.Assign(3,2,49,3);
          C:=New(PStaticText,Init(R,'Zvolte typ kodovani pro "'+
           GetName(fname)+'.'+getExtension(fname)+'"'));
          Insert(C);

          R.Assign(26,5,47,9);
          C:=New(PRadioButtons,Init(R,
               NewSItem('K¢d K~a~menick˜ch',
               NewSItem('La~t~in2',
               NewSItem('EE~C~S',
               NewSItem('~B~ez diakritiky',
               nil))))));
          Insert(C);

          R.Assign(26,4,45,5);
          C:=New(PStaticText,Init(R,' V˜sledn‚ k¢dov n¡ '));
          Insert(C);

          R.Assign(26,10,36,12);
          C:=New(PButton,Init(R,'Ok',cmOk,bfDefault));
          Insert(C);

          R.Assign(37,10,47,12);
          C:=New(PButton,Init(R,'Zru¨it',cmCancel,bfNormal));
          Insert(C);

          R.Assign(6,9,21,11);
          C:=New(PButton,Init(R,'Automaticky',cmAutoDetect,bfNormal));
          Insert(C);

          SelectNext(False);
       end;

   _DataPtr:=@_Data;
   if not _SetData then FillChar(_Data,SizeOf(_Data),0);
   PREVOD:=Application^.ExecuteDialog(D,_DataPtr);
end;

Function IfIsIn(what  : char;i1, i2:byte):char;
var
  x  : byte;
  c  : char;
begin
  x:=1;
  c:=what;
  repeat
    if CTab[x,i1]=what then
    begin
      c:=CTab[x,i2];
      if c=#0 then c:=CTab[x,4];
      x:=chnum;
    end;
    inc(x);
  until x>Chnum;
  IfIsIn:=c;
end;

var
  g     : tprevoddata;
  fajl  : string;
  f     : file;
  i,o   : array [0..255] of char;
  num,x : byte;
begin
  moje.init;
  fajl:='d:\binec.txt';
  if Prevod(g,true,fajl)=cmok then
  begin
    if g.Data1=g.data2 then
    begin
      sound(1000);
      delay(100);
      nosound;
      MessageBox('Zvolene znakove sady jsou stejne.', nil,mfError);
    end else
    begin
      { prevod }
      assign(f,fajl);
      {$I-} reset(f,1); {$I+}
      if ioresult=0 then
      begin
        {prevod}
        repeat
          if filesize(f)-filepos(f)>255 then num:=255 else
             num:=filesize(f)-filepos(f);
          blockread(f,i,num);
          for x:=0 to num do
          begin
            o[x]:=IfIsIn(i[x],g.Data1+1,g.Data2+1);
          end;
          seek(f,filepos(f)-num);
          blockwrite(f,o,num);
          Writeln(filepos(f)*100/filesize(f):4:0,'%');
        until filesize(f)-filepos(f)=0;
        close(f);
      end else
      begin
        sound(1000);
        delay(100);
        nosound;
        MessageBox('Chyba pri otevirani souboru.',nil,mfError);
      end
    end;
  end;
  moje.done;
end.