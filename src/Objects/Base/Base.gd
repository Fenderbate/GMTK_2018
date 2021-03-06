extends Area2D

signal victory

export var health = 100

var base_captured = false

var targets = []

var damage = 0.075

var captured = false

func _ready():
	
	connect("victory", get_parent(), "victory")
	

func _physics_process(delta):
	
	if !base_captured:
		for t in targets:
			t.hurt(damage)

func hurt(dmg):
	health -= dmg
	if health <= 0 and !base_captured:
		for t in get_parent().get_node("Towers").get_children():
			if !t.captured:
				t.captured = true
		print("Victory... Implement stuff here (On Base.gd)")
		base_captured = true
		captured = true
		emit_signal("victory")
		pass

func _on_Defense_area_entered(area):
	targets.append(area)


func _on_Defense_area_exited(area):
	targets.erase(area)
