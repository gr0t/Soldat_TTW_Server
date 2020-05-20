procedure CreateBurningArea2(var flame: array of tVector; duration, owner: byte);
var i, a, n, l: byte;
begin
	for i:=1 to MAXAREAS do
		if not BurningAreas.Area[i].Active then begin
			a:=i;
			break;
		end;
	if a = 0 then exit;
	l := GetArrayLength(flame);
	n := 0;
	i := 0;
	while n < FLAMESNUM do begin
		if i = l then break;
		if flame[i].t > 0 then begin
			n := n + 1;
			BurningAreas.Area[a].fa[n] := true;
			BurningAreas.Area[a].fx[n] := flame[i].x;
			BurningAreas.Area[a].fy[n] := flame[i].y;
		end;
		i := i + 1;
	end;
	BurningAreas.Area[a].Active := true;
	BurningAreas.Area[a].duration:=duration;
	BurningAreas.Area[a].owner:=owner;
	BurningAreas.Area[a].flameN:=n;
	BurningAreas.Active := true;
end;

procedure ProcessBurningAreas(Ticks: integer);
var
	x, y: single;
	i, j, k, l, m, n: byte;
	o: integer;
	burnt: array[1..32] of boolean;
	Active: boolean;
begin
	if BurningAreas.Active then begin
		for i:=1 to MAXAREAS do begin
			if BurningAreas.Area[i].Active then begin
				BurningAreas.Area[i].Active:=(player[BurningAreas.Area[i].owner].Active) and (BurningAreas.Area[i].duration > 0);
				if not BurningAreas.Area[i].Active then continue;
				BurningAreas.Area[i].duration:=BurningAreas.Area[i].duration-1;
				Active := true;
				for j := 1 to BurningAreas.Area[i].flameN do
					BurningAreas.Area[i].fn[j] := 0;
				o := 0;
				for j := 1 to MAXAREAS do // decrease the number of flames on area if there are many flames in game
					if BurningAreas.Area[j].Active then o := o + ToRange(2, BurningAreas.Area[j].duration, 7);
				o := Trunc(o / 8.0);
				n := ToRange(3, BurningAreas.Area[i].duration, ToRange(4, - o + BurningAreas.Area[i].flameN * 3 div 2 + 1, 10));
				for k := 1 to n do begin
					o := 0; // randomize spawn position of flames
					try
						j := RandInt(1, BurningAreas.Area[i].flameN); // start looping from random index
					except
						WriteConsole(0, inttostr(BurningAreas.Area[i].flameN), RGB(100,255,100));
					end;
					l := $FF;
					repeat // choose the position with the lowest number of already created flames
						o := o + 1;
						j := j + 1;
						if j > BurningAreas.Area[i].flameN then j := 1;
						if BurningAreas.Area[i].fa[j] then
							if BurningAreas.Area[i].fn[j] < l then begin
								l := BurningAreas.Area[i].fn[j];
								m := j;
							end;
					until o >= BurningAreas.Area[i].flameN;
					if l <> $FF then begin
						incB(BurningAreas.Area[i].fn[m], 1);
						CreateBullet(BurningAreas.Area[i].fx[m]-RandFlt(-20,20), BurningAreas.Area[i].fy[m]-RandFlt(7,10)*BurningAreas.Area[i].fn[m], RandFlt(-0.2, 0.2), RandFlt(1.5, 3), -FLAMEAREADMG, 5, BurningAreas.Area[i].owner);
						//p := ToRangeB(2, BurningAreas.Area[i].duration div 4, 3);
						for j:=1 to MaxID do
							if player[j].Alive then
								if not burnt[j] then
									if (player[j].Team) <> (player[BurningAreas.Area[i].owner].Team) then begin
										GetPlayerXY(j, x, y);
										if SqrDist(x, y, BurningAreas.Area[i].fx[m], BurningAreas.Area[i].fy[m]) <= 3600 then begin
											DoDamageBy(j, BurningAreas.Area[i].owner, AREADMG);
											burnt[j] := true;
											//for m:=1 to p do
											CreateBullet(x+RandFlt(-8, 8), y-RandFlt(2, 6)*m, 0, 0, -FLAMEAREADMG, 5, BurningAreas.Area[i].owner);
										end;
									end;
					end;
				end;
			end;
		end;
		BurningAreas.Active := Active;
	end;
end;

procedure ClearBurningAreas();
var i, j: byte;
begin
	for i := 1 to MAXAREAS do begin
		BurningAreas.Area[i].Active:=false;
		BurningAreas.Area[i].owner:=0;
		BurningAreas.Area[i].duration:=0;
		for j:=1 to FLAMESNUM do begin
			BurningAreas.Area[i].fx[j]:=0;
			BurningAreas.Area[i].fy[j]:=0;
			BurningAreas.Area[i].fn[j]:=0;
			BurningAreas.Area[i].fa[j]:=false;
		end;
	end;
end;