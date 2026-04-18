extends Node


class_name level_up


static func resolve_vigor_cleanup_action(action):
	if ProcessQueue.PAUSED == true:
		qe.check(action)
	else:
		ProcessQueue.add_effect(action)


static func random():
	var pick = Global.rng.randi_range(1, 4)
	match pick:
			1:
				strength()
			2:
				dexterity()
			3:
				willpower()
			4:
				vigor()

static func strength():
		Global.Player.STR += 1
		Global.Player.HP_max += 25
		Global.Player.HP += 25
		ToolMessageCreator.add_message("[color=#a0c0c0]", "Your [color=#ff7050]Strength[/color] rises! [color=#707070]+25 life[/color]")
		
		if ToolSettings.settings_data.cycle_current > 1:
				var hp_bonus = float(2)
				hp_bonus *= float(ToolSettings.settings_data.cycle_current)
				Global.Player.HP_max += int(hp_bonus)
				Global.Player.HP += int(hp_bonus)
				ToolMessageCreator.add_message("[color=#ff5050]", "You are invigorated by the cycle...[color=#707070] +" + str(int(hp_bonus)) + " life[/color]")
		
		
		Global.Player.update()

static func dexterity():
		Global.Player.DEX += 1
		ToolMessageCreator.add_message("[color=#a0c0c0]", "Your [color=#50ff70]Dexterity[/color] rises!")
		Global.Player.update()
	
static func willpower():
		Global.Player.WIL += 1
		ToolMessageCreator.add_message("[color=#a0c0c0]", "Your [color=#c050ff]Willpower[/color] rises!")
		Global.Player.update()
static func vigor():
		Global.Player.HP_max += 75
		Global.Player.HP += 75
		ToolMessageCreator.add_message("[color=#a0c0c0]", "Your [color=#ff8080]Vigor[/color] rises! [color=#707070]+75 life[/color]")
		if ToolSettings.settings_data.cycle_current > 1:
				var hp_bonus = float(6)
				hp_bonus *= float(ToolSettings.settings_data.cycle_current)
				Global.Player.HP_max += int(hp_bonus)
				Global.Player.HP += int(hp_bonus)
				ToolMessageCreator.add_message("[color=#ff5050]", "You are invigorated by the cycle...[color=#707070] +" + str(int(hp_bonus)) + " life[/color]")
		
		if Global.Player.get_traits().has("Vigorlord"):
			Global.Player.HP_max += 50
			Global.Player.HP += 50
			ToolMessageCreator.add_message("[color=#a0c0c0]", "[color=#30ff30]Robe of Vigor[/color] grants [color=#707070]+50 life[/color]")
		
		Global.Player.update()
		var unit = Global.Player
		var action = {
			"name": "heal", 
			"amount": unit.HP_max - unit.HP, 
			"healer_unit": unit, 
			"healed_unit": unit, 
			"msg": "Vigor!"
		}
		resolve_vigor_cleanup_action(action)
		
		var traits = Global.Player.get_traits()
		for buff in unit.Buffs:
			if buff.harmful == true:
				
				if traits.has("Parafrost") and buff.name == "Freeze":
					pass
				elif traits.has("MasterEntangle") and buff.name == "Entangle":
					pass
				elif traits.has("MasterScorch") and buff.name == "Scorch":
					pass
				elif traits.has("MasterDoom") and buff.name == "Doom":
					pass
				elif traits.has("MasterBleed") and buff.name == "Bleed":
					pass
				elif traits.has("Damunja") and buff.name == "Bleed":
					pass
				elif traits.has("Acid_Necklace") and buff.name == "Corrosion":
					pass
				elif traits.has("Torturer") == true:
					pass
				else:
					action = {
					"name": "remove_buff", 
					"target": unit, 
					"buff": buff, 
					"msg": "Vigor!"
		}
					resolve_vigor_cleanup_action(action)
