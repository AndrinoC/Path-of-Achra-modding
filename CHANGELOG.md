# Changelog

## v2026.04.13.1

- add a built-in `Toggle Combat log processing` feature to the Mods tab
- make combat-log disabling skip message accumulation and log redraw work instead of only hiding UI
- hide and disable the in-combat log buttons when combat log processing is off while keeping hover descriptions available
- keep release documentation aligned with the current shipped `PathofAchra.pck`

## v2026.04.13

- defer full room/UI refresh work during heavy effect-chain processing and flush it at safe points instead of after every single effect
- switch combat log visibility updates to a stronger turn-end/control-return batching path for heavy chain scenarios
- pool floating text popups and move popup lifetime to real-time delta-based timing so readability stays stable across framerates
- cache character-select victory marker data so opening the start menu does not rescan and clone the full graveyard every time
- keep release documentation aligned with the current shipped `PathofAchra.pck`

## v2026.04.12.5

- move delayed-event visuals off per-node `_process()` into a throttled central update path
- keep delayed-event execution order unchanged while reducing delayed-node visual polling cost
- optimize `queue_effects` handling without changing its existing newest-first execution order
- keep release documentation aligned with the current shipped `PathofAchra.pck`

## v2026.04.12.4

- batch combat-log UI refreshes instead of rebuilding on every single message append
- pool temporary animated combat effects to reduce node churn under large effect cascades
- cache pure area tile-range queries per floor to reduce repeated full-ground scans
- add a quiet `ModLoader.gdc` startup fallback for exported packs
- keep release documentation aligned with the current shipped `PathofAchra.pck`

## v2026.04.12.3

- expose `Tame` as a built-in Mods-tab feature toggle instead of a fixed always-on mechanic
- make `Tame` default to off until explicitly enabled
- keep the toggle visible even when no external mods are installed
- stabilize the shipped pack after the toggle rollout with a clean rebuilt `PathofAchra.pck`
- keep release documentation aligned with the current shipped pack behavior

## v2026.04.12.2

- stop dead units from wasting per-frame processing after death
- clean stale active-unit references before turn scheduling
- reduce range-indicator work by only clearing previously lit tiles
- throttle or cache several hot `_process()` UI and combat loops without changing game rules
- keep release documentation aligned with the shipped `PathofAchra.pck`

## v2026.04.12.1

- update Maqbara save keys so duplicate `title_name` heroes no longer overwrite each other
- keep Maqbara reads backward compatible with older `graveyard.json` entries
- raise the Maqbara record cap from `100` to `500`
- add mouse-wheel scrolling for large Maqbara record sets
- reduce Maqbara hitching by removing duplicate graveyard loads, batching viewed-state writes, and reusing visible button nodes

## v2026.04.12

- add a new once-per-map `Tame` action on hotkey `4`
- let `Tame` target visible enemies and convert them into allies on success
- tune tame chance from player `Willpower`, enemy `Willpower`, tier, boss status, summoned status, current health, and distance
- fix tame chance calculation to use normal enemy `tier` instead of the `tier_special = 99` placeholder field
- keep the current loader-enabled pack release docs in sync with the shipped `PathofAchra.pck`

## v2026.04.11

- keep the loader-enabled pack up to date with the current tested `PathofAchra.pck`
- speed up level generation by batching generation steps and caching A* tile lookup
- reduce repeated texture and node lookup overhead in tile, world-map, and UI hot paths
- simplify FPS label updates and fix its layout so the value stays on one line
- document the current release pack as both loader-enabled and performance-fixed

## v2026.04.09

- sync showcase mods and sprite support docs
