extends Node

@onready var character: BetterCharacterController = $".."
@onready var map: Map = $"../../Map"
@onready var gridSpace: float = map.gridSpace 

@onready var cameraRotationRestrictor: CameraRotationRestrictor = $"../CameraRotationRestrictor"

# DEBUG
@onready var debugPanel: DebugPanel = $"../UserInterface/DebugPanel"


@export var lockInGrid: bool = false
var currentPosition: Vector3 = Vector3.ZERO
var goalPosition: Vector3i = Vector3i.ZERO
var inMovement: bool = false


func resetPosition():
	currentPosition = character.position

func _physics_process(delta: float) -> void:
	if lockInGrid:
		if not inMovement:
			var directionVector: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
			if directionVector != Vector2.ZERO:
				
				if directionVector.x > 0 and directionVector.y > 0:
					directionVector.x = round(directionVector.x)
					directionVector.y = 0
				
				if cameraRotationRestrictor.lockCamera:
					directionVector = directionVector.rotated(2*PI -  cameraRotationRestrictor.goalRotation )
				
				goalPosition.x += round(directionVector.x)
				goalPosition.z += round(directionVector.y)
				
				inMovement = true
		
		if inMovement:
			var positionNoY: Vector3 = character.position
			positionNoY.y = 0
			
			var trueGoalPosition: Vector3 = goalPosition * gridSpace
			
			var directionToGoal: Vector3 = positionNoY.direction_to(trueGoalPosition)
			character.handled_input = Vector2(directionToGoal.x, directionToGoal.z)
			#character.handle_movement(delta, Vector2(directionToGoal.x, directionToGoal.z))
			
			if Debug.debug:
				debugPanel.add_property("Direction", directionToGoal, 7)
				debugPanel.add_property("Distance to Goal", trueGoalPosition.distance_to(positionNoY), 8)
				
			if trueGoalPosition.distance_to(positionNoY) < 0.1:
				inMovement = false
				character.handled_input = Vector2.ZERO
				
	if Debug.debug:
		debugPanel.add_property("InMovement", inMovement, 4)
		debugPanel.add_property("Current Position", character.position, 5)
		debugPanel.add_property("Goal Position", goalPosition * gridSpace, 6)
		
		
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug2"):
		lockInGrid = not lockInGrid
		character.immobile = lockInGrid
		character.handled = lockInGrid
		if lockInGrid:
			resetPosition()
