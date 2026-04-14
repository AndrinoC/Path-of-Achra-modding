# Loader Integration Notes

`ModLoader.gd` is the main runtime loader, but it is not enough by itself.

To integrate it into the base game, the shipped game scripts also need small bridge changes.

## Base Game Integration Points

These are the files changed in the tested setup:

- `global.gd`
  - create the loader node at startup
  - expose wrapper methods such as `merge_loaded_data()`, `load_mod_texture()`, and mod toggle helpers
  - provide a direct built-in feature config fallback for the `Tame` toggle path
  - store per-floor range-cache state and pooled temporary effect nodes
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
  - expose `Toggle Tame mechanic` as a built-in Mods-tab row even when no external mods exist
  - expose `Toggle Combat log processing` as a built-in Mods-tab row even when no external mods exist
  - expose `Toggle Item comparison` as a built-in Mods-tab row even when no external mods exist
- `Scenes/Start_Menu.gd`
  - allow custom classes, races, and gods to appear in character creation
  - merge modded invoke data into character-creation prayer setup so modded gods can provide non-null prayers
  - resolve missing saved selections safely when a mod is disabled
  - resolve starting class gear from the merged weapon and armor tables
  - fall back safely when a modded race skin variant is missing
  - clear Maqbara-selected graveyard keys when starting a fresh run from normal character creation
  - expose `Toggle Tame mechanic` as a built-in Mods-tab row even when no external mods exist
  - expose `Toggle Combat log processing` as a built-in Mods-tab row even when no external mods exist
  - expose `Toggle Item comparison` as a built-in Mods-tab row even when no external mods exist
  - cache victory marker title data instead of rescanning and deep-cloning the full graveyard on every open
- `Button_StartMenu.gd`
  - respect loader-provided default-unlocked content in the selection buttons
  - fall back from missing `icon` art to `sprite` art for selection buttons
- `LWep.gd` and `LArm.gd`
  - rebuild runtime weapon and armor caches from merged table data after mods load
- `LEnemies.gd`
  - rebuild runtime enemy caches from merged enemy data after mods load
- `ToolGenerateContinent.gd`
  - build world-map treasure pools from merged weapon and armor data using the same rarity rules as the base game
- `ToolGenerateLevel.gd`
  - batch level generation steps so dungeon carving finishes immediately instead of waiting on visual timer slices
  - cache A* tile lookup by id during generation
  - clear pure area range caches when a new floor is generated
- `Scenes/Invokes.gd`
  - add a fixed `Tame` combat action button separate from religion-based invokes
- `Button_Invoke.gd`
  - route the special `Tame` button through game-side logic instead of prayer casting
- `Scenes/Player.gd`
  - use the loader texture fallback for modded body and equipment layers in-world
  - add hotkey support and score tracking for `Tame`
- `Scenes/Enemy.gd`
  - allow enemy click targeting for `Tame`
  - reduce speed-bar `_process()` churn by throttling redundant visual updates
- `ModLoader.gd`
  - expose `Tame` as a built-in toggleable feature in the Mods tab
  - expose combat log processing as a built-in toggleable feature in the Mods tab
  - expose inventory item comparison as a built-in toggleable feature in the Mods tab
  - persist built-in feature state through `mods-config.json`
- `ToolSaveGraveyard.gd`
  - save Maqbara records under unique compatible keys instead of raw `title_name`
  - increase the Maqbara cap to `500`
  - batch viewed-state updates through a multi-key save path
- `Scenes/Tile.gd`
  - cancel `Tame` target selection on ground click
  - reduce per-frame deck-highlight work when selection state has not changed
- `Scenes/UI_Inv.gd`
  - use the loader texture fallback for the inventory paper-doll body and equipment layers
  - add a toggleable item-comparison preview in inventory with dedicated compare-panel layout
- `Scenes/Game.gd`
  - reduce repeated work in tile refresh and range-indicator updates
  - own the `Tame` action state, validation, chance calculation, and ally conversion
  - stop range-indicator refresh from clearing every ground tile each time
  - defer heavy full-room/UI refreshes during effect-chain processing and flush them at safe points
  - track dirty tiles, dirty units, and dirty UI state so queued combat flushes can use partial room refreshes instead of always rebuilding the full room
- `Scenes/Tile.gd`
  - cache hot child-node references and reuse cached textures during frequent tile updates
- `Scenes/Tile_World.gd`
  - cache world-map child-node references and repeated tier or sprite texture loads
- `Scenes/Continent.gd`
  - reuse cached map icon textures for selected tile, enemy, and item display
- `Scenes/ButtonMaqbara.gd`
  - support pooled Maqbara button rendering and wheel-scroll forwarding
- `Scenes/Graveyard.gd`
  - scroll large Maqbara record sets
  - use visible-button pooling instead of rebuilding the full visible set every wheel step
  - avoid duplicate graveyard loads on scene entry
- `RouterEvents_OnDeath.gd`
  - stop dead unit node processing and remove dead units from active turn scheduling
  - mark corpse and nearby tiles dirty so death cleanup can use partial room refreshes when safe
- `RouterEvents_OnMove.gd`
  - mark moved units, source and destination tiles, and deck/range/hover state dirty instead of forcing broad redraw work on every move
- `RouterEvents_OnTeleport.gd`
  - mark teleport source and destination state dirty for partial refresh handling
- `RouterEvents_OnDamage.gd`
  - mark attacker and defender state dirty after HP changes so enemy-only combat updates can stay local when safe
- `RouterEvents_OnHeal.gd`
  - mark healed and healer state dirty after HP changes
- `RouterEvents_OnApplyBuff.gd` and `RouterEvents_OnRemoveBuff.gd`
  - mark buff target state dirty so buff churn does not always require a full room redraw
- `Process_Queue2.gd`
  - clean stale dead or invalid units from `active_units` before scheduling AI turns
  - keep an active-unit membership set so large summon swarms avoid repeated linear membership checks and erase churn
- `Process_Queue.gd`
  - preserve existing newest-first effect execution order while avoiding front-array removal churn in `queue_effects`
  - mark direct fallback move updates dirty when movement resolves inside queue processing
  - stop re-cleaning the entire effect queue before every effect pop and instead inspect only the next queued effect while preserving existing order
- `ToolMessageCreator.gd`
  - show `Tame` help text and per-target tame chance while selecting
  - batch combat-log redraw requests until control-return / end-of-turn style flush points during chain-heavy processing
  - skip combat-log message accumulation and redraw work entirely when built-in combat log processing is disabled
- `Tool_CalculateRange.gd`
  - cache pure area tile-range lookups for repeated same-floor AoE scans
- `ToolCreateEffect.gd`
  - reuse pooled temporary animated effect nodes instead of always instancing new ones
- `Scenes/EffectAnimated.gd`
  - reset and recycle temporary animated effects back into the shared pool on expire
- `Scenes/Delayed_Event.gd`
  - stop per-node `_process()` polling for delayed-event visuals
  - keep delayed event execution logic in the same tick-order path
- `Process_Text.gd`
  - pool floating text popup nodes instead of instancing a fresh popup for every damage/heal number
- `Scenes/Text_Popup.gd`
  - recycle floating text popups safely and use delta-based lifetime timing for stable readability across framerates
- `Process_Queue_Actions_Effects.gd`
  - resolve queued `Tame` attempts through the normal action effect pipeline
  - expose single-action queue inspection so long effect chains avoid repeated full queue rescans
  - recheck enemy-live gated queued effects at resolution time so effects documented as working only while enemies live do not keep firing after the last enemy dies
- `ToolMagicMaker.gd`
  - mark terrain-changing and buff-duration-changing effect paths dirty for partial room refreshes
- `ToolAI.gd`
  - search enemy residences directly instead of rescanning all ground tiles during swarm-heavy AI target selection
- `Tool_CalculateRange.gd`
  - provide direct closest-open-tile and one-pass random-open-tile helpers for summon placement
- `ToolSpawnUnit.gd`
  - mark newly occupied summon tiles and related UI state dirty instead of relying on a full-room redraw
  - stop rebuilding summon info UI for every repeated summon of the same unit type
- `Universal.gd`
  - update the FPS label as plain text instead of rebuilding right-aligned BBCode every frame
  - reduce FPS label refresh frequency to avoid needless per-frame UI churn
- `Scenes/Universal.tscn`
  - widen or reposition the FPS label so the value stays on one line
- `Scenes/GameBars.gd`
  - throttle repeated turn-bar and speed-bar UI updates when state is unchanged
- `Scenes/UI.gd`
  - only refresh glow indicator visibility when the glow state changes
  - hide and disable combat-log UI widgets when built-in combat log processing is disabled while keeping hover descriptions available
- `Scenes/DeckbuttonGrid.gd`
  - avoid forcing the same mouse-mode state every frame
- `Scenes/Game.gd`
  - centralize delayed-event visual refreshes in a throttled game-level update path
- `Scenes/UI_GameMenu.gd` and `Scenes/DeathScreen.gd`
  - write Maqbara dust progress back to the selected unique graveyard key instead of only `title_name`
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

Built-in feature toggles such as `Tame` and combat log processing also persist there under the same config file.

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
- Maqbara record-key upgrades, 500-record support, and wheel-scrolling for large graveyard sets
- safer runtime cleanup for dead units and several lower-churn `_process()` loops in combat and UI scenes
- a built-in Mods-tab toggle for enabling or disabling the `Tame` mechanic by restartable feature state
- a built-in Mods-tab toggle for enabling or disabling combat log processing by restartable feature state
- batched combat log updates, pooled temporary combat effects, and cached pure area range queries for heavy chain-combat scenarios
- centralized delayed-event visual updates and an order-preserving `queue_effects` optimization for heavy chained combat
- deferred full-room refreshes, pooled floating text, and cached start-menu victory markers for better heavy-combat and large-save responsiveness

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
