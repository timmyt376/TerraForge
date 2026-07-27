-- tf_core: All tool and weapon definitions

local S = minetest.get_translator("tf_core")

-- Tool tiers: {name, desc_prefix, material_item, tool_caps}
-- Tool cap format: {full_punch_interval, max_drop_level, groupcaps}
local tiers = {
    {
        name = "wood",
        desc = "Wooden",
        material = "group:wood",
        caps = {
            full_punch_interval = 1.5,
            max_drop_level = 1,
            groupcaps = {
                cracky = {times = {[2]=3.00, [3]=5.00}, uses = 60, maxlevel = 1},
                choppy = {times = {[2]=1.50, [3]=3.00}, uses = 60, maxlevel = 2},
                crumbly = {times = {[1]=1.00, [2]=2.00, [3]=3.00}, uses = 60, maxlevel = 1},
                snappy = {times = {[1]=1.50, [2]=2.00, [3]=3.00}, uses = 60, maxlevel = 1},
            },
        },
    },
    {
        name = "stone",
        desc = "Stone",
        material = "tf_core:cobblestone",
        caps = {
            full_punch_interval = 1.2,
            max_drop_level = 1,
            groupcaps = {
                cracky = {times = {[1]=2.00, [2]=2.50, [3]=4.00}, uses = 132, maxlevel = 2},
                choppy = {times = {[1]=1.20, [2]=1.80, [3]=2.50}, uses = 132, maxlevel = 2},
                crumbly = {times = {[1]=0.75, [2]=1.50, [3]=2.50}, uses = 132, maxlevel = 1},
                snappy = {times = {[1]=1.20, [2]=1.50, [3]=2.00}, uses = 132, maxlevel = 1},
            },
        },
    },
    {
        name = "iron",
        desc = "Iron",
        material = "tf_core:iron_ingot",
        caps = {
            full_punch_interval = 1.0,
            max_drop_level = 2,
            groupcaps = {
                cracky = {times = {[1]=1.20, [2]=1.50, [3]=3.00}, uses = 251, maxlevel = 2},
                choppy = {times = {[1]=0.80, [2]=1.20, [3]=2.00}, uses = 251, maxlevel = 2},
                crumbly = {times = {[1]=0.50, [2]=1.00, [3]=1.80}, uses = 251, maxlevel = 1},
                snappy = {times = {[1]=0.80, [2]=1.00, [3]=1.50}, uses = 251, maxlevel = 1},
            },
        },
    },
    {
        name = "gold",
        desc = "Gold",
        material = "tf_core:gold_ingot",
        caps = {
            full_punch_interval = 0.8,
            max_drop_level = 2,
            groupcaps = {
                cracky = {times = {[1]=1.00, [2]=1.20, [3]=2.50}, uses = 33, maxlevel = 2},
                choppy = {times = {[1]=0.60, [2]=0.80, [3]=1.50}, uses = 33, maxlevel = 2},
                crumbly = {times = {[1]=0.30, [2]=0.60, [3]=1.20}, uses = 33, maxlevel = 1},
                snappy = {times = {[1]=0.60, [2]=0.80, [3]=1.20}, uses = 33, maxlevel = 1},
            },
        },
    },
    {
        name = "diamond",
        desc = "Diamond",
        material = "tf_core:diamond",
        caps = {
            full_punch_interval = 0.9,
            max_drop_level = 3,
            groupcaps = {
                cracky = {times = {[1]=0.80, [2]=1.00, [3]=2.00}, uses = 1562, maxlevel = 3},
                choppy = {times = {[1]=0.50, [2]=0.80, [3]=1.50}, uses = 1562, maxlevel = 3},
                crumbly = {times = {[1]=0.30, [2]=0.80, [3]=1.50}, uses = 1562, maxlevel = 1},
                snappy = {times = {[1]=0.50, [2]=0.70, [3]=1.00}, uses = 1562, maxlevel = 1},
            },
        },
    },
}

-- Register tools for each tier
for _, tier in ipairs(tiers) do
    -- Pickaxe (digs stone/ores: cracky group)
    minetest.register_tool("tf_core:pick_" .. tier.name, {
        description = S(tier.desc .. " Pickaxe"),
        inventory_image = "tf_core_tool_pick" .. tier.name .. ".png",
        tool_capabilities = {
            full_punch_interval = tier.caps.full_punch_interval,
            max_drop_level = tier.caps.max_drop_level,
            groupcaps = {
                cracky = tier.caps.groupcaps.cracky,
            },
            damage_groups = {fleshy = 2},
        },
        sound = {breaks = "default_tool_breaks"},
        groups = {pickaxe = 1, flammable = (tier.name == "wood" and 1 or 0)},
    })

    -- Shovel (digs dirt/sand: crumbly group)
    minetest.register_tool("tf_core:shovel_" .. tier.name, {
        description = S(tier.desc .. " Shovel"),
        inventory_image = "tf_core_tool_shovel" .. tier.name .. ".png",
        tool_capabilities = {
            full_punch_interval = tier.caps.full_punch_interval,
            max_drop_level = tier.caps.max_drop_level,
            groupcaps = {
                crumbly = tier.caps.groupcaps.crumbly,
            },
            damage_groups = {fleshy = 2},
        },
        sound = {breaks = "default_tool_breaks"},
        groups = {shovel = 1, flammable = (tier.name == "wood" and 1 or 0)},
    })

    -- Axe (chops trees: choppy group)
    minetest.register_tool("tf_core:axe_" .. tier.name, {
        description = S(tier.desc .. " Axe"),
        inventory_image = "tf_core_tool_axe" .. tier.name .. ".png",
        tool_capabilities = {
            full_punch_interval = tier.caps.full_punch_interval,
            max_drop_level = tier.caps.max_drop_level,
            groupcaps = {
                choppy = tier.caps.groupcaps.choppy,
            },
            damage_groups = {fleshy = 4},
        },
        sound = {breaks = "default_tool_breaks"},
        groups = {axe = 1, flammable = (tier.name == "wood" and 1 or 0)},
    })

    -- Sword (combat)
    local sword_damage = {wood=3, stone=5, iron=7, gold=4, diamond=9}
    minetest.register_tool("tf_core:sword_" .. tier.name, {
        description = S(tier.desc .. " Sword"),
        inventory_image = "tf_core_tool_sword" .. tier.name .. ".png",
        tool_capabilities = {
            full_punch_interval = 0.8,
            max_drop_level = 1,
            groupcaps = {
                snappy = tier.caps.groupcaps.snappy,
            },
            damage_groups = {fleshy = sword_damage[tier.name] or 5},
        },
        sound = {breaks = "default_tool_breaks"},
        groups = {sword = 1, flammable = (tier.name == "wood" and 1 or 0)},
    })
end

-- Hoe (tills dirt)
for _, tier in ipairs(tiers) do
    minetest.register_tool("tf_core:hoe_" .. tier.name, {
        description = S(tier.desc .. " Hoe"),
        inventory_image = "tf_core_tool_hoe" .. tier.name .. ".png",
        tool_capabilities = {
            full_punch_interval = 1.0,
            max_drop_level = 1,
            groupcaps = {
                crumbly = {times = {[1]=0.50, [2]=1.00, [3]=2.00}, uses = tier.caps.groupcaps.crumbly.uses, maxlevel = 1},
            },
        },
        sound = {breaks = "default_tool_breaks"},
        groups = {hoe = 1, flammable = (tier.name == "wood" and 1 or 0)},
    })
end

minetest.log("action", "[tf_core] Tools loaded")
