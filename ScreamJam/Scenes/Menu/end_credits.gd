extends Node

@onready var LABEL_TEMPLATE := $VBoxContainer/HBoxContainer/Label.duplicate()
var labels := []

const TWEEN_TIME := 0.5
func add_text(t: Tween, text: String, time: float):
	var lbl := LABEL_TEMPLATE.duplicate()
	lbl.text = text
	lbl.material = lbl.material.duplicate()
	
	labels.append(lbl)
	t.tween_callback($VBoxContainer/HBoxContainer.add_child.bind(lbl))
	t.tween_method(func(x: float): lbl.material.set_shader_parameter("deform", x), 1.0, 0.002, TWEEN_TIME)
	t.parallel().tween_property(lbl, "modulate:a", 1.0, TWEEN_TIME)
	t.tween_interval(time - TWEEN_TIME * 2.0)
	t.tween_property(lbl, "modulate:a", 0.0, TWEEN_TIME)
	t.tween_callback(lbl.queue_free)


# ["text", timeAlive, timeFromLast]
const TEXTS := [
	["The End", 6.0],
	["This game was made for the ScreamJam 2024\nUsing Godot Engine", 6.0],
	["Game Programming\n\nMagnat\nBul0z\nObaniGarage", 5.0],
	["Visual Programming\n\nMagnat\nObaniGarage", 5.0],
	["Graphics\n\nKryspou", 5.0],
	["Audio\n\nObaniGarage", 5.0],
	["This was our first ever horror game, we hope you liked it", 8.0],
]

func _ready():
	PauseMenu.enable(false)
	
	LABEL_TEMPLATE.modulate.a = 0.0
	$VBoxContainer/HBoxContainer/Label.queue_free()
	$VBoxContainer/Buttons.hide()
	
	var main_tween := create_tween()
	main_tween.set_ease(Tween.EASE_OUT)
	main_tween.set_trans(Tween.TRANS_SINE)

	
	for i in TEXTS.size():
		add_text(main_tween, TEXTS[i][0], TEXTS[i][1])
	
	main_tween.tween_callback(func():
		$VBoxContainer/Buttons.modulate.a = 0.0
		$VBoxContainer/Buttons.show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE)
	main_tween.tween_property($VBoxContainer/Buttons, "modulate:a", 1.0, 6.0)
	
	$VBoxContainer/Buttons/PlayAgain.pressed.connect(play_again)
	$VBoxContainer/Buttons/Quit.pressed.connect(quit)

func _exit_tree():
	PauseMenu.enable(true)

func play_again():
	Transition.start(get_tree().change_scene_to_file.bind("res://Scenes/Tutorial/tutorial.tscn"), 1.0, Transition.Type.Alpha, Transition.Type.Alpha)

func quit():
	get_tree().quit()
