procedure HammerStrike(Team: byte);
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

procedure ProcessHammerStrike(Team: byte; Ticks: integer);
var
	vec, vec2: tVector;
	X, Y, angle, velocity: Single;
	i: byte;
	range: boolean;
begin
	if Teams[Team].Strike.Bullets > 0 then begin
		if Team = 1 then
		begin
			vec.X := Teams[Team].Strike.X1 - 300;
			X := vec.X - 500;
		end else
		begin
			vec.X := Teams[Team].Strike.X2 + 300;
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
		CreateBullet(X, Y, cos(angle)*velocity*iif(Team = 1, 1, -1), sin(angle)*velocity, 100, 4, StrikeBot);

		SetArrayLength(Teams[Team].Strike.Area, GetArrayLength(Teams[Team].Strike.Area)+1);
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].X :=  vec.X;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].Y :=  vec.Y;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].start :=  Ticks+1000-vec.t;
		Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].child := 1;
		if Team = 1 then
			Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].range := 2
		else Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].range := 0;
		Teams[Team].Strike.Bullets := 0;
	end;
end;