extends Node3D


@export var sceneToSpawn: PackedScene

func _ready() -> void:
	EventBus.playerInNoGridMode.connect(spawn)
	
func spawn():
	var newEntity = sceneToSpawn.instantiate()
	newEntity.position = global_position
	
	Global.map.add_child(newEntity)
	queue_free()
