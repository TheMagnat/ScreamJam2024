class_name Loot extends Node3D


@export var toolScene: PackedScene

var tween: Tween
func _ready() -> void:
	tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y + 0.1, 2.0)
	tween.tween_property(self, "position:y", position.y - 0.1, 2.0)

func _process(delta: float) -> void:
	global_rotation.y = get_viewport().get_camera_3d().global_rotation.y
