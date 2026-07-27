-- tf_core: TerraForge core mod
-- Loads all sub-modules in order

local modpath = minetest.get_modpath("tf_core")

-- Sound defaults (compatible with minetest_game's default mod)
local function ms(s)
    return minetest.get_modpath("sounds") and s or nil
end

-- Declare global table for minetest_game compatibility
default = {}  -- luacheck: global
default.node_sound_dirt_defaults = function()
    return {
        footstep = {name = ms("default_grass_footstep") or "", gain = 0.2},
        dug = {name = ms("default_grass_footstep") or "", gain = 0.25},
        dig = {name = ms("default_dig_crumbly") or "", gain = 0.2},
        place = {name = ms("default_place_node_hard") or "", gain = 1.0},
    }
end

default.node_sound_stone_defaults = function()
    return {
        footstep = {name = ms("default_stone_footstep") or "", gain = 0.2},
        dug = {name = ms("default_stone_footstep") or "", gain = 0.25},
        dig = {name = ms("default_dig_cracky") or "", gain = 0.2},
        place = {name = ms("default_place_node_hard") or "", gain = 1.0},
    }
end

default.node_sound_wood_defaults = function()
    return {
        footstep = {name = ms("default_wood_footstep") or "", gain = 0.2},
        dug = {name = ms("default_wood_footstep") or "", gain = 0.25},
        dig = {name = ms("default_dig_choppy") or "", gain = 0.2},
        place = {name = ms("default_place_node_hard") or "", gain = 1.0},
    }
end

default.node_sound_leaves_defaults = function()
    return {
        footstep = {name = ms("default_grass_footstep") or "", gain = 0.2},
        dug = {name = ms("default_grass_footstep") or "", gain = 0.25},
        dig = {name = ms("default_dig_crumbly") or "", gain = 0.2},
        place = {name = ms("default_place_node_hard") or "", gain = 1.0},
    }
end

default.node_sound_sand_defaults = function()
    return {
        footstep = {name = ms("default_sand_footstep") or "", gain = 0.2},
        dug = {name = ms("default_sand_footstep") or "", gain = 0.25},
        dig = {name = ms("default_dig_crumbly") or "", gain = 0.2},
        place = {name = ms("default_place_node_hard") or "", gain = 1.0},
    }
end

default.node_sound_gravel_defaults = function()
    return {
        footstep = {name = ms("default_gravel_footstep") or "", gain = 0.2},
        dug = {name = ms("default_gravel_footstep") or "", gain = 0.25},
        dig = {name = ms("default_dig_crumbly") or "", gain = 0.2},
        place = {name = ms("default_place_node_hard") or "", gain = 1.0},
    }
end

default.node_sound_water_defaults = function()
    return {
        footstep = {name = "", gain = 0.1},
        dug = {name = "", gain = 0.1},
        dig = {name = "", gain = 0.1},
        place = {name = "", gain = 0.1},
    }
end

default.node_sound_glass_defaults = function()
    return {
        footstep = {name = ms("default_glass_footstep") or "", gain = 0.2},
        dug = {name = ms("default_glass_footstep") or "", gain = 0.25},
        dig = {name = ms("default_dig_cracky") or "", gain = 0.2},
        place = {name = ms("default_place_node_hard") or "", gain = 1.0},
    }
end

default.node_sound_snow_defaults = function()
    return {
        footstep = {name = ms("default_snow_footstep") or "", gain = 0.2},
        dug = {name = ms("default_snow_footstep") or "", gain = 0.25},
        dig = {name = ms("default_dig_crumbly") or "", gain = 0.2},
        place = {name = ms("default_place_node_hard") or "", gain = 1.0},
    }
end

default.node_sound_metal_defaults = function()
    return {
        footstep = {name = ms("default_metal_footstep") or "", gain = 0.2},
        dug = {name = ms("default_metal_footstep") or "", gain = 0.25},
        dig = {name = ms("default_dig_cracky") or "", gain = 0.2},
        place = {name = ms("default_place_node_hard") or "", gain = 1.0},
    }
end

-- Load sub-modules
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/tools.lua")
dofile(modpath .. "/crafting.lua")
dofile(modpath .. "/furnace.lua")
dofile(modpath .. "/armor.lua")
dofile(modpath .. "/sounds.lua")
dofile(modpath .. "/player.lua")

minetest.log("action", "[tf_core] TerraForge core loaded")
