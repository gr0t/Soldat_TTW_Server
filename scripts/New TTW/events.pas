procedure ActivateServer();
var
	x: integer;
	i: byte;
begin
	if Command('/realistic ') = 1 then
		MaxHP := 65
	else
		MaxHP := 150;

	AppOnIdleTimer := 10;
	FriendlyFire := Command('/friendlyfire');
	InitializeGeoIP();
	LoadTranslations();
	InitializeStrikes();
	repeat
		x := Random(-$FFFF,$FFFF);
	until x <> 0;
	MTInit(x);
	CalculateCosts(false);
	Pause := False;
	for i := 1 to 32 do
		if GetPlayerStat(i, 'Active') then
			if GetPlayerStat(i, 'Human') then
			begin
				InitializeUnit(i, GetPlayerStat(i, 'Team'), true);
				AssignTask(i, 0, true);
				MaxID := i;
			end else MaxID := i;
	Command('/restart');
end;

procedure AppOnIdle(Ticks: integer);
var
	i: byte;
begin
	if Pause then exit;

	if Ticks mod 10 = 0 then
		TickMines(Ticks mod 60 = 0);

	for i := 1 to 2 do begin
		ProcessAirStrike(i, Ticks);
	end;

	if Ticks mod 60 <> 0 then exit;

	CoreAOI(Ticks);
	KitsAOI();

	ProcessBurningAreas(Ticks);

	for i := 1 to 2 do begin
		StatgunsAOI(i);
		if Medic[i].ID > 0 then MedicAOI(i);
		if General[i].ID > 0 then GeneralAOI(i);
		if Radioman[i].ID > 0 then RadiomanAOI(i);
		if Engineer[i].ID > 0 then EngineerAOI(i);
		SpyAOI(i);
		if Saboteur[i].ID > 0 then SaboteurAOI(i);
		if Artillery[i].ID > 0 then ArtilleryAOI(i, Ticks);
		SpectatorAOI();
	end;
end;

procedure OnLeaveGame(ID, Team: byte;Kicked: boolean);
begin
	if StrikeBot = ID then
	begin
		InitializeStrikes();
		exit;
	end;

	if GatherOn = 2 then
	begin
		BackUp.HWID := GetPlayerStat(ID, 'HWID');
		GetPlayerXY(ID, BackUp.X, BackUp.Y);
		BackUp.Task := Player[ID].Task;
		if BackUp.Task = 4 then
		begin
			BackUp.ConqTimer := General[Team].ConqTimer;
			BackUp.ConqBunker := General[Team].ConqBunker;
			BackUp.sabotaging := General[Team].sabotaging;
		end;
		BackUp.HP := GetPlayerStat(ID, 'Health');
		BackUp.Vest := GetPlayerStat(ID, 'Vest');
		BackUp.Pri := GetPlayerStat(ID, 'Primary');
		BackUp.Sec := GetPlayerStat(ID, 'Secondary');
		BackUp.Ammo := 0;
		BackUp.SecAmmo := 0;
		if (BackUp.Pri = 255) then
		begin
			BackUp.Pri := tempA;
			BackUp.Sec := tempB;
		end;
		BackUp.Nades := GetPlayerStat(ID, 'Grenades');
		BackUp.mre := Player[ID].mre;
	end;

	DestroyUnit(ID, true);
	CountMaxID();
	ParaQueueOnLeaveGame(ID);
	if GetNumPlayers() = 0 then
		ResetGame(false);
end;

procedure OnJoinGame(ID, Team: byte);
var i: byte;
begin
	Player[ID].HWID := GetPlayerStat(ID, 'HWID');
	//Check if he's already ingame
	for i := 1 to MaxID do
		if i <> ID then
			if Player[i].HWID = Player[ID].HWID then
				if Player[i].Active then
					OnLeaveGame(i, Player[i].Team, false);

	player[ID].justjoined := true;
	Player[ID].Alive := Team <> 5;
	if ID > MaxID then
		MaxID := ID;
end;

procedure OnJoinTeam(ID, Team: byte);
var Trans: byte;
begin
	if player[ID].team <> team then begin
		Trans := Player[ID].Translation;
		DestroyUnit(ID, true);
		InitializeUnit(ID, Team, true);
		Player[ID].Translation := Trans;
	end else
		DestroyUnit(ID, false);

	if ServerSetTeam then begin
		ServerSetTeam := false;
		Player[ID].Alive := True;
		exit;
	end;

	if player[ID].JustJoined then begin
		//WriteConsole(ID, WWW + ' | ' + IRC, $FFFF00 );
		WriteConsole(ID, t(301, player[ID].translation, 'Welcome to Tactical Trenchwar') + S_VERSION, I_COLOUR );
		WriteConsole(ID, t(302, player[ID].translation, 'Type !help to get started.'), I_COLOUR );
		WriteConsole(ID, t(303, player[ID].translation, 'Type /commands for a list of commands'), I_COLOUR );
		//DrawText(ID, 'Welcome to Tactical Trenchwar',240, RGB(255,80,80), 0.1, 20, 370 );
		OnLangJoinGame(ID);
	end;

	if Team <=2 then AssignTask(ID, 0, not player[ID].JustJoined);

	if player[ID].JustJoined then begin
		player[ID].JustJoined := false;
	end;
	Player[ID].Alive := True;
end;

function OnPlayerDamage(Victim,Shooter: Byte;Damage: Integer) : integer;
begin
	Result := Damage;
	if (Victim = 0) or (Shooter = 0) then exit;
	Result := OnRadiomanDamage(Victim, Shooter, Damage);
	Result := OnCoreDamage(Victim, Shooter, Result);
end;

 procedure OnPlayerKill(Killer, Victim: byte; Weapon: string);
 begin
	if Victim = BackUp.ID then BackUp.ID := 0;
	if (Killer = 0) or (Victim = 0) then exit;
	try
	player[Victim].alive := false;
	player[Killer].kills := player[Killer].kills + 1;
	player[Victim].deaths := player[Victim].deaths + 1;
	if General[player[Victim].team].ID = Victim then OnGeneralKill(player[Victim].team);
	if Spy[Player[Victim].Team].ID = Victim then OnSpyDeath(Player[Victim].Team);
	if Artillery[Player[Victim].Team].ID = Victim then OnArtilleryDeath(Player[Victim].Team);
	OnRadiomanKill(Killer, Victim);

	except
		WriteLn('debug: Killer ' + IDToName(Killer) + ' (' + inttostr(Killer) + ', Team ' + inttostr(Player[Killer].Team) + ')');
		WriteLn(' killed Victim ' + IDToName(Victim) + ' (' + inttostr(Victim) + ')');
		WriteLn('Team ' + inttostr(Player[Victim].Team));
	end;
end;

procedure OnPlayerRespawn(ID: Byte);
begin
	if (Player[ID].Team > 2) or (Player[ID].Team < 1) then exit;

	player[ID].alive := true;
	if player[ID].human then begin
		OnCoreRespawn(ID);
		case player[ID].task of
			1: OnLongRespawn(ID);
			2: OnShortRespawn(ID);
			else begin
				if Medic[player[ID].team].ID = ID then OnMedicRespawn(ID);
				if General[player[ID].team].ID = ID then OnGeneralRespawn(ID);
				if Saboteur[Player[ID].Team].ID = ID then OnSaboRespawn(ID);
				if Spy[Player[ID].Team].ID = ID then OnSpyRespawn(ID);
				if Artillery[Player[ID].team].ID = ID then OnArtilleryRespawn(ID);
			end;
		end;
	end;
	if ID = Paratrooper[Player[ID].Team] then
	if Radioman[Player[ID].Team].KickPara then
	begin
		Radioman[Player[ID].Team].KickPara := False;
		ResetParatrooper(player[ID].team);
	end;
end;

procedure OnPlayerSpeak(ID: Byte; Text: string);
begin
	if Length(Text) > 0 then
		if Text[1] = '/' then begin
			WriteConsole(ID, t(304, player[ID].translation, 'This is not a command!'), INFORMATION)
			WriteConsole(ID, t(305, player[ID].translation, 'To write a command press / without pressing "t" (chat key)'), INFORMATION)
		end;
	OnCoreSpeak(ID, Text);
end;

function OnPlayerCommand(ID: Byte; Text: string): boolean;
begin
	WriteLn('[CMD] ' + taskToShortName(Player[ID].Task, 0) + ' (' + IDToName(ID) + '): ' + Text);
	Result := false;

	if ID = Paratrooper[player[ID].team] then exit;
	if OnCoreCommand(ID, Text) then exit;
	if OnLangCommand(ID, Text) then exit;

	//Quit if not alive, exception for Radioman's tapping
	if Player[ID].Team = 5 then exit;


	Text := Cmmd2RealCmd(ID, player[ID].task, Text, true);
	case player[ID].task of
		1: OnLongCommand(ID, Text);
		2: OnShortCommand(ID, Text);
		else if player[ID].team <= 2 then begin
			if Medic[player[ID].team].ID = ID then if OnMedicCommand(ID, Text) then exit;
			if General[player[ID].team].ID = ID then if OnGeneralCommand(ID, Text) then exit;
			if Radioman[player[ID].team].ID = ID then if OnRadiomanCommand(ID, Text) then exit;
			if Engineer[Player[ID].Team].ID = ID then if OnEngineerCommand(ID, Text) then exit;
			if Saboteur[Player[ID].Team].ID = ID then if OnSaboteurCommand(ID, Text) then exit;
			if Spy[Player[ID].Team].ID = ID then if OnSpyCommand(ID, Text) then exit;
			if Artillery[Player[ID].Team].ID = ID then if OnArtilleryCommand(ID, Text) then exit;
		end;
	end;
end;

function OnCommand(ID: Byte; Text: string): boolean;
var
	a, b: byte;
	found: boolean;
begin
	Result := false;
	found := false;
	case LowerCase(Copy(GetPiece(Text, ' ', 0), 2, 6)) of
		'addbot': begin
			Result := true;
			found := true;
			try
				a := StrToInt(Text[8]);
				delete(Text, 1, 9);
				b := AddBot(Text, a);
			except
				WriteMessage(ID, 'Syntax: /addbot<Team> <BotName>', BAD);
			end;
		end;
		'realis': begin
			found := true;
			case LowerCase(Text) of
				'/realistic 1': MaxHP := 65;
				'/realistic 0': MaxHP := 150;
			end;
		end;
		'friend': begin
			found := true;
			case LowerCase(Text) of
				'/friendlyfire 1': FriendlyFire := true;
				'/friendlyfire 0': FriendlyFire := false;
			end;
		end;
		'sp': Teams[player[ID].team].SP := Teams[player[ID].team].SP + StrToInt(GetPiece(Text, ' ', 1));
		'recomp': begin
						StrikeBot := 0;
						for a := 1 to MaxID do
							if not Player[a].Human then KickPlayer(a);
					end;
		'pause': Pause := True;
		'unpause': Pause := False;
		'gr': begin
			a := StrToIntDef(GetPiece(Text, ' ', 1), 100);
			ServerModifier('Gravity', 0.0006*a);
			WriteMessage(ID, 'Gravity set to ' + IntToStr(a) + '%', GOOD);
		end;
		'fixgam': begin
			SetArrayLength(teams[1].member, 0);
			SetArrayLength(teams[2].member, 0);
			for a := 1 to 32 do begin
				player[a].active := GetPlayerStat(a, 'active');
				player[a].alive := GetPlayerStat(a, 'alive');
				player[a].human := GetPlayerStat(a, 'human');
				player[a].team := GetPlayerStat(a, 'team');
				player[a].HWID := GetPlayerStat(a, 'HWID');
				if (player[a].team > 0) and (player[a].team < 3) then
					PushByteArray(teams[player[a].team].member, a);
			end;
			CountMaxID();
			WriteMessage(ID, 'Game state recalculation complete', GOOD);
		end;
	end;
end;

procedure OnMapChange(NewMap: String);
begin
	//CreateDefaultTranslation();
	InitializeBunkers(NewMap);
	ResetGame(true);
end;

procedure OnWeaponChange(ID, PrimaryNum, SecondaryNum: Byte);
var
	i: byte;
begin
	if not ServerForceWeapon then
		if BackUp.ID = ID then
			if PrimaryNum = 255 then		//his primary changed to fists
			if BackUp.Pri <> 255 then		//He had a primary weapon before
			if BackUp.Pri <> 14 then		//it was no knife
			if (BackUp.Sec <> 255) or (SecondaryNum <> BackUp.Sec) then	//He didn't switch weapons
			begin
				ServerForceWeapon := true;
				ForceWeaponEx(ID, BackUp.Pri, BackUp.Sec, BackUp.Ammo, BackUp.SecAmmo);
				exit;
			end;

	if PrimaryNum = 255 then
		begin
			tempA := Player[ID].pri;
			tempB := Player[ID].sec;
		end;

	player[ID].pri := PrimaryNum;
	player[ID].sec := SecondaryNum;
	if ServerForceWeapon then begin
		ServerForceWeapon := false;
		exit;
	end;

	OnCoreWeaponChange(ID, PrimaryNum, SecondaryNum);
end;

procedure OnFlagGrab(ID, TeamFlag: byte; GrabbedInBase: boolean);
begin
	SendToLive('flagcap ' +inttostr(player[ID].Team) +' '+ taskToName( player[ ID ].task, 0));
end;

procedure OnFlagScore(ID, TeamFlag: byte);
begin
	SendToLive('flagscore ' + inttostr(player[ID].Team) + ' ' + inttostr(GetTicks(1)) + ' ' + inttostr(GetTicks(2)) + ' '+ taskToName( player[ ID ].task, 0));
end;

procedure OnFlagReturn(ID, TeamFlag: byte);
begin
	SendToLive('flagreturn ' + inttostr(player[ID].Team) + ' ' + inttostr(GetTicks(1)) + ' ' + inttostr(GetTicks(2)) + ' '+ taskToName( player[ ID ].task, 0));
end;
