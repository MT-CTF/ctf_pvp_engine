CTF PvP Engine
==============

A highly modular framework for the Minetest game engine, in order to allow
the development of Capture the Flag / City vs City games. Good for any
sort of game where players can join teams - flags are optional, everything
is highly configurable.

Licenses
========

Created by: [rubenwardy](http://rubenwardy.com/).  
Copyright (c) 2013 - 2015  
**Code:** LGPL 2.1 or later.  
**Textures:** CC-BY-SA 3.0

ctf_flag/sounds/trumpet* by tobyk, license: CC-BY 3.0
from: http://freesound.org/people/tobyk/sounds/26198/

Modules
=======

* ctf
	* core - adds saving, loading and settings. All modules depend on this.
	* teams - add the concepts of teams and players. All modules except core depend on this.
	* diplomacy - adds inter team states of war, peace and alliances.
	  Requires ctf.teams
	* gui - adds the team gui on /team. Allows tabs to be registered.
	* hud - adds the name of the team in the TR of the screen, and sets the color
	        of  a player's name.
* ctf_chat - adds chat commands and chat channels.
* ctf_flag - adds flags and flag taking.
* ctf_match - adds the concept of winning, match build time,
              and reseting the map / setting up a new game.
              Requires ctf_flag
* ctf_protect - Adds node ownership / protection to teams. Requires ctf_flag.
* ctf_turret - Adds auto-firing turrets that fire on enemies.
