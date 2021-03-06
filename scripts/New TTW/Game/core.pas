procedure InitializeUnit(ID, Team: byte; human: boolean);
var
	i: byte;
begin
	player[ID].active := true;
	player[ID].team := Team;
	player[ID].human := human;
	if Team <= 2 then PushByteArray(Teams[Team].member, ID);
	if human then
		for i := 1 to MAXWEAPONS do
			player[ID].weapons[i] := false;
end;

procedure ApplyWeapons(ID: byte);
var
	i: byte;
begin
	for i := 0 to MAXWEAPONS do begin
		SetWeaponActive(ID, i, player[ID].weapons[i]);
		sleep(20);
		SetWeaponActive(ID, i, player[ID].weapons[i]);
	end;
end;

procedure AssignTask(ID, task: byte; display: boolean);
begin
	if task = 0 then task := RandInt(1, 2);
	player[ID].task := task;
	Debug(1, IDToName(ID)+' assigned to task '+IntToStr(task));
	WriteConsole(ID, ' ', C_COLOUR); //I like it clean, write one empty line before
	case task of
		1: AssignLongRange(ID);
		2: AssignShortRange(ID);
		3: AssignMedic(ID, player[ID].team);
		4: AssignGeneral(ID, player[ID].team);
		5: AssignRadioman(ID, player[ID].team);
		6: AssignSaboteur(ID, Player[ID].Team);
		7: AssignEngineer(ID, Player[ID].Team);
		8: AssignElite(ID, Player[ID].Team);
		9: AssignSpy(ID, Player[ID].Team);
		10: AssignArtillery(ID, Player[ID].Team);
		11: AssignParatrooper(ID, Player[ID].Team);
	end;
	player[ID].weapons[0] := true;
	ApplyWeapons(ID);
	if display then
		DrawText(ID, taskToName(player[ID].task, player[ID].translation),200, H_COLOUR, 0.1, 20, 370 );
end;

procedure Untask(ID: byte; left: boolean);
var
	i: byte;
begin
	if player[ID].team = 5 then
		exit;
	player[ID].task := 0;
	if Medic[player[ID].team].ID = ID then ResetMedic(player[ID].team, left);
	if General[player[ID].team].ID = ID then ResetGeneral(player[ID].team, left);
	if Radioman[player[ID].team].ID = ID then ResetRadioman(player[ID].team, left);
	if Engineer[player[ID].team].ID = ID then ResetEngineer(player[ID].team, left);
	if Saboteur[Player[ID].Team].ID = ID then ResetSaboteur(Player[ID].Team, left);
	if Spy[Player[ID].Team].ID = ID then ResetSpy(Player[ID].Team, left);
	if Elite[Player[ID].Team].ID = ID then ResetElite(Player[ID].Team, left);
	if Artillery[player[ID].team].ID = ID then ResetArtillery(Player[ID].team, left);
	if Paratrooper[player[ID].team] = ID then ResetParatrooper(Player[ID].team);
	for i := 0 to MAXWEAPONS do
		player[ID].weapons[i] := false;
end;

procedure SwitchTask(ID, NewTask: byte);
var i: byte;
begin
	if Player[ID].Team = 5 then Exit;
	
	if player[ID].task = NewTask then begin
		WriteConsole(ID, t(139, player[ID].translation, 'You already have that task'), BAD);
		exit;
	end;
	case NewTask of
		3: if Medic[player[ID].team].ID > 0 then begin
			WriteConsole(ID, IDToName(Medic[Player[ID].Team].ID) + t(140, player[ID].translation, 'is your team''s Medic'), BAD);
			exit
		end;
		4: if General[player[ID].team].ID > 0 then begin
			WriteConsole(ID, IDToName(General[Player[ID].Team].ID) + t(141, player[ID].translation, 'is your team''s General'), BAD);
			exit;
		end;
		5: if Radioman[player[ID].team].ID > 0 then begin
			WriteConsole(ID, IDToName(Radioman[Player[ID].Team].ID) + t(142, player[ID].translation, 'is your team''s Radioman'), BAD);
			exit;
		end;
		6: 	if Saboteur[Player[ID].Team].ID > 0 then
			begin
				WriteConsole(ID, IDToName(Saboteur[Player[ID].Team].ID) + t(143, Player[ID].Translation, 'is your team''s Saboteur'), BAD);
				Exit;			
			end;
		7: 	if Engineer[Player[ID].Team].ID > 0 then
			begin
				WriteConsole(ID, IDToName(Engineer[Player[ID].Team].ID) + t(144, Player[ID].Translation, 'is your team''s Engineer'), BAD);
				Exit;
			end;
		8: 	if Elite[Player[ID].Team].ID > 0 then
			begin
				WriteConsole(ID, IDToName(Elite[Player[ID].Team].ID) + t(145, Player[ID].Translation, 'is your team''s Elite'), BAD);
				Exit;
			end;
		9:  if Spy[Player[ID].Team].ID > 0 then
			begin
				WriteConsole(ID, IDToName(Spy[Player[ID].Team].ID) + t(146, Player[ID].Translation, 'is your team''s Spy'), BAD);
				Exit;
			end;	
		10: if Artillery[Player[ID].Team].ID > 0 then
			begin
				WriteConsole(ID, IDToName(Artillery[Player[ID].Team].ID) + t(147, Player[ID].Translation, 'is your team''s Artillery'), BAD);
				Exit;
			end;
	end;
	if warmUp < 1 then DoDamage(ID, 4000);
	for i := 0 to GetArrayLength(Teams[Player[ID].Team].member) - 1 do
	begin
		WriteConsole(Teams[Player[ID].Team].member[i], TaskToName(newTask, Player[Teams[Player[ID].Team].member[i]].Translation) + +' '+ t(148, Player[Teams[Player[ID].Team].member[i]].Translation, 'taken by')+' '+ IDToName(ID), INFORMATION);
		WriteConsole(Teams[Player[ID].Team].member[i], TaskToName(Player[ID].Task, Player[Teams[Player[ID].Team].member[i]].Translation) + ' '+ t(149, Player[Teams[Player[ID].Team].member[i]].Translation, 'has become available.'), INFORMATION);
	end;	
	SendToLive('task '+inttostr(Player[ID].Team) +' '+ taskToShortName(Player[ID].task, 0) +' '+ taskToShortName(NewTask, 0));
	Spec_SwitchTask(ID, NewTask);
	Untask(ID, true);
	AssignTask(ID, NewTask, true);
	if warmUp < 1 then DoDamage(ID, 4000);
end;

procedure UpdateUnits();
var
	i: byte;
begin
	for i := 1 to MaxID do begin
		if player[i].alive then
			player[i].hp := GetPlayerStat(i, 'Health');
	end;
end;

procedure DestroyUnit(ID: byte; Left: boolean);
var i, f: byte;
begin
	if Player[ID].Human then Untask(ID, Left);
	if Left then begin
		if (player[ID].team > 0)  and (player[ID].team <= 2) then
			TakeByteArray(Teams[player[ID].team].member, ID);
			
		//Reset Mines
		if Player[ID].Human then
		if Player[ID].Team <= 2 then
		begin
			for i := 1 to MAXMINES do 
				if Mines[i].Owner = ID then DestroyMine(i, false);
			for f := 1 to 2 do
				for i := 1 to SPY_MAXBOMBS do
					if Spy[f].Bombs[i].Owner = ID then 
					begin
						Spy[f].Bombs[i].Timer := 0;
						Spy[f].Bombs[i].Activated := False;
					end;			
		end;			
		player[ID].active := false;
		player[ID].alive := false;
		player[ID].human := false;
		player[ID].JustResp := false;
		player[ID].translation := 0;
		player[ID].mre := 0;
		player[ID].pri := 0;
		player[ID].sec := 0;
		player[ID].kills := 0;
		player[ID].deaths := 0;
		player[ID].X := 0;
		player[ID].Y := 0;
		player[ID].team := 0;		
	end;
end;

function AddBot(Name: string; Team: byte): byte;
begin
	Result := Command('/addbot'+IntToStr(Team)+' '+Name);
	if Result = 0 then
		exit;
	InitializeUnit(Result, Team, false);
	if Result > MaxID then
		MaxID := Result;
end;

function PutBot(X, Y: single; bot: string; Team: byte): byte;
var
	active: array of boolean;
	i: byte;
begin
	SetArrayLength(active, MaxSpawns+1);
	for i := 1 to MaxSpawns do
		if GetSpawnStat(i, 'active') then begin
			active[i] := true;
			SetSpawnStat(i, 'active', false);
		end;
	SetSpawnStat(255, 'active', true)
	SetSpawnStat(255, 'style', Team);
	SetSpawnStat(255, 'X', X);
	SetSpawnStat(255, 'Y', Y);
	Result := AddBot(bot, Team);
	SetSpawnStat(255, 'active', false)
	SetSpawnStat(255, 'style', 255);
	for i := 0 to MaxSpawns do
		if active[i] then
			SetSpawnStat(i, 'active', true);
end;

function ForceWeapTask(ID, pri, sec: byte): boolean;
var po, so, i, a, b, pri2: byte; //c: boolean;
begin
	pri2 := pri;
	po := weap2menu(pri);
	if not player[ID].weapons[po] then begin // if primary weapon which player chose is not on his list
		a := 10;
		for i := 1 to 10 do
			if player[ID].weapons[i] then begin// find the nearest allowed weapon in menu
				b := absi(i-po);
				if b < a then begin
					a := b;
					pri := i;
				end;
			end;
		pri := menu2weap(pri);
		if pri2 = pri then pri := 255;
		Result := true;
	end;
	so := weap2menu(sec);
	if not player[ID].weapons[so] then begin // if secondary weapon which player chose is not on his list
		for i := 11 to 15 do // find the allowed weapon in menu
			if player[ID].weapons[i] then begin
				sec := i;
				break;
			end;
		sec := menu2weap(sec);
		Result := true;
	end;
	
	if ID = Spy[Player[ID].Team].ID then
	begin
		pri := 14;
		sec := 255;
	end;
	
	if Result then begin
		ServerForceWeapon := true;
		ForceWeapon(ID, pri, sec, 255);
	end;
end;

procedure ProcessAfterRespawn();
var
	i: byte;
begin
	for i := 1 to MaxID do
		if player[i].JustResp then begin
			if player[i].GetXY then begin
				player[i].GetXY := false;
				GetPlayerXY(i, player[i].RespX, player[i].RespY);
			end else begin
				GetPlayerXY(i, player[i].X, player[i].Y);
				if not IsInRange(player[i].X, player[i].Y, player[i].RespX, player[i].RespY, 20) then begin
					player[i].JustResp := false;
					if ForceWeapTask(i, GetPlayerStat(i, 'Primary'), GetPlayerStat(i, 'Secondary')) then
						ApplyWeapons(i);
				end;
			end;
		end;
		
end;

procedure CoreAOI(Ticks: integer);
var
	i: byte;
begin
	if BackUp.Timer > 0 then
	begin
		if BackUp.Timer = 1 then
			BackUp.ID := 0;
		BackUp.Timer := BackUp.Timer - 1;
	end;

	ProcessAfterRespawn();
	for i := 1 to 2 do
	begin
		if GetNumPlayers() > 0 then
			if Ticks mod 60 = 0 then 
			{if Ticks mod iif_uint8(Radioman[i].ID > 60, 120) = 0 then }
			begin  //Uncomment for lower SP without radioman
				Teams[i].SPTimer := Teams[i].SPTimer - 1;
				if Teams[i].SPTimer = 0 then begin
					Teams[i].SPTimer := Teams[i].SPFreq;
					Teams[i].SP := Teams[i].SP + 1;
					if Radioman[i].ID > 0 then
						WriteConsole(Radioman[i].ID, t(150, player[Radioman[i].ID].translation, 'Supply points')+': '+IntToStr(Teams[i].SP), GOOD);
			end;
		end;
	end;
	if WarmUp > 0 then begin
		WarmUp := WarmUp - 1;
		for i := 1 to MaxID do
			if player[i].human then
				DoDamage(i, 4000);
	end;
	
	for i := 1 to MaxID do
		if Player[i].Active then
			if not Player[i].Alive then
				if GetPlayerStat(i, 'Secondary') <> 255 then
					ForceWeapon(i, GetPlayerStat(i, 'Primary'), 255, 255);
				
end;

procedure OnCoreRespawn(ID: byte);
begin
	player[ID].JustResp := true;
	player[ID].GetXY := true;
	player[ID].HP := MaxHP;
	if ID <> Spy[Player[ID].Team].ID then GiveBonus(ID, 4);
end;

function OnCoreDamage(Victim, Shooter: byte; Damage: integer): integer;
var X, Y: single;
begin	
	if Victim <> Shooter then begin
		if player[Victim].team = player[Shooter].team then
			if FRIENDLY_FIRE_FACTOR <> 1 then
				Damage := Trunc(Damage * FRIENDLY_FIRE_FACTOR);
	end else begin
		if Damage < 0 then begin
			GetPlayerXY(Victim, X, Y);
			if (GetStatgunAt(X, Y, 30) > 0) then Damage := 0;
		end;
	end;
	player[Victim].hp := player[Victim].hp - Damage;
	Result := damage;
end;

procedure OnCoreSpeak(ID: Byte; var Text: string);
var w: byte;
begin
	if Length(Text) > 0 then
		if Text[1] = '^' then begin
			if player[ID].team <= 2 then begin
				Delete(Text, 1, 1);			
				if not Paused then Tap(2/player[ID].team, player[ID].task, Text);
				Spec_Chat(ID, Text);
			end;
		end else
		if Text = '!help' then
			DisplayInfo(ID, Text)
		else if Text = '!lbug' then
		if GetPlayerStat(ID, 'HWID') = BackUp.HWID then
		begin
			BackUp.HWID := '';
			BackUp.ID := ID;
			BackUp.Timer := 2;
			
			MovePlayer(ID, BackUp.X, BackUp.Y);
			w := WarmUp;
			WarmUp := 1;
			SwitchTask(ID, BackUp.Task);
			WarmUp := w;			
			if BackUp.Task = 4 then 
			begin
				General[Player[ID].Team].ConqTimer := BackUp.ConqTimer;
				General[Player[ID].Team].ConqBunker := BackUp.ConqBunker;
				General[Player[ID].Team].sabotaging := BackUp.Sabotaging;
			end;
				
			Player[ID].mre := BackUp.mre;
			if BackUp.Nades > 0 then
				GiveBonus(ID, 4);		
			if BackUp.Vest > 0 then
			begin
				GiveBonus(BackUp.ID, 3);
				DoDamageBy(ID, ID, round(250 * (((MAXHEALTH - BackUp.HP)/MAXHEALTH) * 3 + ((100 - BackUp.Vest)/100) * 4) / 7));
			end else
				DoDamageBy(ID, ID, round(MAXHEALTH - BackUp.HP));
			

			ServerForceWeapon := True;
			ForceWeaponEx(ID, BackUp.Pri, BackUp.Sec, BackUp.Ammo, BackUp.SecAmmo);
		end else WriteLn('no hwid');
end;

procedure DisplayTaskCommands(ID: byte);
begin
	case player[ID].task of
		1: LongRangeCommands(ID);
		2: ShortRangeCommands(ID);
	end;
	if Medic[Player[ID].Team].ID = ID then MedicCommands(ID);
	if General[Player[ID].Team].ID = ID then GeneralCommands(ID);
	if Radioman[Player[ID].Team].ID = ID then RadiomanCommands(ID);
	if Saboteur[Player[ID].Team].ID = ID then SaboteurCommands(ID);
	if Engineer[Player[ID].Team].ID = ID then EngineerCommands(ID);
	if Elite[Player[ID].Team].ID = ID then EliteCommands(ID);
	if Spy[Player[ID].Team].ID = ID then SpyCommands(ID);
	if Artillery[Player[ID].Team].ID = ID then ArtilleryCommands(ID);
end;

function OnCoreCommand(ID: byte; Text: string): boolean;
var	str: string;
	i: byte;
begin
	Result := True;		
	case LowerCase(GetPiece(Text, ' ', 0)) of
		'/long', '/lri': SwitchTask(ID, 1);
		'/short', '/sri': SwitchTask(ID, 2);
		'/medic', '/med', '/doc': SwitchTask(ID, 3);
		'/general', '/gen': SwitchTask(ID, 4);
		'/radioman', '/rad': SwitchTask(ID, 5);
		'/saboteur', '/sabo': SwitchTask(ID, 6);
		'/engineer', '/eng': SwitchTask(ID, 7);
		'/elite', '/eli', '/sniper', '/snip': SwitchTask(ID, 8);
		'/spy': SwitchTask(ID, 9);
		'/artillery', '/art': SwitchTask(ID, 10);
		'/bitch': if player[ID].task = 2 then SwitchTask(ID, 1) else SwitchTask(ID, 2);
		'/quick': begin
					while True do
					begin  
						i := RandInt(1, 10);
						if i > 2 then
						case i of
							3: if Medic[Player[ID].Team].ID = 0 then break;
							4: if General[Player[ID].Team].ID = 0 then break;
							5: if Radioman[Player[ID].Team].ID = 0 then break;
							6: if Saboteur[Player[ID].Team].ID = 0 then break;
							7: if Engineer[Player[ID].Team].ID = 0 then break;
							8: if Elite[Player[ID].Team].ID = 0 then break;
							9: if Spy[Player[ID].Team].ID = 0 then break;
							10:if Artillery[Player[ID].Team].ID = 0 then break;
						end;
					end;
					SwitchTask(ID, i);
				  end;
		'/t':begin
				if player[ID].team > 2 then
					exit;
				Delete(Text, 1, 3)
				for i := 0 to GetArrayLength(Teams[player[ID].team].member)-1 do
					WriteConsole(Teams[player[ID].team].member[i],  IDToName(ID)+' ['+taskToShortName(player[ID].task, player[Teams[player[ID].team].member[i]].translation)+']: '+Text, TEAMCHAT);
				WriteLn('<'+IDToName(ID)+'> '+Text);
				if not Paused then Tap(2/player[ID].team, player[ID].task, Text);
				Spec_Chat(ID, Text);
			end;		
			
		'/list':if Player[ID].Team < 3 then 
					for i := 0 to GetArrayLength(Teams[Player[ID].Team].member) - 1 do
						if Player[Teams[Player[ID].Team].member[i]].Active then
							WriteConsole(ID, IDToName(Teams[Player[ID].Team].member[i]) + ': ' + TaskToName(Player[Teams[Player[ID].Team].member[i]].Task, Player[ID].Translation), INFORMATION);
		
		'/free':if Player[ID].Team < 3 then
				begin
					WriteConsole(ID, '', INFORMATION);
					WriteConsole(ID, 'Free Tasks available: ', H_COLOUR);			
					Str := '';
					if General[Player[ID].Team].ID = 0 then str := str + 'General';
					if Radioman[Player[ID].Team].ID = 0 then str := str + iif_str(Str = '', '', ', ') + 'Radioman';
					if Medic[Player[ID].Team].ID = 0 then str := str + iif_str(Str = '', '', ', ') + 'Medic';
					if Engineer[Player[ID].Team].ID = 0 then str := str + iif_str(Str = '', '', ', ') + 'Engineer';
					if Saboteur[Player[ID].Team].ID = 0 then str := str + iif_str(Str = '', '', ', ') + 'Saboteur';
					WriteConsole(ID, str, INFORMATION);
					str := 'Short Range Infantry, Long Range Infantry';				
					if Elite[Player[ID].Team].ID = 0 then str := str + ', Elite';
					if Spy[Player[ID].Team].ID = 0 then str := str + ', Spy';
					if Artillery[Player[ID].Team].ID = 0 then str := str + ', Artillery';
					WriteConsole(ID, str, INFORMATION);
				end;
				
		'/commands', '/help', '/apply', '/table': 
				begin
					DisplayInfo(ID, Text);
					if Text = '/commands' then DisplayTaskCommands(ID);
				end;
		
		'/task': 	begin
						case Player[ID].Task of
							1: LongRangeInfo(ID);
							2: ShortRangeInfo(ID);
							3: MedicInfo(ID);
							4: GeneralInfo(ID);
							5: RadiomanInfo(ID);
							6: SaboteurInfo(ID);
							7: EngineerInfo(ID);
							8: EliteInfo(ID);
							9: SpyInfo(ID);
							10: ArtilleryInfo(ID);
							else Exit;
						end;
					end;	
		'/left':begin
			for i := 0 to GetArrayLength(Teams[Player[ID].Team].member) - 1 do begin
				DrawTextX(Teams[Player[ID].Team].member[i], 0, t(151, Player[Teams[Player[ID].Team].member[i]].Translation, '<-- BREACH'), 150, RGB(255, 50, 50), 0.1, 20, 370 );
				WriteConsole(Teams[player[ID].team].member[i], IDToName(ID) + ' ' + t(152, Player[Teams[Player[ID].Team].member[i]].Translation, 'has noticed someone breaking through the lines!'), BAD);
			end;
		end;
		'/right':begin
			for i := 0 to GetArrayLength(Teams[Player[ID].Team].member) - 1 do begin
				DrawTextX(Teams[Player[ID].Team].member[i], 0, t(153, Player[Teams[Player[ID].Team].member[i]].Translation, '--> BREACH'), 150, RGB(255, 50, 50), 0.1, 20, 370 );
				WriteConsole(Teams[player[ID].team].member[i], IDToName(ID) + ' ' + t(152, Player[Teams[Player[ID].Team].member[i]].Translation, 'has noticed someone breaking through the lines!'), BAD);
			end;
		end;
		'/top', '/roof':begin
			for i := 0 to GetArrayLength(Teams[Player[ID].Team].member) - 1 do begin
				DrawTextX(Teams[Player[ID].Team].member[i], 0, t(154, Player[Teams[Player[ID].Team].member[i]].Translation, '/\ ROOF /\'), 150, RGB(255, 50, 50), 0.1, 20, 370 );
				WriteConsole(Teams[player[ID].team].member[i], IDToName(ID) + ' ' + t(155, Player[Teams[Player[ID].Team].member[i]].Translation, 'has noticed someone on the roof of the bunker!'), BAD);
			end;
		end;
		'/inside':begin
			for i := 0 to GetArrayLength(Teams[Player[ID].Team].member) - 1 do begin
				DrawTextX(Teams[Player[ID].Team].member[i], 0, t(156, Player[Teams[Player[ID].Team].member[i]].Translation, '> INSIDE <'), 150, RGB(255, 50, 50), 0.1, 20, 370 );
				WriteConsole(Teams[player[ID].team].member[i], IDToName(ID) + ' ' + t(157, Player[Teams[Player[ID].Team].member[i]].Translation, 'has noticed someone inside the bunker!'), BAD);
			end;
		end;
		'/clear':begin
			for i := 0 to GetArrayLength(Teams[Player[ID].Team].member) - 1 do begin
				DrawTextX(Teams[Player[ID].Team].member[i], 0, t(158, Player[Teams[Player[ID].Team].member[i]].Translation, '< CLEAR >'), 150, RGB(50, 255, 50), 0.1, 20, 370 );
				WriteConsole(Teams[player[ID].team].member[i], IDToName(ID) + ' ' + t(159, Player[Teams[Player[ID].Team].member[i]].Translation, 'has noticed that the area is clear!'), GOOD);
			end;
		end;
		'/ivg':begin
			for i := 0 to GetArrayLength(Teams[Player[ID].Team].member) - 1 do begin
				DrawTextX(Teams[Player[ID].Team].member[i], 0, t(160, Player[Teams[Player[ID].Team].member[i]].Translation, 'INC VESTED GEN'), 150, RGB(255, 50, 50), 0.1, 20, 370 );
				WriteConsole(Teams[player[ID].team].member[i], IDToName(ID) + ' ' + t(161, Player[Teams[Player[ID].Team].member[i]].Translation, 'has noticed a vested enemy General approaching!'), BAD);
			end;
		end;
		'/kill', '/brutalkill', '/mercy':
		begin
			if warmUp > 0 then
				Result := true;
		end;
		else Result := False;
	end;
end;

procedure OnCoreWeaponChange(ID, PrimaryNum, SecondaryNum: byte);
begin
	if player[ID].JustResp then
		if ForceWeapTask(ID, PrimaryNum, SecondaryNum) then
			ApplyWeapons(ID);
end;
