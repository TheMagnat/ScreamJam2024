extends TransitionAnimation

@onready var renderer: ColorRect = $Renderer

func _init() -> void:
	animationName = "SpikeBall"

func _ready() -> void:
	var viewportMaxSize: float = max(get_viewport_rect().size.x, get_viewport_rect().size.y)
	renderer.size = Vector2(viewportMaxSize, viewportMaxSize)

var tween: Tween
func playIn(duration: float) -> void:
	renderer.material.set_shader_parameter("offset", 0.73)
	
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(renderer, "material:shader_parameter/offset", 0.0, duration)
	tween.tween_callback(finished.emit)

func playOut(duration: float) -> void:
	renderer.material.set_shader_parameter("offset", 0.0)
	
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(renderer, "material:shader_parameter/offset", 0.73, duration)
	tween.tween_callback(finished.emit)
