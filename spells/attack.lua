-- The fireball, ignites flames and deals fire damage.
magic.register_spell("magic:spell_fire", {
    description = "Fire Spell",
    type = "missile",
    color = "#F00",
    emblem = "attack",
    speed = 30,
    cost = 2,
    allow_turret = true,
    element = "fire",
    hit_node = function(self, pos, last_empty_pos)
        local flammable = minetest.get_item_group(minetest.get_node(pos).name, "flammable")
        local puts_out = minetest.get_item_group(minetest.get_node(pos).name, "puts_out_fire")
        if puts_out > 0 then
            -- No chance of a fire starting here.
            return true
        end
        if flammable > 0 then
            minetest.set_node(pos, {name = "fire:basic_flame"})
            return true
        elseif magic.missile_passable(pos) then
            return false
        elseif last_empty_pos then
            minetest.set_node(last_empty_pos, {name = "fire:basic_flame"})
            return true
        end
        return false
    end,
    hit_object = function(self, pos, obj)
        magic.damage_obj(obj, {fire = (self.was_near_turret > 0 and 2 or 4)})
        return true
    end,
})
minetest.register_craft({
    output = "magic:spell_fire",
    recipe = {
        {"magic:rage_essence", "group:minor_spellbinding"},
    },
})
minetest.register_craft({
    type = "fuel",
    recipe = "magic:spell_fire",
    burntime = 550,
})

-- The bomb, creates a TNT-style explosion at the contact point.
if rawget(_G, 'tnt') and tnt.boom then
    local hit_node = function(self, pos, last_empty_pos)
        local puts_out = minetest.get_item_group(minetest.get_node(pos).name, "puts_out_fire")
        if puts_out > 0 then
            -- This spell can travel through water.
            return false
        end
        if magic.missile_passable(pos) then
            return false
        end
        tnt.boom(pos, {
            radius = 3,
            damage_radius = 5,
        })
        return true
    end
    magic.register_spell("magic:spell_bomb", {
        description = "Bomb Spell",
        type = "missile",
        color = "#FA0",
        emblem = "attack",
        speed = 15,
        cost = 6,
        gravity = 0.5,
        element = "fire",
        hit_node = hit_node,
        hit_object = function(self, pos, obj)
            return hit_node(self, pos)
        end,
        near_turret = function(self, pos, spell)
            if spell.protects and spell.protects.fire and magic.use_turrent_spell(pos) then
                return true
            end
        end,
    })
    minetest.register_craft({
        output = "magic:spell_bomb",
        recipe = {
            {"magic:spell_fire", "group:minor_spellbinding", "magic:area_essence"},
        },
    })
end

-- A weak but cheap dart.
magic.register_spell("magic:spell_dart", {
    description = "Dart Spell",
    type = "missile",
    color = "#333",
    emblem = "attack",
    speed = 60,
    cost = 1,
    element = "fleshy",
    allow_turret = true,
    hit_object = function(self, pos, obj)
        magic.damage_obj(obj, {fleshy = (self.was_near_turret > 0 and 1 or 2)})
        return true
    end,
})
minetest.register_craft({
    output = "magic:spell_dart 6",
    recipe = {
        {"magic:area_essence", "magic:solidity_essence"},
        {"group:minor_spellbinding", "group:stone"},
    },
})

-- A weak dart that deals armor-bypassing magic and fire damage.
magic.register_spell("magic:spell_missile", {
    description = "Missile Spell",
    type = "missile",
    color = "#04F",
    emblem = "attack",
    speed = 50,
    cost = 1,
    element = "magic",
    allow_turret = true,
    hit_object = function(self, pos, obj)
        magic.damage_obj(obj, {magic = (self.was_near_turret > 0 and 0.5 or 1), fire = (self.was_near_turret > 0 and 0.5 or 1)})
        return true
    end,
})
minetest.register_craft({
    output = "magic:spell_missile 2",
    recipe = {
        {"magic:rage_essence", "magic:day_essence", "group:minor_spellbinding"},
    },
})

local function drop_ice(self, pos)
    self.firsthit = self.firsthit or pos
    if minetest.get_node(pos).name ~= "default:water_source" and minetest.get_node(pos).name ~= "default:water_flowing" then
        return true
    else
        if vector.distance(self.firsthit, pos) >= 16 then
            return true
        end
    end
    local limit = 6
    local positions = kingdoms.utils.shuffled(kingdoms.utils.find_nodes_by_area_under_air(pos, 4, {"default:water_source"}))
    for _,p in ipairs(positions) do
        limit = limit - 1
        minetest.set_node(p, {name="default:ice"})
        if limit <= 0 then
            break
        end
    end
end

-- Convert water sources to ice.
magic.register_spell("magic:spell_ice", {
    description = "Ice Spell",
    type = "missile",
    color = "#08B",
    emblem = "attack",
    speed = 20,
    cost = 8,
    element = "cold",
    hit_node = drop_ice,
    hit_object = function(self, pos, obj)
        magic.damage_obj(obj, {cold = (self.was_near_turret > 0 and 2 or 4)})
        return true
    end,
})
minetest.register_craft({
    output = "magic:spell_ice 2",
    recipe = {
        {"magic:concentrated_night_essence", "magic:calm_essence", ""},
        {"group:minor_spellbinding", "magic:area_essence", "magic:solidity_essence"},
    },
})
