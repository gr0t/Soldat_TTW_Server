procedure DestroyMine(MineID: byte; blow: boolean);
var
	i, j: byte;
begin
	//Must be marked as blown here to avoid recursive DestroyMine() calls
	Mines[MineID].placed := false;
	if blow then begin
		CreateBullet(Mines[MineID].X, Mines[MineID].Y - 19, 0, 0, 99,4, Mines[MineID].owner );
		CreateBullet(Mines[MineID].X + 19, Mines[MineID].Y - 5, 0, 0, 99, 4, Mines[MineID].owner );
		CreateBullet(Mines[MineID].X - 19, Mines[MineID].Y + 5, 0, 0, 99, 4, Mines[MineID].owner);
		CreateBullet(Mines[MineID].X + RandInt(-24,24), Mines[MineID].Y - RandInt(8,16), 0, 0, 99, 4, Mines[MineID].owner);
		
		i := GetStatgunAt(Mines[MineID].X, Mines[MineID].Y, 70);
		if i > 0 then begin
			DestroyStat(i);
			SendToLive('rigsg '+inttostr(i));
			Teams[i].StatgunRefreshTimer := STATGUN_COOLDOWN_TIME;
			if GetArrayLength(Teams[i].member) > 0 then
				for j := 0 to GetArrayLength(Teams[i].member)-1 do
					WriteConsole(Teams[i].member[j], t(122, player[Teams[i].member[j]].translation, 'Your team''s statgun has been destroyed!'), BAD);
			i := 2/i;
			if GetArrayLength(Teams[i].member) > 0 then
				for j := 0 to GetArrayLength(Teams[i].member)-1 do
					WriteConsole(Teams[i].member[j], t(123, player[Teams[i].member[j]].translation, 'Mine destroyed enemy statgun!'), GOOD);
		end;
		for i := 1 to MAXMINES do
			if Mines[i].placed then
				if i <> MineID then
					if IsInRange(Mines[MineID].X, Mines[MineID].Y, Mines[i].X, Mines[i].Y, 70) then
						DestroyMine(i, true);
	end;
	Teams[player[Mines[MineID].owner].team].MinesPlaced := Teams[player[Mines[MineID].owner].team].MinesPlaced - 1;
	Teams[Player[Mines[MineID].Owner].Team].MinesRefreshTimer := MINES_REFRESH_TIME;
	Mines[MineID].Owner := 0;
	Mines[MineID].X := 0;
	Mines[MineID].Y := 0;
end;

procedure CreateMine(X, Y: Single; Owner: Byte);
var i: byte;
begin
	for i := 1 to MAXMINES do
		if not Mines[i].Placed then break;

	Mines[i].X := X;
	Mines[i].Y := Y;
	Mines[i].Y := Mines[i].Y - 4;
	Mines[i].owner := Owner;
	Mines[i].Placed := True;
	Mines[i].Timer := MINES_ACTIVATE_TIME * 2;
end;

procedure ResetMines();
var i: byte;
begin
	for i := 1 to MAXMINES do
		if Mines[i].placed then
			DestroyMine(i, false);
end;

procedure TickMines(fullTick: boolean);
var i, j: byte; x, y, v1x, v1y, v2x, v2y, a: single; r: word;
begin
	for i := 1 to MAXMINES do
		if Mines[i].placed then
			if Mines[i].Timer < 1 then
			begin	
				//Sign Mines
				if fullTick then
					if TimeLeft mod 5 = i mod 5 then
						CreateBullet(Mines[i].X, Mines[i].Y, 0, 0, 0, 7, Mines[i].Owner);

				//Blow Mines
				for j := 1 to MaxID do
				begin
					if (player[j].Alive) and (not player[j].JustResp) then
					begin
						GetPlayerXY(j, x, y);
						v2x:=mines[i].X-x;
						if Abs(v2x) <= MRMAX * 2 then 
						begin
							v2y:=mines[i].Y-2-y;
							if Abs(v2y) <= MRMAX * 2 then
							begin
								v1y:=GetPlayerStat(j, 'VELY');
								v1x:=GetPlayerStat(j, 'VELX');
								r:=ToRange(MRMIN, Round(Sqrt(v1x*v1x + v1y*v1y)*SRFACTOR), MRMAX);
								if IsInRange(X, Y, mines[i].X + v1x*PSFACTOR * r / MRMAX, mines[i].Y + v1y*PSFACTOR * r / MRMAX, r) then 
								begin
									if r > MRMIN+5 then 
									begin
										// calculate angle between vectors
										a:=abv(v1x, v1y, v2x, v2y);
										if a>ANGLE_90 then a:=pi-a;
										if a > MAXANGLE then
											continue;
									end;									
									if j <> Mines[i].Owner then
									begin
										WriteConsole(Mines[i].owner, IDToName(j) + +' '+ t(124, Player[Mines[i].Owner].Translation, 'stepped into your mine!'), GOOD );
										WriteConsole(j, t(125, Player[j].Translation, 'You stepped into a mine!'), BAD);
									end else WriteConsole(Mines[i].Owner, t(126, Player[Mines[i].Owner].Translation, 'You stepped on your own mine!'), BAD);
									DestroyMine(i, true);
									break;
								end;
							end;
						end;
					end;	
				end;		
			end else if fullTick then Mines[i].Timer := Mines[i].Timer - 1;
	//Give new mines
	if fullTick then
	for i := 1 to 2 do
		if (Teams[i].MinesPlaced + Teams[i].Mines) < (MAXMINES / 2) then 
			if Teams[i].MinesRefreshTimer > 0 then
			begin
				Teams[i].MinesRefreshTimer := Teams[i].MinesRefreshTimer - 1;
				if Teams[i].MinesRefreshTimer = 0 then
				begin
					Teams[i].Mines := Teams[i].Mines + 1;
					Teams[i].MinesRefreshTimer := MINES_REFRESH_TIME;
					If Engineer[i].ID > 0 then
						WriteConsole(Engineer[i].ID, t(127, Player[Engineer[i].ID].Translation, '+1 Mine ready to be placed!'), GOOD)
					else if GetArrayLength(Teams[i].member) > 0 then
						for r := 0 to GetArrayLength(Teams[i].member)-1 do
							WriteConsole(Teams[i].member[r], t(127, Player[Teams[i].member[r]].Translation, '+1 Mine ready to be placed!'), GOOD);
				end;
			end;
end;
