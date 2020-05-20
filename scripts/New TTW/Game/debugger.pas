procedure Debug_Initialize();
begin
	Debugger.Alevel := ADMINDEBUG;
	Debugger.Clevel := CONSOLEDEBUG;
	Debugger.Flevel := FILEDEBUG;
end;

procedure Debug(Level: byte; Message: string);
begin
	if Level < Debugger.ALevel then WriteLn('<'+ScriptName+'> '+Message);
	if Level < Debugger.FLevel then Debugger.Buffer := Debugger.Buffer + Message + #13#10;
	if Level < Debugger.CLevel then WriteConsole(Debugger.Player, Message, DEBUGCOLOR);
end;

procedure Debug_WriteBuffer();
begin
	if Length(Debugger.Buffer) > 0 then begin
		WriteLnFile(DEBUGPATH+ScriptName+'_debug-'+FormatDate('dd-mm-yy')+'.log', Copy(Debugger.Buffer, 1, Length(Debugger.Buffer)-2));
		Debugger.Buffer := '';
	end;
end;

procedure DebugAOI(Ticks: integer);
begin
	if Ticks mod (DEBUGINTERVAL*60) = 0 then
		Debug_WriteBuffer();
end;

function OnDebugCommand(ID: byte; Text: string): boolean;
begin
	Result := true;
	case LowerCase(GetPiece(Text, ' ', 0)) of
		'/alevel': Debugger.Alevel := StrToInt(GetPiece(Text, ' ', 1));
		'/clevel': Debugger.Clevel := StrToInt(GetPiece(Text, ' ', 1));
		'/flevel': Debugger.Flevel := StrToInt(GetPiece(Text, ' ', 1));
		else Result := false;
	end;
end;