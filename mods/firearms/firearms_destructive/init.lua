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

-- Destructive weapons

firearmslib.register_bullet("firearms_destructive:he_40mm", {
    description = "40mm HE Rounds";
    inventory_image = "firearms_he_40mm.png";
    texture = "firearms_grenade_entity.png";
    damage = 5;
    power = 5;
    speed = 20;
    gravity = 20;
    explosion_range = 5;
    explosion_damage = 10;
    on_destroy = firearmslib.on_destroy_explode;
});

firearmslib.register_firearm("firearms_destructive:m79", {
    description = "M79 Grenade Launcher";
    inventory_image = "firearms_m79.png";
    bullets = "firearms_destructive:he_40mm";
    clip_size = 10;
    spread = 0.020;
    wield_scale = {x=2,y=2,z=2};
    crosshair_image = "firearms_crosshair_glauncher.png";
    hud_image = "firearms_m79_hud.png";
    sounds = {
        shoot = "firearms_m79_shot";
		empty = "firearms_default_empty";
		reload = "firearms_default_reload";
    };
});

firearmslib.register_bullet("firearms_destructive:rocket", {
    description = "Rocket";
    inventory_image = "firearms_rocket.png";
    texture = "firearms_rocket_entity.png";
    damage = 10;
    power = 5;
    speed = 25;
    gravity = 0;
    explosion_range = 7.5;
    explosion_damage = 6;
    leaves_smoke = true;
    on_destroy = firearmslib.on_destroy_explode;
});

firearmslib.register_firearm("firearms_destructive:bazooka", {
    description = "Bazooka";
    inventory_image = "firearms_bazooka.png";
    bullets = "firearms_destructive:rocket";
    clip_size = 5;
    spread = 0.035;
    wield_scale = {x=3,y=3,z=3};
    crosshair_image = "firearms_crosshair_rlauncher.png";
    hud_image = "firearms_bazooka_hud.png";
    sounds = {
        shoot = "firearms_m79_shot"; -- TODO: Find a better sound
		empty = "firearms_default_empty";
		--reload = "firearms_default_reload";
    };
});

minetest.register_craft({
    output = 'firearms_destructive:he_40mm';
    recipe = {
        { '', 'default:steel_ingot', '' },
        { 'default:steel_ingot', 'bucket:bucket_lava', 'default:steel_ingot' },
        { '', 'default:steel_ingot', '' },
    };
    replacements = { { "bucket:bucket_lava", "bucket:bucket_empty" } };
});

minetest.register_craft({
    output = 'firearms_destructive:rocket';
    recipe = {
        { 'default:steel_ingot', 'bucket:bucket_lava', 'default:steel_ingot' },
    };
    replacements = { { "bucket:bucket_lava", "bucket:bucket_empty" } };
});

minetest.register_craft({
    output = 'firearms_destructive:m79';
    recipe = {
        { 'firearms_destructive:he_40mm', 'default:steel_ingot', 'default:steel_ingot' },
        { '', 'default:stick', 'default:wood' },
        { '', '', 'default:stick' },
    };
});

minetest.register_craft({
    output = 'firearms_destructive:bazooka';
    recipe = {
        { 'firearms_destructive:rocket', 'default:steel_ingot', 'default:steel_ingot' },
        { '', 'default:stick', 'default:wood' },
        { '', '', 'default:stick' },
    };
});
