function magic.register_crystal_craft(def)
    minetest.register_craft({
        type = "cooking",
        output = "magic:"..def.name.."_essence",
        recipe = "magic:crystal_"..def.name,
        cooktime = 6,
    })

    minetest.register_craft({
        type = "shapeless",
        output = "magic:crystal_"..def.name,
        recipe = {"magic:"..def.name.."_essence", "group:spellbinding", "group:stone"}
    })


    minetest.register_craft({
        type = "shapeless",
        output = "magic:"..def.name.."_essence 3",
        recipe = {"magic:concentrated_"..def.name.."_essence"}
    })
    minetest.register_craft({
        type = "shapeless",
        output = "magic:concentrated_"..def.name.."_essence",
        recipe = {"magic:"..def.name.."_essence", "magic:"..def.name.."_essence", "magic:"..def.name.."_essence"}
    })

    minetest.register_craft({
        type = "shapeless",
        output = "magic:crystal_"..def.name.." 9",
        recipe = {"magic:concentrated_crystal_"..def.name}
    })
    minetest.register_craft({
        output = "magic:concentrated_crystal_"..def.name,
        recipe = {
            {"magic:crystal_"..def.name, "magic:crystal_"..def.name, "magic:crystal_"..def.name},
            {"magic:crystal_"..def.name, "magic:crystal_"..def.name, "magic:crystal_"..def.name},
            {"magic:crystal_"..def.name, "magic:crystal_"..def.name, "magic:crystal_"..def.name},
        },
    })

    if def.fuel then
        minetest.register_craft({
            type = "fuel",
            recipe = "magic:crystal_"..def.name,
            burntime = def.fuel,
        })
    end
end

minetest.register_craft({
    type = "shapeless",
    output = "magic:null_essence 4",
    recipe = {"group:minor_essence", "default:gold_ingot", "group:minor_essence"},
})

minetest.register_craft({
    output = "magic:nightcall",
    recipe = {
        {"magic:area_essence", "group:spellbinding", ""},
        {"default:bronzeblock", "magic:calm_essence", "magic:control_essence"},
    },
})

minetest.register_craft({
    output = "magic:daypull",
    recipe = {
        {"magic:area_essence", "group:spellbinding", ""},
        {"default:bronzeblock", "magic:rage_essence", "magic:control_essence"},
    },
})

minetest.register_craft({
    output = "magic:turret",
    recipe = {
        {"magic:rage_essence", "magic:control_essence"},
        {"default:steelblock", "group:spellbinding"},
    },
})
