class_name CameraRotationRestrictor extends Node

@onready var character: Character = get_parent()
@onready var camera: Camera3D = get_parent().get_node("Head/Camera")
@onready var head: Node3D = get_parent().get_node("Head")

@onready var gridRestrictor: GridRestrictor = $"../GridRestrictor"

@export var rotationTime: float = 0.5
var rotationTween: Tween
var goalRotation: float = 0.0
var lockCamera: bool = false

func activate():
	lockCamera = true
	character.lockedCamera = true
	
	if rotationTween: rotationTween.kill()
	rotationTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	rotationTween.tween_property(head, "rotation", Vector3(0.0, goalRotation, 0.0), rotationTime)

func updateGoalRotation(newOffset: float):
	if not character.locked:
		goalRotation -= newOffset * PI / 2.0
		updateHeadRotation()
	
func updateHeadRotation():
	if rotationTween: rotationTween.kill()
	rotationTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	#rotationTween.tween_property(head, "rotation:y", goalRotation, rotationTime)
	var originalRotation: float = head.rotation.y
	rotationTween.tween_method(func(current: float): head.rotation.y = lerp_angle(originalRotation, goalRotation, current), 0.0, 1.0, rotationTime)
	
func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("RotateLeft"):
		updateGoalRotation(-1)
		
	if event.is_action_pressed("RotateRight"):
		updateGoalRotation(1)
	
	if event.is_action_pressed("debug1"):
		lockCamera = not lockCamera
		
		# Can't unlock camera if grid is locked
		if not gridRestrictor.gridToken.isFree: lockCamera = true
		
		if lockCamera:
			activate()
		else:
			character.lockedCamera = false
