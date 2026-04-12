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
  - resolve starting class gear from the merged weapon and armor tables
  - fall back safely when a modded race skin variant is missing
- `Button_StartMenu.gd`
  - respect loader-provided default-unlocked content in the selection buttons
- `LWep.gd` and `LArm.gd`
  - rebuild runtime weapon and armor caches from merged table data after mods load
- `LEnemies.gd`
  - rebuild runtime enemy caches from merged enemy data after mods load
- `ToolGenerateContinent.gd`
  - build world-map treasure pools from merged weapon and armor data using the same rarity rules as the base game
- `ToolGenerateLevel.gd`
  - batch level generation steps so dungeon carving finishes immediately instead of waiting on visual timer slices
  - cache A* tile lookup by id during generation
- `Scenes/Invokes.gd`
  - add a fixed `Tame` combat action button separate from religion-based invokes
- `Button_Invoke.gd`
  - route the special `Tame` button through game-side logic instead of prayer casting
- `Scenes/Player.gd`
  - use the loader texture fallback for modded body and equipment layers in-world
  - add hotkey support and score tracking for `Tame`
- `Scenes/Enemy.gd`
  - allow enemy click targeting for `Tame`
- `Scenes/Tile.gd`
  - cancel `Tame` target selection on ground click
- `Scenes/UI_Inv.gd`
  - use the loader texture fallback for the inventory paper-doll body and equipment layers
- `Scenes/Game.gd`
  - reduce repeated work in tile refresh and range-indicator updates
  - own the `Tame` action state, validation, chance calculation, and ally conversion
- `Scenes/Tile.gd`
  - cache hot child-node references and reuse cached textures during frequent tile updates
- `Scenes/Tile_World.gd`
  - cache world-map child-node references and repeated tier or sprite texture loads
- `Scenes/Continent.gd`
  - reuse cached map icon textures for selected tile, enemy, and item display
- `ToolMessageCreator.gd`
  - show `Tame` help text and per-target tame chance while selecting
- `Process_Queue_Actions_Effects.gd`
  - resolve queued `Tame` attempts through the normal action effect pipeline
- `Universal.gd`
  - update the FPS label as plain text instead of rebuilding right-aligned BBCode every frame
- `Scenes/Universal.tscn`
  - widen or reposition the FPS label so the value stays on one line
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
- merged skill entries
- merged class, race, and god entries
- merged weapon and armor entries
- merged enemy entries
- merged invoke, buff, ally, and lore entries
- merged lore entries
- title-screen mod enable or disable toggling
- richer unlock rules
- broader event trigger coverage
- generic condition rules
- direct queue-action passthrough via the external schema
- synthetic generic start-trait entries for modded class, race, and god traits
- trait-level context for queued-effect schema references
- world-map item pool integration through item `rarity`
- mod-local texture loading for `sprite`, `icon`, `icon_small`, and `proj_art`
- filesystem-first loading for `res://mods/...` art used by in-game player and UI layers
- auto-resize of non-`32x32` mod images to the game's expected sprite footprint
- cached texture reuse for repeated base and mod texture lookups in hot UI paths
- safer low-risk performance fixes in level generation and tile refresh paths
- a fixed once-per-map `Tame` action that is independent from religion-based invoke logic

## Scope

This loader is intended to support lightweight prestige mods with:

- external prestige data
- external skill data
- external class, race, and god data
- external weapon and armor data
- world-map treasure integration for external weapon and armor data through the normal continent generator rarity path
- external lore
- external icons and player-layer sprites
- simple built-in combat behaviors
- title-screen mod enable or disable toggling

The current full schema is documented in `ModSchema.md`.

If you want trigger types, conditions, or actions beyond that documented schema, you will need to extend the base loader and rebuild the base pack.
