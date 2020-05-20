const
	INTERCEPTWAITTIME = 140;
	INTERCEPTTIME = 45;
	SCRAMBLE = true;
	SCRAMBLE_CHANCE = 16;
	SCRAMBLE_FREQUENCY = 30;
	PARA_SPAWN_HEIGHT = 1200;
	
	BOTNAME = 'paratrooper';
	
	LAWNUMBER = 5;

type
	tRadioman = record
		ID, Kills: byte;
		TapCounter: smallint;
		KickPara: boolean;
		KillTick: Cardinal;
	end;

var
	Radioman: array[1..2] of tRadioman;
	Paratrooper: array[1..2] of byte;
	AIRCOCOST, ZEPPELINCOST, BARRAGECOST, HOWITZERCOST, NAPALMCOST, CLUSTERSTRIKECOST, GRENADECOST, CLUSTERCOST, BURSTCOST,
	MEDICOST, VESTCOST, LAWCOST, PARATROOPERCOST, DESTROYSGCOST, ENEMYBASECOST, HACCOST, FLAMERCOST: BYTE;

procedure RadiomanCommands(ID: byte);
begin
	WriteConsole(ID, t(71, Player[ID].Translation, '/tap    - taps into enemy team chat'), C_COLOUR);
	WriteConsole(ID, t(72, Player[ID].Translation, '/supply - shows a list of supplies you can order'), C_COLOUR);
	WriteConsole(ID, t(73, Player[ID].Translation, '/strike - shows a list of available airstrikes'),C_COLOUR);
end;
	
procedure RadiomanInfo(ID: byte);
begin
	WriteConsole(ID, t(74, player[ID].translation, 'You are the Radioman'), H_COLOUR );
	WriteConsole(ID, t(75, player[ID].translation, 'Your task is ordering supply. You can also call'), I_COLOUR );
	WriteConsole(ID, t(76, player[ID].translation, 'airstrikes and tap into enemy communication.'), I_COLOUR );
	RadiomanCommands(ID);
end;

procedure SupplyList(ID: byte);
begin
	WriteConsole(ID, '', INFORMATION );
	WriteConsole(ID, t(77, player[ID].translation, 'Reinforcements (will be delivered at bunker)'), H_COLOUR);
	WriteConsole(ID, t(78, player[ID].translation, '/grenade  grenade pack')+' ('+inttostr(GRENADECOST)+')', C_COLOUR);
	WriteConsole(ID, t(79, player[ID].translation, '/vest     bulletproof vest (/vestgen to vest the General)')+' ('+inttostr(VESTCOST)+')', C_COLOUR);
	WriteConsole(ID, t(80, player[ID].translation, '/medi     medikit')+' ('+inttostr(MEDICOST)+')', C_COLOUR);
	WriteConsole(ID, t(81, player[ID].translation, '/cluster  cluster grenades')+' ('+inttostr(CLUSTERCOST)+')', C_COLOUR);
	WriteConsole(ID, t(82, player[ID].translation, '/law      5 LAW launchers')+' ('+inttostr(LAWCOST)+')', C_COLOUR);
	WriteConsole(ID, t(83, player[ID].translation, '/hac      heavy artillery cannon')+' ('+inttostr(HACCOST)+')', C_COLOUR);
	WriteConsole(ID, t(0, player[ID].translation, '/flamer    Flamethrower M2A1-2')+' ('+inttostr(FLAMERCOST)+')', C_COLOUR);
	WriteConsole(ID, t(84, player[ID].translation, 'Other orders:'), H_COLOUR );
	WriteConsole(ID, t(85, player[ID].translation, '/para     paratrooper over enemy bunker')+' ('+inttostr(PARATROOPERCOST)+')', C_COLOUR);
	WriteConsole(ID, t(86, player[ID].translation, 'for list of available strikes write /strike'), C_COLOUR);
end;

procedure StrikeList(ID: byte);
begin
	WriteConsole(ID, t(87, player[ID].translation, 'Available airstrikes:'), H_COLOUR );
	WriteConsole(ID, t(88, player[ID].translation, '/zeppelin - zeppelin airstrike')+' ('+inttostr(ZEPPELINCOST)+')', C_COLOUR);
	WriteConsole(ID, t(89, player[ID].translation, '/airco    - airco airstrike')+' ('+inttostr(AIRCOCOST)+')', C_COLOUR);
	WriteConsole(ID, t(90, player[ID].translation, '/barrage  - mortar barrage')+' ('+inttostr(BARRAGECOST)+')', C_COLOUR);
	WriteConsole(ID, t(91, player[ID].translation, '/napalm   - napalm strike')+' ('+inttostr(NAPALMCOST)+')', C_COLOUR);
	WriteConsole(ID, t(92, player[ID].translation, '/cluststr - cluster strike')+' ('+inttostr(CLUSTERSTRIKECOST)+')', C_COLOUR);
	WriteConsole(ID, t(93, player[ID].translation, '/nuke     - nuke strike')+' ('+inttostr(HOWITZERCOST)+')', C_COLOUR);
	WriteConsole(ID, t(94, player[ID].translation, '/enemy    - enemy base strike')+' ('+inttostr(ENEMYBASECOST)+')', C_COLOUR);
	WriteConsole(ID, t(95, player[ID].translation, '/burst    - enemy entrance strike')+' ('+inttostr(BURSTCOST)+')', C_COLOUR);
end;

procedure AssignRadioman(ID, Team: byte);
begin
	Radioman[Team].ID := ID;
	Radioman[Team].TapCounter := INTERCEPTWAITTIME;
	player[ID].weapons[3] := true;
	player[ID].weapons[4] := true;
	player[ID].weapons[6] := true;
	player[ID].weapons[9] := true;
	player[ID].weapons[11] := true;
	player[ID].weapons[12] := true;
	player[ID].weapons[14] := true;
	RadiomanInfo(ID);
end;

procedure AssignParatrooper(ID, Team: byte);
begin
	Paratrooper[Team] := ID;
	player[ID].weapons[9] := true;
end;

procedure ResetRadioman(Team: byte; left: boolean);
begin
	if left then Radioman[Team].ID := 0;
	Radioman[Team].TapCounter := INTERCEPTWAITTIME;
	Radioman[Team].KillTick := 0;
	Radioman[Team].Kills := 0;
end;

procedure Tap(Team, Task: shortint; Text: string);
var
	i: word;
begin
	if Radioman[Team].TapCounter < 0 then begin
		if SCRAMBLE then
			if RandInt(1, 100) <= SCRAMBLE_CHANCE then
				for i := 1 to Length(Text) do
					if RandInt(1, 100) <= SCRAMBLE_FREQUENCY then
						Text[i] := '.';
		if GetArrayLength(Teams[Team].member) > 0 then
			for i := 0 to GetArrayLength(Teams[Team].member)-1 do
				WriteConsole(Teams[Team].member[i], '[' + TaskToShortName(Task, player[Teams[Team].member[i]].translation) + ']: '+Text, TAPCOLOUR);
	end;
end;
