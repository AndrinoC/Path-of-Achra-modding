# Example Enemy Pack

This example shows two custom enemies using prestige-style trait images as their sprites:

- `ExampleFenRaider`
- `ExampleVoidPilgrim`

Spawn behavior is based on the real game code in `LEnemies.gd`:

- `ExampleFenRaider` uses `tier: 1` and `summoned: false`, so it can enter normal early-land spawn pools and the nemesis tab
- `ExampleVoidPilgrim` uses `tier: 5` and `summoned: false`, so it can enter the void enemy pool and the nemesis tab

Important note:

- normal and void enemy spawning are driven by `tier`, not an item-style `rarity` field
- the current spawn code does not use `world` for pool selection

This mod is disabled by default through `enabled_by_default: false`.
