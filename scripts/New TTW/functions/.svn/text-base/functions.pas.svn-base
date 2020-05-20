//Explode function by CurryWurst & DorkeyDear
function Explode(Source: string; const Delimiter: string): array of string;
var
  Position, DelLength, ResLength: integer;
begin
  DelLength := Length(Delimiter);
  Source := Source + Delimiter;
  repeat
    Position := Pos(Delimiter, Source);
    SetArrayLength(Result, ResLength + 1);
    Result[ResLength] := Copy(Source, 1, Position - 1);
    ResLength := ResLength + 1;
    Delete(Source, 1, Position + DelLength - 1);
  until (Position = 0);
  SetArrayLength(Result, ResLength - 1);
end;	

function RayCast2(vx, vy: single; range: word; var x, y: single): boolean;
var n: byte; rd,d,x2,y2: single; d2: word;
begin
	d:=Sqrt(vx*vx + vy*vy);
	x2 := x; y2 := y;
	d2 := Trunc(d + 1);
	n := Trunc(1 + range/d);
	while n >= 1 do begin
		n := n - 1;
		x2 := x2 + vx; y2 := y2 + vy;
//		CreateBulletX(x2,y2,0,0,0,5,1);
		if not RayCast(x, y, x2, y2, rd, d2) then
			exit;
		x := x2; y := y2;
	end;
	Result := true;
end;

procedure WriteMessage(ID: byte; Text: string; Color: longint);
begin
	if ID <= 32 then WriteConsole(ID, Text, Color)
	else WriteLn(Text);
end;

procedure Debug(Level: byte; Message: string);
begin
	if Level <= DEBUGLEVEL then WriteLn('<'+ScriptName+'> '+Message);
end;

procedure CountMaxID();
begin
	for MaxID := 32 downto 1 do
		if player[MaxID].active then
			break;
end;

function GetNumPlayers(): byte;
var
	i: byte;
begin
Result := 0;
	for i := 1 to MaxID do
		if player[i].Active then
			if player[i].human then
				Result := Result + 1;
	//Result := NumPlayers - NumBots; says 1 in OnLeaveGame
end;

function SqrDist(X, Y, X2, Y2: single): single;
begin
	X2 := X2 - X;
	Y2 := Y2 - Y; 
	Result := X2 * X2 + Y2 * Y2;
end;

function sign(x: single): shortint;
begin
	if x > 0 then Result := 1 else
	if x < 0 then Result := -1 else
	Result := 0;
end;

function IsInRange(X, Y, X2, Y2: Single; Range: Integer): Boolean;
begin
	X:=X-X2; Y:=Y-Y2;
	Result:=X*X+Y*Y<=Range*Range;
end;

function IsBetween(X1, X2, X3: single): boolean;
begin
	Result := (X3 > X1) and (X3 < X2);
end;

procedure SetTeam(ID, Team: byte; ServerSet: boolean);
begin
	ServerSetTeam := ServerSet;
	Command('/setteam'+IntToStr(Team)+' '+IntToStr(ID));
end;

function GiveHealth( ID, health: smallint): boolean;
begin
	if GetPlayerStat(ID,'Health') + health <= MaxHP then 
		DoDamageBy(ID, ID, -health)
	else begin
		Result:=true;
		DoDamageBy(ID, ID, GetPlayerStat(ID,'Health') - MaxHP);
	end;
end;

function weap2menu(num: byte): byte;
begin
  case num of
    0: Result := 11;
	11: Result := 15;
    14: Result := 12;
    15: Result := 13;
    16: Result := 14;
    255: Result := 0;
    else if num < 14 then Result := num else Result := 0;
  end;
end;

function menu2weap(num: byte): byte;
begin
  case num of
    11: Result := 0;
    12: Result := 14;
    13: Result := 15;
    14: Result := 16;
	15: Result := 11; // flamer
    0:  Result := 255;
    else Result := num;
  end;
end;

function absi(x: shortint): byte;
begin
	if x >= 0 then Result := x else Result := -x;
end;

function ToRange(min, x, max: integer): integer;
begin
	if x < min then Result:=min else
		if x > max then Result:=max else
			Result:=x;
end;

function ToRangeFlt(min, x, max: single): single;
begin
	if x < min then Result:=min else
		if x > max then Result:=max else
			Result:=x;
end;

function arccos(X: double): double;
begin
  Result := ANGLE_90 - arctan(X / sqrt(1 - X*X));
end;

// angle between two vectors
function abv(v1x, v1y, v2x, v2y: single): single;
begin
	Result:=arccos((v1x*v2x + v1y*v2y) / Sqrt((v1x*v1x + v1y*v1y)*(v2x*v2x + v2y*v2y)));
end;

procedure incB(var n: byte; k: smallint);
begin
	n := n + k;
end;

procedure incW(var n: word; k: smallint);
begin
	n := n + k;
end;
