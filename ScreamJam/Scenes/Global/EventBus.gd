extends Node


# Grid
var gridStepDelay: Timer
signal playerGridStep
signal newGridEntity(GridEntity)

func _ready() -> void:
	gridStepDelay = Timer.new()
	gridStepDelay.wait_time = 0.5
	gridStepDelay.one_shot = true
	gridStepDelay.autostart = true
	add_child(gridStepDelay)
	
	playerGridStep.connect(func(): gridStepDelay.start())
