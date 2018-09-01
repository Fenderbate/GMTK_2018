extends Area2D

signal destroyed(instance)

var target = null

var target_arr = []

var damage = 1
var attack_speed = 1 # in seconds
var health = 100
var destroyed = false

func _ready():
	
	connect("destroyed", get_tree().root.get_node("World"), "target_destroyed")
	

func _physics_process(delta):
	
	
	update()
	

func _draw():
	
	if target != null:
		draw_line(Vector2(0,0), target.global_position - global_position,Color(1,0,0,1),3)

func hurt(damage):
	health -= damage
	print(health)
	if health <= 0:
		destroyed = true
		emit_signal("destroyed", self)

func shoot(projectile_target):
	projectile_target.hurt(damage)
	pass

func _on_ShootTimer_timeout():
	if target == null:
		if target_arr.size() > 0:
			target = target_arr.pop_front()
		else:
			return
	
	shoot(target)
	$ShootTimer.start()


func _on_Range_area_entered(area):
	if target == null:
		if target_arr.size() == 0:
			target = area
		else:
			target_arr.push_back(area)
	else:
		target_arr.push_back(area)
	
	if $ShootTimer.is_stopped():
		$ShootTimer.start()


func _on_Range_area_exited(area):
	if target == area:
		target = null
	else:
		if !target_arr.has(area):
			print("somehow, ", self.name, " doesn't have ", area.name, " as target.")
			modulate = Color(1, 0, 0, 1)
		else:
			target_arr.remove(target_arr.find(area))
