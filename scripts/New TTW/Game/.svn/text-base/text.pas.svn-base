function DrawTextX(ID, Priority: Byte; Text: string; Delay: Integer; Color: Longint; Scale: Single;X,Y: Integer): boolean;
var
	i: byte;
begin
	Result := false;
	if ID = 0 then begin
		for i := 1 to MaxID do
			if (player[i].Text.EndTime < GetTickCount()) or (Priority <= player[i].Text.Priority) then begin
				player[i].Text.EndTime := GetTickCount()+Delay;
				player[i].Text.Priority := Priority;
				DrawText(i, Text, Delay, Color, Scale, X, Y);
				Result := true;
			end else
				WriteConsole(ID, Text, Color);
	end else if (player[ID].Text.EndTime < GetTickCount()) or (Priority <= player[ID].Text.Priority) then begin
		player[ID].Text.EndTime := GetTickCount()+Delay;
		player[ID].Text.Priority := Priority;
		DrawText(ID, Text, Delay, Color, Scale, X, Y);
		Result := true;
	end else
		WriteConsole(ID, Text, Color);
end;