local trap = nil
local mode = nil
local scope = "public" -- Set scope of the chat message (public or private)

minetest.register_entity("freeze:fe", {
    physical = true,
    collisionbox = {-0.01,-0.01,-0.01, 0.01,0.01,0.01},
    visual = "sprite",
    visual_size = {x=0, y=0},
    textures = {"freeze_t.png"},
    is_visible = true,
    makes_footstep_sound = false,

    on_activate = function(self, staticdata)
        self.object:set_armor_groups({immortal = 1})

        if not trap or not mode or self.trapped then
            return
        end

        local playerobj = minetest.get_player_by_name(trap)

        if not playerobj then
            return
        end

        if mode == "a" then
            playerobj:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
		
		if scope == "public" then
            	  minetest.chat_send_all("*** "..trap.." can't move anymore.")
		else            
		  minetest.chat_send_player(trap,"You cannot move anymore.")
		end

	    self.trapped = trap

            trap = nil
            mode = nil
        end
    end,

    on_step = function(self,dtime)
        if not trap or not mode then
            return
        end

        if mode == "d" and trap == self.trapped then
            local pobj = minetest.get_player_by_name(trap)

            if not pobj then
                return
            end

            pobj:set_detach()
            
	    if scope == "public" then
                  minetest.chat_send_all("*** "..trap.." can move again.")
            else
                  minetest.chat_send_player(trap,"You can move now again.")
            end

            trap = nil
            mode = nil

            self.object:remove()
        end
    end,
})


minetest.register_on_joinplayer(function(player)
    local istrapped = player:get_attribute("freeze:istrapped")

    if istrapped then
        trap = player:get_player_name()
        mode = "a"
        local pos = player:get_pos()

        minetest.after(0.3,function()
            minetest.add_entity(pos, "freeze:fe")
        end)
    end
end)


minetest.register_on_leaveplayer(function(player)
    local ppos = player:get_pos()
    for _, obj in ipairs(minetest.get_objects_inside_radius(ppos, 2)) do
        obj:remove()
    end
end)


minetest.register_chatcommand("freeze", {
    params = "<player>",
    description = "Freeze movement of a player",
    privs = {kick = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(param)

        if not player then
            return true,"Player not online."
        end

	local frozen = player:get_attribute("freeze:istrapped")

	if frozen then
	    return true,"Player is already frozen."
	end

        trap = param
        mode = "a"
        player:set_attribute("freeze:istrapped","true")
        local pos = player:get_pos()
        minetest.add_entity(pos, "freeze:fe")
    end,
})

minetest.register_chatcommand("unfreeze", {
    params = "<player>",
        description = "Unfreeze movement of a player",
        privs = {kick = true},
        func = function(name, param)

        local player = minetest.get_player_by_name(param)

        if not player then
        return true,"Player not online."
        end

        player:set_attribute("freeze:istrapped",nil)

        trap = param
        mode = "d"
    end,
})
