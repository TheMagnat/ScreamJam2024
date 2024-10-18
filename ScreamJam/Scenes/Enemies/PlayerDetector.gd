extends Node3D


var target: Node3D
@export var nodeToUpdate: Node

const headOffset := Vector3.UP * 1.0


func _ready() -> void:
	target = GridEntityManager.player

func _physics_process(delta: float) -> void:
	if Engine.get_physics_frames() % 4:
		if RayHelper.castRay(global_position + headOffset, target.global_position + headOffset, 0b01):
			nodeToUpdate.target = null
		else:
			nodeToUpdate.target = target
