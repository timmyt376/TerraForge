-- tf_world: World generation for TerraForge
-- Biomes, ores, trees, decorations

-- ========== BIOMES ==========

-- Grassland biome (default overworld)
minetest.register_biome({
    name = "grassland",
    node_top = "tf_core:grass",
    depth_top = 1,
    node_filler = "tf_core:dirt",
    depth_filler = 3,
    node_stone = "tf_core:stone",
    node_water_top = "tf_core:water_source",
    depth_water_top = 1,
    node_water = "",
    y_min = -200,
    y_max = 200,
    heat_point = 50,
    humidity_point = 50,
})

-- Desert biome
minetest.register_biome({
    name = "desert",
    node_top = "tf_core:sand",
    depth_top = 1,
    node_filler = "tf_core:sand",
    depth_filler = 3,
    node_stone = "tf_core:stone",
    node_water_top = "tf_core:water_source",
    depth_water_top = 1,
    node_water = "",
    y_min = -200,
    y_max = 200,
    heat_point = 90,
    humidity_point = 10,
})

-- Snowy biome
minetest.register_biome({
    name = "tundra",
    node_top = "tf_core:snow",
    depth_top = 1,
    node_filler = "tf_core:dirt",
    depth_filler = 3,
    node_stone = "tf_core:stone",
    node_water_top = "tf_core:ice",
    depth_water_top = 1,
    node_water = "",
    y_min = -200,
    y_max = 200,
    heat_point = 10,
    humidity_point = 50,
})

-- ========== ORES ==========

-- Coal: common, all elevations
minetest.register_ore({
    ore_type = "scatter",
    ore = "tf_core:coal_ore",
    wherein = "tf_core:stone",
    clust_scarcity = 8 * 8 * 8,
    clust_num_ores = 8,
    clust_size = 4,
    y_min = -31000,
    y_max = 128,
})

-- Iron: less common, mid-low
minetest.register_ore({
    ore_type = "scatter",
    ore = "tf_core:iron_ore",
    wherein = "tf_core:stone",
    clust_scarcity = 12 * 12 * 12,
    clust_num_ores = 5,
    clust_size = 3,
    y_min = -31000,
    y_max = 64,
})

-- Gold: rare, deep
minetest.register_ore({
    ore_type = "scatter",
    ore = "tf_core:gold_ore",
    wherein = "tf_core:stone",
    clust_scarcity = 20 * 20 * 20,
    clust_num_ores = 4,
    clust_size = 3,
    y_min = -31000,
    y_max = 32,
})

-- Diamond: very rare, very deep
minetest.register_ore({
    ore_type = "scatter",
    ore = "tf_core:diamond_ore",
    wherein = "tf_core:stone",
    clust_scarcity = 30 * 30 * 30,
    clust_num_ores = 3,
    clust_size = 2,
    y_min = -31000,
    y_max = 16,
})

-- ========== DECORATIONS ==========

-- Oak tree in grassland
minetest.register_decoration({
    name = "tf_world:oak_tree",
    deco_type = "schematic",
    place_on = {"tf_core:grass"},
    sidelen = 80,
    noise_params = {
        offset = 0.01,
        scale = 0.02,
        spread = {x = 100, y = 100, z = 100},
        seed = 42,
        octaves = 3,
        persist = 0.6,
    },
    biomes = {"grassland"},
    y_min = 1,
    y_max = 200,
    schematic = {
        size = {x = 1, y = 5, z = 1},
        data = {
            {name = "tf_core:tree", param2 = 12},
            {name = "tf_core:tree", param2 = 12},
            {name = "tf_core:tree", param2 = 12},
            {name = "tf_core:tree", param2 = 12},
            {name = "tf_core:tree", param2 = 12},
        },
    },
    place_offset_y = -1,
    replacements = {},
    flags = "place_center_x, place_center_z",
})

-- Oak tree leaf canopy (wider 5-wide deco at top)
minetest.register_decoration({
    name = "tf_world:oak_canopy",
    deco_type = "schematic",
    place_on = {"tf_core:tree"},
    sidelen = 80,
    noise_params = {
        offset = 0.5,
        scale = 0.5,
        spread = {x = 100, y = 100, z = 100},
        seed = 43,
        octaves = 3,
        persist = 0.6,
    },
    biomes = {"grassland"},
    y_min = 3,
    y_max = 200,
    schematic = {
        size = {x = 5, y = 2, z = 5},
        data = {
            -- Layer 1 (bottom of canopy)
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},

            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},

            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "air"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},

            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},

            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},

            -- Layer 2 (top)
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},

            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},

            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},

            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},

            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
            {name = "tf_core:leaves"},
        },
    },
    place_offset_y = 3,
    flags = "place_center_x, place_center_z",
})

-- Dandelions in grassland
minetest.register_decoration({
    name = "tf_world:dandelion",
    deco_type = "simple",
    place_on = {"tf_core:grass"},
    sidelen = 16,
    noise_params = {
        offset = -0.01,
        scale = 0.05,
        spread = {x = 100, y = 100, z = 100},
        seed = 44,
        octaves = 3,
        persist = 0.6,
    },
    biomes = {"grassland"},
    y_min = 1,
    y_max = 200,
    decoration = "tf_core:dandelion",
})

-- Roses in grassland
minetest.register_decoration({
    name = "tf_world:rose",
    deco_type = "simple",
    place_on = {"tf_core:grass"},
    sidelen = 16,
    noise_params = {
        offset = -0.015,
        scale = 0.03,
        spread = {x = 100, y = 100, z = 100},
        seed = 45,
        octaves = 3,
        persist = 0.6,
    },
    biomes = {"grassland"},
    y_min = 1,
    y_max = 200,
    decoration = "tf_core:rose",
})

-- ========== MAPGEN SETTINGS ==========

-- Register mapgen aliases so v7 mapgen uses our nodes
minetest.register_alias("mapgen_stone", "tf_core:stone")
minetest.register_alias("mapgen_water_source", "tf_core:water_source")
minetest.register_alias("mapgen_river_water_source", "tf_core:water_source")

-- Use v7 mapgen for nice terrain
minetest.set_mapgen_setting("mg_name", "v7")
minetest.set_mapgen_setting("mgv7_spflags", "mountains, ridges, noisepreserving_terrain")

minetest.log("action", "[tf_world] World generation loaded")
