extends Node3D

@export var nextScene: PackedScene

const STATES := [
	["Press %s to turn left", "RotateLeft"],
	["Press %s to turn right", "RotateRight"],
	["Move around with %s %s %s %s", ["Up", "Left", "Down", "Right"]],
]

func _ready() -> void:
	RenderingServer.global_shader_parameter_set("wall_distort", 0.0)
	RenderingServer.global_shader_parameter_set("breathing", 0.0)
	$CanvasLayer/Tutorial.hide()
	Ambience.stop_ambience()
	
	var t := create_tween()
	t.tween_callback($intro.play)
	t.tween_method(func(x: float): $CanvasLayer/ColorRect.material.set_shader_parameter("pixelize", x), 0.0, 1.0, 2.25)
	t.tween_interval(1.0)
	
	t.tween_callback(func():
		$CanvasLayer/Tutorial.show()
		$action.play())
	t.tween_interval(2.0)
	t.tween_callback(func():
		$CanvasLayer/Tutorial.hide()
		$action.play())
	t.tween_callback(next_step)

func _exit_tree():
	print("Exitting tutorial")
	RenderingServer.global_shader_parameter_set("breathing", 1.0)

var step := -1
const BLINK_STEP := 12
const BLINK_INFO := ["If it gets too scary, press %s", "Blink"]
func next_step():
	step += 1
	
	if STATES.size() <= step && step != BLINK_STEP:
		return
	var state: Array
	if step == BLINK_STEP:
		state = BLINK_INFO
	else:
		state = STATES[step]
	
	if state[1] is Array:
		var arr := []
		for action in state[1]:
			arr.append(Global.get_action_key(action))
		$CanvasLayer/Text.text = state[0] % arr
	else:
		$CanvasLayer/Text.text = state[0] % Global.get_action_key(state[1])
	
	if step > 0:
		$validate.play()

var rotating := false
const ROT_TIME := 0.2

func rot_step(t: Tween, a: float):
	t.tween_callback(func():
		$Camera3D.rotation.y += a
		$action.play())
	t.tween_interval(ROT_TIME)

func rotate_camera(a: float):
	rotating = true
	var t := create_tween()
	rot_step(t, a / 3.0)
	rot_step(t, a / 3.0)
	rot_step(t, a / 3.0)
	t.tween_callback(func(): rotating = false)

func check_step(i: int):
	return step == i or step >= (STATES.size() - 1) 

var blink_tween: Tween
var closed_eyes := false
func blink_step(t: Tween, s: float):
	t.tween_callback(func():
		$CanvasLayer/ColorRect.material.set_shader_parameter("blink", s)
		$eye.play())
	t.tween_interval(ROT_TIME)

func blink():
	closed_eyes = true
	if blink_tween: blink_tween.kill()
	blink_tween = create_tween()
	blink_step(blink_tween, 0.2)
	blink_step(blink_tween, 0.4)
	blink_step(blink_tween, 1.0)

func move_step(t: Tween, dir: Vector3):
	t.tween_callback(func():
		$Camera3D.position += dir
		$action.play())
	t.tween_interval(ROT_TIME)

var moving := false
func move(a: float):
	var dir : Vector3 = Vector3(-sin($Camera3D.rotation.y + a), 0.0, -cos($Camera3D.rotation.y + a)) * $MapHolder/TutorialMap.gridSpace
	var expectedPos : Vector3 = ($Camera3D.position + dir)/$MapHolder/TutorialMap.gridSpace
	
	if !$MapHolder/TutorialMap.isAvailable(Vector2i(int(roundf(expectedPos.x)), int(roundf(expectedPos.z)))):
		return
	
	moving = true
	var t := create_tween()
	
	if absf(a) > 0.0:
		rotate_camera(a)
		t.tween_interval(ROT_TIME * 3.5)
	
	move_step(t, dir / 3.0)
	move_step(t, dir / 3.0)
	move_step(t, dir / 3.0)
	t.tween_callback(func(): moving = false)

func load_level():
	Ambience.next_ambience()
	Transition.start(get_tree().change_scene_to_packed.bind(nextScene), 0.25, Transition.Type.Alpha, Transition.Type.Alpha)

func _input(event: InputEvent):
	if rotating || moving:
		return
	
	if step >= BLINK_STEP:
		if event.is_action_pressed("Blink") and !closed_eyes:
			blink()
		elif event.is_action_released("Blink") and closed_eyes:
			print("heyho")
			if blink_tween and blink_tween.is_running():
				set_process_input(false)
				await blink_tween.finished
			
			load_level()
	
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
	
