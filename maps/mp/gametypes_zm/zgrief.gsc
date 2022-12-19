// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_game_module_meat_utility;
#include maps\mp\zombies\_zm_game_module_utility;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\gametypes_zm\_weaponobjects;
#include maps\mp\zombies\_zm_audio_announcer;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\gametypes_zm\_globallogic_score;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_spawner;

main()
{
	level._effect["meat_marker"] = loadfx( "maps/zombie/fx_zmb_meat_marker" );
	level._effect["butterflies"] = loadfx( "maps/zombie/fx_zmb_impact_noharm" );
	level._effect["meat_glow"] = loadfx( "maps/zombie/fx_zmb_meat_glow" );
	level._effect["meat_glow3p"] = loadfx( "maps/zombie/fx_zmb_meat_glow_3p" );
	level._effect["spawn_cloud"] = loadfx( "maps/zombie/fx_zmb_race_zombie_spawn_cloud" );
	level._effect["fw_burst"] = loadfx( "maps/zombie/fx_zmb_race_fireworks_burst_center" );
	level._effect["fw_impact"] = loadfx( "maps/zombie/fx_zmb_race_fireworks_drop_impact" );
	level._effect["fw_drop"] = loadfx( "maps/zombie/fx_zmb_race_fireworks_drop_trail" );
	level._effect["fw_trail"] = loadfx( "maps/zombie/fx_zmb_race_fireworks_trail" );
	level._effect["fw_trail_cheap"] = loadfx( "maps/zombie/fx_zmb_race_fireworks_trail_intro" );
	level._effect["fw_pre_burst"] = loadfx( "maps/zombie/fx_zmb_race_fireworks_burst_small" );
	level._effect["meat_bounce"] = loadfx( "maps/zombie/fx_zmb_meat_collision_glow" );
	level._effect["ring_glow"] = loadfx( "misc/fx_zombie_powerup_on" );
	//level.zm_disable_recording_stats = true;
	game[ "gamestarted" ] = undefined;
	level.timelimitoverride = true;
	maps\mp\gametypes_zm\_zm_gametype::main();
	setDvar( "ui_scorelimit", 1 );
	level.meat_round_number = 1;
	level.spawnpoint_system_using_script_ints = true;
	level._encounters_teams_map = [];
	level._encounters_teams_map[ "axis" ] = "A";
	level._encounters_teams_map[ "allies" ] = "B";
	//set_gamemode_var( "match_end_notify", "meat_end" );
	//set_gamemode_var( "match_end_func", ::meat_end_match );
	onplayerconnect_callback( ::meat_on_player_connect );
	level.onprecachegametype = ::onprecachegametype;
	level.onstartgametype = ::onstartgametype;
	level._game_module_custom_spawn_init_func = maps\mp\gametypes_zm\_zm_gametype::custom_spawn_init_func;
	level._no_static_unitriggers = true;
	level._game_module_player_damage_callback = maps\mp\gametypes_zm\_zm_gametype::game_module_player_damage_callback;
	level._game_module_player_damage_grief_callback = ::game_module_player_damage_grief_callback;
	level.zm_mantle_over_40_move_speed_override = ::handle_super_sprint_mantle;
	level.no_end_game_check = true;
	level.no_board_repair = true;
	level._game_module_game_end_check = ::always_false;
	level.custom_end_screen = ::custom_end_screen;
	//level.check_valid_spawn_override = ::meat_check_valid_spawn_override;
	level.check_for_valid_spawn_near_team_callback = ::meat_check_valid_spawn_override;
	level thread maps\mp\gametypes_zm\_zm_gametype::init();
	level.can_revive_game_module = ::can_revive;
	init_animtree();
	maps\mp\gametypes_zm\_zm_gametype::post_gametype_main( "zgrief" );
}

onprecachegametype()
{
	init_item_meat();
	maps\mp\gametypes_zm\_zm_gametype::rungametypeprecache( "zgrief" );
	game_mode_objects = getstructarray( "game_mode_object", "targetname" );
	meat_objects = getstructarray( "meat_object", "targetname" );
	all_structs = arraycombine( game_mode_objects, meat_objects, 1, 0 );

	for ( i = 0; i < all_structs.size; i++ )
	{
		if ( isdefined( all_structs[i].script_parameters ) )
			precachemodel( all_structs[i].script_parameters );
	}
	precacheshellshock( "grief_stab_zm" );
	precacheitem( "minigun_zm" );
	precacheshader( "faction_cdc" );
	precacheshader( "faction_cia" );
	precachemodel( "p6_zm_sign_meat_01_step1" );
	precachemodel( "p6_zm_sign_meat_01_step2" );
	precachemodel( "p6_zm_sign_meat_01_step3" );
	precachemodel( "p6_zm_sign_meat_01_step4" );
	precachemodel( "collision_player_wall_512x512x10" );
	//level thread spawn_side_trigger();
}

init_item_meat()
{
	set_gamemode_var_once( "item_meat_name", "item_meat_zm" );
	set_gamemode_var_once( "item_meat_model", "t6_wpn_zmb_meat_world" );
	precacheitem( get_gamemode_var( "item_meat_name" ) );
	set_gamemode_var_once( "start_item_meat_name", get_gamemode_var( "item_meat_name" ) );
	level.meat_weaponidx = getweaponindexfromname( get_gamemode_var( "item_meat_name" ) );
	level.meat_pickupsound = getweaponpickupsound( level.meat_weaponidx );
	level.meat_pickupsoundplayer = getweaponpickupsoundplayer( level.meat_weaponidx );
}

meat_hub_start_func()
{
	level.meat_starting_team = ( cointoss() ? "A" : "B" );
	level thread meat_player_initial_spawn();
	level thread spawn_meat_zombies();
	level thread monitor_meat_on_team();
	level thread init_minigun_ring();
	level thread init_ammo_ring();
	level thread hide_non_meat_objects();
	level thread setup_meat_world_objects();
	level thread watch_meat_in_map();
	level thread meat_failsafe();
	level thread end_game_if_empty();
	//level thread watch_player_bounds();
	level._zombie_path_timer_override = ::zombie_path_timer_override;
	level.zombie_health = level.zombie_vars["zombie_health_start"];
	level._zombie_spawning = 0;
	level._poi_override = ::meat_poi_override_func;
	level._meat_on_team = undefined;
	level._meat_zombie_spawn_timer = 1;
	level._meat_zombie_spawn_health = 1;
	level._minigun_time_override = 15;
	level._get_game_module_players = ::get_game_module_players;
	level.powerup_drop_count = 0;
	level.meat_spawners = level.zombie_spawners;

	if ( !( isdefined( level._meat_callback_initialized ) && level._meat_callback_initialized ) )
	{
		maps\mp\zombies\_zm::register_player_damage_callback( maps\mp\zombies\_zm_game_module::damage_callback_no_pvp_damage );
		level._meat_callback_initialized = true;
	}
	setmatchtalkflag( "DeadChatWithDead", 1 );
	setmatchtalkflag( "DeadChatWithTeam", 1 );
	setmatchtalkflag( "DeadHearTeamLiving", 1 );
	setmatchtalkflag( "DeadHearAllLiving", 1 );
	setmatchtalkflag( "EveryoneHearsEveryone", 1 );
	level.zombie_spawn_fx = level._effect["spawn_cloud"];
	level thread monitor_meat_on_side();
	level thread item_meat_watch_for_throw();
	level thread hold_meat_monitor();
	flag_wait( "start_encounters_match_logic" );
	flag_set( "begin_spawning" );
	level.team_a_downed = 0;
	level.team_b_downed = 0;
}

meat_on_player_connect()
{
	self thread spawn_player_meat_manager();
	self thread wait_for_player_disconnect();
	self thread wait_for_player_downed();
	self meat_player_setup();
}

meat_on_player_disconnect()
{
	team_counts = [];
	team_counts["A"] = 0;
	team_counts["B"] = 0;
	players = getPlayers();

	for ( i = 0; i < players.size; i++ )
		team_counts[players[ i ]._encounters_team]++;

	//if ( team_counts["A"] == 0 )
	//	maps\mp\gametypes_zm\_zm_gametype::end_rounds_early( "B" );

	//if ( team_counts["B"] == 0 )
	//	maps\mp\gametypes_zm\_zm_gametype::end_rounds_early( "A" );
}

wait_for_player_disconnect()
{
	level endon( "end_game" );

	self waittill( "disconnect" );

	meat_on_player_disconnect();
}

monitor_meat_on_side()
{
	level endon( "end_game" );

	level waittill( "meat_grabbed" );
	last_team = level._meat_on_team;
	level.meat_lost_time_limit = 5000;

	while ( true )
	{
		wait 0.05;		
		if ( isdefined( level.item_meat ) )
		{
			/*
			if ( is_true( level.meat_touched_middle_volume ) )
			{
				level.meat_touched_middle_volume = false;
				if ( isDefined( level._meat_on_team ) )
				{
					if ( level._meat_on_team == "A" )
					{
						level._meat_on_team = "B";
					}
					else 
					{
						level._meat_on_team = "A";
					}
					level.meat_lost_time = undefined;
				}
			}
			*/
			/*
			else if ( isdefined( last_team ) )
			{
				if ( !isdefined( level.meat_lost_time ) )
					level.meat_lost_time = gettime();
				else if ( gettime() - level.meat_lost_time > level.meat_lost_time_limit )
				{
					add_meat_event( "level_lost_meat" );
					new_team = ( cointoss() ? "A" : "B" );
					level thread item_meat_reset( new_team, true );
					level.meat_lost_time = undefined;

					assign_meat_to_team( undefined, new_team );
				}
			}
			*/
		}
		else
		{
			player_with_meat = get_player_with_meat();
			/*
			if ( !isdefined( player_with_meat ) )
			{
				if ( !isdefined( level.meat_lost_time ) )
					level.meat_lost_time = gettime();
				else if ( gettime() - level.meat_lost_time > level.meat_lost_time_limit )
				{
					add_meat_event( "level_lost_meat" );
					new_team = ( cointoss() ? "A" : "B" );
					level thread item_meat_reset( new_team, true );
					level.meat_lost_time = undefined;
					assign_meat_to_team( undefined, new_team );
				}
			}
			else
				level.meat_lost_time = undefined;
			*/
		}
		/*
		if ( isdefined( level._meat_on_team ) && isdefined( last_team ) && level._meat_on_team != last_team )
		{
			add_meat_event( "level_meat_team", level._meat_on_team );
			last_team = level._meat_on_team;
			assign_meat_to_team( undefined, level._meat_on_team );
		}
		*/
	}
}

item_meat_watch_for_throw()
{
	level endon( "end_game" );

	for (;;)
	{
		level waittill( "meat_thrown", who );

		add_meat_event( "player_thrown", who );

		if ( is_true( who._spawning_meat ) )
			continue;
		who._has_meat = false;

		//assign_meat_to_team( undefined, level._meat_on_team );
	}
}

hold_meat_monitor()
{
	level endon( "end_game" );

	level waittill( "meat_grabbed" );

	while ( true )
	{
		wait 0.2;
		player = get_player_with_meat();

		if ( !isdefined( player ) )
		{
			continue;
		}

		if ( !should_try_to_bring_back_teammate( player._encounters_team ) )
		{
			continue;
		}

		if ( !( isdefined( player._bringing_back_teammate ) && player._bringing_back_teammate ) )
			player thread bring_back_teammate_progress();
	}
}

wait_for_player_downed()
{
	self endon( "disconnect" );

	while ( true )
	{
		self waittill( "player_downed" );
		add_meat_event( "player_down", self );
		wait 0.1;

		if ( isdefined( self._encounters_team ) )
		{
			self thread watch_save_player();
			players = get_players_on_encounters_team( self._encounters_team );
		}
	}
}

item_meat_watch_stationary()
{
	self endon( "death" );
	self endon( "picked_up" );
	self.meat_is_moving = true;

	self waittill( "stationary" );

	self playloopsound( "zmb_meat_looper", 2 );

	add_meat_event( "meat_stationary", self );
	level._meat_moving = false;
	level._last_person_to_throw_meat = undefined;
	self.meat_is_moving = false;
}

item_meat_watch_bounce()
{
	self endon( "death" );
	self endon( "picked_up" );
	self.meat_is_flying = true;

	self waittill( "grenade_bounce", pos, normal, ent );

	add_meat_event( "meat_bounce", self, pos, normal, ent );

	if ( isdefined( level.meat_bounce_override ) )
	{
		self thread [[ level.meat_bounce_override ]]( pos, normal, ent );
		return;
	}

	if ( isdefined( ent ) && isplayer( ent ) )
	{
		add_meat_event( "player_hit_player", self.owner, ent );
	}

	self.meat_is_flying = false;
	self thread watch_for_roll();
	playfxontag( level._effect["meat_marker"], self, "tag_origin" );
}

watch_for_roll()
{
	self endon( "stationary" );
	self endon( "death" );
	self endon( "picked_up" );
	self.meat_is_rolling = false;

	while ( true )
	{
		old_z = self.origin[2];
		wait 1;

		if ( abs( old_z - self.origin[2] ) < 10 )
		{
			self.meat_is_rolling = true;
			self playloopsound( "zmb_meat_looper", 2 );
		}
	}
}

item_meat_pickup()
{
	self.meat_is_moving = false;
	self.meat_is_flying = false;
	level._meat_moving = false;
	self notify( "picked_up" );
}

player_wait_take_meat( meat_name )
{
	self.dont_touch_the_meat = true;

	if ( isdefined( self.pre_meat_weapon ) && self hasweapon( self.pre_meat_weapon ) )
		self switchtoweapon( self.pre_meat_weapon );
	else
	{
		primaryweapons = self getweaponslistprimaries();

		if ( isdefined( primaryweapons ) && primaryweapons.size > 0 )
			self switchtoweapon( primaryweapons[0] );
		else
		{
			self maps\mp\zombies\_zm_weapons::give_fallback_weapon();
		}
	}

	self waittill_notify_or_timeout( "weapon_change_complete", 3 );
	self takeweapon( meat_name );
	self.pre_meat_weapon = undefined;

	if ( self.is_drinking )
		self decrement_is_drinking();

	self.dont_touch_the_meat = false;
}

cleanup_meat()
{
	if ( isdefined( self.altmodel ) )
		self.altmodel delete();

	self delete();
}

#using_animtree("zombie_meat");
init_animtree()
{
	scriptmodelsuseanimtree( #animtree );
}

animate_meat( grenade )
{
	grenade waittill_any( "bounce", "stationary", "death" );
	waittillframeend;

	if ( isdefined( grenade ) )
	{
		grenade hide();
		altmodel = spawn( "script_model", grenade.origin );
		altmodel setmodel( get_gamemode_var( "item_meat_model" ) );
		altmodel useanimtree( #animtree );
		altmodel.angles = grenade.angles;
		altmodel linkto( grenade, "", ( 0, 0, 0 ), ( 0, 0, 0 ) );
		//altmodel setanim( %o_zombie_head_idle_v1 );
		grenade.altmodel = altmodel;

		while ( isdefined( grenade ) )
			wait 0.05;

		if ( isdefined( altmodel ) )
			altmodel delete();
	}
}

indexinarray( array, value )
{
	if ( !isdefined( array ) || !isarray( array ) || !isdefined( value ) || !isinarray( array, value ) )
		return undefined;

	foreach ( index, item in array )
	{
		if ( item == value )
			return index;
	}

	return undefined;
}

item_meat_on_spawn_retrieve_trigger( watcher, player, weaponname )
{
	self endon( "death" );
	add_meat_event( "meat_spawn", self );
	thread animate_meat( self );

	if ( isdefined( player ) )
	{
		self setowner( player );
		self setteam( player.pers["team"] );
		self.owner = player;
		self.oldangles = self.angles;

		if ( player hasweapon( weaponname ) )
		{
			player thread player_wait_take_meat( weaponname );
		}

		if ( !( isdefined( self._respawned_meat ) && self._respawned_meat ) )
		{
			level notify( "meat_thrown", player );
			level._last_person_to_throw_meat = player;
			level._last_person_to_throw_meat_time = gettime();
		}
	}

	level._meat_moving = true;

	if ( isdefined( level.item_meat ) && level.item_meat != self )
		level.item_meat cleanup_meat();

	level.item_meat = self;

	self thread item_meat_watch_stationary();
	self thread item_meat_watch_bounce();
	self.item_meat_pick_up_trigger = spawn( "trigger_radius_use", self.origin, 0, 48, 72 );
	self.item_meat_pick_up_trigger setcursorhint( "HINT_NOICON" );
	self.item_meat_pick_up_trigger sethintstring( &"ZOMBIE_MEAT_PICKUP" );
	self.item_meat_pick_up_trigger enablelinkto();
	self.item_meat_pick_up_trigger linkto( self );
	self.item_meat_pick_up_trigger triggerignoreteam();
	level.item_meat_pick_up_trigger = self.item_meat_pick_up_trigger;
	self thread item_meat_watch_shutdown();

	if ( isdefined( level.dont_allow_meat_interaction ) && level.dont_allow_meat_interaction )
		self.item_meat_pick_up_trigger setinvisibletoall();
	else
	{
		self thread item_meat_watch_trigger( self.item_meat_pick_up_trigger, ::item_meat_on_pickup, level.meat_pickupsoundplayer, level.meat_pickupsound );
		self thread kick_meat_monitor();
	}

	self._respawned_meat = undefined;
}

kick_meat_monitor()
{
	level endon( "meat_grabbed" );
	level endon( "end_meat" );
	self endon( "death" );
	kick_meat_timeout = 150;

	while ( true )
	{
		players = getPlayers();
		curr_time = gettime();

		foreach ( player in players )
		{
			if ( isdefined( level._last_person_to_throw_meat ) && player == level._last_person_to_throw_meat && curr_time - level._last_person_to_throw_meat_time <= kick_meat_timeout )
				continue;

			if ( distancesquared( player.origin, self.origin ) < 48 * 48 && player issprinting() && !player usebuttonpressed() )
			{
				if ( isdefined( player._encounters_team ) && isdefined( level._meat_on_team ) && level._meat_on_team == player._encounters_team )
				{
					add_meat_event( "player_kick_meat", player, self );
					player thread kick_the_meat( self );
				}
			}
		}

		wait 0.05;
	}
}

is_meat( weapon )
{
	return weapon == get_gamemode_var( "item_meat_name" );
}

spike_the_meat( meat )
{
	self endon( "disconnect" );
	if ( isdefined( self._kicking_meat ) && self._kicking_meat )
		return;

	self._kicking_meat = true;
	self._spawning_meat = true;
	org = self getweaponmuzzlepoint();
	vel = meat getvelocity();

	meat cleanup_meat();
	level._last_person_to_throw_meat = self;
	level._last_person_to_throw_meat_time = gettime();

	kickangles = self.angles;
	kickangles += ( randomfloatrange( -30, -20 ), randomfloatrange( -5, 5 ), 0 );
	launchdir = anglestoforward( kickangles );
	speed = length( vel ) * 1.5;
	launchvel = vectorscale( launchdir, speed );
	grenade = self magicgrenadetype( get_gamemode_var( "item_meat_name" ), org, ( launchvel[0], launchvel[1], 380 ) );
	grenade playsound( "zmb_meat_meat_tossed" );
	grenade thread waittill_loopstart();

	level.the_meat = grenade;

	wait 0.1;
	self._spawning_meat = false;
	self._kicking_meat = false;

	level notify( "meat_thrown", self );
	level notify( "meat_kicked" );
}

set_ignore_all()
{
	level endon( "clear_ignore_all" );

	if ( isdefined( level._zombies_ignoring_all ) && level._zombies_ignoring_all )
		return;

	level._zombies_ignoring_all = true;
	zombies = getaiarray( level.zombie_team );

	foreach ( zombie in zombies )
	{
		if ( isdefined( zombie ) )
			zombie.ignoreall = true;
	}

	wait 0.5;
	clear_ignore_all();
}

clear_ignore_all()
{
	if ( !( isdefined( level._zombies_ignoring_all ) && level._zombies_ignoring_all ) )
		return;

	zombies = getaiarray( level.zombie_team );

	foreach ( zombie in zombies )
	{
		if ( isdefined( zombie ) )
			zombie.ignoreall = 0;
	}

	level._zombies_ignoring_all = 0;
}

bring_back_teammate_progress()
{
	self notify( "bring_back_teammate_progress" );
	self endon( "bring_back_teammate_progress" );
	self endon( "disconnect" );
	self._bringing_back_teammate = true;
	revivetime = 15;
	progress = 0;

	while ( player_has_meat( self ) && is_player_valid( self ) && progress >= 0 )
	{
		if ( !isdefined( self.revive_team_progressbar ) )
		{
			self.revive_team_progressbar = self createprimaryprogressbar();
			self.revive_team_progressbar updatebar( 0.01, 1 / revivetime );
			self.revive_team_progressbar.progresstext = self createprimaryprogressbartext();
			self.revive_team_progressbar.progresstext settext( &"ZOMBIE_MEAT_RESPAWN_TEAMMATE" );
			self thread destroy_revive_progress_on_downed();
		}

		progress++;

		if ( progress > revivetime * 10 )
		{
			level bring_back_dead_teammate( self._encounters_team );
			self destroy_revive_progress();
			wait 1;
			self._bringing_back_teammate = false;
			progress = -1;
		}

		wait 0.1;
	}

	self._bringing_back_teammate = 0;
	self destroy_revive_progress();
}

should_try_to_bring_back_teammate( team )
{
	players = getPlayers();

	for ( i = 0; i < players.size; i++ )
	{
		if ( players[ i ]._encounters_team == team && players[ i ].sessionstate == "spectator" )
			return true;
	}

	return false;
}

bring_back_dead_teammate( team )
{
	players = getPlayers();

	players = array_randomize( players );
	for ( i = 0; i < players.size; i++ )
	{
		if ( players[ i ]._encounters_team == team && players[ i ].sessionstate == "spectator" )
		{
			player = players[ i ];
			break;
		}
	}

	if ( !isdefined( player ) )
		return;

	player playsound( level.zmb_laugh_alias );
	wait 0.25;
	playfx( level._effect["poltergeist"], player.spectator_respawn.origin );
	playsoundatposition( "zmb_bolt", player.spectator_respawn.origin );
	earthquake( 0.5, 0.75, player.spectator_respawn.origin, 1000 );
	level.custom_spawnplayer = ::respawn_meat_player;
	player.pers["spectator_respawn"] = player.spectator_respawn;
	player [[ level.spawnplayer ]]();
	level.custom_spawnplayer = undefined;
}

respawn_meat_player()
{
	spawnpoint = self maps\mp\gametypes_zm\_globallogic_score::getpersstat( "meat_spectator_respawn" );
	self spawn( spawnpoint.origin, spawnpoint.angles );
	self._encounters_team = self.pers["encounters_team"];
	self.characterindex = self.pers["characterindex"];
	self._team_name = self.pers["team_name"];
	self.spectator_respawn = self.pers["meat_spectator_respawn"];
	self reviveplayer();
	self.is_burning = false;
	self.is_zombie = false;
	self.ignoreme = false;
}

destroy_revive_progress_on_downed()
{
	level endon( "end_game" );
	self waittill( "player_downed" );
	self destroy_revive_progress();
}

destroy_revive_progress()
{
	if ( isdefined( self.revive_team_progressbar ) )
	{
		self.revive_team_progressbar destroyelem();
		self.revive_team_progressbar.progresstext destroyelem();
	}
}

kick_the_meat( meat, laststand_nudge )
{
	self endon( "disconnect" );
	if ( isdefined( self._kicking_meat ) && self._kicking_meat )
	{
		return;
	}

	self._kicking_meat = true;
	self._spawning_meat = true;
	org = meat.origin;

	meat cleanup_meat();
	level._last_person_to_throw_meat = self;
	level._last_person_to_throw_meat_time = gettime();

	kickangles = self.angles;
	kickangles += ( randomfloatrange( -30, -20 ), randomfloatrange( -5, 5 ), 0 );
	launchdir = anglestoforward( kickangles );
	vel = self getvelocity();
	speed = length( vel ) * 1.5;
	height_boost = 380;

	if ( isdefined( laststand_nudge ) && laststand_nudge )
	{
		if ( vel == ( 0, 0, 0 ) )
			vel = ( 30, 30, 5 );

		speed = length( vel ) * 2;
		height_boost = 120;
	}

	launchvel = vectorscale( launchdir, speed );
	grenade = self magicgrenadetype( get_gamemode_var( "item_meat_name" ), org, ( launchvel[ 0 ], launchvel[ 1 ], height_boost ) );
	grenade playsound( "zmb_meat_meat_tossed" );
	grenade thread waittill_loopstart();

	level.the_meat = grenade;

	wait 0.1;
	self._spawning_meat = false;
	self._kicking_meat = false;

	level notify( "meat_thrown", self );
	level notify( "meat_kicked" );
}

can_revive( revivee )
{
	if ( self hasweapon( get_gamemode_var( "item_meat_name" ) ) )
		return false;

	if ( !self maps\mp\zombies\_zm_laststand::is_reviving_any() && isdefined( level.item_meat_pick_up_trigger ) && self istouching( level.item_meat_pick_up_trigger ) )
		return false;

	return true;
}

can_spike_meat()
{
	if ( isdefined( level._last_person_to_throw_meat ) && self == level._last_person_to_throw_meat )
		return false;

	meat = level.item_meat;
	meat_spike_dist_sq = 4096;
	meat_spike_dot = 0.1;

	if ( isdefined( meat ) )
	{
		view_pos = self getweaponmuzzlepoint();

		if ( distancesquared( view_pos, meat.origin ) < meat_spike_dist_sq )
			return true;
	}

	return false;
}

onstartgametype()
{
	maps\mp\gametypes_zm\_zm_gametype::rungametypemain( "zgrief", ::meat_hub_start_func, false );
}

hide_non_meat_objects()
{
	door_trigs = getentarray( "zombie_door", "targetname" );

	for ( i = 0; i < door_trigs.size; i++ )
	{
		if ( isdefined( door_trigs[i] ) )
			door_trigs[i] trigger_off();
	}

	weapon_spawns = getentarray( "weapon_upgrade", "targetname" );
	for ( i = 0; i < weapon_spawns.size; i++ )
	{
		weapon_spawns[ i ] trigger_off();
	}	
	objects = getentarray();

	for ( i = 0; i < objects.size; i++ )
	{
		if ( objects[i] is_meat_object() )
			continue;

		if ( objects[i] iszbarrier() )
			continue;

		if ( isdefined( objects[i].spawnflags ) && objects[i].spawnflags == 1 )
			objects[i] connectpaths();

		objects[i] notsolid();
		objects[i] hide();
	}
}

is_meat_object()
{
	// if ( !isdefined( self.script_parameters ) )
	// 	return true;

	// tokens = strtok( self.script_parameters, " " );

	// for ( i = 0; i < tokens.size; i++ )
	// {
	// 	if ( tokens[i] == "meat_remove" )
	// 		return false;
	// }

	return true;
}

setup_meat_world_objects()
{
	objects = getentarray( level.scr_zm_map_start_location, "script_noteworthy" );

	for ( i = 0; i < objects.size; i++ )
	{
		if ( !objects[i] is_meat_object() )
			continue;

		if ( isdefined( objects[i].script_gameobjectname ) )
			continue;

		if ( isdefined( objects[i].script_vector ) )
		{
			objects[i] moveto( objects[i].origin + objects[i].script_vector, 0.05 );

			objects[i] waittill( "movedone" );
		}

		if ( isdefined( objects[i].spawnflags ) && objects[i].spawnflags == 1 && !( isdefined( level._dont_reconnect_paths ) && level._dont_reconnect_paths ) )
			objects[i] disconnectpaths();
	}
}

spawn_meat_zombies()
{
	level endon( "end_game" );
	force_riser = 0;
	force_chaser = 0;
	num = 0;
	level.meat_bus_sprinter_max = 1;
	flag_wait( "initial_blackscreen_passed" );
	level waittill( "meat_assigned_to_team" );
	while ( true )
	{
		wait( level._meat_zombie_spawn_timer );
		if ( getDvarIntDefault( "zmeat_disable_zombie_spawning", 0 ) )
		{
			continue;
		}
		flag_wait( "spawn_zombies" );
		ai = getaiarray( level.zombie_team );
		if ( ai.size > getDvarIntDefault( "zmeat_max_zombies", 24 ) )
		{
			continue;
		}
		players = getPlayers();
		level.meat_bus_sprinter_max = int( ceil( players.size / 2 ) );
		side = level._meat_on_team;
		if ( !isDefined( side ) )
		{
			side = level.meat_starting_team;
		}
		spawn_points = array_randomize( level._zmeat_zombie_spawn_locations[ side ] );

		zombie = spawn_meat_zombie( random( level.meat_spawners ), "meat_zombie", spawn_points[ 0 ], level._meat_zombie_spawn_health );

		if ( isdefined( zombie ) )
		{
			if ( count_bus_sprinters() < level.meat_bus_sprinter_max )
			{
				zombie.is_bus_sprinter = true;
				zombie thread set_melee_damage_after_time( 1 );
				zombie make_bus_sprinter_after_time( 0.1 );
			}
			else 
			{
				zombie make_super_sprinter_after_time( 0.1 );
			}
		}
	}
}

set_melee_damage_after_time( time )
{
	self endon( "death" );
	wait time;
	self.meleedamage = 20;
}

count_bus_sprinters()
{
	zombies = getaiarray( level.zombie_team );

	count = 0;
	if ( isdefined( zombies ) && zombies.size > 0 )
	{	
		for ( i = 0; i < zombies.size; i++ )
		{
			if ( is_true( zombies[ i ].is_bus_sprinter ) )
			{
				count++;
			}
		}
	}
	return count;
}

spawn_meat_zombie( spawner, target_name, spawn_point, round_number )
{
	level endon( "end_game" );

	if ( !isdefined( spawner ) )
	{
		return;
	}

	while ( isdefined( level._meat_zombie_spawning ) && level._meat_zombie_spawning )
		wait 0.05;

	level._meat_zombie_spawning = true;
	level.zombie_spawn_locations = [];
	level.zombie_spawn_locations[ level.zombie_spawn_locations.size ] = spawn_point;
	zombie = maps\mp\zombies\_zm_utility::spawn_zombie( spawner, target_name, spawn_point, round_number );
	zombie.zombie_can_sidestep = true;
	//zombie.shouldsidestepfunc = ::meat_should_sidestep;
	spawner._spawning = undefined;
	level._meat_zombie_spawning = false;
	return zombie;
}

make_super_sprinter_after_time( time )
{
	wait time;
	self maps\mp\zombies\_zm_game_module::make_supersprinter();
}

make_bus_sprinter_after_time( time )
{
	wait time;
	self set_zombie_run_cycle( "chase_bus" );
}

monitor_meat_on_team()
{
	level endon( "end_game" );

	while ( true )
	{
		wait 0.1;
		players = getPlayers();

		for ( i = 0; i < players.size; i++ )
		{
			if ( !is_player_valid( players[ i ] ) )
			{
				continue;
			}
			if ( isdefined( level._meat_on_team ) )
			{
				if ( level._meat_on_team == players[ i ]._encounters_team )
				{
					players[ i ].ignoreme = true;
				}
				else 
				{
					players[ i ].ignoreme = false;
				}
			}
			else
			{
				players[ i ].ignoreme = false;
			}
		}
	}
}

item_meat_reset( team, immediate )
{
	level notify( "new_meat" );
	level endon( "new_meat" );

	if ( isdefined( level.item_meat ) )
	{
		level.item_meat cleanup_meat();
		level.item_meat = undefined;
	}

	if ( !( isdefined( immediate ) && immediate ) )
		level waittill( "reset_meat" );

	item_meat_clear();
	if ( isdefined( team ) )
		item_meat_spawn( team );
		
	assign_meat_to_team( undefined, team );
}

meat_player_initial_spawn()
{
	waittillframeend;
	start_round();
}

meat_player_setup()
{
	self.pers["encounters_team"] = self._encounters_team;
	self.pers["characterindex"] = self.characterindex;
	self.pers["team_name"] = self._team_name;
	self.pers["meat_spectator_respawn"] = self.spectator_respawn;
	self.score = 1000;
	self.pers["score"] = 1000;
	self takeallweapons();
	self giveweapon( "knife_zm" );
	self give_start_weapon( 1 );

	if ( !isdefined( self._saved_by_throw ) )
		self._saved_by_throw = false;

	self setmovespeedscale( 1 );
	self._has_meat = false;
	//self setclientfield( "holding_meat", 0 );
	self freeze_player_controls( 1 );
}

can_touch_meat()
{
	if ( is_true( self.dont_touch_the_meat ) )
	{
		//print( "player can't touch the meat because self.dont_touch_the_meat is true" );
		return false;
	}
	return true;
}

trying_to_use()
{
	self.use_ever_released |= !self usebuttonpressed();
	return self.use_ever_released && self usebuttonpressed();
}

trying_to_spike( item )
{
	return item.meat_is_flying && self meleebuttonpressed();
}

item_quick_trigger( trigger )
{
	self endon( "death" );
	meat_trigger_time = 150;

	if ( isdefined( trigger.radius ) )
		radius = trigger.radius + 15.0;
	else
		radius = 51.0;

	trigrad2 = radius * radius;
	players = getPlayers();

	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];
		player.use_ever_released = !player usebuttonpressed();
	}

	while ( isdefined( trigger ) )
	{
		wait 0.05;
		trigorg = trigger.origin;
		players = getPlayers();

		if ( players.size )
		{
			players = array_randomize( players );

			for ( i = 0; i < players.size; i++ )
			{
				player = players[ i ];

				if ( !isdefined( trigger ) )
				{
					break;
				}

				if ( player maps\mp\zombies\_zm_laststand::is_reviving_any() )
				{
					//print( "player is reviving" );
					player reset_trying_to_trigger_meat();
					continue;
				}
				if ( !is_player_valid( player ) )
				{
					//print( "player is not valid" );
					player reset_trying_to_trigger_meat();
					continue;
				}

				if ( player has_powerup_weapon() )
				{
					//print( "player has powerup weapon" );
					player reset_trying_to_trigger_meat();
					continue;
				}
					
				if ( !player istouching( trigger ) )
				{
					//print( "player is not touching the trigger" );
					player reset_trying_to_trigger_meat();
					continue;
				}

				if ( distance2dsquared( player.origin, trigorg ) > trigrad2 )
				{
					//print( "player is not close enough to the trigger" );
					player reset_trying_to_trigger_meat();
					continue;
				}

				if ( !player can_touch_meat() )
				{
					//print( "player can not touch the meat" );
					player reset_trying_to_trigger_meat();
					continue;
				}

				if ( player trying_to_use() )
				{
				}
				else if ( self.meat_is_flying )
				{
					if ( !player ismeleeing() )
					{
						//print( "player is not meleeing" );
						continue;
					}
					if ( !player can_spike_meat() )
					{
						//print( "player can not spike the meat" );
						continue;
					}
					player.trying_to_trigger_meat = false;
					trigger notify( "usetrigger", player );
					continue;
				}
				else 
				{
					//print( "player is not trying to use or the meat is not flying and the player is not meleeing" );
					player reset_trying_to_trigger_meat();
					continue;
				}
				if ( !is_true( player.trying_to_trigger_meat ) )
				{
					//print( "player is not trying to trigger meat" );
					player.trying_to_trigger_meat = true;
					player.trying_to_trigger_meat_time = gettime();
				}
				if ( gettime() - player.trying_to_trigger_meat_time >= meat_trigger_time )
				{
					player.trying_to_trigger_meat = false;
					trigger notify( "usetrigger", player );
				}
				else 
				{
					//print( "player trying to trigger meat time is less than meat_trigger_time" );
				}
			}
		}
	}
}

reset_trying_to_trigger_meat()
{
	self.trying_to_trigger_meat = false;
	self.trying_to_trigger_meat_time = undefined;
}

item_meat_watch_trigger( trigger, callback, playersoundonuse, npcsoundonuse )
{
	self endon( "death" );
	self thread item_quick_trigger( trigger );

	while ( true )
	{
		trigger waittill( "usetrigger", player );
		//print( "item_meat_watch_trigger" );
		volley = self.meat_is_flying && player meleebuttonpressed();
		player.volley_meat = volley;

		if ( volley )
			add_meat_event( "player_volley", player, self );
		else if ( self.meat_is_moving )
			add_meat_event( "player_catch", player, self );
		else
			add_meat_event( "player_take", player, self );

		curr_weap = player getcurrentweapon();

		if ( !is_meat( curr_weap ) )
			player.pre_meat_weapon = curr_weap;

		if ( self.meat_is_moving )
		{
			if ( volley )
				self item_meat_volley( player );
			else
				self item_meat_caught( player, self.meat_is_flying );
		}
		self item_meat_pickup();

		if ( isdefined( playersoundonuse ) )
			player playlocalsound( playersoundonuse );

		if ( isdefined( npcsoundonuse ) )
			player playsound( npcsoundonuse );

		if ( volley )
		{
			//print( "player spiked the meat" );
			player thread spike_the_meat( self );
		}
		else
		{
			//print( "player picked up the meat" );
			self thread [[ callback ]]( player );
		}
	}
}

item_meat_volley( player )
{
}

item_meat_caught( player, in_air )
{
}

item_meat_on_pickup( player )
{
	player maps\mp\gametypes_zm\_weaponobjects::deleteweaponobjecthelper( self );
	self cleanup_meat();
	level.item_meat = undefined;
	level._last_person_to_throw_meat = undefined;
	assign_meat_to_team( player );
	level notify( "meat_grabbed", player );
	player notify( "meat_grabbed" );
	if ( !player hasweapon( get_gamemode_var( "item_meat_name" ) ) )
		player giveweapon( get_gamemode_var( "item_meat_name" ) );

	player increment_is_drinking();
	player switchtoweapon( get_gamemode_var( "item_meat_name" ) );
	player setweaponammoclip( get_gamemode_var( "item_meat_name" ), 2 );
	player thread waittill_thrown();
}

waittill_thrown()
{
	self endon( "bled_out" );
	self endon( "disconnect" );
	self endon( "reset_downed" );

	self waittill( "grenade_fire", grenade );

	grenade playsound( "zmb_meat_meat_tossed" );
	grenade thread waittill_loopstart();
}

waittill_loopstart()
{
	self endon( "stationary" );
	self endon( "death" );
	level endon( "meat_grabbed" );
	level endon( "end_game" );
	level endon( "meat_kicked" );

	while ( true )
	{
		self waittill( "grenade_bounce", pos, normal, ent );

		self stopsounds();
		wait 0.05;
		self playsound( "zmb_meat_bounce" );
	}
}

item_meat_watch_shutdown()
{
	self waittill( "death" );

	if ( isdefined( self.item_meat_pick_up_trigger ) )
	{
		self.item_meat_pick_up_trigger delete();
		level.item_meat_pick_up_trigger = undefined;
	}
}

item_meat_clear()
{
	if ( isdefined( level.item_meat ) )
	{
		level.item_meat cleanup_meat();
		level.item_meat = undefined;
	}
}

zombie_path_timer_override()
{
	return gettime() + randomfloatrange( 0.35, 1 ) * 1000;
}

meat_poi_override_func()
{
	if ( isdefined( level.the_meat ) && ( isdefined( level.the_meat.meat_is_moving ) && level.the_meat.meat_is_moving ) )
	{
		if ( abs( level.the_meat.origin[ 2 ] - groundpos( level.the_meat.origin )[ 2 ] ) < 35 )
		{
			return undefined;
		}
		meat_poi = [];
		meat_poi[ 0 ] = groundpos( level.the_meat.origin );
		meat_poi[ 1 ] = level.the_meat;
		return meat_poi;
	}
	return undefined;
}

updatedownedcounters()
{
	if ( self._encounters_team == "A" )
	{
		level.team_a_downed++;
		self thread waitforrevive( "A" );
	}
	else
	{
		level.team_b_downed++;
		self thread waitforrevive( "B" );
	}
}

waitforrevive( team )
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self endon( "bled_out" );

	self waittill( "player_revived" );

	if ( team == "A" )
		level.team_a_downed--;
	else
		level.team_b_downed--;
}

assign_meat_to_team( player, encounters_team )
{
	meat_team = undefined;

	if ( isdefined( player ) )
	{
		//print( "meat assigned to team based on player " + player._encounters_team );
		meat_team = player._encounters_team;
	}
	else if ( isdefined( encounters_team ) )
	{
		//Print( "meat assigned to team based on team " + encounters_team );
		meat_team = encounters_team;
	}
	players = getPlayers();
	/*
	if ( isdefined( player ) )
	{
		for ( i = 0; i < players.size; i++ )
		{
			if ( !isdefined( players[i] ) )
				continue;

			if ( players[ i ] != player || isdefined( player._meat_hint_shown ) && player._meat_hint_shown )
			{
				players[ i ] iprintlnbold( &"ZOMBIE_GRABBED_MEAT", player.name );
			}
		}

	}
	if ( isdefined( encounters_team ) && is_true( level.meat_show_prints_to_players ) )
	{
		for ( i = 0; i < players.size; i++ )
		{
			if ( players[ i ]._encounters_team == encounters_team )
			{
				players[ i ] iprintlnbold( &"ZOMBIE_YOUR_TEAM_MEAT" );
				continue;
			}

			players[ i ] iprintlnbold( &"ZOMBIE_OTHER_TEAM_MEAT" );
		}
	}
	*/
	level._meat_on_team = meat_team;
	level notify( "meat_assigned_to_team", meat_team );
	if ( !isDefined( player ) )
	{
		return;
	}
	if ( player._has_meat )
	{
		return;
	}
	player._has_meat = true;
	player thread slow_down_player_with_meat();
	player thread reset_meat_when_player_downed();
	player thread reset_meat_when_player_disconnected();
}

slow_down_player_with_meat()
{
	self endon( "disconnect" );
	self setmovespeedscale( 0.6 );
	while ( isdefined( self._has_meat ) && self._has_meat )
	{
		level._meat_player_tracker_origin = self.origin;
		wait 0.2;
	}

	self setmovespeedscale( 1 );
}

reset_meat_when_player_downed()
{
	self endon( "disconnect" );
	self notify( "reset_downed" );
	self endon( "reset_downed" );
	level endon( "meat_reset" );
	level endon( "meat_thrown" );
	self waittill_any( "player_downed", "replace_weapon_powerup" );
	self._has_meat = false;
	self._spawning_meat = true;
	level.the_meat = self magicgrenadetype( get_gamemode_var( "item_meat_name" ), self.origin + ( randomintrange( 5, 10 ), randomintrange( 5, 10 ), 15 ), ( randomintrange( 5, 10 ), randomintrange( 5, 10 ), 0 ) );
	level.the_meat._respawned_meat = true;
	level._last_person_to_throw_meat = undefined;
	playsoundatposition( "zmb_spawn_powerup", self.origin );
	wait 0.1;
	self._spawning_meat = undefined;
	level notify( "meat_reset" );
}

reset_meat_when_player_disconnected()
{
	level endon( "meat_thrown" );
	level endon( "meat_reset" );
	level endon( "end_game" );
	team = self._encounters_team;

	self waittill( "disconnect" );
	while ( !isDefined( level.the_meat ) )
	{
		item_meat_drop( level._meat_player_tracker_origin, team );
		wait 1;
	}
}

item_meat_drop( org, team )
{
	if ( is_true( level.meat_new_round ) )
	{
		return;
	}
	players = getPlayers();

	if ( players.size > 0 )
	{
		player = players[ 0 ];
		player endon( "disconnect" );
		player._spawning_meat = true;
		if ( isDefined( level.the_meat ) )
		{
			return;
		}
		level.the_meat = player magicgrenadetype( get_gamemode_var( "item_meat_name" ), org + ( randomintrange( 5, 10 ), randomintrange( 5, 10 ), 15 ), ( 0, 0, 0 ) );
		level.the_meat._respawned_meat = true;
		level._last_person_to_throw_meat = undefined;
		playsoundatposition( "zmb_spawn_powerup", level.the_meat.origin );
		wait 0.1;
		player._spawning_meat = undefined;
		level notify( "meat_reset" );
	}
}

player_has_meat( player )
{
	return player getcurrentweapon() == get_gamemode_var( "item_meat_name" );
}

get_player_with_meat()
{
	players = getPlayers();

	for ( i = 0; i < players.size; i++ )
	{
		if ( isdefined( players[ i ]._has_meat ) && players[ i ]._has_meat )
			return players[ i ];
	}

	return undefined;
}

spawn_player_meat_manager()
{
	self thread player_watch_weapon_change();
	self thread player_watch_grenade_throw();
}

player_watch_weapon_change()
{
	self endon( "disconnect" );

	for (;;)
	{
		self waittill( "weapon_change", weapon );

		if ( weapon == get_gamemode_var( "item_meat_name" ) )
		{
			add_meat_event( "player_meat", self );
			continue;
		}

		add_meat_event( "player_no_meat", self );
	}
}

player_watch_grenade_throw()
{
	self endon( "disconnect" );

	for (;;)
	{
		self waittill( "grenade_fire", weapon, weapname );
		if ( weapname == get_gamemode_var( "item_meat_name" ) )
		{
			add_meat_event( "player_grenade_fire", self, weapon );
			weapon thread item_meat_on_spawn_retrieve_trigger( undefined, self, get_gamemode_var( "item_meat_name" ) );
			weapon.is_meat = true;
			level.the_meat = weapon;
		}
		//jsonDump( va( "%s_%s_%s_%s", weapname, getDvar( "g_gametype" ), getDvar( "ui_zm_mapstartlocation" ), getDvar( "mapname" ) ), weapon );
	}
}

spawn_level_meat_manager()
{
}

add_meat_event( e, p1, p2, p3, p4 )
{
}

spawn_side_trigger()
{
	switch ( getDvar( "ui_zm_mapstartlocation" ) )
	{
		case "town":
			origin = ( 1431.62, -388.542, -78.5244 );
			angles = ( 0, -146.464, 0  );
			width = 20;
			height = 1000;
			length = distance2D( ( 1120.44, 11.2665, -28.0667 ), ( 1673.39, -710.099, -18.813 ) );
			break;
	}
	trigger = spawn( "trigger_box", origin, 0, width, length, height );
	trigger.angles = angles;
	trigger thread switch_team_has_meat_on_trigger();
}

switch_team_has_meat_on_trigger()
{
	while ( true )
	{
		meat_touched_middle_volume = false;
		while ( isDefined( level.the_meat ) && level.the_meat isTouching( self ) )
		{
			meat_touched_middle_volume = true;
			wait 0.05;
		}
		if ( isDefined( level.the_meat ) && meat_touched_middle_volume )
		{
			if ( level._meat_on_team == "A" )
			{
				level._meat_on_team = "B";
			}
			else 
			{
				level._meat_on_team = "A";
			}
		}
		wait 0.05;
	}
}

wait_for_team_death( team )
{
	level endon( "end_game" );
	encounters_team = undefined;

	while ( true )
	{
		wait 0.05;
		while ( getDvarIntDefault( "zmeat_disable_round_ending", 0 ) == 1 )
			wait 0.1;
		while ( is_true( level._checking_for_save ) )
			wait 0.1;
		while ( is_true( level.meat_new_round ) )
			wait 0.1;
		while ( is_true( level.host_ended_game ) )
			wait 0.1;
		cdc_alive = 0;
		cia_alive = 0;
		players = getPlayers();
		for ( i = 0; i < players.size; i++ )
		{
			if ( !isDefined( players[ i ]._encounters_team ) )
			{
				continue;
			}
			if ( players[ i ]._encounters_team == "A" )
			{
				if ( is_player_valid( players[ i ] ) )
				{
					cia_alive++;
				}
				continue;
			}
			if ( is_player_valid( players[ i ] ) )
			{
				cdc_alive++;
			}
		}
		if ( cia_alive == 0 )
		{
			round_end( "B" );
		}
		else if ( cdc_alive == 0 )
		{
			round_end( "A" );
		}
	}
}

round_end( winner )
{
	level.meat_new_round = true;
	team = undefined;
	if ( isDefined( winner ) )
	{
		if ( winner == "A" )
		{
			team = "axis";
		}
		else
		{
			team = "allies";
		}
	}
	if ( !isDefined( level.meat_score ) )
	{
		level.meat_score = [];
		level.meat_score[ "A" ] = 0;
		level.meat_score[ "B" ] = 0;
	}
	if ( isDefined( winner ) )
	{
		level.meat_score[ winner ]++;
		level.server_hudelems[ "meat_score_" + winner ] SetValue( level.meat_score[ winner ] );
		setteamscore( team, level.meat_score[ winner ] );

		if ( ( level.meat_score[ winner ] >= getDvarIntDefault( "meat_scorelimit", 5 ) ) && !getDvarIntDefault( "zmeat_disable_game_ending", 0 ) )
		{
			game_won( winner );
			return;
		}
	}

	players = getPlayers();
	foreach ( player in players )
	{
		if ( is_player_valid( player ) )
		{
			// don't give perk
			player notify("perk_abort_drinking");
			// save weapons
			//player [[ level._game_module_player_laststand_callback ]]();
		}
	}

	level.zombie_vars[ "spectators_respawn" ] = true;
	if ( isDefined( winner ) )
	{
		foreach ( player in players )
		{
			if ( player.team == team ) 
			{
				player thread show_grief_hud_msg( "You won the round" );
			}
			else
			{
				player thread show_grief_hud_msg( "You lost the round" );
			}
		}
	}
	set_game_var( "side_selection", ( get_game_var( "side_selection" ) == 1 ? 2 : 1 ) );
	side_selection = get_game_var( "side_selection" );
	set_game_var( "switchedsides", !get_game_var( "switchedsides" ) );
	//new_array_a = level.meat_team_bounds[ "A" ];
	//new_array_b = level.meat_team_bounds[ "B" ];
	//level.meat_team_bounds[ "A" ] = new_array_b;
	//level.meat_team_bounds[ "B" ] = new_array_a;
	foreach ( player in players )
	{
		if ( side_selection == 1 ) 
		{
			if ( player.team == "allies" )
			{
				side_selection = 2;
			}
		}
		else if ( side_selection == 2 )
		{
			if ( player.team == "allies" )
			{
				side_selection = 1;
			}
		}
		player.spawnpoint_desired_script_int = side_selection;
	}
	flag_clear( "spawn_zombies" );
	maps\mp\zombies\_zm_game_module_meat_utility::zombie_goto_round( level.meat_round_number );
	//level thread maps\mp\zombies\_zm_game_module::reset_grief();
	//level thread maps\mp\zombies\_zm::round_think( 1 );
	//visionsetnaked( getdvar( "mapname" ), 3.0 );
	level.zombie_vars[ "spectators_respawn" ] = false;
	start_round();
	level notify( "reset_prizes" );
	flag_set( "spawn_zombies" );
	level.meat_new_round = false;
}

game_won( winner )
{
	level.gamemodulewinningteam = winner;
	level.zombie_vars[ "spectators_respawn" ] = false;
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		if ( is_true( players[ i ].has_minigun ) )
		{
			primaryweapons = players[ i ] getweaponslistprimaries();

			for ( x = 0; x < primaryweapons.size; x++ )
			{
				if ( primaryweapons[ x ] == "minigun_zm" )
					players[ i ] takeweapon( "minigun_zm" );
			}

			players[ i ] notify( "minigun_time_over" );
			players[ i ].zombie_vars["zombie_powerup_minigun_on"] = false;
			players[ i ]._show_solo_hud = false;
			players[ i ].has_minigun = false;
			players[ i ].has_powerup_weapon = false;
		}

		if ( players[ i ] hasweapon( get_gamemode_var( "item_meat_name" ) ) )
		{
			players[ i ] takeweapon( get_gamemode_var( "item_meat_name" ) );
			players[ i ] decrement_is_drinking();
		}
		players[ i ] freezecontrols( 1 );
		if ( players[ i ]._encounters_team == winner )
		{
			players[ i ] thread maps\mp\zombies\_zm_audio_announcer::leaderdialogonplayer( "grief_won" );
			continue;
		}
		players[ i ] thread maps\mp\zombies\_zm_audio_announcer::leaderdialogonplayer( "grief_lost" );
	}
	maps\mp\gametypes_zm\_zm_gametype::track_encounters_win_stats( level.gamemodulewinningteam );
	level notify( "game_module_ended", winner );
	level notify( "end_game" );
}

start_round()
{
	flag_clear( "start_encounters_match_logic" );
	if ( !isDefined( level.meat_initial_picked ) )
	{
		if ( cointoss() )
		{
			new_array_a = level.meat_team_bounds[ "A" ];
			new_array_b = level.meat_team_bounds[ "B" ];
			level.meat_team_bounds[ "A" ] = new_array_b;
			level.meat_team_bounds[ "B" ] = new_array_a;
			set_game_var( "side_selection", 1 );
		}
		else
		{
			set_game_var( "side_selection", 2 );
		}
	}
	flag_wait( "initial_blackscreen_passed" );
	if ( !isdefined( level._module_round_hud ) )
	{
		level._module_round_hud = newhudelem();
		level._module_round_hud.x = 0;
		level._module_round_hud.y = 70;
		level._module_round_hud.alignx = "center";
		level._module_round_hud.horzalign = "center";
		level._module_round_hud.vertalign = "middle";
		level._module_round_hud.font = "default";
		level._module_round_hud.fontscale = 2.3;
		level._module_round_hud.color = ( 1, 1, 1 );
		level._module_round_hud.foreground = 1;
		level._module_round_hud.sort = 0;
	}

	level thread freeze_all_players_controls_for_time( 3 );

	level._module_round_hud.alpha = 1;
	label = &"Next Round Starting In  ^2";
	level._module_round_hud.label = label;
	level._module_round_hud settimer( 3 );
	level thread maps\mp\zombies\_zm_audio::change_zombie_music( "round_start" );
	level notify( "start_fullscreen_fade_out" );
	wait 2;
	level._module_round_hud fadeovertime( 1 );
	level._module_round_hud.alpha = 0;
	wait 1;
	players = getPlayers();

	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] freezeControls( false );
		players[ i ] disableInvulnerability();
	}

	flag_set( "start_encounters_match_logic" );
	flag_clear( "pregame" );
	level._module_round_hud destroy();
	award_grenades_for_team( "A" );
	award_grenades_for_team( "B" );
	if ( !isDefined( level.meat_first_round ) )
	{
		level thread wait_for_team_death();
		hud_init();
		//level thread meat_intro( level._meat_start_points[ level.meat_starting_team ] );
		level thread item_meat_reset( level.meat_starting_team, true );
		level.meat_first_round = true;
	}
	else 
	{
		level.meat_starting_team = ( cointoss() ? "A" : "B" );
		item_meat_reset( level.meat_starting_team, true );
	}
}

freeze_all_players_controls_for_time( time )
{
	for ( i = 0; i < time; i += 0.1 )
	{
		players = getPlayers();

		for ( j = 0; j < players.size; j++ )
			players[ j ] freezeControls( true );
		wait 0.1;
	}
}

handle_super_sprint_mantle()
{
	traversealias = "barrier_walk";

	switch ( self.zombie_move_speed )
	{
		case "chase_bus":
		case "super_sprint":
			traversealias = "barrier_sprint";
			break;
		default:
/#
			assertmsg( "Zombie move speed of '" + self.zombie_move_speed + "' is not supported for mantle_over_40." );
#/
	}

	return traversealias;
}

always_false()
{
	return false;
}

watch_meat_in_map()
{
	level.meat_polygon_bounce_factor = 10;
	level.meat_is_under_the_map = false;
	level endon( "end_game" );
	i = 0;
	while ( true )
	{
		level.meat_show_prints_to_players = false;
		wait 0.05;
		waittillframeend;
		if ( !isDefined( level.the_meat ) )
		{
			continue;
		}
		if ( getPlayers().size <= 0 )
		{
			continue;
		}
		//meat_trace = playerPhysicsTrace( level.meat_under_the_map_limit, level.the_meat.origin + ( 0, 0, -2000 ) );
		//print( "meat_trace: " + meat_trace );
		//if ( meat_trace[ 2 ] < level.meat_under_the_map_limit[ 2 ] )
		if ( level.the_meat.origin[ 2 ] < level.meat_under_the_map_limit[ 2 ] )
		{
			print( "meat is under the map " + level.the_meat.origin );
			level.meat_is_under_the_map = true;
			item_meat_reset( level.meat_starting_team, true );
			//apply_penalty_to_team();
			continue;
		}
		if ( isDefined( level.the_meat ) && !check_point_is_in_polygon( level.meat_playable_bounds, level.the_meat.origin ) && !level.meat_is_under_the_map )
		{
			//cur_velocity = level.the_meat getVelocity();
			//new_velocity = ( cur_velocity * -1 ) * 0.2;
			target_pos = level._meat_location_center;
			start_pos = level.the_meat.origin;
			power = 1000;
			gravity = getdvarint( "bg_gravity" ) * -1;
			dist = distance( start_pos, target_pos );
			time = dist / power;
			delta = target_pos - start_pos;
			drop = 0.5 * gravity * ( time * time );
			velocity = ( ( delta[0] / time ) / level.meat_polygon_bounce_factor, ( delta[1] / time ) / level.meat_polygon_bounce_factor, ( delta[2] - drop ) / time );
			cur_origin = level.the_meat.origin;
			//print( "velocity: " + velocity );
			level.the_meat cleanup_meat();
			level.the_meat = getPlayers()[ 0 ] magicgrenadetype( get_gamemode_var( "item_meat_name" ), cur_origin, velocity );
			level.the_meat thread check_meat_is_back_in_bounds();
			level.the_meat waittill_any_timeout( time, "stationary", "death", "in_bounds" );
		}
		first_team_to_check = ( cointoss() ? "A" : "B" );
		//first_team_to_check = "A";
		second_team_to_check = get_other_encounters_team( first_team_to_check );
		if ( check_point_is_in_polygon( level.meat_team_bounds[ first_team_to_check ], level.the_meat.origin ) )
		{
			assign_meat_to_team( undefined, first_team_to_check );
		}
		else if ( check_point_is_in_polygon( level.meat_team_bounds[ second_team_to_check ], level.the_meat.origin ) )
		{
			assign_meat_to_team( undefined, second_team_to_check );
		}
		else 
		{
			//print( "first team: " + first_team_to_check + " " + level.meat_team_bounds[ first_team_to_check ][ 0 ] );
			//print( "second team: " + second_team_to_check + " " + level.meat_team_bounds[ second_team_to_check ] );
			print( "meat is outside team bounds " + level.the_meat.origin );
			//level.meat_is_not_in_team_bounds = true;
			//item_meat_reset( level.meat_starting_team, true );
		}
		if ( ( i % 40 ) == 0 )
		{
			level.meat_show_prints_to_players = true;
			i = 0;
		}
		i++;
	}
}

watch_player_bounds()
{
	level endon( "end_game" );

	while ( true )
	{
		wait 0.05;
		players = getPlayers();
		for ( i = 0; i < players.size; i++ )
		{
			if ( !check_point_is_in_polygon( level.meat_playable_bounds, players[ i ].origin ) && !is_true( players[ i ].being_pushed_towards_center_of_map ) )
			{
				players[ i ].being_pushed_towards_center_of_map = true;
				players[ i ] thread push_player_towards_center_of_map();
			}
		}
	}
}

push_player_towards_center_of_map()
{
	self setVelocity( self get_push_vector() );
	//wait 0.05;
	self.being_pushed_towards_center_of_map = false;
}

get_push_vector()
{
    return vectornormalize( level._meat_location_center - self.origin ) * 100;
}

check_meat_is_back_in_bounds()
{
	self endon( "stationary" );
	self endon( "death" );
	self notify( "check_meat_is_back_in_bounds" );
	self endon( "check_meat_is_back_in_bounds" );

	while ( !check_point_is_in_polygon( level.meat_playable_bounds, self.origin ) )
	{
		wait 0.05;
	}

	self notify( "in_bounds" );
}

meat_check_valid_spawn_override( player, return_struct )
{
	//print( player.name + " meat_check_valid_spawn_override() " );
	structs = getstructarray( "initial_spawn", "script_noteworthy" );

	if ( isdefined( structs ) )
	{
		match_string = "";
		location = level.scr_zm_map_start_location;

		if ( ( location == "default" || location == "" ) && isdefined( level.default_start_location ) )
			location = level.default_start_location;

		match_string = level.scr_zm_ui_gametype + "_" + location;
		spawnpoints = [];
		foreach ( struct in structs )
		{
			if ( isdefined( struct.script_string ) )
			{
				tokens = strtok( struct.script_string, " " );

				foreach ( token in tokens )
				{
					if ( token == match_string )
						spawnpoints[ spawnpoints.size ] = struct;
				}
			}
		}
	}
	spawnpoint = maps\mp\zombies\_zm::getFreeSpawnpoint( spawnpoints, player );
	if ( return_struct )
	{
		return spawnpoint;
	}
	else 
	{
		return isDefined( spawnpoint ) ? spawnpoint.origin : undefined;
	}
}

custom_end_screen()
{
	players = get_players();

	for ( i = 0; i < players.size; i++ )
	{
		players[ i ].game_over_hud = newclienthudelem( players[ i ] );
		players[ i ].game_over_hud.alignx = "center";
		players[ i ].game_over_hud.aligny = "middle";
		players[ i ].game_over_hud.horzalign = "center";
		players[ i ].game_over_hud.vertalign = "middle";
		players[ i ].game_over_hud.y -= 130;
		players[ i ].game_over_hud.foreground = 1;
		players[ i ].game_over_hud.fontscale = 3;
		players[ i ].game_over_hud.alpha = 0;
		players[ i ].game_over_hud.color = ( 1, 1, 1 );
		players[ i ].game_over_hud.hidewheninmenu = 1;
		players[ i ].game_over_hud settext( &"ZOMBIE_GAME_OVER" );
		players[ i ].game_over_hud fadeovertime( 1 );
		players[ i ].game_over_hud.alpha = 1;

		players[ i ].survived_hud = newclienthudelem( players[ i ] );
		players[ i ].survived_hud.alignx = "center";
		players[ i ].survived_hud.aligny = "middle";
		players[ i ].survived_hud.horzalign = "center";
		players[ i ].survived_hud.vertalign = "middle";
		players[ i ].survived_hud.y -= 100;
		players[ i ].survived_hud.foreground = 1;
		players[ i ].survived_hud.fontscale = 2;
		players[ i ].survived_hud.alpha = 0;
		players[ i ].survived_hud.color = ( 1, 1, 1 );
		players[ i ].survived_hud.hidewheninmenu = 1;

		winner_text = &"ZOMBIE_GRIEF_WIN";
		loser_text = &"ZOMBIE_GRIEF_LOSE";

		if ( level.round_number < 2 )
		{
			winner_text = &"ZOMBIE_GRIEF_WIN_SINGLE";
			loser_text = &"ZOMBIE_GRIEF_LOSE_SINGLE";
		}

		if ( isdefined( level.host_ended_game ) && level.host_ended_game )
			players[ i ].survived_hud settext( &"MP_HOST_ENDED_GAME" );
		else if ( isdefined( level.gamemodulewinningteam ) && players[ i ]._encounters_team == level.gamemodulewinningteam )
			players[ i ].survived_hud settext( winner_text, level.round_number );
		else
			players[ i ].survived_hud settext( loser_text, level.round_number );

		players[ i ].survived_hud fadeovertime( 1 );
		players[ i ].survived_hud.alpha = 1;
	}
}

game_module_player_damage_grief_callback( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( isdefined( eattacker ) && isplayer( eattacker ) && eattacker != self && eattacker.team != self.team )
		self applyknockback( idamage, vdir );
}

meat_should_sidestep()
{
	return randomInt( 2 ) == 0 ? "step" : "roll";
}

meat_failsafe()
{
	level endon( "end_game" );
	while ( getPlayers().size <= 0 )
	{
		wait 1;
	}
	while ( true )
	{
		if ( !isDefined( level.the_meat ) && !isDefined( get_player_with_meat() ) )
		{
			wait 5;
			if ( !isDefined( level.the_meat ) && !isDefined( get_player_with_meat() ) )
			{
				item_meat_reset( level.meat_starting_team, true );
			}
		}
		wait 1;
	}
}

end_game_if_empty()
{
	while ( getPlayers().size <= 0 )
	{
		wait 1;
	}
	while ( getPlayers().size > 0 )
	{
		wait 1;
	}
	level notify( "end_game" );
}