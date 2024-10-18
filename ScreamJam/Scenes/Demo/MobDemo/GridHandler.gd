class_name GridHandler extends Node


@onready var parent: GridEntity = $".."
@export var target: Node3D:
	set(value):
		target = value
		if target:
			updateTargetKnownPosition()
	
var lastTargetPositionIsOk: bool = false
var lastTargetGoalPosition: Vector2i
var lastTargetGoalWorldPosition: Vector3

@onready var navigationAgent: NavigationAgent3D = $"../NavigationAgent3D"

# TODO: set dynamiquement
@onready var map: Map = get_parent().map

## Parameters ##
@export var stepToMove: int = 2
@onready var currentStepCounter: int = stepToMove

@onready var idleToMove: int = 2
@onready var currentIdleCounter: int = idleToMove


# Grid positions
@onready var gridToken: GridToken = $"../GridToken"

func _ready() -> void:
	gridToken.map = map
	gridToken.setInitialPosition()

func step() -> void:
	currentStepCounter -= 1
	
	if currentStepCounter == 0:
		currentStepCounter = stepToMove
		if target:
			updateTargetKnownPosition()
			walkToLastTarget()
			return
		
		elif lastTargetPositionIsOk:
			walkToLastTarget()
			
			if lastTargetGoalPosition == gridToken.goalPosition:
				lastTargetPositionIsOk = false
				print("Reached last target known position")
			
			return
		
		currentIdleCounter -= 1
		if currentIdleCounter == 0:
			currentIdleCounter = idleToMove
			walkRandomDirection()
		else:
			print("Idle")

func walkRandomDirection() -> void:
	var neighbors: Array[Vector2i] = map.getNeighbors(gridToken.goalPosition)
	
	var trueNeighbors: Array[Vector2i]
	for neighbor in neighbors:
		if GridEntityManager.isAvailable( neighbor ):
			trueNeighbors.push_back( neighbor )
	
	if trueNeighbors.is_empty():
		print("No Neighbor possible, rest")
		return
	
	gridToken.goalPosition = trueNeighbors[ randi_range(0, trueNeighbors.size() - 1) ]

func updateTargetKnownPosition() -> void:
	var targetGridToken: GridToken = target.get_node("GridToken")
	
	if targetGridToken.isFree:
		lastTargetGoalWorldPosition = target.global_position
		
		var temporary3iPosition: Vector3i = (lastTargetGoalWorldPosition / map.gridSpace).round()
		lastTargetGoalPosition = Vector2i(temporary3iPosition.x, temporary3iPosition.z)
		
	else:
		lastTargetGoalWorldPosition = targetGridToken.goalWorldPosition
		lastTargetGoalPosition = targetGridToken.goalPosition
	
	lastTargetPositionIsOk = true

func walkToLastTarget():
	
	# Special case if target is on our cell
	if gridToken.goalPosition == lastTargetGoalPosition:
		if target:
			parent.attack(target, gridToken.goalWorldPosition)
		
		return
	
	navigationAgent.target_position = lastTargetGoalWorldPosition
	var directionToTarget: Vector3 = parent.global_position.direction_to( navigationAgent.get_next_path_position() )
	
	var xFirst: bool = abs(directionToTarget.x) > abs(directionToTarget.z)
	for i in 2:
		var directionToTest: Vector2i
		directionToTest = Vector2i(sign(directionToTarget.x), 0) if xFirst else Vector2i(0, sign(directionToTarget.z))
		xFirst = not xFirst
		
		var newGoalPosition: Vector2i = gridToken.goalPosition
		newGoalPosition.x += directionToTest.x
		newGoalPosition.y += directionToTest.y
		
		if map.isAvailable( newGoalPosition ) and GridEntityManager.isAvailable( newGoalPosition ):
			
			if target and lastTargetGoalPosition == newGoalPosition:
				parent.attack(target, gridToken.goalWorldPosition)
			else:
				gridToken.goalPosition = newGoalPosition
			
			break

func _physics_process(delta: float) -> void:
	if parent.inAttackAnimation: return
	
	#var velocity: Vector3 = parent.global_position.direction_to(gridToken.goalWorldPosition) * parent.SPEED * delta
	parent.global_position = parent.global_position.lerp(gridToken.goalWorldPosition, 0.5 * parent.SPEED * delta)
