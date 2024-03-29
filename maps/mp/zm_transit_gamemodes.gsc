#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zm_transit_utility;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_game_module_meat_utility;
#include maps\mp\zombies\_zm_game_module_utility;
#include scripts\zm\zm_transit_meat_tunnel;
#include scripts\zm\zm_transit_meat_town;
#include scripts\zm\zm_transit_meat_farm;

init()
{
	// Mode global map specific pre-init, precache and main functions in the add_map_gamemode calls.
	
	// PRECACHE FUNCTIONS ARE NOT CALLED ON A MAP RESTART - ANY LOGIC IN THEM WILL NOT BE RUN ON ROUND CHANGE IN ROUND BASED GAMES.
	
	add_map_gamemode("zclassic", maps\mp\zm_transit::zclassic_preinit, undefined, undefined);
//	add_map_gamemode("zcleansed", maps\mp\zm_transit::zcleansed_preinit, undefined, undefined);
//	add_map_gamemode("zcontainment", maps\mp\zm_transit::zcontainment_preinit, undefined, undefined);
//	add_map_gamemode("zdeadpool", maps\mp\zm_transit::zdeadpool_preinit, undefined, undefined);
	add_map_gamemode("zgrief", maps\mp\zm_transit::zgrief_preinit, undefined, undefined);
	add_map_gamemode("zmeat",  maps\mp\zm_transit::zmeat_preinit, undefined, undefined);
//	add_map_gamemode("znml", maps\mp\zm_transit::znml_preinit, undefined, undefined);
//	add_map_gamemode("zpitted", maps\mp\zm_transit::zpitted_preinit, undefined, undefined);
//	add_map_gamemode("zrace", maps\mp\zm_transit::zrace_preinit, undefined, undefined);
	add_map_gamemode("zstandard", maps\mp\zm_transit::zstandard_preinit, undefined, undefined);
//	add_map_gamemode("zturned", maps\mp\zm_transit::zturned_preinit, undefined, undefined);
	
	// Mode and location specific init and main functions in the add_map_location_gamemode calls.
	add_map_location_gamemode("zclassic", "transit", maps\mp\zm_transit_classic::precache, maps\mp\zm_transit_classic::main);	

	add_map_location_gamemode("zstandard", "transit", maps\mp\zm_transit_standard_station::precache, maps\mp\zm_transit_standard_station::main);
	add_map_location_gamemode("zstandard", "farm", maps\mp\zm_transit_standard_farm::precache, maps\mp\zm_transit_standard_farm::main);
	add_map_location_gamemode("zstandard", "town", maps\mp\zm_transit_standard_town::precache, maps\mp\zm_transit_standard_town::main);

//	add_map_location_gamemode("znml", "cornfield", maps\mp\zm_transit_nml_cornfield::precache, maps\mp\zm_transit_nml_cornfield::main);
//	add_map_location_gamemode("znml", "town", maps\mp\zm_transit_nml_town::precache, maps\mp\zm_transit_nml_town::main);

	add_map_location_gamemode("zmeat", "tunnel", maps\mp\zm_transit_grief_town::precache, maps\mp\zm_transit_grief_town::main);
	add_map_location_gamemode("zmeat", "town", ::zmeat_town_precache, ::zmeat_town_main);
	add_map_location_gamemode("zmeat", "farm", maps\mp\zm_transit_grief_farm::precache, maps\mp\zm_transit_grief_farm::main);
	
//	add_map_location_gamemode("zrace", "tunnel", maps\mp\zm_transit_race_tunnel::precache, maps\mp\zm_transit_race_tunnel::main);
//	add_map_location_gamemode("zrace", "town", maps\mp\zm_transit_race_town::precache, maps\mp\zm_transit_race_town::main);
//	add_map_location_gamemode("zrace", "farm", maps\mp\zm_transit_race_farm::precache, maps\mp\zm_transit_race_farm::main);
//	add_map_location_gamemode("zrace", "power", maps\mp\zm_transit_race_power::precache, maps\mp\zm_transit_race_power::main);

	add_map_location_gamemode("zgrief", "transit", maps\mp\zm_transit_grief_station::precache, maps\mp\zm_transit_grief_station::main);
	add_map_location_gamemode("zgrief", "farm", maps\mp\zm_transit_grief_farm::precache, maps\mp\zm_transit_grief_farm::main);
	add_map_location_gamemode("zgrief", "town", ::zmeat_town_precache, ::zmeat_town_main);

//	add_map_location_gamemode("zcleansed", "farm", maps\mp\zm_transit_turned_farm::precache, maps\mp\zm_transit_turned_farm::main);
//	add_map_location_gamemode("zcleansed", "cornfield", maps\mp\zm_transit_turned_cornfield::precache, maps\mp\zm_transit_turned_cornfield::main);
//	add_map_location_gamemode("zcleansed", "diner", maps\mp\zm_transit_turned_diner::precache, maps\mp\zm_transit_turned_diner::main);
//	add_map_location_gamemode("zcleansed", "town", maps\mp\zm_transit_turned_town::precache, maps\mp\zm_transit_turned_town::main);

	scripts\zm\_gametype_setup::add_struct_location_gamemode_func( "grief", "town", ::zmeat_town_struct_init );
}

zmeat_town_struct_init()
{
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ] = [];
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ] = [];
	coordinates_team1 = array( ( 1098.57, -172.707, -48.5673 ), ( 1225.5, -448.194, -61.875 ), ( 1332.15, -611.788, -61.1024 ), ( 1544.77, -725.784, -54.5458 ) );
	angles_team1 = array( ( 0, 30.6696, 0 ), ( 0, 31.1914, 0 ), ( 0, 41.1835, 0 ), ( 0, 98.2959, 0 ) );
	for ( i = 0; i < coordinates_team1.size; i++ )
	{
		register_map_initial_spawnpoint( coordinates_team1[ i ], angles_team1[ i ], 1 );
	}
	coordinates_team2 = array( ( 1322.92, -4.02464, -61.875 ), ( 1479.94, -164.92, -61.875 ), ( 1682.14, -322.66, -61.875 ), ( 1716.55, -510.453, -54.7499 ) );
	angles_team2 = array( ( 0, -133.95, 0 ), ( 0, -138.086, 0 ), ( 0, -149.803, 0 ), ( 0, -158.592, 0 ) );
	for ( i = 0; i < coordinates_team2.size; i++ )
	{
		register_map_initial_spawnpoint( coordinates_team2[ i ], angles_team2[ i ], 2 );
	}
}

register_map_initial_spawnpoint( spawnpoint_coordinates, spawnpoint_angles, script_int )
{
	spawnpoint_struct = spawnStruct();
	spawnpoint_struct.origin = spawnpoint_coordinates;
	if ( isDefined( spawnpoint_angles ) )
	{
		spawnpoint_struct.angles = spawnpoint_angles;
	}
	else 
	{
		spawnpoint_struct.angles = ( 0, 0, 0 );
	}
	spawnpoint_struct.radius = 32;
	spawnpoint_struct.script_noteworthy = "initial_spawn";
	spawnpoint_struct.script_int = script_int;
	spawnpoint_struct.script_string = getDvar( "g_gametype" ) + "_" + getDvar( "ui_zm_mapstartlocation" );
	spawnpoint_struct.locked = 0;
	player_respawn_point_size = level.struct_class_names[ "targetname" ][ "player_respawn_point" ].size;
	player_initial_spawnpoint_size = level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ].size;
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ][ player_respawn_point_size ] = spawnpoint_struct;
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ][ player_initial_spawnpoint_size ] = spawnpoint_struct;
}

zmeat_town_precache()
{
	precacheModel( "collision_player_wall_512x512x10" );
	precacheModel( "p6_zm_barrier_pedestrian" );
	precacheModel( "collision_player_wall_128x128x10" );
	precacheModel( "collision_player_wall_256x256x10" );
}

zmeat_town_main()
{
	//wait(.5); //wait a small bit to make sure everyone is connected and running before kicking off 
	setup_standard_objects_override( "town" );
	level._meat_location = "town";	
	//level._meat_start_point = random(getstructarray("meat_2_spawn_points","targetname")).origin;//(4352, -13824, 224);
	level._meat_start_points = [];
	level._meat_start_points[ "B" ] = ( 1189.16, -514.579, -56.875 );
	level._meat_start_points[ "A" ] = ( 1648.84, -319.649, -56.875 );
	register_zmeat_riser_location( ( 1583.74, 665.528, -61.875 ), "A" );
	register_zmeat_riser_location( ( 1239.35, 641.686, -55.875 ), "A" );
	register_zmeat_riser_location( ( 1933.47, -525.591, -61.875 ), "A" );
	register_zmeat_riser_location( ( 1973.37, -312.483, -60.0627 ), "A" );
	register_zmeat_riser_location( ( 824.812, -405.236, -61.875 ), "B" );
	register_zmeat_riser_location( ( 856.151, -649.651, -55.875 ), "B" );
	register_zmeat_riser_location( ( 1618.35, -1215.13, -61.875 ), "B" );
	register_zmeat_riser_location( ( 1327.61, -1128, -61.875 ), "B" );

	level._meat_location_center = ( 1425.77, -377.987, -67.875 );
	level.meat_under_the_map_limit = ( 0, 0, -80 );

	create_meat_playable_bounds_polygon();
	create_meat_team_a_bounds();
	create_meat_team_b_bounds();

	flag_clear("zombie_drop_powerups");
	level.custom_intermission  = ::town_meat_intermission;
	level.zombie_vars["zombie_intermission_time"] = 5;
	level._supress_survived_screen = 1;
	level thread maps\mp\gametypes_zm\zmeat::item_meat_clear();
	level thread spawn_player_barriers();
	level.player_out_of_playable_area_monitor = false;
}

town_meat_intermission()
{
	self maps\mp\zombies\_zm_game_module::game_module_custom_intermission("town_meat_intermission_cam");
}

setup_standard_objects_override( location )
{
	structs = getstructarray( "game_mode_object" );

	foreach ( struct in structs )
	{
		if ( isdefined( struct.script_noteworthy ) && struct.script_noteworthy != location )
			continue;

		if ( isDefined( struct.script_parameters ) )
		{
			if ( struct.script_parameters == "p6_zm_barrier_pedestrian" || struct.script_parameters == "p6_zm_barrier_pedestrian_grp" )
			{
				continue;
			}
			if ( struct.script_parameters == "p6_zm_scoreboard_on" )
			{
				continue;
			}
		}

		if ( isdefined( struct.script_string ) )
		{
			keep = 0;
			tokens = strtok( struct.script_string, " " );

			foreach ( token in tokens )
			{
				if ( token == "meat" && token != "zstandard" )
				{
					keep = 1;
					continue;
				}

				if ( token == "zstandard" )
					keep = 1;
			}

			if ( !keep )
				continue;
		}

		barricade = spawn( "script_model", struct.origin );
		barricade.angles = struct.angles;
		barricade setmodel( struct.script_parameters );
	}

	objects = getentarray();

	foreach ( object in objects )
	{
		if ( !object is_survival_object() )
			continue;

		if ( isdefined( object.spawnflags ) && object.spawnflags == 1 && object.classname != "trigger_multiple" )
			object connectpaths();

		object delete();
	}

	if ( isdefined( level._classic_setup_func ) )
		[[ level._classic_setup_func ]]();
}

spawn_player_barriers()
{
	while ( !getDvarIntDefault( "zmeat_spawn_barriers", 1 ) )
		wait 1;

	/*
		Side A next to the right most lava pit begin
	*/
	collision_group1 = [];
	initial_point = ( 1131.64, 248.733, -39.875 );
	collision_group1_angles = ( 0, -15.7128, 0 );
	start_point = get_next_point( initial_point, collision_group1_angles, 256 );
	collision_group1[ 0 ] = spawn( "script_model", start_point );	
	collision_group1[ 0 ] setModel( "collision_player_wall_512x512x10" );
	collision_group1[ 0 ].angles = collision_group1_angles;
	collision_group1[ 1 ] = spawn( "script_model", get_next_point( start_point, collision_group1_angles, 512 ) );	
	collision_group1[ 1 ] setModel( "collision_player_wall_512x512x10" );
	collision_group1[ 1 ].angles = collision_group1_angles;
	
	barrier_group1 = [];
	next_point = undefined;
	initial_point = ( 1131.64, 248.733, -55.875 );
	for ( i = 0; i < 7; i++ )
	{
		distance_apart = 96;
		if ( i == 0 )
			next_point = get_next_point( initial_point, collision_group1_angles, distance_apart / 2 );
		else 
			next_point = get_next_point( next_point, collision_group1_angles, distance_apart );
		
		barrier_group1[ i ] = spawn( "script_model", next_point );
		barrier_group1[ i ] setModel( "p6_zm_barrier_pedestrian" );
		barrier_group1[ i ].angles = collision_group1_angles;
	}

	/*
		Side A behind the center lava pit between two cars begin
	*/
	collision_group2 = [];
	initial_point = ( 1728.35, -540.213, -55.1496 );
	collision_group2_angles = ( 0, 90.5328, 0 );
	start_point = get_next_point( initial_point, collision_group2_angles, 64 );
	collision_group2[ 0 ] = spawn( "script_model", start_point );
	collision_group2[ 0 ] setModel( "collision_player_wall_128x128x10" );
	collision_group2[ 0 ].angles = collision_group2_angles;
	barrier_group2 = [];
	barrier_group2[ 0 ] = spawn( "script_model", start_point );
	barrier_group2[ 0 ] setModel( "p6_zm_barrier_pedestrian" );
	barrier_group2[ 0 ].angles = collision_group2_angles;

	/* 
		Side B between gap before olympia wallbuy begin
	*/
	collision_group3 = [];
	initial_point = ( 1622.55, -1014.79, -42.4881 );
	collision_group3_angles = ( 0, 170.475, 0 );
	start_point = get_next_point( initial_point, collision_group3_angles, 64 );
	collision_group3[ 0 ] = spawn( "script_model", start_point );
	collision_group3[ 0 ] setModel( "collision_player_wall_128x128x10" );
	collision_group3[ 0 ].angles = collision_group3_angles;
	barrier_group3 = [];
	barrier_group3[ 0 ] = spawn( "script_model", start_point );
	barrier_group3[ 0 ] setModel( "p6_zm_barrier_pedestrian" );
	barrier_group3[ 0 ].angles = collision_group3_angles;

	/*
		Side B behind the center lava pit between a car and a bench begin
	*/

	collision_group4 = [];
	initial_point = ( 956.384, -659.012, -55.875 );
	collision_group4_angles = ( 0, 82.4414, 0 );
	start_point = get_next_point( initial_point, collision_group4_angles, 128 );
	collision_group4[ 0 ] = spawn( "script_model", start_point );
	collision_group4[ 0 ] setModel( "collision_player_wall_256x256x10" );
	collision_group4[ 0 ].angles = collision_group4_angles;
	barrier_group4 = [];
	for ( i = 0; i < 3; i++ )
	{
		distance_apart = 96;
		if ( i == 0 )
			next_point = get_next_point( initial_point, collision_group4_angles, distance_apart / 2 );
		else 
			next_point = get_next_point( next_point, collision_group4_angles, distance_apart );
		
		barrier_group4[ i ] = spawn( "script_model", next_point );
		barrier_group4[ i ] setModel( "p6_zm_barrier_pedestrian" );
		barrier_group4[ i ].angles = collision_group4_angles;
	}
	
	/*
		Middle barrier separating sides
	*/

	collision_group5 = [];
	initial_point = ( 1120.58, 11.8504, -67.875 );
	collision_group5_angles = ( 0, -52.229, 0 );
	start_point = get_next_point( initial_point, collision_group5_angles, 256 );
	collision_group5[ 0 ] = spawn( "script_model", start_point );	
	collision_group5[ 0 ] setModel( "collision_player_wall_512x512x10" );
	collision_group5[ 0 ].angles = collision_group5_angles;
	collision_group5[ 1 ] = spawn( "script_model", get_next_point( start_point, collision_group5_angles, 512 ) );	
	collision_group5[ 1 ] setModel( "collision_player_wall_512x512x10" );
	collision_group5[ 1 ].angles = collision_group5_angles;
	barrier_group5 = [];
	for ( i = 0; i < 7; i++ )
	{
		distance_apart = 98;
		if ( i == 0 )
			next_point = get_next_point( initial_point, collision_group5_angles, distance_apart / 2 );
		else 
			next_point = get_next_point( next_point, collision_group5_angles, distance_apart );
		
		barrier_group5[ i ] = spawn( "script_model", next_point );
		barrier_group5[ i ] setModel( "p6_zm_barrier_pedestrian" );
		barrier_group5[ i ].angles = collision_group5_angles;
	}

	/*
	collisions = [];
	collisions[ 0 ] = spawn( "script_model", ( 1188.43, -64.4402, -55.875 ) );
	collisions[ 0 ] setModel( "collision_player_wall_512x512x10" );
	collisions[ 0 ].angles = ( 0, -138 + 90, 0 );
	collisions[ 1 ] = spawn( "script_model", ( 1396.48, -335.717, -67.875 ) );
	collisions[ 1 ] setModel( "collision_player_wall_512x512x10" );
	collisions[ 1 ].angles = ( 0, -139 + 90, 0 );
	collisions[ 2 ] = spawn( "script_model", ( 1493.65, -471.943, -67.875 ) );
	collisions[ 2 ] setModel( "collision_player_wall_512x512x10" );
	collisions[ 2 ].angles = ( 0, -149 + 90, 0 );
	collisions[ 3 ] = spawn( "script_model", ( 1751.49, -492.548, -58.1949 ) ); //back of A team side opposite the middle barrier
	collisions[ 3 ] setModel( "collision_player_wall_512x512x10" );
	collisions[ 3 ].angles = ( 0, 178 + 90, 0 );
	collisions[ 4 ] = spawn( "script_model", ( 1544.17, 451.856, -61.875 ) );
	collisions[ 4 ] setModel( "collision_player_wall_512x512x10" );
	collisions[ 4 ].angles = ( 0, -101 + 90, 0 );
	collisions[ 5 ] = spawn( "script_model", ( 1059.43, -546.414, -61.875 ) ); //back of B team side opposite the middle barrier
	collisions[ 5 ] setModel( "collision_player_wall_512x512x10" );
	collisions[ 5 ].angles = ( 0, -3 + 90, 0 );
	collisions[ 6 ] = spawn( "script_model", ( 1527.66, -1025.5, -46.03 ) ); //right side of B team
	collisions[ 6 ] setModel( "collision_player_wall_512x512x10" );
	collisions[ 6 ].angles = ( 0, 81 + 90, 0 );
	barriers = [];
	for ( i = 0; i < collisions.size; i++ )
	{
		barriers[ i ] = spawn( "script_model", collisions[ i ].origin );
		barriers[ i ] setModel( "p6_zm_barrier_pedestrian" );
		barriers[ i ].angles = collisions[ i ].angles;
	}
	*/
}

register_zmeat_riser_location( origin, side )
{
	if ( !isDefined( level._zmeat_zombie_spawn_locations ) )
	{
		level._zmeat_zombie_spawn_locations = [];
	}
	if ( !isDefined( level._zmeat_zombie_spawn_locations[ side ] ) )
	{
		level._zmeat_zombie_spawn_locations[ side ] = [];
	}
	struct = spawnStruct();
	struct.script_string = "find_flesh";
	struct.origin = origin;
	struct.angles = ( 0, 0, 0 );
	struct.script_noteworthy = "riser_location";
	level._zmeat_zombie_spawn_locations[ side ][ level._zmeat_zombie_spawn_locations[ side ].size ] = struct;
}

create_meat_playable_bounds_polygon()
{
	add_point_to_meat_playable_bounds( ( 1167.49, -851.359, -55.875 ) ); //B side corner by the juggernog drop off
	add_point_to_meat_playable_bounds( ( 970.992, -671.408, -55.875 ) ); //B side at corner of bench across from car and at start of barrier
	add_point_to_meat_playable_bounds( ( 1008.45, -423.233, -61.875 ) ); //B side at point where car and barrier meet
	add_point_to_meat_playable_bounds( ( 1083.85, -388.273, -61.875 ) ); //B side back right corner of car
	add_point_to_meat_playable_bounds( ( 957.55, -158.449, -55.875 ) ); //B side left side of door
	add_point_to_meat_playable_bounds( ( 1135.11, 25.7226, -40.4254 ) ); //B to A side right side of door
	add_point_to_meat_playable_bounds( ( 1139.64, 225.526, -39.875 ) ); //A side start of barrier near side lava pit
	add_point_to_meat_playable_bounds( ( 1736.69, 57.4286, -55.875 ) ); //A side end of barrier next to corner of bench
	add_point_to_meat_playable_bounds( ( 1748.34, -70.6925, -47.0221 ) ); //A side end of bench
	add_point_to_meat_playable_bounds( ( 1776.36, -64.0588, -40.7401 ) ); //A side end of bench against wall
	add_point_to_meat_playable_bounds( ( 1776.25, -147.981, -29.394 ) ); //A side corner of bar outside
	add_point_to_meat_playable_bounds( ( 1815.82, -145.38, -28.4482 ) ); //A side start of fence by bar corner
	add_point_to_meat_playable_bounds( ( 1700.02, -394.447, -60.5263 ) ); //A side end of car and start of barrier
	add_point_to_meat_playable_bounds( ( 1694.36, -594.105, -47.6287 ) ); //A side corner of fence and van near packapunch
	add_point_to_meat_playable_bounds( ( 1618.53, -518.885, -53.836 ) ); //A side end of fence meeting first fence in the center lava pit
	add_point_to_meat_playable_bounds( ( 1469.37, -519.267, -67.875 ) ); //B side end of packapunch fence
	add_point_to_meat_playable_bounds( ( 1448.1, -568.906, -60.3131 ) ); //B side end of packapunch fence other side of fence
	add_point_to_meat_playable_bounds( ( 1559.91, -588.597, -48.1473 ) ); //B side start of packapunch fence opposite side against edge of barrier
	add_point_to_meat_playable_bounds( ( 1752.14, -834.464, -41.517 ) ); //B side start of fence after trash can
	add_point_to_meat_playable_bounds( ( 1759.86, -976.031, -33.106 ) ); //B side front of white car
	add_point_to_meat_playable_bounds( ( 1493.02, -974.125, -55.5443 ) ); //B side end of barrier leading to olympia
	add_point_to_meat_playable_bounds( ( 1281.61, -851.359, -55.9603 ) ); //B side end of minivan
}

create_meat_team_b_bounds()
{
	add_point_to_meat_team_bounds( "B", ( 1167.49, -851.359, -55.875 ) ); //B side corner by the juggernog drop off
	add_point_to_meat_team_bounds( "B", ( 970.992, -671.408, -55.875 ) ); //B side at corner of bench across from car and at start of barrier
	add_point_to_meat_team_bounds( "B", ( 1008.45, -423.233, -61.875 ) ); //B side at point where car and barrier meet
	add_point_to_meat_team_bounds( "B", ( 1083.85, -388.273, -61.875 ) ); //B side back right corner of car
	add_point_to_meat_team_bounds( "B", ( 957.55, -158.449, -55.875 ) ); //B side left side of door
	next_point1 = get_next_point( ( 1107.11, -4.23206, -40.7551 ), ( 0, 35, 0 ), 15 ); //B side start of barrier near door
	add_point_to_meat_team_bounds( "B", next_point1 ); 
	next_point2 = get_next_point( ( 1505.59, -518.493, -67.875 ), ( 0, 35, 0 ), 15 ); //B side end of barrier near packapunch
	add_point_to_meat_team_bounds( "B", next_point2 ); 
	add_point_to_meat_team_bounds( "B", ( 1469.37, -519.267, -67.875 ) ); //B side end of packapunch fence
	add_point_to_meat_team_bounds( "B", ( 1448.1, -568.906, -60.3131 ) ); //B side end of packapunch fence other side of fence
	add_point_to_meat_team_bounds( "B", ( 1559.91, -588.597, -48.1473 ) ); //B side start of packapunch fence opposite side against edge of barrier
	add_point_to_meat_team_bounds( "B", ( 1752.14, -834.464, -41.517 ) ); //B side start of fence after trash can
	add_point_to_meat_team_bounds( "B", ( 1759.86, -976.031, -33.106 ) ); //B side front of white car
	add_point_to_meat_team_bounds( "B", ( 1493.02, -974.125, -55.5443 ) ); //B side end of barrier leading to olympia
	add_point_to_meat_team_bounds( "B", ( 1281.61, -851.359, -55.9603 ) ); //B side end of minivan
}

create_meat_team_a_bounds()
{
	next_point2 = get_next_point( ( 1557.17, -517.947, -67.875 ), ( 0, -145, 0 ), 15 ); //A side end of barrier near packapunch
	add_point_to_meat_team_bounds( "A", next_point2 ); 
	next_point1 = get_next_point( ( 1135.11, 25.7226, -40.4254 ),  (0, -145, 0 ), 15 ); //A side start of barrier near door
	add_point_to_meat_team_bounds( "A", next_point1 ); 
	add_point_to_meat_team_bounds( "A", ( 1139.64, 225.526, -39.875 ) ); //A side start of barrier near side lava pit
	add_point_to_meat_team_bounds( "A", ( 1736.69, 57.4286, -55.875 ) ); //A side end of barrier next to corner of bench
	add_point_to_meat_team_bounds( "A", ( 1748.34, -70.6925, -47.0221 ) ); //A side end of bench
	add_point_to_meat_team_bounds( "A", ( 1776.36, -64.0588, -40.7401 ) ); //A side end of bench against wall
	add_point_to_meat_team_bounds( "A", ( 1776.25, -147.981, -29.394 ) ); //A side corner of bar outside
	add_point_to_meat_team_bounds( "A", ( 1815.82, -145.38, -28.4482 ) ); //A side start of fence by bar corner
	add_point_to_meat_team_bounds( "A", ( 1700.02, -394.447, -60.5263 ) ); //A side end of car and start of barrier
	add_point_to_meat_team_bounds( "A", ( 1694.36, -594.105, -47.6287 ) ); //A side corner of fence and van near packapunch
	add_point_to_meat_team_bounds( "A", ( 1618.53, -518.885, -53.836 ) ); //A side end of fence meeting first fence in the center lava pit
}