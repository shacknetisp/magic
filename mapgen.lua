function magic.register_mapgen()
    -- Vitality crystals form in warm forests.
    minetest.register_decoration({
        deco_type = "simple",
        place_on = {"default:dirt_with_grass"},
        sidelen = 80,
        fill_ratio = 0.00025,
        biomes = {"rainforest", "deciduous_forest", "coniferous_forest"},
        y_min = 1,
        y_max = 31000,
        decoration = "magic:crystal_vitality",
    })
end
