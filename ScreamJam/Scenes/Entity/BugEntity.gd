class_name BugEntity extends Node3D

@onready var sprite: Sprite3D = $Sprite3D

var speed: float = 1.0
var endPos: Vector3
func startCrawling(startPos: Vector3, endPosP: Vector3, speedP: float, inverse: bool = false) -> void:
	global_position = startPos
	endPos = endPosP
	speed = speedP
	
	sprite.flip_h = inverse

const OFFSET := 0.75
func _process(delta: float) -> void:
	global_position += global_position.direction_to(endPos) * speed * delta + Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)) * OFFSET * speed * delta

	if global_position.distance_to(endPos) < 1.0:
		queue_free()
