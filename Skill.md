# Path of Achra Modding Skill

## Current Workflow

Use the loader-based mod system.

Recommended workflow:

1. Create a folder in `mods/<mod_id>/`
2. Add `mod.json`
3. Add `content.json`
4. Add icons if needed
5. Enable the mod in the title-screen `Mods` menu
6. Restart the game if the menu says a restart is required

## Main Files

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

## Supported Top-Level Sections

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

## Description Style

Example content should match the game’s style.

Prefer:

- colored trigger keywords such as `[color=#ff8030]attack[/color]`
- generic prayer wording such as `[color=#78bca4]prayer[/color]` when an effect reacts to invocation use
- colored damage or element keywords such as `[color=#0060ff]Lightning[/color]`
- explicit values in descriptions when possible, such as `heal 15` or `10 Blunt damage`
- brief lore that reads like in-game text, not placeholder tool text

Avoid:

- plain unformatted text for effects when the base game uses colored keywords
- vague effect descriptions when the effect has a fixed numeric value
- example strings that read like developer notes instead of game text

## Custom Trait Logic

Use `trait_effects` when:

- a custom skill needs runtime behavior
- a custom non-prestige trait should react to triggers

This uses the same trigger / condition / action system as modded prestiges.

Top-level `buffs`, `allies`, `weapons`, `armor`, and `invokes` entries can also be referenced from `ref` objects inside queued effects.

## Selection Content

Custom classes, races, and gods can be exposed in character creation.

Custom item mods are best demonstrated through class starting gear.

Use:

- `mods/causeway_warden/` as a shipped showcase of class, race, skill, and starting gear working together
- `mods/example_content_pack/` as a second concrete example of a class using modded starting gear

For selection content and starting gear visuals:

- `sprite` is the in-game body or equipment layer
- `icon` is the larger menu or inventory icon
- `icon_small` is supported for compact race UI icons
- `proj_art` is supported for custom projectile visuals

Do not assume one image works for every surface. UI icons can be denser or more decorative than the in-game player-layer sprites.

For world-map treasure drops, item `rarity` follows the real continent generator:

- `1` = normal world treasure
- `2` = void treasure
- `0` = excluded from continent treasure pools

For custom enemies, the real spawn and nemesis rules are:

- `summoned: false` = included in normal enemy spawn pools
- `summoned: true` = excluded from normal enemy spawn pools
- `tier: 1+` = eligible for the nemesis tab

Use:

- `mods/fen_hunt/` as the shipped showcase of normal-tier and void-tier custom enemies
- `mods/example_enemy_pack/` as the lighter example pack

Use:

- `unlocked_by_default: true` inside the entry if you want it visible without unlock progression
- `enabled_by_default: false` in `mod.json` for template or example mods that should stay off until manually enabled

## When Base Pack Editing Is Needed

Use base-pack edits only when you need to:

- add new trigger types
- add new condition types
- add new action helpers
- add deeper item generation or reward integration
- change core game behavior outside the current schema

For everything else, prefer normal external mods.
