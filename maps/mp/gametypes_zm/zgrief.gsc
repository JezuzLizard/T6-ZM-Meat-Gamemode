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
	level.zm_disable_recording_stats = true;
	game[ "gamestarted" ] = undefined;
	level.timelimitoverride = true;
	maps\mp\gametypes_zm\_zm_gametype::main();
	onplayerconnect_callback( ::meat_on_player_connect );
	level.onprecachegametype = ::onprecachegametype;
	level.onstartgametype = ::onstartgametype;
	level._game_module_custom_spawn_init_func = maps\mp\gametypes_zm\_zm_gametype::custom_spawn_init_func;
	level._no_static_unitriggers = true;
	level._game_module_player_damage_callback = maps\mp\gametypes_zm\_zm_gametype::game_module_player_damage_callback;
	level.zm_mantle_over_40_move_speed_override = ::handle_super_sprint_mantle;
	level.no_end_game_check = true;
	level._game_module_game_end_check = ::always_false;
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
	level thread spawn_side_trigger();
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
	starting_team = ( cointoss() ? "A" : "B" );
	level.meat_starting_team = starting_team;
	level thread meat_player_initial_spawn();
	level thread item_meat_reset( level._meat_start_points[ level.meat_starting_team ] );
	level thread spawn_meat_zombies();
	level thread monitor_meat_on_team();
	level thread init_minigun_ring();
	level thread init_ammo_ring();
	level thread hide_non_meat_objects();
	level thread setup_meat_world_objects();
	level thread watch_meat_in_map();
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
	level thread wait_for_team_death( "A" );
	level thread wait_for_team_death( "B" );
	level.team_a_downed = 0;
	level.team_b_downed = 0;
}

meat_on_player_connect()
{
	hotjoined = flag( "initial_players_connected" );
	self thread spawn_player_meat_manager();
	self thread wait_for_player_disconnect();
	self thread wait_for_player_downed();
	level.player_out_of_playable_area_monitor = false;
	if ( hotjoined )
	{
		self meat_player_setup();
	}
	if ( !isDefined( level.zmeat_test_bots ) )
	{
		level.zmeat_test_bots = getDvarIntDefault( "zmeat_test_bots", 0 );
		for ( i = 0; i < level.zmeat_test_bots; i++ )
		{
			bot = addTestClient();
			bot.pers[ "isBot" ] = true;
		}
	}
}

meat_on_player_disconnect()
{
	team_counts = [];
	team_counts["A"] = 0;
	team_counts["B"] = 0;
	players = getPlayers();

	for ( i = 0; i < players.size; i++ )
		team_counts[players[i]._encounters_team]++;

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
	level endon( "meat_end" );

	level waittill( "meat_grabbed" );
	last_team = level._meat_on_team;
	level.meat_lost_time_limit = 5000;

	while ( true )
	{
		if ( isdefined( level.item_meat ) )
		{
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
			else if ( isdefined( last_team ) )
			{
				if ( !isdefined( level.meat_lost_time ) )
					level.meat_lost_time = gettime();
				else if ( gettime() - level.meat_lost_time > level.meat_lost_time_limit )
				{
					add_meat_event( "level_lost_meat" );
					new_team = ( cointoss() ? "A" : "B" );
					level thread item_meat_reset( level._meat_start_points[ new_team ], 1 );
					level.meat_lost_time = undefined;

					assign_meat_to_team( undefined, new_team );
				}
			}
		}
		else
		{
			player_with_meat = get_player_with_meat();

			if ( !isdefined( player_with_meat ) )
			{
				if ( !isdefined( level.meat_lost_time ) )
					level.meat_lost_time = gettime();
				else if ( gettime() - level.meat_lost_time > level.meat_lost_time_limit )
				{
					add_meat_event( "level_lost_meat" );
					new_team = ( cointoss() ? "A" : "B" );
					level thread item_meat_reset( level._meat_start_points[ new_team ], 1 );
					level.meat_lost_time = undefined;
					assign_meat_to_team( undefined, new_team );
				}
			}
			else
				level.meat_lost_time = undefined;
		}

		if ( isdefined( level._meat_on_team ) && isdefined( last_team ) && level._meat_on_team != last_team )
		{
			level notify( "clear_ignore_all" );
			add_meat_event( "level_meat_team", level._meat_on_team );
			last_team = level._meat_on_team;
			assign_meat_to_team( undefined, level._meat_on_team );
		}

		wait 0.05;
	}
}

item_meat_watch_for_throw()
{
	level endon( "meat_end" );

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
	level endon( "meat_end" );

	level waittill( "meat_grabbed" );

	while ( true )
	{
		player = get_player_with_meat();

		if ( !isdefined( player ) )
		{
			wait 0.2;
			continue;
		}

		if ( !should_try_to_bring_back_teammate( player._encounters_team ) )
		{
			wait 0.2;
			continue;
		}

		if ( !( isdefined( player._bringing_back_teammate ) && player._bringing_back_teammate ) )
			player thread bring_back_teammate_progress();

		wait 0.2;
	}
}

wait_for_player_downed()
{
	self endon( "disconnect" );

	while ( isdefined( self ) )
	{
		self waittill_any( "player_downed", "fake_death", "death" );
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
	level._meat_moving = 0;
	level._meat_splitter_activated = 0;
	level._last_person_to_throw_meat = undefined;
	self.meat_is_moving = 0;
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
	level._meat_splitter_activated = false;
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
	level._meat_splitter_activated = 0;

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
	self._spawning_meat = 0;
	self._kicking_meat = 0;

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
	player = self;
	player._bringing_back_teammate = true;
	revivetime = 15;
	progress = 0;

	while ( player_has_meat( player ) && is_player_valid( player ) && progress >= 0 )
	{
		if ( !isdefined( player.revive_team_progressbar ) )
		{
			player.revive_team_progressbar = player createprimaryprogressbar();
			player.revive_team_progressbar updatebar( 0.01, 1 / revivetime );
			player.revive_team_progressbar.progresstext = player createprimaryprogressbartext();
			player.revive_team_progressbar.progresstext settext( &"ZOMBIE_MEAT_RESPAWN_TEAMMATE" );
			player thread destroy_revive_progress_on_downed();
		}

		progress++;

		if ( progress > revivetime * 10 )
		{
			level bring_back_dead_teammate( player._encounters_team );
			player destroy_revive_progress();
			wait 1;
			player._bringing_back_teammate = false;
			progress = -1;
		}

		wait 0.1;
	}

	player._bringing_back_teammate = 0;
	player destroy_revive_progress();
}

should_try_to_bring_back_teammate( team )
{
	players = getPlayers();

	for ( i = 0; i < players.size; i++ )
	{
		if ( players[i]._encounters_team == team && players[i].sessionstate == "spectator" )
			return true;
	}

	return false;
}

bring_back_dead_teammate( team )
{
	players = getPlayers();

	for ( i = 0; i < players.size; i++ )
	{
		if ( players[i]._encounters_team == team && players[i].sessionstate == "spectator" )
		{
			player = players[i];
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
	self.is_burning = 0;
	self.is_zombie = 0;
	self.ignoreme = 0;
}

destroy_revive_progress_on_downed()
{
	level endon( "end_game" );
	level endon( "meat_end" );
	self waittill_any( "fake_death", "player_downed", "death" );
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
	if ( isdefined( self._kicking_meat ) && self._kicking_meat )
		return;

	self._kicking_meat = true;
	self._spawning_meat = true;
	org = meat.origin;

	meat cleanup_meat();
	level._last_person_to_throw_meat = self;
	level._last_person_to_throw_meat_time = gettime();
	level._meat_splitter_activated = 0;

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
	grenade = self magicgrenadetype( get_gamemode_var( "item_meat_name" ), org, ( launchvel[0], launchvel[1], height_boost ) );
	grenade playsound( "zmb_meat_meat_tossed" );
	grenade thread waittill_loopstart();

	level.the_meat = grenade;

	wait 0.1;
	self._spawning_meat = 0;
	self._kicking_meat = 0;

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

pickup_origin()
{
	origin = self get_eye();

	if ( !isdefined( origin ) )
		origin = self gettagorigin( "tag_weapon" );

	if ( !isdefined( origin ) )
		origin = self gettagorigin( "tag_weapon_right" );

	if ( !isdefined( origin ) )
		origin = self.origin;

	return origin;
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
	level endon( "meat_end" );
	force_riser = 0;
	force_chaser = 0;
	num = 0;
	max_ai_num = 24;
	//level waittill( "meat_grabbed" );
	//level waittill( "meat_assigned_to_team" );
	flag_wait( "initial_blackscreen_passed" );
	wait 10;
	while ( true )
	{
		wait( level._meat_zombie_spawn_timer );
		if ( getDvarIntDefault( "zmeat_disable_zombie_spawning", 0 ) )
		{
			continue;
		}
		ai = getaiarray( level.zombie_team );
		if ( ai.size > max_ai_num )
			wait 0.1;
		else
		{
			side = level._meat_on_team;
			if ( isDefined( side ) )
			{
				spawn_points = level._zmeat_zombie_spawn_locations[ side ];
			}
			else 
			{
				random_side = ( cointoss() ? "A" : "B" );
				spawn_points = level._zmeat_zombie_spawn_locations[ random_side ];
			}
			spawn_points = array_randomize( spawn_points );

			zombie = spawn_meat_zombie( level.meat_spawners[0], "meat_zombie", spawn_points[ 0 ], level._meat_zombie_spawn_health );

			if ( isdefined( zombie ) )
				zombie thread make_super_sprinter_after_time( 0.25 );
		}
	}
}

spawn_meat_zombie( spawner, target_name, spawn_point, round_number )
{
	level endon( "meat_end" );

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
	spawner._spawning = undefined;
	level._meat_zombie_spawning = false;
	return zombie;
}

make_super_sprinter_after_time( time )
{
	wait time;
	self maps\mp\zombies\_zm_game_module::make_supersprinter();
}

monitor_meat_on_team()
{
	level endon( "meat_end" );

	while ( true )
	{
		wait 0.1;
		players = getPlayers();

		for ( i = 0; i < players.size; i++ )
		{
			if ( !isdefined( players[ i ] ) )
			{
				continue;
			}
			if ( !is_player_valid( players[ i ] ) )
			{
				continue;
			}
			if ( isdefined( level._meat_on_team ) )
			{
				if ( level._meat_on_team == players[ i ]._encounters_team )
				{
					players[ i ].ignoreme = false;
				}
				else 
				{
					players[ i ].ignoreme = true;
				}
			}
			else
			{
				players[ i ].ignoreme = false;
			}
		}
	}
}

item_meat_reset( origin, immediate )
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

	if ( isdefined( origin ) )
		item_meat_spawn( origin );
}

meat_player_initial_spawn()
{
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		if ( isdefined( level.custom_player_fake_death_cleanup ) )
			players[i] [[ level.custom_player_fake_death_cleanup ]]();
		players[i] meat_player_setup();
	}

	waittillframeend;
	start_round();
	award_grenades_for_team( "A" );
	award_grenades_for_team( "B" );
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
	/*
	meat = level.item_meat;

	if ( isdefined( meat ) )
	{
		meatorg = meat.origin + vectorscale( ( 0, 0, 1 ), 8.0 );
		trace = bullettrace( self pickup_origin(), meatorg, 0, meat );
		if ( distancesquared( trace["position"], meatorg ) < 1 )
		{
			print( "distancesquared( trace[ position ], meatorg ) < 1" );
			return true;
		}
		else 
		{
			print( "distancesquared( trace[ position ], meatorg ) > 1" );
			return false;
		}
	}
	*/
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
			player thread spike_the_meat( self );
		else
		{
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
	level notify( "meat_grabbed" );
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
	self endon( "death" );
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
	if ( isdefined( level.item_meat ) && ( isdefined( level.item_meat.meat_is_moving ) && level.item_meat.meat_is_moving ) )
	{
		if ( abs( level.item_meat.origin[2] - groundpos( level.item_meat.origin )[2] ) < 35 )
		{
			level._zombies_ignoring_all = 0;
			level notify( "clear_ignore_all" );
			return undefined;
		}

		level thread set_ignore_all();
		meat_poi = [];
		meat_poi[0] = groundpos( level.item_meat.origin );
		meat_poi[1] = level.item_meat;
		return meat_poi;
	}

	level._zombies_ignoring_all = 0;
	return undefined;
}

meat_end_match( winning_team )
{
	players = getPlayers();

	for ( i = 0; i < players.size; i++ )
	{
		if ( isdefined( players[i].has_minigun ) && players[i].has_minigun )
		{
			primaryweapons = players[i] getweaponslistprimaries();

			for ( x = 0; x < primaryweapons.size; x++ )
			{
				if ( primaryweapons[x] == "minigun_zm" )
					players[i] takeweapon( "minigun_zm" );
			}

			players[i] notify( "minigun_time_over" );
			players[i].zombie_vars["zombie_powerup_minigun_on"] = false;
			players[i]._show_solo_hud = false;
			players[i].has_minigun = false;
			players[i].has_powerup_weapon = false;
		}

		if ( players[i] hasweapon( get_gamemode_var( "item_meat_name" ) ) )
		{
			players[i] takeweapon( get_gamemode_var( "item_meat_name" ) );
			players[i] decrement_is_drinking();
		}
	}

	level notify( "game_module_ended", winning_team );
	wait 0.1;
	level delay_thread( 2, ::item_meat_clear );

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
	self endon( "death" );

	self waittill( "player_revived" );

	if ( team == "A" )
		level.team_a_downed--;
	else
		level.team_b_downed--;
}

assign_meat_to_team( player, encounters_team )
{
	meat_team = undefined;
	players = getPlayers();

	if ( isdefined( player ) )
	{
		meat_team = player._encounters_team;
	}
	else if ( isdefined( encounters_team ) )
	{
		meat_team = encounters_team;
	}

	if ( !isDefined( player ) )
	{
		level._meat_on_team = meat_team;
		level notify( "meat_assigned_to_team" );
	}
	teamplayers = get_players_on_encounters_team( meat_team );
	for ( i = 0; i < teamplayers.size; i++ )
	{
		if ( !isdefined( teamplayers[i] ) )
			continue;

		if ( isdefined( player ) && teamplayers[i] == player )
		{
			if ( isdefined( teamplayers[i]._has_meat ) && teamplayers[i]._has_meat )
				continue;

			teamplayers[i]._has_meat = 1;
			teamplayers[i] thread slow_down_player_with_meat();
			teamplayers[i] thread reset_meat_when_player_downed();
			teamplayers[i] thread reset_meat_when_player_disconnected();
		}
	}
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
	self notify( "reset_downed" );
	self endon( "reset_downed" );
	level endon( "meat_reset" );
	level endon( "meat_thrown" );
	self waittill_any( "player_downed", "death", "fake_death", "replace_weapon_powerup" );
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
	level endon( "meat_end" );
	team = self._encounters_team;

	self waittill( "disconnect" );

	level thread item_meat_drop( level._meat_player_tracker_origin, team );
}

item_meat_drop( org, team )
{
	players = get_alive_players_on_encounters_team( team );

	if ( players.size > 0 )
	{
		player = players[0];
		player endon( "disconnect" );
		player._spawning_meat = true;
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
		if ( isdefined( players[i]._has_meat ) && players[i]._has_meat )
			return players[i];
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
	self endon( "death_or_disconnect" );

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
	self endon( "death_or_disconnect" );

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
	//trigger thread debug_trigger();
	trigger thread switch_team_has_meat_on_trigger();
}

// debug_trigger()
// {
// 	while ( true )
// 	{
// 		self waittill( "trigger", ent );
// 		if ( isPlayer( ent ) )
// 		{
// 			ent iPrintLn( "Player is touching trigger" );
// 		}
// 		else if ( is_true( ent.is_meat ) )
// 		{
// 			level iPrintLn( "Meat is touching trigger" );
// 		}
// 		jsonDump( va( "%s_%s_%s_%s", ent.classname, getDvar( "g_gametype" ), getDvar( "ui_zm_mapstartlocation" ), getDvar( "mapname" ) ), ent );
// 		wait 1;
// 	}
// }

switch_team_has_meat_on_trigger()
{
	while ( true )
	{
		if ( isDefined( level.the_meat ) && level.the_meat isTouching( self ) )
		{
			level.meat_touched_middle_volume = true;
		}
		wait 0.05;
	}
}

wait_for_team_death( team )
{
	level endon( "meat_end" );
	encounters_team = undefined;

	while ( true )
	{
		wait 1;

		while ( isdefined( level._checking_for_save ) && level._checking_for_save )
			wait 0.1;

		alive_team_players = get_alive_players_on_encounters_team( team );

		if ( alive_team_players.size > 0 )
		{
			encounters_team = alive_team_players[ 0 ]._encounters_team;
			continue;
		}

		break;
	}

	if ( !isdefined( encounters_team ) )
		return;

	winning_team = "A";

	if ( encounters_team == "A" )
		winning_team = "B";

	level notify( "meat_end", winning_team );
}

start_round()
{
	flag_clear( "start_encounters_match_logic" );
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

	players = getPlayers();

	for ( i = 0; i < players.size; i++ )
		players[i] freeze_player_controls( 1 );

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
		players[i] freeze_player_controls( 0 );
		players[i] sprintuprequired();
	}

	flag_set( "start_encounters_match_logic" );
	flag_clear( "pregame" );
	level._module_round_hud destroy();
	level thread meat_intro( level._meat_start_points[ level.meat_starting_team ] );
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

create_meat_bounds_polygon()
{
	add_point_to_meat_bounds( ( 1173.28, -843.642, -55.875 ) );
	add_point_to_meat_bounds( ( 1086.71, -738.547, -55.875 ) );
	connect_point_on_polygon( ( 1173.28, -843.642, -55.875 ), ( 1086.71, -738.547, -55.875 ) );

	add_point_to_meat_bounds( ( 1073.83, -369.226, -61.875 ) );
	connect_point_on_polygon( ( 1086.71, -738.547, -55.875 ), ( 1073.83, -369.226, -61.875 ) );

	add_point_to_meat_bounds( ( 968.069, -136.957, -48.121 ) );
	connect_point_on_polygon( ( 1073.83, -369.226, -61.875 ), ( 968.069, -136.957, -48.121 ) );

	add_point_to_meat_bounds( ( 1130.38, 21.0768, -40.4399 ) );
	connect_point_on_polygon( ( 968.069, -136.957, -48.121 ), ( 1130.38, 21.0768, -40.4399 ) );

	add_point_to_meat_bounds( ( 1131.93, 248.836, -39.875 ) );
	connect_point_on_polygon( ( 1130.38, 21.0768, -40.4399 ), ( 1131.93, 248.836, -39.875 ) );

	add_point_to_meat_bounds( ( 1395.27, 329.722, -61.875 ) );
	connect_point_on_polygon( ( 1131.93, 248.836, -39.875 ), ( 1395.27, 329.722, -61.875 ) );

	add_point_to_meat_bounds( ( 1746.36, 262.378, -55.875 ) );
	connect_point_on_polygon( ( 1395.27, 329.722, -61.875 ), ( 1746.36, 262.378, -55.875 ) );

	add_point_to_meat_bounds( ( 1728.88, -327.603, -61.875 ) );
	connect_point_on_polygon( ( 1746.36, 262.378, -55.875 ), ( 1728.88, -327.603, -61.875 ) );

	add_point_to_meat_bounds( ( 1696.27, -404.117, -60.0451 ) );
	connect_point_on_polygon( ( 1728.88, -327.603, -61.875 ), ( 1696.27, -404.117, -60.0451 ) );

	add_point_to_meat_bounds( ( 1693.15, -560.723, -49.4247 ) );
	connect_point_on_polygon( ( 1696.27, -404.117, -60.0451 ), ( 1693.15, -560.723, -49.4247 ) );

	add_point_to_meat_bounds( ( 1622.8, -723.422, -54.3495 ) );
	connect_point_on_polygon( ( 1693.15, -560.723, -49.4247 ), ( 1622.8, -723.422, -54.3495 ) );

	add_point_to_meat_bounds( ( 1638.99, -1004.68, -61.875 ) );
	connect_point_on_polygon( ( 1622.8, -723.422, -54.3495 ), ( 1638.99, -1004.68, -61.875 ) );

	add_point_to_meat_bounds( ( 1504.55, -985.215, -52.3769 ) );
	connect_point_on_polygon( ( 1638.99, -1004.68, -61.875 ), ( 1504.55, -985.215, -52.3769 ) );

	add_point_to_meat_bounds( ( 1371.13, -854.452, -61.1272 ) );
	connect_point_on_polygon( ( 1504.55, -985.215, -52.3769 ), ( 1371.13, -854.452, -61.1272 ) );

	connect_point_on_polygon( ( 1371.13, -854.452, -61.1272 ), ( 1086.71, -738.547, -55.875 ) );
}

watch_meat_in_map()
{
	create_meat_bounds_polygon();
	level.meat_polygon_bounce_factor = 10;
	level.meat_is_under_the_map = false;
	level endon( "end_game" );
	while ( true )
	{
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
			level.meat_is_under_the_map = true;
			level thread item_meat_reset( level._meat_start_points[ level.meat_starting_team ], true );
			//apply_penalty_to_team();
			print( "meat is under the map 1" );
			continue;
		}
		if ( isDefined( level.the_meat ) && !check_point_is_in_polygon( level.meat_bounds, level.the_meat.origin ) && !level.meat_is_under_the_map )
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
			print( "velocity: " + velocity );
			level.the_meat cleanup_meat();
			level.the_meat = getPlayers()[ 0 ] magicgrenadetype( get_gamemode_var( "item_meat_name" ), cur_origin, velocity );
			level.the_meat waittill_any_timeout( time, "stationary", "death" );
		}
	}
}
