# Path of Achra Modding Guide

## What You Need

- `Path of Achra`
- the loader-enabled `PathofAchra.pck`
- a mod folder inside `mods/`

This guide is for the current loader-based setup.

For the full prestige schema reference, see `ModSchema.md`.

## Current Release Pack

The current shipped `PathofAchra.pck` release is not only the loader-enabled pack.

It also includes a few safe base-pack fixes that do not intentionally change game content:

- faster level generation by batching floor generation steps instead of visually time-slicing them
- cheaper texture lookups in hot UI and tile update paths through caching
- lighter range-indicator and tile update loops
- FPS counter text fixed to stay on one line
- a new once-per-map `Tame` action that lets the player try to convert one visible enemy into an ally

Core content, loot rules, enemy pools, and mod schema behavior are meant to stay the same.

## Included Base Pack Action: Tame

The current release pack also adds a non-religion action named `Tame`.

- hotkey: `4`
- use limit: `1` per combat map
- target: one visible enemy
- result: roll a chance to convert that enemy into an ally

Current tame chance uses:

- your total `Willpower`
- enemy `Willpower`
- enemy normal `tier`
- boss penalty
- summoned bonus
- missing-health bonus
- distance-based minimum chance

The implementation deliberately does **not** use religion or prayer charge logic.

## Installing The Loader

If the loader is not already installed:

1. Back up the original game pack:

```powershell
Copy-Item '.\PathofAchra.pck' '.\PathofAchra_original_backup.pck'
```

2. Install the loader-enabled pack:

```powershell
Copy-Item 'C:\path\to\downloaded\PathofAchra.pck' '.\PathofAchra.pck' -Force
```

Download `PathofAchra.pck` from the latest GitHub release, place it in the game folder, and replace the game's existing `PathofAchra.pck` with it.

That enables external mods from the `mods/` folder.

When the loader is installed, the title screen main menu will show a new `Mods` button above `Quit`.

The current release pack also includes the base-pack quality-of-life fixes listed above, so you do not need a separate patch for them.

Use that menu to:

- see detected mods
- enable or disable mods
- see when a restart is required

Mod enable or disable state is saved in a separate user config and applies after restarting the game.

## Installing A Mod

Drop a mod folder into:

```text
mods/<mod_id>/
```

Example:

```text
mods/example_pitfighter/
  mod.json
  content.json
  icons/
  PitFighter.png
```

Start the game. The loader scans `mods/` automatically.

You can then open the in-game `Mods` button to enable or disable the mod.

Changes take effect after restarting the game.

## Included Showcase Mods

The repository now ships with curated showcase mods instead of blank templates:

```text
mods/reedbound_ascetic/
mods/lantern_saint/
mods/causeway_warden/
mods/fen_hunt/
```

All showcase mods are disabled by default.

Other disabled example mods are also included:

- `mods/example_pitfighter/`
- `mods/example_tempest_adept/`
- `mods/example_wayfarer/`
- `mods/example_content_pack/`
- `mods/example_runtime_pack/`
- `mods/example_enemy_pack/`

The included showcase mods are meant to read like finished game content:

- colored trigger and element keywords
- explicit values in descriptions when the effect uses fixed numbers
- short lore text instead of placeholder developer text
- real image files stored inside each mod folder
- separate UI icon art and in-game sprite art where needed

Use the showcase packs as starting points:

- `reedbound_ascetic` for prestige mods
- `lantern_saint` for gods, allies, buffs, invokes, and skill runtime effects
- `causeway_warden` for races, classes, skills, and starting gear
- `fen_hunt` for custom enemies and spawn-pool integration

If you want modded weapons or armor to appear in normal map treasure, set their `rarity` to match the real continent loot code:

- `rarity: 1` for normal world treasure
- `rarity: 2` for void treasure
- `rarity: 0` if they should stay out of the continent treasure pools

For custom enemies, the real spawn and nemesis rules come from `LEnemies.gd` and `Scenes/Bestiary.gd`:

- `summoned: false` puts them in normal enemy spawn pools
- `summoned: true` keeps them out of normal world spawns
- `tier: 1+` makes them eligible for the nemesis tab

Recommended workflow:

1. Copy the showcase mod closest to what you want.
2. Rename the folder and `mod.json` id.
3. Replace the internal keys in `content.json`.
4. Swap the copied art in `icons/` for your own.
5. Launch the game and test.

For race bodies and starting gear, prefer separate files for UI and in-game layers:

- `icon` for menus, buttons, and inventory item art
- `sprite` for in-game body or equipment layering
- `icon_small` for compact race UI icons when a race uses one
- `proj_art` for custom projectile visuals when an entry supports it

The loader supports `res://mods/...` art for these fields.

For in-game body, weapon, and armor layers, make the `sprite` art fit the same `32x32` player-layer footprint as the base game. If you only reuse a portrait-style icon, it may technically load but still read poorly in-world.


## Mod File Layout

```text
mods/my_mod/
  mod.json
  content.json
  icons/
    MyPrestige.png
```

## `mod.json`

```json
{
  "id": "my_mod",
  "name": "My Mod",
  "version": "1.0.0",
  "author": "YourName",
  "enabled_by_default": true,
  "load_order": 100
}
```

Set `enabled_by_default` to `false` if you want a template or example mod to stay off until the player enables it in the Mods menu.

## `content.json`

```json
{
  "prestiges": {
    "MyPrestige": {
      "trait": {
        "title": "MyPrestige",
        "Name": "[color=#70ff60]My Prestige[/color]",
        "Level": 1,
        "Description": "On [color=#ff8030]attack[/color]: ...",
        "Description_Unit": "Short alternate description.",
        "Element": "None",
        "sprite": "icons/MyPrestige.png",
        "base": 0,
        "cost": 1,
        "infpen": false,
        "generic": true,
        "reference": "none",
        "organize": "prestige",
        "levelable": false
      },
      "lore": {
        "title": "MyPrestige",
        "text": "Your lore text here."
      },
      "unlock": {
        "type": "always",
        "label": "[color=#70ff60]No requirement[/color] [color=#707070](test)[/color]"
      },
      "effects": []
    }
  }
}
```

The full unlock, trigger, condition, action, metric, and reference system is documented in `ModSchema.md`.

## Icons

Recommended:

1. make a clear `32x32` icon
2. place it in `icons/`
3. point `trait.sprite` at it

Example:

```json
"sprite": "icons/MyPrestige.png"
```

For entries that appear both in UI and on the player sprite, use separate files when needed. `icon` and `sprite` do not have to point to the same PNG.

## Testing Tips

Start with:

```json
"unlock": {
  "type": "always",
  "label": "[color=#70ff60]No requirement[/color] [color=#707070](test)[/color]"
}
```

Once the prestige appears and works, switch to the real requirement.

If an icon is wrong in an old save, test in a new save first. Old saves can keep cached prestige data from earlier versions.

## When You Need Base Pack Editing

Most prestige mods should only need a mod folder.

You only need to edit and rebuild `PathofAchra.pck` if you want to:

- change the loader itself
- add new trigger types
- add new condition types
- add new action types
- change deeper core game systems

## Restore The Original Game

If you made a backup:

```powershell
Copy-Item '.\PathofAchra_original_backup.pck' '.\PathofAchra.pck' -Force
```
