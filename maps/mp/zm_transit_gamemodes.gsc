#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zm_transit_utility;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_game_module_meat_utility;
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
	add_map_location_gamemode("zgrief", "town", maps\mp\zm_transit_grief_town::precache, maps\mp\zm_transit_grief_town::main);

//	add_map_location_gamemode("zcleansed", "farm", maps\mp\zm_transit_turned_farm::precache, maps\mp\zm_transit_turned_farm::main);
//	add_map_location_gamemode("zcleansed", "cornfield", maps\mp\zm_transit_turned_cornfield::precache, maps\mp\zm_transit_turned_cornfield::main);
//	add_map_location_gamemode("zcleansed", "diner", maps\mp\zm_transit_turned_diner::precache, maps\mp\zm_transit_turned_diner::main);
//	add_map_location_gamemode("zcleansed", "town", maps\mp\zm_transit_turned_town::precache, maps\mp\zm_transit_turned_town::main);
}

zmeat_town_precache()
{

}

zmeat_town_main()
{
	//wait(.5); //wait a small bit to make sure everyone is connected and running before kicking off 
	setup_standard_objects_override( "town" );
	level._meat_location = "town";	
	level._meat_start_point = random(getstructarray("meat_2_spawn_points","targetname")).origin;//(4352, -13824, 224);
	level._meat_team_1_zombie_spawn_points = getstructarray("meat_2_team_1_zombie_spawn_points","targetname");
	level._meat_team_2_zombie_spawn_points = getstructarray("meat_2_team_2_zombie_spawn_points","targetname");
	//level._meat_team_1_volume = getent("meat_2_team_1_volume","targetname");
	//level._meat_team_2_Volume = getent("meat_2_team_2_volume","targetname");
	flag_clear("zombie_drop_powerups");
	level.custom_intermission  = ::town_meat_intermission;
	level.zombie_vars["zombie_intermission_time"] = 5;
	level._supress_survived_screen = 1;
	level thread maps\mp\gametypes_zm\zmeat::item_meat_clear();
	level thread meat_intro( "transit_town_meat_launch_spot" );
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
