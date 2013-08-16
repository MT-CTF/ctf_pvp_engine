Capture The Flag
================

This is a highly customisable game for PvP servers.

All settings and features can be modified by editing the settings in this game's configuration.

What is this game for?
----------------------

This game can be used for many PvP purposes.

* Traditional capture the flag.
* Country wars - players can make cities and defend them.
* Obstactle courses - players can make their bases hard to get to with traps.

License
-------

This mod was made by Andrew "rubenwardy" Ward.

License: CC-BY-SA 3.0  UNPORTED

http://creativecommons.org/licenses/by-sa/3.0/

Teams
=====

Players are part of teams. They can either be allocated to teams, or can be invited. Each team is like a separate country; teams have bases and can declare war on each other. Teams can only build on their own territory and unclaimed territory.

Expanding territory
-------------------

If the multiple_flags setting is set to true, players can add more flags to protect areas and claim land for cities.

(coming soon) By default, only the team captain can place flags, but you can make anyone in the team able to place flags by setting the captian_place_flag_only to false.

Allocation
----------

(coming soon - the only current way to join a team is /join team_name)

Players are allocated to teams depending on the allocate_mode setting

* cycle - players are added in a cycle motion to each team (one to team 1, one to team 2, etc)
* lowest - players are added to the team with the lowest number of players
* nil - players have to be invited

Defenses
========

Turrets
-------

Turrets automatically fire at enemy players and vechiles.

* The owner of the current area is the owner of the turret.
* If an area is unclaimed, the placer is the owner.

Mines and traps
---------------

Mines and traps can be placed in the game as defenses.

* Mine - blows up if ANYONE steps on it
* Cage trap - Locks a player in indestructible glass
* Lava trap - Locks a player in a foundian of lava

Fire arms
---------

The fire arms mod is installed

Commands
========

Admin only
----------
Uses priv "team"
* /ateam <name> - add a team called <name>.
* /team_owner <name> - make a player the mod or not off the team (toggle)
* (coming soon) /join <name> <team> - add player <name> to team <team>.
* (coming soon) /lock <team> - stop any players joining team <team>
* (coming soon) /unlock <team> - allow players to join team <team>

Players
-------
* /team - view team panel
* /list_teams - list all teams and their statistics
* /join <team> - join the team <team>