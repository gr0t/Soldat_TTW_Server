const
	STRIKE_COUNTDOWN = 3;

type
	tLastBullet = record
		X: single;
	end;
	
	tArea = record
		X, Y: single;
		start: integer;
		range, child: byte;
	end;

	tStrike = record
		InProgress: boolean;
		stype: (__enemybase, __napalm, __nuke, __barrage, __zeppelin, __airco, __clusterstr, __burst);
		Bullets: byte;
		CountDown: shortint;
		X1, X2, Y: single;
		LastBullet: tLastBullet;
		Area: array of tArea;
	end;

var
	StrikeBot: byte;
