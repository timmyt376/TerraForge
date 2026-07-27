-- tf_core: Player setup, HUD, and chat commands

local S = minetest.get_translator("tf_core")

-- Give starter items to new players
minetest.register_on_newplayer(function(player)
    local inv = player:get_inventory()
    inv:set_size("main", 8 * 4)
    inv:set_size("craft", 9)
    inv:set_size("craftresult", 1)

    inv:add_item("main", "tf_core:pick_stone")
    inv:add_item("main", "tf_core:shovel_stone")
    inv:add_item("main", "tf_core:axe_stone")
    inv:add_item("main", "tf_core:sword_stone")
    inv:add_item("main", "tf_core:torch 16")
    inv:add_item("main", "tf_core:planks 16")
    inv:add_item("main", "tf_core:bread 4")
end)

-- HUD setup on join
minetest.register_on_joinplayer(function(player)
    player:set_physics_override({
        speed = 1.0, jump = 1.0, gravity = 1.0,
    })
    player:set_hp(20)

    -- Crosshair
    player:hud_add({
        hud_elem_type = "image",
        position = {x = 0.5, y = 0.5},
        offset = {x = -8, y = -8},
        text = "tf_core_crosshair.png",
        scale = {x = 1, y = 1},
        alignment = {x = 0, y = 0},
    })

    -- Health bar hearts
    player:hud_add({
        hud_elem_type = "statbar",
        position = {x = 0.5, y = 0.96},
        text = "tf_core_heart.png",
        number = 20,
        max = 20,
        size = {x = 24, y = 24},
        offset = {x = -124, y = 0},
        alignment = {x = 0, y = 0},
        direction = 0,
    })

    -- Hunger bar
    player:hud_add({
        hud_elem_type = "statbar",
        position = {x = 0.5, y = 0.96},
        text = "tf_core_hunger.png",
        number = 20,
        max = 20,
        size = {x = 20, y = 20},
        offset = {x = 124, y = 0},
        alignment = {x = 0, y = 0},
        direction = 0,
    })

    -- Experience bar background
    player:hud_add({
        hud_elem_type = "image",
        position = {x = 0.5, y = 1},
        text = "tf_core_exp_bar_bg.png",
        scale = {x = 4, y = 1},
        alignment = {x = 0, y = 0},
        offset = {x = -146, y = -38},
    })
end)

-- Update health/hunger HUD periodically
minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local hp = player:get_hp()
        local huds = player:hud_get_all() or {}
        for _, hud in ipairs(huds) do
            if hud.hud_elem_type == "statbar" then
                if hud.position.y > 0.9 then  -- health/hunger bars
                    if hud.offset.x < 0 then  -- left side = health
                        player:hud_change(hud.id, "number", hp)
                    end
                end
            end
        end
    end
end)

-- ========== GLOBAL DEFAULTS ==========

local settings = minetest.settings
settings:set("mgv7_sparams", [[{
    lacunarity = 2.0, octaves = 6, persistence = 0.5,
    scale = 200.0, spread = 300.0
}]])
settings:set_bool("enable_damage", true)
settings:set_bool("creative_mode", false)
settings:set("time_speed", "72")

-- ========== CHAT COMMANDS ==========

minetest.register_chatcommand("day", {
    description = S("Set time to day"),
    func = function(name)
        minetest.set_timeofday(0.5)
        return true, "Set time to noon"
    end,
})

minetest.register_chatcommand("night", {
    description = S("Set time to night"),
    func = function(name)
        minetest.set_timeofday(0.0)
        return true, "Set time to midnight"
    end,
})

minetest.register_chatcommand("gamemode", {
    description = S("Toggle creative/survival mode"),
    params = "[creative|survival]",
    func = function(name, param)
        if param == "creative" then
            minetest.set_player_privs(name, {creative = true, fly = true, fast = true})
            return true, "Creative mode enabled"
        elseif param == "survival" then
            minetest.set_player_privs(name, {creative = false, fly = false, fast = false})
            return true, "Survival mode enabled"
        else
            return false, "Usage: /gamemode creative|survival"
        end
    end,
})

minetest.log("action", "[tf_core] Player and HUD loaded")
