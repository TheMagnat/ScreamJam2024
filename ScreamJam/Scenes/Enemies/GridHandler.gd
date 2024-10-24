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

## Parameters ##
@export var stepToMove: int = 2
@onready var currentStepCounter: int = stepToMove

@onready var idleToMove: int = 2
@onready var currentIdleCounter: int = idleToMove


# Grid positions
@onready var gridToken: GridToken = $"../GridToken"

# To reset on player death
var initialPosition: Vector3
var stopIdle: bool = false
func _ready() -> void:
	initialPosition = parent.global_position
	reset()
	
	EventBus.playerRespawned.connect(reset)
	
func reset():
	parent.stopAttackAnimation()
	parent.global_position = initialPosition
	gridToken.setInitialPosition()
	stopIdle = false
	lastTargetPositionIsOk = false
	target = null

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
			return
		
		currentIdleCounter -= 1
		if currentIdleCounter == 0 and (stopIdle or EventBus.noGridModeTriggered):
			currentIdleCounter = idleToMove
			walkRandomDirection()


func walkRandomDirection() -> void:
	var neighbors: Array[Vector2i] = Global.map.getNeighbors(gridToken.goalPosition)
	
	var trueNeighbors: Array[Vector2i]
	for neighbor in neighbors:
		if GridEntityManager.isAvailable( neighbor ):
			trueNeighbors.push_back( neighbor )
	
	if trueNeighbors.is_empty():
		return
	
	gridToken.goalPosition = trueNeighbors[ randi_range(0, trueNeighbors.size() - 1) ]

func updateTargetKnownPosition() -> void:
	var targetGridToken: GridToken = target.get_node("GridToken")
	
	if targetGridToken.isFree:
		lastTargetGoalWorldPosition = target.global_position
		
		var temporary3iPosition: Vector3i = (lastTargetGoalWorldPosition / Global.map.gridSpace).round()
		lastTargetGoalPosition = Vector2i(temporary3iPosition.x, temporary3iPosition.z)
		
	else:
		lastTargetGoalWorldPosition = targetGridToken.goalWorldPosition
		lastTargetGoalPosition = targetGridToken.goalPosition
	
	lastTargetPositionIsOk = true
	stopIdle = true

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
		
		# If the cell exist...
		if Global.map.isAvailable( newGoalPosition ):
			# ...And if the player is on it, attack
			if target and lastTargetGoalPosition == newGoalPosition:
				
				var multiplier: float = 1.0
				if Global.player.gridToken and not Global.player.lootComponent.rightHandTool and not Global.player.gridToken.isFree:
					var neighbors: Array[Vector2i] = Global.map.getNeighbors(Global.player.gridToken.goalPosition)
					var haveNeighbor: bool = false
					for neighbor in neighbors:
						if GridEntityManager.isAvailable( neighbor ):
							haveNeighbor = true
					
					if not haveNeighbor:
						multiplier = 10.0
				
				parent.attack(target, gridToken.goalWorldPosition, multiplier)
				break
			
			# ...Or if their is no player and no other entity go on it
			if GridEntityManager.isAvailable( newGoalPosition ):
				gridToken.goalPosition = newGoalPosition
				break

func _physics_process(delta: float) -> void:
	if parent.inAttackAnimation: return
	
	#var velocity: Vector3 = parent.global_position.direction_to(gridToken.goalWorldPosition) * parent.SPEED * delta
	parent.global_position = parent.global_position.lerp(gridToken.goalWorldPosition, 0.5 * parent.SPEED * delta)
