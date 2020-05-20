procedure OnSpyRespawn(ID: byte);
begin
	Spy[Player[ID].Team].BombsLeft := Spy[Player[ID].Team].BombsLeft + 1;
	if Spy[Player[ID].Team].BombsLeft > SPY_MAXBOMBS then
		Spy[Player[ID].Team].BombsLeft := SPY_MAXBOMBS;
	WriteConsole(ID, t(0, Player[ID].Translation, 'You have ' + IntToStr(Spy[Player[ID].Team].BombsLeft) + iif(Spy[Player[ID].Team].BombsLeft > 1, ' charges', ' charges') + ' to place'), GOOD);
	Spy[Player[ID].Team].Stealth := True;
end;

procedure OnSpyDeath(Team: byte);
var i: byte;
begin
	for i := 1 to SPY_MAXBOMBS do
		if Spy[Team].Bombs[i].Activated = False then
			Spy[Team].Bombs[i].Timer := 0;
end;

procedure placeBomb(ID, time: byte; X, Y: single);
var
	i: byte;
begin
	if (time >= SPY_MIN_TIMER) and (time <= SPY_MAX_TIMER) then
	begin
		for i := 1 to SPY_MAXBOMBS do
			if Spy[Player[ID].Team].Bombs[i].Timer < 1 then
				if not Spy[Player[ID].Team].Bombs[i].Activated then break;
		Spy[Player[ID].Team].Bombs[i].X := X;
		Spy[Player[ID].Team].Bombs[i].Y := Y - 4;
		Spy[Player[ID].Team].Bombs[i].Timer := time;
		Spy[Player[ID].Team].Bombs[i].Owner := ID;
		
		Spy[Player[ID].Team].BombsLeft := Spy[Player[ID].Team].BombsLeft - 1;
		WriteConsole(ID, t(264, Player[ID].Translation, 'Bomb placed! Type /activate (/act) to activate the bombs'), GOOD);							
	end else WriteConsole(ID, t(265, Player[ID].Translation, 'Bombs can be timed with 3 to 8 seconds.'), BAD); // don't want to include t here with constants
end;

procedure Observe(ID: byte);
var
	i, r: byte;
	MinDistance: word;
	Distvar: single;
begin
	GetPlayerXY(ID, player[ID].X, player[ID].Y);
	MinDistance := SPY_OBSERVE_RANGE * SPY_OBSERVE_RANGE;
	//Find a Target
	for i := 1 to MaxID do
		if player[i].Team <> Player[ID].Team then						
			if Player[i].Alive then
			begin
				GetPlayerXY(i, player[i].X, player[i].Y);
				if not RayCast(player[ID].X, player[ID].Y-7, player[i].X, player[i].Y-7, Distvar, SPY_OBSERVE_RANGE) then continue;
				r := i;
			end;
			
	if r > 0 then
	begin
		if Player[r].Task = 0 then Exit;							
		Spy[Player[ID].Team].ObsTimer := SPY_OBSERVE_TIME;
		
		//Report it to the team
		for i := 0 to GetArrayLength(Teams[Player[ID].Team].member) - 1 do
		begin
			WriteConsole(Teams[Player[ID].Team].member[i], '[SPY]' + IDToName(ID) + ': ' + t(266, Player[Teams[Player[ID].Team].member[i]].Translation, '(REPORT)'), TAPCOLOUR);
			WriteConsole(Teams[Player[ID].Team].member[i], '* ' + IDToName(r) + ' ' + t(267, Player[Teams[Player[ID].Team].member[i]].Translation, 'is an enemy') +' '+ TaskToName(Player[r].Task, Player[Teams[Player[ID].Team].member[i]].Translation), TAPCOLOUR);
			if r = Radioman[Player[r].Team].ID then
			begin
				WriteConsole(Teams[Player[ID].Team].member[i], '* ' + t(268, Player[Teams[Player[ID].Team].member[i]].Translation, 'Enemy Supply Points:')+' '+ + inttostr(Teams[Player[r].Team].SP), TAPCOLOUR);
				if Radioman[Player[r].Team].TapCounter < 0 then 
					WriteConsole(Teams[Player[ID].Team].member[i], '* ' + t(269, Player[Teams[Player[ID].Team].member[i]].Translation, 'Enemy Radioman is tapping!'), TAPCOLOUR);
			end;	
		end;	
	end else WriteConsole(ID, t(270, Player[ID].Translation, 'No enemy in sight!'), BAD)
end;

function OnSpyCommand(ID: byte; var Text: string): boolean;
var
	i, timer: byte;
	found: boolean;
begin
	Result := True;
	
	case LowerCase(GetPiece(Text, ' ', 0)) of
		'/stea', '/stealth': if player[ID].alive then begin
			if Spy[Player[ID].Team].Stealth then 
			begin
				Spy[Player[ID].Team].Stealth := False;
				GiveBonus(ID, 1);
				DoDamageBy(ID, ID, Trunc(MaxHP - Player[ID].hp));
				WriteConsole(ID, t(271, Player[ID].Translation, 'Stealth activated!'), GOOD);
			end else WriteConsole(ID, t(272, player[ID].translation, 'No stealthpack avalilable'), BAD);
		end else
			WriteConsole(ID, t(171, player[ID].translation, 'You''re already dead'), BAD);
					
		'/place': if player[ID].alive then begin
			GetPlayerXY(ID, player[ID].X, player[ID].Y)
			if RayCast2(0, 5, 50, player[ID].X, player[ID].Y) then begin
				WriteConsole(ID, t(306, Player[ID].Translation, 'Can''t place charges in midair'), BAD);
				exit;
			end;
			RayCast2(0, 1, 5, player[ID].X, player[ID].Y);
			delete(Text, 1, 7);
			if Length(Text) < 1 then WriteConsole(ID, t(273, Player[ID].Translation, 'Syntax Error: /place <time> | Example: /place 3'), BAD);
			while Length(Text) > 0 do begin
				if Spy[Player[ID].Team].BombsLeft < 1 then 
				begin
					WriteConsole(ID, t(274, Player[ID].Translation, 'No bombs left!'), BAD);
					exit;
				end;
				i := Pos(' ', Text);
				if i = 0 then i := Length(Text)+1;
				try timer := StrToInt(Copy(Text, 1, i-1)); 
				except WriteConsole(ID, t(273, Player[ID].Translation, 'Syntax Error: /place <time> | Example: /place 3'), BAD); exit; end;
				delete(Text, 1, i);
				placeBomb(ID, timer, player[ID].X, player[ID].Y);
			end;
		end else
			WriteConsole(ID, t(275, player[ID].translation, 'You have to be alive to place a bomb'), BAD);
					
		'/act', '/activate': if player[ID].alive then begin
			for i := 1 to SPY_MAXBOMBS do
				if Spy[Player[ID].Team].Bombs[i].Timer > 0 then
					if not Spy[Player[ID].Team].Bombs[i].Activated then
					begin
						Spy[Player[ID].Team].Bombs[i].Activated := True;
						found := True;
					end;
			if found then 
			begin
				WriteConsole(ID, t(276, Player[ID].Translation, 'Timer activated!'), GOOD);
				SendToLive('spybomb' +  inttostr(player[ID].Team));
			end	else WriteConsole(ID, t(277, Player[ID].Translation, 'No inactive bombs placed!'), BAD);
		end else
			WriteConsole(ID, t(278, player[ID].translation, 'You have to be alive to activate timers'), BAD);
					
		'/obs', '/observe': if player[ID].alive then begin
			if Spy[Player[ID].Team].ObsTimer < 1 then
			begin
				Observe(ID);
			end else WriteConsole(ID, t(259, Player[ID].Translation, 'You have to wait')+' '+ + inttostr(Spy[Player[ID].Team].ObsTimer) + ' '+ t(252, Player[ID].translation, 'seconds.'), BAD);
		end else
			WriteConsole(ID, t(279, player[ID].translation, 'You have to be alive to observer enemy'), BAD);
		else Result := False;
	end;
end;

procedure SpyAOI(Team: byte);
var
	i, statgun, r: byte;
	X1, Y1, X2, Y2: single;
begin
	for i := 1 to SPY_MAXBOMBS do
		if Spy[Team].Bombs[i].Activated then
		begin
			if Spy[Team].Bombs[i].Timer > 0 then Spy[Team].Bombs[i].Timer := Spy[Team].Bombs[i].Timer - 1;
			if Spy[Team].Bombs[i].Timer = 0 then
			begin
				CreateBullet(Spy[Team].bombs[i].x+18, Spy[Team].bombs[i].y, 0, 0,100, 4, Spy[Team].Bombs[i].Owner);
				CreateBullet(Spy[Team].bombs[i].x-18, Spy[Team].bombs[i].y, -2, 0,100, 4, Spy[Team].Bombs[i].Owner); 						
				CreateBullet(Spy[Team].bombs[i].x, Spy[Team].bombs[i].y-18, 0, -2,100, 4, Spy[Team].Bombs[i].Owner);	
				CreateBullet(Spy[Team].bombs[i].x+RandInt(-8, 9), Spy[Team].bombs[i].y, 2, 0,100, 4, Spy[Team].Bombs[i].Owner);	
				CreateBullet(Spy[Team].bombs[i].x, Spy[Team].bombs[i].y-10, RandInt(-4,5), RandInt(-8,-20)/10,100, 10, Spy[Team].Bombs[i].Owner);	
				//nova_2(Spy[Team].bombs[i].x, Spy[Team].bombs[i].y-10, 0, 0, 20,4,0,3.14,3.14,5,14, Spy[Team].Bombs[i].Owner);
				statgun := GetStatGunAt(Spy[Team].bombs[i].X, Spy[Team].bombs[i].Y, 30);
				if statgun > 0 then
				begin
					WriteConsole(Spy[Team].bombs[i].owner, t(261, Player[Spy[Team].bombs[i].owner].Translation, 'Statgun rigged!'), GOOD);
					DestroyStat(statgun);
					SendToLive('rigsg ' + inttostr(Team));
					Teams[statgun].StatgunRefreshTimer := STATGUN_COOLDOWN_TIME;
					Engineer[statgun].Timer := 0;
					Engineer[statgun].ProcID := 0;
					If GetArrayLength(Teams[2/Team].member) > 0 then
						for r := 0 to GetArrayLength(Teams[2/Team].member)-1 do
							WriteConsole(Teams[2/Team].member[r], t(122, Player[Teams[2/Team].member[r]].Translation, 'Your team''s statgun has been destroyed!'), BAD);												
				end;					
				Spy[Team].Bombs[i].Activated := False;
			end;
		end;
		
	if Spy[Team].ID > 0 then
		if Spy[Team].ObsTimer > 0 then
		begin
			Spy[Team].ObsTimer := Spy[Team].ObsTimer - 1;
			if Spy[Team].ObsTimer = 0 then
				WriteConsole(Spy[Team].ID, t(280, Player[Spy[Team].ID].Translation, 'Ready to observe the enemy!'), GOOD);
		end;
	if Team = 1 then //perform only once
		if Spy[1].ID > 0 then
			if Spy[2].ID > 0 then begin
				GetPlayerXY(Spy[1].ID, X1, Y1);
				GetPlayerXY(Spy[2].ID, X2, Y2);
				if IsInRange(X1, Y1, X2, Y2, 150) then
					for i := 1 to 2 do
						DrawTextX(Spy[i].ID, 30, t(281, player[Spy[i].ID].translation, 'A spy is nearby!'),100, $FF1800, 0.1, 20, 370);
			end;
end;		
