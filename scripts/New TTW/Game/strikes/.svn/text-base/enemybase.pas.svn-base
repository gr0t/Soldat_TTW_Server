procedure EnemyBaseStrike(Team: byte);
begin
	if Team = 1 then begin
		Teams[Team].Strike.X1 := Bunker[Teams[Team].bunker+1].X1;
		Teams[Team].Strike.X2 := Bunker[Teams[Team].bunker+1].X2;
	end else begin
		Teams[Team].Strike.X1 := Bunker[Teams[Team].bunker-1].X1;
		Teams[Team].Strike.X2 := Bunker[Teams[Team].bunker-1].X2;
	end;
	Teams[Team].Strike.Bullets := Trunc(abs(Teams[Team].Strike.X2 - Teams[Team].Strike.X1)*0.02); //one bullet each 50 pixels
end;

procedure ProcessEnemyBaseStrike(Team: byte; Ticks: integer);
var
	vec: tVector;
	i: integer;
	leng: integer;
begin
	if Teams[Team].Strike.Bullets > 0 then begin
		for i := 1 to Teams[Team].Strike.Bullets do begin
			if Team = 1 then
				vec.X := Teams[Team].Strike.X1+(i-1)*50
			else
				vec.X := Teams[Team].Strike.X2-(i-1)*50;
			vec.Y := Bunker[Teams[Team].bunker+iif_sint8(Team = 1, 1, -1)].ReinforcmentY - 500 - i*100;
			vec.t := 2000;
			CreateBullet(vec.X, vec.Y, 0, 0, 100, 4, StrikeBot);
			BallisticCast(vec.X, vec.Y, 0.06, vec);
			leng := GetArrayLength(Teams[Team].Strike.Area);
			SetArrayLength(Teams[Team].Strike.Area, leng + 1);
			Teams[Team].Strike.Area[leng].X :=  vec.X;
			Teams[Team].Strike.Area[leng].Y :=  vec.Y;
			Teams[Team].Strike.Area[leng].start :=  Ticks+2000-vec.t;
			Teams[Team].Strike.Area[leng].child := 0;
			Teams[Team].Strike.Area[leng].range := 30;
		end;
		Teams[Team].Strike.Bullets := 0;
	end;
end;