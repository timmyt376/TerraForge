
![TerraForge](https://img.shields.io/badge/TerraForge-v1.01-4a9eff)
![Luanti](https://img.shields.io/badge/engine-Luanti_5.10-2d5a27)
![License](https://img.shields.io/badge/license-MIT-green)

# 🌍 TerraForge

**An open-source voxel sandbox game. Dig, build, craft, explore.**

TerraForge is a fully open Minecraft-inspired game built on the [Luanti](https://www.luanti.org) engine (formerly Minetest). Infinite procedurally generated worlds, 30+ block types, 25 tools across 5 tiers, full crafting, survival and creative modes — all running on a battle-tested C++ engine.

---

## 🎮 Quick Start

### Windows
1. Extract the zip
2. Double-click `start_terraforge.bat`
3. Click **Singleplayer** → select or create a world → **Play**

The Python launcher handles world management, settings, and auto-update checking.

### Controls (in-game)

| Key | Action |
|-----|--------|
| `W` `A` `S` `D` | Move |
| `Space` | Jump |
| `Shift` | Sneak |
| `Left Click` | Mine block |
| `Right Click` | Place block / use item |
| `Q` | Drop item |
| `E` / `I` | Inventory |
| `Esc` | Pause / Menu |

---

## ✨ Features

### World
- 🌲 Infinite procedurally generated terrain (v7 mapgen)
- 🏔️ 3 biomes: Grassland, Desert, Tundra
- ⛏️ 4 ore types: Coal, Iron, Gold, Diamond (at correct depths)
- 🌳 Trees with leaf decay and sapling growth
- 🌸 Flowers: Dandelions and Roses
- 🌊 Water physics
- ❄️ Snow and Ice

### Blocks (30+)
Dirt, Grass, Stone, Cobblestone, Stone Bricks, Sand, Gravel, Wood (Oak Log), Oak Planks, Oak Leaves, Sapling, Coal Ore, Iron Ore, Gold Ore, Diamond Ore, Coal Block, Iron Block, Gold Block, Diamond Block, Crafting Table, Furnace, Chest, Torch, Glass, Water, Snow, Ice, Brick, Bookshelf, Bedrock, Dandelion, Rose.

### Tools (25 total)
5 tiers × 5 tool types, all craftable:

| Tier | Pickaxe | Shovel | Axe | Sword | Hoe |
|------|---------|--------|-----|-------|-----|
| 🪵 Wood | ✅ | ✅ | ✅ | ✅ | ✅ |
| 🪨 Stone | ✅ | ✅ | ✅ | ✅ | ✅ |
| 🔩 Iron | ✅ | ✅ | ✅ | ✅ | ✅ |
| ✨ Gold | ✅ | ✅ | ✅ | ✅ | ✅ |
| 💎 Diamond | ✅ | ✅ | ✅ | ✅ | ✅ |

### Crafting
- Shaped crafting at the Crafting Table
- Furnace smelting (iron ingot, gold ingot, glass)
- All tool recipes, storage blocks, torches, chests, doors

### Game Modes
- **Survival** — mine resources, craft tools, explore
- **Creative** — unlimited blocks, flight enabled (`/gamemode creative`)

---

## 🖥️ Launcher

The Python tkinter launcher provides a full game menu:

| Screen | Features |
|--------|----------|
| **Main Menu** | Play, Settings, Mods, Check Updates, Quit |
| **Singleplayer** | World list with Play buttons, world sizes |
| **Create World** | Name, Seed (optional), Survival/Creative mode |
| **Settings** | Player name, Window mode, Sound volume, Render distance, Field of View |

All settings persist in `terraforge_config.json`.

---

## 🔧 Modding

TerraForge is built on Luanti, which has a mature Lua modding API.

### Game Structure
```
TerraForge/
├── launcher.py                         ← Python game menu
├── start_terraforge.bat                ← Windows launcher
├── launcher_version.txt                ← Version for auto-update
└── luanti-5.10.0-win64/
    └── games/terraforge/
        ├── game.conf
        └── mods/
            ├── tf_core/                ← Blocks, tools, crafting, player
            └── tf_world/               ← Biomes, ores, decorations
```

### Adding Blocks
Create a new mod in `games/terraforge/mods/`:
```lua
minetest.register_node("mymod:my_block", {
    description = "My Block",
    tiles = {"mymod_my_block.png"},
    groups = {cracky = 2, building_block = 1},
})
```

### Adding Recipes
```lua
minetest.register_craft({
    output = "mymod:my_item 1",
    recipe = {
        {"mymod:material", "mymod:material"},
        {"mymod:material", "mymod:material"},
    },
})
```

---

## 📦 Planned Features

- [ ] Hostile mobs (zombies, skeletons, spiders)
- [ ] Hunger and food system
- [ ] Armor
- [ ] Bedrock addon compatibility (.mcpack loader)
- [ ] Java mod bridge (Fabric/Forge → Luanti)
- [ ] Furnace GUI (functional smelting)
- [ ] Multiplayer server browser
- [ ] Better textures and sound effects

---

## 🔗 Links

- **Source Code**: [github.com/timmyt376/TerraForge](https://github.com/timmyt376/TerraForge)
- **Luanti Engine**: [luanti.org](https://www.luanti.org)
- **Issue Tracker**: [GitHub Issues](https://github.com/timmyt376/TerraForge/issues)

---

## 📄 License

The TerraForge game code (Lua scripts, Python launcher) is open source under the MIT License.

The Luanti engine is licensed under LGPL-2.1.
