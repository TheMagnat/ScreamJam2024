class_name GridRestrictor extends Node

@onready var character: Character = $".."
@onready var map: Map = get_parent().map

@onready var gridSpace: float = map.gridSpace

@onready var cameraRotationRestrictor: CameraRotationRestrictor = $"../CameraRotationRestrictor"

# DEBUG
@onready var debugPanel: DebugPanel = $"../InterfaceLayer/UserInterface/DebugPanel"

@export var gridToken: GridToken
var inMovement: bool = false
var reachedGoal: bool = false

@export var rotateCameraOnMove: bool = false

# Deactivated grid variables
var timeToStep: Timer
@export var stepDelay: float = 1.0:
	set(value):
		stepDelay = value
		if timeToStep:
			timeToStep.wait_time = stepDelay

func _ready() -> void:
	timeToStep = Timer.new()
	timeToStep.wait_time = stepDelay
	timeToStep.timeout.connect(onStepTimerTimeout)
	add_child(timeToStep)
	
	#TODO: Si on sauvegarde la progression, ici mettre à faux si on veut ne plus le mettre sur la grille au chargement
	gridToken.map = map

func onStepTimerTimeout():
	EventBus.playerGridStep.emit()

func activate():
	gridToken.isFree = false
	
	cameraRotationRestrictor.activate()
	
	character.immobile = true
	character.handled = true
	
	gridToken.setInitialPosition()
	inMovement = true
	
	timeToStep.stop()

func deactivate():
	character.immobile = false
	character.handled = false
	
	timeToStep.start()
	

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
				
				if map.isAvailable( goal2dPosition ) and GridEntityManager.isAvailable( goal2dPosition ):
					if rotateCameraOnMove and cameraRotationRestrictor.lockCamera:
						cameraRotationRestrictor.goalRotation = - PI / 2.0 - directionVector.angle()
						cameraRotationRestrictor.updateHeadRotation()
					
					gridToken.goalPosition = goal2dPosition
					
					inMovement = true
					reachedGoal = false
					
					EventBus.playerGridStep.emit()
			
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
		debugPanel.add_property("Goal Grid Pos", (gridToken.goalWorldPosition / map.gridSpace).round(), 6)
		
		
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Idle"):
		if EventBus.gridStepDelay.is_stopped():
			EventBus.playerGridStep.emit()
	
	if event.is_action_pressed("debug2"):
		gridToken.isFree = not gridToken.isFree
		if not gridToken.isFree:
			activate()
		else:
			deactivate()
