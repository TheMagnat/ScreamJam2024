extends Node3D


const MIN_DISTANCE := 12.0
@onready var material: ShaderMaterial = $Sprite3D.material_override

func _ready():
	$SubViewport/AnimatedSprite2D.scale = Vector2(1.0, 1.0) * randf_range(0.125, 0.25)
	get_tree().create_timer(30.0).timeout.connect(disappear)

func disappear():
	var t := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property($Sprite3D.material_override, "shader_parameter/dist", 0.0, 0.25)
	t.tween_callback(queue_free)

func _process(_delta: float) -> void:
	if global_position.distance_to(Global.player.global_position) < MIN_DISTANCE:
		disappear()
