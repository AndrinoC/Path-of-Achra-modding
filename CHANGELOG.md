# Changelog

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
