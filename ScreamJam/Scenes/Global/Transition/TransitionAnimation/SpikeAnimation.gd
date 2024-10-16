extends TransitionAnimation

@onready var renderer: ColorRect = $Renderer
@onready var viewportSize: Vector2 = get_viewport_rect().size

func _init() -> void:
	animationName = "Spike"

func _ready() -> void:
	renderer.size = Vector2(viewportSize.x * 2.0, viewportSize.y)

var tween: Tween
func playIn(duration: float) -> void:
	renderer.position.x = viewportSize.x
	
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(renderer, "position:x", -512, duration)
	tween.tween_callback(finished.emit)

func playOut(duration: float) -> void:
	renderer.position.x = -512
	
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(renderer, "position:x", -viewportSize.x * 2.0, duration)
	tween.tween_callback(finished.emit)
