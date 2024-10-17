extends Control

@onready var resolutionOptions = $Panel/MarginContainer/GridContainer/ResolutionOptions

@onready var master_bus = AudioServer.get_bus_index("Master")

@onready var hotkeyButtonScene = preload("res://Scenes/Menu/ActionKeyButton.tscn")
@onready var controlsContainer = $Panel/MarginContainer/GridContainer/Container/ScrollContainer/ControlsContainer

var inputDictionnary = {
	"Up": "Forward",
	"Left": "Strafe Left",
	"Down": "Back", 
	"Right": "Strafe Right",
	"RotateLeft": "Rotate Left",
	"RotateRight": "Rotate Right",
	"Jump": "Jump",
	"Crouch": "Crouch",
	"Sprint": "Sprint",
	"Pause": "Pause Menu",
	"Blink": "Blink",
}

var isRemapping = false
var actionRemapping
var buttonRemapping

const VOLUME_LIMIT = -40

func _ready():
	_add_resolutions()
	_create_controls()

func _add_resolutions():
	for i in GuiAutoload.resolutions:
		resolutionOptions.add_item(i)

func _create_controls():
	InputMap.load_from_project_settings()
	for i in controlsContainer.get_children():
		i.queue_free()
	
	for action in inputDictionnary:
		var button = hotkeyButtonScene.instantiate()
		var actionLabel = button.find_child("ActionLabel")
		var inputLabel = button.find_child("InputLabel")
		
		actionLabel.text = inputDictionnary[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			inputLabel.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			inputLabel.text = ""
		
		button.pressed.connect(_on_input_button_pressed.bind(button, action))
		controlsContainer.add_child(button)

func _input(event : InputEvent):
	if isRemapping:
		if(event is InputEventKey || event is InputEventMouseButton && event.pressed):
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false
			
			InputMap.action_erase_events(actionRemapping)
			InputMap.action_add_event(actionRemapping, event)
			_update_controls(buttonRemapping, event)
			
			isRemapping = false
			actionRemapping = null
			buttonRemapping = null
			
			accept_event()

func _update_controls(button : Button, event : InputEvent):
	button.find_child("InputLabel").text = event.as_text().trim_suffix(" (Physical)")

func update_values():
	var windows_size = str(get_window().size.x, "x", get_window().size.y)
	var resIndex = GuiAutoload.resolutions.keys().find(windows_size)
	resolutionOptions.select(resIndex)

func _on_volume_slider_value_changed(value: float):
	if value == 0:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)
		AudioServer.set_bus_volume_db(master_bus, VOLUME_LIMIT * (1 - pow(value/100, 2)))

func _on_resolution_options_item_selected(index: int):
	var key = resolutionOptions.get_item_text(index)
	get_window().set_size(GuiAutoload.resolutions[key])

func _on_full_screen_check_box_toggled(toggled_on: bool):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_input_button_pressed(button : Button, action : InputEvent):
	if !isRemapping:
		isRemapping = true
		actionRemapping = action
		buttonRemapping = button
		button.find_child("InputLabel").text = "Press key..."

func _on_reset_button_pressed():
	_create_controls()
