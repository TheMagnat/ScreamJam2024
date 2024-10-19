class_name SanityAttacker extends Node3D

@export var goalDmgs: float = 50.0
@export var sanityDmgPerSec: float = 20.0
@onready var quanticNode: QuanticNode = $"../QuanticNode"


func _physics_process(delta: float) -> void:
	if quanticNode.isWatching:
		quanticNode.target.damageSanity(sanityDmgPerSec * delta)

func setTrueDmgs():
	sanityDmgPerSec = goalDmgs
