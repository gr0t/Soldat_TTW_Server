const
	MMOD_SCORE_LIMIT = 7;

procedure mmodInitialise();
begin
	CrossFunc([GatherSize], CoreDir + 'SetGatherSize');
end;

procedure mmodGatherStart();
begin
	GatherOn := 2;
	WriteLn('Game started');
end;

procedure mmodGatherEnd();
begin
	if capsRed > capsBlue then
		gatherEndMessage := '--- gatherend 1 ' + IntToStr(capsRed) + ' ' + IntToStr(capsBlue)
	else if capsBlue > capsRed then
		gatherEndMessage := '--- gatherend 2 ' + IntToStr(capsRed) + ' ' + IntToStr(capsBlue)
	else gatherEndMessage := '--- gatherend 0 ' + IntToStr(capsRed) + ' ' + IntToStr(capsBlue);

	acknowledge := true;
	WriteLn(gatherEndMessage);

	if capsRed > capsBlue then 
		WriteConsole(0,'Alpha Won The Match With '+IntToStr(Trunc(capsRed))+' scores!',GOOD)		
	else if capsBlue > capsRed then
		WriteConsole(0,'Bravo Won The Match With '+IntToStr(Trunc(capsBlue))+' scores!',GOOD)
	else WriteConsole(0,'It''s a tie!',GOOD);
	EndGather();
end;

procedure mmodOnMapChange(NewMap: string);
begin
	if CrossFunc([], CoreDir + 'GetMapStatus') >= 3 then
		mmodGatherStart();
end;

procedure mmodAppOnIdle(Ticks: integer);
begin
	if GatherOn = 2 then
		if TimeLeft = 21 then
		begin
			mmodGatherEnd();
		end;
end;

procedure mmodOnFlagScore(ID, TeamFlag: byte);
begin
	if GatherOn = 2 then
		if (capsRed = MMOD_SCORE_LIMIT) or (capsBlue = MMOD_SCORE_LIMIT) then
			mmodGatherEnd();
end;