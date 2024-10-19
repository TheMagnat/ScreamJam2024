extends TransitionAnimation

func _init() -> void:
	animationName = "Alpha"

func _ready() -> void:
	var viewportMaxSize: float = max(get_viewport_rect().size.x, get_viewport_rect().size.y)
	$ColorRect.size = Vector2(viewportMaxSize, viewportMaxSize)
	$ColorRect.modulate.a = 0.0

var tween: Tween
func playIn(duration: float) -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 1.0, duration)
	tween.tween_callback(finished.emit)

func playOut(duration: float) -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 0.0, duration)
	tween.tween_callback(finished.emit)
