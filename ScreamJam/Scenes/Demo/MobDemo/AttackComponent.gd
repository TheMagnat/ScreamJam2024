@tool
extends Node3D

@export var handNode: Node3D
@onready var attackAnimation: AnimationPlayer = $"../Head/HandPosition/AttackAnimation"

# Cache
@onready var gridRestrictor: GridRestrictor = $"../GridRestrictor"

# Debug
const DAGGER_TEST = preload("res://Scenes/PlayerTools/Dagger.tscn")

func _ready() -> void:
	
	var testTool = DAGGER_TEST.instantiate()
	
	handNode.add_child(testTool)
	
	# Attack animation
	attackAnimation.animation_finished.connect(attackFinished)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Attack"):
		if not inAttackAnimation:
			attack()

var inAttackAnimation: bool = false
func attack():
	attackAnimation.play("AttackAnimation")
	inAttackAnimation = true

	if not gridRestrictor.gridToken.isFree:
		var frontPosition: Vector2i = gridRestrictor.getFrontPosition()
		var entity: GridEntity = GridEntityManager.getEntityAt(frontPosition)
		if entity:
			entity.health -= 10.0 #TODO: Utiliser les dégats du tools
	
	EventBus.playerGridStep.emit()
	
func attackFinished(event):
	inAttackAnimation = false
