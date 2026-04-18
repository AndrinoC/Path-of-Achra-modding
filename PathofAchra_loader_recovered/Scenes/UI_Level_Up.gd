extends Node2D

var rng = RandomNumberGenerator.new()
var count = 0
var y = 150
var info_focus = "none"
var info = {
	
}
var disabled = true
var reward_text = "[color=#a0a0a0]Choose an attribute to increase..."

onready var STR = $Choices / STRTEXT / stat
onready var DEX = $Choices / DEXTEXT / stat
onready var WIL = $Choices / WILTEXT / stat

func _process(_delta):
	pass
	
	
	
		
		
	
		
		
		
			
		
	
func enable():
	disabled = false
	
	

func _on_Timer_timeout():
	disabled = false

func _ready():
	info = cloner.clone_dict(LInfo.info_data)
	calc_reward()
	check_inv_glow()
	rng.randomize()
	update_info()
	write_hero()
	STR.bbcode_text = "[color=#a0a0a0][[color=#ffff50]1[/color]] [color=#ff7050]STR[/color] [color=#ffff50]" + str(Global.Player.get_total_STR())
	DEX.bbcode_text = "[color=#a0a0a0][[color=#ffff50]2[/color]] [color=#50ff70]DEX[/color] [color=#ffff50]" + str(Global.Player.get_total_DEX())
	WIL.bbcode_text = "[color=#a0a0a0][[color=#ffff50]3[/color]] [color=#c050ff]WIL[/color] [color=#ffff50]" + str(Global.Player.get_total_WIL())
	setup_deckbuttons()
	Global.game.leveling_up = true
	
	
	
	
	

func write_big_buttons():
	
	var speed_min = "STR"
	if (Global.Player.get_total_DEX() * 2) + Global.Player.SPEED < Global.Player.get_total_STR():
		speed_min = "DEX"
	elif Global.Player.get_total_STR() < (Global.Player.get_total_DEX() * 2) + Global.Player.SPEED:
		speed_min = "STR"
	else:
		speed_min = "none"
	
	var stringa = "[center][color=#a0a0a0][[color=#ffff50]1[/color]][/color]"
	
	
	stringa += "\n\n"
	stringa += info.STR.description_small
	
	if speed_min == "STR":
		stringa += "\n\n[color=#70a070]*will raise minimum Speed"
	elif speed_min == "none":
		stringa += "\n\n[color=#707070]*min speed 'tied,' neither STR / DEX will raise it"
	
	$Choices / STR / Label.bbcode_text = stringa
	
	stringa = "[center][color=#a0a0a0][[color=#ffff50]2[/color]][/color]"
	
	
	stringa += "\n\n"
	stringa += info.DEX.description_small
	
	if speed_min == "DEX":
		stringa += "\n\n[color=#70a070]*will raise minimum Speed"
	
	$Choices / DEX / Label.bbcode_text = stringa
	
	stringa = "[center][color=#a0a0a0][[color=#ffff50]3[/color]][/color]"

	
	stringa += "\n\n"
	stringa += info.WIL.description_small
	$Choices / WIL / Label.bbcode_text = stringa
	
	stringa = "[center][color=#a0a0a0][[color=#ffff50]4[/color]][/color]"
	
	
	stringa += "\n\n"
	stringa += info.revive.description_small
	$Choices / LIFE / Label.bbcode_text = stringa


func write_hero():
	
	var stringa = "[color=#909090][center]"
	
	stringa += "[color=#ff7050]STR[/color] [color=#ffff50]" + str(Global.Player.get_total_STR())
	stringa += "     [color=#50ff70]DEX[/color] [color=#ffff50]" + str(Global.Player.get_total_DEX())
	stringa += "     [color=#c050ff]WIL[/color] [color=#ffff50]" + str(Global.Player.get_total_WIL())
	
	
	
	$info2.bbcode_text = stringa
	
	stringa = "[center]" + ToolMessageCreator.write_unit(Global.Player)
	$Choices / stats.bbcode_text = stringa
	
	write_big_buttons()
	
func write_hero_manual():
	var stringa = ""
	var speed_color = "[color=#30a030]"
	if int(Global.Player.get_total_weight()) > int(Global.Player.get_total_STR()):
					speed_color = "[color=#a03030]"
	if int(Global.Player.get_total_inflex()) > 1:
					speed_color = "[color=#a03030]"
	if StatMods.check(Global.Player, "speed") <= - 1:
					speed_color = "[color=#a03030]"
	
	stringa += "     [color=#30a030]Spd. " + speed_color + str(Global.Player.get_SPEED()) + " [color=#707070](" + str(Global.Player.get_SPEED_min()) + ")"
	
	var enc_color = "[color=#a03030]"
	if int(Global.Player.get_total_weight()) > 0:
					enc_color = "[color=#a03030]"
	if int(Global.Player.get_total_weight()) <= int(Global.Player.get_total_STR()):
					enc_color = "[color=#30a030]"
					
	stringa += "     [color=#a03030]Enc. " + enc_color + str(Global.Player.get_total_weight()) + " [color=#707070]-" + str(Global.Player.get_total_STR()) + ""
	
	
	return stringa
	

func effects(y):
	var start_pos = position
	start_pos.y += y
	start_pos.x += 50
	var animation = Global.Player.god.title
	for n in 50:
		var pos = start_pos
		pos.x += rng.randi_range( - 200, 200)
		pos.y += rng.randi_range( - 200, 200)
		effectmaker.create_effect_animated_ui_context($EFFECTS, pos, animation)

func calc_reward():
	
	

	
	
	
	
	$Rewards / invoke.visible = false
	$Rewards / invoketext.visible = false
	for key in Global.Player.invokes:
			var invoke = Global.Player.invokes[key]
			if invoke["level_required"] == Global.Player.level:
				$Rewards / invoke.visible = true
				$Rewards / invoketext.visible = true
				
				$Rewards / invoketext.bbcode_text = invoke.name
	
func reward_str():
	var life = 25
	reward_text = "\nYou gain "
	reward_text += "[color=#ffff50]+" + str(life) + "[/color] [color=#ff8080]Life[/color]"
	reward_text += " because [color=#ff7050]STR[/color] is your highest attribute"
	Global.Player.HP_max += life
	Global.Player.HP += life
	
	
	$Rewards / Label.bbcode_text = "[color=#dfdf50]+" + str(life) + "[/color]"
	$Rewards / Sprite.texture = load("res://Ham_Sprite/UI/Info/life.png")

func reward_dex():
	Global.Player.SPEED += 1
	
	
	reward_text = "\nYou gain "
	reward_text += "[color=#ffff50]+1[/color] base [color=#20ff20]Speed[/color]"
	reward_text += " because [color=#50ff70]DEX[/color] is your highest attribute"
	
	$Rewards / Label.bbcode_text = "[color=#dfdf50]+1[/color]"
	$Rewards / Sprite.texture = load("res://Ham_Sprite/UI/Info/speed.png")


func reward_wil():
	
	var trait = LTraitsGeneric.trait_data.Empowered
	if Global.Player.abilities.has(trait.title):
				Global.Player.abilities[trait.title].Level += 1
				
	else:
				var new_trait = cloner.clone_dict(trait)
				var name = trait.title
		
			
				Global.Player.abilities[name] = new_trait
	
	reward_text = "\nYou gain "
	reward_text += "[color=#ffff50]+1[/color] [color=#ff90af]Empowered[/color]"
	reward_text += " because [color=#c050ff]WIL[/color] is your highest attribute"
	
	$Rewards / Label.bbcode_text = "[color=#ff90af]+1[/color]"
	$Rewards / Sprite.texture = load("res://Ham_Sprite/TraitIcons/Empowered.png")
	


func str_up():
	if disabled == false:
		Global.sound.new_sound("Click")
		Global.game.leveling_up = false
		Global.game.setup_deckbuttons()
		level_up.strength()
		ProcessQueue.PAUSED = false
		fade_out()

func dex_up():
	if disabled == false:
		Global.sound.new_sound("Click")
		Global.game.leveling_up = false
		Global.game.setup_deckbuttons()
		level_up.dexterity()
		ProcessQueue.PAUSED = false
		fade_out()

func wil_up():
	if disabled == false:
		Global.sound.new_sound("Click")
		Global.game.leveling_up = false
		Global.game.setup_deckbuttons()
		
	
		level_up.willpower()
		ProcessQueue.PAUSED = false
		fade_out()

func hp_up():
	revive()
		

func revive():
	if disabled == false:
		
		
		Global.sound.new_sound("Click")
		Global.game.leveling_up = false
		Global.game.setup_deckbuttons()
	
		
		level_up.vigor()
		
		
		ProcessQueue.PAUSED = false
		
		fade_out()


func _on_Traits_pressed():
	var u = Global.UITraits.instance()
	get_parent().add_child(u)
	u.initiate()


func update_info():
	var stringa = reward_text
	stringa = ""
	if info_focus != "none":
		stringa = "[color=#c0c0c0]"
		
		stringa += info[info_focus].description_small
		
	
			
			
			
			
				
				
			
		
		
		
		$InfoBlocker.visible = true
	else:
		$InfoBlocker.visible = false
		
	
	
	


func fade_out():
	disabled = true
	STR.bbcode_text = "[color=#a0a0a0][[color=#ffff50]1[/color]] [color=#ff7050]STR[/color] [color=#ffff50]" + str(Global.Player.get_total_STR())
	DEX.bbcode_text = "[color=#a0a0a0][[color=#ffff50]2[/color]] [color=#50ff70]DEX[/color] [color=#ffff50]" + str(Global.Player.get_total_DEX())
	WIL.bbcode_text = "[color=#a0a0a0][[color=#ffff50]3[/color]] [color=#c050ff]WIL[/color] [color=#ffff50]" + str(Global.Player.get_total_WIL())
	write_hero()
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Choices.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$AnimationPlayer.play("fade_out")
	


func _on_STR_pressed():
	str_up()
	


func _on_DEX_pressed():
	dex_up()
	


func _on_WIL_pressed():
	wil_up()
	





func _input(event):
	if event.is_action_pressed("3"):
		wil_up()
	elif event.is_action_pressed("1"):
		str_up()
	elif event.is_action_pressed("2"):
		dex_up()
	elif event.is_action_pressed("4"):
		revive()
	Global.universal.deck.input_handler(event)


func _on_HP_pressed():
	hp_up()


func _on_STR_mouse_entered():
	info_focus = "STR"
	update_info()
	Global.sound.new_sound("Hover")


func _on_DEX_mouse_entered():
	info_focus = "DEX"
	update_info()
	Global.sound.new_sound("Hover")


func _on_WIL_mouse_entered():
	info_focus = "WIL"
	update_info()
	Global.sound.new_sound("Hover")


func _on_HP_mouse_entered():
	info_focus = "life"
	update_info()
	Global.sound.new_sound("Hover")


func _on_STR_mouse_exited():
	info_focus = "none"
	update_info()


func _on_DEX_mouse_exited():
	info_focus = "none"
	update_info()


func _on_WIL_mouse_exited():
	info_focus = "none"
	update_info()


func _on_HP_mouse_exited():
	info_focus = "none"
	update_info()

func check_inv_glow():
	var available_traits = []
	
	if Global.Player.ELEMENTS.size() < 2:
		for trait in LTraits.list_all:
			if trait.ready == true:
				if trait.cost <= Global.Player.POINTS_TRAITS:
					available_traits.append(trait)
	else:
		for trait in LTraits.list_all:
			if trait.ready == true:
				if Global.Player.ELEMENTS.has(trait.Element) == true:
					if trait.cost <= Global.Player.POINTS_TRAITS:
						available_traits.append(trait)
	
	if available_traits.size() > 0:
		print("Glow on!")
		
		Global.trait_glow = true




func _on_LIFE_mouse_exited():
	info_focus = "none"
	update_info()


func _on_LIFE_pressed():
	revive()


func _on_LIFE_mouse_entered():
	info_focus = "revive"
	update_info()
	Global.sound.new_sound("Hover")


func setup_deckbuttons():
	Global.universal.deck.deckbutton_selected = null
	Global.universal.deck.index_x = 0
	Global.universal.deck.index_y = 0
	Global.universal.deck.deckbuttons = [[], [], [], []]
	Global.universal.deck.deckbuttons[0] = [$Choices / STR]
	Global.universal.deck.deckbuttons[1] = [$Choices / DEX]
	Global.universal.deck.deckbuttons[2] = [$Choices / WIL]
	Global.universal.deck.deckbuttons[3] = [$Choices / LIFE]
	
	
	Global.universal.deck.set_first_button()
