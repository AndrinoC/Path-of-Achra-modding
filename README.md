# Path of Achra Modding Guide

## What You Need

- `Path of Achra`
- the loader-enabled `PathofAchra.pck`
- a mod folder inside `mods/`

This guide is for the current loader-based setup.

For the full prestige schema reference, see `ModSchema.md`.

## Installing The Loader

If the loader is not already installed:

1. Back up the original game pack:

```powershell
Copy-Item '.\PathofAchra.pck' '.\PathofAchra_original_backup.pck'
```

2. Install the loader-enabled pack:

```powershell
Copy-Item '.\PathofAchra_ModLoader_quiet.pck' '.\PathofAchra.pck' -Force
```

That enables external mods from the `mods/` folder.

When the loader is installed, the title screen main menu will show a new `Mods` button above `Quit`.

Use that menu to:

- see detected mods
- enable or disable mods
- see when a restart is required

Mod enable or disable state is saved in a separate user config and applies after restarting the game.

## Installing A Mod

Drop a mod folder into:

```text
mods/<mod_id>/
```

Example:

```text
mods/pitfighter/
  mod.json
  content.json
  icons/
    PitFighter.png
```

Start the game. The loader scans `mods/` automatically.

You can then open the in-game `Mods` button to enable or disable the mod.

Changes take effect after restarting the game.

## Creating A Mod

Use the included template:

```text
mods/template_mod/
```

The included template is disabled by default.

Other disabled example mods are also included:

- `mods/example_pitfighter/`
- `mods/example_tempest_adept/`
- `mods/example_wayfarer/`
- `mods/example_content_pack/`

The examples are meant to read like game content:

- colored trigger and element keywords
- explicit values in descriptions when the effect uses fixed numbers
- short lore text instead of placeholder developer text

Recommended workflow:

1. Copy `mods/template_mod/` to a new folder name.
2. Rename the mod in `mod.json`.
3. Replace `TemplatePrestige` in `content.json` with your internal prestige key.
4. Edit the display name, description, lore, unlock rule, and effects.
5. Add your icon under `icons/`.
6. Launch the game and test.

## Mod File Layout

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

Set `enabled_by_default` to `false` if you want a template or example mod to stay off until the player enables it in the Mods menu.

## `content.json`

```json
{
  "prestiges": {
    "MyPrestige": {
      "trait": {
        "title": "MyPrestige",
        "Name": "[color=#70ff60]My Prestige[/color]",
        "Level": 1,
        "Description": "On [color=#ff8030]attack[/color]: ...",
        "Description_Unit": "Short alternate description.",
        "Element": "None",
        "sprite": "icons/MyPrestige.png",
        "base": 0,
        "cost": 1,
        "infpen": false,
        "generic": true,
        "reference": "none",
        "organize": "prestige",
        "levelable": false
      },
      "lore": {
        "title": "MyPrestige",
        "text": "Your lore text here."
      },
      "unlock": {
        "type": "always",
        "label": "[color=#70ff60]No requirement[/color] [color=#707070](test)[/color]"
      },
      "effects": []
    }
  }
}
```

The full unlock, trigger, condition, action, metric, and reference system is documented in `ModSchema.md`.

## Icons

Recommended:

1. make a clear `32x32` icon
2. place it in `icons/`
3. point `trait.sprite` at it

Example:

```json
"sprite": "icons/MyPrestige.png"
```

## Testing Tips

Start with:

```json
"unlock": {
  "type": "always",
  "label": "[color=#70ff60]No requirement[/color] [color=#707070](test)[/color]"
}
```

Once the prestige appears and works, switch to the real requirement.

If an icon is wrong in an old save, test in a new save first. Old saves can keep cached prestige data from earlier versions.

## When You Need Base Pack Editing

Most prestige mods should only need a mod folder.

You only need to edit and rebuild `PathofAchra.pck` if you want to:

- change the loader itself
- add new trigger types
- add new condition types
- add new action types
- change deeper core game systems

## Restore The Original Game

If you made a backup:

```powershell
Copy-Item '.\PathofAchra_original_backup.pck' '.\PathofAchra.pck' -Force
```
