extends Node2D

signal map_update

var unit = preload("res://src/Objects/Unit/Unit.tscn")
var moral_boost_spell = preload("res://src/Objects/MoraleBoostSpell/MoraleBoostSpell.tscn")

onready var start_pos = $Start_pos
onready var end_pos = $Base
onready var nav = $Nav
onready var map = $Nav/Map

var selected = null

var spells = {
"MoraleBoost":true,
"Fortify":true
}

func _ready():
	$Nav.modulate.a = 0
	$Menu/UpgradeBar.hide()
	
	
func _process(delta):
	pass
	

func _input(event):
	
	if event is InputEventMouseButton:
		if event.button_index == 2:
			menu_select_changed()

func get_closest_target():
	var ret = null
	var distance = 100000
	for t in $Towers.get_children():
		if $Start_pos.position.distance_to(t.position) < distance and !t.captured and t.targetable:
			distance = $Start_pos.position.distance_to(t.position)
			ret = t
	
	if ret != null:
		return ret
	else:
		#print("error in finding target or no target remaining.")
		return $Base
		
func target_captured(target_instance):
	for u in $Units.get_children():
		u.goal = get_closest_target()
	target_instance.get_node("Sprite").region_rect = Rect2(0,0,64,64)
	target_instance.get_node("Healthbar").hide()

func menu_select_changed(target_instance = null):
	if target_instance == null:
		if $Menu/UpgradeBar.visible:
			$Menu/UpgradeBar.hide()
			selected = null
	else:
		if !$Menu/UpgradeBar.visible:
			$Menu/UpgradeBar.show()
			selected = target_instance

func victory():
	$SpawnTimer.stop()
	$VictoryScreen.show()

func _on_SpawnTimer_timeout():
	for i in 1:
		var u = unit.instance()
		u.position = start_pos.position
		u.initalize(get_closest_target(), nav)
		connect("map_update", u, "update_path")
		$Units.add_child(u)
		u.update_path()


func _on_Upgrade_selected(index):
	match index:
		0:
			pass
		1:
			selected.upgrade = 1
		2:
			selected.upgrade = 2
			
			
	
	selected.get_node("Sprite").region_rect = Rect2(64,0,64,64)
	menu_select_changed()


func _on_MoraleBoost_button_down():
	if spells.MoraleBoost:
		var s = moral_boost_spell.instance()
		add_child(s)


func _on_Fortify_button_down():
	pass # replace with function body
