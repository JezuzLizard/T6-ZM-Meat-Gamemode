#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include common_scripts\utility;

init()
{
	if ( true )
	{
		return;
	}
	level._meat_start_points = [];
	level._meat_start_points[ "A" ] = ( 1189.16, -514.579, -66.875 );
	level._meat_start_points[ "B" ] = ( 1648.84, -319.649, -66.875 );
	while ( true )
	{
		wait 1;
		starting_team = ( cointoss() ? "A" : "B" );
		level.meat_starting_team = starting_team;
		print_vector( level.meat_starting_team );
	}
}

print_vector( team )
{
	print( "item_meat_spawn() team: " + team + " org: " + level._meat_start_points[ team ] );
}

print_zone()
{
	while ( true )
	{
		if ( self meleeButtonPressed() )
		{
			print( "Current zone: " + self maps\mp\zombies\_zm_zonemgr::get_player_zone() );
			while ( self meleeButtonPressed() )
			{
				wait 0.05;
			}
		}
		wait 0.05;
	}
}