procedure ResetGame(MapChange: boolean);
var
	i: byte;
begin
	for i := 1 to 2 do begin
		ResetParatrooper(i);
		ResetStrike(i);
		Teams[i].SP := 0;
		ResetEngineer(i, false);
		ResetGeneral(i, false);
		ResetMedic(i, false);
		ResetRadioman(i, false);
		ResetSaboteur(i, false);
		ResetSpy(i, false);
		ResetArtillery(i, false);
		Teams[i].MinesRefreshTimer := 0;
		Teams[i].Mines := 1;
		Teams[i].StatgunRefreshTimer := 0;
		Teams[i].SPFreq := SUPPLYTIME;
		Teams[i].SPTimer := Teams[i].SPFreq;
		if not MapChange then
			SetArrayLength(Teams[i].member, 0);
		if not MapChange then
			SetArrayLength(Teams[i].member, 0);
	end;
	ResetKits();
	ResetMines();
	ClearStatguns();
	ClearBurningAreas();
	ParaQueueClear();
	BackUp.HWID := '';
	BackUp.ID := 0;
	if MapChange then
		Warmup := 3;
end;
