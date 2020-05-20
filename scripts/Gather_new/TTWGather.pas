//
//     (*)    _ _ _ _   _ _ _ _    _      _     (*)
//    (*)   /_/_/_/_/ /_/_/_/_/   _/     _/    (*)
//   (*)       _/        _/      _/     _/    (*)
//  (*)       _/        _/      _/ _/ _/     (*)
// (*)       _/        _/        _/ _/      (*)
//  
//
// Tactical Trenchwar Script by Joep Vanlier and Tom Jansen
// Uses:
//    xsplit by KeyDon
//
// Please do not distribute and/or alter the script without our permission.
// Thanks and enjoy ... :)
//
//StatisticsGatherLightVersion
//

//

const
	EXPONENT = 0.8;
	e = 2.71828182;
	epsilon = 1e-4;
	SHOWTICKETS_TIME = 30;

var
	ticketsAlpha, ticketsBravo: single;
	ticketTimer: integer;
	numBunkers: integer;
	bunkers: array [1..2] of single;
	AlphaBunk, BravoBunk: integer;
	TeamInBase, TeamInSabo: boolean;

// e^x 
function Exp(X: extended): extended;
var m, n: integer; r, fac, pow: extended;
begin
	m:=Round(Abs(X/10));
	if m >= 2 then
		X:=X/m;
	Result:=1+X;
	fac:=1;
	pow:=X;
	n:=2;
	r:=1;
	while r>epsilon	do
	begin
		fac:=fac*n;
		pow:=pow*X;
		n:=n+1;
		r:=pow/fac;
		Result:=Result+r;
	end;
	if m >= 2 then
	begin
		pow:=Result;
		for n:=2 to m do
			Result:=Result*pow;
	end;
end;

// base^exponent
function Power(Base, Exponent: double): double;
begin
	Result:=Exp(LogN(e, Base)*Exponent);
end;

procedure adjustSPRate();
var projWinner: integer;
begin
	projWinner := 0;

	if gathersize >= 6 then
		if ((TeamInBase) and (numbunkers > 3)) or ((TeamInSabo) and (numBunkers > 5)) then
			if ((AlphaBunk <= 2) and (ticketsAlpha / bunkers[2] < ticketsBravo / bunkers[1])) then
				projWinner := 1
			else if ((AlphaBunk > 2) and (ticketsAlpha / bunkers[2] > ticketsBravo / bunkers[1])) then
				projWinner := 2;

	CrossFunc([projWinner], CoreDir + 'setTeamSPFreq');
end;

// information about number of bunkers is sent here from TTW Core after conquering
procedure SetBunkerNumbers(alpha, bravo: integer; InBase, InSabo: boolean);
begin
	bunkers[1] := Power(alpha, EXPONENT);
	bunkers[2] := Power(bravo, EXPONENT);
	AlphaBunk := alpha;
	BravoBunk := bravo;
	TeamInBase := InBase;
	TeamInSabo := InSabo;
	WriteLn(' [*] '+ ScriptName + ': received bunker numbers: '+ inttostr(alpha) + '|' + inttostr(bravo));
	adjustSPRate();
end;

// needed for crossfunc from TTW Core
function GetTicks(Team: byte): Integer;
begin
	if Team = 1 then Result := Trunc(ticketsAlpha) 
	else Result := Trunc(ticketsBravo);
end;

function GetBunkNum(): Integer;
begin
	Result := numBunkers;
end;

procedure countTickets();
begin
	ticketsAlpha := ticketsAlpha - bunkers[2];
	ticketsBravo := ticketsBravo - bunkers[1];
end;

procedure ttwInitialise();
begin
	ticketTimer := SHOWTICKETS_TIME;
	ticketsAlpha := 500;
	ticketsBravo := 500;
end;

procedure ShowTickets(ID: byte);
begin
	if ticketsAlpha > ticketsBravo then
	begin
		WriteConsole(ID,'Alpha Team has: '+IntToStr(Trunc(ticketsAlpha))+' tickets left!',$FF3520);
		WriteConsole(ID,'Bravo Team has: '+IntToStr(Trunc(ticketsBravo))+' tickets left!',$0000BF);
	end else
	begin
		WriteConsole(ID,'Bravo Team has: '+IntToStr(Trunc(ticketsBravo))+' tickets left!',$6699FF);
		WriteConsole(ID,'Alpha Team has: '+IntToStr(Trunc(ticketsAlpha))+' tickets left!',$B60000);
	end
end;

function ToRange(min, x, max: integer): integer;
begin
	if x < min then Result:=min else
		if x > max then Result:=max else
			Result:=x;
end;

procedure ttwAppOnIdle(Ticks: integer);
begin
	if not CoreFound then exit;
	if GatherOn <> 2 then exit;

	//if gather is running count tickets and check if gather was resetted 
	if GatherOn = 2 then
		if not Pause then
		begin
			countTickets();
			if ( ticketsAlpha < 0 ) or ( ticketsBravo < 0 ) then
			begin
				gatherEndMessage := '--- gatherend '+IntToStr(ToRange(0, Trunc(ticketsAlpha), 99999)) +' '+IntToStr(ToRange(0, Trunc(ticketsBravo), 99999)) +' '+IntToStr(capsRed) + ' ' +IntToStr(capsBlue);
				acknowledge := true;
				WriteLn(gatherEndMessage);
				EndGather();
				if ticketsAlpha > ticketsBravo then
				begin
					WriteConsole(0,'Alpha Won The Match With '+IntToStr(Trunc(ticketsAlpha))+' tickets left!',GOOD);
				end else if ticketsBravo > ticketsAlpha then
					WriteConsole(0,'Bravo Won The Match With '+IntToStr(Trunc(ticketsBravo))+' tickets left!',GOOD)
				else 
					WriteConsole(0,'It''s a tie!!',GOOD);
			end;
		end;

	if ticketTimer > 0 then
		ticketTimer := ticketTimer - 1;

	//displays tickets left while playing if gather is running
	if ticketTimer = 0 then
	begin
		if GatherOn = 2 then
		begin
			ticketTimer := SHOWTICKETS_TIME;
			ShowTickets(0);
		end;
	end;
end;

function ttwOnPlayerCommand(ID: Byte; Text: string): boolean;
begin
	//view team tickets
	if (Text = '/ticks') or (Text = '/tickets') then 
	begin
		ShowTickets(ID);
	end;

	Result := false; 
end;


procedure ttwOnFlagScore(ID, TeamFlag: byte);
begin
	if GatherOn <> 2 then exit;

	if TeamFlag = 2 then
		ticketsBravo := 0.8 * ticketsBravo
	else
		ticketsAlpha := 0.8 * ticketsAlpha;

		adjustSPRate();
end;

procedure ttwOnLeaveGame(ID, Team: byte;Kicked: boolean);
begin
	if GatherOn = 2 then 
		if GetPlayerStat(ID, 'Human') then
			if GetPlayerStat(ID, 'Team') < 3 then
				if (ticketsAlpha > 100) and (ticketsBravo > 100) then
					PauseGame(ID);
end;

procedure ttwOnMapChange(NewMap: string);
var respawnTime: Byte;
begin
	if not CoreFound then
		exit;

	ticketTimer := 0;
	//if gather got reset then set tickets and gather on
	if (GatherOn = 1) or (GatherOn = 2) then
	begin
		numbunkers := CrossFunc([], CoreDir + 'GetNumBunkers');
		Writeln('--- gatherstart ' + StrReplace(CurrentMap, ' ', mapSpaceChar) + ' ' + IntToStr(numbunkers));
		case gathersize of
			2: begin
				ticketsAlpha := 300;
				respawnTime := 5;
			   end;
			4: begin
				ticketsAlpha := 400;
				respawnTime := 6;
			   end;
			6: begin
			    ticketsAlpha := 500;
				respawnTime := 7;
			   end;
			8: begin
			    ticketsAlpha := 600;
				respawnTime := 9;
			   end;
			10:	begin
			    ticketsAlpha := 650;
				respawnTime := 12;
			   end;
			12: begin
			     ticketsAlpha := 700;
				 respawnTime := 14;
				end;
			else ticketsAlpha := 720;
		end;
		ticketsAlpha := ticketsAlpha * numBunkers * EXPONENT;
		ticketsBravo := ticketsAlpha;
		Command('/respawntime ' + IntToStr(respawnTime));
		Command('/minrespawntime ' + IntToStr(respawnTime - 1));
		Command('/maxrespawntime ' + IntToStr(respawnTime + 1));
		SetBunkerNumbers(1, 1, true, false);
	end;
end;