extends Area2D

var target = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_FortifySpell_area_entered(area):
	target = area


func _on_FortifySpell_area_exited(area):
	target = null
