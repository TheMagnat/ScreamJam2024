class_name HypnotizeNode extends Node3D


@onready var quanticNode: QuanticNode = $"../QuanticNode"
@onready var player: Character = Global.player

var locked: bool = false
func _physics_process(_delta: float) -> void:
	if quanticNode.isWatching:
		if not locked:
			lock()
	elif locked:
		unlock()

func _process(_delta: float) -> void:
	if locked:
		player.HEAD.global_transform = player.HEAD.global_transform.interpolate_with(player.HEAD.global_transform.looking_at(global_position), 0.01)

var originalRot: Vector3
func lock():
	locked = true
	player.locked = true
	originalRot = player.HEAD.rotation

func unlock():
	locked = false
	player.locked = false
	
	if player.lockedCamera:
		player.HEAD.rotation = originalRot
