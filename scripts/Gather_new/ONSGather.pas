procedure onsGatherEnd(winnerTeam, nodesAlpha, nodesBravo: byte);
begin
	gatherEndMessage := '--- gatherend ' + IntToStr(winnerTeam) + ' ' + IntToStr(nodesAlpha) + ' ' + IntToStr(nodesBravo);
	acknowledge := true;
	Writeln(gatherEndMessage);
	EndGather();
end;

procedure onsAppOnIdle(Ticks: integer);
begin
	if GatherOn = 2 then
		if TimeLeft = 1 then
		begin
			CrossFunc([0], CoreDir + 'EndGame');
		end;
end;
