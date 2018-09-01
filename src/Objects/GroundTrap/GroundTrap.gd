extends Area2D

var targets = []

export var damage = 0.01

export var effect_area = Vector2(16,16)

func _ready():
	$ColorRect.hide()
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.extents = effect_area

func _physics_process(delta):
	for t in targets:
		t.hurt(damage)


func _on_GroundTrap_area_entered(area):
	targets.append(area)


func _on_GroundTrap_area_exited(area):
	targets.erase(area)
