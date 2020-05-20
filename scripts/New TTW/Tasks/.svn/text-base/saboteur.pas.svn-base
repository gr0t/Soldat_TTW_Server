procedure OnSaboRespawn(ID: byte);
begin
	player[ID].mre := 1;
end;

procedure SaboteurAOI(Team: byte);
var
	r: byte;
begin
	if Saboteur[Team].RigTimer > 0 then begin
		Saboteur[Team].RigTimer := Saboteur[Team].RigTimer - 1;
		if Saboteur[Team].RigTimer = 0 then begin
			CreateBullet(SG[Saboteur[Team].SGTeam].X-10, SG[Saboteur[Team].SGTeam].Y, 0, 0, 25, 4, Saboteur[Team].ID);
			CreateBullet(SG[Saboteur[Team].SGTeam].X+10, SG[Saboteur[Team].SGTeam].Y+5, -5, 0, 25, 4, Saboteur[Team].ID);
			CreateBullet(SG[Saboteur[Team].SGTeam].X, SG[Saboteur[Team].SGTeam].Y-5, 5, 0, 25, 10, Saboteur[Team].ID);
			DestroyStat(Saboteur[Team].SGTeam);
			SendToLive('rigsg '+inttostr(Team));
			Teams[Saboteur[Team].SGTeam].StatgunRefreshTimer := STATGUN_COOLDOWN_TIME;
			Engineer[Saboteur[Team].SGTeam].Timer := 0;
			Engineer[Saboteur[Team].SGTeam].ProcID := 0;
			If GetArrayLength(Teams[Saboteur[Team].SGTeam].member) > 0 then
				for r := 0 to GetArrayLength(Teams[Saboteur[Team].SGTeam].member)-1 do
					WriteConsole(Teams[Saboteur[Team].SGTeam].member[r], t(122, Player[Teams[Saboteur[Team].SGTeam].member[r]].Translation, 'Your team''s statgun has been destroyed!'), BAD);							
			if Saboteur[Team].ID = StrikeBot then Saboteur[Team].ID := 0;
		end;
	end;
end;

function OnSaboteurCommand(ID: byte; var Text: string): boolean;
var
	i: byte;
begin
	Result := True;
	case LowerCase(GetPiece(Text, ' ', 0)) of
		'/mre': if player[ID].alive then begin
			if player[ID].mre > 0 then begin
				player[ID].mre := player[ID].mre - 1;
				WriteConsole(ID, GetFoodMessage(player[ID].translation), GOOD );
				GiveHealth( ID, 32);
			end else
				WriteConsole(ID, t(170, player[ID].translation, 'You do not have a meal ready to eat.'), BAD);
		end else
			WriteConsole(ID, t(171, player[ID].translation, 'You''re already dead'), BAD);
		'/rig': if player[ID].alive then begin
			GetPlayerXY(ID, player[ID].X, player[ID].Y);
			i := GetStatGunAt(player[ID].X, player[ID].Y, STATGUN_DISTANCE);
			if i > 0 then
				if Saboteur[Player[ID].Team].RigTimer < 1 then
				begin
					Saboteur[player[ID].team].RigTimer := SABO_RIGTIME;
					Saboteur[Player[ID].Team].SGTeam := i;
					WriteConsole(ID, t(261, Player[ID].Translation, 'Statgun rigged!'), GOOD);
					DrawTextX(ID, 30, t(261, Player[ID].Translation, 'Statgun rigged!') + ' [' + inttostr(SABO_RIGTIME) + ']', 100, RGB(0,255,0), 0.1, 20, 370);
				end;
			
			for i := 1 to MAXMINES do begin
				if IsInRange(player[ID].X, player[ID].Y, Mines[i].X, Mines[i].Y, MINE_RIG_DISTANCE) then
					if Mines[i].placed then
					begin
						DestroyMine(i, false);
						SendToLive('rigmine '+inttostr(Player[ID].Team));
						WriteConsole(ID, t(262, Player[ID].Translation, 'Mine rigged!'), GOOD);
					end;
			end;
		end else
			WriteConsole(ID, t(263, player[ID].translation, 'You have to be alive to rig something'), BAD);
		
		else Result := False;
	end;
end;
