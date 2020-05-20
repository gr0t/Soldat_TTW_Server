//TODO: Set high score limit, set moderate time limit (15-20 min)

const
	TW_SCORE_LIMIT = 3;
	TW_CORE_NAME = 'TWb.pas';	//Name of the .pas file
	INITIAL_DOMINATION = true;
	INITIAL_FF = true;

var
	Domination, FriendlyFire: boolean;

procedure twInitialise();
begin
	Domination := INITIAL_DOMINATION;
	FriendlyFire := INITIAL_FF;
end;

procedure twGatherEnd(domAlpha, domBravo: word);
begin
	gatherEndMessage := '--- gatherend '+IntToStr(domAlpha) +' '+IntToStr(domBravo) + ' ' + IntToStr(capsRed) + ' ' +IntToStr(capsBlue);
	acknowledge := true;
	WriteLn(gatherEndMessage);

	if not Domination then
		if capsRed > capsBlue then 
			WriteConsole(0,'Alpha Won The Match With '+IntToStr(Trunc(capsRed))+' scores!',GOOD)		
		else if capsBlue > capsRed then
			WriteConsole(0,'Bravo Won The Match With '+IntToStr(Trunc(capsBlue))+' scores!',GOOD)
		else WriteConsole(0,'It''s a tie!',GOOD);
	EndGather();
end;

procedure twOnMapChange(NewMap: string);
var
	separator: char;
begin
	//TODO: Will the map really be changed? Who picks the random map?
	if not CoreFound then
		exit;

	//TODO: Turn off the Domination while the gather isn't running, turn it on then if set
	if GetSystem() = 'windows' then separator := '\'
		else separator := '/';
	if WriteFile('scripts' + separator + Copy(CoreDir, 1, Length(CoreDir) - 1) + separator + 'Includes.txt', 
					iif(Domination, TW_CORE_NAME,'')) then 
		WriteLn(' [*] ' + ScriptName + ': Domination switched ' + iif(Domination, 'on', 'off'))
		else WriteLn(' [*] ' + ScriptName + ': Error trying to enable/disable Domination');
	Command('/recompile ' + Copy(CoreDir, 1, Length(CoreDir) - 1));
	if Domination then
	begin
		CrossFunc([ScriptName], CoreDir + 'SetGatherDir');
		CrossFunc([GatherOn], CoreDir + 'SetGatherOn');
	end;
end;

procedure twAppOnIdle(Ticks: integer);
begin
	if GatherOn = 2 then
		if not Domination then
			if TimeLeft = 1 then
				twGatherEnd(0, 0);
end;

procedure twOnFlagScore(ID, TeamFlag: byte);
begin
	if GatherOn = 2 then
		if not Domination then
			if (capsRed = TW_SCORE_LIMIT) or (capsBlue = TW_SCORE_LIMIT) then
				twGatherEnd(0, 0);
end;

procedure twOnPlayerSpeak(ID: byte; Text: string);
begin	
	//if (GatherOn <> 1) and (GatherOn <> 2) then exit;

	//reset gather
	case LowerCase(Text) of
		'!dom', '!domination':
			begin
				Domination := not Domination;
				CrossFunc([Domination], CoreDir + 'SetDomination');
				WriteConsole(0, 'Domination turned ' + iif(Domination, 'on', 'off') + '. (Reset the gather)', GOOD);
			end;
		'!ff', '!friendlyfire', '!th':
			begin
				FriendlyFire := not FriendlyFire;
				WriteConsole(0, 'Friendlyfire turned ' + iif(Friendlyfire, 'on', 'off'), GOOD);	
				if FriendlyFire then
					Command('/friendlyfire 100')
				else Command('/friendlyfire 0');

			end;
	end;
end;