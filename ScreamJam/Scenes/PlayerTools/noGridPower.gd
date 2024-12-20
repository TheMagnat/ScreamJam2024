extends Node3D

@onready var material: ShaderMaterial = $MeshInstance3D.material_override

var triggered: bool = false
func _on_area_3d_body_entered(body: Node3D) -> void:
	if triggered: return
	triggered = true
	
	Global.player.get_node("GridRestrictor").deactivate()
	EventBus.playerInNoGridMode.emit()

	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(material, "shader_parameter/fadeOut", 1.0, 1.5)
	tween.parallel().tween_property(self, "scale", Vector3.ONE * 2.0, 1.5)
	tween.parallel().tween_property(Global.player.get_node("PostProcess/ColorRect").material, "shader_parameter/tookPower", 1.0, 5.0)
	tween.tween_property(Global.player.get_node("PostProcess/ColorRect").material, "shader_parameter/tookPower", 0.0, 2.0)
	tween.tween_interval(6.0)
	tween.tween_callback(queue_free)
	
	$AudioStreamPlayer.play()
