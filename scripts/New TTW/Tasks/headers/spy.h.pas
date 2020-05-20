const
	SPY_MAXBOMBS = 3;
	SPY_MIN_TIMER = 3;
	SPY_MAX_TIMER = 9;
	SPY_OBSERVE_TIME = 20;
	SPY_OBSERVE_RANGE = 400;

type
	tBomb = record
		X, Y: Single;
		Timer: byte;
		Activated: boolean;
		Owner: byte;
	end;	
	
	tSpy = record
		ID: byte;
		BombsLeft: byte;
		ObsTimer: byte;
		Stealth: boolean;
		Bombs: array[1..SPY_MAXBOMBS] of tBomb;
	end;

	
var
	Spy: array[1..2] of tSpy;
	
procedure SpyCommands(ID: byte);
begin
	WriteConsole(ID, t(105, Player[ID].Translation, '/place <time> - place a timed charge'), C_COLOUR);
	WriteConsole(ID, t(106, Player[ID].Translation, '/act          - activate timers'), C_COLOUR);
	WriteConsole(ID, t(107, Player[ID].Translation, '/obs          - spy on a nearby enemy'), C_COLOUR);
	WriteConsole(ID, t(108, Player[ID].Translation, '/stealth      - activates stealthpack'), C_COLOUR);
end;
	
procedure SpyInfo(ID: byte);
begin
	WriteConsole(ID, t(109, player[ID].translation, 'You are now the Spy'), H_COLOUR);
	WriteConsole(ID, t(110, Player[ID].Translation, 'You have one stealth pack per life.'), I_COLOUR);
	WriteConsole(ID, t(111, player[ID].translation, 'You can place and activate timed charges'), I_COLOUR);			
	WriteConsole(ID, t(112, player[ID].translation, 'You can rig stationary guns with them and spy on the enemies'' tasks'), I_COLOUR);	
	SpyCommands(ID);
end;

procedure AssignSpy(ID, Team: byte);
begin
	Spy[Team].ID := ID;
	Spy[Team].ObsTimer := SPY_OBSERVE_TIME;
	player[ID].weapons[12] := true;
	Spy[Team].BombsLeft := 0;
	SpyInfo(ID);
end;

procedure ResetSpy(Team: byte; left: boolean);
var i: byte;
begin
	for i := 1 to 10 do
		SetWeaponActive(Spy[Team].ID, i, True);
	if left then Spy[Team].ID := 0;
	for i := 1 to SPY_MAXBOMBS do
		if Spy[Team].Bombs[i].Activated = False then
			Spy[Team].Bombs[i].Timer := 0;
end;
