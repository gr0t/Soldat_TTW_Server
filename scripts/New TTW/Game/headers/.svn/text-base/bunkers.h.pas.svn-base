const
	ABASE_SPAWNSTYLE = 10;
	ACONQ_SPAWNSTYLE = 12;
	CONQ_SPAWNSTYLE = 9;
	BCONQ_SPAWNSTYLE = 13;
	BBASE_SPAWNSTYLE = 11;
	X_DELIMITER = 3;

type
	tBunker = record
		ID, MainSpawn, owner: byte;
		style: shortint;
		Enabled: boolean;
		Spawn: array[1..2] of array of byte;
		X1, X2, ReinforcmentX, ReinforcmentY: single;
	end;
	
	tSpawnpoint = record
		ID, style: byte;
		X, Y: single;
		active: boolean;
	end;

var
	Bunker: array of tBunker;
	MaxSpawns: byte;

(***style***
 * -2. Alpha base
 * -1. Alpha conquerable
 * 0. Conquerable
 * 1. Bravo conquerable
 * 2. Brao base
 ***********)
 