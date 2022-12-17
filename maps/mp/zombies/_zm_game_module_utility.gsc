// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_game_module_meat_utility;
#include maps\mp\zombies\_zm_game_module_meat;

hud_init()
{
	hudelem_server_add( "meat_score_A", ::meat_score_axis );
	hudelem_server_add( "meat_score_B", ::meat_score_allies );
	hudelem_server_add( "meat_score_A_icon", ::meat_score_axis_icon );
	hudelem_server_add( "meat_score_B_icon", ::meat_score_allies_icon );
	//hudelem_server_add( "meat_countdown_timer", ::meat_countdown );
	set_server_hud_alpha( getDvarIntDefault( "hud_scoreboard", 1 ) );
}

hudelem_server_add( name, hudelem_constructor )
{
	if ( !isDefined( level.server_hudelem_funcs ) )
	{
		level.server_hudelem_funcs = [];
	}
	if ( !isDefined( level.server_hudelems ) )
	{
		level.server_hudelems = [];
	}
	level.server_hudelem_funcs[ name ] = hudelem_constructor;
	level.server_hudelems[ name ] = [[ hudelem_constructor ]]();
}

set_server_hud_alpha( alpha )
{
	level.server_hudelems[ "meat_score_A" ].alpha = alpha;
	level.server_hudelems[ "meat_score_B" ].alpha = alpha;
	level.server_hudelems[ "meat_score_A_icon" ].alpha = alpha;
	level.server_hudelems[ "meat_score_B_icon" ].alpha = alpha;
}

meat_score_allies()
{
	meat_score_hud = newhudelem();
	meat_score_hud.x += 240;
	meat_score_hud.y += 20;
	meat_score_hud.fontscale = 2.5;
	meat_score_hud.color = ( 0.423, 0.004, 0 );
	meat_score_hud.alpha = 1;
	meat_score_hud.hidewheninmenu = 1;
	meat_score_hud setValue( 0 );
	return meat_score_hud;
}

meat_score_allies_icon()
{
	mapname = getDvar( "mapname" );
	color = undefined;
	if ( mapname == "zm_prison" )
	{
		icon = "faction_guards";
	}
	else if ( mapname == "zm_highrise" )
	{
		icon = "faction_highrise";
	}
	else if ( mapname == "zm_tomb" )
	{
		icon = "faction_tomb";
	}
	else 
	{
		icon = "faction_cdc";
	}
	team_shader2 = createservericon( icon, 35, 35 );
	team_shader2.x += -110;
	team_shader2.y += -20;
	team_shader2.hideWhenInMenu = 1;
	team_shader2.alpha = 1;
	if ( isDefined( color ) )
	{
		team_shader2.color = color;
	}
	return team_shader2;
}

meat_score_axis()
{
	meat_score_hud = newhudelem();
	meat_score_hud.x += 440;
	meat_score_hud.y += 20;
	meat_score_hud.fontscale = 2.5;
	meat_score_hud.color = ( 0.423, 0.004, 0 );
	meat_score_hud.alpha = 1;
	meat_score_hud.hidewheninmenu = 1;
	meat_score_hud setValue( 0 );
	return meat_score_hud;
}

meat_score_axis_icon()
{
	mapname = getDvar( "mapname" );
	color = undefined;
	if ( mapname == "zm_prison" )
	{
		icon = "faction_inmates";
	}
	else if ( mapname == "zm_highrise" )
	{
		icon = "faction_highrise";
	}
	else if ( mapname == "zm_tomb" )
	{
		icon = "faction_tomb";
	}
	else 
	{
		icon = "faction_cia";
	}
	team_shader1 = createservericon( icon, 35, 35 );
	team_shader1.x += 90;
	team_shader1.y += -20;
	team_shader1.hideWhenInMenu = 1;
	team_shader1.alpha = 1;
	if ( isDefined( color ) )
	{
		team_shader1.color = color;
	}
	return team_shader1;
}

show_grief_hud_msg( msg, msg_parm, offset, delay )
{
	if(!isDefined(delay))
	{
		self notify( "show_grief_hud_msg" );
	}
	else
	{
		self notify( "show_grief_hud_msg2" );
	}

	self endon( "disconnect" );

	zgrief_hudmsg = newclienthudelem( self );
	zgrief_hudmsg.alignx = "center";
	zgrief_hudmsg.aligny = "middle";
	zgrief_hudmsg.horzalign = "center";
	zgrief_hudmsg.vertalign = "middle";
	zgrief_hudmsg.sort = 1;
	zgrief_hudmsg.y -= 130;

	if ( self issplitscreen() )
	{
		zgrief_hudmsg.y += 70;
	}

	if ( isDefined( offset ) )
	{
		zgrief_hudmsg.y += offset;
	}

	zgrief_hudmsg.foreground = 1;
	zgrief_hudmsg.fontscale = 5;
	zgrief_hudmsg.alpha = 0;
	zgrief_hudmsg.color = ( 1, 1, 1 );
	zgrief_hudmsg.hidewheninmenu = 1;
	zgrief_hudmsg.font = "default";

	zgrief_hudmsg endon( "death" );

	zgrief_hudmsg thread show_grief_hud_msg_cleanup(self, delay);

	while ( isDefined( level.hostmigrationtimer ) )
	{
		wait 0.05;
	}

	if(isDefined(delay))
	{
		wait delay;
	}

	if ( isDefined( msg_parm ) )
	{
		zgrief_hudmsg settext( msg, msg_parm );
	}
	else
	{
		zgrief_hudmsg settext( msg );
	}

	zgrief_hudmsg changefontscaleovertime( 0.25 );
	zgrief_hudmsg fadeovertime( 0.25 );
	zgrief_hudmsg.alpha = 1;
	zgrief_hudmsg.fontscale = 2;

	wait 3.25;

	zgrief_hudmsg changefontscaleovertime( 1 );
	zgrief_hudmsg fadeovertime( 1 );
	zgrief_hudmsg.alpha = 0;
	zgrief_hudmsg.fontscale = 5;

	wait 1;

	if ( isDefined( zgrief_hudmsg ) )
	{
		zgrief_hudmsg destroy();
	}
}

show_grief_hud_msg_cleanup(player, delay)
{
	self endon( "death" );

	self thread show_grief_hud_msg_cleanup_restart_round();
	self thread show_grief_hud_msg_cleanup_end_game();

	if(!isDefined(delay))
	{
		player waittill( "show_grief_hud_msg" );
	}
	else
	{
		player waittill( "show_grief_hud_msg2" );
	}

	if ( isDefined( self ) )
	{
		self destroy();
	}
}

show_grief_hud_msg_cleanup_restart_round()
{
	self endon( "death" );

	level waittill( "restart_round" );

	if ( isDefined( self ) )
	{
		self destroy();
	}
}

show_grief_hud_msg_cleanup_end_game()
{
	self endon( "death" );

	level waittill( "end_game" );

	if ( isDefined( self ) )
	{
		self destroy();
	}
}

move_ring( ring )
{
	positions = getstructarray( ring.target, "targetname" );
	level endon( "end_game" );

	while ( true )
	{
		wait 0.05;
		positions = array_randomize( positions );
		foreach ( position in positions )
		{
			self moveto( position.origin, randomintrange( 15, 23 ) );

			self waittill( "movedone" );
		}
	}
}

rotate_ring( forward )
{
	level endon( "end_game" );
	dir = -360;

	if ( forward )
		dir = 360;

	while ( true )
	{
		self rotateyaw( dir, 9 );
		wait 9;
	}
}

connect_point_on_polygon( point_a, point_b )
{
	if ( !isDefined( level._polygon_lines ) )
	{
		level._polygon_lines = [];
	}
	level._polygon_lines[ level._polygon_lines.size ] = [];
	level._polygon_lines[ level._polygon_lines.size - 1 ][ 0 ] = point_a;
	level._polygon_lines[ level._polygon_lines.size - 1 ][ 1 ] = point_b;
}

add_point_to_meat_playable_bounds( point )
{
	if ( !isDefined( level.meat_playable_bounds ) )
	{
		level.meat_playable_bounds = [];
	}
	level.meat_playable_bounds[ level.meat_playable_bounds.size ] = point;
}

add_point_to_meat_team_bounds( team, point )
{
	if ( !isDefined( level.meat_team_bounds ) )
	{
		level.meat_team_bounds = [];
	}
	if ( !isDefined( level.meat_team_bounds[ team ] ) )
	{
		level.meat_team_bounds[ team ] = [];
	}
	level.meat_team_bounds[ team ][ level.meat_team_bounds[ team ].size ] = point;
}

on_line( line, point )
{
	// Check whether p is on the line or not
	if ( point[ 0 ] <= max( line[ 0 ][ 0 ], line[ 1 ][ 0 ] )
		&& point[ 0 ] <= min( line[ 0 ][ 0 ], line[ 1 ][ 0 ] )
		&& ( point[ 1 ] <= max( line[ 0 ][ 1 ], line[ 1 ][ 1 ] )
		&& point[ 1 ] <= min( line[ 0 ][ 1 ], line[ 1 ][ 1 ] ) ) )
	{
		return true;
	}
	return false;
}

direction( point_a, point_b, point_c )
{
	val1 = point_b[ 1 ] - point_a[ 1 ];
	val2 = point_c[ 0 ] - point_b[ 0 ];
	val3 = point_b[ 0 ] - point_a[ 0 ];
	val4 = point_c[ 1 ] - point_b[ 1 ];
	val = ( val1 * val2 ) - ( val3 * val4 );

	if ( val == 0 )
	{
		// Colinear
		return 0;
	}
	else if ( val < 0 )
	{
		// Anti-clockwise direction
		return 2;
	}
	// Clockwise direction
	return 1;
}

isIntersect( line1, line2 )
{
	// Four direction for two lines and points of other line
	dir1 = direction( line1[ 0 ], line1[ 1 ], line2[ 0 ] );
	dir2 = direction( line1[ 0 ], line1[ 1 ], line2[ 1 ] );
	dir3 = direction( line2[ 0 ], line2[ 1 ], line1[ 0 ] );
	dir4 = direction( line2[ 0 ], line2[ 1 ], line1[ 1 ] );

	// When intersecting
	if ( dir1 != dir2 && dir3 != dir4 )
	{
		return true;
	}
	// When p2 of line2 are on the line1
	if ( dir1 == 0 && on_line( line1, line2[ 0 ] ) )
	{
		return true;
	}
	// When p1 of line2 are on the line1
	if ( dir2 == 0 && on_line( line1, line2[ 1 ] ) )
	{
		return true;
	}
	// When p2 of line1 are on the line2
	if ( dir3 == 0 && on_line( line2, line1[ 0 ] ) )
	{
		return true;
	}
	// When p1 of line1 are on the line2
	if ( dir4 == 0 && on_line( line2, line1[ 1 ] ) )
	{
		return true;
	}
	return false;
}

checkInside( polygon, sides, point )
{

	// When polygon has less than 3 edge, it is not polygon
	if ( sides < 3 )
		return false;

	// Create a point at infinity, y is same as point p
	exline = [];
	exline[ 0 ] = point;
	exline[ 1 ] = ( 99999, point[ 1 ], 0 );
	count = 0;
	i = 0;
	do {

		// Forming a line from two consecutive points of
		// poly
		side = [];
		side[ 0 ] = polygon[ i ];
		side[ 1 ] = polygon[ ( i + 1 ) % sides ];
		if ( isIntersect( side, exline ) ) 
		{

			// If side is intersects exline
			if ( direction( side[ 0 ], point, side[ 1 ] ) == 0)
				return on_line( side, point );
			count++;
		}
		i = ( i + 1 ) % sides;
	} while ( i != 0 );

	// When count is odd
	return count & 1;
}

// Driver code
check_point_is_in_polygon( polygon, point )
{
	// Function call
	if ( checkInside( polygon, polygon.size, point ) )
	{
		//print( "Point is inside." );
		return true;
	}
	else
	{
		//print( "Point is outside." );
		return false;
	}
}