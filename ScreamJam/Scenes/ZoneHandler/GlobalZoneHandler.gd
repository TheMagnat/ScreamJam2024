extends Node

# Best explored zone
var playerBestZone: int = 0.0
signal playerBestZoneChanged(int)

# Blow part
@onready var blowPlayer: AudioStreamPlayer = $BlowPlayer
signal blow
var alreadyBlown: bool = false

func _ready() -> void:
	EventBus.playerEnteredZone.connect(playerEnteredZone)

func playerEnteredZone(zoneId: int):
	
	if zoneId > playerBestZone:
		playerBestZone = zoneId
		playerBestZoneChanged.emit(playerBestZone)
	
	if zoneId >= 2 and not alreadyBlown:
		blowPlayer.play()
		blow.emit()
		alreadyBlown = true
