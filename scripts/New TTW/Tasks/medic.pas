procedure Heal(Doc, ID: byte);
begin
	GiveHealth(ID, MEDIC_TEAM_HEAL);
	DrawTextX(Doc, 40, t(164, player[Doc].translation, 'Soldier is at full health'),100, RGB(50,50,255), 0.1, 20, 370 );
	DrawTextX(ID, 40, t(165, player[ID].translation, 'Fully healed!'),100, RGB(50,50,255), 0.1, 20, 370 );
	Medic[Player[Doc].Team].KitCooldown := KIT_COOLDOWN;
end;

procedure DropMedkit(ID: byte);
begin
	GetPlayerXY(ID, player[ID].X, player[ID].Y);
	SpawnKit(player[ID].X + iif_sint8(GetPlayerStat(ID, 'Direction') = '>', 20, -20), player[ID].Y - 10, 16);
	WriteConsole( ID, t(166, player[ID].translation, 'Medical kit dropped'), GOOD );
	Medic[Player[ID].Team].KitCooldown := KIT_COOLDOWN;
	SendToLive('medkit '+inttostr(player[ID].Team))
end;

procedure MedicAOI(Team: byte);
begin
	if (Player[Medic[Team].ID].Alive) then
		if Medic[Team].KitCooldown > 0 then
		begin
			Medic[Team].KitCooldown := Medic[Team].KitCooldown - 1;
			if Medic[Team].KitCooldown = 0 then
				WriteConsole(Medic[Team].ID, t(167, player[Medic[Team].ID].translation, 'Medical kit available! Type /kit to drop a medikit'), GOOD );
		end;
end;

procedure OnMedicRespawn(ID: byte);
begin
	Medic[Player[ID].Team].KitCooldown := 0;
end;

procedure HealTeammate(ID: byte);
var i: byte;
begin
	GetPlayerXY(ID, player[ID].X, player[ID].Y);
	for i := 1 to MaxID do
		if i <> ID then
			if player[i].alive and player[i].HP <= MaxHP then begin
				GetPlayerXY(i, player[i].X, player[i].Y);
				if IsInRange(player[ID].X, player[ID].Y, player[i].X, player[i].Y, MEDIC_HEAL_RANGE) then
				begin
					Heal(ID, i);
					exit;
				end;
			end;
	WriteConsole(ID, t(0, player[ID].translation, 'No teammate near to be healed'), BAD);
end;

function OnMedicCommand(ID: byte; var Text: string): boolean;
begin
	Result := True;
	if (Medic[Player[ID].Team].KitCooldown > 0) then
	begin
		case LowerCase(GetPiece(Text, ' ', 0)) of
			'/kit', '/vet', '/vetme': WriteConsole(ID, t(168, player[ID].translation, 'You have no medical kit at the moment'), BAD);
		end;
		exit;
	end;

	case LowerCase(GetPiece(Text, ' ', 0)) of
		'/kit': begin
			if player[ID].alive then begin
				DropMedkit(ID);
			end else WriteConsole(ID, t(169, player[ID].translation, 'You have to be alive to drop a kit'), BAD);
		end;

		// '/vet': begin
		// 	if Player[ID].Alive then
		// 	begin
		// 		HealTeammate(ID);
		// 	end else WriteConsole(ID, t(0, player[ID].translation, 'You have to be alive to use a kit'), BAD);
		// end;

		'/vetme': begin
			if Player[ID].Alive then
			begin
				Heal(ID, ID);
			end else WriteConsole(ID, t(0, player[ID].translation, 'You have to be alive to use a kit'), BAD);
		end;

		else Result := False;
	end;
end;

procedure OnMedicWeaponChange(ID, PrimaryNum, SecondaryNum: Byte);
begin
	if Medic[Player[ID].Team].ID = ID then
		if Player[ID].Alive then
		begin
			HealTeammate(ID);
		end else WriteConsole(ID, t(0, player[ID].translation, 'You have to be alive to heal a teammate'), BAD);
end;
