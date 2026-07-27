-- tf_mobs: Animals and monsters for TerraForge

local modpath = minetest.get_modpath("tf_mobs")
local S = minetest.get_translator("tf_mobs")

-- ===== ITEMS (drops) =====

-- ===== MOB DEFINITIONS =====

local mobs = {
    {
        name = "pig",
        desc = "Pig",
        mtype = "animal",
        hp = 10, color = "#dcb4a0", speed = 2, jump = 3,
        drops = {"tf_core:porkchop_raw 1-3"},
        box = {-0.3, -0.01, -0.3, 0.3, 0.5, 0.3},
        vsize = {x = 0.6, y = 0.5},
    },
    {
        name = "cow",
        desc = "Cow",
        mtype = "animal",
        hp = 10, color = "#c8b4a0", speed = 1.5, jump = 3,
        drops = {"tf_core:beef_raw 1-3", "tf_core:leather 0-2"},
        box = {-0.4, -0.01, -0.4, 0.4, 0.7, 0.4},
        vsize = {x = 0.8, y = 0.7},
    },
    {
        name = "sheep",
        desc = "Sheep",
        mtype = "animal",
        hp = 8, color = "#f0ebe6", speed = 2, jump = 3,
        drops = {"tf_core:mutton_raw 1-2", "tf_core:wool 1"},
        box = {-0.3, -0.01, -0.3, 0.3, 0.6, 0.3},
        vsize = {x = 0.6, y = 0.6},
    },
    {
        name = "chicken",
        desc = "Chicken",
        mtype = "animal",
        hp = 4, color = "#f0dcb4", speed = 3, jump = 5,
        drops = {"tf_core:chicken_raw 1", "tf_core:feather 0-2"},
        box = {-0.2, -0.01, -0.2, 0.2, 0.4, 0.2},
        vsize = {x = 0.4, y = 0.4},
    },
    {
        name = "zombie",
        desc = "Zombie",
        mtype = "monster",
        hp = 20, color = "#3c783c", speed = 1.8, jump = 3,
        damage = 3,
        drops = {"tf_core:rotten_flesh 0-2", "tf_core:iron_ingot 0-1"},
        box = {-0.3, -0.01, -0.3, 0.3, 1.2, 0.3},
        vsize = {x = 0.6, y = 1.2},
    },
    {
        name = "skeleton",
        desc = "Skeleton",
        mtype = "monster",
        hp = 20, color = "#c8c8be", speed = 2, jump = 3,
        damage = 3,
        drops = {"tf_core:bone 0-2", "tf_core:arrow 0-2"},
        box = {-0.3, -0.01, -0.3, 0.3, 1.2, 0.3},
        vsize = {x = 0.6, y = 1.2},
    },
}

for _, m in ipairs(mobs) do
    -- Spawn egg item
    minetest.register_craftitem("tf_mobs:spawn_" .. m.name, {
        description = "Spawn " .. m.desc,
        inventory_image = "tf_mobs_spawn.png",
        groups = {not_in_creative_inventory = 1},
        on_place = function(itemstack, placer, pointed)
            if pointed.type ~= "node" then return itemstack end
            local pos = pointed.above
            minetest.add_entity(pos, "tf_mobs:" .. m.name)
            if not minetest.is_creative(placer:get_player_name()) then
                itemstack:take_item()
            end
            return itemstack
        end,
    })

    -- Entity
    minetest.register_entity("tf_mobs:" .. m.name, {
        initial_properties = {
            hp_max = m.hp,
            physical = true,
            collide_with_objects = true,
            collisionbox = m.box,
            visual = "cube",
            textures = {m.color},
            visual_size = m.vsize,
            makes_footstep_sound = false,
            automatic_rotate = 0,
        },
        _mtype = m.mtype,
        _drops = m.drops,
        _damage = m.damage or 0,
        _speed = m.speed,
        _jump = m.jump,
        _timer = 0,
        _wpos = nil,

        on_step = function(self, dtime)
            local pos = self.object:get_pos()
            if not pos then return end
            -- Despawn if far from players
            local players = minetest.get_connected_players()
            local close = false
            for _, p in ipairs(players) do
                if vector.distance(pos, p:get_pos()) < 64 then
                    close = true; break
                end
            end
            if not close then self.object:remove(); return end

            if self._mtype == "monster" then
                self:_hostile(dtime, pos)
            else
                self:_wander(dtime, pos)
            end
        end,

        on_punch = function(self, puncher)
            if not puncher or not puncher:is_player() then return end
            local hp = self.object:get_hp()
            local item = puncher:get_wielded_item()
            local dmg = 1
            if item then
                local caps = item:get_tool_capabilities()
                if caps and caps.damage_groups and caps.damage_groups.fleshy then
                    dmg = caps.damage_groups.fleshy
                end
            end
            self.object:set_hp(hp - dmg)
            if self.object:get_hp() <= 0 then
                self:_die()
            end
        end,

        _wander = function(self, dtime, pos)
            self._timer = self._timer + dtime
            if self._timer > 3 + math.random() * 2 then
                self._timer = 0
                local a = math.random() * 2 * math.pi
                local d = 2 + math.random() * 4
                self._wpos = vector.add(pos, {x = math.cos(a)*d, y = 0, z = math.sin(a)*d})
            end
            if self._wpos then
                local dir = vector.subtract(self._wpos, pos)
                local dist = vector.length(dir)
                if dist > 0.5 then
                    dir = vector.normalize(dir)
                    self.object:set_velocity({x = dir.x * self._speed, y = 0, z = dir.z * self._speed})
                    self.object:set_yaw(math.atan2(-dir.x, dir.z))
                else
                    self.object:set_velocity({x = 0, y = 0, z = 0})
                end
            end
        end,

        _hostile = function(self, dtime, pos)
            local target, tdist = nil, 16
            for _, p in ipairs(minetest.get_connected_players()) do
                local d = vector.distance(pos, p:get_pos())
                if d < tdist then target = p; tdist = d end
            end
            if target then
                local tp = target:get_pos()
                local dir = vector.subtract(tp, pos)
                local dist = vector.length(dir)
                dir = vector.normalize(dir)
                if dist > 1.5 then
                    self.object:set_velocity({x = dir.x * self._speed * 1.3, y = 0, z = dir.z * self._speed * 1.3})
                    self.object:set_yaw(math.atan2(-dir.x, dir.z))
                    -- Jump if stuck
                    local vel = self.object:get_velocity()
                    if vel and math.abs(vel.x) < 0.1 and math.abs(vel.z) < 0.1 then
                        self.object:set_velocity({x = vel.x, y = self._jump, z = vel.z})
                    end
                elseif self._damage > 0 then
                    self.object:set_velocity({x = 0, y = 0, z = 0})
                    target:set_hp(target:get_hp() - self._damage)
                end
            else
                self:_wander(dtime, pos)
            end
        end,

        _die = function(self)
            local pos = self.object:get_pos()
            if not pos then return end
            if self._drops then
                for _, drop in ipairs(self._drops) do
                    local name, range = drop:match("([^ ]+) (.+)")
                    if name and range then
                        local min_s, max_s = range:match("(%d+)-?(%d*)")
                        local min = tonumber(min_s) or 1
                        local max = tonumber(max_s ~= "" and max_s or min_s) or min
                        local count = math.random(min, max)
                        if count > 0 then
                            minetest.add_item(pos, name .. " " .. count)
                        end
                    end
                end
            end
            self.object:remove()
        end,
    })
end

-- ===== SPAWNING =====

minetest.register_abm({
    label = "Animal spawn",
    nodenames = {"tf_core:grass"},
    interval = 25, chance = 12,
    action = function(pos)
        local tod = minetest.get_timeofday()
        if tod < 0.2 or tod > 0.8 then return end  -- only daytime
        local above = {x = pos.x, y = pos.y + 1, z = pos.z}
        if minetest.get_node(above).name ~= "air" then return end
        if #minetest.get_objects_inside_radius(above, 16) > 4 then return end
        local types = {"pig", "cow", "sheep", "chicken"}
        minetest.add_entity(above, "tf_mobs:" .. types[math.random(#types)])
    end,
})

minetest.register_abm({
    label = "Monster spawn",
    nodenames = {"tf_core:grass", "tf_core:dirt", "tf_core:stone", "tf_core:cobblestone"},
    interval = 20, chance = 15,
    action = function(pos)
        local tod = minetest.get_timeofday()
        if tod > 0.2 and tod < 0.8 then return end  -- only night
        local above = {x = pos.x, y = pos.y + 1, z = pos.z}
        local n = minetest.get_node(above)
        if n.name ~= "air" then return end
        local light = minetest.get_node_light(above, 0.5)
        if light and light > 7 then return end
        if #minetest.get_objects_inside_radius(above, 24) > 3 then return end
        local types = {"zombie", "skeleton"}
        minetest.add_entity(above, "tf_mobs:" .. types[math.random(#types)])
    end,
})

minetest.log("action", "[tf_mobs] Loaded")
