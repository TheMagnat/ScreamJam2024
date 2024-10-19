extends Sprite3D

@onready var quanticNode: QuanticNode = $"../QuanticNode"

@export var startSpeed: float = 0.0
@export var speedIncrement: float = 5.0

@onready var currentSpeed: float = startSpeed



func _process(delta: float) -> void:
	if quanticNode.isWatching:
		currentSpeed += speedIncrement * delta
	else:
		currentSpeed = startSpeed
	
	rotation.z += delta * currentSpeed;
