extends Node3D

@export var MOVE_SPEED := 1.0
@export var DPS_SANITY := 150.0
@export var DPS_HEALTH := 150.0
@export var DAMAGE_SANITY_DISTANCE := 9.0
@export var DAMAGE_HEALTH_DISTANCE := 0.5

var activated: bool = false

var player: Character

var initialPosition: Vector3

func _ready():
	initialPosition = global_position
	EventBus.playerRespawned.connect(reset)
	EventBus.playerInNoGridMode.connect(activate)
	
	$Detection.body_entered.connect(follow)
	$Detection.body_exited.connect(unfollow)
	
	set_physics_process(true)
	set_process(true)

func activate():
	activated = true

func reset():
	global_position = initialPosition

func follow(body): if body is Character: player = body
func unfollow(body): if body is Character: player = null

func damage(delta: float, distance: float, dps: float) -> float:
	var d := global_position.distance_to(player.position) / distance
	return maxf(0.0, 1.0 - sqrt(d)) * dps * delta

func _physics_process(delta: float):
	if player == null or not activated:
		return
	
	var dir := global_position.direction_to(player.position) * MOVE_SPEED * delta
	global_position += Vector3(dir.x, 0.0, dir.z)
	
	player.damageSanity(damage(delta, DAMAGE_SANITY_DISTANCE, DPS_SANITY), 0.25, 0.5)
	player.damageHealth(damage(delta, DAMAGE_HEALTH_DISTANCE, DPS_HEALTH), true)

func _process(_delta:float):
	if player == null or not activated:
		return
	
	var dist := maxf(0.0, 1.0 - global_position.distance_to(player.position) * 0.05)
	$MeshInstance3D.material_override.set_shader_parameter("distort", 0.25 + dist * dist * 2.0)
	$MeshInstance3D.transparency = 1.0 - dist
	$AudioStreamPlayer3D.pitch_scale = 0.1 + sqrt(dist) * 0.25
