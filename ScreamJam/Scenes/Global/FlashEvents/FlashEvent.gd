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
var events: Array[Callable] = [spawnFarEntity, spawnFarSound, spawnCrawlingBug]

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
	#var randValue: float = randf()
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

func getSpawnPosition(dist: float, _angle: float) -> Vector3:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var spawnDirection: Vector3 = -camera.global_transform.basis.z
	spawnDirection.y = 0.0
	spawnDirection.x += randf_range(-0.2, 0.2)
	spawnDirection.z += randf_range(-0.2, 0.2)
	spawnDirection = spawnDirection.normalized()
	
	var spawnPosition: Vector3 = camera.global_position + spawnDirection * dist
	spawnPosition.y = 0.0
	
	return spawnPosition

func spawnEntity(scene, dist: float, height: float, angle: float):
	eventInProgress = false
	
	var spawnPosition: Vector3 = getSpawnPosition(dist, angle)
	spawnPosition.y = height
	
	if not Global.map.isWorldPosAvailable(spawnPosition):
		return
	
	var instance = scene.instantiate()	
	Global.map.add_child(instance)
	instance.global_position = spawnPosition
	return instance

## Cool - Should be low proba
func spawnEye():
	if !Global.player or Global.player.locked:
		return
	
	eventInProgress = true
	
	screenMaterial.set_shader_parameter("color", Vector3.ZERO)
	screenMaterial.set_shader_parameter("alpha", 1.0)
	await get_tree().create_timer(0.05).timeout
	screenMaterial.set_shader_parameter("alpha", 0.0)
		
	var eye = spawnEntity(preload("res://Scenes/Enemies/Model/Eye.tscn"), randf_range(4.5, 5.0), randf_range(1.5, 2.5), 0.4)
	eye.one_shot = true

func spawnFarEntity():
	if!Global.player or  Global.player.locked:
		return
	
	eventInProgress = true
	
	#screenMaterial.set_shader_parameter("color", Vector3.ZERO)
	#screenMaterial.set_shader_parameter("alpha", 1.0)
	#await get_tree().create_timer(0.05).timeout
	#screenMaterial.set_shader_parameter("alpha", 0.0)
	
	spawnEntity(preload("res://Scenes/Entity/FarEntity.tscn"), 13, randf_range(1.5, 3.5), 0.2)

func spawnFarSound():
	if !Global.player or Global.player.locked:
		return
	
	eventInProgress = true
	
	var voice = spawnEntity(preload("res://Scenes/Entity/VoiceEntity.tscn"), randf_range(1.0, 40.0), 0.0, 0.0)

func spawnCrawlingBug():
	# Create the Eye
	var spawnPosition: Vector3 = getSpawnPosition(4 + randf() * 4.0, 0.5)
	spawnPosition.y = 0.0
	
	#if not Global.map.isWorldPosAvailable(spawnPosition):
		#return
	
	var dir: Vector3 = Global.player.global_position.direction_to(spawnPosition)
	var perpendicular := Vector3.UP.cross(dir)
	
	for i in randi_range(1, 3):
		var newFarEntity: BugEntity = preload("res://Scenes/Entity/BugEntity.tscn").instantiate()
		Global.map.add_child(newFarEntity)
		
		const separation: float = 3.0
		var speed: float = randf_range(8.0, 12.0)
		
		var side1 := perpendicular * separation * 2.0
		var side2 := perpendicular * separation * 12.0
		side2.y -= 0.1
		
		var inverse: bool = randi() % 2 == 0
		if inverse:
			newFarEntity.startCrawling(spawnPosition - side1, spawnPosition + side2, speed, inverse)
		else:
			newFarEntity.startCrawling(spawnPosition + side1, spawnPosition - side2, speed, inverse)
