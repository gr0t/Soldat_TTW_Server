procedure DestroyStat(Team: byte);
begin
	KillObject(SG[Team].ID);
	sleep(50);
	KillObject(SG[Team].ID);	
	SG[Team].ID := 0;
	SG[Team].X := 0;
	SG[Team].Y := 0;
	SG[Team].placed := false;
end;

procedure CreateStat(Team: byte; X, Y: single);
begin
	SG[Team].ID := SpawnObject(X, Y - 10, 15);
	SG[Team].X := X;
	SG[Team].Y := Y;
	SG[Team].placed := true;
end;

procedure ClearStatguns();
var
	i: byte;
begin
	for i := 1 to MAXSTATGUNS do
		DestroyStat(i);
end;

procedure StatgunsAOI(Team: byte);
var
	r: byte;
begin
	if Teams[Team].StatgunRefreshTimer > 0 then begin
		Teams[Team].StatgunRefreshTimer := Teams[Team].StatgunRefreshTimer - 1;
		if Teams[Team].StatgunRefreshTimer = 0 then begin
			if Engineer[Team].ID > 0 then
				WriteConsole(Engineer[Team].ID, t(121, player[Engineer[Team].ID].translation, 'Statgun ready to be built!'), GOOD)
			else If GetArrayLength(Teams[Team].member) > 0 then
				for r := 0 to GetArrayLength(Teams[Team].member)-1 do
					WriteConsole(Teams[Team].member[r], t(121, Player[Teams[Team].member[r]].Translation, 'Statgun ready to be built!'), GOOD);
		end;
	end;
end;

function GetStatgunAt(X, Y: Single; Range: Integer): Byte;
var i: byte;
begin
	Result:=0;
	for i := 1 to MAXSTATGUNS do
		if SG[i].placed then
			if IsInRange(SG[i].X, SG[i].Y, X, Y, Range) then 
			begin
				Result := i;
				break;
			end;
end;
