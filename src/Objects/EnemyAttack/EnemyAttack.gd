extends Area2D

var target_pos = null

var speed = 200

var targets = []

var damage = 1

var move = true

func _ready():
	$Arrows/Sprite.look_at(target_pos)
	for a in $Arrows.get_children():
		a.rotation = $Arrows/Sprite.rotation

func _physics_process(delta):
	
	if move:
		position += (target_pos - position).normalized() * (speed * delta)
	
	if position.distance_to(target_pos) < 10:
		move = false
		for t in targets:
			t.hurt(damage)
		queue_free()

func _on_EnemyAttack_area_entered(area):
	targets.append(area)


func _on_EnemyAttack_area_exited(area):
	targets.erase(area)
