extends Sprite3D


@export var yOffset: float = 0.25

func _ready() -> void:
	var originalY: float = position.y
	var tween: Tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", originalY + yOffset, 1.5)
	tween.tween_property(self, "position:y", originalY - yOffset, 1.5)
