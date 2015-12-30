//=============================================================================
//
// This plugin is using BB Stats as a base, so you will see some leftover codes here and there.
//
//=============================================================================

//------------------
//	Include Files
//------------------

#define OLDVALUE	// Comment this out to use the new color features that is made for AMX

#include <amxmodx>
#include <amxmisc>
#include <geoip>
#include <bdef>
#include <fakemeta>
#include <sqlx>
#include <fun>

//------------------
//	Defines
//------------------

// Plugin
#define PLUGIN	"Base Defense STATS"
#define AUTHOR	"JonnyBoy0719"
#define VERSION	"1.1"

//------------------
//	Handles & more
//------------------

new ShouldFullReset[33],
	ResetConvarTime[33],
	lastfrags[33],
	lastDeadflag[33],
	bool:FirstTimeJoining[33],
	bool:HasSpawned[33],
	bool:HasLoadedStats[33],
	bool:HasBackpack[33],
	bool:enable_ranking=false,
	rank_max = 0,
	get_sql_lvl[33]
// Global stuff
new mysqlx_host, mysqlx_user, mysqlx_db, mysqlx_pass, mysqlx_type
new setranking, rank_name[33][185], ply_rank[33], top_rank

//------------------
//	plugin_init()
//------------------

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar("bdefstats_version", VERSION, FCVAR_SPONLY|FCVAR_SERVER)
	
	set_cvar_string("bdefstats_version", VERSION)

	register_forward(FM_PlayerPreThink,"PluginThink")
	register_forward(FM_GetGameDescription,"GameInformation")
	
	register_event("DeathMsg", "EVENT_PlayerDeath", "a")
	register_event("ItemPickup", "EVENT_ItemPickup", "b")

	set_task(1.0,"PluginThinkLoop",0,"",0,"b")
	set_task(30.0,"PluginAdverts",0,"",0,"b")

	mysqlx_host = register_cvar ("bdef_host", "127.0.0.1"); // The host from the db
	mysqlx_user = register_cvar ("bdef_user", "root"); // The username from the db login
	mysqlx_pass = register_cvar ("bdef_pass", ""); // The password from the db password
	mysqlx_type = register_cvar ("bdef_type", "mysql"); // The password from the db type
	mysqlx_db = register_cvar ("bdef_dbname", "my_database"); // The database name 
	register_cvar ("bdef_table", "bdef_stats"); // The table where it will save the information
	register_cvar ("bdef_rank_table", "bdef_stats_rank"); // The table where it will save the information
	register_cvar ("bdef_gameinfo", "1"); // This will enable GameInformation to be overwritten.
	setranking = register_cvar ("bdef_ranking", "1"); // This will enable ranking, or simply disable it.

	// Client commands
	register_clcmd("say","hook_say")
	register_clcmd("say_team","hook_say")
}

//------------------
//	EVENT_PlayerDeath()
//------------------

public EVENT_PlayerDeath()
{
//	new killer = read_data(1);	// Killer
	new victim = read_data(2);	// Victim
//	new weapon = read_data(3);	// Weapon

	// If the player has died, lets save his stuff first.
	if (!is_user_bot(victim) && !is_user_hltv(victim))
	{
		if (HasBackpack[victim])
			client_print ( victim, print_chat, "Saving all progress..." )

		new auth[33];
		get_user_authid( victim, auth, 32);
		SaveLevel(victim, auth);
	}
	return PLUGIN_CONTINUE
}

//------------------
//	EVENT_ItemPickup()
//------------------

public EVENT_ItemPickup(id)
{
	new classname[55];
	read_data(1, classname, 54);	// Classname

	// If the player has picked up the backpack
	if (equali(classname, "item_backpack") && !HasBackpack[id])
		HasBackpack[id] = true
	return PLUGIN_CONTINUE
}

//------------------
//	client_putinserver()
//------------------

public client_putinserver(id)
{
	if (is_user_bot(id))
		return;

	// If the player has died, lets save his stuff first.
	new auth[33];
	get_user_authid( id, auth, 32);
	// Lets load the user's level (will only show if the user has its stats created)
	LoadLevel(id, auth)
	set_task(2.0, "ShowInfo", id)
}

//------------------
//	ShowInfo()
//------------------

public ShowInfo(id)
{
	StatsVersion(id)
	HelpOnConnect(id)
	if( enable_ranking )
		set_task(2.0, "ShowStatsOnSpawn", id)
}

//------------------
//	GameInformation()
//------------------

public GameInformation()
{
	new bb_getinfo = get_cvar_num ( "bdef_gameinfo" )
	if (bb_getinfo>=1)
	{
		new gameinfo[55]
		format( gameinfo, 54, "Base Defense || SQL STATS %s", VERSION )
		forward_return( FMV_STRING, gameinfo )
		return FMRES_SUPERCEDE;
	}
	return PLUGIN_HANDLED
}

//------------------
//	StatsVersion()
//------------------

public StatsVersion(id)
{
	new formated_text[501];
	format(formated_text, 500, "This server is running Base Defense Stats Version {GREEN}%s", VERSION) 
	PrintToChat(id, formated_text)
	return PLUGIN_HANDLED
}

//------------------
//	GetCurrentRankTitle()
//------------------

GetCurrentRankTitle(id)
{
	new error[128], errno
	new Handle:info = MySQLx_Init()
	new Handle:sql = SQL_Connect(info, errno, error, 127)

	if (sql == Empty_Handle)
	{
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_CON", error)
	}

	new table[32]

	get_cvar_string("bdef_rank_table", table, 31)

	// This will read the player LVL and then give him the title he needs
	new Handle:query = SQL_PrepareQuery(sql, "SELECT * FROM `%s` WHERE `lvl` <= (%d) and `lvl` ORDER BY abs(`lvl` - %d) LIMIT 1", table, get_sql_lvl[id], get_sql_lvl[id])
	if (!SQL_Execute(query))
	{
		server_print("query not loaded [title]")
		SQL_QueryError(query, error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", error)
	} else {
		while (SQL_MoreResults(query))
		{
			new ranktitle[185]
			SQL_ReadResult(query, 1, ranktitle, 31)
			
			top_rank = rank_max
			
			rank_name[id] = ranktitle;
			SQL_NextRow(query);
		}
	}
	SQL_FreeHandle(query);
	SQL_FreeHandle(sql);
	SQL_FreeHandle(info);
	return 0;
}

//------------------
//	ShowMyRank()
//------------------

public ShowMyRank(id)
{
	new Position = GetPosition(id);
	ply_rank[id] = Position;
	// Lets call the GetCurrentRankTitle(id) to make sure we get the title for the player
	GetCurrentRankTitle(id);
	new auth[33], formated_text[501];
	get_user_authid( id, auth, 32);
	LoadLevel(id, auth, false);
	
	format(formated_text, 500, "{DEFAULT}you are on rank {GREEN}%d{DEFAULT} of {GREEN}%d{DEFAULT} with the title: ^"{LIGHTBLUE}%s{DEFAULT}^"", ply_rank[id], top_rank, rank_name[id]) 
	PrintToChat(id, formated_text)
	return PLUGIN_HANDLED
}

//------------------
//	ResetStats()
//------------------

public ResetStats(id, FullReset)
{
	new formated_text[501];
	if (FullReset)
	{
		if(ResetConvarTime[id])
			return PLUGIN_HANDLED;

		// If they wrote it by mistake, lets have a message saying (write /fullreset again before X amount of seconds)
		if(!ShouldFullReset[id])
		{
			format(formated_text, 500, "{DEFAULT}[{RED}STATS{DEFAULT}] To make a full reset of your stats, write {GREEN}/fullreset{DEFAULT} again.")
			PrintToChat(id, formated_text)
			format(formated_text, 500, "{DEFAULT}You have 5 seconds to confirm your reset, type {GREEN}/fullreset{DEFAULT} if your absolutely sure.")
			PrintToChat(id, formated_text)
			ShouldFullReset[id] = true;
			set_task(5.0, "ResetConvarStatus", id)
			return PLUGIN_HANDLED;
		}
		else
			ShouldFullReset[id] = false;

		ResetConvarTime[id] = true;

		format(formated_text, 500, "{DEFAULT}[{RED}STATS{DEFAULT}] Everything has now been fully reset.") 
		PrintToChat(id, formated_text)

		// Now the last bit, lets reset everything
		bdef_set_user_level(id, 1);
		bdef_set_user_points(id, 5);
		bdef_set_user_skill_legerity(id, 0);
		bdef_set_user_skill_precision(id, 0);
		bdef_set_user_skill_toughness(id, 0);
		bdef_set_user_skill_sorcery(id, 0);
	}
	else
	{
		// Lets get the player's abilities and points
		new points, legerity, precision, toughness, sorcery;

		legerity = bdef_get_user_skill_legerity(id);
		precision = bdef_get_user_skill_precision(id);
		toughness = bdef_get_user_skill_toughness(id);
		sorcery = bdef_get_user_skill_sorcery(id);
		points = bdef_get_user_points(id);

		// Now, lets convert them into points!
		new GetPoints = points+(legerity+precision+toughness+sorcery)
		bdef_set_user_points(id, GetPoints);

		format(formated_text, 500, "{DEFAULT}[{RED}STATS{DEFAULT}] Your abilities have been reset, and turned them into {GREEN}%d Ability Points(s){DEFAULT}.", GetPoints) 
		PrintToChat(id, formated_text)

		// Now the last bit, lets reset the abilities
		bdef_set_user_skill_legerity(id, 0);
		bdef_set_user_skill_precision(id, 0);
		bdef_set_user_skill_toughness(id, 0);
		bdef_set_user_skill_sorcery(id, 0);
	}
	return PLUGIN_HANDLED
}

public ResetConvarStatus(id)
{
	if(ShouldFullReset[id]) ShouldFullReset[id] = false;
	ResetConvarTime[id] = false;
	return PLUGIN_HANDLED
}

//------------------
//	BBHelp()
//------------------

public BBHelp(id, ShowCommands)
{
	// Chat Print
	if (ShowCommands)
	{
		client_print ( id, print_chat, "The commands have been printed on your console." )
		client_print ( id, print_console, "==----------[[ BASE DEFENSE STATS ]]-------------==" )
		client_print ( id, print_console, "/version			--		Shows the current version" )
		client_print ( id, print_console, "/reset			--		Resets your stats (Points only)" )
		client_print ( id, print_console, "/fullreset		--		Full Reset of your stats" )
		if ( enable_ranking )
		{
			client_print ( id, print_console, "/top10		--		Shows the top10 players" )
			client_print ( id, print_console, "/rank		--		Shows your rank" )
		}
		client_print ( id, print_console, "==--------------------------------------==" )
	}
	else
	{
		if ( enable_ranking )
			client_print ( id, print_chat, "Available commands: /version /rank /top10 /reset /fullreset" )
		else
			client_print ( id, print_chat, "Available commands: /version /reset /fullreset" )
	}
	return PLUGIN_HANDLED
}

//------------------
//	hook_say()
//------------------

public hook_say(id)
{
	new said[32]
	read_argv(1, said, 31)
	remove_quotes(said)

	if (equali(said[0], "/bdefstats") || equali(said[0], "/version"))
		StatsVersion(id)
	else if (equali(said[0], "/help"))
		BBHelp(id, true)
	else if (equali(said[0], "/reset"))
		ResetStats(id, false)
	else if (equali(said[0], "/fullreset"))
		ResetStats(id, true)

	if ( enable_ranking )
	{
		if (equali(said[0], "/top10"))
			ShowTop10(id)
		else if (equali(said[0], "/rank"))
			ShowMyRank(id)
	}

	return PLUGIN_CONTINUE
}

//------------------
//	ShowTop10()
//------------------

public ShowTop10(id)
{
	static getnum

	// Lets not bug the top10 by adding more when we write /top10
	getnum = 0

	new menuBody[215]
	new len = format(menuBody, 214, "BD Stats -- Top10^n^n")

	new error[128], errno
	new Handle:info = MySQLx_Init()
	new Handle:sql = SQL_Connect(info, errno, error, 127)

	if (sql == Empty_Handle)
	{
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_CON", error)
	}

	new table[32], name[33]

	get_cvar_string("bdef_table", table, 31)

	new Handle:query = SQL_PrepareQuery(sql, "SELECT `name` FROM `%s` ORDER BY `exp` + 0 DESC LIMIT 10", table)

	// This is a pretty basic code, get all people from the database.
	if (!SQL_Execute(query))
	{
		server_print("GetPosition not loaded")
		SQL_QueryError(query, error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", error)
	} else {
		while (SQL_MoreResults(query))
		{
			SQL_ReadResult(query, 0, name, 32)
			len += format(menuBody[len], 214-len, "#%d. %s^n", ++getnum, name)

			SQL_NextRow(query);
		}
	}
	SQL_FreeHandle(query);
	SQL_FreeHandle(sql);
	SQL_FreeHandle(info);

	show_menu(id, getnum, menuBody)

	return PLUGIN_CONTINUE;
}

//------------------
//	PluginThinkLoop()
//------------------

public PluginThinkLoop()
{
	new iPlayers[32],iNum
	get_players(iPlayers, iNum)
	for(new i = 0;i < iNum; i++)
	{
		new id = iPlayers[i]
		if(is_user_connected(id) && is_user_alive(id))
		{
			if(get_user_frags(id) > lastfrags[id])
			{
				lastfrags[id] = get_user_frags(id)
				
				new auth[33];
				get_user_authid( id, auth, 32);
				SaveLevel(id, auth, true)
			}
			if (!FirstTimeJoining[id])
			{
				FirstTimeJoining[id] = true;
				new auth[33];
				get_user_authid( id, auth, 32);
				LoadLevel(id, auth)
			}
		}
	}

	if ( setranking >= 1 )
	{
		enable_ranking = true;
	}
	else
	{
		enable_ranking = false;
	}
}

//------------------
//	PluginAdverts()
//------------------

public PluginAdverts()
{
	new iPlayers[32], iNum, formated_text[501]
	get_players(iPlayers, iNum)
	for(new i = 0; i < iNum; i++)
	{
		new id=iPlayers[i]
		if(is_user_connected(id))
		{
			new GetRandom = random_num(0, 8)

			switch (GetRandom)
			{
				case 0:
				{
					format(formated_text, 500, "{ADDITIVE}{DEFAULT}[{RED}STATS{DEFAULT}] Want to see what commands you can write? write {GREEN}/help") 
					PrintToChat(id, formated_text)
				}
				case 5:
				{
					format(formated_text, 500, "{ADDITIVE}{DEFAULT}[{RED}STATS{DEFAULT}] Want to reset your stats? write {GREEN}/reset") 
					PrintToChat(id, formated_text)
				}
				case 8:
				{
					format(formated_text, 500, "{ADDITIVE}{DEFAULT}This server is using Base Defense Stats Version {GREEN}%s{DEFAULT} by {RED}JonnyBoy0719", VERSION) 
					PrintToChat(id, formated_text)
				}
				
				default:
				{
				}
			}
		}
	}
}

//------------------
//	client_connect()
//------------------

public client_connect(id)
{
	FirstTimeJoining[id] = false;
	HasLoadedStats[id] = false;
	HasSpawned[id] = false;
	HasBackpack[id] = false;
	get_sql_lvl[id] = 0;
	// Connected
	new players[32], num , i, formated_text[501];
	get_players(players, num)
	for (i = 0; i<num; i++)
	{
		if (is_user_connected(players[i]) && !is_user_bot(players[i]))
		{
			new plyname[32], auth[33]
			get_user_authid(id, auth, 32)
			get_user_name(id, plyname, 31)

			if (is_user_admin(players[i]))
			{
				format(formated_text, 500, "{DEFAULT}Player {RED}%s{DEFAULT} <^"{GREEN}%s{DEFAULT}^"> is now connecting...", plyname, auth) 
				PrintToChat(players[i], formated_text)
			}
			else
			{
				format(formated_text, 500, "{DEFAULT}Player {RED}%s{DEFAULT} is now connecting...", plyname) 
				PrintToChat(players[i], formated_text)
			}
		}
	}
}

//------------------
//	PluginThink()
//------------------

public PluginThink(id)
{
	new deadflag = pev(id, pev_deadflag)
	if( !deadflag && lastDeadflag[id] )
		OnPlayerSpawn(id)
	lastDeadflag[id] = deadflag
}

//------------------
//	OnPlayerSpawn()
//------------------

public OnPlayerSpawn(id) {
	new auth[33];
	get_user_authid( id, auth, 32);
	// Creates the stats, if it already exists, it will skip it.
	if ( !HasLoadedStats[id] )
		CreateStats(id, auth)
	if ( !HasSpawned[id] )
		HasSpawned[id] = true;
	// If the player doesn't have his backpack.
	if (!HasBackpack[id])
		PrintToChat(id, "{DEFAULT}You need to regain your {GREEN}backpack{DEFAULT}, else it won't save your current stats." )
} 

//------------------
//	HelpOnConnect()
//------------------

public HelpOnConnect(id)
{
	new hostname[101], plyname[32], formated_text[501]
	get_user_name(0,hostname,100)
	get_user_name(id, plyname, 31)

	if ( enable_ranking )
	{
		new Position = GetPosition(id);
		ply_rank[id] = Position;
		format(formated_text, 500, "{DEFAULT}Welcome {RED}%s{DEFAULT} to {ORANGE}%s{DEFAULT}! You are on rank {LIGHTBLUE}%d{DEFAULT}.", plyname, hostname, ply_rank[id]) 
		PrintToChat(id, formated_text)
	}
	else
	{
		format(formated_text, 500, "{DEFAULT}Welcome {RED}%s{DEFAULT} to {ORANGE}%s{DEFAULT}!", plyname, hostname) 
		PrintToChat(id, formated_text)
	}

	BBHelp(id,false)
}

//------------------
//	ShowStatsOnSpawn()
//------------------

public ShowStatsOnSpawn(id)
{
	new players[32],num,i;
	get_players(players, num)
	for (i=0; i<num; i++)
	{
		if (is_user_connected(players[i]) && !is_user_bot(players[i]))
		{
			if (players[i] == id)
			{
				ShowMyRank(id);
				continue;
			}
			new plyname[32], formated_text[501]
			get_user_name(id, plyname, 31)
			format(formated_text, 500, "{RED}%s{DEFAULT} is {LIGHTBLUE}%s{DEFAULT}. Ranked {GREEN}%d{DEFAULT} of {GREEN}%d{DEFAULT}.", plyname, rank_name[id], ply_rank[id], top_rank) 
			PrintToChat( players[i], formated_text)
		}
	}
}

public PrintToChat(id, string[])
{
	replace_all(string, 500, "{NORMAL}", COLOR_NORMAL);
	replace_all(string, 500, "{ADDITIVE}", COLOR_ADDITIVE);
	replace_all(string, 500, "{DEFAULT}", COLOR_DEFAULT);
	replace_all(string, 500, "{RED}", COLOR_RED);
	replace_all(string, 500, "{GREEN}", COLOR_GREEN);
	replace_all(string, 500, "{BLUE}", COLOR_BLUE);
	replace_all(string, 500, "{ORANGE}", COLOR_ORANGE);
	replace_all(string, 500, "{BROWN}", COLOR_BROWN);
	replace_all(string, 500, "{LIGHTBLUE}", COLOR_LIGHTBLUE);
	replace_all(string, 500, "{GRAY}", COLOR_GRAY);

	client_print(id, print_chat, string);

	return PLUGIN_CONTINUE;
}

//------------------
//	client_disconnect()
//------------------

public client_disconnect(id)
{
	new auth[33];
	get_user_authid( id, auth, 32);
	SaveDate(auth);
	UpdateConnection(id, auth,false);
	if(HasSpawned[id])
	{
		SaveLevel(id, auth)
		HasSpawned[id] = false;
		HasLoadedStats[id] = false;
	}
	FirstTimeJoining[id] = false;
}

// ============================================================//
//                          [~ Saving datas ~]			       //
// ============================================================//

//------------------
//	MySQLx_Init()
//------------------
stock Handle:MySQLx_Init(timeout = 0)
{
	static szHost[64], szUser[32], szPass[32], szDB[128];
	static get_type[12], set_type[12];
	
	get_pcvar_string( mysqlx_host, szHost, 63 );
	get_pcvar_string( mysqlx_user, szUser, 31 );
	get_pcvar_string( mysqlx_type, set_type, 11);
	get_pcvar_string( mysqlx_pass, szPass, 31 );
	get_pcvar_string( mysqlx_db, szDB, 127 );
	
	SQL_GetAffinity(get_type, 12);
	
	if (!equali(get_type, set_type))
	{
		if (!SQL_SetAffinity(set_type))
		{
			log_amx("Failed to set affinity from %s to %s.", get_type, set_type);
		}
	}
	
	return SQL_MakeDbTuple( szHost, szUser, szPass, szDB, timeout );
}

//------------------
//	QueryCreateTable()
//------------------

public QueryCreateTable( iFailState, Handle:hQuery, szError[ ], iError, iData[ ], iDataSize, Float:fQueueTime ) 
{ 
	if( iFailState == TQUERY_CONNECT_FAILED 
	|| iFailState == TQUERY_QUERY_FAILED ) 
	{ 
		log_amx( "%s", szError ); 
		
		return;
	} 
}

//------------------
//	SaveLevel()
//------------------

SaveLevel(id, auth[], fragkill=false)
{
	if (!HasBackpack[id])
		return;

	new error[128], errno

	new Handle:info = MySQLx_Init()
	new Handle:sql = SQL_Connect(info, errno, error, 127)

	if (sql == Empty_Handle)
	{
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_CON", error)
	}

	new table[32]

	get_cvar_string("bdef_table", table, 31)

	new Handle:query = SQL_PrepareQuery(sql, "SELECT * FROM `%s` WHERE (`authid` = '%s')", table, auth)

	if (!SQL_Execute(query))
	{
		server_print("query not saved")
		SQL_QueryError(query, error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", error)
	} else {
		new level, points, money,
			legerity, precision, toughness, sorcery,
			item_health, item_mana, exp_min, exp_max;
		level = bdef_get_user_level(id);
		legerity = bdef_get_user_skill_legerity(id);
		precision = bdef_get_user_skill_precision(id);
		toughness = bdef_get_user_skill_toughness(id);
		sorcery = bdef_get_user_skill_sorcery(id);
		points = bdef_get_user_points(id);
		money = bdef_get_user_money(id);
		item_health = bdef_get_user_item_health(id);
		item_mana = bdef_get_user_item_mana(id);
		exp_min = bdef_get_user_exp_min(id);
		exp_max = bdef_get_user_exp_max(id);
		
		if (!fragkill)
			HasBackpack[id] = false;
		
		new plyname[32]
		get_user_name(id,plyname,31)
		SQL_QueryAndIgnore(sql, "UPDATE `%s` SET `name` = '%s', `money` = %d, `lvl` = %d, `item_health` = %i, `item_mana` = %i, `skill_legerity` = %d, `skill_precision` = %d, `skill_toughness` = %d, `skill_sorcery` = %d, `points` = %d, `exp` = %d, `exp_max` = %d WHERE `authid` = '%s';", table, plyname, money, level, item_health, item_mana, legerity, precision, toughness, sorcery, points, exp_min, exp_max, auth )
	}

	SQL_FreeHandle(query)
	SQL_FreeHandle(sql)
	SQL_FreeHandle(info)
}

//------------------
//	UpdateConnection()
//------------------

UpdateConnection(client, auth[],IsOnline=true)
{
	new error[128], errno
	new countrycode[3]
	new ip[33][32]

	new Handle:info = MySQLx_Init()
	new Handle:sql = SQL_Connect(info, errno, error, 127)

	if (sql == Empty_Handle)
	{
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_CON", error)
	}

	if(IsOnline)
	{
		get_user_ip(client,ip[client],31)
		geoip_code2_ex(ip[client],countrycode)
	}

	new table[32]

	get_cvar_string("bdef_table", table, 31)

	new Handle:query = SQL_PrepareQuery(sql, "SELECT * FROM `%s` WHERE (`authid` = '%s')", table, auth)

	if (!SQL_Execute(query))
	{
		server_print("query not saved")
		SQL_QueryError(query, error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", error)
	} else {
		if (IsOnline)
			SQL_QueryAndIgnore(sql, "UPDATE `%s` SET `online` = 'true',`country` = '%s' WHERE `authid` = '%s';", table, countrycode, auth )
		else
			SQL_QueryAndIgnore(sql, "UPDATE `%s` SET `online` = 'false' WHERE `authid` = '%s';", table, auth )
	}

	SQL_FreeHandle(query)
	SQL_FreeHandle(sql)
	SQL_FreeHandle(info)
}

//------------------
//	SaveDate()
//------------------

SaveDate(auth[])
{
	new error[128], errno

	new Handle:info = MySQLx_Init()
	new Handle:sql = SQL_Connect(info, errno, error, 127)

	if (sql == Empty_Handle)
	{
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_CON", error)
	}

	new table[32]

	get_cvar_string("bdef_table", table, 31)

	new Handle:query = SQL_PrepareQuery(sql, "SELECT * FROM `%s` WHERE (`authid` = '%s')", table, auth)

	if (!SQL_Execute(query))
	{
		server_print("query not saved")
		SQL_QueryError(query, error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", error)
	} else {
		SQL_QueryAndIgnore(sql, "UPDATE `%s` SET `date` = UNIX_TIMESTAMP(NOW()) WHERE `authid` = '%s';", table, auth )
	}

	SQL_FreeHandle(query)
	SQL_FreeHandle(sql)
	SQL_FreeHandle(info)
}

//------------------
//	LoadLevel()
//------------------

LoadLevel(id, auth[], LoadMyStats = true)
{
	// This will fix some minor bugs when joining.
	rank_max = 0
	new error[128], errno

	new Handle:info = MySQLx_Init()
	new Handle:sql = SQL_Connect(info, errno, error, 127)

	if (sql == Empty_Handle)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_CON", error)

	new table[32], table2[32]

	get_cvar_string("bdef_table", table, 31)
	get_cvar_string("bdef_rank_table", table2, 31)

	new Handle:query = SQL_PrepareQuery(sql, "SELECT * FROM `%s` WHERE (`authid` = '%s')", table, auth)
	new Handle:query_g = SQL_PrepareQuery(sql, "SELECT `authid` FROM `%s`", table)

	// This is a pretty basic code, get all people from the database.
	if (!SQL_Execute(query_g))
	{
		server_print("bdef_table doesn't exist?")
		SQL_QueryError(query_g, error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", error)
	} else {
		while (SQL_MoreResults(query_g))
		{
			rank_max++;
			SQL_NextRow(query_g);
		}
	}
	SQL_FreeHandle(query_g);

	if (!SQL_Execute(query))
	{
		server_print("LoadStats query has stopped due to errors.")
		SQL_QueryError(query, error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", error)
	} else if (SQL_NumResults(query)) {
		server_print("loaded stats for:^nID: ^"%s^"", auth)

		HasLoadedStats[id] = true;
		HasBackpack[id] = true;
			
		new hps, mana, lvl, precision,
			toughness, sorcery, points,
			legerity, exp, exp_max, money;
		exp = SQL_FieldNameToNum(query, "exp");
		exp_max = SQL_FieldNameToNum(query, "exp_max");
		lvl = SQL_FieldNameToNum(query, "lvl");
		money = SQL_FieldNameToNum(query, "money");
		hps = SQL_FieldNameToNum(query, "item_health");
		mana = SQL_FieldNameToNum(query, "item_mana");
		legerity = SQL_FieldNameToNum(query, "skill_legerity");
		precision = SQL_FieldNameToNum(query, "skill_precision");
		toughness = SQL_FieldNameToNum(query, "skill_toughness");
		sorcery = SQL_FieldNameToNum(query, "skill_sorcery");
		points = SQL_FieldNameToNum(query, "points");

		new sql_lvl, sql_exp, sql_exp_max, sql_money,
			sql_legerity, sql_precision, sql_toughness, sql_sorcery,
			sql_points, sql_hps, sql_mana;

		while (SQL_MoreResults(query))
		{
			sql_lvl = SQL_ReadResult(query, lvl);
			sql_exp = SQL_ReadResult(query, exp);
			sql_exp_max = SQL_ReadResult(query, exp_max);
			sql_money = SQL_ReadResult(query, money);
			sql_hps = SQL_ReadResult(query, hps);
			sql_mana = SQL_ReadResult(query, mana);
			sql_legerity = SQL_ReadResult(query, legerity);
			sql_precision = SQL_ReadResult(query, precision);
			sql_toughness = SQL_ReadResult(query, toughness);
			sql_sorcery = SQL_ReadResult(query, sorcery);
			sql_points = SQL_ReadResult(query, points);
			get_sql_lvl[id] = sql_lvl

			if (LoadMyStats)
			{
				// The player stats, only shows on the console once.
				//*
				server_print("-------")
				server_print("Level: %d", sql_lvl);
				server_print("EXP MAX: %d", sql_exp_max);
				server_print("EXP MIN: %d", sql_exp);
				server_print("Money: %d", sql_money);
				server_print("Legerity: %d", sql_legerity);
				server_print("Precision: %d", sql_precision);
				server_print("Toughness: %d", sql_toughness);
				server_print("Sorcery: %d", sql_sorcery);
				server_print("Available Points: %d", sql_points);
				server_print("--- ITEMS ----")
				server_print("Healthkits: %d", sql_hps);
				server_print("Manakits: %d", sql_mana);
				server_print("-------")
				//*/
				SaveDate(auth);
				UpdateConnection(id, auth);

				bdef_set_user_level(id, sql_lvl);
				bdef_set_user_exp_max(id, sql_exp_max);
				bdef_set_user_exp_min(id, sql_exp);
				bdef_set_user_money(id, sql_money);
				bdef_set_user_item_health(id, sql_hps);
				bdef_set_user_item_mana(id, sql_mana);
				bdef_set_user_skill_legerity(id, sql_legerity);
				bdef_set_user_skill_precision(id, sql_precision);
				bdef_set_user_skill_toughness(id, sql_toughness);
				bdef_set_user_skill_sorcery(id, sql_sorcery);
				bdef_set_user_points(id, sql_points);
			}

			SQL_NextRow(query);
		}
	} else {
		// The user doesn't exist, lets stop the process.
		return;
	}

	// This will read the player LVL and then give him the title he needs
	new Handle:query2 = SQL_PrepareQuery(sql, "SELECT * FROM `%s` WHERE `lvl` <= (%d) and `lvl` ORDER BY abs(`lvl` - %d) LIMIT 1", table2, get_sql_lvl[id], get_sql_lvl[id])
	if (!SQL_Execute(query2))
	{
		server_print("query not loaded [query2]")
		SQL_QueryError(query2, error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", error)
	} else {
		while (SQL_MoreResults(query2))
		{
			// Not the best code, this needs improvements...
			new ranktitle[185]
			SQL_ReadResult(query2, 1, ranktitle, 31)
			// This only gets the max players on the database
			top_rank = rank_max
			// This reads the players EXP, and then checks with other players EXP to get the players rank
			new Position = GetPosition(id);
			ply_rank[id] = Position;
			// Sets the title
			rank_name[id] = ranktitle;
			SQL_NextRow(query2);
		}
	}

	SQL_FreeHandle(query2);
	SQL_FreeHandle(query);
	SQL_FreeHandle(sql);
	SQL_FreeHandle(info);
}

//------------------
//	GetPosition()
//------------------

GetPosition(id)
{
	static Position;

	// If used, lets reset it
	Position = 0;

	new error[128], errno
	new Handle:info = MySQLx_Init()
	new Handle:sql = SQL_Connect(info, errno, error, 127)

	if (sql == Empty_Handle)
	{
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_CON", error)
	}

	new table[32]

	get_cvar_string("bdef_table", table, 31)

	new Handle:query = SQL_PrepareQuery(sql, "SELECT `authid` FROM `%s` ORDER BY `exp` + 0 DESC", table)

	// This is a pretty basic code, get all people from the database.
	if (!SQL_Execute(query))
	{
		server_print("GetPosition not loaded")
		SQL_QueryError(query, error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", error)
	} else {
		while (SQL_MoreResults(query))
		{
			Position++
			new authid[33]
			SQL_ReadResult(query, 0, authid, 32)
			new auth_self[33];
			get_user_authid(id, auth_self, 32);
			if (equal(auth_self, authid))
				return Position;
			SQL_NextRow(query);
		}
	}
	SQL_FreeHandle(query);
	SQL_FreeHandle(sql);
	SQL_FreeHandle(info);
	return 0;
}

//------------------
//	CreateStats()
//------------------

CreateStats(id, auth[])
{
	new error[128], errno

	new Handle:info = MySQLx_Init()
	new Handle:sql = SQL_Connect(info, errno, error, 127)

	if (sql == Empty_Handle)
	{
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_CON", error)
	}

	new table[32]

	get_cvar_string("bdef_table", table, 31)

	new Handle:query = SQL_PrepareQuery(sql, "SELECT * FROM `%s` WHERE (`authid` = '%s')", table, auth)

	if (!SQL_Execute(query))
	{
		server_print("query not saved")
		SQL_QueryError(query, error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", error)
	} else if (SQL_NumResults(query)) {
		// If we already created one, lets continnue
	} else {
		console_print(id, "Adding to database:^nID: ^"%s^"", auth)
		server_print("Adding to database:^nID: ^"%s^"", auth)

		new plyname[32]
		get_user_name(id,plyname,31)

		SQL_QueryAndIgnore(sql, "INSERT INTO `%s` (`authid`, `name`) VALUES ('%s', '%s')", table, auth, plyname)
	}
	
	SaveDate(auth);
	UpdateConnection(id, auth);

	SQL_FreeHandle(query)
	SQL_FreeHandle(sql)
	SQL_FreeHandle(info)
}
