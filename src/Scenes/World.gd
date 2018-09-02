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

export var unit_number = 50

export var nextstage = -1

func _ready():
	$Nav.modulate.a = 0
	$Camera/Camera2D/MenuRoot/Menu/UpgradeBar/Panel.hide()
	
	
func _physics_process(delta):
	
	if !$BMTimer.is_stopped():
		$Camera/Camera2D/MenuRoot/Menu/SpellBar/Panel/MoraleBoost/MBCD.value = ($BMTimer.time_left / $BMTimer.wait_time) * 100
	if !$FTimer.is_stopped():
		$Camera/Camera2D/MenuRoot/Menu/SpellBar/Panel/Fortify/FCD.value = ($FTimer.time_left / $FTimer.wait_time) * 100
	
	if $Units.get_child_count() == 0 and unit_number == 0:
		get_tree().reload_current_scene()
	
	$Camera/Camera2D/MenuRoot/Menu/Units1.text = str("Units\nFighting:\n",$Units.get_child_count())
	$Camera/Camera2D/MenuRoot/Menu/Units2.text = str("Units\nIn Base:\n",unit_number)
	
#	if move_camera:
#		$Camera.move_and_slide(
#				(get_global_mouse_position() - $Camera.position).normalized() * 
#				$Camera.position.distance_to(get_global_mouse_position())
#		)
	
	update()
	
func _input(event):
	
	if event is InputEventMouseButton:
		if event.button_index == 2:
			if selected != null:
				selected.selected = false
			menu_select_changed()
		if event.button_index == 3 and event.is_pressed():
			move_camera = true
		else:
			move_camera = false
	if event is InputEventMouseMotion:
		if move_camera:
			$Camera.position -= event.relative
			
			if $Camera.position.x < $CameraLimitTopLeft.position.x:
				$Camera.position.x = $CameraLimitTopLeft.position.x
			
			if $Camera.position.y < $CameraLimitTopLeft.position.y:
				$Camera.position.y = $CameraLimitTopLeft.position.y
			
			if $Camera.position.x > $CameraLimitBotRight.position.x:
				$Camera.position.x = $CameraLimitBotRight.position.x
			
			if $Camera.position.y > $CameraLimitBotRight.position.y:
				$Camera.position.y = $CameraLimitBotRight.position.y

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
	
	if target_instance != selected:
		if selected != null:
			selected.selected = false
		if target_instance != null:
			target_instance.selected = true
			selected = target_instance
	
	if target_instance == null:
		if $Camera/Camera2D/MenuRoot/Menu/UpgradeBar/Panel.visible:
			$Camera/Camera2D/MenuRoot/Menu/UpgradeBar/Panel.hide()
			selected = null
	else:
		if !$Camera/Camera2D/MenuRoot/Menu/UpgradeBar/Panel.visible:
			$Camera/Camera2D/MenuRoot/Menu/UpgradeBar/Panel.show()
			selected = target_instance
			selected.selected = true



    

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
	if selected.upgrade != index:
		selected.upgrade = index
	else:
		$Camera/Camera2D/MenuRoot/Menu/UpgradeBar/Description.text = "The tower already has this upgrade!"
			
	


func _on_MoraleBoost_button_down():
	if spells.MoraleBoost:
		var s = moral_boost_spell.instance()
		add_child(s)


func _on_Fortify_button_down():
	if spells.Fortify:
		var f = fortify_spell.instance()
		add_child(f)

func _on_Button_mouse_entered(index):
	match index:
		0:
			$Camera/Camera2D/MenuRoot/Menu/UpgradeBar/Description.text = "Heal Upgrade:\nHeals the units within the tower's range."
		1:
			$Camera/Camera2D/MenuRoot/Menu/UpgradeBar/Description.text = "Shield Upgrade:\nShields the units within the tower's range."
		2:
			$Camera/Camera2D/MenuRoot/Menu/UpgradeBar/Description.text = "Battle Morale:\nMakes usints go faster."
		3:
			$Camera/Camera2D/MenuRoot/Menu/UpgradeBar/Description.text = "Fortify:\nBoosts the selected towers effect."

func _on_Button_mouse_left():
	$Camera/Camera2D/MenuRoot/Menu/UpgradeBar/Description.text = ""


func _on_BMTimer_timeout():
	spells.MoraleBoost = true


func _on_FTimer_timeout():
	spells.Fortify = true


func _on_NextStage_button_down():
	if nextstage != -1:
		get_tree().change_scene(str("res://src/Scenes/World",nextstage,".tscn"))
