procedure StartConquer(BunkID, GenID: byte; sabo: boolean);
begin
	General[player[GenID].team].ConqTimer := CONQUERTIME;
	General[player[GenID].team].sabotaging := sabo;
	General[player[GenID].team].ConqBunker := BunkID;
	if sabo then
		WriteConsole(GenID, t(172, player[GenID].translation, 'Sabotaging bunker... Don''t move!'), GOOD)
	else
		WriteConsole(GenID, t(173, player[GenID].translation, 'Conquering bunker... Don''t move!'), GOOD);
end;

procedure StopConquer(Team: byte);
begin
	if General[Team].ID > 0 then begin
		if General[Team].sabotaging then begin
			if not DrawTextX(General[Team].ID, 10, t(174, player[General[Team].ID].translation, 'Failed to sabotage bunker!'), 100, RGB(0,255,0), 0.1, 20, 370) then
				WriteConsole(General[Team].ID, t(174, player[General[Team].ID].translation, 'Failed to sabotage bunker!'), BAD);
		end else if not DrawTextX( General[Team].ID, 10, t(175, player[General[Team].ID].translation, 'Failed to conquer bunker!'), 100, RGB(0,255,0), 0.1, 20, 370) then
				WriteConsole(General[Team].ID, t(175, player[General[Team].ID].translation, 'Failed to conquer bunker!'), BAD);
	end;
	WriteLn(IDToName(General[Team].ID) + ': Failed to conquer ' + iif(Player[General[Team].ID].Alive, ' (out of borders)', ' (died/left)'));
	General[Team].ConqTimer := 0;
	General[Team].ConqBunker := 0;
	General[Team].sabotaging := false;
end;

procedure GeneralAOI(Team: byte);
var
	i: byte;
	b: boolean;
begin
	if General[Team].ConqTimer > 0 then begin
		GetPlayerXY(General[Team].ID, player[General[Team].ID].X, player[General[Team].ID].Y);
		if (not IsBetween(Bunker[General[Team].ConqBunker].X1, Bunker[General[Team].ConqBunker].X2, player[General[Team].ID].X)) and (BackUp.ID <> General[Team].ID) then begin
			StopConquer(Team);
			exit;
		end;
		General[Team].ConqTimer := General[Team].ConqTimer - 1;
		if General[Team].ConqTimer = 0 then begin
			if General[Team].sabotaging then begin
				if GetArrayLength(Teams[Team].member) > 0 then
					for i := 0 to GetArrayLength(Teams[Team].member)-1 do begin
						if Teams[Team].member[i] <> General[Team].ID then
							DrawTextX(Teams[Team].member[i], 10, t(176, player[Teams[Team].member[i]].translation, 'Your team sabotaged a bunker!'),100, RGB(0,255,0), 0.1, 20, 370 );
						WriteConsole(Teams[Team].member[i], t(177, player[Teams[Team].member[i]].translation, 'Your team pushed the enemy back a bunker!'), GOOD);
					end;
				if GetArrayLength(Teams[2/Team].member) > 0 then
					for i := 0 to GetArrayLength(Teams[2/Team].member)-1 do
						if DrawTextX(Teams[2/Team].member[i], 10, t(178, player[Teams[2/Team].member[i]].translation, 'The enemy has sabotaged your bunker!'),100, RGB(255,0,0), 0.1, 20, 370 ) then
							WriteConsole(Teams[2/Team].member[i], t(179, player[Teams[2/Team].member[i]].translation, 'The enemy pushed your team back a bunker!'), BAD);
				DrawTextX(General[Team].ID, 10, t(180, player[General[Team].ID].translation, 'Bunker sabotaged!'), 100, RGB(0,255,0), 0.1, 20, 370);
			end else begin
				if GetArrayLength(Teams[Team].member) > 0 then
					for i := 0 to GetArrayLength(Teams[Team].member)-1 do begin
						b := false;
						if (Teams[Team].member[i] <> General[Team].ID) then
							b := DrawTextX(Teams[Team].member[i], 10, t(181, player[Teams[Team].member[i]].translation, 'Your team has advanced a bunker!'),100, RGB(0,255,0), 0.1, 20, 370 )
							else b := True;

						if b then
							WriteConsole(Teams[Team].member[i], t(181, player[Teams[Team].member[i]].translation, 'Your team has advanced a bunker!'), GOOD);
					end;
				DrawTextX(General[Team].ID, 10, t(182, player[General[Team].ID].translation, 'Bunker conquered!'), 100, RGB(0,255,0), 0.1, 20, 370);
				if General[2/Team].ConqTimer > 0 then
					if General[2/Team].sabotaging then
						StopConquer(2/Team);
				if GetArrayLength(Teams[2/Team].member) > 0 then
					for i := 0 to GetArrayLength(Teams[2/Team].member)-1 do
						if DrawTextX(Teams[2/Team].member[i], 10, t(183, player[Teams[2/Team].member[i]].translation, 'The enemy has conquered a bunker!'),100, RGB(255,0,0), 0.1, 20, 370 ) then
							WriteConsole(Teams[2/Team].member[i], t(183, player[Teams[2/Team].member[i]].translation, 'The enemy has conquered a bunker!'), BAD);
			end;
			SwapBunker(General[Team].ConqBunker, Team, General[Team].sabotaging);
			SendToLive('conquer ' +inttostr(Team) +' '+inttostr(GetTicks(1)) +' '+inttostr(GetTicks(2))	+' '+inttostr(Teams[1].Bunker + 1) +' '+inttostr(Teams[2].Bunker + 1) +iif_str(General[Team].sabotaging, ' 0', ' 1'));
			Spec_Conquer(Team, General[Team].ConqBunker, General[Team].sabotaging);
			ResetGeneral(Team, false);
		end else begin
			if General[Team].sabotaging then
				DrawTextX(General[Team].ID, 10, t(184, player[General[Team].ID].translation, 'Sabotaging...')+' ['+inttostr( General[Team].ConqTimer )+']', 100, RGB(0,255,0), 0.1, 20, 370)
			else
				DrawTextX(General[Team].ID, 10, t(185, player[General[Team].ID].translation, 'Conquering...')+' ['+inttostr( General[Team].ConqTimer )+']', 100, RGB(0,255,0), 0.1, 20, 370);
		end;
	end;
end;

procedure OnGeneralKill(Team: byte);
begin
	if General[Team].ConqTimer > 0 then
		StopConquer(Team);
end;

procedure OnGeneralRespawn(ID: byte);
begin
	player[ID].mre := 1;
end;

function OnGeneralCommand(ID: byte; var Text: string): boolean;
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
		'/conquer', '/conq': begin
			GetPlayerXY(ID, player[ID].X, player[ID].Y);
			if player[ID].alive then begin
				if General[player[ID].team].ConqTimer = 0 then begin
					for i := 0 to GetArrayLength(Bunker)-1 do
						if IsBetween(Bunker[i].X1, Bunker[i].X2, player[ID].X) then
						begin
							case Bunker[i].style of
								-2: begin
									case player[ID].team of
										1: WriteConsole(ID, t(186, player[ID].translation, 'This is your own base.'), BAD);
										2: WriteConsole(ID, t(187, player[ID].translation, 'This is enemy base, you can''t conquer it'), BAD);
									end;
								end;
								-1: begin
									case player[ID].team of
										1: begin
											if bunker[i].owner <> 1 then begin
												if i > Teams[player[ID].team].bunker then
													StartConquer(i, ID, false)
												else
													WriteConsole(ID, t(188, player[ID].translation, 'Your team already have farther bunker'), BAD);
											end else WriteConsole(ID, t(189, player[ID].translation, 'You already have this bunker'), BAD);
										end;
										2: begin
											if bunker[i].owner = 1 then begin
												if bunker[i+1].owner <> 1 then
													StartConquer(i, ID, true)
												else
													WriteConsole(ID, t(190, player[ID].translation, 'You can only sabotage this bunker when you have all other bunkers'), BAD);
											end else
												WriteConsole(ID, t(191, player[ID].translation, 'You can only sabotage this bunker if the enemy has conquered it'), BAD);
										end;
									end;
								end;
								0: begin
									if Bunker[i].owner <> player[ID].team then begin
										if ((player[ID].team = 1) and (i > Teams[player[ID].team].bunker)) or ((player[ID].team = 2) and (i < Teams[player[ID].team].bunker)) then
										begin
											if (General[2/player[ID].team].ConqTimer < 1) or (General[2/player[ID].team].ConqBunker <> i) then
												StartConquer(i, ID, false)
											else WriteConsole(ID, 'This bunker is already being conquered.', BAD);
										end else
											WriteConsole(ID, t(188, player[ID].translation, 'Your team already has a farther bunker'), BAD);
									end else
										WriteConsole(ID, t(189, player[ID].translation, 'You already have this bunker'), BAD);
								end;
								1: begin
									case player[ID].team of
										1: begin
											if bunker[i].owner = 2 then begin
												if bunker[i-1].owner <> 2 then
													StartConquer(i, ID, true)
												else
													WriteConsole(ID, t(190, player[ID].translation, 'You can only sabotage this bunker when you have all other bunkers'), BAD);
											end else
												WriteConsole(ID, t(191, player[ID].translation, 'You can only sabotage this bunker if the enemy has conquered it'), BAD);
										end;
										2: begin
											if bunker[i].owner <> 2 then begin
												if i < Teams[player[ID].team].bunker then
													StartConquer(i, ID, false)
												else
													WriteConsole(ID, t(188, player[ID].translation, 'Your team already have farther bunker'), BAD);
											end else
												WriteConsole(ID, t(189, player[ID].translation, 'You already have this bunker'), BAD);
										end;
									end;
								end;
								2: begin
									case player[ID].team of
										1: WriteConsole(ID, t(187, player[ID].translation, 'This is enemy base, you can''t conquer it'), BAD);
										2: WriteConsole(ID, t(186, player[ID].translation, 'This is your own base.'), BAD);
									end;
								end;
							end;
							break;
						end;
				end else
					WriteConsole(ID, t(192, player[ID].translation, 'Already conquering...'), BAD);
			end else
				WriteConsole(ID, t(193, player[ID].translation, 'You have to be alive to conquer a bunker'), BAD);
		end;

		else Result := False;
	end;
end;
