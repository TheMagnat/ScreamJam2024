extends Node3D


@onready var originalPosition: Vector3 = position

var elapsedTime: float = 0.0
func _process(delta: float) -> void:
	elapsedTime += delta
	
	position = originalPosition + Vector3(cos(elapsedTime * 2.5 * 12.48), cos(elapsedTime * 2.5 * 14.64), sin(elapsedTime * 2.5 * 18.14)) * Global.sanity * 0.05
	
