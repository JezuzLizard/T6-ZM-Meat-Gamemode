// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_game_module_meat_utility;
#include maps\mp\zombies\_zm_game_module_meat;

move_ring( ring )
{
	positions = getstructarray( ring.target, "targetname" );
	positions = array_randomize( positions );
	level endon( "end_game" );

	while ( true )
	{
		foreach ( position in positions )
		{
			self moveto( position.origin, randomintrange( 30, 45 ) );

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
	if ( !isDefined( level.bounds_point_pairs ) )
	{
		level.bounds_point_pairs = [];
	}
	level._polygon_lines[ level._polygon_lines.size ] = [];
	level._polygon_lines[ level._polygon_lines.size - 1 ][ 0 ] = point_a;
	level._polygon_lines[ level._polygon_lines.size - 1 ][ 1 ] = point_b;
}

on_line( line, point )
{
	// Check whether p is on the line or not
	if ( point[ 0 ] <= max( line[ 0 ][ 0 ], line[ 1 ][ 0 ] )
		&& point[ 0 ] <= min( line[ 0 ][ 0 ], line[ 1 ][ 0 ] )
		&& ( point[ 1 ] <= max( line[ 0 ][ 1 ], line[ 1 ][ 1 ] )
		&& point[ 1 ] <= min( line[ 0 ][ 1 ], line[ 1 ][ 1 ] ) ) )
		return true;

	return false;
}

direction( point_a, point_b, point_c )
{
	val = ( point_b[ 1 ] - point_a[ 1 ] ) * ( point_c[ 0 ] - point_b[ 0 ] )
			- ( point_b[ 0 ] - point_a[ 0 ] ) * ( point_c[ 1 ] - point_b[ 1 ] );

	if ( val == 0 )

		// Colinear
		return 0;

	else if ( val < 0 )

		// Anti-clockwise direction
		return 2;

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
		return true;

	// When p2 of line2 are on the line1
	if ( dir1 == 0 && on_line( line1, line2[ 0 ] ) )
		return true;

	// When p1 of line2 are on the line1
	if ( dir2 == 0 && on_line( line1, line2[ 1 ] ) )
		return true;

	// When p2 of line1 are on the line2
	if ( dir3 == 0 && on_line( line2, line1[ 0 ] ) )
		return true;

	// When p1 of line1 are on the line2
	if ( dir4 == 0 && on_line( line2, line1[ 1 ] ) )
		return true;

	return false;
}

checkInside( polygon, sides, point )
{

	// When polygon has less than 3 edge, it is not polygon
	if ( sides < 3 )
		return false;

	// Create a point at infinity, y is same as point p
	//exline = { point, { 99999, point[ 1 ] } };
	exline = [];
	exline[ 0 ] = point;
	exline[ 1 ] = ( 99999, point[ 1 ], 0 );
	count = 0;
	i = 0;
	do {

		// Forming a line from two consecutive points of
		// poly
		//side = { polygon[ i ], polygon[ ( i + 1 ) % sides] };
		side = [];
		side[ 0 ] = polygon[ i ];
		side[ 1 ] = polygon[ i + 1 ] % sides;
		if ( isIntersect( side, exline ) ) {

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
	//Point polygon[] = { { 0, 0 }, { 10, 0 }, { 10, 10 }, { 0, 10 } };
	//polygon = level._polygon_lines;
	//Point p = { 5, 3 };
	//int n = 4; //num sides

	// Function call
	if ( checkInside( polygon, polygon.size, point ) )
		print( "Point is inside." );
	else
		print( "Point is outside." );
}