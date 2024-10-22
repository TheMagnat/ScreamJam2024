@tool
extends AnimatedSprite2D


var blinkTimer: Timer
func _ready() -> void:
	animation_finished.connect(blinkFinish)
	
	blinkTimer = Timer.new()
	blinkTimer.one_shot = true
	blinkTimer.timeout.connect(blink)
	add_child(blinkTimer)
	
	blinkTimer.start(2.0 + randf() * 8.0)

var onBlink: bool = false
func blink() -> void:
	onBlink = true
	play("default")

func blinkFinish():
	if not onBlink: return
	
	onBlink = false
	play("default", -1.0, true)
	
	blinkTimer.start(2.0 + randf() * 8.0)
