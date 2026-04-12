# Changelog

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
