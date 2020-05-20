procedure m79cGatherStart();
begin
	GatherOn := 2;
	WriteLn('Game started');
end;

procedure m79cGatherEnd();
begin
	gatherEndMessage := '--- gatherend';
	WriteLn(gatherEndMessage);
	EndGather();
end;

procedure m79cOnMapChange(NewMap: string);
begin
	m79cGatherStart();
end;

procedure m79cAppOnIdle(Ticks: integer);
begin
	if GatherOn = 2 then
		if TimeLeft = 2 then
		begin
			m79cGatherEnd();
		end;
end;

procedure m79cOnFlagScore(ID, TeamFlag: byte);
begin
	if GatherOn = 2 then
		m79cGatherEnd();
end;