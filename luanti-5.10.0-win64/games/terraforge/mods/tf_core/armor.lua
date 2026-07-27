-- tf_core: Armor system
-- Helmet, Chestplate, Leggings, Boots for all 5 tiers
-- Damage reduction and durability

local S = minetest.get_translator("tf_core")

-- Armor tiers: {name, material, protection, durability, color}
local armor_tiers = {
    {name="leather", material="tf_core:leather", protection=1, durability=55, color={150,100,60}},
    {name="iron", material="tf_core:iron_ingot", protection=3, durability=165, color={200,200,210}},
    {name="gold", material="tf_core:gold_ingot", protection=2, durability=77, color={255,215,50}},
    {name="diamond", material="tf_core:diamond", protection=4, durability=363, color={100,230,255}},
}

-- Armor slot types
local armor_slots = {
    {name="helmet", hp=3, recipe_rows={
        {"", "", ""},
        {"", "", ""},
        {"", "", ""},
    }},
    {name="chestplate", hp=8, recipe_rows={
        {"", "", ""},
        {"", "", ""},
        {"", "", ""},
    }},
    {name="leggings", hp=6, recipe_rows={
        {"", "", ""},
        {"", "", ""},
        {"", "", ""},
    }},
    {name="boots", hp=3, recipe_rows={
        {"", "", ""},
        {"", "", ""},
        {"", "", ""},
    }},
}

-- Crafting patterns
local patterns = {
    helmet = {
        {1,1,1},
        {1,0,1},
        {0,0,0},
    },
    chestplate = {
        {1,0,1},
        {1,1,1},
        {1,1,1},
    },
    leggings = {
        {1,1,1},
        {0,1,0},
        {0,1,0},
    },
    boots = {
        {0,0,0},
        {1,0,1},
        {1,0,1},
    },
}

for _, tier in ipairs(armor_tiers) do
    for _, slot in ipairs(armor_slots) do
        local item_name = "tf_core:" .. slot.name .. "_" .. tier.name
        local desc = tier.name:sub(1,1):upper() .. tier.name:sub(2) .. " " ..
                     slot.name:sub(1,1):upper() .. slot.name:sub(2)

        -- Register armor as a tool with wear capability
        minetest.register_tool(item_name, {
            description = S(desc),
            inventory_image = item_name:gsub(":", "_") .. ".png",
            groups = {armor = 1, armor_heal = slot.hp * tier.protection, flammable = (tier.name == "leather" and 1 or 0)},
            tool_capabilities = {
                full_punch_interval = 1.0,
                max_drop_level = 0,
                groupcaps = {},
                damage_groups = {fleshy = 0},
            },
            wear = math.ceil(65535 / tier.durability),
            sound = {breaks = "default_tool_breaks"},
            on_place = function(itemstack, placer, pointed_thing)
                -- Basic armor equipping: right-click places it
                return minetest.item_place(itemstack, placer, pointed_thing)
            end,
        })

        -- Register crafting recipe
        local recipe = {}
        for y = 1, 3 do
            local row = {}
            for x = 1, 3 do
                if patterns[slot.name][y] and patterns[slot.name][y][x] == 1 then
                    table.insert(row, tier.material)
                else
                    table.insert(row, "")
                end
            end
            table.insert(recipe, row)
        end
        minetest.register_craft({
            output = item_name,
            recipe = recipe,
        })
    end
end

-- Damage reduction: when a player gets hit, reduce damage based on armor
minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if hp_change >= 0 then return hp_change end  -- only reduce damage (negative)
    local inv = player:get_inventory()
    if not inv then return hp_change end

    local total_protection = 0
    local armor_slot_names = {"head", "torso", "legs", "feet"}

    for _, slot_name in ipairs(armor_slot_names) do
        local stack = inv:get_stack(slot_name, 1)
        if not stack:is_empty() then
            local groups = minetest.get_item_group(stack:get_name(), "armor_heal")
            if groups and groups > 0 then
                total_protection = total_protection + groups
                -- Wear the armor
                local w = stack:get_wear()
                stack:set_wear(w + math.ceil(65535 / 200))
                if stack:get_wear() >= 65535 then
                    stack:clear()
                end
                inv:set_stack(slot_name, 1, stack)
            end
        end
    end

    if total_protection > 0 then
        local reduction = math.min(total_protection, math.abs(hp_change) - 1)
        hp_change = hp_change + reduction
    end

    return hp_change
end, true)

-- Give armor inventory slots on join
minetest.register_on_joinplayer(function(player)
    local inv = player:get_inventory()
    inv:set_size("head", 1)
    inv:set_size("torso", 1)
    inv:set_size("legs", 1)
    inv:set_size("feet", 1)
end)

minetest.log("action", "[tf_core] Armor loaded")
