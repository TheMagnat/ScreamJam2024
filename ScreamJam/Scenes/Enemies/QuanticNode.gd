class_name QuanticNode extends Node3D


@onready var sanityAttacker: SanityAttacker = $"../SanityAttacker"
@onready var hypnotizeNode: HypnotizeNode = $"../HypnotizeNode"


@export var observed: GeometryInstance3D
@export var target: Character

const headOffset := Vector3(0.0, 1.0, 0.0)
const mobHeightRand := Vector2(1.5, 2.5)
const distMax: float = 8.0
var oneShot: bool = false

var foundTimer: Timer

func _ready() -> void:
	target = Global.player
	
	foundTimer = Timer.new()
	foundTimer.wait_time = 10.0
	foundTimer.one_shot = true
	foundTimer.timeout.connect(foundTimeOut)
	add_child(foundTimer)
	
	# Note: we only start when we first see it
	#foundTimer.start()

func foundTimeOut():
	stopedWatching()

var isWatching: bool = false
func _process(_delta: float) -> void:
	if not target.closed_eyes:
		if isInFrustum and (isWatching or global_position.distance_to(target.global_position) < distMax):
			if not RayHelper.castRay(global_position, target.global_position + headOffset, 0b01):
				isWatching = true
				foundTimer.stop()
				return
	
	if isWatching:
		stopedWatching()
		
	isWatching = false

func stopedWatching():
	if oneShot:
		get_parent().queue_free()
		hypnotizeNode.unlock()
		return
	
	var pos: Vector3 = Global.map.getRandomPos()
	while get_viewport().get_camera_3d().is_position_in_frustum(pos) or pos.distance_to(target.global_position) < 3.0:
		pos = Global.map.getRandomPos()
	
	# Random vertical
	pos.y += randf_range(mobHeightRand.x, mobHeightRand.y)
	
	# Random lateral
	pos.x += randf_range(-2.0, 2.0) # For map spacing of 5
	pos.z += randf_range(-2.0, 2.0)
	
	get_parent().global_position = pos
	
	sanityAttacker.setTrueDmgs()
	
	foundTimer.start()

var isInFrustum: bool = false
func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	isInFrustum = true

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	isInFrustum = false
