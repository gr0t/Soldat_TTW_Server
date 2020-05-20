const
	MAXSTATGUNS = 2;

type
	tStat = record
		X, Y: single;
		ID: byte; //team: byte;
		placed: boolean;
	end;		
	
var
	SG: Array[1..MAXSTATGUNS] of tStat;
	