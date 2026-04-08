extends Node

const CONFIG_FILE = "user://mods-config.json"


var mods = []
var mods_all = []
var prestige_defs = []
var prestige_by_title = {}
var lore_entries = {}
var icon_aliases = {}
var mod_config = {}


func _enter_tree():
	load_mods()


func load_mods():
	load_mod_config()
	mods = []
	mods_all = []
	prestige_defs = []
	prestige_by_title = {}
	lore_entries = {}
	icon_aliases = {}

	var mods_root = get_mods_root_path()
	ensure_mods_folder(mods_root)

	var dir = Directory.new()
	if dir.open(mods_root) != OK:
		return

	dir.list_dir_begin(true, true)
	var entry_name = dir.get_next()
	while entry_name != "":
		var entry_path = mods_root.plus_file(entry_name)
		var mod = null
		if dir.current_is_dir():
			mod = load_folder_mod(entry_name, entry_path)
		elif entry_name.get_extension().to_lower() == "pck":
			mod = load_pck_mod(entry_name, entry_path)

		if mod != null:
			mods_all.append(mod)
			if mod.enabled == true:
				mod.loaded_now = true
				mods.append(mod)

		entry_name = dir.get_next()
	dir.list_dir_end()

	mods.sort_custom(self, "sort_mods")
	mods_all.sort_custom(self, "sort_mods")
	rebuild_indexes()


func ensure_mods_folder(mods_root):
	var dir = Directory.new()
	if dir.dir_exists(mods_root):
		return

	var game_root = OS.get_executable_path().get_base_dir()
	if dir.open(game_root) == OK:
		dir.make_dir("mods")


func get_mods_root_path():
	return OS.get_executable_path().get_base_dir().plus_file("mods")


func load_folder_mod(folder_name, folder_path):
	var base_path = "res://mods/" + folder_name
	var manifest_path = folder_path.plus_file("mod.json")
	var content_path = folder_path.plus_file("content.json")
	return load_mod_definition(folder_name, manifest_path, content_path, base_path, folder_path)


func load_pck_mod(file_name, pck_path):
	if ProjectSettings.load_resource_pack(pck_path, false) == false:
		return null

	var folder_name = file_name.get_basename()
	var base_path = "res://mods/" + folder_name
	var manifest_path = base_path + "/mod.json"
	var content_path = base_path + "/content.json"
	return load_mod_definition(folder_name, manifest_path, content_path, base_path, "")


func load_mod_definition(folder_name, manifest_path, content_path, base_path, filesystem_root):
	var manifest = load_json_file(manifest_path)
	var content = load_json_file(content_path)

	if typeof(manifest) != TYPE_DICTIONARY:
		return null
	if typeof(content) != TYPE_DICTIONARY:
		return null

	return {
		"id": str(manifest.get("id", folder_name)),
		"folder_name": folder_name,
		"name": str(manifest.get("name", folder_name)),
		"version": str(manifest.get("version", "0.0.0")),
		"load_order": int(manifest.get("load_order", 100)),
		"base_path": base_path,
		"filesystem_root": filesystem_root,
		"enabled": is_mod_enabled(str(manifest.get("id", folder_name))),
		"loaded_now": false,
		"content": content,
	}


func rebuild_indexes():
	prestige_defs = []
	prestige_by_title = {}
	lore_entries = {}

	for mod in mods:
		var mod_prestiges = mod.content.get("prestiges", {})
		if typeof(mod_prestiges) != TYPE_DICTIONARY:
			continue

		for key in mod_prestiges:
			var prestige_def = normalize_prestige_definition(mod, key, mod_prestiges[key])
			if prestige_def != null:
				set_prestige_definition(prestige_def)


func normalize_prestige_definition(mod, title, definition):
	if typeof(definition) != TYPE_DICTIONARY:
		return null
	if definition.has("trait") == false:
		return null
	if typeof(definition.trait) != TYPE_DICTIONARY:
		return null

	var trait = definition.trait.duplicate(true)
	if trait.has("title") == false:
		trait["title"] = title

	if trait.has("sprite"):
		var sprite_path = str(trait.sprite)
		if sprite_path.find("://") == -1:
			if sprite_path.begins_with("/"):
				sprite_path = sprite_path.substr(1, sprite_path.length() - 1)
			trait["sprite"] = mod.base_path + "/" + sprite_path
			if str(mod.filesystem_root) != "":
				icon_aliases["res://Ham_Sprite/TraitIcons/" + sprite_path.get_file()] = mod.filesystem_root.plus_file(sprite_path)

	var lore = definition.get("lore", null)
	if typeof(lore) == TYPE_DICTIONARY:
		lore = lore.duplicate(true)
		if lore.has("title") == false:
			lore["title"] = trait.title

	return {
		"title": str(trait.title),
		"trait": trait,
		"unlock": definition.get("unlock", {}),
		"effects": definition.get("effects", []),
		"lore": lore,
	}


func set_prestige_definition(prestige_def):
	var title = prestige_def.title
	for n in prestige_defs.size():
		if prestige_defs[n].title == title:
			prestige_defs[n] = prestige_def
			prestige_by_title[title] = prestige_def
			if typeof(prestige_def.lore) == TYPE_DICTIONARY:
				lore_entries[title] = prestige_def.lore
			return

	prestige_defs.append(prestige_def)
	prestige_by_title[title] = prestige_def
	if typeof(prestige_def.lore) == TYPE_DICTIONARY:
		lore_entries[title] = prestige_def.lore


func sort_mods(a, b):
	return int(a.load_order) < int(b.load_order)


func load_mod_config():
	mod_config = {
		"enabled": {}
	}

	var file = File.new()
	if file.file_exists(CONFIG_FILE) == false:
		save_mod_config()
		return

	if file.open(CONFIG_FILE, File.READ) != OK:
		return

	var parsed = JSON.parse(file.get_as_text())
	file.close()
	if parsed.error != OK:
		return
	if typeof(parsed.result) != TYPE_DICTIONARY:
		return

	mod_config = parsed.result
	if mod_config.has("enabled") == false:
		mod_config["enabled"] = {}


func save_mod_config():
	var file = File.new()
	if file.open(CONFIG_FILE, File.WRITE) != OK:
		return
	file.store_string(to_json(mod_config))
	file.close()


func is_mod_enabled(mod_id):
	if mod_config.has("enabled") == false:
		if mod_id == "template_mod":
			return false
		return true
	if typeof(mod_config.enabled) != TYPE_DICTIONARY:
		if mod_id == "template_mod":
			return false
		return true
	if mod_config.enabled.has(mod_id) == false:
		if mod_id == "template_mod":
			return false
		return true
	return bool(mod_config.enabled[mod_id])


func set_mod_enabled(mod_id, enabled):
	if mod_config.has("enabled") == false or typeof(mod_config.enabled) != TYPE_DICTIONARY:
		mod_config["enabled"] = {}

	mod_config.enabled[mod_id] = enabled
	save_mod_config()

	for mod in mods_all:
		if mod.id == mod_id:
			mod.enabled = enabled
			break


func get_mod_info_list():
	var list = []
	for mod in mods_all:
		list.append({
			"id": mod.id,
			"name": mod.name,
			"version": mod.version,
			"load_order": mod.load_order,
			"enabled": mod.enabled,
			"loaded_now": mod.loaded_now,
			"folder_name": mod.folder_name,
		})
	return list


func has_restart_pending():
	for mod in mods_all:
		if mod.enabled != mod.loaded_now:
			return true
	return false


func load_json_file(path):
	var file = File.new()
	if file.file_exists(path) == false:
		return null
	if file.open(path, File.READ) != OK:
		return null

	var parsed = JSON.parse(file.get_as_text())
	file.close()
	if parsed.error != OK:
		return null

	return parsed.result


func merge_loaded_data(path, loaded_data):
	if typeof(loaded_data) != TYPE_DICTIONARY:
		return loaded_data

	match path.to_lower():
		"res://data/table_traitsgeneric.json":
			for prestige_def in prestige_defs:
				loaded_data[prestige_def.title] = prestige_def.trait.duplicate(true)
		"res://data/table_lore.json":
			for title in lore_entries:
				loaded_data[title] = lore_entries[title].duplicate(true)

	return loaded_data


func has_prestige(title):
	return prestige_by_title.has(title)


func append_available_prestiges(available_prestiges, traits):
	var known_titles = {}
	for trait in available_prestiges:
		known_titles[trait.title] = true

	for prestige_def in prestige_defs:
		if known_titles.has(prestige_def.title):
			continue
		if unlock_is_met(prestige_def, traits) == false:
			continue

		if LTraitsGeneric.trait_data.has(prestige_def.title):
			available_prestiges.append(cloner.clone_dict(LTraitsGeneric.trait_data[prestige_def.title]))
		else:
			available_prestiges.append(cloner.clone_dict(prestige_def.trait))
		known_titles[prestige_def.title] = true


func get_prestige_requirement_text(trait):
	if has_prestige(trait.title) == false:
		return ""

	var unlock = prestige_by_title[trait.title].get("unlock", {})
	if typeof(unlock) == TYPE_DICTIONARY:
		if unlock.has("label"):
			return "[color=#a0a0a0]Requires " + str(unlock.label)

	return "[color=#a0a0a0]Requires [color=#70ff60]Modded prestige[/color]"


func unlock_is_met(prestige_def, traits):
	var unlock = prestige_def.get("unlock", {})
	if typeof(unlock) != TYPE_DICTIONARY:
		return true
	if unlock.empty():
		return true

	match str(unlock.get("type", "always")):
		"always":
			return true
		"skill_sum":
			return skill_sum_is_met(unlock, traits)

	return false


func skill_sum_is_met(unlock, traits):
	var skills = unlock.get("skills", [])
	if typeof(skills) != TYPE_ARRAY:
		return false

	var total = 0
	for key in traits:
		var trait = traits[key]
		if skills.has(trait.title):
			total += int(trait.cost) * int(trait.Level)

	return total >= int(unlock.get("threshold", 0))


func apply_prestige_trigger(trigger, context):
	var trigger_unit = null
	match trigger:
		"on_attack":
			trigger_unit = context.get("attacker", null)
		"on_block":
			trigger_unit = context.get("defender", null)

	if trigger_unit == null:
		return

	var trigger_traits = trigger_unit.get_traits()
	for prestige_def in prestige_defs:
		if trigger_traits.has(prestige_def.title) == false:
			continue

		var effects = prestige_def.get("effects", [])
		if typeof(effects) != TYPE_ARRAY:
			continue

		for effect in effects:
			if typeof(effect) != TYPE_DICTIONARY:
				continue
			if str(effect.get("trigger", "")) != trigger:
				continue
			if conditions_are_met(effect.get("conditions", []), context, trigger_unit) == false:
				continue

			execute_effect(effect, context, trigger_traits[prestige_def.title].Name)


func conditions_are_met(conditions, context, trigger_unit):
	if typeof(conditions) != TYPE_ARRAY:
		return true

	for condition in conditions:
		if condition_is_met(str(condition), context, trigger_unit) == false:
			return false

	return true


func condition_is_met(condition, context, trigger_unit):
	match condition:
		"mainhand_bare_fist":
			if trigger_unit == null:
				return false
			return translate.is_bare_fist(trigger_unit.weapon_main)
		"melee_range_1":
			if context.has("attacker") == false or context.has("defender") == false:
				return false
			return calcrange.tile_is_in_range(context.attacker.residence, context.defender.residence, 1)

	return false


func execute_effect(effect, context, msg):
	match str(effect.get("action", "")):
		"extra_attack_same_target":
			execute_extra_attack_same_target(effect, context, msg)
		"counterattack_attacker":
			execute_counterattack_attacker(effect, context, msg)


func execute_extra_attack_same_target(effect, context, msg):
	var attacker = context.get("attacker", null)
	var defender = context.get("defender", null)
	var weapon = context.get("weapon", null)
	if attacker == null or defender == null or weapon == null:
		return

	var tile_start = context.get("tile_start", attacker.residence)
	var tile_end = context.get("tile_end", defender.residence)
	var tile_range = int(context.get("tile_range", attacker.get_range_attack(weapon)))
	var count = int(effect.get("count", 1))

	for _n in count:
		ToolMagicMaker.add_attack(attacker, tile_start, tile_end, tile_range, defender, weapon, msg)


func execute_counterattack_attacker(effect, context, msg):
	var attacker = context.get("attacker", null)
	var defender = context.get("defender", null)
	if attacker == null or defender == null:
		return

	var weapon = defender.weapon_main
	var tile_range = defender.get_range_attack(weapon)
	var count = int(effect.get("count", 1))

	for _n in count:
		ToolMagicMaker.add_attack(defender, defender.residence, attacker.residence, tile_range, attacker, weapon, msg)


func load_texture(path):
	if str(path).begins_with("res://mods/") == false and icon_aliases.has(path) == false:
		var texture = load(path)
		if texture != null:
			return texture

	var image = Image.new()
	if image.load(path) == OK:
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(image, 0)
		return image_texture

	var filesystem_path = resolve_filesystem_path(path)
	if filesystem_path != "" and filesystem_path != path:
		var image_file = Image.new()
		if image_file.load(filesystem_path) == OK:
			var fs_texture = ImageTexture.new()
			fs_texture.create_from_image(image_file, 0)
			return fs_texture

	return null


func resolve_filesystem_path(path):
	if path.begins_with("res://"):
		if icon_aliases.has(path):
			return icon_aliases[path]
		return OS.get_executable_path().get_base_dir().plus_file(path.replace("res://", ""))
	if path.begins_with("user://"):
		return ProjectSettings.globalize_path(path)
	return path
