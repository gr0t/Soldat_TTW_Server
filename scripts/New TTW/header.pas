const
	S_VERSION = '2.0.1';
	IRC = '#soldat.eat-this! @ Quakenet';
	WWW = 'www.eat-that.org';
	
	//COLOURS
	ANNOUNCEMENT1 = $FFFFFFFF;
//	INFORMATION = $8888FF;
	INFORMATION = $D3D3D3;
	GOOD = $8Ec163;
	BAD = $FF6666;
	TEAMCHAT =$ADFF30;
	H_COLOUR = $F4A460;
	I_COLOUR = $F0FFFF;
	C_COLOUR = $FAEBD7;
	TAPCOLOUR = $FF1E14;
	
	ANG_PI   = 3.14159265;
	DEG_2_RAD = ANG_PI / 180;
	ANGLE_15 = ANG_PI / 12;
	ANGLE_30 = ANG_PI / 6;
	ANGLE_40 = DEG_2_RAD * 40;
	ANGLE_45 = ANG_PI / 4;
	ANGLE_60 = ANG_PI / 3;
	ANGLE_70 = DEG_2_RAD * 70;
	ANGLE_80 = DEG_2_RAD * 80;
	ANGLE_90 = ANG_PI / 2;
	ANGLE_100= DEG_2_RAD * 100;
	ANGLE_110= DEG_2_RAD * 110;
	ANG_2PI  = ANG_PI * 2;
	
	DEBUGLEVEL = 99;
	
	STRIKE_FF = true;
	FRIENDLY_FIRE_FACTOR = 0.5;


(*****TASKS*****
 * 1. Long range infarty DONE
 * 2. Short range infarty DONE
 * 3. Medic DONE
 * 4. General DONE
 * 5. Radioman DONE
 * 6. Saboteur DONE
 * 7. Engineer DONE
 * 8. Elite DONE
 * 9. Spy DONE
 * 10. Artillery DONE
 ***************)
 
(* TODO
 * - m00
 *)
 
(* CHANGELOG
 * - moved from GetPlayerStat to OnEvent variables
 * - completly rewritten and redesigned code
 * - added localization support
 * - added ballisitc functions support
 * - added OnScreen text priority system
 * - Modified radioman's battery charges only when alive
 * - Modified scramble replaced with dotting
 * - Modified quick commands for:
	 Spy: 1 - stealth | 2 - obs | 3 - place 3 | 4 - act|
	 Rad: 										4 - barrage
	 Art: 						  3 - mark		4 - mortal
 * - Removed Spy's command /rig, charges now rig close SG's
 * - Modified the mines' system (Stolen from LS)
 * - Modified strikes use now ballistic functions
 * - Modified every bullet handled by server rigs everything they hit
 * - Removed howitzer strike
 * - Removed /enemysg and /statgun strikes
 * - Added /enemybase strike
 * - Added /nuke strike (howitzer replacement)
 * - Modified strikes now goes from bunker to bunker (can't spawnkill, that doesn't count for enemy base strike).
 * - Modified burning areas system (Stolen from LS)
 * - Modified spy can place all three bombs using only one command (/place time1 time2 time3)
 * - Modified artillery's nuke -> mortal
 *)
