-- Absorb rage damage.
magic.register_spell("magic:spell_dark_shield", {
    description = "Dark Shield Spell",
    type = "shield",
    color = "#222",
    emblem = "defense",
    cost = 1,
    allow_turret = true,
    protects = {
        fire = {
            max = 4,
            factor = 0.5,
        },
    },
})
minetest.register_craft({
    output = "magic:spell_dark_shield 9",
    recipe = {
        {"group:minor_spellbinding", "magic:night_essence"},
    },
})

-- Refract magic damage.
magic.register_spell("magic:spell_white_shield", {
    description = "White Shield Spell",
    type = "shield",
    color = "#DDD",
    emblem = "defense",
    cost = 1,
    allow_turret = true,
    protects = {
        magic = {
            max = 4,
            factor = 0.5,
        },
    },
    harmful = true,
})
minetest.register_craft({
    output = "magic:spell_white_shield 9",
    recipe = {
        {"group:minor_spellbinding", "magic:day_essence"},
    },
})

-- Block fleshy damage.
magic.register_spell("magic:spell_solid_shield", {
    description = "Solid Shield Spell",
    type = "shield",
    color = "#AA0",
    emblem = "defense",
    cost = 2,
    allow_turret = true,
    protects = {
        fleshy = {
            max = 4,
            factor = 0.5,
        },
    },
})
minetest.register_craft({
    output = "magic:spell_solid_shield 9",
    recipe = {
        {"group:minor_spellbinding", "magic:solidity_essence"},
    },
})
