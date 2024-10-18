extends Node3D

@export var MOVE_SPEED := 1.0
@export var DPS := 150.0
@export var DAMAGE_DISTANCE := 8.0

var player: Character

func _ready():
	$Detection.body_entered.connect(follow)
	$Detection.body_exited.connect(unfollow)
	
	set_physics_process(true)
	set_process(true)

func follow(body): if body is Character: player = body
func unfollow(body): if body is Character: player = null

func _physics_process(delta: float):
	if player == null:
		return
	
	var dir := global_position.direction_to(player.position) * MOVE_SPEED * delta
	global_position += Vector3(dir.x, 0.0, dir.z)
	
	var d := global_position.distance_to(player.position) / DAMAGE_DISTANCE
	var dist := maxf(0.0, 1.0 - sqrt(d))
	player.damageSanity(dist * delta * DPS, 0.25)

func _process(delta:float):
	if player == null:
		return
	
	var dist := maxf(0.0, 1.0 - global_position.distance_to(player.position) * 0.05)
	$MeshInstance3D.material_override.set_shader_parameter("distort", 0.25 + dist * dist * 2.0)
	$MeshInstance3D.transparency = 1.0 - dist
	$AudioStreamPlayer3D.pitch_scale = 0.1 + sqrt(dist) * 0.25
