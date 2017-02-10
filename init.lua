-- Function to execute more files.
local modpath = minetest.get_modpath("magic")
local function domodfile(f)
    dofile(modpath .. '/' .. f)
end

-- Mod namespace.
magic = {}

magic.config = kingdoms.config_table("magic")
magic.log = kingdoms.log_function("magic")
domodfile("defaults.lua")

minetest.override_item("default:mese", {
    groups = {cracky = 1, level = 2, major_spellbinding = 1}
})

domodfile("mana.lua")
domodfile("throwing.lua")
domodfile("mapgen.lua")

domodfile("crafts.lua")

domodfile("timegens.lua")
domodfile("crystals.lua")
domodfile("spells.lua")
domodfile("potions.lua")
domodfile("turrets.lua")

domodfile("spells/action.lua")
domodfile("spells/attack.lua")
domodfile("spells/defense.lua")
domodfile("spells/teleportation.lua")

if rawget(_G, "ancient_world") then
    domodfile("structures.lua")
end

magic.log("action", "Loaded.")
kingdoms.mod_ready("magic")
