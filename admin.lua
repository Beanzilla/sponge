
sponge.players = {}
minetest.register_chatcommand("sponge", {
    privs = {
        shout = true,
        server = true,
    },
    description = "Toggles a auto collecting liquid feature",
    func = function(name, param)
        -- Check if they are already in the list
        local idx = -1
        for i, p in pairs(sponge.players) do
            if p == name then
                found = true
                idx = i
                break
            end
        end
        if idx ~= -1 then
            -- They existed, remove them
            table.remove(sponge.players, idx)
            return true, "Auto-Sponge: OFF"
        else
            -- They didn't exist, add them
            table.insert(sponge.players, name)
            return true, "Auto-Sponge: ON"
        end
    end,
})

minetest.register_on_leaveplayer(function(player)
    -- Check if they are in the list
    local idx = -1
    for i, p in pairs(sponge.players) do
        if p == name then
            found = true
            idx = i
            break
        end
    end
    if idx ~= -1 then
        -- They existed, remove them
        table.remove(sponge.players, idx)
    end
end)

local interval = 0
mintest.register_globalstep(function(detla)
    interval = interval + delta
    if interval >= 1 then -- every second
        for _, player in pairs(sponge.players) do
            if not player then
                goto continue
            end
            if not minetest.get_player_by_name(player:get_player_name()) then
                goto continue
            end
            sponge._placement2(player:get_pos())
            ::continue::
        end
        interval = 0
    end
end)
