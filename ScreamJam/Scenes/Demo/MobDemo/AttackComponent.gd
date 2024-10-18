@tool
extends Node3D

@export var handNode: Node3D
@onready var attackAnimation: AnimationPlayer = $"../Head/HandPosition/AttackAnimation"
@onready var frontArea: Area3D = $"../Head/FrontRangeArea"


# Cache
@onready var gridRestrictor: GridRestrictor = $"../GridRestrictor"

# Debug
const DAGGER_TEST = preload("res://Scenes/PlayerTools/Dagger.tscn")

func _ready() -> void:
	
	var testTool = DAGGER_TEST.instantiate()
	
	handNode.add_child(testTool)
	
	# Attack animation
	attackAnimation.animation_finished.connect(attackFinished)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Attack"):
		if not inAttackAnimation:
			attack()

var inAttackAnimation: bool = false
func attack():
	attackAnimation.play("AttackAnimation")
	inAttackAnimation = true

	var bestBody: Node3D = null
	var bestBodyDist: float = INF
	for body in frontArea.get_overlapping_bodies():
		if body.is_in_group("ClassicEntity"):
			var dist: float = body.global_position.distance_squared_to(global_position)
			if dist < bestBodyDist:
				bestBodyDist = dist
				bestBody = body
	
	if bestBody:
		print("FOUND BEST BODY")
		bestBody.health -= 10.0 #TODO: Utiliser les dégats du tools
	
	if not gridRestrictor.gridToken.isFree:
		if not bestBody:
			var frontPosition: Vector2i = gridRestrictor.getFrontPosition()
			var entity: GridEntity = GridEntityManager.getEntityAt(frontPosition)
			if entity:
				print("FOUND GRID ENEMY")
				entity.health -= 10.0 #TODO: Utiliser les dégats du tools
		
		EventBus.playerGridStep.emit()
		
		#var currentCamera: Camera3D = get_viewport().get_camera_3d()
		#var result = RayHelper.castRay(currentCamera.global_position, currentCamera.global_position + -currentCamera.global_transform.basis.z * 5.0, 0b100)
		#if result:
			#print("FOUND MOB")
		#else:
			#print("No MOB")
	
	
	
func attackFinished(event):
	inAttackAnimation = false
