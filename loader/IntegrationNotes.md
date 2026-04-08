# Loader Integration Notes

`ModLoader.gd` is the main runtime loader, but it is not enough by itself.

To integrate it into the base game, the shipped game scripts also need small bridge changes.

## Base Game Integration Points

These are the files changed in the tested setup:

- `global.gd`
  - create the loader node at startup
  - expose wrapper methods such as `merge_loaded_data()` and `load_mod_texture()`
- `ToolLoaderJson.gd`
  - merge external prestige and lore data after loading JSON
- `ToolPrestigeGiver.gd`
  - append external prestige entries
  - show external requirement labels
- `RouterEvents_OnAttack.gd`
  - dispatch `on_attack` prestige triggers to the loader
- `RouterEvents_OnBlock.gd`
  - dispatch `on_block` prestige triggers to the loader
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

## Current Supported Schema

Unlock types:

- `always`
- `skill_sum`

Triggers:

- `on_attack`
- `on_block`

Conditions:

- `mainhand_bare_fist`
- `melee_range_1`

Actions:

- `extra_attack_same_target`
- `counterattack_attacker`

## Scope

This loader is intended to support lightweight prestige mods with:

- external prestige data
- external lore
- external icons
- simple built-in combat behaviors

If you want new trigger types, new conditions, or new action types, you will need to extend the base loader and rebuild the base pack.
