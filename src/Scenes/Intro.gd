extends Node

var index = 0

func _ready():
	$AnimationPlayer.play("ScrollUp")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	
	index += 1
	if $AnimationPlayer.has_animation(str(index)):
		$Next.show()


func _on_Next_button_down():
	
	if $AnimationPlayer.has_animation(str(index)):
		$AnimationPlayer.play(str(index))
		$Next.hide()


func _on_Skip_button_down():
	get_tree().change_scene("res://src/Scenes/World.tscn")


func _on_Start_button_down():
	get_tree().change_scene("res://src/Scenes/World.tscn")
