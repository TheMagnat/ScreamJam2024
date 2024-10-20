extends Node


# Blow part
@onready var blowPlayer: AudioStreamPlayer = $BlowPlayer
signal blow
var alreadyBlown: bool = false

func _ready() -> void:
	EventBus.playerEnteredZone.connect(playerEnteredZone)


func playerEnteredZone(zoneId: int):
	if zoneId >= 2 and not alreadyBlown:
		blowPlayer.play()
		blow.emit()
		alreadyBlown = true
