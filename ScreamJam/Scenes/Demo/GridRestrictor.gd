class_name GridRestrictor extends Node

@onready var character: BetterCharacterController = $".."
@onready var map: Map = $"../../Map"
@onready var gridSpace: float = map.gridSpace 

@onready var cameraRotationRestrictor: CameraRotationRestrictor = $"../CameraRotationRestrictor"

# DEBUG
@onready var debugPanel: DebugPanel = $"../InterfaceLayer/UserInterface/DebugPanel"


@export var lockInGrid: bool = false
var goalPosition: Vector3i = Vector3i.ZERO
var inMovement: bool = false
var reachedGoal: bool = false

@export var rotateCameraOnMove: bool = false


func activate():
	lockInGrid = true
	
	cameraRotationRestrictor.activate()
	
	character.immobile = true
	character.handled = true
	
	goalPosition = (character.position / gridSpace).round()
	inMovement = true

func _physics_process(delta: float) -> void:
	if lockInGrid:
		if not inMovement or reachedGoal:
			var directionVector: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
			if directionVector != Vector2.ZERO:
				
				if directionVector.x != 0 and directionVector.y != 0:
					directionVector.y = round(directionVector.y)
					directionVector.x = 0
				
				#TODO: ça c'est peut être impossible de l'avoir à faux ici
				if cameraRotationRestrictor.lockCamera:
					directionVector = directionVector.rotated(2 * PI - cameraRotationRestrictor.goalRotation )
				
				var goal2dPosition := Vector2i(goalPosition.x + round(directionVector.x), goalPosition.z + round(directionVector.y))
				
				if map.isAvailable(goal2dPosition):
					if rotateCameraOnMove and cameraRotationRestrictor.lockCamera:
						cameraRotationRestrictor.goalRotation = - PI / 2.0 - directionVector.angle()
						cameraRotationRestrictor.updateHeadRotation()
					
					goalPosition.x = goal2dPosition.x
					goalPosition.z = goal2dPosition.y
					
					inMovement = true
					reachedGoal = false
			
			if reachedGoal:
				reachedGoal = false
				inMovement = false
				character.handled_input = Vector2.ZERO
				character.handled_sprint = false
		
		if inMovement:
			var positionNoY: Vector3 = character.position
			positionNoY.y = 0
			
			var trueGoalPosition: Vector3 = goalPosition * gridSpace
			
			var directionToGoal: Vector3 = positionNoY.direction_to(trueGoalPosition)
			character.handled_input = Vector2(directionToGoal.x, directionToGoal.z)
			character.handled_sprint = true
			#character.handle_movement(delta, Vector2(directionToGoal.x, directionToGoal.z))
			
			if Debug.debug:
				debugPanel.add_property("Direction", directionToGoal, 7)
				debugPanel.add_property("Distance to Goal", trueGoalPosition.distance_to(positionNoY), 8)
				
			if trueGoalPosition.distance_to(positionNoY) < 0.1:
				reachedGoal = true
				
	if Debug.debug:
		debugPanel.add_property("InMovement", inMovement, 4)
		debugPanel.add_property("Current Position", character.position, 5)
		debugPanel.add_property("Goal Position", goalPosition * gridSpace, 6)
		
		
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug2"):
		lockInGrid = not lockInGrid
		if lockInGrid:
			activate()
		else:
			character.immobile = false
			character.handled = false
