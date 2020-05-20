const
	MAXWEAPONS = 16;
	SUPPLYTIME = 10;
	SPINCREASE = 7;
	MAXHEALTH = 65;

type
	tPlayer = record
		active, alive, human: boolean;
		team, pri, sec, translation, mre: byte;
		task: shortint;
		kills, deaths: word;
		X, Y, VX, VY, RespX, RespY, hp: single;
		JustJoined, JustResp, GetXY: boolean;
		weapons: array [0..MAXWEAPONS] of boolean;
		text: tText;
		HWID: string;
	end;
	
	tTeam = record
		member: array of byte;
		bunker, SPTimer, SPFreq, MinesRefreshTimer, Mines, MinesPlaced, StatgunRefreshTimer: byte;
		SP: word;
		Strike: tStrike;
	end;
	
		
	tStored = record
		HWID: String;
		Timer: byte;
		X, Y: single;
		Task, mre, Nades, ID, ConqBunker: byte;
		ConqTimer: byte;
		HP, Vest: single;
		Pri, Sec: byte;
		Ammo, SecAmmo: Byte;
		Sabotaging: boolean;
	end;
		
var
	player: array[1..32] of tPlayer;
	teams: array[1..2] of tTeam;
	ServerSetTeam, ServerForceWeapon: boolean;
	MaxID, MaxHP, WarmUp, tempA, tempB: byte;
	BackUp: tStored;
	
	GatherDir: string;
	GatherOn: Byte;
	Pause, FriendlyFire: boolean;
	