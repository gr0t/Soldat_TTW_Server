procedure ActivateServer();
begin
	mainActivateServer();
end;

procedure AppOnIdle(Ticks: integer);
begin
	if Ticks mod 60 <> 0 then exit;
	mainAppOnIdle(Ticks);
	case GatherMode of
		MODE_TTW: ttwAppOnIdle(Ticks);
		MODE_TW: twAppOnIdle(Ticks);
		MODE_ONS: onsAppOnIdle(Ticks);
		MODE_MMOD: mmodAppOnIdle(Ticks);
		MODE_M79C: m79cAppOnIdle(Ticks);
		MODE_MM: mmAppOnIdle(Ticks);
		MODE_POR: porAppOnIdle(Ticks);
	end;
	
	//Initialisation of the mode at start
	if initMode = 1 then
	begin
		initMode := 2;
		case GatherMode of
			MODE_TTW: 	ttwInitialise();
			MODE_TW:	twInitialise();
			MODE_MMOD: 	mmodInitialise();
			MODE_MM: 	mmInitialise();
		end;
	end;
end;

procedure OnMapChange(NewMap: string);
begin
	mainOnMapChange(NewMap);
	case GatherMode of
		MODE_TTW: ttwOnMapChange(NewMap);
		MODE_TW: twOnMapChange(NewMap);
		MODE_MM: mmOnMapChange(NewMap);
		MODE_MMOD: mmodOnMapChange(NewMap);
		MODE_M79C: m79cOnMapChange(NewMap);
	end;
	
	if GatherOn = 1 then
		GatherOn := 2;
end;

procedure OnFlagScore(ID, TeamFlag: byte);
begin
	mainOnFlagScore(ID, TeamFlag);
	case GatherMode of
		MODE_TTW: ttwOnFlagScore(ID, TeamFlag);
		MODE_TW: twOnFlagScore(ID, TeamFlag);
		MODE_MMOD: mmodOnFlagScore(ID, TeamFlag);
		MODE_M79C: m79cOnFlagScore(ID, TeamFlag);
	end;
end;

procedure OnJoinTeam(ID, Team: byte);
begin
	mainOnJoinTeam(ID, Team);
end;

procedure OnJoinGame(ID, Team: byte);
begin
	mainOnJoinGame(ID, Team);
	
	case GatherMode of
		MODE_POR: porOnJoinGame(ID, Team);
	end;
end;

procedure OnLeaveGame(ID, Team: byte;Kicked: boolean);
begin
	mainOnLeaveGame(ID, Team, Kicked);
	case GatherMode of
		MODE_TTW: ttwOnLeaveGame(ID, Team, Kicked);
	end;
end;

procedure OnAdminMessage(IP, Msg: string);
begin
	mainOnAdminMessage(IP, Msg);
end;

function OnCommand(ID: Byte; Text: string): boolean;
begin
	mainOnCommand(ID, Text);
	
	Result := false;
end;

function OnPlayerCommand(ID: Byte; Text: string): boolean;
begin
	mainOnPlayerCommand(ID, Text);
	case GatherMode of
		MODE_TTW: ttwOnPlayerCommand(ID, Text);
		MODE_MM: mmOnPlayerCommand(ID, Text);
	end;
	Result := false; 
end;

procedure OnPlayerSpeak(ID: byte; Text: string);
begin
	mainOnPlayerSpeak(ID, Text);
	case GatherMode of
		MODE_TW: twOnPlayerSpeak(ID, Text);
		MODE_MM: mmOnPlayerSpeak(ID, Text);
	end;
end;

procedure OnPlayerRespawn(ID: byte);
begin
	mainOnPlayerRespawn(ID);
end;
