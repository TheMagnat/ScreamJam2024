class_name FreeModel extends Node3D


@onready var material: ShaderMaterial = $MainSprite.material_override

func _process(delta: float) -> void:
	global_rotation.y = get_viewport().get_camera_3d().global_rotation.y
	material.set_shader_parameter("dist", clampf(global_position.distance_to(Global.player.global_position) / 10.0, 0.0, 1.0))

var dmgTween: Tween
func takeHit():
	if dmgTween: dmgTween.kill()
	
	
	dmgTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	dmgTween.tween_property(material, "shader_parameter/hit", 1.0, 0.1)
	dmgTween.tween_property(material, "shader_parameter/hit", 0.0, 0.5)
	#dmgTween.parallel().tween_property(self, "scale", Vector3.ONE * 1.25, 0.05)
	#dmgTween.tween_property(self, "scale", Vector3.ONE, 0.25)
	
func die():
	if dmgTween: dmgTween.kill()
	material.set_shader_parameter("death", 0.0)
	dmgTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	dmgTween.tween_property(material, "shader_parameter/death", 1.0, 1.0)
	dmgTween.parallel().tween_property($"../OmniLight3D", "light_energy", 0.0, 1.0)
	dmgTween.tween_callback(get_parent().queue_free)
	
