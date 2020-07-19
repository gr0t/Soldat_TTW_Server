procedure CalculateCosts(Gather: boolean);
begin
	if Gather then begin
		ZEPPELINCOST := 5;
		AIRCOCOST := 7;
		BARRAGECOST := 9;
		NAPALMCOST := 5;
		CLUSTERSTRIKECOST := 7;
		HOWITZERCOST := 6;
		ENEMYBASECOST := 5;
		BURSTCOST := 3;
		GRENADECOST := 1;
		CLUSTERCOST := 1;
		MEDICOST := 1;
		VESTCOST := 12;
		LAWCOST := 2;
		PARATROOPERCOST := 9;
		DESTROYSGCOST := 4;
		HACCOST := 4;
		FLAMERCOST := 2;
	end else begin
		AIRCOCOST := 9;
		ZEPPELINCOST := 8;
		BARRAGECOST := 11;
		HOWITZERCOST := 8;
		NAPALMCOST := 10;
		CLUSTERSTRIKECOST := 9;
		GRENADECOST := 1;
		CLUSTERCOST := 2;
		MEDICOST := 1;
		VESTCOST := 8;
		LAWCOST := 3;
		PARATROOPERCOST := 9;
		DESTROYSGCOST := 4;
		ENEMYBASECOST := 6;
		BURSTCOST := 7;
		HACCOST := 	5;
		FLAMERCOST := 3;
	end;
end;

procedure ResetParatrooper(Team: byte);
begin
	if Paratrooper[Team] = 0 then
		exit;
	if player[Paratrooper[Team]].active then begin
		if player[Paratrooper[Team]].human then begin
			if (GetPlayerStat(Paratrooper[Team], 'team') <> 5) then
				SetTeam(Paratrooper[Team], 5, true)
		end else
			KickPlayer(Paratrooper[Team]);
	end;

	Paratrooper[Team] := 0;
end;

procedure TapSupply(Team: byte;  Item: (_vest, _vestgen, _law, _grenade, _medi, _cluster, _hac, _para, _enemybase, _napalm, _rocket, _barrage, _zeppelin, _airco, _clusterstr, _burst, _flamer));
var
	i: byte;
begin
	if Pause then exit;
	if Radioman[Team].TapCounter >= 0 then
		exit;
	for i := 0 to GetArrayLength(Teams[Team].member)-1 do begin
		case Item of
			_vest: WriteConsole(Teams[Team].member[i], t(194, player[Teams[Team].member[i]].translation, 'Enemy radioman orders vest'), TAPCOLOUR);
			_vestgen: WriteConsole(Teams[Team].member[i], t(195, player[Teams[Team].member[i]].translation, 'Enemy radioman orders vest for the general'), TAPCOLOUR);
			_law: WriteConsole(Teams[Team].member[i], t(196, player[Teams[Team].member[i]].translation, 'Enemy radioman orders laws'), TAPCOLOUR);
			_grenade: WriteConsole(Teams[Team].member[i], t(197, player[Teams[Team].member[i]].translation, 'Enemy radioman orders grenades'), TAPCOLOUR);
			_medi: WriteConsole(Teams[Team].member[i], t(198, player[Teams[Team].member[i]].translation, 'Enemy radioman orders medkit'), TAPCOLOUR);
			_cluster: WriteConsole(Teams[Team].member[i], t(199, player[Teams[Team].member[i]].translation, 'Enemy radioman orders cluster grenades'), TAPCOLOUR);
			_hac: WriteConsole(Teams[Team].member[i], t(200, player[Teams[Team].member[i]].translation, 'Enemy radioman orders heavy artillery cannon'), TAPCOLOUR);
			_para: WriteConsole(Teams[Team].member[i], t(201, player[Teams[Team].member[i]].translation, 'Enemy radioman orders Paratropper'), TAPCOLOUR);

			_enemybase: WriteConsole(Teams[Team].member[i], t(202, player[Teams[Team].member[i]].translation, 'Enemy radioman calls airstrike on your bunker'), TAPCOLOUR);
			_napalm: WriteConsole(Teams[Team].member[i], t(203, player[Teams[Team].member[i]].translation, 'Enemy radioman calls napalm strike'), TAPCOLOUR);
			_rocket: WriteConsole(Teams[Team].member[i], t(204, player[Teams[Team].member[i]].translation, 'Enemy radioman calls nuke strike'), TAPCOLOUR);
			_barrage: WriteConsole(Teams[Team].member[i], t(205, player[Teams[Team].member[i]].translation, 'Enemy radioman calls mortar barrage'), TAPCOLOUR);
			_zeppelin: WriteConsole(Teams[Team].member[i], t(206, player[Teams[Team].member[i]].translation, 'Enemy radioman calls zeppelin strike'), TAPCOLOUR);
			_airco: WriteConsole(Teams[Team].member[i], t(207, player[Teams[Team].member[i]].translation, 'Enemy radioman calls airco strike'), TAPCOLOUR);
			_clusterstr: WriteConsole(Teams[Team].member[i], t(208, player[Teams[Team].member[i]].translation, 'Enemy radioman calls cluster strike'), TAPCOLOUR);
			_burst: WriteConsole(Teams[Team].member[i], t(209, player[Teams[Team].member[i]].translation, 'Enemy radioman calls burst strike'), TAPCOLOUR);
			_flamer: WriteConsole(Teams[Team].member[i], t(0, player[Teams[Team].member[i]].translation, 'Enemy radioman orders flamer'), TAPCOLOUR);
		end;
		WriteConsole(Teams[Team].member[i], t(210, player[Teams[Team].member[i]].translation, 'Supply points left')+': '+IntToStr(Teams[2/Team].SP), TAPCOLOUR);
	end;
end;

procedure TryBuyOperation(Team: byte; Item: (_vest, _vestgen, _law, _grenade, _medi, _cluster, _hac, _para, _enemybase, _napalm, _nuke, _barrage, _zeppelin, _airco, _clusterstr, _burst, _flamer));
var
	i: byte;
	b, a: boolean;
begin
	if not player[Radioman[Team].ID].alive then begin
		WriteConsole(Radioman[Team].ID, t(211, player[Radioman[Team].ID].translation, 'You have to be alive to order supplies'), BAD);
		exit;
	end;
	b := false;
	case Item of
		_vest: begin
			if Teams[Team].SP >= VESTCOST then begin
				Spawnobject(Bunker[Teams[Team].bunker].ReinforcmentX, Bunker[Teams[Team].bunker].ReinforcmentY, 19)
				Teams[Team].SP := Teams[Team].SP - VESTCOST;

				for i := 0 to GetArrayLength(Teams[Team].member)-1 do
					WriteConsole(Teams[Team].member[i], t(212, player[Teams[Team].member[i]].translation, 'Vest delivered to your team base!'), GOOD);

				b := true;
				SendToLive('sup_vest '+inttostr(Team));
			end;
		end;
		_vestgen: begin
			if Teams[Team].SP >= VESTCOST then begin
				if General[Team].ID > 0 then begin
					if player[General[Team].ID].alive then begin
						GetPlayerXY(General[Team].ID, player[General[Team].ID].X, player[General[Team].ID].Y)
						if IsBetween(Bunker[Teams[Team].bunker].X1, Bunker[Teams[Team].bunker].X2, player[General[Team].ID].X) then
						begin
							GiveBonus(General[Team].ID, 3)
							for i := 0 to GetArrayLength(Teams[Team].member)-1 do
								WriteConsole(Teams[Team].member[i], t(213, player[Teams[Team].member[i]].translation, 'Vest delivered to your general!'), GOOD);
						end	else begin
							WriteConsole(Radioman[Team].ID, t(214, player[Radioman[Team].ID].translation, 'No general in the bunker!'), BAD);
							exit;
						end;
					end else begin
						WriteConsole(Radioman[Team].ID, t(215, player[Radioman[Team].ID].translation, 'The general is already dead!'), BAD);
						exit;
					end;
				end else begin
					WriteConsole(Radioman[Team].ID, t(216, player[Radioman[Team].ID].translation, 'Your team has no general'), BAD);
					exit;
				end;
				Teams[Team].SP := Teams[Team].SP - VESTCOST;
				b := true;
				SendToLive('sup_vestgen '+inttostr(Team));
			end;
		end;
		_law: begin
			if Teams[Team].SP >= LAWCOST then begin
				for i := 1 to LAWNUMBER do Spawnobject(Bunker[Teams[Team].bunker].ReinforcmentX-Trunc(i-0.5*LAWNUMBER)*5, Bunker[Teams[Team].bunker].ReinforcmentY, 14);
				Teams[Team].SP := Teams[Team].SP - LAWCOST;

				for i := 0 to GetArrayLength(Teams[Team].member)-1 do
					WriteConsole(Teams[Team].member[i], t(217, player[Teams[Team].member[i]].translation, 'Laws delivered to your team base!'), GOOD);
				b := true;
				SendToLive('sup_law '+inttostr(Team));
			end;
		end;
		_grenade: begin
			if Teams[Team].SP >= GRENADECOST then begin
				SpawnKit(Bunker[Teams[Team].bunker].ReinforcmentX, Bunker[Teams[Team].bunker].ReinforcmentY, 17);
				Teams[Team].SP := Teams[Team].SP - GRENADECOST;

				for i := 0 to GetArrayLength(Teams[Team].member)-1 do
					WriteConsole(Teams[Team].member[i], t(218, player[Teams[Team].member[i]].translation, 'Grenades delivered to your team base!'), GOOD);
				b := true;
				SendToLive('sup_nade ' + inttostr(Team));
			end;
		end;
		_medi: begin
			if Teams[Team].SP >= MEDICOST then begin
				SpawnKit(Bunker[Teams[Team].bunker].ReinforcmentX, Bunker[Teams[Team].bunker].ReinforcmentY, 16);
				Teams[Team].SP := Teams[Team].SP - MEDICOST;

				for i := 0 to GetArrayLength(Teams[Team].member)-1 do
					WriteConsole(Teams[Team].member[i], t(219, player[Teams[Team].member[i]].translation, 'Medikit delivered to your team base!'), GOOD);
				b := true;
				SendToLive('sup_medi ' + inttostr(Team));
			end;
		end;
		_cluster: begin
			if Teams[Team].SP >= CLUSTERCOST then begin
				Spawnobject(Bunker[Teams[Team].bunker].ReinforcmentX, Bunker[Teams[Team].bunker].ReinforcmentY, 22);
				Teams[Team].SP := Teams[Team].SP - CLUSTERCOST;

				for i := 0 to GetArrayLength(Teams[Team].member)-1 do
					WriteConsole(Teams[Team].member[i], t(220, player[Teams[Team].member[i]].translation, 'Cluster grenades delivered to your team base!'), GOOD);
				b := true;
				SendToLive('sup_cluster '+inttostr(Team));
			end;
		end;
		_hac: begin
			if Teams[Team].SP >= HACCOST then begin
				if Artillery[Team].ID > 0 then begin
					if player[Artillery[Team].ID].alive then begin
						Player[Artillery[Team].ID].JustResp := False;
						ForceWeapon(Artillery[Team].ID, 10, GetPlayerStat(Artillery[Team].ID, 'Secondary'), 9);
						WriteConsole(Radioman[Team].ID, t(221, player[Radioman[Team].ID].translation, 'HAC delivered to Artillery!'), GOOD);
						WriteConsole(Artillery[Team].ID, t(222, player[Artillery[Team].ID].translation, 'You''ve recieved HAC-25, BE CAREFUL'), GOOD);
					end else begin
						Player[Radioman[Team].ID].JustResp := False;
						ForceWeapon(Radioman[Team].ID, 10, GetPlayerStat(Radioman[Team].ID, 'Secondary'), 9);
						WriteConsole(Radioman[Team].ID, t(222, player[Radioman[Team].ID].translation, 'You''ve recieved HAC-25, BE CAREFUL'), GOOD);
					end;
				end else begin
					Player[Radioman[Team].ID].JustResp := False;
					ForceWeapon(Radioman[Team].ID, 10, GetPlayerStat(Radioman[Team].ID, 'Secondary'), 9);
					WriteConsole(Radioman[Team].ID, t(222, player[Radioman[Team].ID].translation, 'You''ve recieved HAC-25, BE CAREFUL'), GOOD);
				end;
				Teams[Team].SP := Teams[Team].SP - HACCOST;
				b := true;
				SendToLive('sup_hac ' + inttostr(Team));
			end;
		end;
		_flamer: begin
			if Teams[Team].SP >= FLAMERCOST then begin
				if Engineer[Team].ID > 0 then begin
					if player[Engineer[Team].ID].alive then
					begin
						GetPlayerXY(Engineer[Team].ID, player[Engineer[Team].ID].X, player[Engineer[Team].ID].Y)
						if IsBetween(Bunker[Teams[Team].bunker].X1, Bunker[Teams[Team].bunker].X2, player[Engineer[Team].ID].X) then
						begin
							Player[Engineer[Team].ID].JustResp := False;
							ForceWeapon(Engineer[Team].ID, 11, GetPlayerStat(Engineer[Team].ID, 'Secondary'), 98);
							WriteConsole(Radioman[Team].ID, t(0, player[Radioman[Team].ID].translation, 'Flamer delivered to Engineer!'), GOOD);
							WriteConsole(Engineer[Team].ID, t(0, player[Engineer[Team].ID].translation, 'You''ve recieved the Flamethrower M2A1-2!'), GOOD);
						end else a := true;
					end else a := true;
				end else a := true;

				if a then
				begin
					GetPlayerXY(Radioman[Team].ID, player[Radioman[Team].ID].X, player[Radioman[Team].ID].Y)
					if IsBetween(Bunker[Teams[Team].bunker].X1, Bunker[Teams[Team].bunker].X2, player[Radioman[Team].ID].X) then
					begin
						Player[Radioman[Team].ID].JustResp := False;
						ForceWeapon(Radioman[Team].ID, 11, GetPlayerStat(Radioman[Team].ID, 'Secondary'), 98);
						WriteConsole(Radioman[Team].ID, t(0, player[Radioman[Team].ID].translation, 'You''ve recieved the Flamethrower M2A1-2'), GOOD);
					end else
					begin
						WriteConsole(Radioman[Team].ID, t(0, player[Radioman[Team].ID].translation, 'You or the engineer must be in the bunker!'), BAD);
						exit;
					end;
				end;

				Teams[Team].SP := Teams[Team].SP - FLAMERCOST;
				b := true;
				SendToLive('sup_flamer ' + inttostr(Team));
			end;
		end;
		_para: begin
			if Teams[Team].SP >= PARATROOPERCOST then begin
				if Paratrooper[Team] = 0 then begin
					i := Teams[Team].bunker+iif_sint8(Team = 1, 1, -1);
					if i = 0 then
						i := i + 1
					else if i = GetArrayLength(Bunker)-1 then
						i := i - 1;
					Paratrooper[Team] := FindParatrooper();
					if Paratrooper[Team] = 0 then begin
						Paratrooper[Team] := PutBot((Bunker[i].X1+Bunker[i].X2)/2, Bunker[i].ReinforcmentY-PARA_SPAWN_HEIGHT, BOTNAME, Team)
						GiveBonus(paratrooper[Team], 3);
						ForceWeapon(paratrooper[Team], 9, 0, 50);
					end else
						PutParatrooper((Bunker[i].X1+Bunker[i].X2)/2, Bunker[i].ReinforcmentY-PARA_SPAWN_HEIGHT, Paratrooper[Team], Team);
					AssignTask(Paratrooper[Team], 11, player[Paratrooper[Team]].human);
					if Paratrooper[Team] = 0 then begin
						WriteConsole(Radioman[Team].ID, t(223, player[Radioman[Team].ID].translation, 'ERROR: Paratrooper bot file not found'), BAD);
						exit;
					end;
					Player[Paratrooper[Team]].Alive := true;
					Player[Paratrooper[Team]].Task := 11;
					b := true;
				end else begin
					WriteConsole(Radioman[Team].ID, t(224, player[Radioman[Team].ID].translation, 'Paratrooper already in the field, type /kick to kick it'), BAD);
					exit;
				end;
				Teams[Team].SP := Teams[Team].SP - PARATROOPERCOST;
				b := true;
				SendToLive('sup_para '+inttostr(Team));
			end;
		end;
		else if not Teams[Team].Strike.InProgress then begin
			case Item of
				_enemybase: begin
					if Teams[Team].SP >= ENEMYBASECOST then begin
						CallAirStrike(Team, __enemybase);
						Teams[Team].SP := Teams[Team].SP - ENEMYBASECOST;
						b := true;
						SendToLive('strike_base ' + inttostr(Team));
					end;
				end;
				_napalm: begin
					if Teams[Team].SP >= NAPALMCOST then begin
						CallAirStrike(Team, __napalm);
						Teams[Team].SP := Teams[Team].SP - NAPALMCOST;
						b := true;
						SendToLive('strike_nap ' + inttostr(Team));
					end;
				end;
				_nuke: begin
					if Teams[Team].SP >= HOWITZERCOST then begin
						CallAirStrike(Team, __nuke);
						Teams[Team].SP := Teams[Team].SP - HOWITZERCOST;
						b := true;
						SendToLive('strike_nuke ' + inttostr(Team));
					end;
				end;
				_barrage: begin
					if Teams[Team].SP >= BARRAGECOST then begin
						CallAirStrike(Team, __barrage);
						Teams[Team].SP := Teams[Team].SP - BARRAGECOST;
						b := true;
						SendToLive('strike_bar ' + inttostr(Team));
					end;
				end;
				_zeppelin: begin
					if Teams[Team].SP >= ZEPPELINCOST then begin
						CallAirStrike(Team, __zeppelin);
						Teams[Team].SP := Teams[Team].SP - ZEPPELINCOST;
						b := true;
						SendToLive('strike_zep ' + inttostr(Team));
					end;
				end;
				_airco: begin
					if Teams[Team].SP >= AIRCOCOST then begin
						CallAirStrike(Team, __airco);
						Teams[Team].SP := Teams[Team].SP - AIRCOCOST;
						b := true;
						SendToLive('strike_air ' + inttostr(Team));
					end;
				end;
				_clusterstr: begin
					if Teams[Team].SP >= CLUSTERSTRIKECOST then begin
						CallAirStrike(Team, __clusterstr);
						Teams[Team].SP := Teams[Team].SP - CLUSTERSTRIKECOST;
						b := true;
						SendToLive('strike_clus ' + inttostr(Team));
					end;
				end;
				_burst: begin
					if Teams[Team].SP >= BURSTCOST then begin
						CallAirStrike(Team, __burst);
						Teams[Team].SP := Teams[Team].SP - BURSTCOST;
						b := true;
						SendToLive('strike_burst ' + inttostr(Team));
					end;
				end;
			end;
			if b then begin
				case Item of
					_barrage: begin
						if GetArrayLength(Teams[Team].member) > 0 then
							for i := 0 to GetArrayLength(Teams[Team].member)-1 do
								WriteConsole(Teams[Team].member[i], t(225, player[Teams[Team].member[i]].translation, '[Artillery support]: Affirmative!'), TEAMCHAT);
						if Radioman[2/Team].TapCounter < 0 then
							if GetArrayLength(Teams[2/Team].member) > 0 then
								for i := 0 to GetArrayLength(Teams[2/Team].member)-1 do
									WriteConsole(Teams[2/Team].member[i], t(225, player[Teams[2/Team].member[i]].translation, '[Artillery support]: Affirmative!'), BAD);
					end;
					else begin
						if GetArrayLength(Teams[Team].member) > 0 then
							for i := 0 to GetArrayLength(Teams[Team].member)-1 do
								WriteConsole(Teams[Team].member[i], t(226, player[Teams[Team].member[i]].translation, '[Pilot]: Affirmative!'), TEAMCHAT);
						if Radioman[2/Team].TapCounter < 0 then
							if GetArrayLength(Teams[2/Team].member) > 0 then
								for i := 0 to GetArrayLength(Teams[2/Team].member)-1 do
									WriteConsole(Teams[2/Team].member[i], t(226, player[Teams[2/Team].member[i]].translation, '[Pilot]: Affirmative!'), BAD);
					end;
				end;
			end;
		end else begin
			WriteConsole(Radioman[Team].ID, t(227, player[Radioman[Team].ID].translation, 'Strike currently in progress'), BAD);
			exit;
		end;
	end;
	if not b then
		WriteConsole(Radioman[Team].ID, t(228, player[Radioman[Team].ID].translation, 'Not enough supply points'), TAPCOLOUR)
	else begin
		WriteConsole(Radioman[Team].ID, t(210, player[Radioman[Team].ID].translation, 'Supply points left')+': '+IntToStr(Teams[Team].SP), GOOD);
		TapSupply(2/Team, Item);
		Spec_Supply(Team, Item);
	end;
end;

procedure RadiomanAOI(Team: byte);
begin
	if GatherDir <> '' then
		if GatherOn <> 2 then exit;
	if Radioman[Team].TapCounter > 0 then begin
		if player[Radioman[Team].ID].alive then begin
			Radioman[Team].TapCounter := Radioman[Team].TapCounter - 1;
			if Radioman[Team].TapCounter = 0 then
				WriteConsole(Radioman[Team].ID, t(229, player[Radioman[Team].ID].translation, 'Your battery is full, type /tap to tap into enemy communication'), TAPCOLOUR);
		end;
	end else if Radioman[Team].TapCounter < 0 then begin
		Radioman[Team].TapCounter := Radioman[Team].TapCounter + 1;
		if Radioman[Team].TapCounter = 0 then begin
			WriteConsole(Radioman[Team].ID, t(230, player[Radioman[Team].ID].translation, 'Field Battery drained!'), TAPCOLOUR);
			Radioman[Team].TapCounter := INTERCEPTWAITTIME;
		end;
	end;
end;

function OnRadiomanDamage(Victim,Shooter: byte; var Damage: integer) : integer;
begin
	Result := Damage;
	if Shooter = StrikeBot then
	begin
		if not FriendlyFire then
			if not STRIKE_FF then
				if not Teams[2/player[Victim].team].Strike.InProgress then begin
					Result := round(GetPlayerStat(Victim, 'health') - player[Victim].HP);
					Damage := 0;
				end;
	end;
end;

function ComboName(N: word): string;
begin
	case N of
			0: Result:='';
			1: Result:='DOUBLE KILL';
			2: Result:='TRIPLE KILL';
			3: Result:='MULTI KILL';
			4: Result:='MULTI KILL x2';
			5: Result:='SERIAL KILL';
			6: Result:='INSANE KILLS';
			7: Result:='GIMME MORE!';
	else Result:='MASTA KILLA!';
	end;
end;


procedure OnRadiomanKill(Killer, Victim: byte);
begin
	if Paratrooper[player[Victim].team] = Victim then
		Radioman[Player[Victim].Team].KickPara := True;

	if Killer = StrikeBot then
	begin
		if Victim <> StrikeBot then
			if Teams[2/player[Victim].team].Strike.InProgress then
				if Radioman[2/player[Victim].team].ID > 0 then begin
					player[Radioman[2/player[Victim].team].ID].kills := player[Radioman[2/player[Victim].team].ID].kills + 1;
					SetScore(Radioman[2/player[Victim].team].ID, player[Radioman[2/player[Victim].team].ID].kills);

					if GetTickCount - Radioman[2/Player[Victim].Team].KillTick <= 190 then
					begin
						Radioman[2/Player[Victim].Team].Kills := Radioman[2/Player[Victim].Team].Kills + 1;
						DrawTextX(Radioman[2/Player[Victim].team].ID, 0, ComboName(Radioman[2/Player[Victim].Team].Kills),125,$ffff2020,0.24,40,340);
					end else
					begin
						Radioman[2/Player[Victim].Team].Kills := 0;
						DrawTextX(Radioman[2/Player[Victim].team].ID, 0, 'You killed ' + IDToName(Victim),125,$ffff2020,0.24,40,365)
					end;

					Radioman[2/Player[Victim].Team].KillTick := GetTickCount;
				end;
	end
	else if Killer = Radioman[Player[Killer].Team].ID then
		if Teams[2/player[Victim].team].Strike.InProgress then
		begin
			if GetTickCount - Radioman[2/Player[Victim].Team].KillTick <= 190 then
			begin
				Radioman[2/Player[Victim].Team].Kills := Radioman[2/Player[Victim].Team].Kills + 1;
				DrawTextX(Radioman[2/Player[Victim].team].ID, 2, ComboName(Radioman[2/Player[Victim].Team].Kills),125,$ffff2020,0.24,40,365);
			end else
				Radioman[2/Player[Victim].Team].Kills := 0;
			Radioman[2/Player[Victim].Team].KillTick := GetTickCount;
		end;
end;

function OnRadiomanCommand(ID: byte; var Text: string): boolean;
var
	i: byte;
begin
	Result := false;
	case LowerCase(GetPiece(Text, ' ', 0)) of
		'/tap': begin
			if GatherDir <> '' then
				if GatherOn <> 2 then exit;
			if Radioman[player[ID].team].TapCounter = 0 then begin
				Radioman[player[ID].team].TapCounter := -INTERCEPTTIME;
				for i := 0 to GetArrayLength(Teams[player[ID].team].member)-1 do
					WriteConsole(Teams[player[ID].team].member[i],
						t(25, player[Teams[player[ID].team].member[i]].translation, 'Radioman')
							+' '+IDToName(ID) +' '+
							t(231, player[Teams[player[ID].team].member[i]].translation, 'has started tapping into enemy communication (shown in red)')
						, TAPCOLOUR);
			end else if Radioman[player[ID].team].TapCounter > 0 then
				WriteConsole(ID, t(232, player[ID].translation, 'Field battery is not ready yet')
				+' ('+IntToStr(Radioman[player[ID].team].TapCounter)+' '
				+ t(233, player[ID].translation, 'seconds left')+')'
				, TAPCOLOUR)
			else
				WriteConsole(ID, t(234, player[ID].translation, 'Already tapping...'), TAPCOLOUR);
		end;
		'/kick': begin
			if Paratrooper[player[ID].team] > 0 then
				ResetParatrooper(Player[ID].Team);
		end;
		'/vest': TryBuyOperation(player[ID].team, _vest);
		'/vestgen': TryBuyOperation(player[ID].team, _vestgen);
		'/law': TryBuyOperation(player[ID].team, _law);
		'/grenade': TryBuyOperation(player[ID].team, _grenade);
		'/medi', '/medkit', '/kit': TryBuyOperation(player[ID].team, _medi);
		'/cluster': TryBuyOperation(player[ID].team, _cluster);
		'/hac': TryBuyOperation(player[ID].team, _hac);
		'/flamer': TryBuyOperation(player[ID].team, _flamer);
		'/para': TryBuyOperation(player[ID].team, _para);
		'/basestr', '/enemybase', '/enemy': TryBuyOperation(player[ID].team, _enemybase);
		'/napalm': TryBuyOperation(player[ID].team, _napalm);
		'/nuke': TryBuyOperation(player[ID].team, _nuke);
		'/barrage': TryBuyOperation(player[ID].team, _barrage);
		'/zeppelin': TryBuyOperation(player[ID].team, _zeppelin);
		'/airco': TryBuyOperation(player[ID].team, _airco);
		'/clusterstr', '/cluststr': TryBuyOperation(player[ID].team, _clusterstr);
		'/burst': TryBuyOperation(player[ID].team, _burst);
		'/supply': SupplyList(ID);
		'/strike': StrikeList(ID);
	end;
end;
