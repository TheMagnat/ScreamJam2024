extends Node


@export var parent: FreeEntity

var target: Node3D
var validLastPosition: bool = false
var targetLastPosition: Vector3
var dead: bool = false

# Cache
@onready var navigationAgent: NavigationAgent3D = $"../NavigationAgent3D"

# Random direction handler
var timeSinceRandomDir: float = 3.0
var randomDirection: Vector3

const randomDirLength: float = 10.0

# To reset on player death
var initialPosition: Vector3
var stopIdle: bool = false
func _ready() -> void:
	initialPosition = parent.global_position
	EventBus.playerRespawned.connect(reset)

func reset():
	parent.stopAttackAnimation()
	parent.global_position = initialPosition
	stopIdle = false
	validLastPosition = false
	target = null

var attackTimer : SceneTreeTimer
func _physics_process(delta: float) -> void:
	if parent.inAttackAnimation or dead or (attackTimer and attackTimer.time_left > 0.0): return
	
	var reachedTargetPosition: bool = false
	
	# We can see the target, save its position
	if target:
		targetLastPosition = target.global_position
		validLastPosition = true
		stopIdle = true
	
	if validLastPosition:
		# We already reached target position
		if targetLastPosition.distance_to(parent.global_position) < 3.0:
			reachedTargetPosition = true
			validLastPosition = false
			
			if target:
				parent.attack(target, parent.global_position)
				attackTimer = get_tree().create_timer(1.25)
		
		# We need to reach target position
		else:
			goToLastPosition()
	
	else:
		if not stopIdle and not EventBus.noGridModeTriggered: return
		
		if timeSinceRandomDir == 0.0:
			randomDirection = Vector3(randf_range(-1, 1), 0.0, randf_range(-1, 1)).normalized()
			targetLastPosition = parent.global_position + randomDirection * randomDirLength
		
		timeSinceRandomDir += delta
		
		if timeSinceRandomDir > 5.0:
			timeSinceRandomDir = 0.0
		elif timeSinceRandomDir > 3.0:
			pass # Idle
		else:
			goToLastPosition()

func goToLastPosition() -> void:
	navigationAgent.target_position = targetLastPosition
	
	var goalPosition: Vector3 = navigationAgent.get_next_path_position()
	goalPosition.y = 0.0
	
	var direction: Vector3 = parent.global_position.direction_to( goalPosition )
	parent.velocity = direction * parent.SPEED * (2.0 if EventBus.noGridModeTriggered else 1.0)
	#parent.velocity.y -= 9 # GRAVITY
	
	parent.move_and_slide()
