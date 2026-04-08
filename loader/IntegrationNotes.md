# Loader Integration Notes

`ModLoader.gd` is the main runtime loader, but it is not enough by itself.

To integrate it into the base game, the shipped game scripts also need small bridge changes.

## Base Game Integration Points

These are the files changed in the tested setup:

- `global.gd`
  - create the loader node at startup
  - expose wrapper methods such as `merge_loaded_data()`, `load_mod_texture()`, and mod toggle helpers
- `ToolLoaderJson.gd`
  - merge external prestige, skill, class, race, god, item, and lore data after loading JSON
- `ToolPrestigeGiver.gd`
  - append external prestige entries
  - show external requirement labels
  - evaluate richer external unlock rules
- `RouterEvents_OnAttack.gd`
  - dispatch `on_attack` prestige triggers to the loader
- `RouterEvents_OnBlock.gd`
  - dispatch `on_block` prestige triggers to the loader
- additional event routers
  - dispatch the broader external trigger set such as hit, damage, heal, move, dodge, death, buffs, level, teleport, pickup, invoke, learn, summon, and turn
- `Scenes/First_Menu.gd`
  - add the title-screen `Mods` button and mod list panel
  - allow enable or disable toggling with restart-required messaging
- `Scenes/Start_Menu.gd`
  - allow custom classes, races, and gods to appear in character creation
  - resolve missing saved selections safely when a mod is disabled
- `Button_StartMenu.gd`
  - respect loader-provided default-unlocked content in the selection buttons
- UI files
  - use the loader texture fallback so external mod icons render correctly

Tested UI files:

- `Scenes/Button_Traits_UI.gd`
- `Scenes/UI_Prestige.gd`
- `Scenes/UI_Traits_Basic.gd`
- `Scenes/Feats.gd`
- `Scenes/UI_Inv.gd`
- `Scenes/UI_Enemies.gd`
- `Scenes/AbilityBook.gd`

## Mod State Persistence

The loader stores mod enabled or disabled state in:

- `user://mods-config.json`

This is separate from normal game settings.

The current setup reads mod state at startup, so changes made in the Mods panel require a restart.

## Current Supported Schema

Current support includes:

- merged prestige entries
- merged lore entries
- title-screen mod enable or disable toggling
- richer unlock rules
- broader event trigger coverage
- generic condition rules
- direct queue-action passthrough via the external schema

## Scope

This loader is intended to support lightweight prestige mods with:

- external prestige data
- external skill data
- external class, race, and god data
- external weapon and armor data
- external lore
- external icons
- simple built-in combat behaviors
- title-screen mod enable or disable toggling

The current full schema is documented in `ModSchema.md`.

If you want trigger types, conditions, or actions beyond that documented schema, you will need to extend the base loader and rebuild the base pack.
