class_name Eye extends Node3D


@export var oneShot: bool = false
@onready var quanticNode: QuanticNode = $QuanticNode

func _ready() -> void:
	quanticNode.oneShot = oneShot

func _process(_delta: float) -> void:
	global_rotation.y = get_viewport().get_camera_3d().global_rotation.y
	
