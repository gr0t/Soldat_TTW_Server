//TTW to Gather
//Results the tickets of a Team
function GetTicks(Team: byte): Integer;
begin
	Result := CrossFunc([Team], GatherDir +'GetTicks');
end;

//Updates the bunkers for gather script
procedure updateBunkers();
var InBase: boolean;
	InSabo: boolean;
begin
	if (Bunker[Teams[1].Bunker].style < -1) or (Bunker[Teams[2].bunker].style > 1) then
		InBase := true
	else if (Bunker[Teams[1].Bunker].style < 0) or (Bunker[Teams[2].bunker].style > 0) then
		InSabo := true;
	if (GatherDir <> '') and (GatherOn = 2) then
		CrossFunc([Teams[1].Bunker + 1, GetArrayLength(Bunker) - Teams[2].Bunker, InBase, InSabo], GatherDir +'SetBunkerNumbers');
end;


procedure SendToLive(Text: String);
begin
	if GatherDir = '' then exit;
	if GatherOn <> 2 then exit;
	
	WriteLn('--- ' + Text);
end;
