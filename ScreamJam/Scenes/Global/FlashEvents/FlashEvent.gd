extends Node


# Cache
@onready var eventScreen: ColorRect = $CanvasLayer/EventScreen
@onready var screenMaterial: ShaderMaterial = eventScreen.material

# Last time since event
var elapsedTimeSinceLastEvent: float = 0.0

# Event probability
const probabilityMax: float = 0.25
const probabilityMin: float = 0.0
const probabilityCurbeSteepness: float = 0.1

# Current event
var eventInProgress: bool = false

# Possible events
#var events: Array[Callable] = [colorFlash.bind(Vector3.ZERO)]
var events: Array[Callable] = [spawnFarEntity]

func _physics_process(delta: float) -> void:
	if not Global.inGame: return
	
	elapsedTimeSinceLastEvent += delta
	
	if Engine.get_physics_frames() % 10 or eventInProgress:
		return
	
	var currentProbability: float = probabilityMax - (probabilityMax - probabilityMin) * exp(-probabilityCurbeSteepness * elapsedTimeSinceLastEvent)
	var randValue: float = randf()
	if randValue < currentProbability:
		#print("TRIGGERED !!! = ", currentProbability, " mu rand: ", randValue)
		elapsedTimeSinceLastEvent = 0.0
		fireEvent()
		
	#else:
		#print("Proba: ", currentProbability, " my rand: ", randValue)

func fireEvent():
	var randValue: float = randf()
	events.pick_random().call()


## Animations ##
var animTween: Tween
func colorFlash(color: Vector3):
	eventInProgress = true
	screenMaterial.set_shader_parameter("color", color)
	screenMaterial.set_shader_parameter("alpha", 1.0)
	await get_tree().create_timer(0.05).timeout
	screenMaterial.set_shader_parameter("inverseScreen", 0.5)
	screenMaterial.set_shader_parameter("alpha", 0.0)
	await get_tree().create_timer(1.0).timeout
	screenMaterial.set_shader_parameter("alpha", 1.0)
	await get_tree().create_timer(0.05).timeout
	screenMaterial.set_shader_parameter("inverseScreen", 0.0)
	screenMaterial.set_shader_parameter("alpha", 0.0)
	eventInProgress = false

# Mew
func distortY():
	eventInProgress = true
	if animTween: animTween.kill()
	animTween = create_tween()
	animTween.tween_property(screenMaterial, "shader_parameter/inverseScreen", 0.1, 0.0)
	animTween.tween_interval(0.1)
	animTween.tween_property(screenMaterial, "shader_parameter/inverseScreen", 0.7, 0.0)
	animTween.tween_interval(0.1)
	animTween.tween_property(screenMaterial, "shader_parameter/inverseScreen", 0.5, 0.0)
	animTween.tween_interval(0.2)
	animTween.tween_property(screenMaterial, "shader_parameter/color", Vector3.ZERO, 0.0)
	animTween.tween_property(screenMaterial, "shader_parameter/alpha", 1.0, 0.0)
	animTween.tween_interval(0.1)
	animTween.tween_property(screenMaterial, "shader_parameter/alpha", 0.0, 0.0)
	animTween.tween_property(screenMaterial, "shader_parameter/inverseScreen", 0.0, 0.0)
	animTween.tween_property(self, "eventInProgress", false, 0.0)

func inversedGrid():
	pass

func getSpawnPosition(dist: float, angle: float) -> Vector3:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var spawnDirection: Vector3 = -camera.global_transform.basis.z
	spawnDirection.y = 0.0
	spawnDirection.x += randf_range(-0.2, 0.2)
	spawnDirection.z += randf_range(-0.2, 0.2)
	spawnDirection = spawnDirection.normalized()
	
	var spawnPosition: Vector3 = camera.global_position + spawnDirection * dist
	spawnPosition.y = 0.0
	
	return spawnPosition

## Cool - Should be low proba
func spawnEye():
	if Global.player.locked:
		return
	
	eventInProgress = true
	
	screenMaterial.set_shader_parameter("color", Vector3.ZERO)
	screenMaterial.set_shader_parameter("alpha", 1.0)
	await get_tree().create_timer(0.05).timeout
	screenMaterial.set_shader_parameter("alpha", 0.0)
	
	eventInProgress = false
	
	# Create the Eye
	var spawnPosition: Vector3 = getSpawnPosition(randf_range(4.5, 5.0), 0.4)
	spawnPosition.y = randf_range(1.5, 2.5)
	
	if not Global.map.isWorldPosAvailable(spawnPosition):
		return
	
	var newEye: Eye = preload("res://Scenes/Enemies/Model/Eye.tscn").instantiate()
	newEye.oneShot = true
	
	Global.map.add_child(newEye)
	newEye.global_position = spawnPosition

func spawnFarEntity():
	if Global.player.locked:
		return
	
	eventInProgress = true
	
	#screenMaterial.set_shader_parameter("color", Vector3.ZERO)
	#screenMaterial.set_shader_parameter("alpha", 1.0)
	#await get_tree().create_timer(0.05).timeout
	#screenMaterial.set_shader_parameter("alpha", 0.0)
	
	eventInProgress = false
	
	# Create the Eye
	var spawnPosition: Vector3 = getSpawnPosition(12, 0.2)
	spawnPosition.y = randf_range(1.5, 3.5)
	
	if not Global.map.isWorldPosAvailable(spawnPosition):
		return
	
	var newFarEntity = preload("res://Scenes/Entity/FarEntity.tscn").instantiate()
	
	Global.map.add_child(newFarEntity)
	newFarEntity.global_position = spawnPosition
