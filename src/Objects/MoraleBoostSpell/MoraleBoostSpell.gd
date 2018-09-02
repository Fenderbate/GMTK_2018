extends Area2D

var targets = []

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			for t in targets:
				t.moral_boost()
			get_parent().spells.MoraleBoost = false
			get_parent().get_node("BMTimer").start()
			queue_free()
		elif event.button_index == 2 and event.pressed:
			queue_free()

func _process(delta):
	
	position += (get_global_mouse_position() - position)
	


func _on_MoraleBoostSpell_area_entered(area):
	targets.append(area)


func _on_MoraleBoostSpell_area_exited(area):
	targets.erase(area)
