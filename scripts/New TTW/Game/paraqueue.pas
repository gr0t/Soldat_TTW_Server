function FindParatrooper(): Byte;
var
	i: shortint;
begin
	Result := 0;	
	if GetArrayLength(ParatrooperQueue) > 0 then begin
		for i := 0 to GetArrayLength(ParatrooperQueue)-1 do
			if player[ParatrooperQueue[i]].Team = 5 then begin
				Result := ParatrooperQueue[i];
				for i := i + 1 to GetArrayLength(ParatrooperQueue)-1 do
					ParatrooperQueue[i-1] := ParatrooperQueue[i];
				ParatrooperQueue[i-1] := Result;
			end;
	end;
end;

procedure CheckHWID(ID: Byte; HWID: string);
var
	len: shortint;
begin
	if IDToHW(ID) = HWID then begin
		len := GetArrayLength(ParatrooperQueue);
		SetArrayLength(ParatrooperQueue, len+1);
		ParatrooperQueue[len] := ID;
		WriteConsole(ID, 'You''ll be put as a paratrooper as soon as one is called', $FF99FF99);
		WriteLn(IDToName(ID) + ' added to paratrooper queue');
	end;
end;

procedure ResetParatrooper(Team: Byte); forward;

procedure ParaQueueOnLeaveGame(ID: Byte);
var
	i: shortint;
begin
	for i := 1 to 2 do
		if ID = Paratrooper[i] then
			ResetParatrooper(i);
	for i := 0 to GetArrayLength(ParatrooperQueue)-1 do
 		if ID = ParatrooperQueue[i] then begin
			for i := i to GetArrayLength(ParatrooperQueue)-2 do
				ParatrooperQueue[i] := ParatrooperQueue[i+1];
			SetArrayLength(ParatrooperQueue, GetArrayLength(ParatrooperQueue)-1);
			break;
		end;
end;

procedure ParaQueueClear();
begin
	SetArrayLength(ParatrooperQueue, 0);
end;

procedure PutParatrooper(X, Y: single; ID, Team: byte);
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
	for i := 0 to 14 do
		// prevent race conditions in packets
		if i <> 9 then
			SetWeaponActive(ID, i, false);
	SetWeaponActive(ID, 9, true);	
	SetTeam(ID, Team, true);
	SetSpawnStat(255, 'active', false)
	SetSpawnStat(255, 'style', 255);
	for i := 0 to MaxSpawns do
		if active[i] then
			SetSpawnStat(i, 'active', true);
end;