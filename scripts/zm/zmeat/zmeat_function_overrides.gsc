#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\zmeat;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\gametypes_zm\_globallogic_ui;

main()
{
	replaceFunc( maps\mp\zombies\_zm::player_monitor_time_played, ::player_monitor_time_played_override );
	replaceFunc( maps\mp\gametypes_zm\_zm_gametype::round_logic, ::round_logic_override );
	replaceFunc( maps\mp\zombies\_zm_stats::initializeMatchStats, ::initializeMatchStats_override );
	replaceFunc( maps\mp\zombies\_zm_utility::track_players_intersection_tracker, ::track_players_intersection_tracker_override );
	replaceFunc( maps\mp\_utility::setclientfieldtoplayer, ::setclientfieldtoplayer_override );
	replaceFunc( maps\mp\_visionset_mgr::update_clientfields, ::update_clientfields_override );
	replaceFunc( maps\mp\zombies\_zm::watch_rampage_bookmark, ::watch_rampage_bookmark_override );
	replaceFunc( maps\mp\zombies\_zm_spawner::play_ambient_zombie_vocals, ::play_ambient_zombie_vocals_override );
	replaceFunc( maps\mp\zombies\_zm::getFreeSpawnpoint, ::getFreeSpawnpoint_override );
	replaceFunc( maps\mp\gametypes_zm\_globallogic_ui::setupcallbacks, ::setupcallbacks_override );
	level._game_module_player_laststand_callback = ::meat_last_stand_callback;
}

init()
{
	level.autoassign = ::menuautoassign_override;
}

meat_last_stand_callback( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	if ( isdefined( self._has_meat ) && self._has_meat )
		level thread item_meat_drop( self.origin, self._encounters_team );
}

startnextzmround_override( winner )
{
	if ( !isonezmround() )
	{
		if ( !waslastzmround() )
		{
			nextzmhud( winner );
			setmatchtalkflag( "DeadChatWithDead", level.voip.deadchatwithdead );
			setmatchtalkflag( "DeadChatWithTeam", level.voip.deadchatwithteam );
			setmatchtalkflag( "DeadHearTeamLiving", level.voip.deadhearteamliving );
			setmatchtalkflag( "DeadHearAllLiving", level.voip.deadhearallliving );
			setmatchtalkflag( "EveryoneHearsEveryone", level.voip.everyonehearseveryone );
			setmatchtalkflag( "DeadHearKiller", level.voip.deadhearkiller );
			setmatchtalkflag( "KillersHearVictim", level.voip.killershearvictim );
			game["state"] = "playing";
			level.allowbattlechatter = getgametypesetting( "allowBattleChatter" );

			if ( isdefined( level.zm_switchsides_on_roundswitch ) && level.zm_switchsides_on_roundswitch )
				set_game_var( "switchedsides", !get_game_var( "switchedsides" ) );
			return true;
		}
	}

	return false;
}

player_monitor_time_played_override()
{
	return;
}

initializeMatchStats_override()
{
	return;
}

track_players_intersection_tracker_override()
{
	return;
}

setclientfieldtoplayer_override( field_name, value )
{
	return;
	// if ( !isDefined( self ) || !isPlayer( self ) || self isTestClient() || !isDefined( field_name ) || !isDefined( value ) )
	// {
	// 	return;
	// }
	// codesetplayerstateclientfield( self, field_name, value );
}

update_clientfields_override( player, type_struct )
{
	return;
	// if ( !isDefined( player ) || !isPlayer( player ) || self isTestClient() || !isDefined( type_struct ) )
	// {
	// 	return;
	// }
    // name = player get_first_active_name( type_struct );
    // player setclientfieldtoplayer( type_struct.cf_slot_name, type_struct.info[name].slot_index );

    // if ( 1 < type_struct.cf_lerp_bit_count )
    //     player setclientfieldtoplayer( type_struct.cf_lerp_name, type_struct.info[name].state.players[player._player_entnum].lerp );
}

watch_rampage_bookmark_override()
{
	return;
}

updategametypedvars_override()
{
	return;
}

play_ambient_zombie_vocals_override()
{
	self endon( "death" );

	if ( self.animname == "monkey_zombie" || isdefined( self.is_avogadro ) && self.is_avogadro )
		return;

	while ( true )
	{
		type = "ambient";
		float = 2;

		if ( !isdefined( self.zombie_move_speed ) )
		{
			wait 0.5;
			continue;
		}

		switch ( self.zombie_move_speed )
		{
			case "walk":
				type = "ambient";
				float = 4;
				break;
			case "run":
				type = "sprint";
				float = 4;
				break;
			case "sprint":
				type = "sprint";
				float = 4;
				break;
			case "super_sprint":
				type = "sprint";
				float = 4;
				break;
			case "chase_bus":
				type = "sprint";
				float = 4;
				break;
		}

		if ( self.animname == "zombie" && !self.has_legs )
			type = "crawler";
		else if ( self.animname == "thief_zombie" || self.animname == "leaper_zombie" )
			float = 1.2;

		name = self.animname;

		if ( isdefined( self.sndname ) )
			name = self.sndname;

		self thread maps\mp\zombies\_zm_audio::do_zombies_playvocals( type, name );
		wait( randomfloatrange( 1, float ) );
	}
}

round_logic_override( mode_logic_func )
{
	level.skit_vox_override = 1;

	if ( isdefined( level.flag["start_zombie_round_logic"] ) )
		flag_wait( "start_zombie_round_logic" );
	flag_wait( "initial_blackscreen_passed" );
	flag_wait( "start_encounters_match_logic" );

	if ( !isdefined( game["gamemode_match"]["rounds"] ) )
		game["gamemode_match"]["rounds"] = [];

	set_gamemode_var_once( "current_round", 0 );
	set_gamemode_var_once( "team_1_score", 0 );
	set_gamemode_var_once( "team_2_score", 0 );

	if ( isdefined( is_encounter() ) && is_encounter() )
	{
		[[ level._setteamscore ]]( "allies", get_gamemode_var( "team_2_score" ) );
		[[ level._setteamscore ]]( "axis", get_gamemode_var( "team_1_score" ) );
	}

	flag_set( "pregame" );
	waittillframeend;
	level.gameended = 0;
	cur_round = get_gamemode_var( "current_round" );
	set_gamemode_var( "current_round", cur_round + 1 );
	game["gamemode_match"]["rounds"][cur_round] = spawnstruct();
	game["gamemode_match"]["rounds"][cur_round].mode = getdvar( "ui_gametype" );
	level thread [[ mode_logic_func ]]();
	flag_wait( "start_encounters_match_logic" );
	level.gamestarttime = gettime();
	level.gamelengthtime = undefined;
	level notify( "clear_hud_elems" );

	level waittill( "game_module_ended", winner );

	game["gamemode_match"]["rounds"][cur_round].winner = winner;
	level thread kill_all_zombies();
	level.gameendtime = gettime();
	level.gamelengthtime = level.gameendtime - level.gamestarttime;
	level.gameended = 1;

	if ( winner == "A" )
	{
		score = get_gamemode_var( "team_1_score" );
		set_gamemode_var( "team_1_score", score + 1 );
	}
	else
	{
		score = get_gamemode_var( "team_2_score" );
		set_gamemode_var( "team_2_score", score + 1 );
	}

	if ( isdefined( is_encounter() ) && is_encounter() )
	{
		[[ level._setteamscore ]]( "allies", get_gamemode_var( "team_2_score" ) );
		[[ level._setteamscore ]]( "axis", get_gamemode_var( "team_1_score" ) );
	}

	level thread delete_corpses();
	level delay_thread( 5, ::revive_laststand_players );
	level notify( "clear_hud_elems" );

	if ( startnextzmround_override( winner ) )
	{
		//level clientnotify( "gme" );
		exitLevel( false );
		while ( true )
			wait 1;
	}

	level.match_is_ending = 1;

	if ( isdefined( is_encounter() ) && is_encounter() )
	{
		level create_final_score();
	}

	maps\mp\zombies\_zm::intermission();
	level.can_revive_game_module = undefined;
	level notify( "end_game" );
}

getFreeSpawnpoint_override( spawnpoints, player )
{
	if ( !isdefined( spawnpoints ) )
	{
		return undefined;
	}
	foreach ( spawnpoint in spawnpoints )
	{
		print( "getFreeSpawnpoint() spawnpoint.script_int = " + spawnpoint.script_int + " desired = " + self.spawnpoint_desired_script_int );
		if ( spawnpoint.script_int == self.spawnpoint_desired_script_int )
		{
			if ( isDefined( spawnpoint.player_name ) && spawnpoint.player_name == self.name )
			{
				return spawnpoint;
			}
			else if ( !isDefined( spawnpoint.player_name ) )
			{
				spawnpoint.player_name = self.name;
				return spawnpoint;
			}
		}
	}
	//All spawnpoints taken by previous players try to remove old spawnpoints from disconnected players
	print( "getFreeSpawnpoint() is trying to reuse old spawnpoints" );
	foreach ( spawnpoint in spawnpoints )
	{
		spawnpoint_is_active = false;
		foreach ( player in level.players )
		{
			if ( spawnpoint.player_name == player.name )
			{
				spawnpoint_is_active = true;
				break;
			}
		}
		if ( !spawnpoint_is_active )
		{
			if ( spawnpoint.script_int == self.spawnpoint_desired_script_int )
			{
				spawnpoint.player_name = self.name;
				return spawnpoint;
			}
		}
	}
	print( "getFreeSpawnpoint() is returning the spawnpoint with the same script int as a failsafe THIS SHOULD NOT HAPPEN!" );
	foreach ( spawnpoint in spawnpoints )
	{
		if ( spawnpoint.script_int == self.spawnpoint_desired_script_int )
		{
			return spawnpoint;
		}
	}
	return spawnpoints[ 0 ];
}

setupcallbacks_override()
{
	level.autoassign = ::menuautoassign_override;
	level.spectator = ::menuspectator;
	level.class = ::menuclass;
	level.teammenu = ::menuteam;
}

menuautoassign_override( comingfrommenu )
{
	teamkeys = getarraykeys( level.teams );
	assignment = "";
	self closemenus();
	if ( level.teambased )
	{
		if ( assignment == "" )
		{
			teamplayersallies = countplayers("allies");
			teamplayersaxis = countplayers("axis");

			if(teamplayersallies == teamplayersaxis)
			{
				assignment = "allies";
				self._encounters_team = "A";
			}
			else
			{
				if(teamplayersallies > teamplayersaxis)
				{
					assignment = "axis";
					self._encounters_team = "B";
				}
				else
				{
					assignment = "allies";
					self._encounters_team = "A";
				}
			}
		}
	}
	self.pers["team"] = assignment;
	self.team = assignment;
	self.pers["class"] = undefined;
	self.class = undefined;
	self.pers["weapon"] = undefined;
	self.pers["savedmodel"] = undefined;
	self updateobjectivetext();

	if ( level.teambased )
		self.sessionteam = assignment;

	if ( !isalive( self ) )
		self.statusicon = "hud_status_dead";

	if ( !isdefined( game["spawns_randomized"] ) )
	{
		game["spawns_randomized"] = 1;
		random_chance = randomint( 100 );

		if ( random_chance > 50 )
			set_game_var( "side_selection", 1 );
		else
			set_game_var( "side_selection", 2 );
	}
	side_selection = get_game_var( "side_selection" );
	if ( get_game_var( "switchedsides" ) )
	{
		if ( side_selection == 2 )
		{
			side_selection = 1;
		}
		else if ( side_selection == 1 )
		{
			side_selection = 2;
		}
	}
	if ( side_selection == 1 ) 
	{
		if ( assignment == "allies" )
		{
			side_selection = 2;
		}
	}
	else 
	{
		if ( assignment == "allies" )
		{
			side_selection = 1;
		}
	}

	self.spawnpoint_desired_script_int = side_selection;

	self notify( "joined_team" );
	level notify( "joined_team" );
	self notify( "end_respawn" );
	self beginclasschoice();
	self setclientscriptmainmenu( game["menu_class"] );
}
