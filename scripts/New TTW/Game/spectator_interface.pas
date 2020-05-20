//TODO: translations
procedure WriteToSpect(Text: string; Color: longint);
var
	i: byte;
begin
	for i := 1 to MaxID do		
		if player[i].Team = 5 then
			WriteConsole(i, Text, Color);
end;

procedure DrawToSpect(Priority: byte; Text: string; Delay: integer; Color: longint; Scale: single; X, Y: integer);
var
	i: byte;
begin
	for i := 1 to MaxID do
		if player[i].alive then
			if player[i].Team = 5 then
				DrawTextX(i, Priority, Text, Delay, Color, Scale, X, Y);
end;

procedure Spec_Conquer(Team, Bunk: byte; Sabo: boolean);
var
	Text: string;
	Color: longint;
begin

	if Team = 1 then begin
		if Sabo then
			Text := 'Alpha team sabotaged a bunker'
		else
			Text := 'Alpha team conquered a bunker';
		Color := $FF6666;
	end else begin
		if Sabo then
			Text := 'Bravo team sabotaged a bunker'
		else
			Text := 'Bravo team conquered a bunker';
		Color := $6666FF;
	end;
	DrawToSpect(10, Text, 100, Color, 0.1, 20, 370);
end;

procedure Spec_Chat(ID: byte; Text: string);
begin
	WriteToSpect('(TEAM) [' + IDToName(ID) + '] ' + Text, iif_uint32(Player[ID].Team = 1, $FFFF6666, $FF6666FF));
end;

procedure Spec_Supply(Team: byte; Item: (_vest, _vestgen, _law, _grenade, _medi, _cluster, _hac, _para, _enemybase, _napalm, _rocket, _barrage, _zeppelin, _airco, _clusterstr, _burst, _flamer));
var
	Text: string;
	Color: longint;
begin
	case Team of
		1: begin
			case Item of
				_vest: Text := 'Alpha radioman ordered vest';
				_vestgen: Text := 'Alpha radioman ordered a vest for general';
				_law: Text := 'Alpha radioman ordered LAWs';
				_grenade: Text := 'Alpha radioman ordered grenade kit';
				_medi: Text := 'Alpha radioman ordered medical kit';
				_cluster: Text := 'Alpha radioman ordered cluster grenade kit';
				_hac: Text := 'Alpha radioman ordered HAC';
				_para: Text := 'Alpha radioman ordered a paratrooper';
				_enemybase: Text := 'Alpha radioman ordered enemy base strike';
				_napalm: Text := 'Alpha radioman ordered napalm strike';
				_barrage: Text := 'Alpha radioman ordered barrage strike';
				_zeppelin: Text := 'Alpha radioman ordered zeppelin strike';
				_airco: Text := 'Alpha radioman ordered airco strike';
				_clusterstr: Text := 'Alpha radioman ordered cluster strike';
				_burst: Text := 'Alpha radioman ordered burst strike';
				_flamer: Text := 'Alpha radioman ordered flamer';
			end;
			Color := $FF6666;
		end;
		2: begin
			case Item of
				_vest: Text := 'Bravo radioman ordered vest';
				_vestgen: Text := 'Bravo radioman ordered a vest for general';
				_law: Text := 'Bravo radioman ordered LAWs';
				_grenade: Text := 'Bravo radioman ordered grenade kit';
				_medi: Text := 'Bravo radioman ordered medical kit';
				_cluster: Text := 'Bravo radioman ordered cluster grenade kit';
				_hac: Text := 'Bravo radioman ordered HAC';
				_para: Text := 'Bravo radioman ordered a paratrooper';
				_enemybase: Text := 'Bravo radioman ordered enemy base strike';
				_napalm: Text := 'Bravo radioman ordered napalm strike';
				_barrage: Text := 'Bravo radioman ordered barrage strike';
				_zeppelin: Text := 'Bravo radioman ordered zeppelin strike';
				_airco: Text := 'Bravo radioman ordered airco strike';
				_clusterstr: Text := 'Bravo radioman ordered cluster strike';
				_burst: Text := 'Bravo radioman ordered burst strike';
				_flamer: Text := 'Bravo radioman ordered flamer';
			end;
			Color := $6666FF;
		end;
	end;
	WriteToSpect(Text, Color);
end;

procedure Spec_SwitchTask(ID, NewTask: byte);
begin
	WriteToSpect(IDToName(ID) + ' is now ' + taskToName(NewTask, 0), iif_uint32(Player[ID].Team = 1, $FFFF6666, $FF6666FF));
end;

procedure SpectatorAOI();
var
	i: Byte;
	Message: string;
begin
	if Spectators > 0 then begin		
		if GetArrayLength(Bunker) > 0 then begin
			Message := '[';
			case Bunker[0].owner of
				1: Message := Message + 'A';
				2: Message := Message + 'B';
				else Message := Message + 'X'
			end;			
			for i := 1 to GetArrayLength(Bunker)-1 do begin
				case Bunker[i].owner of
					1: Message := Message + '-A';
					2: Message := Message + '-B';
					else Message := Message + '-X'
				end;
			end;
			Message := Message + ']';
			DrawToSpect(100, Message, 500, $FFFFFFFF, 0.1, 20, 370);
		end;		
	end;
end;