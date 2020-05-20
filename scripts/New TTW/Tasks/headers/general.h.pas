const
	CONQUERTIME = 6;

type
	tGeneral = record
		ID, ConqTimer, ConqBunker: byte;
		sabotaging: boolean;
	end;

var
	General: array[1..2] of tGeneral;

procedure GeneralCommands(ID: byte);
begin
	WriteConsole(ID, t(59, Player[ID].Translation, '/mre    - meal ready to eat, regenerates 50% hp'), C_COLOUR);
	WriteConsole(ID, t(67, Player[ID].Translation, '/conq   - conquers bunker you are in'), C_COLOUR);
end;
	
procedure GeneralInfo(ID: byte);
begin
	WriteConsole(ID, t(68, player[ID].translation, 'You are the General'), H_COLOUR );
	WriteConsole(ID, t(69, player[ID].translation, 'Your task is conquering bunkers making them new '), I_COLOUR );
	WriteConsole(ID, t(70, player[ID].translation, 'spawn positions for your team.'), I_COLOUR );
	GeneralCommands(ID);
end;

procedure AssignGeneral(ID, Team: byte);
begin
	General[Team].ID := ID;
	player[ID].weapons[1] := true;
	player[ID].weapons[3] := true;
	player[ID].weapons[11] := true;
	player[ID].weapons[12] := true;
	GeneralInfo(ID);
end;

procedure ResetGeneral(Team: byte; left: boolean);
begin
	if left then General[Team].ID := 0;
	General[Team].ConqTimer := 0;
	General[Team].ConqBunker := 0;
	General[Team].sabotaging := false;
end;
