function magic.register_spell(name, def)
    local item_def = {
        description = def.description..(" (%d)"):format(def.cost),
        inventory_image = "magic_essence.png^[colorize:"..def.color..":"..tostring(0xCC).."^magic_emblem_"..def.emblem..".png",
        groups = def.groups or {spell = 1},
        original = def,
    }
    local function docost(player)
        -- If the spell is harmful, it will dip into player health when mana runs out.
        if def.harmful then
            return magic.require_energy(player, def.cost, true)
        else
            return magic.require_mana(player, def.cost, true)
        end
    end
    if def.type == "missile" then
        local f = magic.register_missile(name.."_missile", item_def.inventory_image, def, item_def)
        function item_def.on_use(itemstack, player, pointed_thing)
            if not docost(player) then return end
            return f(itemstack, player, pointed_thing)
        end
    elseif def.type == "action" then
        function item_def.on_use(itemstack, player, pointed_thing)
            if not docost(player) then return end
            if def.on_use(itemstack, player, pointed_thing) then
                itemstack:take_item()
            end
            return itemstack
        end
    elseif def.type == "shield" then
        -- magic.damage_obj handles shields.
    else
        error("Unknown spell type: "..def.type)
    end
    minetest.register_craftitem(name, item_def)
end

-- Convert all damage to fleshy.
function magic.damage_obj(obj, g)
    local groups = table.copy(g)
    -- If the target is a player, apply shields.
    if obj:is_player() then
        local heldstack = obj:get_wielded_item()
        local def = minetest.registered_items[heldstack:get_name()]
        local remove = false
        if (def.groups.spell or 0) > 0 and def.original.protects then
            for k,protect in pairs(def.original.protects) do
                if not groups[k] then
                    break
                end
                if def.original.harmful then
                    if not magic.require_energy(obj, def.original.cost) then
                        break
                    end
                else
                    if not magic.require_mana(obj, def.original.cost) then
                        break
                    end
                end
                remove = true
                groups[k] = math.max(0, math.min(protect.max, groups[k] * protect.factor))
            end
        end
        if remove then
            heldstack:take_item()
            obj:set_wielded_item(heldstack)
        end
    end
    local x = 0
    local armor = obj:get_armor_groups()
    for k,v in pairs(groups) do
        local factor = 1
        if k ~= 'fleshy' then
            factor = (armor.fleshy or 100) / 100
        end
        local delta = (v / factor)
        x = x + delta
    end
    obj:punch(obj, 1.0, {full_punch_interval=1.0, damage_groups={fleshy=x}, nil})
    -- Magic damage has a chance to drain mana (or deal extra damage if the target doesn't have enough mana).
    if obj:is_player() and groups.magic and groups.magic > 0 then
        magic.require_energy(obj, math.random(0, math.max(1, math.ceil(groups.magic / 3))))
    end
end
