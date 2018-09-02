extends Area2D

signal captured(instance)
signal tower_select(instance)

var projectile = preload("res://src/Objects/EnemyAttack/EnemyAttack.tscn")

var target = null

var target_arr = []

var damage = 1
var attack_speed = 1 # in seconds
var health = 10
export var captured = false setget set_captured
export var targetable = true

var heal_amount = 0.01

var upgrade = null setget set_upgrade

var selected = false

func set_upgrade(value):
	upgrade = value
	
	match upgrade:
		0:
			pass
		1:
			
			$ShootTimer.wait_time = 0.5
			$Range/Area.shape = CircleShape2D.new()
			$Range/Area.shape.radius = 250
			$Sprite.region_rect = Rect2(64,448,64,64)
		2:
			$ShootTimer.wait_time = 0.01
			$Range/Area.shape = CircleShape2D.new()
			$Range/Area.shape.radius = 300
			$ShieldTimer.start()
			$Sprite.region_rect = Rect2(0,448,64,64)
		null:
				pass

func _ready():
	
	connect("captured", get_tree().root.get_node("World"), "target_captured")
	connect("tower_select", get_tree().root.get_node("World"), "menu_select_changed")
	$Healthbar.max_value = health
	$Healthbar.value = health
	
	if captured:
		emit_signal("captured", self)
	

func set_captured(value):
	captured = value
	if captured:
		emit_signal("captured", self)

func _physics_process(delta):
	if captured and upgrade == 1:
		if target != null:
			heal(target)
		for t in target_arr:
			heal(t)
	
	update()

func _draw():
	if selected:
		draw_empty_circle(Vector2(),Vector2(1,1).normalized() * $Range/Area.shape.radius,Color(1,1,1,1),1)

func draw_empty_circle(circle_center, circle_radius, color, resolution):
	var draw_counter = 1
	var line_origin = Vector2()
	var line_end = Vector2()
	line_origin = circle_radius + circle_center
	
	while draw_counter <= 360:
		line_end = circle_radius.rotated(deg2rad(draw_counter)) + circle_center
		draw_line(line_origin, line_end, color)
		draw_counter += 1 / resolution
		line_origin = line_end
	
	line_end = circle_radius.rotated(deg2rad(360)) + circle_center
	draw_line(line_origin, line_end, color)
	
func hurt(damage):
	health -= damage
	$Healthbar.value = health
	if health <= 0:
		self.captured = true
		

func shoot(projectile_target):
	var p = projectile.instance()
	p.position = $ShootingPivot.global_position
	p.target_pos = projectile_target.position
	get_tree().root.get_node("World").add_child(p)
	#projectile_target.hurt(damage)

func heal(heal_target):
	heal_target.heal(heal_amount)

func fortify():
	match upgrade:
		0:
			pass
		1:
			heal_amount = heal_amount * 2
		2:
			$ShieldTimer.start()

func _on_ShootTimer_timeout():
	if target == null:
		if target_arr.size() > 0:
			target = target_arr.pop_front()
		else:
			return
	
	if !captured:
		
		shoot(target)
	else:
		match upgrade:
			0:
				pass
			1:
#				heal(target)
#				for t in target_arr:
#					heal(t)
				pass
			2:
				target.shield = true
				for t in target_arr:
					t.shield = true
	
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
	
	if captured and upgrade == 2:
		area.shield = true


func _on_Range_area_exited(area):
	if target == area:
		target = null
	else:
		if !target_arr.has(area):
			print("somehow, ", self.name, " doesn't have ", area.name, " as target.")
			modulate = Color(1, 0, 0, 1)
		else:
			target_arr.remove(target_arr.find(area))
	
	if captured and upgrade == 2:
		area.shield = false
	

func _on_Select_button_down():
	if captured:
		emit_signal("tower_select", self)
	else:
		print("not captured yet!")


func _on_ShieldTimer_timeout():
	for u in get_tree().root.get_node("World/Units").get_children():
		if u.shield:
			u.shield = false
	self.upgrade = null
	$Sprite.region_rect = Rect2(0,0,64,64)
