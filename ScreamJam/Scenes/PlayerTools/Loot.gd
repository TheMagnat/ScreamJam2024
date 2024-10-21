class_name Loot extends Node3D


@export var toolScene: PackedScene

func _process(delta: float) -> void:
	global_rotation.y = get_viewport().get_camera_3d().global_rotation.y
