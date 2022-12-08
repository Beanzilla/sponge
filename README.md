# Sponge

Liquid-removing sponges.

[Original](https://github.com/BenjieFiftysix/sponge) made by Benjie/Fiftysix

## In the box

- A dry sponge, when placed replaces a set of liquids into air. (unlike the Original we don't keep liquid away, due to an [issue](https://github.com/BenjieFiftysix/sponge/issues/2))
- When a dry sponge replaces 3 or more liquids it becomes soaked.
- Cooking a soaked sponge returns a dry sponge.
- **Or** place a soaked sponge in the crafting grid with a empty bucket to collect the liquid and get a dry sponge back. (at most 1 bucket of liquid can be obtained, regardless of how much liquid the sponge really soaked up)
- **Or** place soaked sponge full of lava as fuel in a furnace, you'll get a dry sponge back and get a awesome burntime.
- There are 4 variants of sponges. (dry, water, river_water, lava)
- The dry sponge can collect both water or lava! (lava has a reduced collection range)

## Setting types

- `sponge.soak_lava` (boolean, default true) Can dry sponges soak up lava?
- `sponge.range` (int, default 6) Distance that liquids from a placed dry sponge will be turned to air, Can't be smaller than 4. (a dry sponge soaking lava reduces this by 2, thus must be 4 or higher)
- `sponge.minimum` (int, default 3) Number of liquids a placed dry sponge must turn to air before becoming a soaked sponge.
