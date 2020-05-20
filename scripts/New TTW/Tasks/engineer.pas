procedure StopProcess(Team: Byte; Display: boolean);
begin
	if Display then
		case Engineer[Team].ProcID of
			2: DrawTextX(Engineer[Team].ID, 20, t(235, Player[Engineer[Team].ID].Translation, 'Construction failed!'), 100, BAD, 0.1, 20, 370);
			3: DrawTextX(Engineer[Team].ID, 20, t(236, Player[Engineer[Team].ID].Translation, 'Deconstruction failed!'), 100, BAD, 0.1, 20, 370);			
			4: DrawTextX(Engineer[Team].ID, 20, t(237, Player[Engineer[Team].ID].Translation, 'Reparation failed!'), 100, BAD, 0.1, 20, 370);			
		end;
	Engineer[Team].Timer := 0;
	Engineer[Team].ProcID := 0;
end;

procedure EngineerAOI(Team: byte);
begin
	if Engineer[Team].Timer > 0 then 
	begin	
		//Check if Engineer is still alive/active
		if not Player[Engineer[Team].ID].Alive then 
			StopProcess(Team, player[Engineer[Team].ID].active);
		
		GetPlayerXY(Engineer[Team].ID, player[Engineer[Team].ID].X, player[Engineer[Team].ID].Y);
		if Distance(Engineer[Team].BuildX, Engineer[Team].BuildY, player[Engineer[Team].ID].X, player[Engineer[Team].ID].Y) >= STATGUN_DISTANCE then
		begin
			StopProcess(Team, true);
			Exit;
		end;
		Engineer[Team].Timer := Engineer[Team].Timer - 1;
		if Engineer[Team].Timer = 0 then
		begin
			case Engineer[Team].ProcID of
				2:	//Builing done
					begin 						
						CreateStat(Team, Engineer[Team].BuildX,Engineer[Team].BuildY);
						if DrawTextX(Engineer[Team].ID, 20, t(238, Player[Engineer[Team].ID].Translation, 'Construction complete!'),100, RGB(100,255,100), 0.1, 20, 370) then
							WriteConsole(Engineer[Team].ID, t(238, Player[Engineer[Team].ID].Translation, 'Construction complete!'), GOOD);
						StopProcess(Team, false);
						SendToLive('build '+inttostr(Team))
					end;
					
				3:	//Retrieval done
					begin
						DestroyStat(Team);
						Engineer[Team].Timer := 0;
						if DrawTextX(Engineer[Team].ID, 20, t(239, Player[Engineer[Team].ID].Translation, 'Statgun retrieved!'),100, RGB(100,255,100), 0.1, 20, 370) then
							WriteConsole(Engineer[Team].ID, t(239, Player[Engineer[Team].ID].Translation, 'Statgun retrieved!'), GOOD);
						StopProcess(Team, false);
					end;
						
				4:	//Repairing done
					begin
						if DrawTextX(Engineer[Team].ID, 20, t(240, Player[Engineer[Team].ID].Translation, 'Successfully repaired!'),100, RGB(100,255,100), 0.1, 20,370) then
							WriteConsole(Engineer[Team].ID, t(240, Player[Engineer[Team].ID].Translation, 'Successfully repaired!'), GOOD );
						DestroyStat(Team);
						CreateStat(Team, Engineer[Team].BuildX,Engineer[Team].BuildY);
						StopProcess(Team, false);
					end;
			end	
		end else 
		//Processes on Statgun
		begin
			case Engineer[Team].ProcID of
				2: DrawTextX(Engineer[Team].ID, 20, t(241, Player[Engineer[Team].ID].Translation, 'Constructing...')+'['+inttostr(Engineer[Team].Timer) + ']', 100, RGB(0,255,0), 0.1, 20, 370);
				3: DrawTextX(Engineer[Team].ID, 20, t(242, Player[Engineer[Team].ID].Translation, 'Deconstructing...')+'['+inttostr(Engineer[Team].Timer) + ']', 100, RGB(0,255,0), 0.1, 20, 370);
				4: DrawTextX(Engineer[Team].ID, 20, t(243, Player[Engineer[Team].ID].Translation, 'Repairing...')+'['+inttostr(Engineer[Team].Timer) + ']', 100, RGB(0,255,0), 0.1, 20, 370);
			end;
		end;
	end;			
end;

function OnEngineerCommand(ID: byte; var Text: string): boolean;
var
	Statgun: byte;
begin
	Result := True;	
	GetPlayerXY(ID, player[ID].X, player[ID].Y);	
	case LowerCase(GetPiece(Text, ' ', 0)) of
		'/fix', '/repair', '/rep': if player[ID].alive then begin
			begin
				Statgun := GetStatgunAt(player[ID].X, player[ID].Y, STATGUN_DISTANCE);
				if Statgun = player[ID].team then
				begin
					Engineer[player[ID].team].ProcID := 4;
					Engineer[player[ID].team].Timer := STATGUN_REPAIR_TIME;
					WriteConsole(ID, t(244, Player[ID].Translation, 'Repairing Statgun, do not move!'), GOOD);
				end else	
					WriteConsole(ID, t(245, Player[ID].Translation, 'Stand near to a Statgun to repair it!'), BAD);
			end;			
		end else
			WriteConsole(ID, t(246, Player[ID].Translation, 'You have to be alive to fix a stationary gun'), BAD);
		'/get': if player[ID].alive then begin
			begin
				Statgun := GetStatGunAt(player[ID].X, player[ID].Y, STATGUN_DISTANCE);
				if Statgun = player[ID].team then
				begin
					Engineer[player[ID].team].ProcID := 3;
					Engineer[player[ID].team].Timer := STATGUN_RETRIEVE_TIME;
					WriteConsole(ID, t(247, Player[ID].Translation, 'Retrieving Statgun, do not move!'), GOOD);
				end else 
					WriteConsole(ID, t(248, Player[ID].Translation, 'Stand near to a Statgun to retrieve it!'), BAD);
			end;
		end else
			WriteConsole(ID, t(249, Player[ID].Translation, 'You have to be alive to get a stationary gun'), BAD);
		'/build':if player[ID].alive then begin
				if SG[player[ID].team].ID = 0 then begin//Not built already
					if Engineer[player[ID].team].ProcID = 0 then 
						if Teams[player[ID].team].StatgunRefreshTimer = 0 then 	//Cooldown done
						begin
							Engineer[player[ID].team].BuildX := player[ID].X;
							Engineer[player[ID].team].BuildY := player[ID].Y;
							Engineer[player[ID].team].ProcID := 2;
							Engineer[player[ID].team].Timer := STATGUN_BUILD_TIME;
							WriteConsole( ID, t(250, Player[ID].Translation, 'Construction started! Do not move!'), GOOD );
						end else WriteConsole(ID, t(251, Player[ID].Translation, 'Statgun not ready yet. Wait') + ' ' + inttostr(Teams[Player[ID].Team].StatgunRefreshTimer) + ' '+ t(252, Player[ID].Translation, 'seconds.'), BAD)
					else WriteConsole(ID, t(253, Player[ID].Translation, 'Another process in progress, please wait'), BAD);					
				end else WriteConsole(ID, t(254, Player[ID].Translation, 'Statgun already in game. Type /get near it to get it'), BAD);					
		end else
			WriteConsole(ID, t(255, Player[ID].Translation, 'You have to be alive to build a stationary gun'), BAD);
		'/mine': if player[ID].alive then begin
				if Teams[Player[ID].Team].Mines > 0 then
				begin
					//Place Mine
					if RayCast2(0, 5, 50, player[ID].X, player[ID].Y) then begin
						WriteConsole(ID, t(307, Player[ID].Translation, 'Can''t place mine in midair'), BAD);
						exit;
					end;
					RayCast2(0, 1, 5, player[ID].X, player[ID].Y);
					CreateMine(player[ID].X, player[ID].Y, ID);
					SendToLive('mine '+inttostr(player[ID].Team));
					Teams[Player[ID].Team].Mines := Teams[Player[ID].Team].Mines - 1;
					Teams[Player[ID].Team].MinesPlaced := Teams[Player[ID].Team].MinesPlaced + 1;
					WriteConsole(ID, t(256, Player[ID].Translation, 'Mine placed! Get away from it!'), GOOD);
					DrawTextX(ID, 20, t(257, Player[ID].Translation, 'Mine placed!'), 100, RGB(0,255,0), 0.1, 20, 370);
				end	else WriteConsole(ID, t(258, Player[ID].Translation, 'You have no mines left!') 
						+ ' ' + iif(Teams[Player[ID].Team].MinesPlaced < MAXMINES / 2, t(259, Player[ID].Translation, 'You have to wait') + ' ' + inttostr(Teams[Player[ID].Team].MinesRefreshTimer) + ' ' + t(252, Player[ID].translation, 'seconds.'), ''), BAD);		
		end else
			WriteConsole(ID, t(260, Player[ID].Translation, 'You have to be alive to place a mine'), BAD);
		else Result := False;
	end;
end;
