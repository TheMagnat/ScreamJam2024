class_name GridModel extends Sprite3D




func _process(delta: float) -> void:
	global_rotation.y = get_viewport().get_camera_3d().global_rotation.y

var dmgTween: Tween
func takeHit():
	if dmgTween: dmgTween.kill()
	
	material_override.set_shader_parameter("hit", 1.0)
	
	dmgTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	dmgTween.tween_property(material_override, "shader_parameter/hit", 0.0, 0.5)
	#dmgTween.parallel().tween_property(self, "scale", Vector3.ONE * 1.25, 0.05)
	#dmgTween.tween_property(self, "scale", Vector3.ONE, 0.25)
	
func die():
	if dmgTween: dmgTween.kill()
	material_override.set_shader_parameter("death", 0.0)
	dmgTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	dmgTween.tween_property(material_override, "shader_parameter/death", 1.0, 1.0)
	dmgTween.tween_callback(get_parent().queue_free)
	
	
