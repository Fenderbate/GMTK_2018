extends Area2D

var fireball = preload("res://src/Objects/Fireball/Fireball.tscn")

var speed = 100
var nav = null setget set_nav
var path = []
var goal = null setget set_goal

var distance_threshold = 5

var attack_range = 40 # minimum 40

var MAX_HEALTH = 6
var health = 6
var damage = 3
var ranged = false

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
	$HPPivot/Healthbar.max_value = MAX_HEALTH
	$HPPivot/Healthbar.value = health

func heal(hp):
	health += hp
	if health > MAX_HEALTH:
		health = MAX_HEALTH
	$HPPivot/Healthbar.value = health

func hurt(dmg):
	if !shield:
		health -= dmg
	$HPPivot/Healthbar.value = health
	if health <= 0:
		queue_free()

func shoot():
	var f = fireball.instance()
	f.global_position = $Sprite/AttackPivot.global_position
	f.target_pos = goal.position
	get_parent().get_parent().add_child(f)

func hit():
	if goal.is_in_group("Enemy"):
		goal.hurt(damage)

func moral_boost():
	speed += 100
	$Animation.playback_speed = 2
	$Sprite.self_modulate = Color(1,0.5,0.5,1)

func update_path():
	if goal != null:
		path = nav.get_simple_path(position, goal.position, false)
	else:
		update_path()
	if path.size() == 0:
		pass

func _physics_process(delta):
	if position.distance_to(goal.position) <= attack_range:
		
		if (goal.position - position).normalized().x > 0:
			$Sprite.scale.x = 1
		else:
			$Sprite.scale.x = -1
		
		if ranged:
			if $Animation.current_animation != "Gandalf Attack": $Animation.play("Gandalf Attack")
		else:
			if $Animation.current_animation != "Mele Attack": $Animation.play("Mele Attack")
		return
		
	if path.size() > 1:
		
		if ranged:
			if $Animation.current_animation != "Gandalf Walk": $Animation.play("Gandalf Walk")
		else:
			if $Animation.current_animation != "Mele Walk": $Animation.play("Mele Walk")
		
		var d = position.distance_to(path[0])
		if d > distance_threshold:
			#position.linear_interpolate(path[0], ((speed * delta)))
			position += (path[0] - position).normalized() * (speed * delta)
			if (path[0] - position).normalized().x > 0:
				$Sprite.scale.x = 1
			else:
				$Sprite.scale.x = -1
		else:
			path.remove(0)
	else:
		pass
