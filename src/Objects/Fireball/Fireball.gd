extends Area2D

var target_pos = Vector2()

var speed = 200

var damage = 2

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _physics_process(delta):
	
	position += (target_pos - position).normalized() * (speed * delta)


func _on_Fireball_area_entered(area):
	area.hurt(damage)
	queue_free()
