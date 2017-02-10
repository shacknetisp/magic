local teleporting = {}
minetest.register_globalstep(function(dtime)
    for _, player in pairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local tp = teleporting[name]
        if tp then
            tp.timer = tp.timer + dtime
            if vector.distance(player:getpos(), tp.start) > 0.1 then
                magic.cancel_teleportation(name)
            elseif tp.timer >= tp.delay then
                minetest.registered_items[tp.item].original.go(player)
                teleporting[name] = nil
            end
        end
    end
end)

function magic.start_teleportation(player, item, delay)
    local name = player:get_player_name()
    if teleporting[name] then
        magic.cancel_teleportation(name)
    end
    teleporting[name] = {
        timer = 0,
        delay = delay,
        item = item,
        start = player:getpos(),
    }
    minetest.chat_send_player(name, "Teleportation will occur in "..tostring(delay).." seconds. Remain still.")
end

function magic.cancel_teleportation(name)
    minetest.chat_send_player(name, "Teleportation has been canceled.")
    teleporting[name] = nil
end

minetest.register_on_leaveplayer(function(player)
    magic.cancel_teleportation(player:get_player_name())
end)

magic.register_spell("magic:spell_teleport_spawn", {
    description = "Spawn Teleportation Spell",
    type = "action",
    color = "#0A0",
    emblem = "action",
    cost = 15,
    on_use = function(itemstack, player)
        magic.start_teleportation(player, itemstack:get_name(), magic.config.teleportation_delay)
        return true
    end,
    go = function(player)
        if not kingdoms.db.servercorestone then
            minetest.chat_send_player(player:get_player_name(), "There is no destination.")
            return
        end
        player:setpos(vector.add(kingdoms.db.servercorestone, {x=0, y=1, z=0}))
    end,
})
minetest.register_craft({
    output = "magic:spell_teleport_spawn",
    recipe = {
        {"magic:concentrated_warp_essence", "magic:control_essence"},
        {"group:minor_spellbinding", "default:sapling"},
    },
})

magic.register_spell("magic:spell_teleport_kingdom", {
    description = "Kingdom Teleportation Spell",
    type = "action",
    color = "#FA0",
    emblem = "action",
    cost = 15,
    on_use = function(itemstack, player)
        magic.start_teleportation(player, itemstack:get_name(), magic.config.teleportation_delay)
        return true
    end,
    go = function(player)
        local kingdom = kingdoms.player.kingdom(player:get_player_name())
        if not kingdom or not kingdom.corestone.pos then
            minetest.chat_send_player(player:get_player_name(), "There is no destination.")
            return
        end
        player:setpos(vector.add(kingdom.corestone.pos, {x=0, y=1, z=0}))
    end,
})
minetest.register_craft({
    output = "magic:spell_teleport_kingdom",
    recipe = {
        {"magic:concentrated_warp_essence", "magic:control_essence"},
        {"group:minor_spellbinding", "default:junglesapling"},
    },
})

if magic.config.enable_short_teleports then
    magic.register_spell("magic:spell_short_teleport", {
        description = "Short Teleportation Spell",
        type = "missile",
        color = "#F0F",
        emblem = "action",
        speed = 10,
        cost = 7,
        gravity = 0.35,
        forceload = true,
        near_turret = function(self, pos, spell)
            if spell.protects and spell.protects.magic and magic.use_turrent_spell(pos) then
                return true
            end
        end,
        hit_node = function(self, pos, last_empty_pos)
            local akingdom = kingdoms.bypos(last_empty_pos)
            if self.player then
                local pkingdom = kingdoms.player.kingdom(self.player:get_player_name())
                if akingdom and (not pkingdom or pkingdom.id ~= akingdom.id) then
                    minetest.chat_send_player(self.player:get_player_name(), "You cannot teleport there.")
                    return true
                end
                self.player:setpos(last_empty_pos)
            end
            return true
        end,
        hit_object = function() return false end
    })
    minetest.register_craft({
        output = "magic:spell_short_teleport",
        recipe = {
            {"magic:concentrated_warp_essence", "magic:control_essence"},
            {"group:minor_spellbinding", ""},
        },
    })
end
