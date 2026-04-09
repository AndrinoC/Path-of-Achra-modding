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
- Template: `mods/template_mod/`
- Runtime template: `mods/template_runtime_pack/`
- Class-and-gear template: `mods/template_items_pack/`
- Examples:
  - `mods/example_pitfighter/`
  - `mods/example_tempest_adept/`
  - `mods/example_wayfarer/`
  - `mods/example_content_pack/`
  - `mods/example_runtime_pack/`

## Supported Top-Level Sections

- `prestiges`
- `skills`
- `classes`
- `races`
- `gods`
- `weapons`
- `armor`
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

Custom item mods are best tested through class starting gear.

Use:

- `mods/template_items_pack/` to build a class that starts with your custom weapon and armor
- `mods/example_content_pack/` as the concrete example of a class using modded starting gear

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
