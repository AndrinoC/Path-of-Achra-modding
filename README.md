# Path of Achra Modding Guide

## What This Guide Covers

This guide explains how to mod `Path of Achra` by unpacking the game, editing data and scripts, adding images, rebuilding the pack, and installing your mod.

It is based on a working workflow tested directly against the Steam install.

## Game Facts

- Game executable pack: `PathofAchra.pck`
- Engine version: `Godot 3.5.2`
- Script bytecode version: `3.5.0-stable (a7aad78)`
- Tool used in this guide: `gdre_tools.exe`

## Folder Layout Used In This Guide

- Original game folder: `C:\Program Files (x86)\Steam\steamapps\common\Path of Achra`
- Recovered editable project: `achra_full\`
- Compiled script output: `mod_build\`

## Before You Start

You should have:

1. `gdre_tools.exe`
2. the game installed
3. permission to write inside the game folder

Recommended safety step:

```powershell
Copy-Item '.\PathofAchra.pck' '.\PathofAchra_original_backup.pck'
```

That gives you a clean backup to restore later.

## Step 1: Recover The Game Project

Recover the full Godot project from the shipped `.pck`:

```powershell
.\gdre_tools.exe --headless --recover=".\PathofAchra.pck" --output=".\achra_full" --quit
```

This gives you editable files such as:

- `.gd` scripts
- `.json` data files
- `.png` images
- `project.godot`

Important:

- edit files inside `achra_full\`
- do not edit the original `.pck` directly

## Step 2: Understand The Main Modding Files

These are the main files used when adding or changing traits, prestiges, and icons.

### Data

- `achra_full\Data\Table_TraitsGeneric.json`
  - generic traits, prestige classes, item traits, racial traits, etc.
- `achra_full\Data\Table_Lore.json`
  - lore text shown for traits and prestiges
- `achra_full\Data\Table_Traits.json`
  - normal learnable skills and powers

### Prestige Logic

- `achra_full\ToolPrestigeGiver.gd`
  - decides which prestiges are available
  - provides the requirement text shown in the prestige UI

### Runtime Behavior Hooks

- `achra_full\RouterEvents_OnAttack.gd`
  - use for `On attack`
- `achra_full\RouterEvents_OnHit.gd`
  - use for `On hit`
- `achra_full\RouterEvents_OnBlock.gd`
  - use for `On block`
- `achra_full\RouterEvents_OnDamage.gd`
  - use for `On dealing damage`
- `achra_full\Scenes\Player.gd`
  - use for passive stat or player-level behavior changes

### UI / Icon Loading

- `achra_full\Scenes\Button_Traits_UI.gd`
- `achra_full\Scenes\UI_Prestige.gd`
- `achra_full\Scenes\UI_Traits_Basic.gd`

These matter if you use custom icons.

## Step 3: Decide What Kind Of Mod You Are Making

Common examples:

1. edit existing numbers in JSON
2. add a new prestige
3. add a new icon
4. change how an effect works in combat

If you are new, start with JSON edits first. They are easier than script changes.

## Step 4: Add A New Prestige Class

Open:

- `achra_full\Data\Table_TraitsGeneric.json`

Add a new prestige entry.

### Required Structure

```json
"MyPrestige": {
  "title": "MyPrestige",
  "Name": "[color=#70ff60]My Prestige[/color]",
  "Level": 1,
  "Description": "On [color=#ff8030]attack[/color]: ...",
  "Description_Unit": "Short alternate description",
  "Element": "None",
  "sprite": "res://Ham_Sprite/TraitIcons/MyPrestige.png",
  "base": 0,
  "cost": 1,
  "infpen": false,
  "generic": true,
  "reference": "none",
  "organize": "prestige",
  "levelable": false
}
```

### What The Fields Mean

- `MyPrestige`
  - the internal JSON key
- `title`
  - the internal runtime key
- `Name`
  - the player-facing styled display name
- `Description`
  - the full in-game description
- `Description_Unit`
  - short alternate description used by the game
- `sprite`
  - icon path inside the Godot project
- `generic: true`
  - prestige traits are generic traits, not standard learned skills
- `organize: "prestige"`
  - tells the game this is a prestige class

### Naming Rule

The internal key must match everywhere.

Example:

- JSON key: `PitFighter`
- `title`: `PitFighter`
- script checks: `attacker_traits.has("PitFighter")`

The display `Name` can be different, such as `Pit-Fighter`.

## Step 5: Add Prestige Lore

Open:

- `achra_full\Data\Table_Lore.json`

Add a matching lore entry:

```json
"MyPrestige": {
  "title": "MyPrestige",
  "text": "Your lore text here"
}
```

The lore key and `title` should match your prestige internal key.

## Step 6: Make The Prestige Unlock In Game

Open:

- `achra_full\ToolPrestigeGiver.gd`

You usually need to change three things.

### 6.1 Add It To `look_for_prestige(traits)`

This function decides which prestiges appear in the prestige screen.

Example: unconditional test unlock

```gdscript
available_prestiges.append(cloner.clone_dict(LTraitsGeneric.trait_data.MyPrestige))
```

Example: element-based requirement

```gdscript
if blood_total + life_total >= cost_standard:
    if Global.Player.ELEMENTS.has("Life") and Global.Player.ELEMENTS.has("Blood"):
        added_prestige = cloner.clone_dict(LTraitsGeneric.trait_data.MyPrestige)
        available_prestiges.append(added_prestige)
```

Example: skill-based requirement

First, count the relevant skills by matching their internal trait keys:

```gdscript
"Murmillo":
    guard_count += increase
"RapidStrikes":
    pugilism_count += increase
```

Then unlock the prestige when the threshold is met:

```gdscript
if guard_count + pugilism_count >= 20:
    added_prestige = cloner.clone_dict(LTraitsGeneric.trait_data.MyPrestige)
    available_prestiges.append(added_prestige)
```

### 6.2 Add It To `trans_prestige_to_string(trait)`

Add a case like this:

```gdscript
"MyPrestige":
    stringa = "MyPrestige"
```

### 6.3 Add Requirement Text In `trans_prestige_to_requirement_text(trait)`

Example:

```gdscript
"MyPrestige":
    stringa += "20 points between [color=#af8f50]Guard[/color] and [color=#af8f50]Pugilism[/color]"
```

For testing with no requirement:

```gdscript
"MyPrestige":
    stringa += "[color=#70ff60]No requirement[/color] [color=#707070](test)[/color]"
```

## Step 7: Add The Actual Effect

Pick the file based on when the effect should happen.

### Use `RouterEvents_OnAttack.gd` For

- `On attack`
- follow-up attacks
- chained attack behavior

### Use `RouterEvents_OnHit.gd` For

- `On hit`
- effects that should only happen after a hit actually lands

### Use `RouterEvents_OnBlock.gd` For

- `On block`
- counterattacks
- retaliation behavior

### Use `RouterEvents_OnDamage.gd` For

- `On dealing damage`
- damage conversion or bonus damage logic

## Step 8: Prefer Existing Combat Helpers

The most useful helper for attack-like prestige effects is:

```gdscript
ToolMagicMaker.add_attack(attacker, tile_start, target.residence, tile_range, target, weapon, msg)
```

Why this is good:

1. it uses the normal combat pipeline
2. it plays the usual attack animation flow
3. it makes extra attacks visible and readable
4. it behaves more like vanilla content

### Example: Extra Attacks On Attack

```gdscript
if attacker_traits.has("MyPrestige"):
    if translate.is_bare_fist(weapon):
        for _n in 2:
            ToolMagicMaker.add_attack(attacker, tile_start, tile_end, tile_range, enemy, weapon, attacker_traits.MyPrestige.Name)
```

### Example: Counterattack On Block

```gdscript
if defender_traits.has("MyPrestige") == true:
    if translate.is_bare_fist(defender.weapon_main):
        if calcrange.tile_is_in_range(attacker.residence, defender.residence, 1) == true:
            var msg = defender_traits.MyPrestige.Name
            ToolMagicMaker.add_attack(defender, defender.residence, attacker.residence, defender.get_range_attack(defender.weapon_main), attacker, defender.weapon_main, msg)
```

### Important Recursion Note

Extra attacks should usually not count as initial attacks.

This game commonly uses `msg == "Initial"` to distinguish the first attack from follow-up attacks. If your effect should not recursively retrigger itself, use a custom message string instead of `Initial`.

## Step 9: Add A Custom Icon

Place your final icon at:

- `achra_full\Ham_Sprite\TraitIcons\MyPrestige.png`

Set the JSON sprite path to:

```json
"sprite": "res://Ham_Sprite/TraitIcons/MyPrestige.png"
```

### Recommended Icon Workflow

1. create the source image at high resolution
2. crop it tightly
3. scale it down to `32x32`
4. keep the silhouette readable
5. save the final version into `Ham_Sprite\TraitIcons\`

### Very Important Godot Export Pitfall

Godot 3 exported games often expect imported texture metadata such as:

- `.import`
- `.stex`

If you only drop in a raw custom PNG, `load(trait.sprite)` may fail.

### Fix Already Present In This Setup

These UI files now have a fallback loader:

- `Scenes\Button_Traits_UI.gd`
- `Scenes\UI_Prestige.gd`
- `Scenes\UI_Traits_Basic.gd`

Their logic is:

1. try `load(path)`
2. if that fails, use `Image.load(path)` and create an `ImageTexture`

That means custom prestige PNGs can still appear even without imported Godot texture metadata.

### One More UI Detail

`UI_Prestige.gd` also embeds the icon in RichText with `[img]...[/img]`.

That embed only works if direct `load(path)` succeeds, so the guide workflow now skips embedding the `[img]` preview when the texture is only available through the raw-image fallback.

## Step 10: Compile Changed Scripts

After editing `.gd` files, compile them back into `.gdc`:

```powershell
.\gdre_tools.exe --headless --compile=".\achra_full\ToolPrestigeGiver.gd" --compile=".\achra_full\RouterEvents_OnAttack.gd" --compile=".\achra_full\RouterEvents_OnBlock.gd" --bytecode="3.5.0-stable" --output=".\mod_build"
```

Add every changed script file to the command.

If you changed UI files, compile those too.

Example:

```powershell
.\gdre_tools.exe --headless --compile=".\achra_full\Scenes\UI_Prestige.gd" --bytecode="3.5.0-stable" --output=".\mod_build"
```

## Step 11: Patch The Game Pack

Patch the changed files into a new `.pck`:

```powershell
.\gdre_tools.exe --headless --pck-patch=".\PathofAchra.pck" --patch-file=".\mod_build\ToolPrestigeGiver.gdc=res://ToolPrestigeGiver.gdc" --patch-file=".\mod_build\RouterEvents_OnAttack.gdc=res://RouterEvents_OnAttack.gdc" --patch-file=".\mod_build\RouterEvents_OnBlock.gdc=res://RouterEvents_OnBlock.gdc" --patch-file=".\achra_full\Data\Table_TraitsGeneric.json=res://Data/Table_TraitsGeneric.json" --patch-file=".\achra_full\Data\Table_Lore.json=res://Data/Table_Lore.json" --patch-file=".\achra_full\Ham_Sprite\TraitIcons\MyPrestige.png=res://Ham_Sprite/TraitIcons/MyPrestige.png" --output=".\PathofAchra_MyPrestige.pck"
```

Add any changed UI `.gdc` files too if needed.

## Step 12: Install The Modded Pack

Install your new pack over the game pack:

```powershell
Copy-Item '.\PathofAchra_MyPrestige.pck' '.\PathofAchra.pck' -Force
```

If you made a backup earlier, you can always restore it.

## Step 13: Verify Your Mod

Check that the live pack contains the files you changed:

```powershell
.\gdre_tools.exe --headless --list-files=".\PathofAchra.pck" --quit | Select-String -Pattern 'MyPrestige|MyPrestige.png|ToolPrestigeGiver.gdc|RouterEvents_OnAttack.gdc'
```

You can also recover the installed JSON back out of the live pack to confirm your final trait data:

```powershell
.\gdre_tools.exe --headless --recover=".\PathofAchra.pck" --include="res://Data/Table_TraitsGeneric.json" --output=".\verify_mod" --quit
```

If you want to verify script compilation, decompile the new `.gdc` files:

```powershell
.\gdre_tools.exe --headless --decompile=".\mod_build\ToolPrestigeGiver.gdc" --bytecode="3.5.0-stable" --output=".\decompile_check"
```

## Step 14: Good Modding Habits

1. start by making the prestige unconditional for testing
2. confirm the UI, icon, and behavior all work
3. only then add the real requirement
4. reuse vanilla patterns whenever possible
5. prefer small local edits over broad rewrites
6. keep your internal key stable once the prestige works

## Example: Final Working Prestige From This Workflow

This workflow ended with a working prestige:

- internal key: `PitFighter`
- display name: `Pit-Fighter`
- requirement: `20 points between Guard and Pugilism`
- behavior:
  - on attack with bare fists: `2 extra attacks`
  - on block with bare fists: `1 counterattack`
- icon path:
  - `res://Ham_Sprite/TraitIcons/PitFighter.png`

## Restoring The Original Game Pack

If something goes wrong and you made a backup:

```powershell
Copy-Item '.\PathofAchra_original_backup.pck' '.\PathofAchra.pck' -Force
```

## Short Version

If you only want the shortest workflow:

1. recover the project
2. add prestige JSON
3. add lore JSON
4. add unlock logic in `ToolPrestigeGiver.gd`
5. add runtime behavior in the right router script
6. add a `32x32` icon
7. compile changed scripts
8. patch the pack
9. install and test
