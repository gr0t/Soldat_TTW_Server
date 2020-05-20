const
	MAXKITS = 20;
	KITMAXXDISTANCE = 100;
	KITMAXYDISTANCE = 150;
	KITDURATION = 60;

type
	tKit = record
		ID, duration: byte;
		X, Y: single;
		active: boolean;
	end;

var	
	Kit: array[0..MAXKITS] of tKit;
