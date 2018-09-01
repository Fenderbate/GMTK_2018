extends Node2D

signal map_update

var unit = preload("res://src/Objects/Unit/Unit.tscn")
var moral_boost_spell = preload("res://src/Objects/MoraleBoostSpell/MoraleBoostSpell.tscn")
var fortify_spell = preload("res://src/Objects/FortifySpell/FortifySpell.tscn")

onready var start_pos = $Start_pos
onready var end_pos = $Base
onready var nav = $Nav
onready var map = $Nav/Map

var selected = null

var spells = {
"MoraleBoost":true,
"Fortify":true
}

var move_camera = false

export var unit_number = 10

func _ready():
	$Nav.modulate.a = 0
	$Camera/Camera2D/MenuRoot/Menu/UpgradeBar.hide()
	
	
func _physics_process(delta):
	
	if move_camera:
		$Camera.move_and_slide(
				(get_global_mouse_position() - $Camera.position).normalized() * 
				$Camera.position.distance_to(get_global_mouse_position())
		)
		print($Camera.position.distance_to(get_global_mouse_position()))
	

func _input(event):
	
	if event is InputEventMouseButton:
		if event.button_index == 2:
			menu_select_changed()
		if event.button_index == 3 and event.is_pressed():
			move_camera = true
		else:
			move_camera = false

func get_closest_target_airline():
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

func get_closest_target():
	for t in $Towers.get_children():
		if !t.captured and t.targetable:
			return t
	return $Base

func target_captured(target_instance):
	for u in $Units.get_children():
		u.goal = get_closest_target()
	target_instance.get_node("Sprite").region_rect = Rect2(0,0,64,64)
	target_instance.get_node("Healthbar").hide()
	unit_number += 5

func menu_select_changed(target_instance = null):
	if target_instance == null:
		if $Camera/Camera2D/MenuRoot/Menu/UpgradeBar.visible:
			$Camera/Camera2D/MenuRoot/Menu/UpgradeBar.hide()
			selected = null
	else:
		if !$Camera/Camera2D/MenuRoot/Menu/UpgradeBar.visible:
			$Camera/Camera2D/MenuRoot/Menu/UpgradeBar.show()
			selected = target_instance

func victory():
	$SpawnTimer.stop()
	$Camera/Camera2D/MenuRoot/VictoryScreen.show()

func _on_SpawnTimer_timeout():
	if unit_number > 0:
		randomize()
		var u = unit.instance()
		u.position = start_pos.position
		u.initalize(get_closest_target(), nav)
		connect("map_update", u, "update_path")
		if rand_range(0,100) > 50:
			u.attack_range = 100
			u.ranged = true
			u.get_node("Animation").play("Gandalf Walk")
		else:
			u.get_node("Animation").play("Mele Walk")
		
		$Units.add_child(u)
		u.update_path()
		unit_number -= 1
		


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
	if spells.Fortify:
		var f = fortify_spell.instance()
		add_child(f)
