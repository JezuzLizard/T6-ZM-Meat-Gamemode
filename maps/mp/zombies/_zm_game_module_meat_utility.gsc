// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_game_module_utility;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_audio_announcer;
#include maps\mp\gametypes_zm\zmeat;
#include maps\mp\zombies\_zm_powerups;

award_grenades_for_team( team )
{
	players = getPlayers();

	for ( i = 0; i < players.size; i++ )
	{
		if ( !isdefined( players[i]._encounters_team ) || players[i]._encounters_team != team )
			continue;

		lethal_grenade = players[i] get_player_lethal_grenade();
		players[i] giveweapon( lethal_grenade );
		players[i] setweaponammoclip( lethal_grenade, 4 );
	}
}

get_players_on_encounters_team( team )
{
	players = getPlayers();
	players_on_team = [];

	for ( i = 0; i < players.size; i++ )
	{
		if ( !isdefined( players[i]._encounters_team ) || players[i]._encounters_team != team )
			continue;

		players_on_team[players_on_team.size] = players[i];
	}

	return players_on_team;
}

get_alive_players_on_encounters_team( team )
{
	players = getPlayers();
	players_on_team = [];

	for ( i = 0; i < players.size; i++ )
	{
		if ( !isdefined( players[i]._encounters_team ) || players[i]._encounters_team != team )
			continue;

		if ( players[i].sessionstate == "spectator" || players[i] maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
			continue;

		players_on_team[players_on_team.size] = players[i];
	}

	return players_on_team;
}

init_minigun_ring()
{
	if ( isdefined( level._minigun_ring ) )
		return;

	ring_pos = getstruct( level._meat_location + "_meat_minigun", "script_noteworthy" );

	if ( !isdefined( ring_pos ) )
	{
		return;
	}
	level._minigun_ring = spawn( "script_model", ring_pos.origin );
	level._minigun_ring.angles = ring_pos.angles;
	//level._minigun_ring setmodel( ring_pos.script_parameters );
	// level._minigun_ring_clip = getent( level._meat_location + "_meat_minigun_clip", "script_noteworthy" );

	// if ( isdefined( level._minigun_ring_clip ) )
	//     level._minigun_ring_clip linkto( level._minigun_ring );
	// else
	// {
	//     iprintlnbold( "BUG: no level._minigun_ring_clip" );
	// 	print( "no minigun ring clip" );
	// }
	level._minigun_ring_trig = getent( level._meat_location + "_meat_minigun_trig", "targetname" );

	if ( !isDefined( level._minigun_ring_trig ) )
	{
		level._minigun_ring_trig = spawn( "trigger_radius", ring_pos.origin, 0, 100, 100 );
	}
	if ( isdefined( level._minigun_ring_trig ) )
	{
		level._minigun_ring_trig enablelinkto();
		level._minigun_ring_trig linkto( level._minigun_ring );
		level._minigun_icon = spawn( "script_model", level._minigun_ring_trig.origin );
		level._minigun_icon setmodel( getweaponmodel( "minigun_zm" ) );
		level._minigun_icon._glow_fx = playfxontag( level._effect["ring_glow"], level._minigun_icon, "tag_origin" );
		level._minigun_icon linkto( level._minigun_ring );
		//level._minigun_icon setclientfield( "ring_glowfx", 1 );
		level thread ring_toss( level._minigun_ring_trig, "minigun" );
	}
	// else
	// {
	// 	print( "no minigun ring trig" );
	//     iprintlnbold( "BUG: no level._minigun_ring_trig" );
	// }
	level._minigun_ring thread move_ring( ring_pos );
	level._minigun_ring thread rotate_ring( 1 );
}

init_ammo_ring()
{
	if ( isdefined( level._ammo_ring ) )
		return;

	name = level._meat_location + "_meat_ammo";
	ring_pos = getstruct( name, "script_noteworthy" );

	if ( !isdefined( ring_pos ) )
	{
		print( "no ammo ring" );
		return;
	}
	level._ammo_ring = spawn( "script_model", ring_pos.origin );
	level._ammo_ring.angles = ring_pos.angles;
	//level._ammo_ring setmodel( ring_pos.script_parameters );
	name = level._meat_location + "_meat_ammo_clip";
	// level._ammo_ring_clip = getent( name, "script_noteworthy" );

	// if ( isdefined( level._ammo_ring_clip ) )
	//     level._ammo_ring_clip linkto( level._ammo_ring );
	// else
	// {
	// 	print( "no ammo ring clip" );
	//     iprintlnbold( "BUG: no level._ammo_ring_clip" );
	// }
	name = level._meat_location + "_meat_ammo_trig";
	level._ammo_ring_trig = getent( name, "targetname" );
	if ( !isDefined( level._ammo_ring_trig ) )
	{
		level._ammo_ring_trig = spawn( "trigger_radius", ring_pos.origin, 0, 100, 100 );
	}
	if ( isdefined( level._ammo_ring_trig ) )
	{
		level._ammo_ring_trig enablelinkto();
		level._ammo_ring_trig linkto( level._ammo_ring );
		level._ammo_icon = spawn( "script_model", level._ammo_ring_trig.origin );
		level._ammo_icon setmodel( "zombie_ammocan" );
		level._ammo_icon._glow_fx = playfxontag( level._effect["ring_glow"], level._ammo_icon, "tag_origin" );
		level._ammo_icon linkto( level._ammo_ring );
		//level._ammo_icon setclientfield( "ring_glowfx", 1 );
		level thread ring_toss( level._ammo_ring_trig, "ammo" );
	}
	else
	{
		print( "no ammo ring trig" );
		iprintlnbold( "BUG: no level._ammo_ring_trig" );
	}
	level._ammo_ring thread move_ring( ring_pos );
	level._ammo_ring thread rotate_ring( 1 );
}

ring_toss( trig, type )
{
	level endon( "end_game" );

	while ( true )
	{
		if ( isdefined( level._ring_triggered ) && level._ring_triggered )
		{
			wait 0.05;
			continue;
		}

		if ( isdefined( level.item_meat ) && ( isdefined( level.item_meat.meat_is_moving ) && level.item_meat.meat_is_moving ) )
		{
			if ( level.item_meat istouching( trig ) )
			{
				level thread ring_toss_prize( type, trig );
				level._ring_triggered = 1;
				level thread ring_cooldown();
			}
		}

		wait 0.05;
	}
}

ring_cooldown()
{
	wait 3;
	level._ring_triggered = 0;
}

ring_toss_prize( type, trig )
{
	switch ( type )
	{
		case "minigun":
			level thread minigun_prize( trig );
			break;
		case "ammo":
			level thread ammo_prize( trig );
			break;
	}
}

minigun_prize( trig )
{
	while ( isdefined( level.item_meat ) && level.item_meat istouching( trig ) )
		wait 0.05;

	if ( !isdefined( level.item_meat ) )
		return;

	if ( isdefined( level._minigun_toss_cooldown ) && level._minigun_toss_cooldown )
		return;

	level thread minigun_toss_cooldown();

	if ( !is_player_valid( level._last_person_to_throw_meat ) )
		return;

	level._last_person_to_throw_meat thread maps\mp\zombies\_zm_powerups::powerup_vo( "minigun" );
	level thread maps\mp\zombies\_zm_powerups::minigun_weapon_powerup( level._last_person_to_throw_meat );
}

ammo_prize( trig )
{
	while ( isdefined( level.item_meat ) && level.item_meat istouching( trig ) )
		wait 0.05;

	if ( !isdefined( level.item_meat ) )
		return;

	if ( isdefined( level._ammo_toss_cooldown ) && level._ammo_toss_cooldown )
		return;

	playfx( level._effect["poltergeist"], trig.origin );
	level thread ammo_toss_cooldown();
	level._last_person_to_throw_meat thread maps\mp\zombies\_zm_powerups::powerup_vo( "full_ammo" );
	level thread maps\mp\zombies\_zm_powerups::full_ammo_powerup( undefined, level._last_person_to_throw_meat );
}

minigun_toss_cooldown()
{
	level._minigun_toss_cooldown = 1;

	if ( isdefined( level._minigun_icon ) )
		level._minigun_icon delete();

	waittill_any_or_timeout( 120, "meat_end" );
	playfx( level._effect["poltergeist"], level._minigun_ring_trig.origin );
	level._minigun_icon = spawn( "script_model", level._minigun_ring_trig.origin );
	level._minigun_icon setmodel( getweaponmodel( "minigun_zm" ) );
	level._minigun_icon._glow_fx = playfxontag( level._effect["ring_glow"], level._minigun_icon, "tag_origin" );
	level._minigun_icon linkto( level._minigun_ring );
	//level._minigun_icon setclientfield( "ring_glowfx", 1 );
	level._minigun_toss_cooldown = 0;
}

ammo_toss_cooldown()
{
	level._ammo_toss_cooldown = 1;

	if ( isdefined( level._ammo_icon ) )
		level._ammo_icon delete();

	waittill_any_or_timeout( 60, "meat_end" );
	playfx( level._effect["poltergeist"], level._ammo_ring_trig.origin );
	level._ammo_icon = spawn( "script_model", level._ammo_ring_trig.origin );
	level._ammo_icon setmodel( "zombie_ammocan" );
	level._ammo_icon._glow_fx = playfxontag( level._effect["ring_glow"], level._ammo_icon, "tag_origin" );
	level._ammo_icon linkto( level._ammo_ring );
	//level._ammo_icon setclientfield( "ring_glowfx", 1 );
	level._ammo_toss_cooldown = 0;
}

watch_save_player()
{
	if ( !isdefined( level._meat_on_team ) )
		return false;

	if ( !isdefined( level._last_person_to_throw_meat ) || level._last_person_to_throw_meat != self )
		return false;

	level._checking_for_save = 1;

	while ( isdefined( level.item_meat ) && ( isdefined( level.item_meat.meat_is_moving ) && level.item_meat.meat_is_moving || isdefined( level.item_meat.meat_is_flying ) && level.item_meat.meat_is_flying ) )
	{
		if ( level._meat_on_team != self._encounters_team )
			break;

		if ( isdefined( level.item_meat ) && ( isdefined( level.item_meat.meat_is_rolling ) && level.item_meat.meat_is_rolling ) && level._meat_on_team == self._encounters_team )
			break;

		wait 0.05;
	}

	if ( level._meat_on_team != self._encounters_team && isdefined( level._last_person_to_throw_meat ) && level._last_person_to_throw_meat == self )
	{
		if ( self maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
		{
			level thread revive_saved_player( self );
			return true;
		}
	}

	level._checking_for_save = 0;
	return false;
}

revive_saved_player( player )
{
	player endon( "disconnect" );
	player iprintlnbold( &"ZOMBIE_PLAYER_SAVED" );
	player playsound( level.zmb_laugh_alias );
	wait 0.25;
	playfx( level._effect["poltergeist"], player.origin );
	playsoundatposition( "zmb_bolt", player.origin );
	earthquake( 0.5, 0.75, player.origin, 1000 );
	player thread maps\mp\zombies\_zm_laststand::auto_revive( player );
	player._saved_by_throw++;
	level._checking_for_save = 0;
}

get_game_module_players( player )
{
	return get_players_on_encounters_team( player._encounters_team );
}

item_meat_spawn( origin )
{
	print( "item_meat_spawn() origin: " + origin );
	level endon( "end_game" );
	org = origin;
	player = getPlayers()[0];
	if ( !isDefined( player ) )
	{
		return;
	}
	player._spawning_meat = 1;
	level.the_meat = player magicgrenadetype( get_gamemode_var( "item_meat_name" ), org, ( 0, 0, 0 ) );
	playsoundatposition( "zmb_spawn_powerup", org );
	level.the_meat._marker = playfxontag( level._effect["meat_marker"], level.the_meat, "tag_origin" );
	wait 0.1;
	player._spawning_meat = undefined;
	level.meat_is_under_the_map = false;
}

init_item_meat( gametype )
{
	set_gamemode_var_once( "item_meat_name", "item_meat_zm" );
	set_gamemode_var_once( "item_meat_model", "t6_wpn_zmb_meat_world" );
	precacheitem( get_gamemode_var( "item_meat_name" ) );
	set_gamemode_var_once( "start_item_meat_name", get_gamemode_var( "item_meat_name" ) );
	level.meat_weaponidx = getweaponindexfromname( get_gamemode_var( "item_meat_name" ) );
	level.meat_pickupsound = getweaponpickupsound( level.meat_weaponidx );
	level.meat_pickupsoundplayer = getweaponpickupsoundplayer( level.meat_weaponidx );
}

meat_intro( launch_spot )
{
	flag_wait( "start_encounters_match_logic" );
	wait 3;
	level thread multi_launch( launch_spot );
	launch_meat( launch_spot );
	drop_meat( launch_spot );
}

launch_meat( launch_spot )
{
	level waittill( "launch_meat" );
	meat = spawn( "script_model", launch_spot );
	meat setmodel( "tag_origin" );
	wait_network_frame();
	playfxontag( level._effect["fw_trail"], meat, "tag_origin" );
	meat playloopsound( "zmb_souls_loop", 0.75 );
	dest = launch_spot;

	while ( isdefined( dest ) && isdefined( dest.target ) )
	{
		new_dest = getstruct( dest.target, "targetname" );
		dest = new_dest;
		dist = distance( new_dest.origin, meat.origin );
		time = dist / 700;
		meat moveto( new_dest.origin, time );

		meat waittill( "movedone" );
	}

	meat playsound( "zmb_souls_end" );
	playfx( level._effect["fw_burst"], meat.origin );
	wait( randomfloatrange( 0.2, 0.5 ) );
	meat playsound( "zmb_souls_end" );
	playfx( level._effect["fw_burst"], meat.origin + ( randomintrange( 50, 150 ), randomintrange( 50, 150 ), randomintrange( -20, 20 ) ) );
	wait( randomfloatrange( 0.5, 0.75 ) );
	meat playsound( "zmb_souls_end" );
	playfx( level._effect["fw_burst"], meat.origin + ( randomintrange( -150, -50 ), randomintrange( -150, 50 ), randomintrange( -20, 20 ) ) );
	wait( randomfloatrange( 0.5, 0.75 ) );
	meat playsound( "zmb_souls_end" );
	playfx( level._effect["fw_burst"], meat.origin );
	meat delete();
}

multi_launch( launch_spot )
{
	wait( randomfloatrange( 0.25, 0.75 ) );
	level notify( "launch_meat" );
}

drop_meat( drop_spot )
{
	meat = spawn( "script_model", drop_spot + vectorscale( ( 0, 0, 1 ), 600.0 ) );
	meat setmodel( "tag_origin" );
	dist = distance( meat.origin, drop_spot );
	time = dist / 400;
	wait 2;
	meat moveto( drop_spot, time );
	wait_network_frame();
	playfxontag( level._effect["fw_drop"], meat, "tag_origin" );

	meat waittill( "movedone" );

	playfx( level._effect["fw_impact"], drop_spot );
	level notify( "reset_meat" );
	meat delete();
}

test_meat_is_under_map()
{
	level.meat_is_under_the_map = false;
	test_model = spawn( "script_model", level.the_meat.origin + ( 0, 0, 50 ) );
	test_model setmodel( "zombie_ammocan" );
	test_model hide();
	test_model physicslaunch( ( 0, 0, 1 ), vectorscale( ( 1, 1, 1 ), 5.0 ) );
	test_model waittill( "stationary" );
	test_model_origin = test_model.origin;
	test_model delete();
	if ( isDefined( level.the_meat ) && level.the_meat.origin[ 2 ] < test_model_origin[ 2 ] )
	{
		level.meat_is_under_the_map = true;
	}
}

last_team_to_touch_the_meat()
{

}

init_splitter_ring()
{

}

wait_for_team_death( team )
{

}

get_players_on_meat_team( team )
{

}

get_alive_players_on_meat_team( team )
{

}