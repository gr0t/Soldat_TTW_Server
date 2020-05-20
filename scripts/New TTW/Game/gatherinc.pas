//Gather to TTW
function SetGatherDir(ValueToSet: string): boolean;
begin
	GatherDir := ValueToSet +'.';
	Result := True;
	WriteLn(' [*] '+ScriptName+': '+ ValueToSet +' found');
	CalculateCosts(True);
end;

procedure SetGatherOn(ValueToSet: Integer);
begin
	GatherOn := ValueToSet;
	WriteLn(' [*] '+ScriptName+': GatherOn set to: '+ IntToStr(ValueToSet));
end;

function GetPlayerTask(ID: Byte): Integer;
begin
	Result := Player[ID].Task;
end;

function GetNumBunkers(): Integer;
begin
	Result := GetArrayLength(Bunker);
end;

procedure SetGatherPause(ValueToSet: Boolean);
begin
	Pause := ValueToSet;
	
	if Pause = False then
		BackUp.HWID := '';
	WriteLn(' [*] '+ScriptName+': Gather pause set to: '+ iif(Pause, 'True', 'False'));
end;









procedure AddParatrooper(HWID: string);
var
	i: ShortInt;
begin	
	for i := 1 to MaxID do
		if player[i].Active then
			CheckHWID(i, HWID);
end;

procedure setTeamSPFreq(Team: byte);
var 
	i: ShortInt;
begin
	for i := 1 to 2 do 
	begin
		Teams[i].SPFreq := SUPPLYTIME;
	end;
	if Team <> 0 then
		Teams[Team].SPFreq := Teams[Team].SPFreq + SPINCREASE;
end;
