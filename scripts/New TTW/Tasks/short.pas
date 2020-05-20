procedure OnShortRespawn(ID: byte);
begin
	player[ID].mre := 1;
end;

function OnShortCommand(ID: byte; var Text: string): boolean;
begin
	Result := True;
	case LowerCase(GetPiece(Text, ' ', 0)) of
		'/mre': if player[ID].alive then begin
			if player[ID].mre > 0 then begin
				player[ID].mre := player[ID].mre - 1;
				WriteConsole(ID, GetFoodMessage(player[ID].translation), GOOD );
				GiveHealth( ID, 32);
			end else
				WriteConsole(ID, t(170, player[ID].translation, 'You do not have a meal ready to eat.'), BAD);
		end else
			WriteConsole(ID, t(171, player[ID].translation, 'You''re already dead'), BAD);
		
		else Result := False;
	end;
end;
