const
	MEDIC_TEAM_HEAL = 20;
	MEDIC_HEAL_RANGE= 100;
	KIT_COOLDOWN = 12;


type
	tMedic = record
		ID: byte;
		KitCooldown: integer;
	end;

var
	Medic: array[1..2] of tMedic;

procedure MedicCommands(ID: byte);
begin
	WriteConsole(ID, t(63, Player[ID].Translation, '/kit    - drops a medical kit near you'),C_COLOUR);
//	WriteConsole(ID, t(0, Player[ID].Translation, '/vet    - heals nearest teammate'),C_COLOUR);
	WriteConsole(ID, t(0, Player[ID].Translation, '/vetme    - heals yourself'),C_COLOUR);
end;

procedure MedicInfo(ID: byte);
begin
	WriteConsole(ID, t(64, player[ID].translation, 'You are the Medic'), H_COLOUR);
	WriteConsole(ID, t(0, player[ID].translation, 'You get a medkit each spawn and after ' + inttostr(KIT_COOLDOWN) + ' seconds.'), I_COLOUR);
	WriteConsole(ID, t(0, player[ID].translation, 'You can drop it or heal someone directly by switching weapons'), I_COLOUR);
	MedicCommands(ID);
end;

procedure AssignMedic(ID, Team: byte);
begin
	Medic[Team].ID := ID;
  player[ID].weapons[2] := true;
	player[ID].weapons[4] := true;
	player[ID].weapons[11] := true;
	MedicInfo(ID);
end;

procedure ResetMedic(Team: byte; left: boolean);
begin
	if left then Medic[Team].ID := 0;
end;
