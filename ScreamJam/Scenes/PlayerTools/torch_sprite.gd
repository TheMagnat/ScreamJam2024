class_name TorchSprite extends Sprite3D


const TWEEN_TIME := 1.75
func blow():
	var t := create_tween().set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_SINE)
	t.tween_property($Flame.material_override, "shader_parameter/isOn", 0.0, TWEEN_TIME)
	t.parallel().tween_property($AudioStreamPlayer3D, "volume_db", -80.0, TWEEN_TIME)
	t.tween_callback($AudioStreamPlayer3D.stop)
