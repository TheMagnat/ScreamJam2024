class_name LootComponent extends Node3D


@onready var frontArea: Area3D = $"../Head/FrontRangeArea"

@onready var rightHand: Marker3D = $"../Head/RightHandPosition"
var rightHandTool: Node3D = null

@onready var leftHand: Marker3D = $"../Head/LeftHandPosition"
var leftHandTool: Node3D = null

func tryLoot(left: bool) -> bool:
	if nearestLoot:
		take(nearestLoot, left)
		return true
	
	return false

var takeTween: Tween
func take(loot: Loot, left: bool):
	var oldTool: Node3D = null
	if not left:
		oldTool = rightHandTool
		if rightHandTool:
			rightHandTool = null
		
	else:
		oldTool = leftHandTool
		if leftHandTool:
			leftHandTool = null
	
	if oldTool:
		#TODO: drop l'item a la place de l'autre
		pass
		oldTool.queue_free()
	
	var newTool = loot.toolScene.instantiate()
	
	if not left:
		rightHandTool = newTool
		rightHand.add_child(newTool)
	else:
		leftHandTool = newTool
		leftHand.add_child(newTool)
	
	newTool.global_transform = loot.global_transform
	loot.queue_free()
	
	if takeTween: takeTween.kill()
	takeTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	takeTween.tween_property(newTool, "transform", Transform3D(), 0.25)


var nearestLoot: Loot = null

@onready var indicator: Label = $Label
func _process(delta: float) -> void:
	var bestBody: Node3D = null
	var bestBodyDist: float = INF
	for body in frontArea.get_overlapping_bodies():
		if body.is_in_group("Tool"):
			var dist: float = body.global_position.distance_squared_to(global_position)
			if dist < bestBodyDist:
				bestBodyDist = dist
				bestBody = body
	
	if bestBody:
		indicator.show()
		nearestLoot = bestBody
		indicator.global_position = get_viewport().get_camera_3d().unproject_position(bestBody.global_position)
	else:
		indicator.hide()
		nearestLoot = null
