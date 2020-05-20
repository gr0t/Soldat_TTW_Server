const
	MM_POINT_LIMIT = 3;
	cMM = $CCCC00;

var
	mresetVotes:gathervoteStruct;
	Restart: boolean;
	RestartCountdown: byte;
	
function getPoints(): string;
var i: byte;
begin
	Result := '';
	for i := 1 to MaxID do
		if Player[i].Active then
			if not Player[i].Spectator then
				if not Player[i].bot then
					Result := Result + StrReplace(Player[i].Name, ' ', spaceChar) + ':' + inttostr(Player[i].Points) + ' ';
	Result := Copy(Result, 1, Length(Result) - 1);
end;

procedure ShowPoints(ID: byte);
var i: byte;
begin
	for i := 1 to MaxID do
		if Player[i].Active then
			if not Player[i].Spectator then
				if not Player[i].bot then
					WriteConsole(ID, Player[i].Name + ': ' + inttostr(Player[i].Points) + ' points', cMM);
end;

procedure mmInitialise();
begin
	mresetVotes.voteTimer := 0;
	RestartCountdown := 3;
end;

procedure mmGatherEnd();
var i: byte;
begin
	gatherEndMessage := '--- gatherend ';
	for i := 1 to MaxID do
		if Player[i].Active then
		begin
			WriteConsole(i, '------------------', cMM);
			WriteConsole(i, 'Final scores:', CMM);
			ShowPoints(i);
		end;
	gatherEndMessage := gatherEndMessage + getPoints();
	acknowledge := true;
	WriteLn(gatherEndMessage);
	CrossFUnc([], CoreDir + 'initialiseStartUp');
	EndGather();
	kickTimer := 2;
end;

procedure addPoint(ID: byte);
var i, p: byte;
	s: string;
begin
	WriteConsole(0, '---', cMM);
	if ID = 0 then
	begin
		WriteConsole(0, 'Round ended with a tie.', cMM);
		WriteConsole(0, '---', cMM);		
		exit;
	end;
	
	if not Player[ID].Active then
	begin
		if GetArrayLength(TempPlayer) > 0 then
			for i := 0 to GetArrayLength(TempPlayer) - 1 do
				if TempPlayer[i].HWID = Player[ID].HWID then
				begin
					TempPlayer[i].Points := TempPlayer[i].Points + 1;
					s := TempPlayer[i].Name;
					p := TempPlayer[i].Points;
				end;
	end else
	begin
		Player[ID].Points := Player[ID].Points + 1;	
		s := Player[ID].Name;
		p := Player[ID].Points;
	end;

	WriteConsole(0, s + ' has won the round! (' + IntToStr(p) + ' points now)', cMM);
	WriteConsole(0, '---', cMM);

	if p = MM_POINT_LIMIT then
		mmGatherEnd();
end;

procedure addPointTeam(Team: byte);
var i: byte;
	reached: boolean;
begin
	//Tie
	WriteConsole(0, '---', cMM);

	if Team = 0 then
	begin
		WriteConsole(0, 'Round ended with a tie!', cMM)
		WriteConsole(0, '---', cMM);
		exit;
	end;
	case Team of
		1:	WriteConsole(0, 'Alpha team has won the round!', cMM);
		2:	WriteConsole(0, 'Bravo team has won the round!', cMM);
		3:	WriteConsole(0, 'Charlie team has won the round!', cMM);
		4:	WriteConsole(0, 'Delta team has won the round!', cMM);	
	end;
	
	WriteConsole(0, '---', cMM);

	reached := false;
	for i := 1 to MaxID do
		if Player[i].Active then
		if Player[i].Team = Team then
		if not Player[i].Bot then
		begin
			Player[i].Points := Player[i].Points + 1;
			if Player[i].Points = MM_POINT_LIMIT then
				reached := true;
		end;

	if GetArrayLength(TempPlayer) > 0 then
	for i := 0 to GetArrayLength(TempPlayer)-1 do
		if TempPlayer[i].Team = Team then	
		begin
			TempPlayer[i].Points := TempPlayer[i].Points + 1;
			if TempPlayer[i].Points = MM_POINT_LIMIT then
				reached := true;
		end;

	if reached then mmGatherEnd();
end;

procedure mmAppOnIdle(Ticks: integer);
begin
	if mresetVotes.voteTimer = 10 then
	begin
		WriteConsole( 0, '10 seconds left to vote for reset!', INFORMATION );
		WriteConsole( 0, 'Vote using /ready (to vote in favour of restarting the round)', INFORMATION );		
	end;
	if mresetVotes.voteTimer > 0 then
	begin
		mresetVotes.voteTimer := mresetVotes.voteTimer - 1;
		if mresetVotes.voteTimer = 0 then
		begin				
			WriteConsole( 0, 'Reset failed!', BAD );
		end;
	end;
	
	if Restart then
		if Restartcountdown > 0 then begin
			WriteConsole(0, IntToStr(RestartCountdown)+'...', GOOD);
			RestartCountdown := Restartcountdown - 1;
		end else begin
			WriteConsole(0, 'Round restarting!', GOOD);
			Restart := false;
			Restartcountdown := 3;
			Command('/restart');
		end;
end;

procedure mmOnMapChange(NewMap: string);
var i: byte;
begin
	//if !reset'd, all points 0
	if GatherOn = 1 then
	begin
		CrossFunc([GatherSize], CoreDir + 'setTeams');
		for i := 1 to MaxID do
			if Player[i].Active then
			begin
				Player[i].Points := 0;
				if Player[i].Team = 5 then
					Player[i].Spectator := true;
			end;
	end;
end;

function mmOnPlayerCommand(ID: Byte; Text: string): boolean;
var b: byte;
	foundVoter: boolean;
begin
	if GatherOn <> 2 then 
	begin
		Result := false;
		exit;
	end;

	//view points
	if (Text = '/points') or (Text = '/status') then 
	begin
		ShowPoints(ID);
	end
	else if (Text = '/mready') then
	begin
		if Player[ID].Team = 5 then
			exit;
		if mresetVotes.voteTimer > 0 then
		begin
			foundVoter := false;				
			b := 1;
			while ( ( b < MaxID ) and ( mresetVotes.votes[b] > 0 ) ) do
			begin
				if mresetVotes.votes[b] = ID then
					foundVoter := true;
				b := b + 1;
			end;
			if foundVoter = false then
			begin
				mresetVotes.votes[b] := ID;
				mresetVotes.numVotes := mresetVotes.numVotes + 1;
				WriteConsole( 0, IDToName( ID )+' voted in favor of restarting the round.', GOOD );
				WriteConsole( 0, IntToStr(mresetVotes.numVotes)+'/'+IntToStr( mresetVotes.numVotesRequired ), GOOD );
				if mresetVotes.numVotes = mresetVotes.numVotesRequired then
				begin				
					mresetVotes.voteTimer := 0;
					WriteConsole( 0, 'Round restarting in 3 seconds!', GOOD );					
					Restart := True;
				end;
			end else WriteConsole( ID, 'You have already voted in this poll!', BAD );
		end else WriteConsole( ID, 'No vote going on right now', BAD );
	end;

	Result := false; 
end;


procedure mmOnPlayerSpeak(ID: byte; Text: string);
begin	
	if GatherOn <> 2 then
		exit;

	//reset gather
	case LowerCase(Text) of
		'!mreset' :
		begin
			if Player[ID].Team = 5 then
				exit;
			if mresetVotes.voteTimer = 0 then
			begin
				if GetPlayerNum() >= gatherSize then
				begin			
					WriteConsole( 0, 'Vote for restarting the round started! Type /mready if you are ready to start', GOOD );
					mresetVotes.voterID := ID;
					mresetVotes.voteTimer := 90;
					mresetVotes.numVotesRequired := gatherSize;
					mresetVotes.numVotes := 0;
					mresetVotes.numVotes := mresetVotes.numVotes + 1;
				end else WriteConsole( ID, 'Cannot start vote, not everybody is on the server yet', BAD );
			end else WriteConsole( ID, 'There is already a vote for reset going on', BAD );
		end;
	end;
end;