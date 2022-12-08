
sponge.settings.soak_lava = minetest.settings:get_bool("sponge.soak_lava")
if not sponge.settings.soak_lava then
    sponge.settings.soak_lava = true
    minetest.settings:set_bool("sponge.soak_lava", true)
end

sponge.settings.range = minetest.settings:get("sponge.range")
if not sponge.settings.range then
    sponge.settings.range = 6
    minetest.settings:set("sponge.range", 6)
else
    sponge.settings.range = tonumber(sponge.settings.range)
    if sponge.settings.range < 4 then
        sponge.settings.range = 4
    end
end

sponge.settings.minimum = minetest.settings:get("sponge.minimum")
if not sponge.settings.minimum then
    sponge.settings.minimum = 3
    minetest.settings:set("sponge.minimum", 3)
else
    sponge.settings.minimum = tonumber(sponge.settings.minimum)
    if sponge.settings.minimum < 1 then
        sponge.settings.minimum = 1
    end
end
