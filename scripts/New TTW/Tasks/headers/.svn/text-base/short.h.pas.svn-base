procedure ShortRangeCommands(ID: byte);
begin
	WriteConsole(ID, t(59, Player[ID].Translation, '/mre    - meal ready to eat, regenerates 50% hp'), C_COLOUR);
end;

procedure ShortRangeInfo(ID: byte);
begin
	WriteConsole(ID, t(62, player[ID].translation, 'You are the Short Range Infantry'), H_COLOUR);
	WriteConsole(ID, t(61, player[ID].translation, 'You have a meal ready to eat (mre). To eat it, do /mre (regenerates 50% hp)'), I_COLOUR);			
	ShortRangeCommands(ID);
end;

procedure AssignShortRange(ID: byte);
begin
	player[ID].mre := 1;
	player[ID].weapons[1] := true;
	player[ID].weapons[2] := true;
	player[ID].weapons[5] := true;
	player[ID].weapons[11] := true;
	player[ID].weapons[12] := true;
	player[ID].weapons[13] := true;
	ShortRangeInfo(ID);
end;
