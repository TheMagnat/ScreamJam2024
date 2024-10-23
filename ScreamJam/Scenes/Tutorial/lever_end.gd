extends Node3D

signal finished

func _ready():
	$AnimationPlayer.animation_finished.connect(finish)

func finish(_anim_name: String):
	finished.emit()
	$AudioStreamPlayer.play()

func _process(_delta: float):
	$Label.hide()
	for body in $Area3D.get_overlapping_bodies():
		if body == Global.player:
			$Label.show()
			$Label.global_position = get_viewport().get_camera_3d().unproject_position(global_position) - Vector2($Label.size.x * 0.5, -256)
			return

var ending := false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Action"):
		for body in $Area3D.get_overlapping_bodies():
			if body == Global.player:
				ending = true
				$AnimationPlayer.play("leverUse")
				return
