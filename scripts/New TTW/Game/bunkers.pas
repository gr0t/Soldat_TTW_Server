{procedure SetBunker(ID, Team: byte);
var
	i: byte;
begin
	for i := 0 to GetArrayLength(Bunker
end;}
procedure SetMaxSpawns();
begin
	for MaxSpawns := 254 downto 1 do
		if GetSpawnStat(MaxSpawns, 'active') then
			break;
end;

procedure SetBunker(Enabled: boolean; ID, Team: byte);
var
	i: byte;
begin
	Bunker[ID].Enabled := Enabled;
	if Enabled then begin
		Bunker[ID].owner := Team;
		Teams[Team].Bunker := ID;
		if GetArrayLength(Bunker[ID].Spawn[Team]) > 0 then
			for i := 0 to GetArrayLength(Bunker[ID].Spawn[Team])-1 do begin
				SetSpawnStat(Bunker[ID].Spawn[Team][i], 'active', true);
				SetSpawnStat(Bunker[ID].Spawn[Team][i], 'style', Team);
			end;
	end else begin
		Bunker[ID].owner := 0;
		if GetArrayLength(Bunker[ID].Spawn[Team]) > 0 then
			for i := 0 to GetArrayLength(Bunker[ID].Spawn[Team])-1 do begin
				SetSpawnStat(Bunker[ID].Spawn[Team][i], 'active', false);
				SetSpawnStat(Bunker[ID].Spawn[Team][i], 'style', 255);
			end;
	end;
end;

procedure SwapBunker(BunkID, Team: byte; sabotage: boolean);
begin
	if ((Team = 1) and (Teams[2/Team].bunker <= BunkID)) or ((Team = 2) and (Teams[2/Team].bunker >= BunkID)) then begin
		SetBunker(false, Teams[2/Team].bunker, 2/Team); //turn off old one
		Teams[2/Team].bunker := BunkID+iif_sint8(Team = 2, -1, 1); //upload vars
		SetBunker(true, Teams[2/Team].bunker, 2/Team); //tur on new one
	end;
	if not sabotage then begin
		SetBunker(false, Teams[Team].bunker, Team);
		Teams[Team].bunker := BunkID;
		SetBunker(true, BunkID, Team);
	end;
	updateBunkers();
end;

//Spawnpoint quicksort implementaion. Sorts by X position.
procedure SpawnSort(var spawns: array of tSpawnpoint; l,r:integer);
var
	b: tSpawnpoint;
	pivot: single;
	i, j: integer;
begin
	if l < r then
	begin
		pivot := spawns[random(l+1, r+1)].X;
		i := l-1;
		j := r+1;
		repeat
			repeat i := i+1 until pivot <= spawns[i].X;
			repeat j := j-1 until pivot >= spawns[j].X;
			b := spawns[i];
			spawns[i] := spawns[j];
			spawns[j] := b;
		until i >= j;
		spawns[j] := spawns[i];
		spawns[i] := b;
		SpawnSort(spawns,l,i-1);
		SpawnSort(spawns,i,r);
	end;
end;

procedure InitializeBunkers_File(Path: string);
var
	file: string;
	Position: word;
	i, j, k: byte;
	bunkernum: shortint;
	X: single;
begin
	file := ReadFile(Path);
	file := Copy(file, 1, Length(file)-6);
	bunkernum := -1;
	Position := Pos(' ', file);
	i := 0;
	while Position > 0 do begin
		case i mod 5 of
			0: begin
				bunkernum := bunkernum + 1;
				SetArrayLength(Bunker, bunkernum+1);
				Bunker[bunkernum].X1 := StrToFloat(Copy(file, 1, Position-1));
			end;
			1: Bunker[bunkernum].X2 := StrToFloat(Copy(file, 1, Position-1));
			2: Bunker[bunkernum].ReinforcmentX := StrToFloat(Copy(file, 1, Position-1));
			3: Bunker[bunkernum].ReinforcmentY := StrToFloat(Copy(file, 1, Position-1));
			4: begin
				case StrToInt(Copy(file, 1, Position-1)) of
					0: Bunker[bunkernum].style := 0;
					1: Bunker[bunkernum].style := -2;
					2: Bunker[bunkernum].style := 2;
					3: Bunker[bunkernum].style := 1;
					4: Bunker[bunkernum].style := -1;
				end;
			end;
		end;
		delete(file, 1, Position);
		Position := Pos(' ', file);
		i := i + 1;
	end;
	for i := 0 to GetArrayLength(Bunker)-1 do
		for j := 1 to MaxSpawns do
			if GetSpawnStat(j, 'active') then begin
				k := GetSpawnStat(j, 'Style')
				if (k = 1) or (k = 2) then begin
					X := GetSpawnStat(j, 'X');
					if IsBetween(Bunker[i].X1, Bunker[i].X2, X) then begin
						PushByteArray(Bunker[i].Spawn[k], j);
					end;
				end;
			end;
end;

procedure InitializeBunkers_Map();
var
	Spawnpoint: array of tSpawnpoint;
	i: byte;
	bunk: shortint;
	InBunker: boolean;
begin
	SetArrayLength(Spawnpoint, MaxSpawns+1);
	for i := 1 to MaxSpawns do begin
		//i assume that all spawnpoints to MaxSpawns are active
		Spawnpoint[i].active := true;
		Spawnpoint[i].ID := i;
		Spawnpoint[i].style := GetSpawnStat(i, 'style');
		Spawnpoint[i].X := GetSpawnStat(i, 'X');
		Spawnpoint[i].Y := GetSpawnStat(i, 'Y');
	end;
	bunk := -1;
	SpawnSort(Spawnpoint, 1, MaxSpawns);
	for i := 1 to MaxSpawns do begin
		case Spawnpoint[i].style of
			1, 2: if InBunker then begin
				PushByteArray(Bunker[bunk].Spawn[Spawnpoint[i].style], Spawnpoint[i].ID);
			end;
			5, 6, 7, 8: continue; //flags (5, 6), kits (7, 8)
			ABASE_SPAWNSTYLE: if InBunker then begin
				Bunker[bunk].style := -2;
				Bunker[bunk].ReinforcmentX := Spawnpoint[i].X;
				Bunker[bunk].ReinforcmentY := Spawnpoint[i].Y;
			end;
			ACONQ_SPAWNSTYLE: if InBunker then begin
				Bunker[bunk].style := -1;
				Bunker[bunk].ReinforcmentX := Spawnpoint[i].X;
				Bunker[bunk].ReinforcmentY := Spawnpoint[i].Y;
			end;
			CONQ_SPAWNSTYLE: if InBunker then begin
				Bunker[bunk].style := 0;
				Bunker[bunk].ReinforcmentX := Spawnpoint[i].X;
				Bunker[bunk].ReinforcmentY := Spawnpoint[i].Y;
			end;
			BCONQ_SPAWNSTYLE: if InBunker then begin
				Bunker[bunk].style := 1;
				Bunker[bunk].ReinforcmentX := Spawnpoint[i].X;
				Bunker[bunk].ReinforcmentY := Spawnpoint[i].Y;
			end;
			BBASE_SPAWNSTYLE: if InBunker then begin
				Bunker[bunk].style := 2;
				Bunker[bunk].ReinforcmentX := Spawnpoint[i].X;
				Bunker[bunk].ReinforcmentY := Spawnpoint[i].Y;
			end;
			X_DELIMITER: begin
				if InBunker then begin
					InBunker := false;
					Bunker[bunk].X2 := Spawnpoint[i].X;
				end else begin
					InBunker := true;
					bunk := bunk + 1;
					SetArrayLength(Bunker, bunk+1);
					Bunker[bunk].X1 := Spawnpoint[i].X;
				end;
			end;
		end;
		//SetSpawnStat(Spawnpoint[i].ID, 'active', false);
		//SetSpawnStat(Spawnpoint[i].ID, 'style', 255);
	end;
end;

procedure InitializeBunkers(Map: string);
var
	i: byte;
begin
	SetArrayLength(Bunker, 0);
	SetMaxSpawns();
	Debug(1, 'Initializing bunkers...');
	if FileExists('bunkers/'+Map+'.txt') then begin
		Debug(2, 'found file, parsing...');
		InitializeBunkers_File('bunkers/'+Map+'.txt');
	end else begin
		Debug(2, 'File not found, parsing map...');
		InitializeBunkers_Map();
	end;
	Debug(1, 'Done, '+IntToStr(GetArrayLength(Bunker))+' bunkers loaded');
	for i := 0 to GetArrayLength(Bunker)-1 do
		case Bunker[i].style of
			-2: begin
				SetBunker(false, i, 2);
				SetBunker(true, i, 1);
			end;
			-1,0,1: begin
				SetBunker(false, i, 1);
				SetBunker(false, i, 2);
			end;
			2: begin
				SetBunker(false, i, 1);
				SetBunker(true, i, 2);
			end;
		end;
end;
