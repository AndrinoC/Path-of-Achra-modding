# Template Enemy Pack

Use this template when you want a custom enemy to appear in the normal world spawn pools and in the nemesis tab.

What it includes:

- a custom enemy: `TemplateBogRaider`

Important fields from the real game code:

- `summoned: false` means `LEnemies.get_enemies_of_tier()` and `get_enemies_for_dust()` can include it
- `tier: 1` means `Scenes/Bestiary.gd` can show it in the nemesis tab
- `boss: false` keeps it in the normal enemy pool instead of the boss pool

This template is disabled by default through `enabled_by_default: false`.
