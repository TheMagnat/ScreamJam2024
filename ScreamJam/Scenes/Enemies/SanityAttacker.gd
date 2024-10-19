extends Node3D

@export var sanityDmgPerSec: float = 50.0
@onready var quanticNode: QuanticNode = $"../QuanticNode"


func _physics_process(delta: float) -> void:
	if quanticNode.isWatching:
		quanticNode.target.damageSanity(sanityDmgPerSec * delta)
