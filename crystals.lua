magic.crystals = {
    {
        name = "rage",
        desc = "Rage",
        color = "#A00",
        light = 10,
        fuel = 500,
        ores = {
            {
                rarity = 4 * 4 * 4,
                clust_num_ores = 1,
                clust_size     = 1,
                wherein        = "default:lava_source",
                y_max = -64,
            },
        },
    },
    {
        name = "solidity",
        desc = "Solidity",
        color = "#AA0",
        light = 4,
    },
    {
        name = "area",
        desc = "Area",
        color = "#033",
        light = 8,
    },
    {
        name = "warp",
        desc = "Warp",
        color = "#0CC",
        light = 13,
        rarity = 0.5,
    },
    {
        name = "control",
        desc = "Control",
        color = "#707",
        light = 7,
    },
    {
        name = "vitality",
        desc = "Vitality",
        color = "#0F0",
        light = 12,
        ores = {
            {
                rarity = 18 * 18 * 18,
                clust_num_ores = 1,
                clust_size     = 1,
                wherein        = "default:dirt",
            },
        },
    },
    {
        name = "calm",
        desc = "Calm",
        color = "#00F",
        light = 5,
        ores = {
            {
                rarity = 4 * 4 * 4,
                clust_num_ores = 1,
                clust_size     = 1,
                wherein        = "default:water_source",
                y_max = -128,
            },
            {
                rarity = 16 * 16 * 16,
                clust_num_ores = 1,
                clust_size     = 1,
                wherein        = "default:water_source",
                y_min = -128,
                y_max = -8,
            },
        },
    },
    {
        name = "day",
        desc = "Day",
        color = "#FFF",
        light = 14,
        fuel = 350,
        nodefgen = true,
        ores = {
            {
                rarity = 15 * 15 * 15,
                clust_num_ores = 3,
                clust_size     = 2,
                y_min          = 400,
                wherein = "air"
            },
        },
    },
    {
        name = "night",
        desc = "Night",
        color = "#000",
        light = 0,
        nodefgen = true,
        ores = {
            {
                rarity = 15 * 15 * 15,
                clust_num_ores = 3,
                clust_size     = 2,
                y_min          = 400,
                wherein = "air"
            },
        },
    },
}

minetest.register_craftitem("magic:null_essence", {
    description = "Null Essence",
    inventory_image = "magic_essence.png",
})

function magic.register_crystal(def, nocraft)
    minetest.register_node("magic:crystal_"..def.name, {
        description = def.desc.." Crystal",
        drawtype = "glasslike",
        tiles = {"magic_crystal.png^[colorize:"..def.color..":"..tostring(0xCC)},
        groups = {cracky = 2, not_in_creative_inventory = (def.hidecrystal and 1 or 0)},
        light_source = def.light or 7,
        sunlight_propagates = true,
        use_texture_alpha = true,
        paramtype = "light",
        sounds = default.node_sound_stone_defaults(),
    })

    minetest.register_node("magic:concentrated_crystal_"..def.name, {
        description = "Compressed "..def.desc.." Crystal",
        tiles = {"magic_concentrated_crystal.png^[colorize:"..def.color..":"..tostring(0xCC)},
        is_ground_content = false,
        drawtype = "glasslike",
        light_source = def.light or 7,
        sunlight_propagates = true,
        use_texture_alpha = true,
        paramtype = "light",
        groups = {cracky = 2, not_in_creative_inventory = (def.hidecrystal and 1 or 0)},
        sounds = default.node_sound_stone_defaults(),
    })

    if rawget(_G, 'ancient_world') then
        ancient_world.register_item("magic:concentrated_crystal_"..def.name, (4 / #magic.crystals) * (def.rarity or 1))
    end

    minetest.register_craftitem("magic:"..def.name.."_essence", {
        description = def.desc.." Essence",
        inventory_image = "magic_essence.png^[colorize:"..def.color..":"..tostring(0xCC),
        groups = {minor_essence = 1},
    })

    minetest.register_craftitem("magic:concentrated_"..def.name.."_essence", {
        description = "Concentrated "..def.desc.." Essence",
        inventory_image = "magic_concentrated_essence.png^[colorize:"..def.color..":"..tostring(0xCC),
    })

    local ndefd = {
        ore_type       = "scatter",
        ore            = "magic:crystal_"..def.name,
        wherein        = "default:stone",
        clust_num_ores = 1,
        clust_size     = 1,
        y_min          = -31000,
        y_max          = 31000,
    }

    if def.ores then
        for _,oredef in ipairs(def.ores) do
            local ndef = table.copy(ndefd)
            ndef.clust_scarcity = oredef.rarity * #magic.crystals * (def.rarity or 1)
            for k,v in pairs(oredef) do
                ndef[k] = v
            end
            minetest.register_ore(ndef)
        end
    end

    if not def.nodefgen then
        local ores = {
            -- 30k belt.
            {
                rarity = 8 * 8 * 8,
                clust_num_ores = 4,
                clust_size     = 3,
                y_max          = -30000,
                y_min          = -30008,
            },
            -- 20k belt.
            {
                rarity = 9 * 9 * 9,
                clust_num_ores = 4,
                clust_size     = 3,
                y_max          = -20000,
                y_min          = -20016,
            },
            -- 10k belt.
            {
                rarity = 10 * 10 * 10,
                clust_num_ores = 4,
                clust_size     = 3,
                y_max          = -10000,
                y_min          = -10025,
            },
            {
                rarity = 12 * 12 * 12,
                clust_num_ores = 4,
                clust_size     = 2,
                y_max          = -2048,
            },
            {
                rarity = 13 * 13 * 13,
                clust_num_ores = 3,
                clust_size     = 2,
                y_max          = -1024,
                y_min = -2048,
            },
            {
                rarity = 14 * 14 * 14,
                clust_num_ores = 3,
                clust_size     = 2,
                y_max          = -512,
                y_min = -1024,
            },
            {
                rarity = 16 * 16 * 16,
                clust_num_ores = 3,
                clust_size     = 2,
                y_max          = -64,
                y_min = -512,
            },
            {
                rarity = 14 * 14 * 14,
                clust_num_ores = 3,
                clust_size     = 2,
                y_min          = 50,
            },
        }
        for _,oredef in ipairs(ores) do
            local ndef = table.copy(ndefd)
            ndef.clust_scarcity = oredef.rarity * #magic.crystals * (def.rarity or 1)
            for k,v in pairs(oredef) do
                ndef[k] = v
            end
            minetest.register_ore(ndef)
        end
    end

    if not nocraft then
        magic.register_crystal_craft(def)
    end
end

for _,def in ipairs(magic.crystals) do
    magic.register_crystal(def)
end
