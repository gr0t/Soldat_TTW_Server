//TODO: Include some !a, !b, !votemap commands
const
	MAXPLAYER = 16;
	INITIAL_PASSWORD = '';

	// Colours
	ANNOUNCEMENT1 = 4294967295;//#FFFFFFFF;
	INFORMATION = $FF8888FF;
	GOOD = $8EC163;
	BAD = $FF0000;
	TEAMCHAT =$ADFF30;
	ORANGE = $F4A460;
	BOTSTRING = $E8A317;

	MODE_TTW = 'TTW';
	TTWCOREDIR = 'New TTW.';
	MODE_TW = 'TW';
	TWCOREDIR = 'TW.';
	MODE_MMOD = 'MMOD';
	MMODCOREDIR = 'MiracleMod.';
	MODE_ONS = 'ONS';
	ONSCOREDIR = 'Onslaught.';
	MODE_MM = 'MM';
	MMCOREDIR = 'MultiMode.';
	MODE_POR = 'POR';
	PORCOREDIR = 'Portal.';
	MODE_M79C = 'M79C';
	M79CCOREDIR = 'coop.';
	br = #13+#10;
	spaceChar = #1;
	mapSpaceChar = '_';

type
	gathervoteStruct = record
		voterID: byte;
		voteTimer: integer;
		numVotes: byte;
		numVotesRequired: byte;
		votes: array[1..MAXPLAYER] of byte;
	end;

	tPlayer = record
		//Player
		Name, HWID: string;
		Team, Points: byte;
		Active, Bot, Voted, Spectator, Acknowledged: boolean;
	end;
var
	MaxID, capsRed, capsBlue: byte;
	gatherEndMessage, GatherMode, CoreDir, Pauser: String;
	acknowledge, CoreFound, Confirm, Pause, Unpause, StartMatch, SetGatherPause, SetGatherOn: Boolean;
	initMode, GatherOn, Gathersize, UPCountDown, StartCountdown: Integer;
	//GatherOn:
	// 	1 = reset - mapchange
	// 	2 = gather running
	// 	3 = gather end
	//initMode:
	//	0 = unknown
	//	1 = received
	//	2 = initialised
	resetVotes:gathervoteStruct;
	kickDelay, kickTimer: integer;
	unpauseVotes:gathervoteStruct;
	Teams: array of string;
	Player: array[1..MAXPLAYER] of tPlayer;
	TempPlayer: array of tPlayer;
	PauseInAOI: boolean;

function Explode(Source: string; const Delimiter: string): array of string;
var
  Position, DelLength, ResLength: integer;
begin
  DelLength := Length(Delimiter);
  Source := Source + Delimiter;
  repeat
    Position := Pos(Delimiter, Source);
    SetArrayLength(Result, ResLength + 1);
    Result[ResLength] := Copy(Source, 1, Position - 1);
    ResLength := ResLength + 1;
    Delete(Source, 1, Position + DelLength - 1);
  until (Position = 0);
  SetArrayLength(Result, ResLength - 1);
end;


procedure newPlayer(ID, Team: byte; Human, CheckTemp: boolean);
var i: byte;
begin

	if Player[ID].Active then
	begin
		//If the same player respawned, his stats stay
		if Player[ID].HWID = GetPlayerStat(ID, 'HWID') then
		begin
			Player[ID].Team := Team;
		end else
		begin
			i := GetArrayLength(TempPlayer);
			SetArrayLength(TempPlayer, i + 1);
			TempPlayer[i].HWID := Player[ID].HWID;
			TempPlayer[i].Name := Player[ID].Name;
			TempPlayer[i].Team := Player[ID].Team;
			TempPlayer[i].Points := Player[ID].Points;
		end;
	end;

	Player[ID].Spectator := false;
	Player[ID].Name := IDToName(ID);
	Player[ID].Active := True;
	Player[ID].Bot := not Human;
	Player[ID].Team := Team;
	Player[ID].HWID := GetPlayerStat(ID, 'HWID');;

	if ID > MaxID then
		MaxID := ID;

	if checkTemp then
	begin
		if GetArrayLength(TempPlayer) > 0 then
			for i := 0 to GetArrayLength(TempPlayer)-1 do
				if TempPlayer[i].HWID = Player[ID].HWID then
				begin
					Player[ID].Points := TempPlayer[i].Points;
					TempPlayer[i].HWID := '';
					TempPlayer[i].Points := 0;
					TempPlayer[i].Name := '';
					TempPlayer[i].Team := 0;
					exit;
				end;
	end;

	Player[ID].Points := 0;
end;

//Called in Gather_new\Events.pas -> ActivateServer()
procedure mainActivateServer();
var i: byte;
begin
	gatherEndMessage := '';
	acknowledge := false;
	initMode := -2;
	GatherOn := 0;
	GatherMode := '';
	Pause := False;
	CoreFound := false;
	kickDelay := 0;
	kickTimer := 15;
	resetVotes.voteTimer := 0;
	unpauseVotes.voteTimer := 0;
	UPcountdown := 3;
	StartCountdown := 3;
	Command('/password ' + INITIAL_PASSWORD);
	gathersize := 6;

	for i := 1 to MAXPLAYERS do
		if GetPlayerStat(i, 'Active') then
		begin
			newPlayer(i, GetPlayerStat(i, 'Team'), GetPlayerStat(i, 'Human'), false);
		end;
end;

//
procedure GetMode();
var i: byte;
	Dir, ModeName: String;
begin
	WriteLn(' [*] Looking for modes...');
	GatherMode := '';
	for i := 0 to 6 do
	begin
		case i of
			0: 	begin
					Dir := TTWCOREDIR;
					ModeName := MODE_TTW;
				end;
			1: 	begin
					Dir := TWCOREDIR;
					ModeName := MODE_TW;
				end;
			2: 	begin
					Dir := ONSCOREDIR;
					ModeName := MODE_ONS;
				end;
			3: 	begin
					Dir := MMODCOREDIR;
					ModeName := MODE_MMOD;
				end;
			4:	begin
					Dir := MMCOREDIR;
					ModeName := MODE_MM;
				end;
			5:	begin
					Dir := PORCOREDIR;
					ModeName := MODE_POR;
				end;
			5:	begin
					Dir := M79CCOREDIR;
					ModeName := MODE_M79C;
				end;
		end;
		if CrossFunc([ScriptName], Dir + 'SetGatherDir') then
		begin
			WriteLn(' [*] Found Modecore ' + ModeName);
			GatherMode := ModeName;
		end;
	end;

	if GatherMode = '' then
		GatherMode := 'NONE';
	WriteLn(' [*] GatherMode: ' + GatherMode);
end;

procedure initialiseMode();
var mapslist: array of string;
begin
	gatherEndMessage := '--- currentmode ' + GatherMode;

	if GatherMode = 'NONE' then
	begin
		WriteLn(' [!] ' + ScriptName + ': No mode known!');
		exit;
	end;

	initMode := 1;

	if GatherMode <> MODE_MMOD then
	begin
		mapslist := Explode(ReadFile('mapslist.txt'), br);
		Command('/map ' + mapslist[0]);
	end;


	case GatherMode of
		MODE_TTW: 	CoreDir := TTWCOREDIR;
		MODE_TW: 	CoreDir := TWCOREDIR;
		MODE_ONS: 	CoreDir := ONSCOREDIR;
		MODE_MMOD: 	CoreDir := MMODCOREDIR;
		MODE_MM:	CoreDir := MMCOREDIR;
		MODE_POR:	CoreDir := PORCOREDIR;
		MODE_M79C:	CoreDir := M79CCOREDIR;
	end;

	//Connect to the game core and send address of Gather to it;
	CoreFound := True;
	SetGatherPause := true;
	SetGatherOn := true;
end;


procedure UnpauseGame(Cmd: boolean);
begin
	if not Pause then exit;

	Writeln('GATHER UNPAUSED!');
	Writeln('--- gatherunpause');
	Pause := False;
	CrossFunc([false], CoreDir + 'SetGatherPause');
	SetGatherPause := true;
	if Cmd then
	begin
		Command('/unpause');
		sleep(50);
		Command('/unpause');
	end;
	unpauseVotes.voteTimer := 0;
end;

procedure PauseGame(ID: byte);
begin
	WriteLn('GATHER PAUSED!');
	if ID > 0 then
		pauser := IDToName(ID)
	else pauser := '';
	Pause := True;
	SetGatherPause := True;
	//TODO: Tickets not known
	Writeln('--- gatherpause');
	Command('/pause');
	sleep(50);
	Command('/pause');
	CrossFunc([true], CoreDir + 'SetGatherPause');
end;

procedure StartGather();
begin
	GatherOn := 1;
	SetGatherOn := true;
	WriteConsole(0,'Gather Reset, Restarting Now!',GOOD);
	Writeln('USER RESET, GATHER RESTART!');
	UnpauseGame(True);
	Command('/map ' + CurrentMap);
end;

procedure EndGather();
begin
	kickDelay := 1;
	kickTimer := 15;
	GatherOn := 3;
	SetGatherOn := True;
	Command('/password ' + INITIAL_PASSWORD);
	PauseGame(0);
end;


procedure Start();
var i, a, b: byte;
begin
	for i := 1 to MaxID do
		if Player[i].Active then
		if not Player[i].Bot then
		if Player[i].Team = 1 then
			a := a + 1
		else if Player[i].Team = 2 then
			b := b + 1;

	if (a <> GatherSize / 2) or (b <> GatherSize / 2) then
	begin
		WriteCOnsole(0, 'Gather reset cancelled: Join your teams first.', BAD);
		resetVotes.voteTimer := 0;
		for i := 1 to MaxID do
			Player[i].voted := false;
		exit;
	end;
	StartMatch := true;
	WriteConsole( 0, 'Gather starting in', GOOD );
	for i := 1 to MaxID do
		Player[i].voted := false;
	resetVotes.voteTimer := 0;
	SetArrayLength(TempPlayer, 0);
end;


//Called in Gather_new\Events.pas -> AppOnIdle()
procedure mainAppOnIdle(Ticks: integer);
var
	i: byte;
begin
	if PauseInAOI then
	begin
		PauseInAOI := false;
		PauseGame(0);
	end;

	if initMode < 0 then
		initMode := initMode + 1;

	if initMode = 0 then
	begin
		GetMode();
		initialiseMode();
	end;

	if SetGatherPause then begin
		SetGatherPause := false;
		CrossFunc([Pause], CoreDir + 'SetGatherPause');
	end;

	if SetGatherOn then begin
		SetGatherOn := false;
		CrossFunc([GatherOn], CoreDir + 'SetGatherOn');
	end;

	for i := 1 to MaxID do
	begin
		if Player[i].Active then
			if not Player[i].Bot then
				if not Player[i].Acknowledged then
					WriteLn('--- hwid ' + Player[i].HWID + ' ' + IDToName(i));
	end;

	//if kickdelay is on then kick players after a while
	if kickDelay = 1 then
	begin
		kickTimer := kickTimer -1;

		if kickTimer < 1 then
		begin
			for i := 1 to MaxID do
			begin
				if Player[i].Active then
				if not Player[i].Bot then
				begin
					kickplayer(i);
				end;
			end;
			kickDelay := 0;
			kickTimer := 15;
			UnpauseGame(True);
			GatherOn := 0;
			SetGatherOn := true;
		end;
	end;

	if resetVotes.voteTimer = 10 then
	begin
		WriteConsole( 0, '10 seconds left to vote for reset!', INFORMATION );
		WriteConsole( 0, 'Vote using /ready (to vote in favour of starting the game)', INFORMATION );
	end;
	if resetVotes.voteTimer > 0 then
	begin
		resetVotes.voteTimer := resetVotes.voteTimer - 1;
		if resetVotes.voteTimer = 0 then
		begin
			WriteConsole( 0, 'Reset failed!', BAD );
			for i := 1 to 32 do Player[i].voted := false;
		end;
	end;

	if unpauseVotes.voteTimer = 10 then
	begin
		WriteConsole( 0, '10 seconds left to vote for unpause!', INFORMATION );
		WriteConsole( 0, 'Vote using /gogo (to vote in favour of resuming the game)', INFORMATION );
	end;
	if unpauseVotes.voteTimer > 0 then
	begin
		unpauseVotes.voteTimer := unpauseVotes.voteTimer - 1;
		if unpauseVotes.voteTimer = 0 then
		begin
			WriteConsole( 0, 'Unpause failed!', BAD );
		end;
	end;


	if Unpause then
		if UPcountdown > 0 then begin
			WriteConsole(0, IntToStr(UPcountdown)+'...', GOOD);
			UPcountdown := UPcountdown - 1;
		end else begin
			WriteConsole(0, 'Go!', GOOD);
			Unpause := false;
			UPcountdown := 3;
			UnpauseGame(True);
		end;

	if StartMatch then
		if StartCountdown > 0 then begin
			WriteConsole(0, IntToStr(StartCountdown)+'...', GOOD);
			StartCountdown := StartCountdown - 1;
		end else begin
			StartMatch := false;
			StartCountdown := 3;
			StartGather();
		end;
end;


procedure mainOnMapChange(NewMap: string);
var
	i: Byte;
begin
	currentMap := NewMap;
	kickDelay := 0;
	kickTimer := 15;
	capsBlue := 0;
	capsRed := 0;

	if (GatherOn = 1) or (GatherOn = 2) then
	begin
		SetGatherOn := true;
		case GatherMode of
			MODE_TW: 	WriteLn('--- gatherstart ' + StrReplace(CurrentMap, ' ', mapSpaceChar));
			MODE_ONS: 	WriteLn('--- gatherstart ' + StrReplace(CurrentMap, ' ', mapSpaceChar) + ' ' + IntToStr(CrossFunc([], CoreDir + 'GetNodeNum')));
			MODE_MMOD: 	WriteLn('--- gatherstart ' + StrReplace(CurrentMap, ' ', mapSpaceChar));
			MODE_MM:	if GatherOn = 1 then
							WriteLn('--- gatherstart ' + StrReplace(CrossFunc([], CoreDir + 'GetMode'), ' ', spaceChar) + ' ' + StrReplace(CurrentMap, ' ', mapSpaceChar));
		end;

	end;

	for i := 1 to MaxID do
		Player[i].voted := false;

	// unpause the game
	if GatherOn <> 3 then
		UnpauseGame(False);
end;

procedure mainOnFlagScore(ID, TeamFlag: byte);
begin
	if TeamFlag = 1 then
		capsBlue := capsBlue + 1
	else
		capsRed := capsRed + 1;
end;

procedure mainOnJoinGame(ID, Team: byte);
var spec: boolean;
begin
	if not Player[ID].Active then
		if Team = 5 then
			spec := true;
	newPlayer(ID, Team, true, true);
	if spec then Player[ID].Spectator := True;
end;

function GetPlayerNum(): byte;
var i: byte;
begin
	Result := 0;
	for i := 1 to MaxID do
		if Player[i].Active then
		if not Player[i].Spectator then
		if not Player[i].Bot then
			Result := Result + 1;
end;

procedure mainOnJoinTeam(ID, Team: byte);
begin
// 	if Team < 5 then
// 		if Player[ID].Spectator then
// 		if GatherOn = 2 then
// 		begin
//
// 			if GetPlayerNum() >= GatherSize then
// 			begin
// 				WriteConsole(ID, 'You can''t join the game as spectator. (Type !a, !b,.. if you''re a player.', BAD);
// 				Command('/setteam5 ' + inttostr(ID));
// 				Player[ID].Team := 5;
// 				exit;
// 			end;
// 		end;

	Player[ID].Team := Team;
	if Team < 5 then Player[ID].Spectator := False;

	if Team = 5 then
		if Player[ID].voted then
		begin
			Player[ID].voted := false;
			resetVotes.numVotes := resetVotes.numVotes - 1;
		end;

end;

procedure mainOnPlayerRespawn(ID: byte);
begin
	if not Player[ID].Active then
	if not GetPlayerStat(ID, 'Human') then
	begin
		newPlayer(ID, GetPlayerStat(ID, 'Team'), false, true);
	end;
end;

procedure mainOnLeaveGame(ID, Team: byte;Kicked: boolean);
var i: byte;
begin
	Player[ID].Active := False;
	Player[ID].Acknowledged := False;
	if Player[ID].voted then begin
		Player[ID].voted := false;
		resetVotes.numVotes := resetVotes.numVotes - 1;
	end;
	if MaxID <= ID then
		for i := 1 to MAXPLAYER do
		begin
			If Player[i].Active then
				MaxID := ID;
		end;
	case GatherMode of
		MODE_MMOD, MODE_TW, MODE_ONS:
				if not Player[ID].Bot then
				if Player[ID].Team < 5 then
				if GatherOn = 2 then
				begin
					PauseInAOI := True;
				end;
	end;
	i := GetArrayLength(TempPlayer);
	SetArrayLength(TempPlayer, i + 1);
	TempPlayer[i].HWID := Player[ID].HWID;
	TempPlayer[i].Team := Player[ID].Team;
	TempPlayer[i].Name := Player[ID].Name;
	TempPlayer[i].Points := Player[ID].Points;
end;

procedure mainOnAdminMessage(IP, Msg: string);
var
	i: byte;
	hwid, playerType: string;

begin
	if Copy(Msg, 1, 3) <> '===' then exit;

	case GetPiece(Msg, ' ', 1) of
		'info': begin
					WriteConsole(0, '{[i]} ' + Copy(Msg, 10, Length(Msg)), BOTSTRING);
				end;
		'status': begin
					case GatherMode of
						MODE_TTW:
							WriteLn('--- status ' + IntToStr(Trunc(CrossFunc([1], ScriptName + '.GetTicks')))
									+ ' ' + IntToStr(Trunc(CrossFunc([2], ScriptName + '.GetTicks')))
									+ ' ' + IntToStr(capsRed) + ' ' + IntToStr(capsBlue));
						MODE_TW:
							WriteLn('--- status ' + IntToStr(TimeLeft)
									+ ' ' + IntToStr(CrossFunc([1], CoreDir + 'GetDom'))
									+ ' ' + IntToStr(CrossFunc([2], CoreDir + 'GetDom'))
									+ ' ' + IntToStr(capsRed)
									+ ' ' + IntToStr(capsBlue));
						MODE_ONS:
							WriteLn('--- status ' + IntToStr(TimeLeft)
									+ ' ' + IntToStr(CrossFunc([1], CoreDir + 'GetNodes'))
									+ ' ' + IntToStr(CrossFunc([2], CoreDir + 'GetNodes')));

						MODE_MM:
							WriteLn('--- status ' + StrReplace(CrossFunc([], CoreDir + 'GetMode'), ' ', spaceChar)
									+ ' ' + StrReplace(CurrentMap, ' ', mapSpaceChar)
									+ ' ' + CrossFunc([], ScriptName + '.getPoints'));

						else WriteLn('--- status ' + IntToStr(capsRed) + ' ' + IntToStr(capsBlue));

					end;
				end;
		'reset': begin
				WriteConsole( 0, 'GATHER CANCELLED', BAD );
				UnpauseGame(True);
				GatherOn := 0;
				SetGatherOn := True;
				kickDelay := 1;
				kickTimer := 15;
			end;

		'gather': begin
				GatherSize := StrToInt(GetPiece(Msg, ' ', 2));
				SetArrayLength(Teams, GatherSize);

				for i := 0 to (Gathersize - 1) do
					Teams[i] := GetPiece(Msg, ' ', i + 3);

				WriteLn('[*] ' + ScriptName + ': Received Gathersize and Teams.');
				Command('/maxplayers ' + inttostr(Gathersize));
				if (GatherMode = MODE_MMOD) then
					CrossFunc([GatherSize], CoreDir + 'SetGatherSize');
			end;

		'sub': WriteConsole(0, GetPiece(Msg, ' ', 2) + ' has added as substitute.', GOOD);
		'delsub': WriteConsole(0, 'Substitute call deleted.', BAD);
		'spect': begin
			WriteConsole(0, GetPiece(Msg, ' ', 2) + ' has added as spectator.', GOOD);
			Command('/maxplayers '+IntToStr(MaxPlayers+1));
		end;
		'currentmode': begin
			WriteLn(gatherEndMessage);
		end;
		//'gatherend': begin
		//end;
		'ack': begin
			hwid := GetPiece(Msg, ' ', 2);
			playerType := GetPiece(Msg, ' ', 3);
			for i := 1 to MaxID do
				if Player[i].Active then
				if Player[i].HWID = hwid then
				begin
					Player[i].Acknowledged := True;
					WriteLn('Acknowledged player ' + IDToName(i));
					case playerType of
					'para': begin
						CrossFunc([hwid], CoreDir + 'AddParatrooper');
					end;
					end;
					break;
				end;
			if i > MaxID then
			begin
				WriteLn('--- error unknown_hwid');
			end;
		end;
		'para': if GatherMode = MODE_TTW then begin
			hwid := GetPiece(Msg, ' ', 3);
			Msg := GetPiece(Msg, ' ', 2);
			WriteConsole(0, Msg + ' added as a paratrooper!', $FF99FF99);
			CrossFunc([hwid], CoreDir + 'AddParatrooper');
			Command('/maxplayers '+IntToStr(MaxPlayers+1));
		end;
	end;
end;


function mainOnCommand(ID: Byte; Text: string): boolean;
begin
	if Copy(Text, 2, 10) = 'gathersize' then
	begin
		gatherSize := StrToInt(GetPiece(Text, ' ', 1));
		gatherSize := gatherSize + gathersize mod 2;
		WriteLn('Gathersize set to '+IntToStr(gatherSize));
	end else
	if Text = '/unpause' then begin
		Result := true;
		Unpause := true;
	end else
	if Text = '/start' then
	begin
		if GatherOn = 2 then
		begin
			if ID <= 32 then WriteConsole( ID, 'Gather is running, are you sure? (/yes)', GOOD ) else
				WriteLn('Gather is running, are you sure? (/yes)');
			Confirm := true;
		end else Start();
	end else
	if Text = '/yes' then
		if Confirm then
		begin
			Confirm := false;
			Start();
		end;

	if GetPiece(Text, ' ', 0) = '/---' then
	begin
		WriteLn(Copy(Text, 2, Length(Text)-1));
	end;
end;


function mainOnPlayerCommand(ID: Byte; Text: string): boolean;
var
	b: byte;
	foundVoter: boolean;
begin
	if Text='/ready' then
	begin
		if Player[ID].Team = 5 then
			exit;

		if resetVotes.voteTimer > 0 then
		begin
			if not Player[ID].voted then
			begin
				resetVotes.numVotes := resetVotes.numVotes + 1;
				WriteConsole( 0, IDToName( ID )+' voted in favor of reset.', GOOD );
				Player[ID].voted := true;
				WriteConsole( 0, IntToStr(resetVotes.numVotes)+'/'+IntToStr( resetVotes.numVotesRequired ), GOOD );
				if resetVotes.numVotes = resetVotes.numVotesRequired then
					Start();
			end else WriteConsole( ID, 'You have already voted in this poll!', BAD );
		end else WriteConsole( ID, 'No vote going on right now', BAD );
	end else

	if Text='/unready' then
	begin
		if resetVotes.voteTimer > 0 then
		begin
			if Player[ID].voted then
			begin
				resetVotes.numVotes := resetVotes.numVotes - 1;
				WriteConsole( 0, IDToName( ID )+' drew back his vote.', BAD);
				Player[ID].voted := false;
				WriteConsole( 0, IntToStr(resetVotes.numVotes)+'/'+IntToStr( resetVotes.numVotesRequired ), BAD);
			end else WriteConsole( ID, 'You have not voted yet in this poll!', BAD );
		end else WriteConsole( ID, 'No vote going on right now', BAD );
	end else

	if Text='/gogo' then
	begin
		if Player[ID].Team = 5 then
			exit;
		if unpauseVotes.voteTimer > 0 then
		begin
			foundVoter := false;
			b := 1;
			while ( ( b < MaxID ) and ( unpauseVotes.votes[b] > 0 ) ) do
			begin
				if unpauseVotes.votes[b] = ID then
					foundVoter := true;
				b := b + 1;
			end;
			if foundVoter = false then
			begin
				unpauseVotes.votes[b] := ID;
				unpauseVotes.numVotes := unpauseVotes.numVotes + 1;
				WriteConsole( 0, IDToName( ID )+' voted in favor of unpausing the game.', GOOD );
				WriteConsole( 0, IntToStr(unpauseVotes.numVotes)+'/'+IntToStr( unpauseVotes.numVotesRequired ), GOOD );
				if unpauseVotes.numVotes = unpauseVotes.numVotesRequired then
				begin
					unpauseVotes.voteTimer := 0;
					WriteConsole( 0, 'Gather resuming in 3 seconds!', GOOD );
					Unpause := true;
				end;
			end else WriteConsole( ID, 'You have already voted in this poll!', BAD );
		end else WriteConsole( ID, 'No vote going on right now', BAD );
	end else

	if LowerCase(Copy(Text, 1, 3)) = '/t ' then
		if GatherMode <> MODE_TTW then
		begin
			for b := 1 to MaxID do
				if Player[b].Active then
					if Player[b].Team = Player[ID].Team then
						WriteConsole(b, IDToName(ID) + ': ' + Copy(Text, 4, Length(Text)), TEAMCHAT);

		end;
  Result := false;
end;

procedure mainOnPlayerSpeak(ID: byte; Text: string);
var
	b: byte;
	pauseVoted: array[1..MAXPLAYER] of boolean;
	str: string;
begin
	//reset gather
	case LowerCase(Text) of
		'!reset' :
		begin
			if Player[ID].Team = 5 then
				exit;
			if resetVotes.voteTimer = 0 then
			begin
				if GetPlayerNum() >= gatherSize then
				begin
					WriteConsole( 0, 'Vote for resetting the gather started! Type /ready if you are ready to start', GOOD );
					resetVotes.voterID := ID;
					resetVotes.voteTimer := 90;
					resetVotes.numVotesRequired := gatherSize;
					resetVotes.numVotes := 0;
					Player[ID].voted := true;
					resetVotes.numVotes := resetVotes.numVotes + 1;
				end else WriteConsole( ID, 'Cannot start vote, not everybody is on the server yet', BAD );
			end else WriteConsole( ID, 'There is already a vote for reset going on', BAD );
		end;

		'!delsub': Writeln('--- delsub');

		//pause gather
		'!pause', '!p':
		begin
			if Player[ID].Team = 5 then
				exit;

			if GatherOn = 2 then
			begin
				if not Pause then
					PauseGame(ID);
			end;
		end;

		//reset gather
		'!unpause', '!up':
		begin
			if Pause then
			begin
				if Player[ID].Team = 5 then
					exit;
				if IDToName(ID) = pauser then
				begin
					Unpause := true;
				end else begin
					if unpauseVotes.voteTimer = 0 then
					begin
						if numPlayers - spectators - numBots + 1 >= gatherSize then
						begin
							WriteConsole( 0, 'Vote for unpausing the gather started! Type /gogo if you are ready to start', GOOD );
							unpauseVotes.voterID := ID;
							unpauseVotes.voteTimer := 90;
							unpauseVotes.numVotesRequired := gatherSize;
							unpauseVotes.numVotes := 0;
							for b := 1 to MaxID do
								unpauseVotes.votes[b] := 0;
							unpauseVotes.votes[1] := ID;
							unpauseVotes.numVotes := unpauseVotes.numVotes + 1;
						end else WriteConsole( ID, 'Cannot start vote', BAD );
					end else
					begin
						for b := 1 to MaxID do
						begin
							if unpauseVotes.votes[b] < 1 then break;
							pauseVoted[unpauseVotes.votes[b]] := True;
						end;

						for b := 1 to MaxID do
						begin
							if Player[b].Active then
								if not Player[b].Bot then
									if Player[b].Team < 5 then
										if not pausevoted[b] then
											WriteConsole(0, IDToName(b) + '     [ UNREADY ]', $CC3333);
						end;
					end;
				end;
			end else WriteConsole( ID, 'Game isn''t paused silly', BAD );
		end;

		'!list': begin
			if resetVotes.voteTimer <= 0 then begin
				WriteConsole( 0, 'No vote going on right now', BAD );
				exit;
			end;
			for b := 1 to MaxID do
				if Player[b].Active then
					if not Player[b].Bot then
						if Player[b].Team < 5 then
							if not Player[b].voted then
							begin
								WriteConsole(0, IDToName( b ) + '     [ UNREADY ]', $CC3333);
								Sleep(10);
							end;
		end;

		//reset gather
		'!unbanlast', '!ub', '!ul':
		begin
			Command('/unbanlast');
			WriteConsole(0, 'Last Player unbanned.', GOOD);
		end;

		//command to request sub
		'!asub': begin
					Writeln('--- subreq');
					WriteConsole(0, 'Requesting a substitute!', GOOD);
				end;
		'!teams': try
					if (GatherMode <> MODE_POR) and (GatherMode <> MODE_M79C) then
					begin
						str := 'Alpha:';
						for b := 0 to Trunc((Gathersize / 2) - 1) do
							str := str + ' � ' + Teams[b];
						WriteConsole(0, str, $B60000);

						str := 'Bravo:';
						for b := Trunc(Gathersize / 2) to (Gathersize - 1) do
							str := str + ' � ' + Teams[b];
						WriteConsole(0, str, $6699FF);
					end else
					begin
						str := 'Players:';
						for b := 0 to Gathersize - 1 do
							str := str + ' � ' + Teams[b];
						WriteConsole(0, str, BOTSTRING);
					end;
				except
					WriteConsole(0, 'Teams array messed up.', BAD);
				end;
		'!a', '!alpha': begin
							Player[ID].Spectator := False;
							Command('/setteam1 '+ inttostr(ID));
						end;
		'!b', '!bravo': begin
							Player[ID].Spectator := False;
							Command('/setteam2 ' + inttostr(ID));
						end;
		'!s', '!spec', '!spect':
						begin
							Player[ID].Spectator := True;
							Command('/setteam5 ' + inttostr(ID));
						end;
	end
end;
