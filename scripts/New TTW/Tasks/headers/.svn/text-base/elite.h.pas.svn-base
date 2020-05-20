type
	tElite = record
		ID: byte;
	end;

	
var
	Elite: array[1..2] of tElite;
	
	
procedure EliteCommands(ID: byte);
begin
	WriteConsole(ID, t(113, player[ID].translation, 'Elite does not have any Task-specific commands.'), C_COLOUR);
end;
	
procedure EliteInfo(ID: byte);
begin
	WriteConsole(ID, t(114, player[ID].translation, 'You are now the Elite'), H_COLOUR);
	WriteConsole(ID, t(115, Player[ID].Translation, 'Your task is providing sniper cover.'), I_COLOUR);
	EliteCommands(ID);
end;

procedure AssignElite(ID, Team: byte);
begin
	Elite[Team].ID := ID;
	player[ID].weapons[8] := true;
	player[ID].weapons[11] := true;
	player[ID].weapons[12] := true;	
	EliteInfo(ID);
end;

procedure ResetElite(Team: byte; left: boolean);
begin
	Elite[Team].ID := 0;
end;
