extends AudioStreamPlayer3D


func _ready() -> void:
	EventBus.playerInNoGridMode.connect(activate)

func activate() -> void:
	await get_tree().create_timer(9.0).timeout
	play()
