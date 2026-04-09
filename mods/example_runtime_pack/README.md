# Example Runtime Pack

This example shows one working chain built from three custom content types:

1. a custom god: `ExampleLanternSaint`
2. a custom invoke: `ExampleLanternVigil`
3. a custom buff and ally: `ExampleAshenWard` and `ExampleLanternWisp`

Enable the mod, restart the game, choose `Lantern Saint`, and use `Lantern Vigil` in combat.

The invoke does three things through `trait_effects`:

- applies the custom buff to yourself
- summons the custom ally
- deals `10 Astral damage` to the closest enemy

This mod is disabled by default through `enabled_by_default: false`.

It also demonstrates table references inside queued effects:

- `buffs.ExampleAshenWard`
- `allies.ExampleLanternWisp`
