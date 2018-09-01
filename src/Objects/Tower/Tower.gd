extends Area2D

signal captured(instance)

var target = null

var target_arr = []

var damage = 1
var attack_speed = 1 # in seconds
var health = 10
export var captured = false

var heal_amount = 1

func _ready():
	
	connect("captured", get_tree().root.get_node("World"), "target_captured")
	$Healthbar.max_value = health
	$Healthbar.value = health
	

func _physics_process(delta):
	
	pass
	

func hurt(damage):
	health -= damage
	$Healthbar.value = health
	print(health)
	if health <= 0:
		captured = true
		emit_signal("captured", self)

func shoot(projectile_target):
	projectile_target.hurt(damage)

func heal(heal_target):
	heal_target.heal(heal_amount)

func _on_ShootTimer_timeout():
	if target == null:
		if target_arr.size() > 0:
			target = target_arr.pop_front()
		else:
			return
	
	if !captured:
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
