procedure LongRangeCommands(ID: byte);
begin
	WriteConsole(ID, t(59, Player[ID].Translation, '/mre    - meal ready to eat, regenerates 50% hp'), C_COLOUR);
end;

procedure LongRangeInfo(ID: byte);
begin
	WriteConsole(ID, t(60, player[ID].translation, 'You are the Long Range Infantry'), H_COLOUR);
	WriteConsole(ID, t(61, player[ID].translation, 'You have a meal ready to eat (mre). To eat it, do /mre (regenerates 50% hp)'), I_COLOUR);			
	LongRangeCommands(ID);
end;

procedure AssignLongRange(ID: byte);
begin
	player[ID].mre := 1;
	player[ID].weapons[3] := true;
	player[ID].weapons[4] := true;
	player[ID].weapons[6] := true;
	player[ID].weapons[9] := true;
	player[ID].weapons[14] := true;
	LongRangeInfo(ID);
end;
