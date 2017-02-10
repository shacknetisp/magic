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


local ele_parts = function(pos)
    for i=0,math.random(1,3) do
        minetest.add_particle({
            pos = vector.add(pos, vector.multiply({x=math.random()-0.5, y=math.random()-0.5, z=math.random()-0.5}, math.random())),
            velocity = vector.multiply({x=math.random()-0.5, y=math.random()-0.5, z=math.random()-0.5}, math.random() * 2),
            acceleration = vector.multiply({x=math.random()-0.5, y=math.random()*-5, z=math.random()-0.5}, math.random() * 4),
            expirationtime = math.random() * 5,
            size = math.random() * 5,
            texture = "smoke_puff.png^[transform" .. math.random(0, 7),
        })
    end
end

minetest.register_entity("magic:explosive_launch_entity", {
    physical = false,
    timer = 0,
    parttimer = 0,
    collisionbox = {0,0,0,0,0,0},
    textures = {"default_cloud.png^[opacity:0"},
    visual_size = {x=0, y=0},

    on_step = function(self, dtime)
        self.timer = self.timer - dtime
        self.parttimer = self.timer + dtime
        if not self.p then
            self.object:remove()
            return
        end
        if self.timer <= 0 or self.object:getvelocity().y < 0 then
            self.object:remove()
            return
        end
        local pos = self.object:getpos()
        if self.parttimer > 0.3 then
            ele_parts(pos)
            self.parttimer = self.parttimer - 0.3
        end
        if not magic.missile_passable(vector.add(pos, {x=0, y=1, z=0})) then
            self.object:remove()
            return
        end
        if not magic.missile_passable(pos) then
            self.object:remove()
            return
        end
    end,
})

magic.register_potion("magic:explosive_launch_potion", {
    description = "Explosive Launch Potion",
    color = "#B30",
    on_use = function(itemstack, player)
        if not minetest.registered_nodes[minetest.get_node(vector.add(player:get_pos(), {x=0, y=-1, z=0})).name].walkable then
            return false
        end
        local pos = player:get_pos()
        local speed = math.random(15, 20)
        local time = 10
        local obj = minetest.add_entity(pos, "magic:explosive_launch_entity")
        local dir = player:get_look_dir()
        local v = {x=dir.x*-speed, y=dir.y*-speed, z=dir.z*-speed}
        obj:setvelocity(v)
        obj:setacceleration({x=-(v.x / math.abs(v.y / 9.81)), y=-9.81, z=-(v.z / math.abs(v.y / 9.81))})
        obj:setyaw(player:get_look_horizontal()+math.pi)
        player:set_attach(obj, "", {x=0, y=0, z=0}, {x=0, y=0, z=0})
        obj:get_luaentity().timer = time
        obj:get_luaentity().p = player
        return true
    end,
})

minetest.register_craft({
    output = "magic:explosive_launch_potion",
    type = "shapeless",
    recipe = {"magic:water_bottle", "magic:rage_essence", "magic:vitality_essence"},
})
