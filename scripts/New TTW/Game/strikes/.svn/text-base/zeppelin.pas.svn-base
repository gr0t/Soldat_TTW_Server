procedure ZeppelinStrike(Team: byte);
begin
	if Team = 1 then begin
		Teams[Team].Strike.X1 := Bunker[Teams[Team].bunker].X2+20;
		Teams[Team].Strike.X2 := Bunker[Teams[Team].bunker+1].X1-20;
	end else begin
		Teams[Team].Strike.X1 := Bunker[Teams[Team].bunker].X1-20;
		Teams[Team].Strike.X2 := Bunker[Teams[Team].bunker-1].X2+20;
	end;
	Teams[Team].Strike.Y := Bunker[Teams[Team].bunker].ReinforcmentY-700;
	Teams[Team].Strike.Bullets := Trunc(abs(Teams[Team].Strike.X2 - Teams[Team].Strike.X1)*0.02); //one (two in fact) bullet each 50 pixels
	Teams[Team].Strike.LastBullet.X := Teams[Team].Strike.Bullets; //for loop
end;

procedure ProcessZeppelinStrike(Team: byte; Ticks: integer);
var
	vec: tVector;
	i: integer;
begin
	if Teams[Team].Strike.Bullets > 0 then begin
		if Teams[Team].Strike.Bullets mod 2 = 0 then
			for i := 0 to 1 do begin
				vec.X := Teams[Team].Strike.X1+(Teams[Team].Strike.LastBullet.X-Teams[Team].Strike.Bullets)*50*(4/Team-3)+i*40*(4/Team-3);
				vec.Y := Teams[Team].Strike.Y-i*100;
				vec.t := 1000;
				vec.vx := 0;
				vec.vy := 0;
				CreateBullet(vec.X, vec.Y, vec.vx, vec.vy, 100, 4, StrikeBot);
				BallisticCast(vec.X, vec.Y, 0.06, vec);
				SetArrayLength(Teams[Team].Strike.Area, GetArrayLength(Teams[Team].Strike.Area)+1);
				Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].X :=  vec.X;
				Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].Y :=  vec.Y;
				Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].start :=  Ticks+1000-vec.t;
				Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].child := 0;
				Teams[Team].Strike.Area[GetArrayLength(Teams[Team].Strike.Area)-1].range := 30;
			end;
		Teams[Team].Strike.Bullets := Teams[Team].Strike.Bullets - 1;
	end;
end;