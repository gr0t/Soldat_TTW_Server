const 
	STATGUN_COOLDOWN_TIME = 65;
	STATGUN_REPAIR_TIME = 3;
	STATGUN_BUILD_TIME = 7;
	STATGUN_RETRIEVE_TIME = 3;
	STATGUN_DISTANCE = 20;

type
	tEngineer = record
		ID, Timer, ProcID: byte;
		BuildX, BuildY: single;
	end;

var
	Engineer: array[1..2] of tEngineer;

procedure EngineerCommands(ID: byte);
begin
	WriteConsole(ID, t(96, Player[ID].Translation, '/build  - constructs a stationary gun'), C_COLOUR);
	WriteConsole(ID, t(97, Player[ID].Translation, '/get    - deconstructs a stationary gun'), C_COLOUR);
	WriteConsole(ID, t(98, Player[ID].Translation, '/fix    - repairs a broken stationary gun'), C_COLOUR);
	WriteConsole(ID, t(99, Player[ID].Translation, '/mine   - places a landmine'), C_COLOUR);
end;	

procedure EngineerInfo(ID: byte);
begin
	WriteConsole(ID, t(100, Player[ID].Translation, 'You are the Engineer'), H_COLOUR);
	WriteConsole(ID, t(101, Player[ID].Translation, 'You can build stationary guns and place landmines'), I_COLOUR);	
	EngineerCommands(ID);
end;

procedure AssignEngineer(ID, Team: byte);
begin
	Engineer[Team].ID := ID;
	player[ID].weapons[1] := true;
	player[ID].weapons[2] := true;
	player[ID].weapons[11] := true;
	EngineerInfo(ID);
end;

procedure ResetEngineer(Team: byte; left: boolean);
begin
	if left then Engineer[Team].ID := 0;
	Engineer[Team].Timer := 0;
	Engineer[Team].ProcID := 0;
	Engineer[Team].BuildX := 0;
	Engineer[Team].BuildY := 0;
end;
