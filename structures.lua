ancient_world.register("magic:magic_hovel_1", {
    schematic = minetest.get_modpath("magic") .. "/schematics/magic_hovel_1.mts",
    type = "decoration",
    limit_y = {
        max = -1024,
        min = -31000,
    },
    on = {"default:stone"},
    random_replacements = {
        ["ancient_world:placeholder_1"] = {"magic:nightcall", "magic:daypull"},
    },
})

ancient_world.register("magic:magic_hovel_2", {
    schematic = minetest.get_modpath("magic") .. "/schematics/magic_hovel_2.mts",
    type = "decoration",
    on = {"default:dirt_with_grass"},
    offset = {
        x = 0,
        y = -3,
        z = 0,
    },
    random_replacements = {
        ["ancient_world:placeholder_1"] = true,
    },
})

ancient_world.register("magic:underground_lab_1", {
    schematic = minetest.get_modpath("magic") .. "/schematics/underground_lab_1.mts",
    type = "decoration",
    limit_y = {
        max = -512,
        min = -31000,
    },
    offset = {
        x = 0,
        y = -16,
        z = 0,
    },
    on = {"default:stone"},
    replacements = {
        ["ancient_world:placeholder_2"] = "air",
    },
    random_replacements = {
        ["ancient_world:placeholder_1"] = true,
    },
})
