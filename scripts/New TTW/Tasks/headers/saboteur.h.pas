type
	tSaboteur = record
		ID, RigTimer, SGTeam: byte;
	end;

var
	Saboteur: array[1..2] of tSaboteur;
	
const
	SABO_RIGTIME = 3;

procedure SaboteurCommands(ID: byte);
begin
	WriteConsole(ID, t(59, Player[ID].Translation, '/mre    - meal ready to eat, regenerates 50% hp'), C_COLOUR);
	WriteConsole(ID, t(102, Player[ID].Translation, '/rig    - destroys nearby stationary gun or mine'), C_COLOUR);
end;
	
procedure SaboteurInfo(ID: byte);
begin
	WriteConsole(ID, t(103, player[ID].translation, 'You are the Saboteur'), H_COLOUR);
	WriteConsole(ID, t(61, player[ID].translation, 'You have a meal ready to eat (mre). To eat it, do /mre (regenerates 50% hp)'), I_COLOUR);			
	WriteConsole( ID, t(104, player[ID].translation, 'You can rig mines and stationary guns with /rig'), I_COLOUR );	
	SaboteurCommands(ID);
end;

procedure AssignSaboteur(ID, Team: byte);
begin
	Saboteur[Team].ID := ID;
	player[ID].mre := 1;
	player[ID].weapons[1] := true;
	player[ID].weapons[2] := true;
	player[ID].weapons[5] := true;
	player[ID].weapons[11] := true;
	player[ID].weapons[12] := true;
	player[ID].weapons[13] := true;
	SaboteurInfo(ID);
end;

procedure ResetSaboteur(Team: byte; left: boolean);
begin
	if left then Saboteur[Team].ID := 0;
	if Saboteur[Team].RigTimer > 0 then Saboteur[Team].ID := StrikeBot;
end;
