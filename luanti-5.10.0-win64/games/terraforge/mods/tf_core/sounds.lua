-- tf_core: Sound definitions
-- Sounds auto-loaded from sounds/ directory by filename

local S = minetest.get_translator("tf_core")

-- Node sound tables for digging/placing
function tf_core.node_sound_defaults()
    return {
        dug = {name = "tf_core_dig_dirt", gain = 0.5},
        dig = {name = "tf_core_dig_dirt", gain = 0.3},
        place = {name = "tf_core_dig_dirt", gain = 0.4},
    }
end

function tf_core.node_sound_stone_defaults()
    return {
        dug = {name = "tf_core_dig_stone", gain = 0.4},
        dig = {name = "tf_core_dig_stone", gain = 0.2},
        place = {name = "tf_core_dig_stone", gain = 0.3},
    }
end

function tf_core.node_sound_wood_defaults()
    return {
        dug = {name = "tf_core_dig_wood", gain = 0.5},
        dig = {name = "tf_core_dig_wood", gain = 0.3},
        place = {name = "tf_core_dig_wood", gain = 0.4},
    }
end

function tf_core.node_sound_sand_defaults()
    return {
        dug = {name = "tf_core_dig_sand", gain = 0.4},
        dig = {name = "tf_core_dig_sand", gain = 0.2},
        place = {name = "tf_core_dig_sand", gain = 0.3},
    }
end

function tf_core.node_sound_gravel_defaults()
    return {
        dug = {name = "tf_core_dig_gravel", gain = 0.5},
        dig = {name = "tf_core_dig_gravel", gain = 0.3},
        place = {name = "tf_core_dig_gravel", gain = 0.4},
    }
end

function tf_core.node_sound_snow_defaults()
    return {
        dug = {name = "tf_core_dig_snow", gain = 0.4},
        dig = {name = "tf_core_dig_snow", gain = 0.2},
        place = {name = "tf_core_dig_snow", gain = 0.3},
    }
end

-- Player hurt sound
minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if hp_change < 0 then
        minetest.sound_play("tf_core_hurt", {to_player=player:get_player_name(), gain=0.5})
    end
    return hp_change
end, true)

minetest.log("action", "[tf_core] Sounds loaded")
