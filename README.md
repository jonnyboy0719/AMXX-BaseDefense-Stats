AMXX -- Base Defense Stats
=====================

This plugin will save all of your stats to a MySQL server, which multiple servers can use w/o loosing your progress when the map changes level.

Created by: [Johan Eherndahl](http://jonnyboy0719.co.uk/bdef/)  


Commands
-----------
`/help` - Prints all the available commands on the console  
`/reset` - To reset your skills  
`/fullreset` - To reset your level, skills and experience back to 0 (can't be undone!)  
`/bdefstats or /version` - To show the correction  
`/top10` - Shows the top10 players  
`/rank` - Shows your rank   

Server Commands
-----------
`bdef_ranking` - This will enable ranking, or simply disable it.  
`bdef_gameinfo` - This will enable GameInformation to be overwritten.  

How it Works
-----------

Simply copy the `bdef_stats.amxx` to your plugins folder and add `bdef_stats.amxx` under `configs/plugins.ini` file.  

Now open `configs/sql.cfg` and add the new commands:  
`bdef_host			"127.0.0.1"`  
`bdef_user			"root"`  
`bdef_pass			""`  
`bdef_type			"mysql"`  
`bdef_dbname			"my_database"`  
`bdef_table			"bdef_stats"`  
`bdef_rank_table			"bdef_stats_rank"`  

Database setup
-----------

The sql file is under `web/database.sql`. Simple copy paste it to your PhpMyAdmin, 
or any SQL Manager that you have installed, into its query, and hit run. But make sure its inside a database, else it will throw errors!

Web GUI
-----------

Make sure you install the web gui on your apache folder (you can find all files under `web/` folder) and not copying it to your actual base defense server!  
You also need to make sure to setup the configurations on the config.php.

Web GUI Demo
-----------

If you want to see how the Web GUI looks like, you can do so by going to our official Base Defense Stats page for our server!  
Demo: [Click here!](http://stats.jonnyboy0719.co.uk/bdef/)
