program project1;
uses Crt;
const
  MaxTah = 150;                       //program se po projití tohoto počtů posunů krabic ukončí
  SizeOfm = 50;                       //maximální výška mapy
  SizeOfn = 50;                       //maximální šířka mapy
  EndOfMapChar = '#';                 //znak konce mapy
  PlayerChar = 'P';                   //znak Hráče
  BoxChar = 'K';                      //znak krabice
  BoxOnTargetPlaceChar = 'k';         //znak krabice umístěné na cílové pozici
  PlayerOnTargetPlaceChar = 'p';      //hráč stojící na cílové pozici
  TargetPlaceChar = 'O';              //znak cílové pozice
  ObstructionChar = 'x';              //znak překážky
  ProblemBoxChar = 'B';               //pomocný znak, podezřelá krabice, co může zajistit prohru v daném kroku
type
  map = array[0..SizeOfm,0..SizeOfn] of char;             //mapa se znaky
  valueMap = array[0..SizeOfm,0..SizeOfn] of integer;     //mapa s čísly
  field = array[0..1] of integer;                         //souřadnice políčka na mapě
  PKrabice = ^Krabice;                                    //aktuální vlastnosti krabic
  Krabice = record
    S: boolean;
    J: boolean;
    V: boolean;
    Z: boolean;
    souradnice : field;
    dalsi: PKrabice;
  end;
  PSituace = ^Situace;                                    //všechny prozkoumané situace rozmístění krabic a hráče
  Situace = record
    kraby: Pkrabice;
    dalsi: PSituace;
  end;
  PVyherniKroky = ^VyherniKroky;                          //sled map změn krabic zaručující výhru
  VyherniKroky = record
     krok:map;
     dalsi:PVyherniKroky;
  end;
  PnejkrCesta = ^nejkrCesta;                              //sled map změn hráče zaručující výhru
  nejkrCesta = record
     Z:PnejkrCesta;
     souradnice:field;
     dalsi:PnejkrCesta;
  end;

var
 f : text;
 mapa: map;
 c : char;
 hrac, smer: field;
 HerniSituace:PSituace;
 vyhKrok, HlavaKrok:PVyherniKroky;
 vyhralJsem:boolean;







 {FUNKCE ZJISTUJICI, ZDA MUZE ZKOUMANA POZICE JESTE DOJIT K CILY, CI UZ K NEMU DOSLA}
function muzuVyhratRohy(vyhraMap:map):boolean; //Ověří, zda jsou v dané mapě v rozích zablokované neumístěné krabice. Vrací true/false.
var
  i,j:integer;
begin
     Result := true;

    i:=0;
    j:=0;
        while Result AND(vyhraMap[i,j] <> EndOfMapChar) do
           begin
              while(vyhraMap[i,j] <> EndOfMapChar) do
                 begin
                   if(vyhraMap[i,j] = BoxChar)
                   then begin
                      if((vyhraMap[i+1,j] = ObstructionChar)OR(vyhraMap[i-1, j] = ObstructionChar)) AND ((vyhraMap[i, j+1] = ObstructionChar)OR(vyhraMap[i, j-1] = ObstructionChar))
                      then Result:=false;
                   end;
                   j := j+1;
                 end;
                  j:=0;
                  i:=i+1;
        end;
end;
function muzuVyhratVert(vyhraMap:map; krabice:PKrabice):boolean;  //Ověří, zda jsou v dané mapě vertikálně zablokované neumístěné krabice. Vrací true/false.
var
  x,y:integer;
  jeZabitaKrabice:boolean;
begin
      Result:=true;

   while(krabice^.dalsi<>nil)do
      begin
        krabice:=krabice^.dalsi;
        jeZabitaKrabice:=true;
        x:=krabice^.souradnice[0];
        y:=krabice^.souradnice[1];
        while(vyhraMap[x, y]<>TargetPlaceChar)AND(vyhraMap[x,y]<>PlayerOnTargetPlaceChar)AND(vyhraMap[x, y-1]=ObstructionChar)AND not(vyhraMap[x, y]=ObstructionChar)do x:=x+1;
        if (not(vyhraMap[x,y-1]=ObstructionChar))OR(vyhraMap[x, y]=TargetPlaceChar)OR(vyhraMap[x,y]=PlayerOnTargetPlaceChar)
        then jeZabitaKrabice:=false;
        x:=krabice^.souradnice[0];
        y:=krabice^.souradnice[1];
        while(vyhraMap[x, y]<>TargetPlaceChar)AND(vyhraMap[x,y]<>PlayerOnTargetPlaceChar)AND(vyhraMap[x, y-1]=ObstructionChar)AND not(vyhraMap[x, y]=ObstructionChar)do x:=x-1;
        if (not(vyhraMap[x,y-1]=ObstructionChar))OR(vyhraMap[x, y]=TargetPlaceChar)OR(vyhraMap[x,y]=PlayerOnTargetPlaceChar)
        then jeZabitaKrabice:=false;
        if(jeZabitaKrabice)
        then Result:=false;

        jeZabitaKrabice:=true;
        x:=krabice^.souradnice[0];
        y:=krabice^.souradnice[1];
        while(vyhraMap[x, y]<>TargetPlaceChar)AND(vyhraMap[x,y]<>PlayerOnTargetPlaceChar)AND(vyhraMap[x, y+1]=ObstructionChar)AND not(vyhraMap[x, y]=ObstructionChar)do x:=x+1;
        if (not(vyhraMap[x,y+1]=ObstructionChar))OR(vyhraMap[x, y]=TargetPlaceChar)OR(vyhraMap[x,y]=PlayerOnTargetPlaceChar)
        then jeZabitaKrabice:=false;
        x:=krabice^.souradnice[0];
        y:=krabice^.souradnice[1];
        while(vyhraMap[x, y]<>TargetPlaceChar)AND(vyhraMap[x,y]<>PlayerOnTargetPlaceChar)AND(vyhraMap[x, y+1]=ObstructionChar)AND not(vyhraMap[x, y]=ObstructionChar)do x:=x-1;
        if (not(vyhraMap[x,y+1]=ObstructionChar))OR(vyhraMap[x, y]=TargetPlaceChar)OR(vyhraMap[x,y]=PlayerOnTargetPlaceChar)
        then jeZabitaKrabice:=false;

        if(jeZabitaKrabice)
        then Result:=false;
      end;

end;
function muzuVyhratHor(vyhraMap:map; krabice:PKrabice):boolean;  //Ověří, zda jsou v dané mapě horizontálně zablokované neumístěné krabice. Vrací true/false.
var
  x,y:integer;
  jeZabitaKrabice:boolean;
begin
   Result:=true;
   while(krabice^.dalsi<>nil)do
      begin
        krabice:=krabice^.dalsi;
        jeZabitaKrabice:=true;
        x:=krabice^.souradnice[0];
        y:=krabice^.souradnice[1];
        while(vyhraMap[x, y]<>TargetPlaceChar)AND(vyhraMap[x,y]<>PlayerOnTargetPlaceChar)AND(vyhraMap[x-1, y]=ObstructionChar)AND not(vyhraMap[x, y]=ObstructionChar)do y:=y+1;
        if (not(vyhraMap[x-1,y]=ObstructionChar))OR(vyhraMap[x, y]=TargetPlaceChar)OR(vyhraMap[x,y]=PlayerOnTargetPlaceChar)
        then jeZabitaKrabice:=false;
        x:=krabice^.souradnice[0];
        y:=krabice^.souradnice[1];
        while(vyhraMap[x, y]<>TargetPlaceChar)AND(vyhraMap[x,y]<>PlayerOnTargetPlaceChar)AND(vyhraMap[x-1, y]=ObstructionChar)AND not(vyhraMap[x, y]=ObstructionChar)do y:=y-1;
        if (not(vyhraMap[x-1,y]=ObstructionChar))OR(vyhraMap[x, y]=TargetPlaceChar)OR(vyhraMap[x,y]=PlayerOnTargetPlaceChar)
        then jeZabitaKrabice:=false;

        if(jeZabitaKrabice)
        then Result:=false;

        jeZabitaKrabice:=true;
        x:=krabice^.souradnice[0];
        y:=krabice^.souradnice[1];
        while(vyhraMap[x, y]<>TargetPlaceChar)AND(vyhraMap[x,y]<>PlayerOnTargetPlaceChar)AND(vyhraMap[x+1, y]=ObstructionChar)AND not(vyhraMap[x, y]=ObstructionChar)do y:=y+1;
        if (not(vyhraMap[x+1,y]=ObstructionChar))OR(vyhraMap[x, y]=TargetPlaceChar)OR(vyhraMap[x,y]=PlayerOnTargetPlaceChar)
        then jeZabitaKrabice:=false;
        x:=krabice^.souradnice[0];
        y:=krabice^.souradnice[1];
        while(vyhraMap[x, y]<>TargetPlaceChar)AND(vyhraMap[x,y]<>PlayerOnTargetPlaceChar)AND(vyhraMap[x+1, y]=ObstructionChar)AND not(vyhraMap[x, y]=ObstructionChar)do y:=y-1;
        if (not(vyhraMap[x+1,y]=ObstructionChar))OR(vyhraMap[x, y]=TargetPlaceChar)OR(vyhraMap[x,y]=PlayerOnTargetPlaceChar)
        then jeZabitaKrabice:=false;

        if(jeZabitaKrabice)
        then Result:=false;
      end;
end;
function muzuVyhratSkupinkyNemuzu(vyhraMap:map; x,y:integer):boolean; //Pomocná podmínka pro "muzuVyhratSkupinky()". Zjišťuje, zda se může krabice přemístit na příchozí souřadnici. Vrací true/false.
begin
  if(vyhraMap[x,y]=BoxChar)OR(vyhraMap[x,y]=BoxOnTargetPlaceChar)OR(vyhraMap[x,y]=ObstructionChar)OR(vyhraMap[x,y]=ProblemBoxChar)
  then Result:=true
  else Result:=false;
end;
function jeKolemKrabice(vyhraMap:map; x,y:integer):boolean; //Zjišťuje, zda je kolem konkrétního políčka příchozích souřadnic krabice. Pokud ano, vrací true, jinak false.
begin
  Result:=false;
  if(vyhraMap[x+1, y]=BoxChar)OR(vyhraMap[x+1,y]=BoxOnTargetPlaceChar)
  then Result:=true;
  if(vyhraMap[x-1, y]=BoxChar)OR(vyhraMap[x-1, y]=BoxOnTargetPlaceChar)
  then Result:=true;
  if(vyhraMap[x, y+1]=BoxChar)OR(vyhraMap[x, y+1]=BoxOnTargetPlaceChar)
  then Result:=true;
  if(vyhraMap[x, y-1]=BoxChar)OR(vyhraMap[x, y-1]=BoxOnTargetPlaceChar)
  then Result:=true;
end;
function muzuVyhratSkupinky(vyhraMap:map):boolean; //Zjišťuje, zda se uskupené krabice neblokují navzájem a tedy zda je ještě možná výhra. Vrací true/false.
var
  i,j:integer;
begin
  Result:=true;
    i:=0;
    j:=0;
        while(vyhraMap[i,j] <> EndOfMapChar) do
           begin
              while(vyhraMap[i,j] <> EndOfMapChar) do
                 begin
                   if(vyhraMap[i,j] = BoxChar)
                   then begin
                      if(muzuVyhratSkupinkyNemuzu(vyhraMap, i-1, j)OR muzuVyhratSkupinkyNemuzu(vyhraMap, i+1, j))AND(muzuVyhratSkupinkyNemuzu(vyhraMap, i, j-1)OR muzuVyhratSkupinkyNemuzu(vyhraMap, i, j+1))
                      then
                      begin
                      vyhraMap[i,j]:=ProblemBoxChar;

                      if(not jeKolemKrabice(vyhraMap, i, j))
                      then Result:=false;
                      end;
                   end;
                   j := j+1;
                 end;
                  j:=0;
                  i:=i+1;
        end;
end;
function uzBylo(vlastKrab:PKrabice):boolean; //Zjišťuje, zda už někdy dříve nastalo dané rozmístění krabic. Pokud ne, zapíše toto rozmístění do seznamu rozmístění, které už byly. Vrací true/false.
var
 sitBylo, tsitBylo: PSituace;
 pkrabVSit, pvlastKrab: PKrabice;
 nebyla:boolean;
begin

   nebyla:=true;
   sitBylo:=HerniSituace;

   while(sitBylo^.dalsi<>nil)AND(nebyla) do
      begin
        sitBylo:=sitBylo^.dalsi;
        pvlastKrab:=vlastKrab;
        pkrabVSit:=sitBylo^.kraby;
        nebyla:=false;
        while(pvlastKrab^.dalsi<>nil) AND not(nebyla) do
           begin
             nebyla:=true;
             pvlastKrab:=pvlastKrab^.dalsi;
             pkrabVSit:=pkrabVSit^.dalsi;

             if (pvlastKrab^.souradnice[0]=pkrabVSit^.souradnice[0])AND(pvlastKrab^.souradnice[1]=pkrabVSit^.souradnice[1])AND(pvlastKrab^.S=pkrabVSit^.S)AND(pvlastKrab^.J=pkrabVSit^.J)AND(pvlastKrab^.V=pkrabVSit^.V)AND(pvlastKrab^.Z=pkrabVSit^.Z)
             then nebyla:=false;
           end;
        if(not nebyla)
        then Result:=true;

      end;


   if(nebyla)
   then begin
      new(tsitBylo);
      sitBylo^.dalsi:=tsitBylo;
      sitBylo:=sitBylo^.dalsi;
      sitBylo^.dalsi:=nil;
      sitBylo^.kraby:=vlastKrab;
      Result:=false;
      end;

end;
function jeVyhra(vyhraMap: map):boolean; //Ověřuje, zda v dané mapě nastala výhra. Vrací true/false.
var
 i,j: integer;
begin
  i:=0;
  j:=0;
        while(vyhraMap[i,j] <> BoxChar)AND(vyhraMap[i,j] <> EndOfMapChar) do
           begin
              while(vyhraMap[i,j] <> BoxChar)AND(vyhraMap[i,j] <> EndOfMapChar) do
                 begin
                   j := j+1;
                 end;
              if((vyhraMap[i,j] <> BoxChar))
              then begin
                  j:=0;
                  i:=i+1;
              end;
        end;
        if(vyhraMap[i,j] = BoxChar)
        then Result := false
        else Result := true;


end;
function overKrok(overMap: map;hrac, smer: field):boolean; //Ověřuje, zda krok, který by měl být proveden, je platný. Vrací true/false
var
kam: field;
begin
 {Overi, jestli je krok proveditelny nebo ne. Vraci true/false jestli je ci ne. Nic nemění}
kam[0] := hrac[0] + smer[0];
kam[1] := hrac[1] + smer[1];
if(overMap[kam[0], kam[1]] = EndOfMapChar)
then Result:=false
else if(overMap[kam[0], kam[1]] = PlayerChar)OR(overMap[kam[0], kam[1]] = PlayerOnTargetPlaceChar)
   then {wtf, dva hraci v poli}
   else if(overMap[kam[0], kam[1]] = BoxChar)OR(overMap[kam[0], kam[1]] = BoxOnTargetPlaceChar)OR(overMap[kam[0],kam[1]]=BoxOnTargetPlaceChar)
       then begin
           if (overMap[kam[0]+smer[0], kam[1]+smer[1]] = BoxChar)OR (overMap[kam[0]+smer[0], kam[1]+smer[1]] = BoxOnTargetPlaceChar) OR (overMap[kam[0]+smer[0], kam[1]+smer[1]] = EndOfMapChar)OR(overMap[kam[0]+smer[0], kam[1]+smer[1]] = ObstructionChar)
               then Result:=false
               else Result:=true;
       end
       else if(overMap[kam[0], kam[1]] = TargetPlaceChar)
           then Result:=true
           else if(overMap[kam[0], kam[1]] = ObstructionChar)
               then Result:=false
               else Result:=true;


end;
function NeulozeneKrabice(kmkMapa: map):PKrabice; //Vrací zpět seznam a charaktreristiku krabic neležící na cílových políčcích, pro danou příchozí mapu.
var
  Box, pBox ,tBox: PKrabice;
  i, j: integer;
begin
  i:=0;
  j:=0;
  new(pBox);
  Box:=pBox;


        while(kmkMapa[i,j] <> EndOfMapChar) do
           begin
              while(kmkMapa[i,j] <> EndOfMapChar) do
                 begin
                   if(kmkMapa[i,j] = BoxChar)
                   then begin
                      new(tBox);
                      pBox^.dalsi:=tBox;
                      pBox:=pBox^.dalsi;
                      if(kmkMapa[i-1,j] = PlayerChar) OR (kmkMapa[i-1,j] = PlayerOnTargetPlaceChar)
                      then pBox^.S:=true else pBox^.S:=false;
                      if(kmkMapa[i+1, j] = PlayerChar) OR (kmkMapa[i+1,j] = PlayerOnTargetPlaceChar)
                      then pBox^.J:=true else pBox^.J:=false;
                      if(kmkMapa[i, j+1] = PlayerChar) OR (kmkMapa[i,j+1] = PlayerOnTargetPlaceChar)
                      then pBox^.V:=true else pBox^.V:=false;
                      if(kmkMapa[i, j-1] = PlayerChar) OR (kmkMapa[i,j-1] = PlayerOnTargetPlaceChar)
                      then pBox^.Z:=true else pBox^.Z:=false;
                      pBox^.souradnice[0]:= i;
                      pBox^.souradnice[1]:= j;
                   end;
                   j := j+1;
                 end;
              i:=i+1;
              j:=0;
        end;
        pBox^.dalsi:=nil;

        Result:=Box;



end;
function muzuVyhrat(vyhraMap : map):boolean; //Zjišťuje, zda ještě může aktuální krok vést k cíli. Vrací true/false.
var
 krabice:PKrabice;
begin
  krabice:=NeulozeneKrabice(vyhraMap);
  if(muzuVyhratRohy(vyhraMap) AND muzuVyhratSkupinky(vyhraMap)AND muzuVyhratHor(vyhraMap, krabice)AND muzuVyhratVert(vyhraMap, krabice))
  then Result:=true
  else Result:=false;
end;
{-----------------------------------------------------------------------------------------------------------------------}



{POMOCNE PROCEDURY,FUNKCE K PROCEDURE 'JduToVyhrat', HLEDAJI SE POSUNY KRABIC VEDOUCI K CILI}
function KamMuzeKrabice(kmkMapa: map):PKrabice; //Najde všechny krabice, jejich souřadnice a z jaké strany se k nim hráč dostane (tedy jakým směrem se teoreticky mohou pohnout. Vrací zpět list těchto informací.
var
  Box, pBox ,tBox: PKrabice;
  i, j: integer;
begin
  i:=0;
  j:=0;
  new(pBox);
  Box:=pBox;


        while(kmkMapa[i,j] <> EndOfMapChar) do
           begin
              while(kmkMapa[i,j] <> EndOfMapChar) do
                 begin
                   if(kmkMapa[i,j] = BoxChar) OR (kmkMapa[i,j] = BoxOnTargetPlaceChar)
                   then begin
                      new(tBox);
                      pBox^.dalsi:=tBox;
                      pBox:=pBox^.dalsi;
                      if(kmkMapa[i-1,j] = PlayerChar) OR (kmkMapa[i-1,j] = PlayerOnTargetPlaceChar)
                      then pBox^.S:=true else pBox^.S:=false;
                      if(kmkMapa[i+1, j] = PlayerChar) OR (kmkMapa[i+1,j] = PlayerOnTargetPlaceChar)
                      then pBox^.J:=true else pBox^.J:=false;
                      if(kmkMapa[i, j+1] = PlayerChar) OR (kmkMapa[i,j+1] = PlayerOnTargetPlaceChar)
                      then pBox^.V:=true else pBox^.V:=false;
                      if(kmkMapa[i, j-1] = PlayerChar) OR (kmkMapa[i,j-1] = PlayerOnTargetPlaceChar)
                      then pBox^.Z:=true else pBox^.Z:=false;
                      pBox^.souradnice[0]:= i;
                      pBox^.souradnice[1]:= j;
                   end;
                   j := j+1;
                 end;
              i:=i+1;
              j:=0;
        end;
        pBox^.dalsi:=nil;

        Result:=Box;



end;
procedure odstranVlastnostKrabic(vlastnosti:PKrabice); //uvolní pamět od příchozích vlastností krabic
begin
  if(vlastnosti^.dalsi <> nil) then
    odstranVlastnostKrabic(vlastnosti^.dalsi);

  dispose(vlastnosti);

end;
procedure zapisujuVyherniKroky(vyherniMapa: map); //Pomocí příchozích map vytváří seznam kroků, které vedou k cíli (konkrétně od cíle k začátku).
var
 prvek:PVyherniKroky;
begin
 new(prvek);
 prvek^.krok:=vyherniMapa;
 prvek^.dalsi:=vyhKrok;
 vyhKrok:=prvek;
end;
function odPlayerovac(OdPlayerujuMap: map; hrac: field):map; //z mapy vymaže všechny znaky hráče
var
 i,j: integer;
begin
  {smaze vsechny P, na konci urci jedno P }
  i:=0;
  j:=0;
        while(OdPlayerujuMap[i,j] <> EndOfMapChar) do
           begin
              while(OdPlayerujuMap[i,j] <> EndOfMapChar) do
                 begin
                   if(OdPlayerujuMap[i,j] = PlayerChar)AND((i<>hrac[0]) OR (j<>hrac[1]))
                   then OdPlayerujuMap[i,j] := ' '
                   else if(OdPlayerujuMap[i,j] = PlayerOnTargetPlaceChar)AND((i<>hrac[0]) OR (j<>hrac[1]))
                   then OdPlayerujuMap[i,j] := TargetPlaceChar;

                   j := j+1;

                 end;
              i:=i+1;
              j:=0;
        end;
        Result:=OdPlayerujuMap;

end;
function oPlayerovac(playerujuMap :map; hrac:field):map;  //Vrací zpět mapu, ve které vloží na každé políčko, na které může hráč bez posunutí krabic dostat, symbol hráče.
begin
    if(playerujuMap[hrac[0], hrac[1]] = ' ')
    then playerujuMap[hrac[0], hrac[1]] := PlayerChar
    else if (playerujuMap[hrac[0], hrac[1]] = TargetPlaceChar)
    then playerujuMap[hrac[0], hrac[1]] := PlayerOnTargetPlaceChar;

   if(playerujuMap[hrac[0]+1, hrac[1]] = ' ') OR (playerujuMap[hrac[0]+1, hrac[1]] = TargetPlaceChar)then
   begin
      hrac[0] := hrac[0]+1;
      playerujuMap := oPlayerovac(playerujuMap, hrac);
      hrac[0] := hrac[0]-1;
   end;
   if(playerujuMap[hrac[0]-1, hrac[1]] = ' ') OR (playerujuMap[hrac[0]-1, hrac[1]] = TargetPlaceChar) then
   begin
      hrac[0] := hrac[0]-1;
      playerujuMap := oPlayerovac(playerujuMap, hrac);
      hrac[0] := hrac[0]+1;
   end;
   if(playerujuMap[hrac[0], hrac[1]+1] = ' ') OR (playerujuMap[hrac[0], hrac[1]+1] = TargetPlaceChar) then
   begin
      hrac[1] := hrac[1]+1;
      playerujuMap := oPlayerovac(playerujuMap, hrac);
      hrac[1] := hrac[1]-1;
   end;
   if(playerujuMap[hrac[0], hrac[1]-1] = ' ') OR (playerujuMap[hrac[0], hrac[1]-1] = TargetPlaceChar) then
   begin
      hrac[1] := hrac[1]-1;
      playerujuMap := oPlayerovac(playerujuMap, hrac);
      hrac[1] := hrac[1]+1;
   end;

   Result:= playerujuMap;
end;
function najdiHrace(hledamMap: map):field; //Zpět vrací souřadnice políčka symbolu hráče v dané mapě, co přichází argumentem.
var
 i,j: integer;
begin
  {nic nenici. Najde hrace a posle jeho souradnice zpet}
  i:=0;
  j:=0;
        while(hledamMap[i,j] <> EndOfMapChar)AND(hledamMap[i,j] <> PlayerChar)AND(hledamMap[i,j]<>PlayerOnTargetPlaceChar) do
           begin
              while(hledamMap[i,j] <> EndOfMapChar)AND(hledamMap[i,j] <> PlayerChar)AND(hledamMap[i,j]<>PlayerOnTargetPlaceChar) do
                 begin
                   j := j+1;
                 end;
              if((hledamMap[i,j] <> PlayerChar)AND(hledamMap[i,j]<>PlayerOnTargetPlaceChar))
              then begin
                  j:=0;
                  i:=i+1;
              end;
        end;
        Result[0] := i;
        Result[1] := j;
end;
function provedKrok(provedMap: map; hrac, smer: field):map; //Provede žádaný krok. Vrací zpět mapu s aktualizovaným krokem.
var
 kam :field;
begin
{pretvori mapu a tu vraci zpatky. Hrace prepise na nove policko. Krabice posunuje.}
   kam[0] := hrac[0] + smer[0];
   kam[1] := hrac[1] + smer[1];
   if(provedMap[hrac[0], hrac[1]] = PlayerChar)
       then provedMap[hrac[0], hrac[1]] := ' '
       else if(provedMap[hrac[0], hrac[1]] = PlayerOnTargetPlaceChar)
            then provedMap[hrac[0], hrac[1]] := TargetPlaceChar;
   if(provedMap[kam[0], kam[1]] = ' ')
       then provedMap[kam[0], kam[1]] := PlayerChar
       else if (provedMap[kam[0], kam[1]] = TargetPlaceChar)
           then provedMap[kam[0], kam[1]] := PlayerOnTargetPlaceChar
           else if(provedMap[kam[0], kam[1]] = BoxChar)
               then begin
                   if(provedMap[kam[0]+smer[0],kam[1]+smer[1]] = TargetPlaceChar)
                     then begin
                         provedMap[kam[0]+smer[0],kam[1]+smer[1]] := BoxOnTargetPlaceChar;
                         provedMap[kam[0], kam[1]] := PlayerChar;
                     end
                     else if(provedMap[kam[0]+smer[0],kam[1]+smer[1]]=' ')
                     then begin
                         provedMap[kam[0]+smer[0],kam[1]+smer[1]] := BoxChar;
                         provedMap[kam[0], kam[1]] := PlayerChar;
                     end;
               end
               else if(provedMap[kam[0], kam[1]] = BoxOnTargetPlaceChar)
               then begin
                   if(provedMap[kam[0]+smer[0],kam[1]+smer[1]] = TargetPlaceChar)
                     then begin
                         provedMap[kam[0]+smer[0],kam[1]+smer[1]] := BoxOnTargetPlaceChar;
                         provedMap[kam[0], kam[1]] := PlayerOnTargetPlaceChar;
                     end
                     else if(provedMap[kam[0]+smer[0],kam[1]+smer[1]]=' ')
                     then begin
                         provedMap[kam[0]+smer[0],kam[1]+smer[1]] := BoxChar;
                         provedMap[kam[0], kam[1]] := PlayerOnTargetPlaceChar;
                     end;
               end;



   Result:=provedMap;

end;
procedure JduToVyhrat(mapaVyhry:map; hrac, smer: field; vrstva:integer); //Rekurzivní procedůra, co projíždí všechny neprohrané a nenaskytlé situace hry pro možné posuny krabic (hráče zatím ignoruje). Po nalezení konečného výherního kroku se zpětně uloží do seznamu kroky(mapy), co k tomuto kroku vedly.
var
 vlastnostKrabic, PvlastnostKrabic : PKrabice;
 mapaVyhryAHrac : map;
begin

   if(mapaVyhry[hrac[0], hrac[1]]=' ')
   then mapaVyhry[hrac[0], hrac[1]]:=PlayerChar
   else if(mapaVyhry[hrac[0], hrac[1]]=TargetPlaceChar)
   then mapaVyhry[hrac[0], hrac[1]]:=PlayerOnTargetPlaceChar;
   mapaVyhryAHrac:=mapaVyhry;

if(vrstva<maxTah)AND(overKrok(mapaVyhry, hrac, smer) AND muzuVyhrat(mapaVyhry) AND (not vyhralJsem)) then
begin
   mapaVyhry:=provedKrok(mapaVyhry, hrac, smer);
   hrac:=najdiHrace(mapaVyhry);


   if(not jeVyhra(mapaVyhry))then
   begin
      mapaVyhry:= oPlayerovac(mapaVyhry, hrac);
      vlastnostKrabic:=KamMuzeKrabice(mapaVyhry);
      PvlastnostKrabic:=vlastnostKrabic;
      mapaVyhry:= odPlayerovac(mapaVyhry, hrac);
      if(mapaVyhry[hrac[0], hrac[1]] = PlayerChar)
      then mapaVyhry[hrac[0], hrac[1]] :=' ';
      if(mapaVyhry[hrac[0], hrac[1]]=PlayerOnTargetPlaceChar)
      then mapaVyhry[hrac[0], hrac[1]]:=TargetPlaceChar;




      if(not uzBylo(PvlastnostKrabic)) then begin
      while(PvlastnostKrabic^.dalsi<>nil)do
         begin
           PvlastnostKrabic:=PvlastnostKrabic^.dalsi;
           if(PvlastnostKrabic^.S)AND(not vyhralJsem)
           then begin
              hrac[0]:= PvlastnostKrabic^.souradnice[0]-1;
              hrac[1]:= PvlastnostKrabic^.souradnice[1];
              smer[0]:= 1;
              smer[1]:= 0;
              JduToVyhrat(mapaVyhry, hrac, smer, vrstva+1);
              end;
           if(PvlastnostKrabic^.J)AND(not vyhralJsem)
           then begin
              hrac[0]:= PvlastnostKrabic^.souradnice[0]+1;
              hrac[1]:= PvlastnostKrabic^.souradnice[1];
              smer[0]:= -1;
              smer[1]:= 0;
              JduToVyhrat(mapaVyhry, hrac, smer, vrstva+1);
              end;
           if(PvlastnostKrabic^.V)AND(not vyhralJsem)
           then begin
              hrac[0]:= PvlastnostKrabic^.souradnice[0];
              hrac[1]:= PvlastnostKrabic^.souradnice[1]+1;
              smer[0]:= 0;
              smer[1]:= -1;
              JduToVyhrat(mapaVyhry, hrac, smer, vrstva+1);
              end;
           if(PvlastnostKrabic^.Z)AND(not vyhralJsem)
           then begin
              hrac[0]:= PvlastnostKrabic^.souradnice[0];
              hrac[1]:= PvlastnostKrabic^.souradnice[1]-1;
              smer[0]:= 0;
              smer[1]:= 1;
              JduToVyhrat(mapaVyhry, hrac, smer, vrstva+1);
           end;
         end;

   end;

   end
   else begin
     mapa:=mapaVyhry;
     vyhralJsem:=true;
     writeln('POCITAC DOSEL DO CILE');
     new(vyhKrok);
     vyhKrok^.dalsi:=nil;
     vyhKrok^.krok:=mapaVyhry;
   end;

end;
if(vyhralJsem)
then zapisujuVyherniKroky(mapaVyhryAHrac);

end;
{-----------------------------------------------------------------------------------------------------------------------}



{ALGORITMUS PRO HLEDANI CESTY MEZI DVOUMA POLICKAMA (DVOUMA STAVAMA POSUNUTI KRABIC - POUZIT A*}
function nejCePrvek(aktualni:PnejkrCesta;x, y:integer):PnejkrCesta; //Vytvoření a charakterizování políčka, aby se dalo zařadit do seznamu "otevřených" políček. Posílá zpět tuto charakteristiku políčka.
var
  prvek:PnejkrCesta;
begin
  new(prvek);
  prvek^.souradnice[0]:=x;
  prvek^.souradnice[1]:=y;
  prvek^.Z:=aktualni;

  Result:=prvek;

end;
function nejCeH(x, y, b, c: integer;mapaHodnotH:valueMap):valueMap; //vypočítá a vrací hodnotu funkce H na základě příchozích informací, pro A*
begin
  if(b<0)then b:=-b;
  if(c<0)then c:=-c;
  mapaHodnotH[x,y]:=b+c;
  Result:=mapaHodnotH;
end;
function nejCeG(x,y, a:integer; mapaHodnotG:valueMap):valueMap; //vypočítá a vrací hodnotu funkce G na základě příchozích informací, pro A*
begin
  mapaHodnotG[x,y] := a + 1;
  Result:=mapaHodnotG;
end;
procedure pridejDoOtevrenych(prvek, otevreny: PnejkrCesta; mapaHodnotH, mapaHodnotG:valueMap;x,y:integer);//přidává říchozí políčko do seznamu políček, ze kterých by ještě mohla vést cesta k cíly, pro A*
var
  Potevreny:PnejkrCesta;
  UkladamCis:integer;
begin
  UkladamCis:=(mapaHodnotG[x,y]+mapaHodnotH[x,y]);
  Potevreny:=otevreny;
  while(Potevreny^.dalsi<>nil)AND (UkladamCis > mapaHodnotG[Potevreny^.dalsi^.souradnice[0], Potevreny^.dalsi^.souradnice[1]]+mapaHodnotH[Potevreny^.dalsi^.souradnice[0], Potevreny^.dalsi^.souradnice[1]])do
     begin
       Potevreny:=Potevreny^.dalsi;
     end;
     while(Potevreny^.dalsi<>nil)AND(mapaHodnotH[x, y]>mapaHodnotH[Potevreny^.dalsi^.souradnice[0], Potevreny^.dalsi^.souradnice[1]])AND(UkladamCis=mapaHodnotG[Potevreny^.dalsi^.souradnice[0], Potevreny^.dalsi^.souradnice[1]]+mapaHodnotH[Potevreny^.dalsi^.souradnice[0], Potevreny^.dalsi^.souradnice[1]])do
       begin
       Potevreny:=Potevreny^.dalsi;
       end;

  if(Potevreny^.dalsi=nil)then
     begin
       Potevreny^.dalsi:=prvek;
       prvek^.dalsi:=nil;
     end else begin
       prvek^.dalsi:=Potevreny^.dalsi;
       Potevreny^.dalsi:=prvek;
     end;
end;
function jeVOtevrenych(x,y:integer;Potevreny:PnejkrCesta):boolean; //zjišťuje, zda je dané políčko v seznamu políček, ze kterých by ještě mohla vést cesta k cíly (otevřených políček), vrací true/false
begin
  Result:=false;
  while(Potevreny^.dalsi<>nil)do
    begin
           if(Potevreny^.souradnice[0]=x)AND(Potevreny^.souradnice[1]=y)
           then Result:=true;
           Potevreny:=Potevreny^.dalsi;
    end;
end;
function oMapujHodnotouH():valueMap; //vrací mapu hodnot, která obsahuje defaultní hodnoty funkce H A* algoritmu
var
  H:valueMap;
  i, j:integer;
begin
  for i:=0 to SizeOfm do
  begin
         for j:=0 to SizeOfn do
         begin
                H[i, j]:=SizeOfm+SizeOfn;
         end;
  end;
  Result:=H;
end;
function oMapujHodnotouG():valueMap; //vrací mapu hodnot, která obsahuje defaultní hodnoty funkce G A* algoritmu
var
  F:valueMap;
  i, j:integer;
begin
  for i:=0 to SizeOfm do
  begin
         for j:=0 to SizeOfn do
         begin
                F[i, j]:=2*(SizeOfm+SizeOfn);
         end;
  end;
  Result:=F;
end;
function nejCePrvekExistujici(x,y :integer; otevreny, aktualni:PnejkrCesta):PnejkrCesta; //Políčko již zaznamenané v seznamu "otevřených" políček A* ze seznamu vyjme a vrací ho zpátky.
var
  Potevreny, prvek:PnejkrCesta;
begin
  Potevreny:=otevreny;
  while(Potevreny^.dalsi^.souradnice[0]<>x)AND(Potevreny^.dalsi^.souradnice[1]<>y)do
    begin
           Potevreny:=Potevreny^.dalsi;
    end;
   prvek:=Potevreny^.dalsi;
   prvek^.Z:=aktualni;
   if(Potevreny^.dalsi^.dalsi<>nil)
   then Potevreny^.dalsi:=Potevreny^.dalsi^.dalsi
   else Potevreny^.dalsi:=nil;
   Result:=prvek;
end;
function nejkratsiCesta(A, B:field; nejceMap:map):PnejkrCesta; //hledá pomocí A* cestu hráče mezi pozicí hráče v n-th posunu krabic a (n+1)th posunu krabic, zpět vrací seznam těchto kroků
var
 otevreny, aktualni, prvek:PnejkrCesta;
 mapaHodnotG, mapaHodnotH:valueMap;
 i,j,AObjevovani,BObjevovani,objevovani:integer;
begin
 new(aktualni);
 new(otevreny);
 otevreny^.souradnice[0]:=0;
 otevreny^.souradnice[1]:=0;
 otevreny^.dalsi:=nil;
 nejceMap:=odPlayerovac(nejceMap, A);
 aktualni^.Z:=nil;
 aktualni^.souradnice[0]:=A[0];
 aktualni^.souradnice[1]:=A[1];
 nejceMap[A[0], A[1]]:=PlayerChar;
 mapaHodnotG:=oMapujHodnotouG();
 mapaHodnotH:=oMapujHodnotouH();
 mapaHodnotG[A[0], A[1]]:=0;
 while(aktualni^.souradnice[0] <> B[0]) OR (aktualni^.souradnice[1] <> B[1])do {než nenajdu druhé p}
   begin
     i:=aktualni^.souradnice[0];
     j:=aktualni^.souradnice[1];


     {objevování nových hodnot}
     for objevovani:=0 to 3 do
     begin
       case objevovani of
           0: begin BObjevovani:=j; AObjevovani:=i-1; end;
           1: AObjevovani:=i+1;
           2: begin AObjevovani:=i; BObjevovani:=j+1; end;
           3: BObjevovani:=j-1;
       end;
       if(mapaHodnotG[AObjevovani, BObjevovani] > mapaHodnotG[i,j] + 1)AND(nejceMap[AObjevovani, BObjevovani]=PlayerChar)then
          begin
             if(jeVOtevrenych(AObjevovani, BObjevovani, otevreny))
             then prvek:=nejCePrvekExistujici(AObjevovani, BObjevovani, otevreny, aktualni);
             mapaHodnotG[AObjevovani, BObjevovani]:= mapaHodnotG[i, j] + 1;
             pridejDoOtevrenych(prvek, otevreny, mapaHodnotH, mapaHodnotG, AObjevovani, BObjevovani);
          end;
       if(nejceMap[AObjevovani, BObjevovani] = ' ') OR (nejceMap[AObjevovani, BObjevovani] = TargetPlaceChar)then{pokud políčko nad aktuálním je ' ' či 'O'}
         begin
           nejceMap[AObjevovani, BObjevovani] := PlayerChar;
           prvek:=nejCePrvek(aktualni, AObjevovani, BObjevovani);
           mapaHodnotH:=nejCeH(prvek^.souradnice[0], prvek^.souradnice[1], B[0]-AObjevovani, B[1]-BObjevovani, mapaHodnotH);
           mapaHodnotG:=nejCeG(prvek^.souradnice[0], prvek^.souradnice[1],mapaHodnotG[i,j], mapaHodnotG);
           pridejDoOtevrenych(prvek, otevreny, mapaHodnotH, mapaHodnotG, prvek^.souradnice[0], prvek^.souradnice[1]);
         end;
     end;



     {Teď musím prohledat všechny směry, zda není nějaká hodnota větší a tu přepsat jak Z tak hodnotu}


     aktualni:=otevreny^.dalsi;
     if(otevreny^.dalsi^.dalsi<>nil)
     then otevreny^.dalsi:=otevreny^.dalsi^.dalsi
     else otevreny^.dalsi:=nil;



   end;
  new(prvek);
  prvek^.Z:=aktualni;
  aktualni:=prvek;

 Result:=aktualni;
end;
{-----------------------------------------------------------------------------------------------------------------------}


{VYPISOVACI/NACITACI PROCEDRUY,FUNKCE}
procedure vypisMapu(vypMap: map); //vypisuje mapu, která mu přijde v argumentu
var
 i, j: integer;
begin
   {vypisuje mapu z prichozi mapy, nijak ji neupravuje}
  i:=0;
  j:=0;
  while(vypMap[i,j] <> EndOfMapChar) do
    begin
      while(vypMap[i,j] <> EndOfMapChar) do
        begin
           write(vypMap[i,j]);
           j := j+1;
        end;
        j:=0;
        i:=i+1;
      writeln();
    end;

end;
function nactiMapu():map; //načte ze souboru mapu, tedy řádky mezi symboly #. To vrací jako hodnotu
var
 i, j: integer;
begin
  readln(f,c);
  read(f,c);
  i:=0;
  j:=0;
  if(c <> '#') then begin
  {cte radky a uklada do pole, dokud nenarazi na novou mapu, na kraj mapy pridava znak #, aby pak rozpoznal konec}
  while(c<>'#')do
    begin

      if(c=#10)
      then begin
          Result[i, j] := EndOfMapChar;
          i:=i+1;
          j:=0;
      end
      else begin
          Result[i, j] := c;
          j:=j+1;

      end;
      read(f,c);
    end;
       Result[i, j] := EndOfMapChar;
   end else
   Result[0,0]:=EndOfMapChar;

end;
procedure chciVypsatPandulaky(pandulaci:PnejkrCesta; mapa:map); //Rekurzivní procedůra, co projede seznam map posunů hráče mezi krabicemi a zpětně vypisuje dané mapy.
begin
   if(pandulaci^.Z<>nil)
     then chciVypsatPandulaky(pandulaci^.Z, mapa);
  mapa:=odPlayerovac(mapa, pandulaci^.souradnice);
  mapa[pandulaci^.souradnice[0], pandulaci^.souradnice[1]] := PlayerChar;
  if((pandulaci^.souradnice[0]<>0)OR(pandulaci^.souradnice[1]<>0))
  then begin
  vypisMapu(mapa);
  ReadKey;
  ClrScr;
  end;
end;
procedure ukazKroky(); //Žádá o vypsání všech výherních kroků (map) (posunů krabic) a ke každým dvoum krokům pohyb hráče mezi změnou krabic.
var
 A, B: field;
 pandulaci:PnejkrCesta;
 mapa:map;
begin
 while(vyhKrok^.dalsi<>nil)AND not (jeVyhra(vyhKrok^.dalsi^.krok))do
   begin
     vyhKrok:=vyhKrok^.dalsi;
     A:=najdiHrace(vyhKrok^.krok);
     B:=najdiHrace(vyhKrok^.dalsi^.krok);
     mapa:=vyhKrok^.dalsi^.krok;
     pandulaci:=nejkratsiCesta(A,B,mapa);
     chciVypsatPandulaky(pandulaci, mapa);

   end;
end;
{-----------------------------------------------------------------------------------------------------------------------}





begin
  Randomize;
  assign(f, 'maps.TXT');
  reset(f);
  mapa := nactiMapu();
  while not(mapa[0,0]=EndOfMapChar) do
    begin

         hrac := najdiHrace(mapa);
         vyhralJsem:=false;


          new(HerniSituace);
          HerniSituace^.dalsi:=nil;
          smer[0]:=0;
          smer[1]:=1;




          while(not overKrok(mapa, hrac, smer))
              do begin
                            smer[0] := Random(3)-1;
                            if(smer[0] = 0)
                            then smer[1] := Random(2)
                            else smer[1] := 0;
                            if(smer[0]=0) AND (smer[1]=0)
                            then smer[1]:= -1;
              end;

         JduToVyhrat(mapa, hrac, smer,0);
         if(vyhralJsem)then
         begin
           writeln('VYHRAVAJICI TAKTIKA:');
           new(HlavaKrok);
           HlavaKrok^.dalsi:=vyhKrok;
           vyhKrok:=HlavaKrok;
           ukazKroky();
         end else
         writeln('Na 150 posunu krabic to vyhrat nejde');
         mapa := nactiMapu();
    end;
  writeln('V PROGRAMU UZ NEJSOU ZADNE DALSI MAPY!!');
  readln();
  close(f);


end.

