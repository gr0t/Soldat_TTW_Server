procedure AircoStrike(Team: byte);
var
	dist: single;
	vec: tVector;
begin
	if Team = 1 then begin
		Teams[Team].Strike.X1 := Bunker[Teams[Team].bunker].X2;
		Teams[Team].Strike.X2 :=  Bunker[Teams[Team].bunker+1].X1;
	end else begin
		Teams[Team].Strike.X1 := Bunker[Teams[Team].bunker].X1;
		Teams[Team].Strike.X2 :=  Bunker[Teams[Team].bunker-1].X2;
	end;
	Teams[Team].Strike.Y := Bunker[Teams[Team].bunker].ReinforcmentY-700;
	if not RayCast(Teams[Team].Strike.X1, Teams[Team].Strike.Y, Teams[Team].Strike.X1+10*(4/Team-3), Teams[Team].Strike.Y, dist, 11) then begin
		WriteConsole(Radioman[Team].ID, t(128, player[Radioman[Team].ID].translation, 'Sorry, but airco strike can''t be droped here'), BAD);
		Teams[Team].SP := Teams[Team].SP + AIRCOCOST;
		Teams[Team].Strike.CountDown := 0;
		Teams[Team].Strike.InProgress := false;
		exit;
	end;
	
	dist := 0;
	repeat
		vec.x := Teams[Team].Strike.X1 + dist;
		vec.y := Teams[Team].Strike.Y;
		vec.vx := 5*(4/Team-3);
		vec.vy := 0;
		vec.t := 1000;
		BallisticCast(vec.x, vec.y, 0.06, vec);
		dist := dist - 20*(4/Team-3);
	until ((Team = 1) and (vec.x < Teams[Team].Strike.X1)) or ((Team = 2) and (vec.x > Teams[Team].Strike.X1));
	dist := dist + 20*(4/Team-3);
	Teams[Team].Strike.X1 := Teams[Team].Strike.X1 + dist;
	
	dist := 0;
	Teams[Team].Strike.Bullets := Trunc(abs(Teams[Team].Strike.X1-Teams[Team].Strike.X2)*0.025); //calculate to determinate last Y
	repeat
		vec.x := Teams[Team].Strike.X2 + dist;
		vec.y := Teams[Team].Strike.Y-100*Teams[Team].Strike.Bullets;
		vec.vx := 5*(4/Team-3);
		vec.vy := 0;
		vec.t := 1000;
		BallisticCast(vec.x, vec.y, 0.06, vec);
		dist := dist - 20*(4/Team-3);
	until ((Team = 1) and (vec.x < Teams[Team].Strike.X2)) or ((Team = 2) and (vec.x > Teams[Team].Strike.X2));
	Teams[Team].Strike.X2 := Teams[Team].Strike.X2 + dist;
	Teams[Team].Strike.Bullets := Trunc(abs(Teams[Team].Strike.X1-Teams[Team].Strike.X2)*0.025); //one bullet per 40 pixels
end;

procedure ProcessAircoStrike(Team: byte; Ticks: integer);
var
	vec: tVector;
	i: integer;
begin
	if Teams[Team].Strike.Bullets > 0 then begin
		for i := 1 to Teams[Team].strike.Bullets do begin
			vec.X := Teams[Team].Strike.X1+i*40*(4/Team-3);
			vec.Y := Teams[Team].Strike.Y-i*100;
			vec.t := 1000;
			vec.vx := 5*(4/Team-3);
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
		Teams[Team].Strike.Bullets := 0;
	end;
end;
