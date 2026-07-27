-- tf_core: All block (node) definitions
-- Minelike: Fully open Minecraft-like game

local S = minetest.get_translator("tf_core")

-- Global table for shared functions
tf_core = {}  -- luacheck: global

-- Helper to create node textures from a single color
-- Will be replaced with actual textures later
local function rgb(r, g, b)
    return ("%02x%02x%02x"):format(r, g, b)
end

-- ========== NATURAL BLOCKS ==========

-- Dirt
minetest.register_node("tf_core:dirt", {
    description = S("Dirt"),
    tiles = {"tf_core_dirt.png"},
    groups = {crumbly = 3, soil = 1, building_block = 1},
    sounds = default.node_sound_dirt_defaults(),
})

-- Grass Block
minetest.register_node("tf_core:grass", {
    description = S("Grass Block"),
    tiles = {"tf_core_grass_top.png", "tf_core_dirt.png", "tf_core_grass_side.png"},
    groups = {crumbly = 3, soil = 1, building_block = 1, grass_block = 1},
    sounds = default.node_sound_dirt_defaults(),
    drop = "tf_core:dirt",
})

-- Stone
minetest.register_node("tf_core:stone", {
    description = S("Stone"),
    tiles = {"tf_core_stone.png"},
    groups = {cracky = 2, stone = 1, building_block = 1},
    sounds = default.node_sound_stone_defaults(),
    drop = "tf_core:cobblestone",
})

-- Cobblestone
minetest.register_node("tf_core:cobblestone", {
    description = S("Cobblestone"),
    tiles = {"tf_core_cobblestone.png"},
    groups = {cracky = 2, building_block = 1},
    sounds = default.node_sound_stone_defaults(),
})

-- Stone Brick
minetest.register_node("tf_core:stonebrick", {
    description = S("Stone Bricks"),
    tiles = {"tf_core_stonebrick.png"},
    groups = {cracky = 2, building_block = 1},
    sounds = default.node_sound_stone_defaults(),
})

-- Bedrock
minetest.register_node("tf_core:bedrock", {
    description = S("Bedrock"),
    tiles = {"tf_core_bedrock.png"},
    groups = {unbreakable = 1, building_block = 1},
    sounds = default.node_sound_stone_defaults(),
})

-- Sand
minetest.register_node("tf_core:sand", {
    description = S("Sand"),
    tiles = {"tf_core_sand.png"},
    groups = {crumbly = 3, falling_node = 1, sand = 1, building_block = 1},
    sounds = default.node_sound_sand_defaults(),
})

-- Gravel
minetest.register_node("tf_core:gravel", {
    description = S("Gravel"),
    tiles = {"tf_core_gravel.png"},
    groups = {crumbly = 2, falling_node = 1, building_block = 1},
    sounds = default.node_sound_gravel_defaults(),
})

-- ========== WOOD & TREES ==========

-- Oak Log
minetest.register_node("tf_core:tree", {
    description = S("Oak Log"),
    tiles = {"tf_core_tree_top.png", "tf_core_tree_top.png", "tf_core_tree_side.png"},
    groups = {tree = 1, choppy = 2, flammable = 2, wood = 1, building_block = 1},
    sounds = default.node_sound_wood_defaults(),
})

-- Oak Planks
minetest.register_node("tf_core:planks", {
    description = S("Oak Planks"),
    tiles = {"tf_core_planks.png"},
    groups = {choppy = 2, flammable = 2, wood = 1, building_block = 1},
    sounds = default.node_sound_wood_defaults(),
})

-- Oak Leaves
minetest.register_node("tf_core:leaves", {
    description = S("Oak Leaves"),
    tiles = {"tf_core_leaves.png"},
    groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
    sounds = default.node_sound_leaves_defaults(),
    drop = {
        max_items = 1,
        items = {
            {items = {"tf_core:sapling"}, rarity = 20},
            {items = {"tf_core:leaves"}},
        }
    },
})

-- Oak Sapling
minetest.register_node("tf_core:sapling", {
    description = S("Oak Sapling"),
    tiles = {"tf_core_sapling.png"},
    groups = {snappy = 2, dig_immediate = 3, flammable = 2, attached_node = 1, sapling = 1},
    sounds = default.node_sound_leaves_defaults(),
    drawtype = "plantlike",
    paramtype = "light",
    walkable = false,
    selection_box = {
        type = "fixed",
        fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3},
    },
})

-- Stick (item)
minetest.register_craftitem("tf_core:stick", {
    description = S("Stick"),
    inventory_image = "tf_core_stick.png",
    groups = {stick = 1},
})

-- ========== ORES ==========

-- Coal Ore
minetest.register_node("tf_core:coal_ore", {
    description = S("Coal Ore"),
    tiles = {"tf_core_stone.png^tf_core_ore_coal.png"},
    groups = {cracky = 2, ore = 1},
    sounds = default.node_sound_stone_defaults(),
    drop = "tf_core:coal_lump",
})

-- Iron Ore
minetest.register_node("tf_core:iron_ore", {
    description = S("Iron Ore"),
    tiles = {"tf_core_stone.png^tf_core_ore_iron.png"},
    groups = {cracky = 1, ore = 1, level = 2},
    sounds = default.node_sound_stone_defaults(),
    drop = "tf_core:iron_ore",
})

-- Gold Ore
minetest.register_node("tf_core:gold_ore", {
    description = S("Gold Ore"),
    tiles = {"tf_core_stone.png^tf_core_ore_gold.png"},
    groups = {cracky = 1, ore = 1, level = 3},
    sounds = default.node_sound_stone_defaults(),
    drop = "tf_core:gold_ore",
})

-- Diamond Ore
minetest.register_node("tf_core:diamond_ore", {
    description = S("Diamond Ore"),
    tiles = {"tf_core_stone.png^tf_core_ore_diamond.png"},
    groups = {cracky = 1, ore = 1, level = 3},
    sounds = default.node_sound_stone_defaults(),
    drop = "tf_core:diamond",
})

-- ========== MINERAL BLOCKS ==========

minetest.register_node("tf_core:coal_block", {
    description = S("Block of Coal"),
    tiles = {"tf_core_coal_block.png"},
    groups = {cracky = 2, building_block = 1},
    sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("tf_core:iron_block", {
    description = S("Block of Iron"),
    tiles = {"tf_core_iron_block.png"},
    groups = {cracky = 1, building_block = 1},
    sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("tf_core:gold_block", {
    description = S("Block of Gold"),
    tiles = {"tf_core_gold_block.png"},
    groups = {cracky = 1, building_block = 1},
    sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("tf_core:diamond_block", {
    description = S("Block of Diamond"),
    tiles = {"tf_core_diamond_block.png"},
    groups = {cracky = 1, building_block = 1},
    sounds = default.node_sound_metal_defaults(),
})

-- ========== CRAFTING & UTILITY ==========

-- Crafting Table
minetest.register_node("tf_core:crafting_table", {
    description = S("Crafting Table"),
    tiles = {"tf_core_crafting_top.png", "tf_core_planks.png", "tf_core_crafting_side.png"},
    groups = {choppy = 2, flammable = 2, building_block = 1},
    sounds = default.node_sound_wood_defaults(),
    on_rightclick = function(pos, node, clicker)
        minetest.show_formspec(clicker:get_player_name(), "tf_core:crafting_table",
            get_crafting_formspec())
    end,
})

function get_crafting_formspec()
    return "size[8,7.5]" ..
        "list[current_player;main;0,3.5;8,4;]" ..
        "list[current_name;craft;2,1;3,3;]" ..
        "list[current_name;output;6,1.5;1,1;]" ..
        "label[0,0;Crafting]" ..
        "listring[current_player;main]" ..
        "listring[current_name;craft]"
end

minetest.register_craft({
    output = "tf_core:crafting_table",
    recipe = {
        {"group:wood", "group:wood"},
        {"group:wood", "group:wood"},
    },
})

-- Furnace
minetest.register_node("tf_core:furnace", {
    description = S("Furnace"),
    tiles = {"tf_core_furnace_top.png", "tf_core_furnace_top.png",
             "tf_core_furnace_side.png", "tf_core_furnace_side.png",
             "tf_core_furnace_side.png", "tf_core_furnace_front.png"},
    groups = {cracky = 2, building_block = 1},
    sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("tf_core:furnace_active", {
    description = S("Furnace"),
    tiles = {"tf_core_furnace_top.png", "tf_core_furnace_top.png",
             "tf_core_furnace_side.png", "tf_core_furnace_side.png",
             "tf_core_furnace_side.png", "tf_core_furnace_front_active.png"},
    groups = {cracky = 2, building_block = 1, not_in_creative_inventory = 1},
    sounds = default.node_sound_stone_defaults(),
    light_source = 13,
    drop = "tf_core:furnace",
})

-- Chest
minetest.register_node("tf_core:chest", {
    description = S("Chest"),
    tiles = {"tf_core_chest_top.png", "tf_core_chest_top.png",
             "tf_core_chest_side.png", "tf_core_chest_side.png",
             "tf_core_chest_side.png", "tf_core_chest_front.png"},
    groups = {choppy = 2, flammable = 2, building_block = 1},
    sounds = default.node_sound_wood_defaults(),
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec",
            "size[8,9]" ..
            "list[current_name;main;0,0;8,4;]" ..
            "list[current_player;main;0,5;8,4;]" ..
            "listring[current_name;main]" ..
            "listring[current_player;main]")
        meta:set_string("infotext", "Chest")
        local inv = meta:get_inventory()
        inv:set_size("main", 8 * 4)
    end,
    can_dig = function(pos, player)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        return inv:is_empty("main")
    end,
})

-- ========== RAW MATERIALS (items) ==========

minetest.register_craftitem("tf_core:coal_lump", {
    description = S("Coal"),
    inventory_image = "tf_core_coal_lump.png",
    groups = {coal = 1},
})

minetest.register_craftitem("tf_core:iron_ingot", {
    description = S("Iron Ingot"),
    inventory_image = "tf_core_iron_ingot.png",
})

minetest.register_craftitem("tf_core:gold_ingot", {
    description = S("Gold Ingot"),
    inventory_image = "tf_core_gold_ingot.png",
})

minetest.register_craftitem("tf_core:diamond", {
    description = S("Diamond"),
    inventory_image = "tf_core_diamond.png",
})

-- ========== TORCH ==========

minetest.register_node("tf_core:torch", {
    description = S("Torch"),
    drawtype = "torchlike",
    tiles = {"tf_core_torch.png"},
    inventory_image = "tf_core_torch_inv.png",
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    light_source = 14,
    groups = {choppy = 2, dig_immediate = 3, flammable = 1, attached_node = 1},
    sounds = default.node_sound_wood_defaults(),
    selection_box = {
        type = "wallmounted",
        wall_side = {-0.1, -0.4, -0.1, 0.1, 0.4, 0.1},
    },
})

-- ========== LIQUIDS ==========

minetest.register_node("tf_core:water_source", {
    description = S("Water"),
    tiles = {"tf_core_water.png"},
    use_texture_alpha = "blend",
    drawtype = "liquid",
    waving = 1,
    paramtype = "light",
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    liquidtype = "source",
    liquid_alternative_flowing = "tf_core:water_flowing",
    liquid_alternative_source = "tf_core:water_source",
    liquid_viscosity = 1,
    liquid_range = 7,
    groups = {water = 3, liquid = 3, puts_out_fire = 1},
    sounds = default.node_sound_water_defaults(),
    post_effect_color = {a = 100, r = 30, g = 60, b = 140},
})

minetest.register_node("tf_core:water_flowing", {
    description = S("Flowing Water"),
    tiles = {"tf_core_water.png"},
    use_texture_alpha = "blend",
    drawtype = "flowingliquid",
    waving = 1,
    paramtype = "light",
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    liquidtype = "flowing",
    liquid_alternative_flowing = "tf_core:water_flowing",
    liquid_alternative_source = "tf_core:water_source",
    liquid_viscosity = 1,
    liquid_range = 7,
    groups = {water = 3, liquid = 3, puts_out_fire = 1, not_in_creative_inventory = 1},
    sounds = default.node_sound_water_defaults(),
    post_effect_color = {a = 100, r = 30, g = 60, b = 140},
})

-- ========== GLASS ==========

minetest.register_node("tf_core:glass", {
    description = S("Glass"),
    tiles = {"tf_core_glass.png"},
    drawtype = "glasslike",
    paramtype = "light",
    sunlight_propagates = true,
    groups = {snappy = 2, building_block = 1},
    sounds = default.node_sound_glass_defaults(),
})

-- ========== SNOW & ICE ==========

minetest.register_node("tf_core:snow", {
    description = S("Snow"),
    tiles = {"tf_core_snow.png"},
    groups = {crumbly = 3, building_block = 1, snowy = 1},
    sounds = default.node_sound_snow_defaults(),
})

minetest.register_node("tf_core:ice", {
    description = S("Ice"),
    tiles = {"tf_core_ice.png"},
    drawtype = "glasslike",
    paramtype = "light",
    groups = {cracky = 3, building_block = 1},
    sounds = default.node_sound_glass_defaults(),
})

-- ========== EXTRA DECORATION ==========

minetest.register_node("tf_core:brick", {
    description = S("Brick Block"),
    tiles = {"tf_core_brick.png"},
    groups = {cracky = 2, building_block = 1},
    sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("tf_core:bookshelf", {
    description = S("Bookshelf"),
    tiles = {"tf_core_planks.png", "tf_core_planks.png", "tf_core_bookshelf.png"},
    groups = {choppy = 2, flammable = 2, building_block = 1},
    sounds = default.node_sound_wood_defaults(),
})

-- ========== FLOWERS ==========

local flowers = {
    {"tf_core:dandelion", S("Dandelion"), "tf_core_dandelion.png"},
    {"tf_core:rose", S("Rose"), "tf_core_rose.png"},
}

for _, f in ipairs(flowers) do
    minetest.register_node(f[1], {
        description = f[2],
        tiles = {f[3]},
        groups = {snappy = 3, flower = 1, flammable = 2, attached_node = 1, dig_immediate = 3, color_flora = 1},
        sounds = default.node_sound_leaves_defaults(),
        drawtype = "plantlike",
        walkable = false,
        paramtype = "light",
        selection_box = {
            type = "fixed",
            fixed = {-0.15, -0.5, -0.15, 0.15, 0.3, 0.15},
        },
    })
end

-- ========== ABMS ==========

-- Grow saplings into trees
minetest.register_abm({
    label = "Tree growth",
    nodenames = {"tf_core:sapling"},
    interval = 60,
    chance = 20,
    action = function(pos, node)
        tf_core.grow_tree(pos)
    end,
})

-- Leaf decay
minetest.register_abm({
    label = "Leaf decay",
    nodenames = {"tf_core:leaves"},
    interval = 10,
    chance = 5,
    action = function(pos, node)
        local has_log = minetest.find_node_near(pos, 4, {"tf_core:tree"})
        if not has_log then
            minetest.remove_node(pos)
        end
    end,
})

-- ========== TREE GROWTH HELPER ==========

function tf_core.grow_tree(pos)
    local height = 4 + math.random(2)
    local trunk = "tf_core:tree"
    local leaves = "tf_core:leaves"

    for y = 1, height do
        local p = {x = pos.x, y = pos.y + y, z = pos.z}
        local node = minetest.get_node(p)
        if node.name == "air" or node.name == "ignore" then
            minetest.set_node(p, {name = trunk})
        end
    end

    local top = pos.y + height
    for dx = -2, 2 do
        for dz = -2, 2 do
            for dy = -1, 1 do
                local dist = math.abs(dx) + math.abs(dz) + math.abs(dy)
                if dist <= 3 and not (dx == 0 and dz == 0 and dy == 0) then
                    local p = {x = pos.x + dx, y = top + dy, z = pos.z + dz}
                    if minetest.get_node(p).name == "air" then
                        minetest.set_node(p, {name = leaves})
                    end
                end
            end
        end
    end
end

minetest.log("action", "[tf_core] Nodes loaded")
