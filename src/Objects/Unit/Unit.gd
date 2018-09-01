extends Area2D

var speed = 100
var nav = null setget set_nav
var path = []
var goal = null setget set_goal

var distance_threshold = 5

var attack_range = 30 # minimum 30

var MAX_HEALTH = 50
var health = 50
var damage = 3

var shield = false setget set_shield

func set_nav(new_nav):
	nav = new_nav
	update_path()

func set_goal(new_goal):
	goal = new_goal
	update_path()

func set_shield(value):
	shield = value
	
	if shield:
		$Shield.show()
	else:
		$Shield.hide()

func initalize(_goal,_nav):
	goal = _goal
	nav = _nav

func _ready():
	$Healthbar.max_value = MAX_HEALTH
	$Healthbar.value = health

func heal(hp):
	health += hp
	if health > MAX_HEALTH:
		health = MAX_HEALTH
		$Healthbar.value = health

func hurt(dmg):
	if !shield:
		health -= dmg
	$Healthbar.value = health
	if health <= 0:
		queue_free()

func moral_boost():
	speed += 100
	$AtttackTimer.wait_time = $AtttackTimer.wait_time * 0.75

func update_path():
	$AtttackTimer.stop()
	path = nav.get_simple_path(position, goal.position, false)
	if path.size() == 0:
		pass

func _physics_process(delta):
	if position.distance_to(goal.position) <= attack_range:
		if $AtttackTimer.is_stopped():
			if goal.is_in_group("Enemy"):
				goal.hurt(damage)
			$AtttackTimer.start()
		return
	if path.size() > 1:
		var d = position.distance_to(path[0])
		if d > distance_threshold:
			#position.linear_interpolate(path[0], ((speed * delta)))
			position += (path[0] - position).normalized() * (speed * delta)
		else:
			path.remove(0)
	else:
		pass

func _on_AtttackTimer_timeout():
	if goal.is_in_group("Enemy") and position.distance_to(goal.position) <= attack_range:
		goal.hurt(damage)
	$AtttackTimer.start()
