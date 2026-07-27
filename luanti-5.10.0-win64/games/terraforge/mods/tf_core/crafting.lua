-- tf_core: All crafting recipes

-- ========== BASIC BLOCK RECIPES ==========

-- Planks from logs
minetest.register_craft({
    output = "tf_core:planks 4",
    recipe = {
        {"tf_core:tree"},
    },
})

-- Stick from planks
minetest.register_craft({
    output = "tf_core:stick 4",
    recipe = {
        {"tf_core:planks"},
        {"tf_core:planks"},
    },
})

-- Cobblestone -> Stone Bricks
minetest.register_craft({
    output = "tf_core:stonebrick 4",
    recipe = {
        {"tf_core:cobblestone", "tf_core:cobblestone"},
        {"tf_core:cobblestone", "tf_core:cobblestone"},
    },
})

-- Brick
minetest.register_craft({
    output = "tf_core:brick 4",
    recipe = {
        {"tf_core:cobblestone", "tf_core:cobblestone"},
        {"tf_core:cobblestone", "tf_core:cobblestone"},
    },
})

-- Glass (smelt sand)
minetest.register_craft({
    type = "cooking",
    output = "tf_core:glass",
    recipe = "tf_core:sand",
    cooktime = 3,
})

-- Bookshelf
minetest.register_craft({
    output = "tf_core:bookshelf",
    recipe = {
        {"tf_core:planks", "tf_core:planks", "tf_core:planks"},
        {"group:wood", "group:wood", "group:wood"},
        {"tf_core:planks", "tf_core:planks", "tf_core:planks"},
    },
})

-- ========== STORAGE BLOCKS ==========

-- Chest
minetest.register_craft({
    output = "tf_core:chest",
    recipe = {
        {"group:wood", "group:wood", "group:wood"},
        {"group:wood", "", "group:wood"},
        {"group:wood", "group:wood", "group:wood"},
    },
})

-- ========== ORE SMELTING ==========

minetest.register_craft({
    type = "cooking",
    output = "tf_core:iron_ingot",
    recipe = "tf_core:iron_ore",
    cooktime = 5,
})

minetest.register_craft({
    type = "cooking",
    output = "tf_core:gold_ingot",
    recipe = "tf_core:gold_ore",
    cooktime = 5,
})

-- ========== MINERAL BLOCKS ==========

minetest.register_craft({
    output = "tf_core:coal_block",
    recipe = {
        {"tf_core:coal_lump", "tf_core:coal_lump"},
        {"tf_core:coal_lump", "tf_core:coal_lump"},
    },
})

minetest.register_craft({
    output = "tf_core:iron_block",
    recipe = {
        {"tf_core:iron_ingot", "tf_core:iron_ingot"},
        {"tf_core:iron_ingot", "tf_core:iron_ingot"},
    },
})

minetest.register_craft({
    output = "tf_core:gold_block",
    recipe = {
        {"tf_core:gold_ingot", "tf_core:gold_ingot"},
        {"tf_core:gold_ingot", "tf_core:gold_ingot"},
    },
})

minetest.register_craft({
    output = "tf_core:diamond_block",
    recipe = {
        {"tf_core:diamond", "tf_core:diamond"},
        {"tf_core:diamond", "tf_core:diamond"},
    },
})

-- Reverse: blocks back to materials
minetest.register_craft({
    output = "tf_core:coal_lump 4",
    recipe = {{"tf_core:coal_block"}},
})

minetest.register_craft({
    output = "tf_core:iron_ingot 4",
    recipe = {{"tf_core:iron_block"}},
})

minetest.register_craft({
    output = "tf_core:gold_ingot 4",
    recipe = {{"tf_core:gold_block"}},
})

minetest.register_craft({
    output = "tf_core:diamond 4",
    recipe = {{"tf_core:diamond_block"}},
})

-- ========== TOOL RECIPES ==========

local tool_recipes = {
    pick = {
        {"group:wood", "group:wood", "group:wood"},
        {"", "tf_core:stick", ""},
        {"", "tf_core:stick", ""},
    },
    shovel = {
        {"group:wood"},
        {"tf_core:stick"},
        {"tf_core:stick"},
    },
    axe = {
        {"group:wood", "group:wood"},
        {"group:wood", "tf_core:stick"},
        {"", "tf_core:stick"},
    },
    sword = {
        {"group:wood"},
        {"group:wood"},
        {"tf_core:stick"},
    },
    hoe = {
        {"group:wood", "group:wood"},
        {"", "tf_core:stick"},
        {"", "tf_core:stick"},
    },
}

for _, tool_name in ipairs({"pick", "shovel", "axe", "sword", "hoe"}) do
    local tiers_tool = {"wood", "stone", "iron", "gold", "diamond"}
    local materials = {"group:wood", "tf_core:cobblestone", "tf_core:iron_ingot", "tf_core:gold_ingot", "tf_core:diamond"}

    for i, tier in ipairs(tiers_tool) do
        -- Get the recipe template
        local recipe = {}
        for _, row in ipairs(tool_recipes[tool_name]) do
            local new_row = {}
            for _, item in ipairs(row) do
                if item == "group:wood" then
                    table.insert(new_row, materials[i])
                else
                    table.insert(new_row, item)
                end
            end
            table.insert(recipe, new_row)
        end

        minetest.register_craft({
            output = "tf_core:" .. tool_name .. "_" .. tier,
            recipe = recipe,
        })
    end
end

-- ========== TORCH ==========

minetest.register_craft({
    output = "tf_core:torch 4",
    recipe = {
        {"tf_core:coal_lump"},
        {"tf_core:stick"},
    },
})

-- ========== FURNACE ==========

minetest.register_craft({
    output = "tf_core:furnace",
    recipe = {
        {"tf_core:cobblestone", "tf_core:cobblestone", "tf_core:cobblestone"},
        {"tf_core:cobblestone", "", "tf_core:cobblestone"},
        {"tf_core:cobblestone", "tf_core:cobblestone", "tf_core:cobblestone"},
    },
})

-- ========== GLASS ==========

minetest.register_craft({
    output = "minecraft:glass 2",
    type = "cooking",
    recipe = "tf_core:sand",
    cooktime = 3,
})

minetest.log("action", "[tf_core] Crafting loaded")

-- ========== FOOD SMELTING ==========

minetest.register_craft({
    type = "cooking",
    output = "tf_core:porkchop_cooked",
    recipe = "tf_core:porkchop_raw",
    cooktime = 5,
})
minetest.register_craft({
    type = "cooking",
    output = "tf_core:beef_cooked",
    recipe = "tf_core:beef_raw",
    cooktime = 5,
})
minetest.register_craft({
    type = "cooking",
    output = "tf_core:chicken_cooked",
    recipe = "tf_core:chicken_raw",
    cooktime = 5,
})
minetest.register_craft({
    type = "cooking",
    output = "tf_core:mutton_cooked",
    recipe = "tf_core:mutton_raw",
    cooktime = 5,
})

-- Bread
minetest.register_craft({
    output = "tf_core:bread 2",
    recipe = {
        {"tf_core:planks", "tf_core:planks", "tf_core:planks"},
    },
})
