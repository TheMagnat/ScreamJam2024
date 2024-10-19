extends Node3D

@export var nextScene: PackedScene

const STATES := [
	["Press %s to turn left", "RotateLeft"],
	["Press %s to turn right", "RotateRight"],
	["Move around with %s %s %s %s", ["Up", "Left", "Right", "Down"]],
	["If it gets too scary, press %s", "Blink"],
	["Now, find the exit! :)", []]
]

func _ready() -> void:
	RenderingServer.global_shader_parameter_set("wall_distort", 0.0)
	$CanvasLayer/Tutorial.hide()
	
	var t := create_tween()
	t.tween_method(func(x: float): $CanvasLayer/ColorRect.material.set_shader_parameter("pixelize", x), 0.0, 1.0, 3.0)
	
	t.tween_callback($CanvasLayer/Tutorial.show)
	t.tween_interval(1.0)
	t.tween_callback($CanvasLayer/Tutorial.hide)
	t.tween_callback(next_step)

func get_event(action: String) -> String:
	var events = InputMap.action_get_events(action)
	if events.size() > 0:
		return events[0].as_text().trim_suffix(" (Physical)")
	return ""

var step := -1
func next_step():
	step += 1
	
	if STATES.size() <= step:
		return
	
	if STATES[step][1] is Array:
		var arr := []
		for action in STATES[step][1]:
			arr.append(get_event(action))
		$CanvasLayer/Text.text = STATES[step][0] % arr
	else:
		$CanvasLayer/Text.text = STATES[step][0] % get_event(STATES[step][1])
	
	if step == (STATES.size() - 1):
		var t := create_tween()
		t.tween_property($CanvasLayer/Text, "modulate:a", 0.0, 5.0)
		t.parallel().tween_method(func(x: float): $CanvasLayer/ColorRect.material.set_shader_parameter("pixelize", x), 1.0, 0.0, 10.0)
		t.tween_callback(get_tree().change_scene_to_packed.bind(nextScene))

var rotating := false
const ROT_TIME := 0.125
func rotate_camera(a: float):
	rotating = true
	var t := create_tween()
	t.tween_callback(func(): $Camera3D.rotation.y += a / 4.0)
	t.tween_interval(ROT_TIME)
	t.tween_callback(func(): $Camera3D.rotation.y += a / 4.0)
	t.tween_interval(ROT_TIME)
	t.tween_callback(func(): $Camera3D.rotation.y += a / 4.0)
	t.tween_interval(ROT_TIME)
	t.tween_callback(func(): $Camera3D.rotation.y += a / 4.0)
	t.tween_callback(func(): rotating = false)

func check_step(i: int):
	return step == i or step >= (STATES.size() - 1) 

var blink_tween: Tween
var closed_eyes := false
func blink(closing : bool):
	if closing == closed_eyes: return
	
	if blink_tween: blink_tween.kill()
	blink_tween = create_tween()
	blink_tween.tween_callback(func(): $CanvasLayer/ColorRect.material.set_shader_parameter("blink", 0.4))
	blink_tween.tween_interval(0.25)
	blink_tween.tween_callback(func(): $CanvasLayer/ColorRect.material.set_shader_parameter("blink", 1.0 if closing else 0.0))
	
	if closing:
		blink_tween.tween_callback(func(): closed_eyes = true)
	else:
		closed_eyes = false

const DIST := 5.0

var moving := false
func move(a: float):
	moving = true
	var t := create_tween()
	
	if absf(a) > 0.0:
		rotate_camera(a)
		t.tween_interval(ROT_TIME * 3.5)
	
	var dir := Vector3(-sin($Camera3D.rotation.y + a), 0.0, -cos($Camera3D.rotation.y + a)) * DIST
	t.tween_callback(func(): $Camera3D.position += dir / 4.0)
	t.tween_interval(ROT_TIME)
	t.tween_callback(func(): $Camera3D.position += dir / 4.0)
	t.tween_interval(ROT_TIME)
	t.tween_callback(func(): $Camera3D.position += dir / 4.0)
	t.tween_interval(ROT_TIME)
	t.tween_callback(func(): $Camera3D.position += dir / 4.0)
	t.tween_callback(func(): moving = false)

func _input(event: InputEvent):
	if rotating || moving:
		return
	
	if event.is_action_pressed("Blink") and check_step(3):
		blink(true)
	elif event.is_action_released("Blink"):
		blink(false)
		next_step()
	
	if closed_eyes:
		return
	
	if event.is_action_pressed("RotateLeft") and check_step(0):
		rotate_camera(PI/2.0)
		next_step()
	elif event.is_action_pressed("RotateRight") and check_step(1):
		rotate_camera(-PI/2.0)
		next_step()
	
	if event.is_action_pressed("Left") and check_step(2):
		move(PI/2.0)
		next_step()
	elif event.is_action_pressed("Up") and check_step(2):
		move(0.0)
		next_step()
	elif event.is_action_pressed("Right") and check_step(2):
		move(-PI/2.0)
		next_step()
	elif event.is_action_pressed("Down") and check_step(2):
		move(PI)
		next_step()
	
