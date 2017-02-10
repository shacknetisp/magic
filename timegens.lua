minetest.register_node("magic:nightcall", {
    description = "Nightcall",
    tiles = {"magic_nightcall.png"},
    groups = {cracky = 1},
    after_place_node = function(pos)
        local meta = minetest.get_meta(pos)
        meta:get_inventory():set_size("input", 1)
        meta:get_inventory():set_size("output", 6)
        meta:set_string("formspec", [[
            size[8,7]
            label[0,0.1;Input null essences during the night to produce night essences. Requires mana.]
            list[context;input;0,1;1,1;]
            list[context;output;2,1;6,1;]
            list[current_player;main;0,3;8,4;]
        ]])
    end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
        local meta = minetest.get_meta(pos)
        meta:get_inventory():set_list("input", {})
        local leftover = meta:get_inventory():add_item("output", "magic:night_essence "..tostring(stack:get_count()))
        minetest.add_item(vector.add(pos, {x=0, y=1, z=0}), leftover)
    end,
    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        return 0
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        local tod = minetest.get_timeofday()
        if listname ~= "input" then return 0 end
        if stack:get_name() ~= "magic:null_essence" then
            return 0
        end
        if not kingdoms.player.canpos(pos, player:get_player_name(), "devices") then
            minetest.chat_send_player(player:get_player_name(), "You cannot use this device.")
            return 0
        end
        if not (tod < 0.2 or tod > 0.805) then
            minetest.chat_send_player(player:get_player_name(), "It is not night.")
            return 0
        end
        if not magic.require_mana(player, stack:get_count() / 10, true) then
            return 0
        end
        return stack:get_count()
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if not kingdoms.player.canpos(pos, player:get_player_name(), "devices") then
            minetest.chat_send_player(player:get_player_name(), "You cannot use this device.")
            return 0
        end
        return stack:get_count()
    end,
})

minetest.register_node("magic:daypull", {
    description = "Daypull",
    tiles = {"magic_daypull.png"},
    groups = {cracky = 1},
    after_place_node = function(pos)
        local meta = minetest.get_meta(pos)
        meta:get_inventory():set_size("input", 1)
        meta:get_inventory():set_size("output", 6)
        meta:set_string("formspec", [[
            size[8,7]
            label[0,0.1;Input null essences during the day to produce day essences. Requires mana.]
            list[context;input;0,1;1,1;]
            list[context;output;2,1;6,1;]
            list[current_player;main;0,3;8,4;]
        ]])
    end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
        local meta = minetest.get_meta(pos)
        meta:get_inventory():set_list("input", {})
        local leftover = meta:get_inventory():add_item("output", "magic:day_essence "..tostring(stack:get_count()))
        minetest.add_item(vector.add(pos, {x=0, y=1, z=0}), leftover)
    end,
    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        return 0
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        local tod = minetest.get_timeofday()
        if listname ~= "input" then return 0 end
        if stack:get_name() ~= "magic:null_essence" then
            return 0
        end
        if not kingdoms.player.canpos(pos, player:get_player_name(), "devices") then
            minetest.chat_send_player(player:get_player_name(), "You cannot use this device.")
            return 0
        end
        if tod < 0.2 or tod > 0.805 then
            minetest.chat_send_player(player:get_player_name(), "It is not day.")
            return 0
        end
        if not magic.require_mana(player, stack:get_count() / 10, true) then
            return 0
        end
        return stack:get_count()
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if not kingdoms.player.canpos(pos, player:get_player_name(), "devices") then
            minetest.chat_send_player(player:get_player_name(), "You cannot use this device.")
            return 0
        end
        return stack:get_count()
    end,
})

