extends Node3D


@export var minDistance: float = 8.0

func _physics_process(delta: float) -> void:
	if global_position.distance_to(Global.player.global_position) < minDistance:
		queue_free()
