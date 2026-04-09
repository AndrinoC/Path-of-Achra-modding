# Template Runtime Pack

Use this template if you want one mod folder that exposes all three runtime content types together:

- a custom invoke
- a custom buff
- a custom ally or summon

What to rename first:

- `TemplatePrayerBond`
- `TemplatePatron`
- `TemplateCall`
- `TemplateWard`
- `TemplateServitor`

How it works:

1. `TemplatePatron` gives the player `TemplatePrayerBond`
2. `TemplateCall` appears as the god's first invoke
3. `trait_effects` listens for the generic `on_invoke` trigger
4. the effect applies `TemplateWard`, summons `TemplateServitor`, and heals the player

This template is disabled by default through `enabled_by_default: false`.

It also shows how to reference top-level table entries inside queued effects:

- `buffs.TemplateWard`
- `allies.TemplateServitor`
