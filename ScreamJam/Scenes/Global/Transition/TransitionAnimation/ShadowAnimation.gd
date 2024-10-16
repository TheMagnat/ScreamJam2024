extends TransitionAnimation

@onready var shadow: ColorRect = $Shadow
@onready var viewportSize: Vector2 = get_viewport_rect().size

const viewportScale: float = 2.0
@onready var viewportLeftPosition: float = (viewportSize.x * viewportScale) - viewportSize.x

func _init() -> void:
	animationName = "Shadow"

func _ready() -> void:
	shadow.size = Vector2(viewportSize.x * viewportScale, viewportSize.y)

const UV_MIN_SCALE: float = 2.0
const UV_MAX_SCALE: float = 3.0

var tween: Tween
func playIn(duration: float) -> void:
	shadow.position.x = viewportSize.x
	shadow.material.set_shader_parameter("direction", 0.0) # Shadow on the left
	shadow.material.set_shader_parameter("timeDirection", -1.0)
	shadow.uvScaler.x = UV_MIN_SCALE
	
	if tween: tween.kill()
	tween = create_tween()#.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(shadow, "uvScaler:x", UV_MAX_SCALE, duration)
	tween.parallel().tween_property(shadow, "position:x", -viewportLeftPosition, duration)
	tween.tween_callback(finished.emit)

var outDirection: int = 0
func playOut(duration: float) -> void:
	
	var targetPosition: float
	
	if outDirection == 0:
		shadow.position.x = 0
		shadow.material.set_shader_parameter("direction", 1.0) # Shadow on the right
		shadow.material.set_shader_parameter("timeDirection", -1.0)
		shadow.uvScaler.x = UV_MAX_SCALE
		
		targetPosition = -shadow.size.x
		
	else:
		shadow.position.x = -viewportLeftPosition
		shadow.material.set_shader_parameter("direction", 0.0) # Shadow on the left
		shadow.material.set_shader_parameter("timeDirection", 1.0)
		shadow.uvScaler.x = UV_MAX_SCALE
		
		targetPosition = viewportSize.x
	
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(shadow, "uvScaler:x", UV_MIN_SCALE, duration)
	tween.parallel().tween_property(shadow, "position:x", targetPosition, duration)
	tween.tween_callback(finished.emit)

func setParameters(parameters: Array) -> void:
	if parameters.size() > 0:
		outDirection = parameters[0]
