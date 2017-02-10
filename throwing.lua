-- Throwing movement physics.

NO_HIT_ENTS = {
    ["__builtin:item"] = true,
    ["itemframes:item"] = true,
    ["xdecor:f_item"] = true,
}

local TIMEOUT = 300

-- ORIGINALLY COPIED FROM technic, under LGPL v2
-- BEGIN COPIED
local scalar = vector.scalar or vector.dot or function(v1, v2)
	return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z
end

local function biggest_of_vec(vec)
	if vec.x < vec.y then
		if vec.y < vec.z then
			return "z"
		end
		return "y"
	end
	if vec.x < vec.z then
		return "z"
	end
	return "x"
end

local function rayIter(pos, dir, range)
	-- make a table of possible movements
	local step = {}
	for i in pairs(pos) do
		local v = math.sign(dir[i])
		if v ~= 0 then
			step[i] = v
		end
	end

	local p
	return function()
		if not p then
			-- avoid skipping the first position
			p = vector.round(pos)
			return vector.new(p)
		end

		-- find the position which has the smallest distance to the line
		local choose = {}
		local choosefit = vector.new()
		for i in pairs(step) do
			choose[i] = vector.new(p)
			choose[i][i] = choose[i][i] + step[i]
			choosefit[i] = scalar(vector.normalize(vector.subtract(choose[i], pos)), dir)
		end
		p = choose[biggest_of_vec(choosefit)]

		if vector.distance(pos, p) <= range then
			return vector.new(p)
		end
	end
end
-- END COPIED

function magic.missile_passable(pos)
    local def = minetest.registered_nodes[minetest.get_node(pos).name]
    if not def.walkable and def.buildable_to then
        return true
    end
    return false
end

function magic.register_missile(name, texture, def, item_def)

    def.hit_object = def.hit_object or function(self, pos, obj)
        return true
    end

    def.hit_player = def.hit_player or function(self, pos, obj)
        return def.hit_object(self, pos, obj)
    end

    def.hit_node = def.hit_node or function(self, pos, last_empty_pos)
        if magic.missile_passable(pos) then
            return false
        end
        return true
    end

    def.near_turret = def.near_turret or function(self, pos, spell)
        return false
    end

    def.is_passthrough_node = def.is_passthrough_node or function(self, pos, node)
        return node.name == "air"
    end

    local ent_def = {
            physical = false,
            hp_max = math.ceil(def.cost / 2),
            timer=0,
            particletimer = 0,
            visual = "sprite",
            visual_size = {x=0.4, y=0.4},
            textures = {texture},
            lastpos={},
            lastair = nil,
            was_near_turret = 0,
            collisionbox = {0,0,0,0,0,0},
    }

    ent_def.on_step = function(self, dtime)
            self.timer=self.timer+dtime
            self.particletimer = self.particletimer + dtime
            local pos = self.object:getpos()
            if self.lastpos.x == nil then
                self.lastpos = pos
                if def.is_passthrough_node(self, pos, minetest.get_node(pos).name) then
                    self.lastair = pos
                elseif def.is_passthrough_node(self, vector.add(pos, {x=0, y=1, z=0}), minetest.get_node(vector.add(pos, {x=0, y=1, z=0}))) then
                    self.lastair = vector.add(pos, {x=0, y=1, z=0})
                elseif def.is_passthrough_node(self, vector.add(pos, {x=0, y=2, z=0}), minetest.get_node(vector.add(pos, {x=0, y=2, z=0}))) then
                    self.lastair = vector.add(pos, {x=0, y=2, z=0})
                end
                return
            end

            if self.timer > TIMEOUT then
                self.object:remove()
                return
            end

            local line = {
                start = self.lastpos,
                finish = pos,
            }

            line.middle = {
                x = (line.start.x + line.finish.x) / 2,
                y = (line.start.y + line.finish.y) / 2,
                z = (line.start.z + line.finish.z) / 2,
            }

            local Hit = {x=0, y=0, z=0};

            local function GetIntersection(fDst1, fDst2, P1, P2)
                if ( (fDst1 * fDst2) >= 0.0) then return nil end
                if ( fDst1 == fDst2) then return nil end
                Hit = vector.multiply(vector.add(P1, vector.subtract(P2, P1)), ( -fDst1/(fDst2-fDst1) ));
                return true
            end

            local function InBox(H, B1, B2, Axis)
                if ( Axis==1 and H.z > B1.z and H.z < B2.z and H.y > B1.y and H.y < B2.y) then return true; end
                if ( Axis==2 and H.z > B1.z and H.z < B2.z and H.x > B1.x and H.x < B2.x) then return true; end
                if ( Axis==3 and H.x > B1.x and H.x < B2.x and H.y > B1.y and H.y < B2.y) then return true; end
                return false;
            end

            local function CheckLineBox( B1, B2, L1, L2)
                if (L2.x < B1.x and L1.x < B1.x) then return false end
                if (L2.x > B2.x and L1.x > B2.x) then return false end
                if (L2.y < B1.y and L1.y < B1.y) then return false end
                if (L2.y > B2.y and L1.y > B2.y) then return false end
                if (L2.z < B1.z and L1.z < B1.z) then return false end
                if (L2.z > B2.z and L1.z > B2.z) then return false end
                if (L1.x > B1.x and L1.x < B2.x and
                    L1.y > B1.y and L1.y < B2.y and
                    L1.z > B1.z and L1.z < B2.z)
                    then
                        Hit = L1;
                    return true
                    end
                if ( (GetIntersection( L1.x-B1.x, L2.x-B1.x, L1, L2) and InBox( Hit, B1, B2, 1 ))
                or (GetIntersection( L1.y-B1.y, L2.y-B1.y, L1, L2) and InBox( Hit, B1, B2, 2 ))
                or (GetIntersection( L1.z-B1.z, L2.z-B1.z, L1, L2) and InBox( Hit, B1, B2, 3 ))
                or (GetIntersection( L1.x-B2.x, L2.x-B2.x, L1, L2) and InBox( Hit, B1, B2, 1 ))
                or (GetIntersection( L1.y-B2.y, L2.y-B2.y, L1, L2) and InBox( Hit, B1, B2, 2 ))
                or (GetIntersection( L1.z-B2.z, L2.z-B2.z, L1, L2) and InBox( Hit, B1, B2, 3 )))
                then
                        return true
                end

                return false;
            end

            local function CheckLineNear(line, pos, distance)
                local nx = 0.5
                if line.finish.x < line.start.x then nx = -nx end
                local ny = 0.5
                if line.finish.y < line.start.y then ny = -ny end
                local nz = 0.5
                if line.finish.z < line.start.z then nz = -nz end

                for x=line.start.x,line.finish.x,nx do
                for y=line.start.y,line.finish.y,ny do
                for z=line.start.z,line.finish.z,nz do
                    if vector.distance({x=x, y=y, z=z}, pos) <= distance then
                        return true
                    end
                end
                end
                end

                return false
            end

            if def.forceload then
                for pos in rayIter(line.start, vector.normalize(self.object:getvelocity()), math.max(64, vector.distance(line.start, line.finish) * 2)) do
                    kingdoms.utils.load_pos(pos)
                end
            end

            for _,pos in ipairs(kingdoms.utils.find_nodes_by_area(pos, magic.config.turret_shield_radius, {"magic:turret"})) do
                if self.kingdom ~= minetest.get_meta(pos):get_string("kingdom.id") then
                    local turret_spell = magic.get_turret_spell(pos)
                    if turret_spell.protects and turret_spell.protects[def.element] and (self.was_near_turret > 1 or magic.use_turrent_spell(pos)) then
                        self.was_near_turret = self.was_near_turret + 1
                    end
                    if def.near_turret(self, pos, turret_spell) then
                        self.object:remove()
                        return
                    end
                end
            end

            local hitnode = nil
            local willremove = false

            for pos in rayIter(line.start, self.object:getvelocity(), vector.distance(line.start, line.finish)) do
                local node = minetest.get_node(pos)
                if node.name == "ignore" then
                    return
                elseif def.is_passthrough_node(self, pos, node) then
                    self.lastair = pos
                else
                    hitnode = pos
                    break
                end
            end

            if hitnode then
                if def.hit_node(self, hitnode, self.lastair) then
                    self.object:remove()
                    willremove = true
                end
            end

            local objs = minetest.get_objects_inside_radius(line.middle, (math.ceil(vector.distance(line.middle, line.start)) + math.ceil(vector.distance(line.middle, line.finish)) * 2) + 6)
            for k, obj in pairs(objs) do
                    local bb = obj:get_properties().collisionbox
                    local pp = vector.add(obj:getpos(), {x=0, y=0.5, z=0})
                    -- If bb collides with line...
                    local b1 = vector.add(pp, vector.multiply({x=bb[1], y=bb[2], z=bb[3]}, 1.5))
                    local b2 = vector.add(pp, vector.multiply({x=bb[4], y=bb[5], z=bb[6]}, 1.5))
                    if willremove and vector.distance(obj:getpos(), line.start) > vector.distance(hitnode, line.start) then
                        break
                    end
                    if CheckLineBox(b1, b2, line.start, line.finish) or CheckLineNear(line, pp, 1) then
                        if obj:get_luaentity() ~= nil then
                                if obj:get_luaentity().name ~= name and not NO_HIT_ENTS[obj:get_luaentity().name] then
                                    if def.hit_object(self, obj:getpos(), obj) then
                                        self.object:remove()
                                        return
                                    end
                                end
                        elseif obj:is_player() then
                            local can = true
                            if self.timer > 0.5 or not self.player or obj:get_player_name() ~= self.player:get_player_name() then
                                if def.hit_player(self, obj:getpos(), obj) then
                                    self.object:remove()
                                    return
                                end
                            end
                        end
                    end
            end

            if willremove then
                self.object:remove()
                return
            end

            if self.particletimer > 0.05 then
                minetest.add_particle({
                    pos = pos,
                    velocity = {x=math.random()-0.5, y=math.random()-0.5, z=math.random()-0.5},
                    acceleration = {x=0, y=-1, z=0},
                    expirationtime = 1.5,
                    size = math.random() * 4,
                    texture = "smoke_puff.png^[transform" .. math.random(0, 7),
                })
                self.particletimer = 0
            end

            self.lastpos={x=pos.x, y=pos.y, z=pos.z}
    end

    minetest.register_entity(name, ent_def)

    return function(itemstack, player, pointed_thing)
        local playerpos = player:getpos()
        local obj = minetest.add_entity({x=playerpos.x,y=playerpos.y+1.4,z=playerpos.z}, name)
        local dir = player:get_look_dir()
        obj:setvelocity({x=dir.x*def.speed, y=dir.y*def.speed, z=dir.z*def.speed})
        obj:setacceleration({x=0, y=-8.5*(def.gravity or 0), z=0})
        obj:setyaw(player:get_look_horizontal()+math.pi)
        obj:get_luaentity().player = player
        obj:get_luaentity().kingdom = kingdoms.player.kingdom(player:get_player_name()) and kingdoms.player.kingdom(player:get_player_name()).id or nil
        itemstack:take_item()
        return itemstack
    end
end
