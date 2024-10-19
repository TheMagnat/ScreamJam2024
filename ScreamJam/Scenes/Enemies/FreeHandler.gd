extends Node


@export var parent: FreeEntity

var target: Node3D
var validLastPosition: bool = false
var targetLastPosition: Vector3

# Cache
@onready var navigationAgent: NavigationAgent3D = $"../NavigationAgent3D"

func _physics_process(delta: float) -> void:
	if parent.inAttackAnimation: return
	
	var reachedTargetPosition: bool = false
	
	# We can see the target, save its position
	if target:
		targetLastPosition = target.global_position
		validLastPosition = true
	
	if validLastPosition:
		# We already reached target position
		if targetLastPosition.distance_to(parent.global_position) < 3.0:
			reachedTargetPosition = true
			validLastPosition = false
			
			if target:
				parent.attack(target, parent.global_position)
		
		# We need to reach target position
		else:
			goToLastPosition()
	
	else:
		#TODO: Ici pas de last position, avancer en random ?
		pass
	
	
		
	
func goToLastPosition() -> void:
	navigationAgent.target_position = targetLastPosition
	
	var goalPosition: Vector3 = navigationAgent.get_next_path_position()
	goalPosition.y = 0.0
	
	var direction: Vector3 = parent.global_position.direction_to( goalPosition )
	parent.velocity = direction * parent.SPEED
	parent.velocity.y -= 9 # GRAVITY
	
	parent.move_and_slide()