extends MeshInstance3D


func _process(delta: float) -> void:
	global_rotation = Vector3.ZERO
	global_position.y = 0.5
