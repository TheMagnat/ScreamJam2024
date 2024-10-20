extends Area3D


@export var zoneNumber: int

func _on_body_entered(body: Node3D) -> void:
	if body is Character:
		print("PLAYER ENTERED")
		EventBus.playerEnteredZone.emit(zoneNumber)
