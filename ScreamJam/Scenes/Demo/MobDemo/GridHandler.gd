class_name GridHandler extends Node


@onready var parent: GridEntity = $".."
@export var target: Node3D

@onready var navigationAgent: NavigationAgent3D = $"../NavigationAgent3D"

# TODO: set dynamiquement
@onready var map: Map = $"../../NavigationRegion3D/Map"

## Parameters ##
@export var stepToMove: int = 2
@onready var currentStepCounter: int = stepToMove

# Grid positions
@onready var gridToken: GridToken = $"../GridToken"

func _ready() -> void:
	gridToken.setInitialPosition()

func step() -> void:
	currentStepCounter -= 1
	
	if currentStepCounter == 0:
		currentStepCounter = stepToMove
		if not target:
			walkRandomDirection()
		else:
			walkTargetDirection()

func walkRandomDirection() -> void:
	pass

func walkTargetDirection() -> void:
	var targetPosition: Vector3
	var targetGridToken: GridToken = target.get_node("GridToken")
	if targetGridToken.isFree:
		targetPosition = target.global_position
	else:
		targetPosition = targetGridToken.goalWorldPosition
	
	navigationAgent.target_position = targetPosition
	var directionToTarget: Vector3 = parent.global_position.direction_to( navigationAgent.get_next_path_position() )
	
	var xFirst: bool = abs(directionToTarget.x) > abs(directionToTarget.z)
	for i in 2:
		var directionToTest: Vector2i
		directionToTest = Vector2i(sign(directionToTarget.x), 0) if xFirst else Vector2i(0, sign(directionToTarget.z))
		xFirst = not xFirst
		
		var newGoalPosition: Vector2i = gridToken.goalPosition
		newGoalPosition.x += directionToTest.x
		newGoalPosition.y += directionToTest.y
		
		if map.isAvailable( newGoalPosition ) and parent.gridEntityManager.isAvailable( newGoalPosition ):
			
			if target.get_node("GridToken").goalPosition == newGoalPosition:
				attack(target.global_position)
			else:
				gridToken.goalPosition = newGoalPosition
			
			break

var inAttackAnimation: bool = false
var attackTween: Tween
func attack(attackPosition: Vector3):
	inAttackAnimation = true
	
	print("ATTACK")
	if attackTween: attackTween.kill()
	attackTween = create_tween()
	attackTween.tween_property(parent, "global_position", attackPosition, 0.25)
	attackTween.tween_property(parent, "global_position", gridToken.goalWorldPosition, 0.25)
	attackTween.tween_property(self, "inAttackAnimation", false, 0.0)

func _physics_process(delta: float) -> void:
	if inAttackAnimation: return
	
	parent.velocity = parent.global_position.direction_to(gridToken.goalWorldPosition) * parent.SPEED * delta
	parent.move_and_slide()
