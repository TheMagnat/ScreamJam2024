extends Node

# Death Events
signal playerRespawned

# Zone
signal playerEnteredZone(zoneNumber: int)
signal playerInNoGridMode
var noGridModeTriggered: bool = false

# Grid
var gridStepDelay: Timer
signal playerGridStep

func _ready() -> void:
	gridStepDelay = Timer.new()
	gridStepDelay.wait_time = 0.5
	gridStepDelay.one_shot = true
	gridStepDelay.autostart = true
	add_child(gridStepDelay)
	
	playerGridStep.connect(func(): gridStepDelay.start())
	playerInNoGridMode.connect(func(): noGridModeTriggered = true)
