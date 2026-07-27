-- tf_core: Functional furnace with GUI
-- Provides smelting with fuel management and progress bar

local S = minetest.get_translator("tf_core")

-- Fuel values (cooking time units per item)
local function get_fuel_value(item)
    local name = item:get_name()
    if name == "tf_core:coal_lump" then return 80 end
    if name == "tf_core:coal_block" then return 800 end
    if name == "tf_core:tree" then return 60 end
    if name == "tf_core:planks" then return 15 end
    if name == "tf_core:stick" then return 5 end
    if minetest.get_item_group(name, "wood") > 0 then return 10 end
    return 0
end

-- Smelting recipes
local recipes = {
    {"tf_core:iron_ore", "tf_core:iron_ingot", 5},
    {"tf_core:gold_ore", "tf_core:gold_ingot", 5},
    {"tf_core:sand", "tf_core:glass", 3},
    {"tf_core:porkchop_raw", "tf_core:porkchop_cooked", 5},
    {"tf_core:beef_raw", "tf_core:beef_cooked", 5},
    {"tf_core:chicken_raw", "tf_core:chicken_cooked", 5},
    {"tf_core:mutton_raw", "tf_core:mutton_cooked", 5},
}

-- Formspec builder
local function furnace_formspec(active, src_percent)
    local src_bar = ""
    if active and src_percent then
        src_bar = "image[2.2,1.2;1,1;default_furnace_fire_bg.png^[lowpart:" ..
                  math.floor(src_percent * 100 + 0.5) .. ":default_furnace_fire_fg.png]"
    end
    return "size[8,8.5]" ..
           "list[current_name;fuel;2,3;1,1;]" ..
           "list[current_name;src;2,1;1,1;]" ..
           "list[current_name;dst;5,1;2,2;]" ..
           "list[current_player;main;0,5;8,4;]" ..
           src_bar ..
           "label[0,0;Furnace]" ..
           "listring[current_name;dst]" ..
           "listring[current_player;main]" ..
           "listring[current_name;fuel]" ..
           "listring[current_name;src]"
end

-- Shared furnace timer logic
local function furnace_timer(pos, elapsed)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local src = inv:get_stack("src", 1)
    local fuel = inv:get_stack("fuel", 1)
    local dst = inv:get_stack("dst", 1)
    local fuel_time = meta:get_float("fuel_time")
    local src_time = meta:get_float("src_time")

    -- Find matching recipe
    local recipe = nil
    for _, r in ipairs(recipes) do
        if src:get_name() == r[1] then
            recipe = r; break
        end
    end

    local was_active = meta:get_int("active") == 1

    if recipe and (dst:get_name() == "" or dst:get_name() == recipe[2]) and dst:get_count() < 99 then
        local cook_time = recipe[3]

        -- Need fuel
        if fuel_time <= 0 then
            local fv = get_fuel_value(fuel)
            if fv > 0 then
                fuel:take_item()
                inv:set_stack("fuel", 1, fuel)
                fuel_time = fv
            end
        end

        if fuel_time > 0 then
            local step = math.min(elapsed, fuel_time, cook_time - src_time)
            src_time = src_time + step
            fuel_time = fuel_time - step

            if src_time >= cook_time then
                -- Smelt!
                src:take_item()
                inv:set_stack("src", 1, src)
                if dst:get_name() == "" then
                    inv:set_stack("dst", 1, recipe[2])
                else
                    dst:set_count(dst:get_count() + 1)
                    inv:set_stack("dst", 1, dst)
                end
                src_time = 0
            end

            meta:set_float("fuel_time", fuel_time)
            meta:set_float("src_time", src_time)
            meta:set_int("active", 1)

            -- Update formspec with progress
            local pct = src_time / cook_time
            meta:set_string("formspec", furnace_formspec(true, pct))

            -- Swap to active visual if needed
            if not was_active then
                minetest.swap_node(pos, {name = "tf_core:furnace_active", param2 = minetest.get_node(pos).param2})
                meta:set_string("infotext", "Furnace (lit)")
            end

            minetest.get_node_timer(pos):start(1.0)
            return false
        end
    end

    -- Not active - turn off
    meta:set_float("fuel_time", 0)
    meta:set_float("src_time", 0)
    meta:set_int("active", 0)
    meta:set_string("formspec", furnace_formspec(false))
    if was_active then
        minetest.swap_node(pos, {name = "tf_core:furnace", param2 = minetest.get_node(pos).param2})
        meta:set_string("infotext", "Furnace")
    end
    minetest.get_node_timer(pos):start(3.0) -- check again in 3s
    return false
end

-- Common on_construct
local function furnace_construct(pos)
    local meta = minetest.get_meta(pos)
    meta:set_string("formspec", furnace_formspec(false))
    meta:set_string("infotext", "Furnace")
    local inv = meta:get_inventory()
    inv:set_size("fuel", 1)
    inv:set_size("src", 1)
    inv:set_size("dst", 4)
end

local function furnace_put_take(pos)
    minetest.get_node_timer(pos):start(1.0)
end

-- Register normal furnace (overrides nodes.lua registration)
minetest.register_node("tf_core:furnace", {
    description = S("Furnace"),
    tiles = {"tf_core_furnace_top.png", "tf_core_furnace_top.png",
             "tf_core_furnace_side.png", "tf_core_furnace_side.png",
             "tf_core_furnace_side.png", "tf_core_furnace_front.png"},
    groups = {cracky = 2, building_block = 1},
    sounds = default.node_sound_stone_defaults(),
    on_construct = furnace_construct,
    on_metadata_inventory_move = furnace_put_take,
    on_metadata_inventory_put = furnace_put_take,
    on_metadata_inventory_take = furnace_put_take,
    on_timer = furnace_timer,
})

-- Register active furnace
minetest.register_node("tf_core:furnace_active", {
    description = S("Furnace"),
    tiles = {"tf_core_furnace_top.png", "tf_core_furnace_top.png",
             "tf_core_furnace_side.png", "tf_core_furnace_side.png",
             "tf_core_furnace_side.png", "tf_core_furnace_front_active.png"},
    groups = {cracky = 2, building_block = 1, not_in_creative_inventory = 1},
    sounds = default.node_sound_stone_defaults(),
    light_source = 13,
    drop = "tf_core:furnace",
    on_construct = furnace_construct,
    on_metadata_inventory_move = furnace_put_take,
    on_metadata_inventory_put = furnace_put_take,
    on_metadata_inventory_take = furnace_put_take,
    on_timer = furnace_timer,
})

minetest.log("action", "[tf_core] Furnace loaded")
