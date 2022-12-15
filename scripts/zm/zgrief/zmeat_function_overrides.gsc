#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\zmeat;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\gametypes_zm\_globallogic_ui;

main()
{
	replaceFunc( maps\mp\zombies\_zm::player_monitor_time_played, ::player_monitor_time_played_override );
	replaceFunc( maps\mp\zombies\_zm_stats::initializeMatchStats, ::initializeMatchStats_override );
	replaceFunc( maps\mp\zombies\_zm_utility::track_players_intersection_tracker, ::track_players_intersection_tracker_override );
	replaceFunc( maps\mp\_utility::setclientfieldtoplayer, ::setclientfieldtoplayer_override );
	replaceFunc( maps\mp\_visionset_mgr::update_clientfields, ::update_clientfields_override );
	replaceFunc( maps\mp\zombies\_zm::watch_rampage_bookmark, ::watch_rampage_bookmark_override );
	replaceFunc( maps\mp\zombies\_zm_spawner::play_ambient_zombie_vocals, ::play_ambient_zombie_vocals_override );
	replaceFunc( maps\mp\zombies\_zm::getFreeSpawnpoint, ::getFreeSpawnpoint_override );
	replaceFunc( maps\mp\gametypes_zm\_globallogic_ui::setupcallbacks, ::setupcallbacks_override );
	replaceFunc( maps\mp\zombies\_zm_perks::perk_machine_spawn_init, ::perk_machine_spawn_init_override );
	level._game_module_player_laststand_callback = ::meat_last_stand_callback;
	level thread on_player_connect();
}

init()
{
	level.autoassign = ::menuautoassign_override;
	level.callbackactordamage = ::actor_damage_override_wrapper;
	level.default_solo_laststandpistol = "m1911_zm";
}

actor_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
	if ( !isdefined( self ) || !isdefined( attacker ) )
		return damage;

	if ( weapon == "tazer_knuckles_zm" || weapon == "jetgun_zm" )
		self.knuckles_extinguish_flames = 1;
	else if ( weapon != "none" )
		self.knuckles_extinguish_flames = undefined;

	if ( isdefined( attacker.animname ) && attacker.animname == "quad_zombie" )
	{
		if ( isdefined( self.animname ) && self.animname == "quad_zombie" )
			return 0;
	}

	if ( !isplayer( attacker ) && isdefined( self.non_attacker_func ) )
	{
		if ( isdefined( self.non_attack_func_takes_attacker ) && self.non_attack_func_takes_attacker )
			return self [[ self.non_attacker_func ]]( damage, weapon, attacker );
		else
			return self [[ self.non_attacker_func ]]( damage, weapon );
	}

	if ( !isplayer( attacker ) && !isplayer( self ) )
		return damage;

	if ( !isdefined( damage ) || !isdefined( meansofdeath ) )
		return damage;

	if ( meansofdeath == "" )
		return damage;

	old_damage = damage;
	final_damage = damage;

	if ( isdefined( self.actor_damage_func ) )
		final_damage = [[ self.actor_damage_func ]]( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
/#
	if ( getdvarint( _hash_5ABA6445 ) )
		println( "Perk/> Damage Factor: " + final_damage / old_damage + " - Pre Damage: " + old_damage + " - Post Damage: " + final_damage );
#/
	if ( attacker.classname == "script_vehicle" && isdefined( attacker.owner ) )
		attacker = attacker.owner;

	if ( isdefined( self.in_water ) && self.in_water )
	{
		if ( int( final_damage ) >= self.health )
			self.water_damage = 1;
	}

	attacker thread maps\mp\gametypes_zm\_weapons::checkhit( weapon );

	if ( attacker maps\mp\zombies\_zm_pers_upgrades_functions::pers_mulit_kill_headshot_active() && is_headshot( weapon, shitloc, meansofdeath ) )
		final_damage *= 2;

	if ( isdefined( level.headshots_only ) && level.headshots_only && isdefined( attacker ) && isplayer( attacker ) )
	{
		if ( meansofdeath == "MOD_MELEE" && ( shitloc == "head" || shitloc == "helmet" ) )
			return int( final_damage );

		if ( is_explosive_damage( meansofdeath ) )
			return int( final_damage );
		else if ( !is_headshot( weapon, shitloc, meansofdeath ) )
			return 0;
	}
	if ( is_melee_weapon( weapon ) )
	{
		final_damage /= 2;
	}
	return int( final_damage );
}

actor_damage_override_wrapper( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
	damage_override = self actor_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );

	if ( damage_override < self.health || !( isdefined( self.dont_die_on_me ) && self.dont_die_on_me ) )
		self finishactordamage( inflictor, attacker, damage_override, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
}

on_player_connect()
{
	while ( true )
	{
		level waittill( "connected", player );
		player thread print_origin();
	}
}

print_origin()
{
	self endon( "disconnect" );
	while ( true )
	{
		if ( self meleeButtonPressed() )
		{
			logprint( self.origin + "\n" );
		}
		wait 0.05;
	}
}

meat_last_stand_callback( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	if ( isdefined( self._has_meat ) && self._has_meat )
		level thread item_meat_drop( self.origin, self._encounters_team );
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
	if ( !isDefined( self ) || !isPlayer( self ) || self isTestClient() || !isDefined( field_name ) || !isDefined( value ) )
	{
		return;
	}
	codesetplayerstateclientfield( self, field_name, value );
}

update_clientfields_override( player, type_struct )
{
	if ( !isDefined( player ) || !isPlayer( player ) || player isTestClient() || !isDefined( type_struct ) )
	{
		return;
	}
    name = player get_first_active_name( type_struct );
    player setclientfieldtoplayer( type_struct.cf_slot_name, type_struct.info[name].slot_index );

    if ( 1 < type_struct.cf_lerp_bit_count )
        player setclientfieldtoplayer( type_struct.cf_lerp_name, type_struct.info[name].state.players[player._player_entnum].lerp );
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

getFreeSpawnpoint_override( spawnpoints, player )
{
	if ( !isdefined( spawnpoints ) )
	{
		return undefined;
	}
	//If we are using the script_int system to make the starting teams spawn facing each other. 
	//We only spawn players if their team script_int matches the spawnpoint script_int. 
	//Treyarch's normal spawnpoints do this to a degree.
	if ( is_true( level.spawnpoint_system_using_script_ints ) )
	{
		foreach ( spawnpoint in spawnpoints )
		{
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
	}
	else
	{
		foreach ( spawnpoint in spawnpoints )
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
	//If we aren't using the script_int system or we are and we ran out of spawnpoints due to many players joining and leaving try to free up old spawnpoints.
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
			if ( is_true( level.spawnpoint_system_using_script_ints ) )
			{
				if ( spawnpoint.script_int == self.spawnpoint_desired_script_int )
				{
					spawnpoint.player_name = self.name;
					return spawnpoint;
				}
			}
			else 
			{
				spawnpoint.player_name = self.name;
				return spawnpoint;
			}
		}
	}
	//This shouldn't happen but if it does something went wrong.
	print( "getFreeSpawnpoint() is returning a failsafe spawnpoint THIS SHOULD NOT HAPPEN!" );
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
		game["spawns_randomized"] = true;
		random_chance = randomint( 100 );

		if ( random_chance > 50 )
			set_game_var( "side_selection", 1 );
		else
			set_game_var( "side_selection", 2 );
	}
	side_selection = get_game_var( "side_selection" );
	if ( side_selection == 1 ) 
	{
		if ( assignment == "allies" )
		{
			side_selection = 2;
		}
	}
	else if ( side_selection == 2 )
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

perk_machine_spawn_init_override()
{
	return;
}