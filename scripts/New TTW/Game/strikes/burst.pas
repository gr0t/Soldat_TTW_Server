procedure BurstStrike(Team: byte);
begin
	if Team = 1 then begin
		Teams[Team].Strike.X1 := Bunker[Teams[Team].bunker+1].X1;
		Teams[Team].Strike.X2 := Bunker[Teams[Team].bunker+1].X2;
	end else begin
		Teams[Team].Strike.X1 := Bunker[Teams[Team].bunker-1].X1;
		Teams[Team].Strike.X2 := Bunker[Teams[Team].bunker-1].X2;
	end;
	Teams[Team].Strike.Bullets := 1;
end;

//sides: 0 = left, 2 = right, 1 = both
procedure Bomb2(X, Y, minang, maxang: single; minrange, maxrange: word; burn: boolean; child, team, sides: byte);
var
	i, bul: smallint;
	a, X2, v: single;
	flame: array of tVector;
begin
	bul := 25;//(maxrange-minrange) div 20;
	SetArrayLength(flame, bul);
	a := minang;
	X2 := minrange;
	for i := 0 to bul-1 do begin
		X2 := X2 + (maxrange-minrange)/25;//
		a := RandFlt(minang, maxang);
		
		v := BallisticAim2(X, Y, X+X2, Y, a, 0.06);		
		v := v * (0.6*a+0.33);		
		if sides = 1 then 
			flame[i].vx := cos(a)*v*iif_sint8(RandInt(0, 1) = 1, 1, -1)
		else 
			flame[i].vx := cos(a)*v*(sides-1.0);

		flame[i].vy := -sin(a)*v;
		CreateBullet(X, Y, flame[i].vx, flame[i].vy,150, 10, StrikeBot);
		flame[i].t := 600;
		BallisticCast(x, y, 0.06, flame[i]);
		SetArrayLength(Teams[Team].Strike.Area, GetArrayLength(Teams[Team].Strike.Area)+1);
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].X :=  flame[i].X;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].Y :=  flame[i].Y;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].start := GetTickCount()+600-flame[i].t;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].child := child;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].range := 40;
	end;
	if burn then
		CreateBurningArea2(flame, 10, StrikeBot);
end;

procedure ProcessBurstStrike(Team: byte; Ticks: integer);
var
	vec, vec2: tVector;
	X, Y, angle, velocity: Single;
begin
	if Teams[Team].Strike.Bullets > 0 then begin
		if Team = 1 then
		begin
			vec.X := Teams[Team].Strike.X1 - 200;
			X := vec.X - 500;
		end else
		begin
			vec.X := Teams[Team].Strike.X2 + 200;
			X := vec.X + 500;
		end;

		Y := (Bunker[Teams[Team].bunker].ReinforcmentY+Bunker[Teams[2/Team].bunker].ReinforcmentY)/2 - 500;
		angle := ANG_PI/4;
		velocity := 13;
		vec2.vX := cos(angle)*velocity*iif(Team = 1, 1, -1);
		vec2.vY := sin(angle)*velocity;
		vec2.t := 1000;
		BallisticCast(X, Y, 0.06, vec2);
		
		//Correct the spawnplace
		X := X - (vec2.X - vec.X);
		
		//Find out at which Y coordinate it'll land
		vec.Y := Y;
		vec.t := 1000;
		vec.vx := 0;
		vec.vy := 0;		
		BallisticCast(vec.X, vec.Y, 0.06, vec);
		CreateBullet(X, Y, cos(angle)*velocity*iif(Team = 1, 1, -1), sin(angle)*velocity, 150, 4, StrikeBot);
		SetArrayLength(Teams[Team].Strike.Area, GetArrayLength(Teams[Team].Strike.Area)+1);
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].X :=  vec.X;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].Y :=  vec.Y;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].start :=  Ticks+955-vec.t;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].child := 1;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].range := 30;
		Teams[Team].Strike.Bullets := 0;
	end;
end;