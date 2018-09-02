extends Area2D

var target = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			if target != null:
				target.fortify()
				get_parent().spells.Fortify = false
				get_parent().get_node("FTimer").start()
			queue_free()
		elif event.button_index == 2 and event.pressed:
			queue_free()

func _process(delta):
	
	position += (get_global_mouse_position() - position)


func _on_FortifySpell_area_entered(area):
	target = area


func _on_FortifySpell_area_exited(area):
	target = null
