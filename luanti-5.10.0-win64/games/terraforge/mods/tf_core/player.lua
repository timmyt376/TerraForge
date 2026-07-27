-- tf_core: Player setup and HUD

local S = minetest.get_translator("tf_core")

-- Give starter items to new players
minetest.register_on_newplayer(function(player)
    local inv = player:get_inventory()
    inv:set_size("main", 8 * 4)
    inv:set_size("craft", 9)
    inv:set_size("craftresult", 1)

    -- Starter tools
    inv:add_item("main", "tf_core:pick_stone")
    inv:add_item("main", "tf_core:shovel_stone")
    inv:add_item("main", "tf_core:axe_stone")
    inv:add_item("main", "tf_core:sword_stone")
    inv:add_item("main", "tf_core:torch 16")
    inv:add_item("main", "tf_core:planks 16")
end)

-- Set player physics (Minecraft-like)
minetest.register_on_joinplayer(function(player)
    player:set_physics_override({
        speed = 1.0,
        jump = 1.0,
        gravity = 1.0,
    })
    player:set_hp(20)
end)

-- ========== GLOBAL DEFAULTS ==========

-- Set default game settings
local settings = minetest.settings
settings:set("mgv7_sparams", [[{
    lacunarity = 2.0,
    octaves = 6,
    persistence = 0.5,
    scale = 200.0,
    spread = 300.0
}]])
settings:set_bool("enable_damage", true)
settings:set_bool("creative_mode", false)
settings:set("time_speed", "72") -- 20 min day/night cycle

-- Override chat prefix to be Minecraft-like
settings:set("default_game", "minelike")

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

minetest.log("action", "[tf_core] Player setup loaded")
