extends Control

@onready var resolutionOptions = $Panel/GridContainer/ResolutionOptions

@onready var master_bus = AudioServer.get_bus_index("Master")

const VOLUME_LIMIT = -40

# Called when the node enters the scene tree for the first time.
func _ready():
	add_resolutions()

func add_resolutions():
	for i in GuiAutoload.resolutions:
		resolutionOptions.add_item(i)

func update_values():
	var windows_size = str(get_window().size.x, "x", get_window().size.y)
	var resIndex = GuiAutoload.resolutions.keys().find(windows_size)
	resolutionOptions.select(resIndex)

func _on_resolution_options_item_selected(index: int):
	var key = resolutionOptions.get_item_text(index)
	get_window().set_size(GuiAutoload.resolutions[key])

func _on_full_screen_check_box_toggled(toggled_on: bool):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_volume_slider_value_changed(value: float):
	if value == 0:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)
		AudioServer.set_bus_volume_db(master_bus, VOLUME_LIMIT * (1 - pow(value/100, 2)))
