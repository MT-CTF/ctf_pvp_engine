--[[
This file is part of the Firearms mod for Minetest.

Copyright (C) 2013, Diego Martínez <lkaezadl3@gmail.com>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
]]

firearmslib.register_bullet("firearms_guns:bullet_45", {
    description = ".45 Rounds";
    inventory_image = "firearms_bullet_45.png";
    damage = 4;
    power = 5;
});

firearmslib.register_firearm("firearms_guns:pistol_45", {
    description = ".45 Pistol";
    inventory_image = "firearms_pistol_45.png";
    bullets = "firearms_guns:bullet_45";
    clip_size = 10;
    spread = 0.020;
    crosshair_image = "firearms_crosshair_pistol.png";
    hud_image = "firearms_pistol_45_hud.png";
    sounds = {
        shoot = "firearms_pistol_45_shot";
		empty = "firearms_default_empty";
		reload = "firearms_default_reload";
    };
});

firearmslib.register_bullet("firearms_guns:bullet_556", {
    description = "5.56 Rifle Rounds";
    inventory_image = "firearms_bullet_556.png";
    damage = 6;
    power = 5;
    gravity = 0;
});

firearmslib.register_firearm("firearms_guns:m4", {
    description = "M4 Carbine";
    inventory_image = "firearms_m4.png";
    bullets = "firearms_guns:bullet_556";
    clip_size = 12;
    spread = 0.035;
    burst = 3;
    burst_interval = 0.15;
    wield_scale = {x=2,y=2,z=2};
    crosshair_image = "firearms_crosshair_rifle.png";
    hud_image = "firearms_m4_hud.png";
    sounds = {
        shoot = "firearms_m4_shot";
        empty = "firearms_default_empty";
        reload = "firearms_rifle_reload";
    };
});

firearmslib.register_bullet("firearms_guns:shell_12", {
    description = "12 Gauge Shell";
    inventory_image = "firearms_shell_12.png";
    damage = 2;
    power = 5;
    gravity = 0;
    pellets = 12;
    maxtimer = 0.3;
});

firearmslib.register_firearm("firearms_guns:m3", {
    description = "Benelli M3 Shotgun";
    inventory_image = "firearms_m3.png";
    bullets = "firearms_guns:shell_12";
    clip_size = 8;
    spread = 0.100;
    wield_scale = {x=2,y=2,z=2};
    crosshair_image = "firearms_crosshair_shotgun.png";
    hud_image = "firearms_m3_hud.png";
    sounds = {
        shoot = "firearms_m3_shot";
        empty = "firearms_default_empty";
        reload = "firearms_shotgun_reload";
    };
});

minetest.register_craft({
    output = 'firearms_guns:bullet_45 10';
    recipe = {
        { 'default:steel_ingot', 'default:steel_ingot' },
    };
});

minetest.register_craft({
    output = 'firearms_guns:bullet_556 10';
    recipe = {
        {'default:steel_ingot', 'default:steel_ingot', 'default:leaves'},
    };
});

minetest.register_craft({
    output = 'firearms_guns:shell_12 8';
    recipe = {
        { 'default:steel_ingot', '', '' },
        { 'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot' },
        { 'default:steel_ingot', '', '' },
    };
});

minetest.register_craft({
    output = 'firearms_guns:pistol_45';
    recipe = {
        { 'firearms_guns:bullet_45', 'default:steel_ingot', 'default:steel_ingot' },
        { '', 'default:stick', 'deafutl:wood' },
        { '', '', 'deafault:stick' },
    };
});

minetest.register_craft({
    output = 'firearms:m4';
    recipe = {
        { 'firearms:bullet_556', 'default:steel_ingot', 'default:steel_ingot' },
        { '', 'default:stick', 'default:wood' },
        { '', '', 'default:stick' },
    };
});

minetest.register_craft({
    output = 'firearms:m3';
    recipe = {
        { 'firearms:shell_12', 'default:steel_ingot', 'default:steel_ingot' },
        { '', 'default:stick', 'default:wood' },
        { '', '', 'default:stick' },
    };
});
