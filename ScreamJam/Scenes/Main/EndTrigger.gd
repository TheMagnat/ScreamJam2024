extends Area3D


func _ready() -> void:
	body_entered.connect(startEnd)

func startEnd(body: Node3D):
	await get_tree().create_timer(5.0).timeout
	Global.player.blink(true)
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_packed(preload("res://Scenes/Tutorial/tutorialEnd.tscn"))
