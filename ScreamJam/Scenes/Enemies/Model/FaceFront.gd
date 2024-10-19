extends Node3D


func _process(delta: float) -> void:
	global_rotation.y = get_viewport().get_camera_3d().global_rotation.y
