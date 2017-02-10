function magic.register_potion(name, def)
    local item_def = {
        description = def.description,
        drawtype = "plantlike",
        tiles = {"vessels_glass_bottle.png^[colorize:"..def.color..":200"},
        inventory_image = "vessels_glass_bottle.png^[colorize:"..def.color..":200",
        wield_image = "vessels_glass_bottle.png^[colorize:"..def.color..":200",
        paramtype = "light",
        is_ground_content = false,
        walkable = false,
        selection_box = {
            type = "fixed",
            fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
        },
        groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
        sounds = default.node_sound_glass_defaults(),
    }
    local function docost(player)
        if def.harmful then
            return magic.require_energy(player, def.cost, true)
        else
            return magic.require_mana(player, def.cost, true)
        end
    end
    if def.on_use then
        function item_def.on_use(itemstack, player)
            if def.cost then
                if not docost(player) then return end
            end
            if def.on_use(itemstack, player) then
                if player:get_inventory():room_for_item("main", "vessels:glass_bottle") then
                    player:get_inventory():add_item("main", "vessels:glass_bottle")
                else
                    minetest.add_item(pos, "vessels:glass_bottle")
                end
                itemstack:take_item()
            end
            return itemstack
        end
    end
    minetest.register_node(name, item_def)
end

magic.register_potion("magic:water_bottle", {
    description = "Bottle of Water",
    color = "#02A",
})

minetest.register_craft({
    output = "magic:water_bottle",
    type = "shapeless",
    recipe = {"vessels:glass_bottle", "bucket:bucket_water"},
    replacements = {{"bucket:bucket_water", "bucket:bucket_empty"}},
})

magic.register_potion("magic:purified_water_bottle", {
    description = "Purified Bottle of Water",
    color = "#23B",
})

minetest.register_craft({
    type = "cooking",
    output = "magic:purified_water_bottle",
    recipe = "magic:water_bottle",
    cooktime = 5,
})

magic.register_potion("magic:minor_mana_potion", {
    description = "Minor Mana Restoration Potion",
    color = "#00F",
    on_use = function(itemstack, player)
        magic.require_mana(player, -2)
        return true
    end,
})

minetest.register_craft({
    output = "magic:minor_mana_potion",
    type = "shapeless",
    recipe = {"magic:water_bottle", "flowers:geranium"},
})
