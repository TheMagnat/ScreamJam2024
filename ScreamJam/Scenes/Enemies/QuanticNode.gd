class_name QuanticNode extends Node3D


@onready var sanityAttacker: SanityAttacker = $"../SanityAttacker"

@export var observed: GeometryInstance3D
@export var target: Character

const headOffset := Vector3(0.0, 1.0, 0.0)
const mobHeightRand := Vector2(1.5, 2.5)
const distMax: float = 8.0

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
func _process(delta: float) -> void:
	
	if target.sanity <= 0.0 and isWatching:
		return
	
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
	var pos: Vector3 = Global.map.getRandomPos()
	while get_viewport().get_camera_3d().is_position_in_frustum(pos):
		pos = Global.map.getRandomPos()
	
	pos.y += randf_range(mobHeightRand.x, mobHeightRand.y)
	get_parent().global_position = pos
	
	sanityAttacker.setTrueDmgs()
	
	foundTimer.start()

var isInFrustum: bool = false
func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	isInFrustum = true

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	isInFrustum = false
