procedure NapalmStrike(Team: byte);
begin
	if Team = 1 then begin
		Teams[Team].Strike.X1 := Bunker[Teams[Team].bunker].X2;
		Teams[Team].Strike.X2 := Bunker[Teams[Team].bunker+1].X1;
	end else begin
		Teams[Team].Strike.X1 := Bunker[Teams[Team].bunker-1].X2;
		Teams[Team].Strike.X2 := Bunker[Teams[Team].bunker].X1;
	end;
	Teams[Team].Strike.Bullets := Trunc(abs(Teams[Team].Strike.X2 - Teams[Team].Strike.X1)*0.003*2); //two bullets each 300 pixels
end;

//sides: 0 = left, 2 = right, 1 = both
procedure Bomb(X, Y, minang, maxang: single; minrange, maxrange: word; burn: boolean; child, team, sides: byte);
var
	i, bul: smallint;
	a, X2, v: single;
	flame: array of tVector;
begin
	bul := (maxrange-minrange) div 20;
	SetArrayLength(flame, bul);
	for i := 0 to bul-1 do begin
		X2 := RandFlt(minrange, maxrange);
		a := RandFlt(minang, maxang);
		
		v := BallisticAim2(X, Y, X+X2, Y, a, 0.06);		
		if sides = 1 then 
			flame[i].vx := cos(a)*v*iif_sint8(RandInt(0, 1) = 1, 1, -1)
		else 
			flame[i].vx := cos(a)*v*(sides-1.0);

		flame[i].vy := -sin(a)*v;
		CreateBullet(X, Y, flame[i].vx, flame[i].vy,100, iif_uint8(i mod 2 = 0, 4, 10), StrikeBot);
		flame[i].t := 600;
		BallisticCast(x, y, 0.06, flame[i]);
		SetArrayLength(Teams[Team].Strike.Area, GetArrayLength(Teams[Team].Strike.Area)+1);
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].X :=  flame[i].X;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].Y :=  flame[i].Y;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].start := GetTickCount()+600-flame[i].t;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].child := child;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].range := iif_uint8(i mod 2 = 0, 30, 20);
	end;
	if burn then
		CreateBurningArea2(flame, 10, StrikeBot);
end;

procedure ProcessNapalmStrike(Team: byte; Ticks: integer);
var
	vec: tVector;
	i: byte;
begin
	if Ticks mod 120 <> 0 then exit; //one bullet for 2 seconds
	if Teams[Team].Strike.Bullets > 0 then begin
		i := 0;
		repeat
			vec.X := RandFlt(Teams[Team].Strike.X1+150, Teams[Team].Strike.X2-150);
			i := i + 1;
		until (abs(vec.X-Teams[Team].Strike.LastBullet.X) > 120) or (i = 20);
		if vec.X = 0 then
			vec.X := Teams[Team].Strike.LastBullet.X+150;
		if vec.X > Teams[Team].Strike.X2-80 then
			vec.X := Teams[Team].Strike.LastBullet.X-150;
		vec.Y := (Bunker[Teams[Team].bunker].ReinforcmentY+Bunker[Teams[2/Team].bunker].ReinforcmentY) div 2 - 700;
		vec.t := 1000;
		Teams[Team].Strike.LastBullet.X := vec.X;
		CreateBullet(vec.X, vec.Y, 0, 0, 100, 4, StrikeBot);
		BallisticCast(vec.X, vec.Y, 0.06, vec);
		SetArrayLength(Teams[Team].Strike.Area, GetArrayLength(Teams[Team].Strike.Area)+1);
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].X :=  vec.X;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].Y :=  vec.Y;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].start :=  Ticks+1000-vec.t;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].child := 1;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].range := 30;
		Teams[Team].Strike.Bullets := Teams[Team].Strike.Bullets - 1;
	end;
end;
