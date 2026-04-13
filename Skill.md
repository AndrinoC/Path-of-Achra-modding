# Path of Achra Working Skill

## Project Reality

- This workspace is the live game install plus recovered source.
- The game is Godot 3.5.x / GDScript, not Unity.
- Main active workflow is base-pack optimization and QoL work, then redeploy into the live `PathofAchra.pck`.
- Prefer performance-only, UI-only, or quality-of-life changes unless gameplay/content changes are explicitly requested.

## Current Workflow

1. Edit recovered source in `PathofAchra_loader_recovered/`
2. Keep changes minimal and local
3. Preserve event order, trigger chains, summon order, and core mechanics
4. Compile changed scripts to `.gdc` when patching the shipped pack
5. Patch to a temporary `.pck` first, then replace the live `PathofAchra.pck` only after patch success
6. Smoke-test startup and the touched flow
7. Inspect the latest Godot log for real script or parse errors
8. Update docs/changelog in the repo when the change is stable
9. Publish a dated release tag when requested

## Critical Tooling Rules

- Do not run `gdre_tools.exe` blindly from the workspace root.
- `gdre_tools.exe` requires a sibling `gdre_tools.pck` in the same directory.
- If that companion `.pck` is missing, GDRE throws the popup error:
  - `Couldn't load project data at path ... Is the .pck file missing?`
- That error means the GDRE tool package is incomplete. It does **not** mean the game pack is broken.
- If the root GDRE tool is incomplete, download or extract a full GDRETools Windows package to a temporary folder such as `gdre_runtime/` and run the tool from there.
- Clean temporary GDRE download folders after patching.
- Use `build_gdre/` as the compiled `.gdc` staging folder.
- The live pack uses `.gdc` plus `.gd.remap` entries for core scripts. Patch `.gdc`, not raw `.gd`.
- In context-mode shell, `rg` may be unavailable. Prefer built-in `grep`/`read` tools or sandboxed JavaScript file scanning instead of assuming ripgrep exists.

## Safe PCK Patch Workflow

Preferred workflow for shipped-pack edits:

1. Verify a working GDRE runtime exists with both:
   - `gdre_tools.exe`
   - `gdre_tools.pck`
2. Compile changed scripts with GDRE using:
   - `--bytecode=3.5.0-stable`
3. Output compiled files into `build_gdre/`
4. Patch the live `PathofAchra.pck` into a temporary output file first
5. Replace `PathofAchra.pck` only after the temp patch succeeds
6. Keep `PathofAchra_original.pck` untouched as the rollback backup

Known patched script paths in the live pack include:

- `res://Scenes/Game.gdc`
- `res://ToolAstar.gdc`
- `res://ToolMagicMaker.gdc`
- `res://Tool_CalculateRange.gdc`

## Smoke-Test And Log Rules

- Short startup smoke test is enough for low-risk script-only changes.
- Latest logs are under:
  - `C:\Users\Admin\AppData\Roaming\Godot\app_userdata\PoA\logs\`
- Look for real failures such as:
  - `SCRIPT ERROR`
  - `Parse Error`
  - `Invalid call`
  - failed script loads
- If the test used a forced close, generic exit-time warnings can appear and are not automatically a regression.
- Common non-actionable forced-exit warnings seen in this workspace:
  - `ERROR: Condition "_first != nullptr" is true.`
  - `ERROR: Resources still in use at exit (run with --verbose for details).`
  - `ERROR: There are still MemoryPool allocs in use at exit!`

## Live Files And Paths

- Live pack: `PathofAchra.pck`
- Original backup: `PathofAchra_original.pck`
- Recovered source: `PathofAchra_loader_recovered/`
- Compiled script staging: `build_gdre/`
- Temporary GDRE runtime folder: `gdre_runtime/` when needed
- Repo/docs:
  - `README.md`
  - `CHANGELOG.md`
  - `loader/IntegrationNotes.md`
- User data:
  - `C:\Users\Admin\AppData\Roaming\Godot\app_userdata\PoA\settings.save`
  - `C:\Users\Admin\AppData\Roaming\Godot\app_userdata\PoA\mods-config.json`
  - `C:\Users\Admin\AppData\Roaming\Godot\app_userdata\PoA\graveyard.json`

## Main Findings So Far

- Main bottleneck is serialized main-thread combat/event-chain work.
- Low total CPU/GPU utilization is expected. One logic thread is the bottleneck.
- GPU or broad thread offload is not the practical fix for this pack.
- Character select lag was heavily tied to graveyard victory-marker scanning and cloning.
- Maqbara lag was heavily tied to large `graveyard.json` load/parse and too many rendered entries.
- Extreme combat lag cases come from chain reactions, large AoE scans, summon floods, queue growth, and visual effect floods.

## Completed Work

### Performance And UI

- Batched dungeon floor generation in `ToolGenerateLevel.gd`
- Added A* tile id lookup cache
- Added texture cache in `global.gd`
- Reduced repeated `get_node()` / `load()` calls in tile and continent scripts
- Lightened range-indicator work in `Scenes/Game.gd`
- Added `_process()` throttles and state-change-only updates in several scripts
- Fixed FPS label churn
- Reworked player deckbutton rebuilds in `Scenes/Game.gd` to avoid repeated full slow rebuild patterns
- Added cached player deck column reuse for unchanged deck state

### Graveyard / Maqbara

- Switched graveyard storage from `title_name` keying to unique record keys
- Kept backward-compatible loading for old records
- Raised graveyard cap from 100 to 500
- Added scrolling, visible-button pooling, and batched viewed-state writes
- Cached winning-title data for character select
- Stopped deep-cloning graveyard entries on open

### Combat / Runtime

- Dead units now stop `_process()` and leave active processing lists
- Cleaned stale active units in `ProcessQueue2`
- Range indicators clear only previously lit tiles
- Combat log batching improved to flush at safer points instead of mid-chain
- Added animated effect pooling
- Added floating text pooling
- Added pure area range cache per floor
- Moved delayed-event visual updates into centralized throttled updates
- Optimized `queue_effects` while preserving exact newest-first/LIFO behavior
- Optimized queue cleanup to one-pass filtering
- Reduced unseen/empty-tile visual effect flood
- Deferred heavy `update_game()` / room refreshes to safe flush points
- Optimized `ToolMagicMaker.gd` target picking to reduce array copying and full-list shuffle cost
- Optimized closest/furthest enemy helpers to compare unit residences directly
- Cached tileset table loads in `ToolMagicMaker.gd`
- Optimized `Tool_CalculateRange.gd` adjacent-border helpers to use `Tile_XY` adjacency instead of full tile scans
- Optimized walkable path helper to use direct id lookups from `ToolAstar.gd`
- Optimized line helper to step directly through tiles instead of nested tile scans
- Added `ToolAstar.gd` tile arrays for direct id-to-tile lookup reuse
- Added dirty partial room refreshes in `Scenes/Game.gd` so queued combat flushes can update changed tiles/units/UI state without always rebuilding the full room
- Marked movement, teleport, death, damage, heal, buff, summon, and terrain-change paths dirty so chained combat refreshes can stay local when safe

### Bug Fixes

- Fixed corpse effect visuals moving with player by tightening effect pooling exclusions/reset
- Fixed floating text lifetime so faster FPS does not make text vanish too quickly
- `global.gd` now prefers `res://ModLoader.gdc` before `.gd` for exported-pack loading safety

### Built-In Feature Toggles

Expose built-in toggles in the title-screen `Mods` tab, like Tame.

- `Toggle Tame mechanic`
  - default disabled
  - persisted in `user://mods-config.json`
- `Toggle Combat log processing`
  - default enabled
  - when off, skips most combat log accumulation/redraw work
  - hides/disables combat log UI while keeping hover descriptions working

## Tame Mechanic Notes

- Built-in action, hotkey `4`
- One use per map
- Click visible enemy to attempt conversion
- Chance uses player WIL versus enemy WIL, tier, boss/summoned state, HP, and distance
- Severe `tier_special = 99` chance bug already fixed
- Tame defaults to off

## Mod Folder Rule

- Keep the live local `mods/` folder empty when requested for the deployed game setup.
- Do not delete tracked example/showcase mods from the Git repo.
- If `git status` shows example mod deletions in this install snapshot, do not commit them accidentally.

## Existing Mod Content References

- These references are repo-oriented and may not be present in the live install snapshot if the local `mods/` folder has been cleared.
- Short guide: `README.md`
- Full schema: `ModSchema.md`
- Showcase prestige mod: `mods/reedbound_ascetic/`
- Showcase god and runtime mod: `mods/lantern_saint/`
- Showcase class, race, and item mod: `mods/causeway_warden/`
- Showcase enemy mod: `mods/fen_hunt/`
- Examples:
  - `mods/example_pitfighter/`
  - `mods/example_tempest_adept/`
  - `mods/example_wayfarer/`
  - `mods/example_content_pack/`
  - `mods/example_runtime_pack/`
  - `mods/example_enemy_pack/`

## Supported Top-Level Mod Sections

- `prestiges`
- `skills`
- `classes`
- `races`
- `gods`
- `weapons`
- `armor`
- `enemies`
- `invokes`
- `buffs`
- `allies`
- `trait_effects`
- `lore`

## Modding Style Notes

Example content should match the game's style.

Prefer:

- colored trigger keywords such as `[color=#ff8030]attack[/color]`
- generic prayer wording such as `[color=#78bca4]prayer[/color]`
- colored damage or element keywords such as `[color=#0060ff]Lightning[/color]`
- explicit numeric values when possible
- brief lore that reads like in-game text

Avoid:

- plain unformatted effect text where the base game uses colored keywords
- vague fixed-value descriptions
- strings that read like developer notes

## Custom Trait Logic

Use `trait_effects` when:

- a custom skill needs runtime behavior
- a custom non-prestige trait should react to triggers

This uses the same trigger / condition / action system as modded prestiges.

Top-level `buffs`, `allies`, `weapons`, `armor`, and `invokes` entries can also be referenced from `ref` objects inside queued effects.

## Selection And Spawn Notes

- `sprite` = in-game body or equipment layer
- `icon` = larger menu or inventory icon
- `icon_small` = compact race UI icon
- `proj_art` = projectile visual

World-map treasure rarity:

- `1` = normal world treasure
- `2` = void treasure
- `0` = excluded from continent treasure pools

Custom enemy spawn rules:

- `summoned: false` = normal enemy spawn pools
- `summoned: true` = excluded from normal enemy spawn pools
- `tier: 1+` = eligible for nemesis tab

Useful flags:

- `unlocked_by_default: true` to show content without unlock progression
- `enabled_by_default: false` in `mod.json` for template/example mods that should stay off

## When Base Pack Editing Is Needed

Use base-pack edits when you need to:

- add new trigger types
- add new condition types
- add new action helpers
- add deeper item generation or reward integration
- change core game behavior outside the current schema

Otherwise prefer normal external mods.

## Recent Release Trail

Published releases already include:

- `v2026.04.11`
- `v2026.04.12`
- `v2026.04.12.1`
- `v2026.04.12.2`
- `v2026.04.12.3`
- `v2026.04.12.4`
- `v2026.04.12.5`
- `v2026.04.13`
- `v2026.04.13.1`
- `v2026.04.13.2`

Latest documented repo state from the earlier session:

- commit `5730d66`
- release tag `v2026.04.13.1`

Latest local pack work after that state:

- shipped additional live-pack optimizations for deckbutton rebuilds and target/path helpers
- updated live `PathofAchra.pck` locally after compiling and patching new `.gdc` files
- shipped a second pass that adds dirty partial `update_game()` refreshes for chained combat instead of always doing full room/UI rebuilds on queued flushes

## Next Likely Targets

- More careful AoE visual flood compression
- More start-menu / build-menu caching if needed
- `Process_Queue2.gd` active-unit membership optimization if summon floods still spike
- lower-priority menu/UI churn such as `Scenes/Lines.gd` per-frame redraw if still relevant
