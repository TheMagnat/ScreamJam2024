@tool
extends ColorRect

@export var timeScale: float = 1.0:
	set(value):
		timeScale = value
		material.set_shader_parameter("timeScale", timeScale)

@export var noiseHeight: int = 512:
	set(value):
		noiseHeight = value
		updateTexture()
		updateScaler()

@export var autoUvScaler: bool = false:
	set(value):
		autoUvScaler = value
		updateScaler()
		
@export var uvScaler := Vector2.ONE:
	set(value):
		uvScaler = value
		updateScaler()

@export var SCALE_FACTOR: float = 8.0

func updateScaler() -> void:
	if not autoUvScaler:
		material.set_shader_parameter("uvScaler", uvScaler)
		return
	
	# Texture related scale
	var yTextureScale: float = SCALE_FACTOR * 512.0 / float(noiseHeight)
	
	# Aspect ratio related scale
	var currentSize: Vector2 = scale
	var yAspectRatio: float = currentSize.y / currentSize.x
	
	material.set_shader_parameter("uvScaler", Vector2(uvScaler.x, yAspectRatio * yTextureScale))

	
@export var noise: FastNoiseLite

var noiseTexture = NoiseTexture2D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if autoUvScaler: updateScaler()
	updateTexture()

func _process(_delta: float) -> void:
	if autoUvScaler: updateScaler()

func updateTexture() -> void:
	#var aspectRatio = material.get_shader_parameter("aspectRatio")
	
	#noiseTexture.width *= aspectRatio.x
	noiseTexture.height = noiseHeight
	noiseTexture.seamless = true
	noiseTexture.seamless_blend_skirt = 0.2
	noiseTexture.noise = noise
	
	material.set_shader_parameter("noise", noiseTexture)
