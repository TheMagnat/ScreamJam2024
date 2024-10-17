extends CanvasLayer

var pauseMenuPath = "res://Scenes/Menu/PauseMenu.tscn"

var resolutions = {
	"2560x1440": Vector2i(2560,1440),
	"1920x1080": Vector2i(1920,1080),
	"1366x768": Vector2i(1366,768),
	"1280x720": Vector2i(1280,720),
	"1920x1200" : Vector2i(1920,1200),
	"1680x1050" : Vector2i(1680,1050),
	"1440x900" : Vector2i(1440,900),
	"1280x800" : Vector2i(1280,800),
	"1024x768" : Vector2i(1024,768),
	"800x600" : Vector2i(800,600),
	"640x480" : Vector2i(640,480),
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var pauseMenuScene = load(pauseMenuPath).instantiate()
	add_child(pauseMenuScene)
	pauseMenuScene.hide()
	pass # Replace with function body.


func _input(_event):
	if Input.is_action_just_pressed("Pause"):
		var pauseMenu = get_node("PauseMenu")
		pauseMenu.visible = !pauseMenu.visible
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if pauseMenu.visible else Input.MOUSE_MODE_CAPTURED
		if pauseMenu.visible:
			pauseMenu.update_values()
