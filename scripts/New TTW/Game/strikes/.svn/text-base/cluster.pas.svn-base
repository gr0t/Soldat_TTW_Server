procedure ClusterStrike(Team: byte);
begin
	if Team = 1 then begin
		Teams[Team].Strike.X1 := Bunker[Teams[Team].bunker].X2;
		Teams[Team].Strike.X2 := Bunker[Teams[Team].bunker+1].X1;
	end else begin
		Teams[Team].Strike.X1 := Bunker[Teams[Team].bunker-1].X2;
		Teams[Team].Strike.X2 := Bunker[Teams[Team].bunker].X1;
	end;
	Teams[Team].Strike.Bullets := Trunc(abs(Teams[Team].Strike.X2 - Teams[Team].Strike.X1)*0.001*5); //5 bullets each 600 pixels
end;

procedure ProcessClusterStrike(Team: byte; Ticks: integer);
var
	vec: tVector;
	i: byte;
begin
	if Ticks mod 120 <> 0 then exit; //one bullet for 2 seconds
	if Teams[Team].Strike.Bullets > 0 then begin
		i := 0;
		repeat
			vec.X := RandFlt(Teams[Team].Strike.X1+300, Teams[Team].Strike.X2-300);
			i := i + 1;
		until (abs(vec.X-Teams[Team].Strike.LastBullet.X) > 200) or (i = 20);
		if vec.X = 0 then
			vec.X := Teams[Team].Strike.LastBullet.X+300;
		if vec.X > Teams[Team].Strike.X2-300 then
			vec.X := Teams[Team].Strike.LastBullet.X-300;
		Teams[Team].Strike.LastBullet.X := vec.X;
		vec.Y := (Bunker[Teams[Team].bunker].ReinforcmentY+Bunker[Teams[2/Team].bunker].ReinforcmentY) div 2 - 700;
		vec.t := 1000;
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
