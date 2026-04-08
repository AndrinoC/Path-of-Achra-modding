# Template Mod

1. Rename the folder.
2. Edit `mod.json`.
3. Edit `content.json`.
4. Add your icon to `icons/`.
5. Replace `TemplatePrestige` everywhere with your own internal key.

See `ModSchema.md` for the full unlock, trigger, condition, action, and reference format.

This template is disabled by default through `enabled_by_default: false`.

Other example mods are available in the `mods/` folder if you want working samples.

Recommended icon path in `content.json`:

`icons/YourPrestige.png`

Recommended test unlock:

`"type": "always"`

Switch to a real requirement after the prestige appears and works in-game.
