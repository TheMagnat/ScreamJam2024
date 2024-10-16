class_name CameraRotationRestrictor extends Node

@onready var character: BetterCharacterController = get_parent()
@onready var camera: Camera3D = get_parent().get_node("Head/Camera")
@onready var head: Node3D = get_parent().get_node("Head")


@export var rotationTime: float = 0.5
var rotationTween: Tween
var goalRotation: float = 0.0
var lockCamera: bool = false

func resetCamera():
	head.rotation_degrees = Vector3.ZERO

func updateHeadRotation(newOffset: float):
	if rotationTween: rotationTween.kill()
	goalRotation -= newOffset * PI / 2.0
	
	rotationTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	rotationTween.tween_property(head, "rotation:y", goalRotation, rotationTime)

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("RotateLeft"):
		updateHeadRotation(-1)
		
	if event.is_action_pressed("RotateRight"):
		updateHeadRotation(1)
	
	if event.is_action_pressed("debug1"):
		lockCamera = not lockCamera
		character.lockedCamera = lockCamera
		if lockCamera:
			resetCamera()
