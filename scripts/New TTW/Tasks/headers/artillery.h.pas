const
	NADEWAITTIME = 20;
	MORTARWAITTIME = 40;
	MORTARSPEED = 20;
	MORTARFIRETIME = 12;

type
	tMarker = record
		active: boolean;
		X, Y: single;
	end;

	tRigArea = record
		X, Y: single;
		start: integer;
	end;

	tMortar = record
		X, Y, Angle: single;
		Timer: shortint;
		RigArea: array of tRigArea;
	end;
	
	tArtillery = record
		ID: byte;
		NadeTimer: shortint;
		Marker: tMarker;
		Mortar: tMortar;
	end;

var
	Artillery: array[1..2] of tArtillery;

procedure ArtilleryCommands(ID: byte);
begin
	WriteConsole(ID, t(116, Player[ID].Translation, '/nade    - drops a grenade kit near you'),C_COLOUR);
	WriteConsole(ID, t(117, Player[ID].Translation, '/mark    - places mortar''s mark on the map'),C_COLOUR);
	WriteConsole(ID, t(118, Player[ID].Translation, '/mortar  - fire up mortar'),C_COLOUR);
end;

procedure ArtilleryInfo(ID: byte);
begin
	WriteConsole(ID, t(119, player[ID].translation, 'You are the Artillery'), H_COLOUR);
	WriteConsole(ID, t(120, player[ID].translation, 'You can drop grenade kits, and fire mortar cannon.'), I_COLOUR);
	ArtilleryCommands(ID);
end;

procedure AssignArtillery(ID, Team: byte);
begin
	Artillery[Team].ID := ID;
	player[ID].weapons[7] := true;
	player[ID].weapons[14] := true;
	ArtilleryInfo(ID);
end;

procedure ResetArtillery(Team: byte; left: boolean);
begin
	if left then Artillery[Team].ID := 0;
	SetArrayLength(Artillery[Team].Mortar.RigArea, 0);
	Artillery[Team].Mortar.Timer := MORTARWAITTIME;
	Artillery[Team].Mortar.Angle := 0;
	Artillery[Team].Mortar.X := 0;
	Artillery[Team].Mortar.Y := 0;
	Artillery[Team].NadeTimer := NADEWAITTIME;
	Artillery[Team].Marker.active := false;
	Artillery[Team].Marker.X := 0;
	Artillery[Team].Marker.Y := 0;
end;
