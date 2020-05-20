procedure SpawnKit(X, Y: single; Style: byte);
var
	i: byte;
begin
	for i := 0 to MAXKITS do
		if not kit[i].active then begin
			kit[i].ID := SpawnObject(X, Y, Style);
			kit[i].X := X;
			kit[i].Y := Y;
			kit[i].active := true;
			kit[i].duration := KITDURATION;
			break;
		end;
end;

procedure KillKit(ID: byte);
begin
	kit[ID].active := false;
	if GetObjectStat(kit[ID].ID, 'Active') then
		KillObject(kit[ID].ID);
end;

procedure ProcessKits();
var
	i: byte;
	x, y: single;
begin
	for i := 0 to MAXKITS do
		if kit[i].active then
			if kit[i].duration > 0 then begin
				kit[i].duration := kit[i].duration - 1;
				x := GetObjectStat(kit[i].ID, 'X');
				y := GetObjectStat(kit[i].ID, 'Y');
				if (abs(kit[i].x -x) > KITMAXXDISTANCE ) or (abs(kit[i].y - y) > KITMAXYDISTANCE) then begin
					KillKit(i);
					continue;
				end;
				kit[i].x := x;
				kit[i].y := y;
			end else KillKit(i);
end;

procedure ResetKits();
var
	i: byte;
begin
	for i := 0 to MAXKITS do
		KillKit(i);
end;

procedure KitsAOI();
begin
	ProcessKits();
end;

