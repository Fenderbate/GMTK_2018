extends Position2D

signal victory

var health = 100

var base_captured = false

var targets = []

var damage = 0.25

func _ready():
	
	connect("victory", get_parent(), "victory")
	

func _physics_process(delta):
	
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
		emit_signal("victory")
		pass

func _on_Defense_area_entered(area):
	targets.append(area)


func _on_Defense_area_exited(area):
	targets.erase(area)
