const
	cMsg = $C89850;
	
procedure porGatherEnd(portals: byte);
begin
	gatherEndMessage := '--- gatherend ' + IntToStr(portals);
	acknowledge := true;
	WriteLn(gatherEndMessage);
	EndGather();
end;

procedure porAppOnIdle(Ticks: integer);
begin
	if TimeLeft = 1 then
		EndGather();
end;

procedure porOnJoinGame(ID, Team: Byte);
begin
	if AlphaPlayers = GatherSize then
		if GatherOn < 1 then
		begin
			WriteLn('--- gatherstart');
			WriteConsole(0, 'Chamber loaded. ' + IntToStr(GatherSize) + ' subjects participating. Good luck.', cMsg);
			GatherOn := 1;
			SetGatherOn := true;
			Writeln('USERS JOINED, GATHER RESTART!');
			UnpauseGame(True);
			Command('/map ' + CurrentMap);
		end;
end;