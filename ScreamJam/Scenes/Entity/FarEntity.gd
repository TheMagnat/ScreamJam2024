extends Node3D


@export var minDistance: float = 8.5
@onready var material: ShaderMaterial = $Sprite3D.material_override

func _process(delta: float) -> void:
	var distToPlayer: float = global_position.distance_to(Global.player.global_position)
	if distToPlayer < minDistance:
		queue_free()
	
	material.set_shader_parameter("dist", clampf((distToPlayer - 8.5), 0.0, 1.0))
