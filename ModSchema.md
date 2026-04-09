# Path of Achra Mod Schema

This file documents the current external prestige mod schema used by the loader.

## Mod Structure

```text
mods/my_mod/
  mod.json
  content.json
  icons/
    MyPrestige.png
```

## `mod.json`

```json
{
  "id": "my_mod",
  "name": "My Mod",
  "version": "1.0.0",
  "author": "YourName",
  "enabled_by_default": true,
  "load_order": 100
}
```

### `enabled_by_default`

- `true`: the mod is active unless the player disables it
- `false`: the mod starts disabled until the player enables it in the Mods menu

This is useful for templates and example mods.

## `content.json` Shape

```json
{
  "skills": { ... },
  "prestiges": {
    "MyPrestige": {
      "trait": { ... },
      "lore": { ... },
      "unlock": { ... },
      "effects": [ ... ]
    }
  },
  "classes": { ... },
  "races": { ... },
  "gods": { ... },
  "weapons": { ... },
  "armor": { ... },
  "invokes": { ... },
  "buffs": { ... },
  "allies": { ... },
  "trait_effects": { ... },
  "lore": { ... }
}
```

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

`prestiges` use the wrapped format with `trait`, `lore`, `unlock`, and `effects`.

The other content tables use direct table entries.

`trait_effects` lets custom non-prestige traits, such as modded skills, use the same trigger and action system as modded prestiges.

## Trait Section

Required fields:

- `title`
- `Name`
- `Level`
- `Description`
- `Description_Unit`
- `Element`
- `sprite`
- `base`
- `cost`
- `infpen`
- `generic`
- `reference`
- `organize`
- `levelable`

For prestiges:

- `generic` should be `true`
- `organize` should be `prestige`
- `levelable` should be `false`

## Unlock Rules

Unlock rules are defined in `unlock`.

### Supported Unlock Types

- `always`
- `all`
- `any`
- `not`
- `skill_sum`
- `metric_gte`
- `metric_sum_gte`
- `element_presence_all`
- `element_presence_any`
- `player_level_gte`
- `elements_empty`
- `land_is`
- `item_match`
- `compare`

### `skill_sum`

Adds the `cost * level` values for the listed skill keys.

```json
{
  "type": "skill_sum",
  "skills": ["Murmillo", "RapidStrikes"],
  "threshold": 20,
  "label": "20 points between [color=#af8f50]Guard[/color] and [color=#af8f50]Pugilism[/color]"
}
```

### `metric_gte`

Checks a computed metric against a threshold.

### `metric_sum_gte`

Adds several computed metrics together.

### `item_match`

Checks one equipped item slot.

Slots:

- `weapon_main`
- `weapon_off`
- `armor_head`
- `armor_chest`
- `armor_hands`
- `armor_legs`

Operators:

- `eq`
- `neq`
- `gt`
- `gte`
- `lt`
- `lte`
- `contains`

## Computed Metrics

- `all_total`
- `body_total`
- `martial_total`
- `fire_total`
- `life_total`
- `lightning_total`
- `astral_total`
- `psychic_total`
- `poison_total`
- `death_total`
- `blood_total`
- `ice_total`
- `form_total`
- `ooze_total`
- `necro_total`
- `gallus_total`
- `starjumper_total`
- `strijela_total`
- `nochti_total`
- `lit_total`
- `master_total`
- `self_damage_total`
- `self_damage`
- `chant_total`
- `staff_count`
- `beast_total`
- `mindfight_total`
- `gorecleave_total`
- `elementalist_total`
- `player_level`

## Supported Triggers

- `on_attack`
- `on_block`
- `on_hit`
- `on_damage`
- `on_receive_damage`
- `on_heal`
- `on_receive_heal`
- `on_move`
- `on_wait`
- `on_dodge`
- `on_death`
- `on_kill`
- `on_apply_buff_target`
- `on_apply_buff_source`
- `on_remove_buff`
- `on_apply_bonus_target`
- `on_apply_bonus_source`
- `on_level_up`
- `on_intervention`
- `on_spawned`
- `on_shrug_off`
- `on_turn`
- `on_teleport`
- `on_enter_level`
- `on_pickup`
- `on_invoke`
- `on_learn`
- `on_summon`

## Conditions

Conditions can be written as string shorthands, condition objects, or nested `all` / `any` / `not` rules.

### Supported String Conditions

- `mainhand_bare_fist`
- `melee_range_1`

### Supported Condition Types

- `all`
- `any`
- `not`
- `trait_has`
- `trait_lacks`
- `buff_has`
- `buff_lacks`
- `element_has`
- `element_lacks`
- `weapon_bare_fist`
- `melee_range`
- `is_player`
- `is_dead`
- `object_type_is`
- `compare`

## Actions

### Supported Action Types

- `extra_attack_same_target`
- `counterattack_attacker`
- `queue_effect`
- `queue_effects`
- `add_message`

### Queue Effect Action Names

The following queue action names are currently available through `queue_effect` because they already exist in the game effect queue:

- `add_message`
- `level_up`
- `display_generic`
- `display_item`
- `display_intro`
- `display_land_intro`
- `create_effect`
- `attack_extra`
- `apply_bonus`
- `apply_bonus_random_ally`
- `apply_bonus_ally_random_of_tag`
- `add_buff`
- `buff_tiles_in_range`
- `buff_targets_in_range`
- `remove_random_buff`
- `remove_buff`
- `reduce_buff`
- `magic_damage_targets_range`
- `attack_targets`
- `hit_targets_range`
- `hit_target`
- `magic_damage_tiles_in_range`
- `magic_damage_tiles_in_area`
- `magic_damage_tiles_in_line`
- `magic_damage_tiles_in_path`
- `magic_damage_tiles_in_path_to_targets_in_range`
- `magic_damage_tiles_in_path_to_furthest`
- `delayed_magic_damage_tiles_in_range`
- `delayed_magic_damage_tiles_in_path_to_targets_in_range`
- `delayed_damage_target`
- `magic_damage_target`
- `magic_damage_target_closest`
- `magic_damage_target_furthest`
- `summon`
- `summon_random`
- `heal`
- `heal_allies_in_range`
- `heal_allied_targets_in_range`
- `teleport`
- `teleport_random`
- `change_tileset_in_area`
- `change_tileset_in_path`
- `delayed_damage_tile`

## Reference Resolution

Action and condition values can reference runtime context with `@` strings or `ref` objects.

Examples:

- `"@attacker"`
- `"@defender"`
- `"@weapon"`
- `"@tile_start"`
- `"@tile_end"`
- `"@healer_unit"`
- `"@healed_unit"`
- `"@summoner"`
- `"@msg"`
- `"@attacker.weapon_main"`
- `"@buff.target"`
- `"@player.level"`
- `"@attacker.speed"`

Numeric reference objects support:

- `mult`
- `div`
- `add`
- `sub`
- `min`
- `max`
- `round`

Supported `round` values:

- `int`
- `floor`
- `ceil`

### Supported Reference Roots

- `player`
- `land`
- `buffs`
- `allies`
- `weapons`
- `armor`
- `invokes`

### Dictionary Reference Overrides

If a `ref` resolves to a dictionary, you can override or add fields in the same object.

```json
{
  "name": "add_buff",
  "buff": {
    "ref": "buffs.MyCustomBuff",
    "target": "@unit",
    "source": "@unit",
    "duration": 4
  }
}
```

This is useful for custom buffs and summoned allies, since you can reuse the top-level table entry and only set the runtime fields you need.
