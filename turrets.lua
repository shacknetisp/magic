local function update_formspec(pos)
    local meta = minetest.get_meta(pos)
    local name = meta:get_string("spell_name")
    name = (name ~= "") and name or "N/A"
    local count = meta:get_int("spell_count")
    meta:set_string("formspec", ([[
        size[8,6]
        label[0,0.1;Input spells. Current: ]]..tostring(name).." qty "..tostring(count)..[[]
        button[0,1;8,1;setp_%d;Only target players (current: %s)]
        list[context;input;7,0;1,1;]
        list[current_player;main;0,2;8,4;]
    ]]):format(meta:get_int("onlyplayers"), (meta:get_int("onlyplayers") == 1) and "yes" or "no"))
end

minetest.register_node("magic:turret", {
    description = "Turret",
    tiles = {"magic_turret.png"},
    groups = {cracky = 1, kingdom_infotext = 1},

    on_place = function(itemstack, placer, pointed_thing)
        if not placer or pointed_thing.type ~= "node" then
            return itemstack
        end

        local kingdom = kingdoms.player.kingdom(placer:get_player_name())
        if not kingdom then
            minetest.chat_send_player(placer:get_player_name(), "You cannot place a turret if you are not a member of a kingdom.")
            return itemstack
        end

        return minetest.item_place(itemstack, placer, pointed_thing)
    end,

    after_place_node = function(pos, placer)
        local kingdom = kingdoms.player.kingdom(placer:get_player_name())
        local meta = minetest.get_meta(pos)
        meta:set_string("kingdom.id", kingdom.id)
        meta:set_string("spell_name", "")
        meta:set_int("spell_count", 0)

        meta:get_inventory():set_size("input", 8)
        update_formspec(pos)
    end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
        local meta = minetest.get_meta(pos)
        meta:get_inventory():set_list("input", {})
        meta:set_string("spell_name", stack:get_name())
        meta:set_int("spell_count", meta:get_int("spell_count") + stack:get_count())
        meta:set_int("spell_max", stack:get_stack_max())
        meta:set_int("onlyplayers", 0)
        update_formspec(pos)
    end,
    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        return 0
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        local meta = minetest.get_meta(pos)
        if listname ~= "input" then return 0 end
        if not minetest.registered_items[stack:get_name()].original or not minetest.registered_items[stack:get_name()].original.allow_turret then
            minetest.chat_send_player(player:get_player_name(), "You must place turret-enabled spells in this device.")
            return 0
        end
        if stack:get_name() ~= meta:get_string("spell_name") and meta:get_int("spell_count") > 0 then
            minetest.chat_send_player(player:get_player_name(), "This turret still is holding "..meta:get_string("spell_name"))
            return 0
        end
        if not kingdoms.player.canpos(pos, player:get_player_name(), "devices") then
            minetest.chat_send_player(player:get_player_name(), "You cannot use this device.")
            return 0
        end
        return stack:get_count()
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        return 0
    end,
    on_destruct = function(pos)
        local meta = minetest.get_meta(pos)
        if meta:get_string("spell_name") ~= "" then
            local count = meta:get_int("spell_count")
            local needed = math.ceil(count / meta:get_int("spell_max"))
            for i=1,needed do
                minetest.add_item(pos, meta:get_string("spell_name").." "..tostring(math.min(meta:get_int("spell_max"), count)))
                count = count - meta:get_int("spell_max")
            end
        end
    end,
    on_receive_fields = function(pos, formname, fields, player)
        if not kingdoms.player.canpos(pos, player:get_player_name(), "devices") then
            minetest.chat_send_player(player:get_player_name(), "You cannot use this device.")
            return 0
        end
        local meta = minetest.get_meta(pos)
        if fields.setp_0 then
            meta:set_int("onlyplayers", 1)
        elseif fields.setp_1 then
            meta:set_int("onlyplayers", 0)
        end
        update_formspec(pos)
    end,
})

minetest.register_abm({
    nodenames = {"magic:turret"},
    interval = 3,
    chance = 1,
    action = function(pos, node)
        local meta = minetest.get_meta(pos)
        if not kingdoms.db.kingdoms[meta:get_string("kingdom.id")] then
            return
        end
        local name = meta:get_string("spell_name")
        local count = meta:get_int("spell_count")
        if count <= 0 then return end
        local def = minetest.registered_items[name].original
        if def.type == "missile" then
            local closest = nil
            local objs = minetest.get_objects_inside_radius(pos, magic.config.turret_missile_radius)
            for _,obj in pairs(objs) do
                local ok = true
                if def.friendly_turret then
                    if not obj:is_player() or not kingdoms.player.is_friendly(meta:get_string("kingdom.id"), obj:get_player_name())  then
                        ok = false
                    end
                else
                    if obj:get_luaentity() ~= nil and meta:get_int("onlyplayers") == 0 then
                        if NO_HIT_ENTS[obj:get_luaentity().name] then
                            ok = false
                        end
                    elseif obj:is_player() then
                        if kingdoms.player.kingdom(obj:get_player_name()) and kingdoms.player.is_friendly(meta:get_string("kingdom.id"), obj:get_player_name()) then
                            ok = false
                        end
                    end
                end
                if def.check_object then
                    ok = def.check_object(obj, ok)
                end
                if ok and (not closest or vector.distance(obj:getpos(), pos) < vector.distance(closest:getpos(), pos)) then
                    closest = obj
                end
            end
            if closest then
                local dir = vector.normalize{x=closest:getpos().x - pos.x, y=(closest:getpos().y + closest:get_properties().collisionbox[5]) - pos.y, z=closest:getpos().z - pos.z}
                local mobj = minetest.add_entity(pos, name.."_missile")
                mobj:setvelocity({x=dir.x*def.speed, y=dir.y*def.speed, z=dir.z*def.speed})
                mobj:setacceleration({x=0, y=-8.5*(def.gravity or 0), z=0})
                mobj:get_luaentity().kingdom = meta:get_string("kingdom.id")
                meta:set_int("spell_count", count - 1)
                update_formspec(pos)
            end
        end
    end,
})

function magic.get_turret_spell(pos)
    local meta = minetest.get_meta(pos)
    local name = meta:get_string("spell_name")
    local count = meta:get_int("spell_count")
    if count <= 0 then return end
    return minetest.registered_items[name].original
end

function magic.use_turret_spell(pos)
    local meta = minetest.get_meta(pos)
    local name = meta:get_string("spell_name")
    local count = meta:get_int("spell_count")
    if count <= 0 then return false end
    meta:set_int("spell_count", count - 1)
    update_formspec(pos)
    return true
end

