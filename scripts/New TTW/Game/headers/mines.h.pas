type
	tMine = record
		X, Y: single;
		placed: boolean;
		Owner: byte;
		Timer: byte;
	end;
	
const
	MAXMINES = 2; //In total.
	// mine constants from LS
	MRMAX =    30; // max mine range
	MRMIN =    10; // min mine range
	SRFACTOR = 8; // speed -> range factor
	PSFACTOR =  1; // position shift factor
	MAXANGLE = 0.6981317; // max angle between vectors (player_speed, distance_mine_player)
	MINES_REFRESH_TIME = 100;
	MINES_ACTIVATE_TIME = 2;
	MINE_RIG_DISTANCE = 100;
	
var Mines: array[1..MAXMINES] of tMine;
