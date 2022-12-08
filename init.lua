
sponge = {
    settings = {
        range = 6, -- How far a sponge can soak up?
        minimum = 3, -- Minimum nodes needed to replace the dry sponge to a wet/soggy sponge?
        soak_lava = true, -- do sponges soak up lava?
    },
    version = "2.0.1", -- Our version
    liquids = {
        water = { -- Nodes counted as water
            "default:water_source",
            "default:water_flowing"
        },
        river = { -- Nodes counted as river water
            "default:river_water_source",
            "default:river_water_flowing",
        },
        lava = { -- Nodes counted as lava
            "default:lava_source",
            "default:lava_flowing",
        }
    }
}

-- Process settings
local modpath = minetest.get_modpath("sponge")
dofile(modpath .. DIR_DELIM .. "settings.lua")

-- Checks if the node is water
sponge.is_water = function(node)
    if type(node) ~= "string" and node.name ~= nil then
        node = node.name
    end
    for _, val in pairs(sponge.liquids.water) do
        if val == node then
            return true
        end
    end
    return false
end

-- Checks if the node is river water
sponge.is_river = function(node)
    if type(node) ~= "string" and node.name ~= nil then
        node = node.name
    end
    for _, val in pairs(sponge.liquids.river) do
        if val == node then
            return true
        end
    end
    return false
end

-- Checks if the node is lava (only if a sponge can soak up lava)
--
-- Also accepts admin mode (so the chat command will regardless soak up lava)
sponge.is_lava = function(node, admin)
    if type(node) ~= "string" and node.name ~= nil then
        node = node.name
    end
    if not sponge.settings.soak_lava and admin == nil then -- stop here, we don't want to replace lava
        return false
    end
    for _, val in pairs(sponge.liquids.lava) do
        if val == node then
            return true
        end
    end
    return false
end

local nodes = {} -- Cache the list of nodes we look for

-- Given the position of which we've placed a dry sponge
--
-- Replaces liquids into air (counting each one by water, river water, and lava)
-- Determins if the dry sponge replaced enough liquids to be swapped
-- Determins what the sponge should swap too by the count of each node
--
-- Will log any errors it encounters
local placement = function(pos)
    local min = vector.subtract(pos, {x=sponge.settings.range, y=sponge.settings.range, z=sponge.settings.range})
    local max = vector.add(pos, {x=sponge.settings.range, y=sponge.settings.range, z=sponge.settings.range})
    --minetest.log("action", "[sponge] min=" .. minetest.pos_to_string(min) .. " max=" .. minetest.pos_to_string(max))
    if #nodes == 0 then -- Generate a cache of nodes we look for
        for _, val in pairs(sponge.liquids.water) do
            table.insert(nodes, val)
        end
        for _, val in pairs(sponge.liquids.river) do
            table.insert(nodes, val)
        end
        for _, val in pairs(sponge.liquids.lava) do
            table.insert(nodes, val)
        end
        --minetest.log("action", "[sponge] nodes=" .. minetest.serialize(nodes))
    end
    local area = minetest.find_nodes_in_area(min, max, nodes)
    if not area or #area == 0 then -- We found nothing
        return
    end
    local waters = 0
    local rivers = 0
    local lavas = 0
    for i=1, #area do
        local node = minetest.get_node_or_nil(area[i])
        if not node then
            minetest.log("action", "[sponge] Failed obtaining node " .. minetest.pos_to_string(area[i], 1))
        else
            --minetest.log("action", "[sponge] " .. minetest.pos_to_string(area[i], 1) .. " = " .. node.name)
            local delta = vector.subtract(area[i], pos)
            local distance = (delta.x*delta.x) + (delta.y*delta.y) + (delta.z*delta.z)
            local range = sponge.settings.range
            if sponge.is_lava(node) then
                range = range - 2
            end
            if range <= 0 then
                range = 1
            end
            if distance <= range then
                local replace = false
                if sponge.is_water(node) then
                    waters = waters + 1
                    replace = true
                elseif sponge.is_river(node) then
                    rivers = rivers + 1
                    replace = true
                elseif sponge.is_lava(node) then
                    lavas = lavas + 1
                    replace = true
                end
                if replace then
                    minetest.remove_node(area[i])
                end
            end
        end
    end
    local total = waters + rivers + lavas
    if total < sponge.settings.minimum then
        return -- We don't need to swap, we didn't soak up the minimum number of nodes
    end
    if (waters ~= 0 and rivers ~= 0 and lavas ~= 0) and (waters == lavas and waters == rivers) then
        -- I've determined lava more valuable than water or river water
        -- So when/if there is a tie then we go for lava (more valuable)
        minetest.swap_node(pos, {name="sponge:sponge_lava"})
        return -- We're done, no need to check the below for swaping
    end
    if waters ~= 0 then
        if waters > rivers and waters > lavas then
            minetest.swap_node(pos, {name="sponge:sponge_water"})
        end
    elseif rivers ~= 0 then
        if rivers > waters and rivers > lavas then
            minetest.swap_node(pos, {name="sponge:sponge_river"})
        end
    elseif lavas ~= 0 then
        if lavas > waters and lavas > rivers then
            minetest.swap_node(pos, {name="sponge:sponge_lava"})
        end
    end
end

-- This is the admin chat command function
--
-- It ignores sponge.soak_lava, and doesn't replace any node since there isn't one. (it moves by player)
sponge._placement = function(pos)
    local min = vector.subtract(pos, {x=sponge.settings.range, y=sponge.settings.range, z=sponge.settings.range})
    local max = vector.add(pos, {x=sponge.settings.range, y=sponge.settings.range, z=sponge.settings.range})
    --minetest.log("action", "[sponge] min=" .. minetest.pos_to_string(min) .. " max=" .. minetest.pos_to_string(max))
    if #nodes == 0 then -- Generate a cache of nodes we look for
        for _, val in pairs(sponge.liquids.water) do
            table.insert(nodes, val)
        end
        for _, val in pairs(sponge.liquids.river) do
            table.insert(nodes, val)
        end
        for _, val in pairs(sponge.liquids.lava) do
            table.insert(nodes, val)
        end
        --minetest.log("action", "[sponge] nodes=" .. minetest.serialize(nodes))
    end
    local area = minetest.find_nodes_in_area(min, max, nodes)
    if not area or #area == 0 then -- We found nothing
        return
    end
    for i=1, #area do
        local node = minetest.get_node_or_nil(area[i])
        if not node then
            minetest.log("action", "[sponge] Failed obtaining node " .. minetest.pos_to_string(area[i], 1))
        else
            --minetest.log("action", "[sponge] " .. minetest.pos_to_string(area[i], 1) .. " = " .. node.name)
            local delta = vector.subtract(area[i], pos)
            local distance = (delta.x*delta.x) + (delta.y*delta.y) + (delta.z*delta.z)
            local range = sponge.settings.range
            if distance <= range then
                local replace = false
                if sponge.is_water(node) then
                    replace = true
                elseif sponge.is_river(node) then
                    replace = true
                elseif sponge.is_lava(node, true) then
                    replace = true
                end
                if replace then
                    minetest.remove_node(area[i])
                end
            end
        end
    end
end

minetest.register_node("sponge:sponge", {  -- dry sponge
    description = "Sponge",
    tiles = {"sponge_sponge.png"},
    groups = {crumbly=3},
    sounds = default.node_sound_dirt_defaults(),
    after_place_node = placement,
})

minetest.register_node("sponge:sponge_water", {
    description = "Wet Sponge (Water)",
    tiles = {"sponge_water_sponge.png"},
    groups = {crumbly=3},
    sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("sponge:sponge_river", {
    description = "Wet Sponge (River Water)",
    tiles = {"sponge_river_sponge.png"},
    groups = {crumbly=3},
    sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("sponge:sponge_lava", {
    description = "Wet Sponge (Lava)",
    tiles = {"sponge_lava_sponge.png"},
    groups = {crumbly=3},
    sounds = default.node_sound_dirt_defaults(),
})

-- Cooking simply returns a dry sponge (but doesn't return the liquid)
minetest.register_craft({
    type = "cooking",
    recipe = "sponge:sponge_water",
    output = "sponge:sponge",
    cooktime = 2,
})
minetest.register_craft({
    type = "cooking",
    recipe = "sponge:sponge_river",
    output = "sponge:sponge",
    cooktime = 2,
})
minetest.register_craft({
    type = "cooking",
    recipe = "sponge:sponge_lava",
    output = "sponge:sponge",
    cooktime = 2,
})

-- Use sponge_lava as fuel
minetest.register_craft({
	type = "fuel",
	recipe = "sponge:sponge_lava",
	burntime = 60, -- Equal to a bucket:bucket_lava
	replacements = {{"sponge:sponge_lava", "sponge:sponge"}},
})

-- Collection recipes (returns a dry sponge, and the liquid)
minetest.register_craft({
    type = "shapeless",
    output = "sponge:sponge 1",
    recipe = {
        "sponge:sponge_water",
        "bucket:bucket_empty"
    },
    replacements = {
        {"bucket:bucket_empty", "bucket:bucket_water"}
    }
})
minetest.register_craft({
    type = "shapeless",
    output = "sponge:sponge 1",
    recipe = {
        "sponge:sponge_river",
        "bucket:bucket_empty"
    },
    replacements = {
        {"bucket:bucket_empty", "bucket:bucket_river_water"}
    }
})
minetest.register_craft({
    type = "shapeless",
    output = "sponge:sponge 1",
    recipe = {
        "sponge:sponge_lava",
        "bucket:bucket_empty"
    },
    replacements = {
        {"bucket:bucket_empty", "bucket:bucket_lava"}
    }
})

-- Natural spawning
-- sponges are found deep in the sea
minetest.register_decoration({
    name = "sponge:sponges",
    deco_type = "simple",
    place_on = {"default:sand"},
    spawn_by = "default:water_source",
    num_spawn_by = 3,
    fill_ratio = 0.0003,
    y_max = -12,
    flags = "force_placement",
    decoration = "sponge:sponge_water",
})
minetest.register_decoration({
    name = "sponge:sponges_river",
    deco_type = "simple",
    place_on = {"default:sand"},
    spawn_by = "default:river_water_source",
    num_spawn_by = 3,
    fill_ratio = 0.0003,
    y_max = -12,
    flags = "force_placement",
    decoration = "sponge:sponge_river",
})

-- Admin chat command
dofile(modpath .. DIR_DELIM .. "admin.lua")

minetest.log("action", "[sponge] Version: " .. sponge.version)
minetest.log("action", "[sponge] Ready")
