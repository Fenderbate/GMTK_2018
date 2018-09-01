extends Area2D

var speed = 150
var nav = null setget set_nav
var path = []
var goal = null setget set_goal

var distance_threshold = 5

var attack_range = 60

var health = 10
var damage = 1

func set_nav(new_nav):
	nav = new_nav
	update_path()

func set_goal(new_goal):
	goal = new_goal
	update_path()

func initalize(_goal,_nav):
	goal = _goal
	nav = _nav

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func hurt(dmg):
	health -= dmg
	if health <= 0:
		queue_free()

func update_path():
	path = nav.get_simple_path(position, goal.position, false)
	if path.size() == 0:
		pass

func _physics_process(delta):
	if path.size() > 1:
		var d = position.distance_to(path[0])
		if d > distance_threshold:
			#position.linear_interpolate(path[0], ((speed * delta)))
			position += (path[0] - position).normalized() * (speed * delta)
		else:
			path.remove(0)
	else:
		if position.distance_to(goal.position) <= attack_range and goal.is_in_group("Enemy"):
			goal.hurt(damage)