extends Node

const CONFIG_FILE = "user://mods-config.json"


var mods = []
var mods_all = []
var prestige_defs = []
var prestige_by_title = {}
var trait_effect_defs = {}
var lore_entries = {}
var icon_aliases = {}
var mod_config = {}
var table_patches = {}
var default_unlocked_keys = {}

const TABLE_SECTION_MAP = {
	"res://Data/Table_TraitsGeneric.json": "prestiges",
	"res://Data/Table_Traits.json": "skills",
	"res://Data/Table_Lore.json": "lore_entries",
	"res://Data/Table_Classes.json": "classes",
	"res://Data/Table_Races.json": "races",
	"res://Data/Table_Gods.json": "gods",
	"res://Data/Table_Weapons.json": "weapons",
	"res://Data/Table_Armor.json": "armor",
	"res://Data/Table_Invokes.json": "invokes",
	"res://Data/Table_Buffs.json": "buffs",
	"res://Data/Table_Allies.json": "allies",
}

const SPRITE_KEYS = ["sprite", "icon", "tile_sprite", "formsprite", "sprite_corpse", "world_icon"]


func _enter_tree():
	load_mods()


func load_mods():
	load_mod_config()
	mods = []
	mods_all = []
	prestige_defs = []
	prestige_by_title = {}
	trait_effect_defs = {}
	lore_entries = {}
	icon_aliases = {}
	table_patches = {}
	default_unlocked_keys = {}

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

	var mod_id = str(manifest.get("id", folder_name))
	var default_enabled = true
	if manifest.has("enabled_by_default"):
		default_enabled = bool(manifest.get("enabled_by_default", true))
	elif mod_id == "template_mod":
		default_enabled = false

	return {
		"id": mod_id,
		"folder_name": folder_name,
		"name": str(manifest.get("name", folder_name)),
		"version": str(manifest.get("version", "0.0.0")),
		"load_order": int(manifest.get("load_order", 100)),
		"base_path": base_path,
		"filesystem_root": filesystem_root,
		"default_enabled": default_enabled,
		"enabled": is_mod_enabled(mod_id, default_enabled),
		"loaded_now": false,
		"content": content,
	}


func rebuild_indexes():
	prestige_defs = []
	prestige_by_title = {}
	trait_effect_defs = {}
	lore_entries = {}

	for mod in mods:
		var mod_prestiges = mod.content.get("prestiges", {})
		if typeof(mod_prestiges) != TYPE_DICTIONARY:
			continue

		for key in mod_prestiges:
			var prestige_def = normalize_prestige_definition(mod, key, mod_prestiges[key])
			if prestige_def != null:
				set_prestige_definition(prestige_def)

		var mod_trait_effects = mod.content.get("trait_effects", {})
		if typeof(mod_trait_effects) == TYPE_DICTIONARY:
			for key in mod_trait_effects:
				set_trait_effect_definition(key, normalize_trait_effect_definition(mod_trait_effects[key]))

	collect_table_patches()


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


func collect_table_patches():
	table_patches = {}
	default_unlocked_keys = {}
	for table_path in TABLE_SECTION_MAP:
		table_patches[table_path] = {}

	for mod in mods:
		for table_path in TABLE_SECTION_MAP:
			var section_name = TABLE_SECTION_MAP[table_path]
			var section_data = get_mod_content_section(mod, section_name)
			if typeof(section_data) != TYPE_DICTIONARY:
				continue

			for key in section_data:
				table_patches[table_path][key] = normalize_table_entry(mod, section_data[key], key)
				if section_name == "classes" or section_name == "races" or section_name == "gods":
					if entry_unlocked_by_default(section_data[key]):
						default_unlocked_keys[key] = true


func entry_unlocked_by_default(entry):
	if typeof(entry) == TYPE_DICTIONARY and entry.has("unlocked_by_default"):
		return bool(entry.unlocked_by_default)
	return true


func get_mod_content_section(mod, section_name):
	if section_name == "prestiges":
		var out = {}
		var mod_prestiges = mod.content.get("prestiges", {})
		if typeof(mod_prestiges) != TYPE_DICTIONARY:
			return out
		for key in mod_prestiges:
			var definition = mod_prestiges[key]
			if typeof(definition) == TYPE_DICTIONARY and definition.has("trait") and typeof(definition.trait) == TYPE_DICTIONARY:
				out[key] = definition.trait
		return out

	if section_name == "lore_entries":
		var lore_out = {}
		var mod_prestige_lore = mod.content.get("prestiges", {})
		if typeof(mod_prestige_lore) == TYPE_DICTIONARY:
			for key in mod_prestige_lore:
				var definition = mod_prestige_lore[key]
				if typeof(definition) == TYPE_DICTIONARY and definition.has("lore") and typeof(definition.lore) == TYPE_DICTIONARY:
					lore_out[key] = definition.lore
		var explicit_lore = mod.content.get("lore", {})
		if typeof(explicit_lore) == TYPE_DICTIONARY:
			for key in explicit_lore:
				lore_out[key] = explicit_lore[key]
		return lore_out

	return mod.content.get(section_name, {})


func normalize_table_entry(mod, entry, default_key = ""):
	if typeof(entry) != TYPE_DICTIONARY:
		return entry
	var out = entry.duplicate(true)
	if default_key != "" and out.has("title") == false:
		out["title"] = default_key
	if out.has("unlocked_by_default"):
		out.erase("unlocked_by_default")
	adjust_entry_paths(mod, out)
	return out


func adjust_entry_paths(mod, entry):
	for key in entry.keys():
		var value = entry[key]
		if typeof(value) == TYPE_DICTIONARY:
			adjust_entry_paths(mod, value)
		elif typeof(value) == TYPE_ARRAY:
			for item in value:
				if typeof(item) == TYPE_DICTIONARY:
					adjust_entry_paths(mod, item)
		elif key in SPRITE_KEYS and typeof(value) == TYPE_STRING:
			entry[key] = normalize_mod_path(mod, str(value))


func normalize_mod_path(mod, value):
	var path = str(value)
	if path.find("://") != -1:
		return path
	if path.begins_with("/"):
		path = path.substr(1, path.length() - 1)
	if str(mod.filesystem_root) != "":
		icon_aliases[mod.base_path + "/" + path] = mod.filesystem_root.plus_file(path)
	return mod.base_path + "/" + path


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
	if prestige_def.effects != null:
		set_trait_effect_definition(title, {
			"effects": prestige_def.effects,
		})


func normalize_trait_effect_definition(definition):
	if typeof(definition) == TYPE_ARRAY:
		return {
			"effects": definition,
		}
	if typeof(definition) == TYPE_DICTIONARY:
		if definition.has("effects"):
			return definition
		return {
			"effects": [definition],
		}
	return {
		"effects": [],
	}


func set_trait_effect_definition(title, definition):
	trait_effect_defs[title] = definition


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


func is_mod_enabled(mod_id, default_enabled = true):
	if mod_config.has("enabled") == false:
		return default_enabled
	if typeof(mod_config.enabled) != TYPE_DICTIONARY:
		return default_enabled
	if mod_config.enabled.has(mod_id) == false:
		return default_enabled
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


func is_key_default_unlocked(key):
	return default_unlocked_keys.has(key)


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

	for table_path in TABLE_SECTION_MAP:
		if path.to_lower() == table_path.to_lower():
			for key in table_patches[table_path]:
				loaded_data[key] = cloner.clone_dict(table_patches[table_path][key])
			break

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
	var metrics = compute_unlock_metrics(traits)
	return evaluate_unlock_rule(unlock, traits, metrics)


func compute_unlock_metrics(traits):
	var metrics = {
		"all_total": 0,
		"body_total": 0,
		"martial_total": 0,
		"fire_total": 0,
		"life_total": 0,
		"lightning_total": 0,
		"astral_total": 0,
		"psychic_total": 0,
		"poison_total": 0,
		"death_total": 0,
		"blood_total": 0,
		"ice_total": 0,
		"form_total": 0,
		"ooze_total": 0,
		"necro_total": 0,
		"gallus_total": 0,
		"starjumper_total": 0,
		"strijela_total": 0,
		"nochti_total": 0,
		"lit_total": 0,
		"master_total": 0,
		"self_damage_total": 0,
		"self_damage": 0,
		"chant_total": 0,
		"staff_count": 0,
		"beast_total": 0,
		"mindfight_total": 0,
		"gorecleave_total": 0,
		"elementalist_total": 0,
		"player_level": 0,
	}

	if Global.Player == null:
		return metrics

	metrics.player_level = Global.Player.level

	var items = []
	for item in Global.Player.bag:
		items.append(item)
	var slots = [Global.Player.weapon_main, Global.Player.weapon_off, Global.Player.armor_head, Global.Player.armor_chest, Global.Player.armor_hands, Global.Player.armor_legs]
	for slot in slots:
		if slot != null:
			items.append(slot)

	for item in items:
		if "staff" in textstrip.strip_bbcode(item.name).to_lower():
			metrics.staff_count += 1

	for key in traits:
		var trait = traits[key]
		if trait.generic == false:
			var increase = trait.cost * trait.Level

			if "self-damage" in textstrip.strip_bbcode(trait.Description).to_lower():
				metrics.self_damage_total += increase
				metrics.self_damage += increase

			if "chant" in textstrip.strip_bbcode(trait.Name).to_lower():
				metrics.chant_total += increase

			if "kinesis" in textstrip.strip_bbcode(trait.Name).to_lower():
				metrics.elementalist_total += increase

			metrics.all_total += increase

			match trait.Element:
				"Body":
					metrics.body_total += increase
					metrics.martial_total += increase
				"Fire":
					metrics.fire_total += increase
				"Lightning":
					metrics.lightning_total += increase
				"Poison":
					metrics.poison_total += increase
				"Life":
					metrics.life_total += increase
				"Death":
					metrics.death_total += increase
				"Astral":
					metrics.astral_total += increase
				"Ice":
					metrics.ice_total += increase
				"Blood":
					metrics.blood_total += increase
				"Psychic":
					metrics.psychic_total += increase

			match trait.title:
				"Batform", "Snakeform", "Wormform", "Sparkform", "Geistform", "Vineform":
					metrics.form_total += increase
				"SummonRedDragon", "SummonGrika", "PoisonFamiliar":
					metrics.beast_total += increase
				"Oozemancy", "Slime", "BurningOoze":
					metrics.ooze_total += increase
				"Necromancy", "MavetKa", "HungryGrave", "ChannelDeath":
					metrics.necro_total += increase
				"Tenacity":
					metrics.gallus_total += increase
				"Aim":
					metrics.strijela_total += increase
				"Rampage":
					metrics.nochti_total += increase
				"GoreCleave":
					metrics.gorecleave_total += increase
				"MindKnight":
					metrics.mindfight_total += increase
				"Astrostoicism", "Astrohunting", "AstralSeeking", "Shimmergang":
					metrics.starjumper_total += increase
				"BlightCult", "MinionFeast", "GroveCult", "FlameCult", "FulminantCult", "StarCult":
					metrics.lit_total += increase
				"MasterEntangle", "MasterScorch", "Parafrost", "MasterDoom", "MasterBleed":
					metrics.master_total += increase

	return metrics


func evaluate_unlock_rule(rule, traits, metrics):
	if typeof(rule) != TYPE_DICTIONARY:
		return false

	match str(rule.get("type", "always")):
		"always":
			return true
		"all":
			for subrule in rule.get("requirements", []):
				if evaluate_unlock_rule(subrule, traits, metrics) == false:
					return false
			return true
		"any":
			for subrule in rule.get("requirements", []):
				if evaluate_unlock_rule(subrule, traits, metrics) == true:
					return true
			return false
		"not":
			return evaluate_unlock_rule(rule.get("requirement", {}), traits, metrics) == false
		"skill_sum":
			return skill_sum_is_met(rule, traits)
		"metric_gte":
			return get_metric(metrics, str(rule.get("metric", ""))) >= float(rule.get("threshold", 0))
		"metric_sum_gte":
			var total = 0.0
			for metric_name in rule.get("metrics", []):
				total += get_metric(metrics, str(metric_name))
			return total >= float(rule.get("threshold", 0))
		"element_presence_all":
			for element in rule.get("elements", []):
				if Global.Player.ELEMENTS.has(str(element)) == false:
					return false
			return true
		"element_presence_any":
			for element in rule.get("elements", []):
				if Global.Player.ELEMENTS.has(str(element)) == true:
					return true
			return false
		"player_level_gte":
			return Global.Player.level >= int(rule.get("level", 0))
		"elements_empty":
			return Global.Player.ELEMENTS.empty()
		"land_is":
			return StateWorld.land == str(rule.get("value", ""))
		"item_match":
			return item_match(rule)
		"compare":
			return compare_values(resolve_schema_value(rule.get("left", null), {"player": Global.Player}), str(rule.get("op", "eq")), resolve_schema_value(rule.get("right", null), {"player": Global.Player}))

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


func get_metric(metrics, key):
	if metrics.has(key):
		return float(metrics[key])
	return 0.0


func item_match(rule):
	var item = get_player_item_from_slot(str(rule.get("slot", "")))
	if item == null:
		return false

	var property_name = str(rule.get("property", "title"))
	var left = resolve_ref_segment(item, property_name)
	var right = rule.get("value", null)
	return compare_values(left, str(rule.get("op", "eq")), right)


func get_player_item_from_slot(slot):
	match slot:
		"weapon_main":
			return Global.Player.weapon_main
		"weapon_off":
			return Global.Player.weapon_off
		"armor_head":
			return Global.Player.armor_head
		"armor_chest":
			return Global.Player.armor_chest
		"armor_hands":
			return Global.Player.armor_hands
		"armor_legs":
			return Global.Player.armor_legs

	return null


func apply_prestige_trigger(trigger, context):
	var trigger_unit = get_trigger_unit(trigger, context)

	if trigger_unit == null:
		return

	context["trigger"] = trigger
	context["trigger_unit"] = trigger_unit

	var trigger_traits = trigger_unit.get_traits()
	for title in trait_effect_defs:
		if trigger_traits.has(title) == false:
			continue

		var effects = trait_effect_defs[title].get("effects", [])
		if typeof(effects) != TYPE_ARRAY:
			continue

		for effect in effects:
			if typeof(effect) != TYPE_DICTIONARY:
				continue
			if str(effect.get("trigger", "")) != trigger:
				continue
			if conditions_are_met(effect.get("conditions", []), context, trigger_unit) == false:
				continue

			execute_effect_entry(effect, context, trigger_traits[title].Name)


func get_trigger_unit(trigger, context):
	match trigger:
		"on_attack", "on_hit", "on_damage":
			return context.get("attacker", null)
		"on_heal":
			return context.get("healer_unit", null)
		"on_invoke", "on_learn":
			return Global.Player
		"on_summon":
			return context.get("summoner", null)
		"on_apply_bonus_source":
			return context.get("origin", null)
		"on_apply_buff_source":
			var buff_source = context.get("buff", null)
			if buff_source != null:
				return buff_source.source
		"on_block", "on_dodge", "on_shrug_off", "on_receive_damage":
			return context.get("defender", null)
		"on_receive_heal":
			return context.get("healed_unit", null)
		"on_apply_bonus_target":
			return context.get("target", null)
		"on_move", "on_wait", "on_turn", "on_level_up", "on_teleport", "on_enter_level", "on_spawned", "on_intervention", "on_remove_buff":
			return context.get("unit", null)
		"on_death":
			return context.get("dying_unit", null)
		"on_kill":
			return context.get("killer", null)
		"on_pickup":
			return Global.Player
		"on_apply_buff_target":
			var buff_target = context.get("buff", null)
			if buff_target != null:
				return buff_target.target

	return null


func conditions_are_met(conditions, context, trigger_unit):
	if typeof(conditions) == TYPE_NIL:
		return true
	if typeof(conditions) == TYPE_DICTIONARY:
		return condition_is_met(conditions, context, trigger_unit)
	if typeof(conditions) != TYPE_ARRAY:
		return true

	for condition in conditions:
		if condition_is_met(condition, context, trigger_unit) == false:
			return false

	return true


func condition_is_met(condition, context, trigger_unit):
	if typeof(condition) == TYPE_STRING:
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

	if typeof(condition) != TYPE_DICTIONARY:
		return false

	match str(condition.get("type", "all")):
		"all":
			for subcondition in condition.get("conditions", []):
				if condition_is_met(subcondition, context, trigger_unit) == false:
					return false
			return true
		"any":
			for subcondition in condition.get("conditions", []):
				if condition_is_met(subcondition, context, trigger_unit) == true:
					return true
			return false
		"not":
			return condition_is_met(condition.get("condition", {}), context, trigger_unit) == false
		"trait_has":
			var trait_unit = get_condition_subject(condition, context, trigger_unit)
			return trait_unit != null and trait_unit.get_traits().has(str(condition.get("trait", "")))
		"trait_lacks":
			var no_trait_unit = get_condition_subject(condition, context, trigger_unit)
			return no_trait_unit != null and no_trait_unit.get_traits().has(str(condition.get("trait", ""))) == false
		"buff_has":
			var buff_unit = get_condition_subject(condition, context, trigger_unit)
			return buff_unit != null and buff_unit.get_buff_names().has(str(condition.get("buff", "")))
		"buff_lacks":
			var no_buff_unit = get_condition_subject(condition, context, trigger_unit)
			return no_buff_unit != null and no_buff_unit.get_buff_names().has(str(condition.get("buff", ""))) == false
		"element_has":
			var element_unit = get_condition_subject(condition, context, trigger_unit)
			return element_unit == Global.Player and Global.Player.ELEMENTS.has(str(condition.get("element", "")))
		"element_lacks":
			var no_element_unit = get_condition_subject(condition, context, trigger_unit)
			return no_element_unit == Global.Player and Global.Player.ELEMENTS.has(str(condition.get("element", ""))) == false
		"weapon_bare_fist":
			var weapon_unit = get_condition_subject(condition, context, trigger_unit)
			if weapon_unit == null:
				return false
			var slot_name = str(condition.get("slot", "main"))
			var weapon = weapon_unit.weapon_main
			if slot_name == "off":
				weapon = weapon_unit.weapon_off
			return translate.is_bare_fist(weapon)
		"melee_range":
			var source = resolve_schema_value(condition.get("source", "@attacker"), context)
			var target = resolve_schema_value(condition.get("target", "@defender"), context)
			var distance = int(resolve_schema_value(condition.get("distance", 1), context))
			if source == null or target == null:
				return false
			return calcrange.tile_is_in_range(source.residence, target.residence, distance)
		"is_player":
			return get_condition_subject(condition, context, trigger_unit) == Global.Player
		"is_dead":
			var dead_unit = get_condition_subject(condition, context, trigger_unit)
			return dead_unit != null and dead_unit.is_dead() == bool(condition.get("value", true))
		"object_type_is":
			var object_unit = get_condition_subject(condition, context, trigger_unit)
			return object_unit != null and object_unit.object_type == str(condition.get("value", ""))
		"compare":
			return compare_values(resolve_schema_value(condition.get("left", null), context), str(condition.get("op", "eq")), resolve_schema_value(condition.get("right", null), context))

	return false


func get_condition_subject(condition, context, trigger_unit):
	if condition.has("subject"):
		return resolve_schema_value(condition.subject, context)
	return trigger_unit


func execute_effect_entry(effect, context, msg):
	if effect.has("actions") and typeof(effect.actions) == TYPE_ARRAY:
		for action_def in effect.actions:
			execute_action(action_def, context, msg)
	else:
		execute_action(effect, context, msg)


func execute_action(effect, context, msg):
	if typeof(effect) != TYPE_DICTIONARY:
		return

	var local_context = context.duplicate(true)
	var local_msg = msg
	if effect.has("msg"):
		local_msg = str(resolve_schema_value(effect.msg, local_context))
	local_context["msg"] = local_msg

	match str(effect.get("action", "")):
		"extra_attack_same_target":
			execute_extra_attack_same_target(effect, local_context, local_msg)
		"counterattack_attacker":
			execute_counterattack_attacker(effect, local_context, local_msg)
		"queue_effect":
			queue_effect(effect, local_context, local_msg)
		"queue_effects":
			for queued in effect.get("effects", []):
				queue_effect({"effect": queued}, local_context, local_msg)
		"add_message":
			ToolMessageCreator.add_message(str(resolve_schema_value(effect.get("color", "[color=#c0c0c0]"), local_context)), str(resolve_schema_value(effect.get("message", ""), local_context)))


func queue_effect(effect, context, msg):
	var effect_data = effect.get("effect", null)
	if effect_data == null:
		effect_data = effect
	var queued = resolve_schema_value(effect_data, context)
	if typeof(queued) != TYPE_DICTIONARY:
		return
	if queued.has("action"):
		queued.erase("action")
	if queued.has("msg") == false:
		queued["msg"] = msg
	ProcessQueue.add_effect(queued)


func execute_extra_attack_same_target(effect, context, msg):
	var attacker = resolve_schema_value(effect.get("attacker", "@attacker"), context)
	var defender = resolve_schema_value(effect.get("defender", "@defender"), context)
	var weapon = resolve_schema_value(effect.get("weapon", "@weapon"), context)
	if attacker == null or defender == null or weapon == null:
		return

	var tile_start = resolve_schema_value(effect.get("tile_start", "@tile_start"), context)
	if tile_start == null:
		tile_start = attacker.residence
	var tile_end = resolve_schema_value(effect.get("tile_end", "@tile_end"), context)
	if tile_end == null:
		tile_end = defender.residence
	var tile_range = int(resolve_schema_value(effect.get("tile_range", context.get("tile_range", attacker.get_range_attack(weapon))), context))
	var count = int(resolve_schema_value(effect.get("count", 1), context))

	for _n in count:
		ToolMagicMaker.add_attack(attacker, tile_start, tile_end, tile_range, defender, weapon, msg)


func execute_counterattack_attacker(effect, context, msg):
	var attacker = resolve_schema_value(effect.get("attacker", "@attacker"), context)
	var defender = resolve_schema_value(effect.get("defender", "@defender"), context)
	if attacker == null or defender == null:
		return

	var weapon = resolve_schema_value(effect.get("weapon", "@defender.weapon_main"), context)
	if weapon == null:
		weapon = defender.weapon_main
	var tile_range = int(resolve_schema_value(effect.get("tile_range", defender.get_range_attack(weapon)), context))
	var count = int(resolve_schema_value(effect.get("count", 1), context))

	for _n in count:
		ToolMagicMaker.add_attack(defender, defender.residence, attacker.residence, tile_range, attacker, weapon, msg)


func resolve_schema_value(value, context):
	var value_type = typeof(value)
	if value_type == TYPE_STRING:
		var string_value = str(value)
		if string_value.begins_with("@"):
			return resolve_ref_path(string_value.substr(1, string_value.length() - 1), context)
		return value
	if value_type == TYPE_ARRAY:
		var out_array = []
		for item in value:
			out_array.append(resolve_schema_value(item, context))
		return out_array
	if value_type == TYPE_DICTIONARY:
		if value.has("ref"):
			return evaluate_ref_spec(value, context)
		var out_dict = {}
		for key in value:
			out_dict[key] = resolve_schema_value(value[key], context)
		return out_dict
	return value


func evaluate_ref_spec(spec, context):
	var base = resolve_ref_path(str(spec.ref), context)
	if is_numeric_value(base):
		var number = float(base)
		if spec.has("mult"):
			number *= float(resolve_schema_value(spec.mult, context))
		if spec.has("div"):
			number /= float(resolve_schema_value(spec.div, context))
		if spec.has("add"):
			number += float(resolve_schema_value(spec.add, context))
		if spec.has("sub"):
			number -= float(resolve_schema_value(spec.sub, context))
		if spec.has("min"):
			var min_value = float(resolve_schema_value(spec.min, context))
			if number < min_value:
				number = min_value
		if spec.has("max"):
			var max_value = float(resolve_schema_value(spec.max, context))
			if number > max_value:
				number = max_value
		match str(spec.get("round", "")):
			"int":
				return int(number)
			"floor":
				return floor(number)
			"ceil":
				return ceil(number)
		return number
	return base


func resolve_ref_path(path, context):
	var parts = str(path).split(".")
	if parts.empty():
		return null

	var current = resolve_ref_root(parts[0], context)
	for index in range(1, parts.size()):
		current = resolve_ref_segment(current, parts[index])
	return current


func resolve_ref_root(root, context):
	if typeof(context) == TYPE_DICTIONARY and context.has(root):
		return context[root]

	match root:
		"player":
			return Global.Player
		"land":
			return StateWorld.land

	return null


func resolve_ref_segment(current, segment):
	if current == null:
		return null
	if typeof(current) == TYPE_DICTIONARY:
		if current.has(segment):
			return current[segment]
		return null
	if typeof(current) == TYPE_ARRAY:
		var index = int(segment)
		if index >= 0 and index < current.size():
			return current[index]
		return null

	match segment:
		"speed":
			if current.has_method("get_SPEED"):
				return current.get_SPEED()
		"damage_total_mainhand":
			if current.has_method("get_DMG_total"):
				return current.get_DMG_total(current.weapon_main)
		"damage_type_mainhand":
			if current.has_method("get_DMG_type"):
				return current.get_DMG_type(current.weapon_main)
		"range_mainhand":
			if current.has_method("get_range_attack"):
				return current.get_range_attack(current.weapon_main)
		"buff_names":
			if current.has_method("get_buff_names"):
				return current.get_buff_names()
		"traits":
			if current.has_method("get_traits"):
				return current.get_traits()

	return current.get(segment)


func compare_values(left, op, right):
	match op:
		"eq":
			return normalize_compare_value(left) == normalize_compare_value(right)
		"neq":
			return normalize_compare_value(left) != normalize_compare_value(right)
		"gt":
			return float(left) > float(right)
		"gte":
			return float(left) >= float(right)
		"lt":
			return float(left) < float(right)
		"lte":
			return float(left) <= float(right)
		"contains":
			return normalize_compare_value(left).find(normalize_compare_value(right)) != -1
		"has":
			if typeof(left) == TYPE_ARRAY or typeof(left) == TYPE_DICTIONARY:
				return left.has(right)

	return false


func normalize_compare_value(value):
	if typeof(value) == TYPE_STRING:
		return textstrip.strip_bbcode(str(value)).to_lower()
	return value


func is_numeric_value(value):
	var value_type = typeof(value)
	return value_type == TYPE_INT or value_type == TYPE_REAL


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
