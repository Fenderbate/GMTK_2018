extends Node

signal map_update

var unit = preload("res://src/Objects/Unit/Unit.tscn")

onready var start_pos = $Start_pos
onready var end_pos = $End_pos
onready var nav = $Nav
onready var map = $Nav/Map

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func get_closest_target():
	var ret = null
	var distance = 100000
	for t in $Towers.get_children():
		if $Start_pos.position.distance_to(t.position) < distance and !t.destroyed:
			distance = $Start_pos.position.distance_to(t.position)
			ret = t
	
	if ret != null:
		return ret
	else:
		#print("error in finding target or no target remaining.")
		return $End_pos
		
func target_destroyed(target_instance):
	for u in $Units.get_children():
		u.goal = get_closest_target()
	target_instance.queue_free()

func _on_SpawnTimer_timeout():
	var u = unit.instance()
	u.position = start_pos.position
	u.initalize(get_closest_target(), nav)
	connect("map_update", u, "update_path")
	$Units.add_child(u)
	u.update_path()
