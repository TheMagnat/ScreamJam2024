class_name GridRestrictor extends Node

@onready var character: Character = $".."

@onready var gridSpace: float = Global.map.gridSpace

@onready var cameraRotationRestrictor: CameraRotationRestrictor = $"../CameraRotationRestrictor"

# DEBUG
@onready var debugPanel: DebugPanel = $"../InterfaceLayer/UserInterface/DebugPanel"

@export var gridToken: GridToken
var inMovement: bool = false
var reachedGoal: bool = false

@export var rotateCameraOnMove: bool = false

# Deactivated grid variables
var timeToStep: Timer
var gridStepDelay: float = 3.0
var freeStepDelay: float = 1.0

func _ready() -> void:
	timeToStep = Timer.new()
	timeToStep.wait_time = gridStepDelay
	timeToStep.timeout.connect(onStepTimerTimeout)
	add_child(timeToStep)
	
	timeToStep.start()

func shouldEmitStep():
	timeToStep.start()
	EventBus.playerGridStep.emit()
	
func onStepTimerTimeout():
	EventBus.playerGridStep.emit()

func activate():
	gridToken.isFree = false
	
	cameraRotationRestrictor.activate()
	
	character.immobile = true
	character.handled = true
	
	gridToken.setInitialPosition()
	inMovement = true
	
	timeToStep.wait_time = gridStepDelay

func deactivate():
	gridToken.isFree = true
	
	cameraRotationRestrictor.deactivate()
	
	character.immobile = false
	character.handled = false
	
	timeToStep.wait_time = freeStepDelay

func getFrontPosition() -> Vector2i:
	return gridToken.goalPosition + Vector2i(Vector2(0, -1.0).rotated(2 * PI - cameraRotationRestrictor.goalRotation ).round())

func _physics_process(_delta: float) -> void:
	if not gridToken.isFree:
		if (not inMovement or reachedGoal) and not character.locked:
			var directionVector: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
			if directionVector != Vector2.ZERO:
				
				if directionVector.x != 0 and directionVector.y != 0:
					directionVector.y = round(directionVector.y)
					directionVector.x = 0
				
				#TODO: ça c'est peut être impossible de l'avoir à faux ici
				if cameraRotationRestrictor.lockCamera:
					directionVector = directionVector.rotated(2 * PI - cameraRotationRestrictor.goalRotation )
				
				var goal2dPosition = gridToken.goalPosition + Vector2i(directionVector.round())
				
				if Global.map.isAvailable( goal2dPosition ) and GridEntityManager.isAvailable( goal2dPosition ):
					if rotateCameraOnMove and cameraRotationRestrictor.lockCamera:
						cameraRotationRestrictor.goalRotation = - PI / 2.0 - directionVector.angle()
						cameraRotationRestrictor.updateHeadRotation()
					
					gridToken.goalPosition = goal2dPosition
					
					inMovement = true
					reachedGoal = false
					
					shouldEmitStep()
			
			if reachedGoal:
				reachedGoal = false
				inMovement = false
				character.handled_input = Vector2.ZERO
				character.handled_sprint = false
		
		# Verify distance to goal
		var positionNoY: Vector3 = character.position
		positionNoY.y = 0
		if gridToken.goalWorldPosition.distance_to(positionNoY) >= 0.5:
			inMovement = true
		else:
			reachedGoal = true
		
		if inMovement:
			var directionToGoal: Vector3 = positionNoY.direction_to(gridToken.goalWorldPosition)
			character.handled_input = Vector2(directionToGoal.x, directionToGoal.z)
			character.handled_sprint = true
			#character.handle_movement(delta, Vector2(directionToGoal.x, directionToGoal.z))
			
			if Global.debug:
				debugPanel.add_property("Direction", directionToGoal, 7)
				debugPanel.add_property("Distance to Goal", gridToken.goalWorldPosition.distance_to(positionNoY), 8)
				
			#if gridToken.goalWorldPosition.distance_to(positionNoY) < 0.1:
				#reachedGoal = true
			
	if Global.debug:
		debugPanel.add_property("InMovement", inMovement, 4)
		debugPanel.add_property("Current Position", character.position, 5)
		debugPanel.add_property("Goal Position", gridToken.goalWorldPosition, 6)
		debugPanel.add_property("Current Grid Pos", gridToken.goalPosition, 5)
		debugPanel.add_property("Goal Grid Pos", (gridToken.goalWorldPosition / Global.map.gridSpace).round(), 6)
		
func _input(event: InputEvent) -> void:
	if Global.debug:
		if event.is_action_pressed("debug2"):
			gridToken.isFree = not gridToken.isFree
			if not gridToken.isFree:
				activate()
			else:
				deactivate()
