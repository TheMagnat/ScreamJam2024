
# COPYRIGHT Colormatic Studios
# MIT licence
# Quality Godot First Person Controller v2


class_name Character extends CharacterBody3D

## The settings for the character's movement and feel.
@export_category("Character")
## The speed that the character moves at without crouching or sprinting.
@export var base_speed : float = 3.0
## The speed that the character moves at when sprinting.
@export var sprint_speed : float = 6.0
## The speed that the character moves at when crouching.
@export var crouch_speed : float = 1.0

## How fast the character speeds up and slows down when Motion Smoothing is on.
@export var acceleration : float = 10.0
## How high the player jumps.
@export var jump_velocity : float = 4.5
## How far the player turns when the mouse is moved.
@export var mouse_sensitivity : float = 0.1
## Invert the Y input for mouse and joystick
@export var invert_mouse_y : bool = false # Possibly add an invert mouse X in the future
## Wether the player can use movement inputs. Does not stop outside forces or jumping. See Jumping Enabled.
@export var immobile : bool = false
## The reticle file to import at runtime. By default are in res://addons/fpc/reticles/. Set to an empty string to remove.
@export_file var default_reticle

@export_group("Nodes")
## The node that holds the camera. This is rotated instead of the camera for mouse input.
@export var HEAD : Node3D
@export var CAMERA : Camera3D
@export var HEADBOB_ANIMATION : AnimationPlayer
@export var JUMP_ANIMATION : AnimationPlayer
@export var CROUCH_ANIMATION : AnimationPlayer
@export var COLLISION_MESH : CollisionShape3D

@export_group("Controls")
# We are using UI controls because they are built into Godot Engine so they can be used right away
@export var JUMP : String = "Jump"
@export var LEFT : String = "Left"
@export var RIGHT : String = "Right"
@export var FORWARD : String = "Up"
@export var BACKWARD : String = "Down"
@export var CROUCH : String = "Crouch"
@export var SPRINT : String = "Sprint"

# Uncomment if you want controller support
#@export var controller_sensitivity : float = 0.035
#@export var LOOK_LEFT : String = "look_left"
#@export var LOOK_RIGHT : String = "look_right"
#@export var LOOK_UP : String = "look_up"
#@export var LOOK_DOWN : String = "look_down"

@export_group("Feature Settings")
## Enable or disable jumping. Useful for restrictive storytelling environments.
const jumping_enabled : bool = false
## Wether the player can move in the air or not.
@export var in_air_momentum : bool = true
## Smooths the feel of walking.
@export var motion_smoothing : bool = true
@export var sprint_enabled : bool = true
@export var crouch_enabled : bool = true
@export_enum("Hold to Crouch", "Toggle Crouch") var crouch_mode : int = 0
@export_enum("Hold to Sprint", "Toggle Sprint") var sprint_mode : int = 0
## Wether sprinting should effect FOV.
@export var dynamic_fov : bool = true
## If the player holds down the jump button, should the player keep hopping.
@export var continuous_jumping : bool = true
## Enables the view bobbing animation.
@export var view_bobbing : bool = true
## Enables an immersive animation when the player jumps and hits the ground.
@export var jump_animation : bool = true
## Use with caution.
@export var gravity_enabled : bool = true

@export_category("Custom Features")
@export var lockedCamera: bool = false
@export var handled: bool = false
@export var handled_input := Vector2.ZERO
@export var handled_sprint: bool = false
@export var locked: bool = false # When true NOT ANY MOVE can be done
@export var keepY: bool = false

@export var environment: WorldEnvironment
@onready var lootComponent: LootComponent = get_node("LootComponent") if has_node("LootComponent") else null



# Member variables
var speed : float = base_speed
var current_speed : float = 0.0
# States: normal, crouching, sprinting
var state : String = "normal"
var low_ceiling : bool = false # This is for when the cieling is too low and the player needs to crouch.
var was_on_floor : bool = true # Was the player on the floor last frame (for landing animation)

# The reticle should always have a Control node as the root
var RETICLE : Control

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") # Don't set this as a const, see the gravity section in _physics_process

# Stores mouse input for rotating the camera in the phyhsics process
var mouseInput : Vector2 = Vector2(0,0)

const SANITY_MAX := 100.0
const SANITY_RECOVER := 2.0
var sanity := SANITY_MAX

const HEALTH_MAX := 100.0
const HEALTH_RECOVER := 1.0
var health := HEALTH_MAX

var hypnotized := false
func set_hypnotized(h: bool):
	hypnotized = h
	locked = h

func damageSanity(dmg: float, eyes_closed_factor := 1.0, under_zero_factor := 1.0):
	if dead: return
	
	var oldSanityZ: float = minf(0.0, sanity)
	sanity -= dmg * (eyes_closed_factor if closed_eyes else 1.0)
	
	var underZDmgs: float = min(sanity - oldSanityZ, 0.0)
	
	if underZDmgs != 0.0:
		damageHealth(-underZDmgs * under_zero_factor, true)
	
func rands() -> float:
	return signf(randf() - 0.5)

var damageTween: Tween
var lastTweenDelta: float = 0.0
var lastRotDiff: Vector3
func damageHealth(dmg: float, dot := false):
	if dead: return
	
	health -= dmg
	if !dot:
		if damageTween:
			damageTween.kill()
			lastRotDiff -= lastRotDiff * lastTweenDelta
		else:
			lastRotDiff = Vector3.ZERO
		
		damageTween = create_tween()
		damageTween.set_ease(Tween.EASE_OUT)
		damageTween.set_trans(Tween.TRANS_SINE)
		var d := dmg * 0.01
		var preRot := HEAD.rotation
		preRot.z = 0.0
		var newRotDiff := Vector3(d * rands(), d * rands(), d * rands())
		
		HEAD.rotation += newRotDiff
		lastRotDiff -= newRotDiff
		
		$Head/hit.play()
		
		lastTweenDelta = 0.0
		damageTween.tween_method(func(delta: float):
			var deltaDiff: float = delta - lastTweenDelta
			HEAD.rotation += lastRotDiff * deltaDiff
			lastTweenDelta = delta,
		0.0, 1.0, 0.3)
	
	if health < 0.0:
		die()

var dead := false
var death_tween: Tween

var textId := 0
const DEATH_TEXTS := [
	"Nightmares don't always end by waking up",
	"Death is everyone's destination. What if it didn't exist?",
	"Your soul escaped your body, not the maze",
	"Fear emerges from the unknown",
]
func die():
	dead = true
	set_physics_process(false)
	blink(true)
	
	$PostProcess/Label.modulate.a = 0.0
	$PostProcess/RespawnInfo.modulate.a = 0.0
	$PostProcess/Label.text = DEATH_TEXTS[textId]
	$PostProcess/RespawnInfo.text = "\n\n\n\nPress %s to respawn" % Global.get_action_key("Blink")
	
	textId = (textId + 1) % DEATH_TEXTS.size()
	
	death_tween = create_tween()
	death_tween.tween_property($PostProcess/Label, "modulate:a", 1.0, 40.0)
	death_tween.parallel().tween_property($PostProcess/RespawnInfo, "modulate:a", 1.0, 100.0)
	
	$RespawnTimer.start()


func spawn():
	if death_tween: death_tween.kill()
	death_tween = create_tween()
	death_tween.tween_property($PostProcess/Label, "modulate:a", 0.0, 0.5)
	death_tween.parallel().tween_property($PostProcess/RespawnInfo, "modulate:a", 0.0, 0.5)
	
	var newPosition = Global.map.availableSpawns[GlobalZoneHandler.playerBestZone].pick_random()
	#if not Global.debug:
	if keepY:
		var oldY: float = global_position.y
		global_position = newPosition
		global_position.y = oldY
	else:
		global_position = newPosition
	
	if has_node("GridToken"):
		$GridToken.setInitialPosition()

	sanity = SANITY_MAX
	health = HEALTH_MAX
	
	HEADBOB_ANIMATION.play("RESET")
	JUMP_ANIMATION.play("RESET")
	CROUCH_ANIMATION.play("RESET")
	
	enter_normal_state()
	
	set_physics_process(true)
	
	$PostProcess/ColorRect.material.set_shader_parameter("blink", 1.0)
	blink(true)
	shouldOpen = true
	
	if has_node("GridRestrictor") and not $GridToken.isFree:
		$GridRestrictor.activate()
	
	dead = false

func _ready():
	Global.player = self
	Global.inGame = true
	GridEntityManager.player = self
	
	#It is safe to comment this line if your game doesn't start with the mouse captured
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# If the controller is rotated in a certain direction for game design purposes, redirect this rotation into the head.
	HEAD.rotation.y = rotation.y
	rotation.y = 0
	
	if default_reticle:
		change_reticle(default_reticle)
	
	# Reset the camera position
	# If you want to change the default head height, change these animations.
	check_controls()
	
	$PostProcess/Label.modulate.a = 0.0
	spawn()
	if not keepY:
		global_position.y = 0.0 # Only on first spawn to have a seemless transition with the tutorial
	
	if has_node("GridRestrictor"):
		$GridRestrictor.activate()

func _exit_tree() -> void:
	Global.inGame = false

func check_controls(): # If you add a control, you might want to add a check for it here.
	# The actions are being disabled so the engine doesn't halt the entire project in debug mode
	#if !InputMap.has_action(JUMP):
		#push_error("No control mapped for jumping. Please add an input map control. Disabling jump.")
		#jumping_enabled = false
	if !InputMap.has_action(LEFT):
		push_error("No control mapped for move left. Please add an input map control. Disabling movement.")
		immobile = true
	if !InputMap.has_action(RIGHT):
		push_error("No control mapped for move right. Please add an input map control. Disabling movement.")
		immobile = true
	if !InputMap.has_action(FORWARD):
		push_error("No control mapped for move forward. Please add an input map control. Disabling movement.")
		immobile = true
	if !InputMap.has_action(BACKWARD):
		push_error("No control mapped for move backward. Please add an input map control. Disabling movement.")
		immobile = true
	if !InputMap.has_action(CROUCH):
		push_error("No control mapped for crouch. Please add an input map control. Disabling crouching.")
		crouch_enabled = false
	if !InputMap.has_action(SPRINT):
		push_error("No control mapped for sprint. Please add an input map control. Disabling sprinting.")
		sprint_enabled = false


func change_reticle(reticle): # Yup, this function is kinda strange
	if RETICLE:
		RETICLE.queue_free()
	
	RETICLE = load(reticle).instantiate()
	RETICLE.character = self
	$InterfaceLayer/UserInterface.add_child(RETICLE)


func _physics_process(delta):
	# Big thanks to github.com/LorenzoAncora for the concept of the improved debug values
	current_speed = Vector3.ZERO.distance_to(get_real_velocity())
	$InterfaceLayer/UserInterface/DebugPanel.add_property("Speed", snappedf(current_speed, 0.001), 1)
	$InterfaceLayer/UserInterface/DebugPanel.add_property("Target speed", speed, 2)
	var cv : Vector3 = get_real_velocity()
	var vd : Array[float] = [
		snappedf(cv.x, 0.001),
		snappedf(cv.y, 0.001),
		snappedf(cv.z, 0.001)
	]
	var readable_velocity : String = "X: " + str(vd[0]) + " Y: " + str(vd[1]) + " Z: " + str(vd[2])
	$InterfaceLayer/UserInterface/DebugPanel.add_property("Velocity", readable_velocity, 3)
	
	# Gravity
	#gravity = ProjectSettings.get_setting("physics/3d/default_gravity") # If the gravity changes during your game, uncomment this code
	if not is_on_floor() and gravity and gravity_enabled:
		velocity.y -= gravity * delta
	
	handle_jumping()
	
	var input_dir = Vector2.ZERO
	if !immobile and !locked: # Immobility works by interrupting user input, so other forces can still be applied to the player
		input_dir = Input.get_vector(LEFT, RIGHT, FORWARD, BACKWARD)
	
	
	if handled:
		handle_movement(delta, handled_input)
		input_dir = handled_input # To trigger is moving
	else:
		handle_movement_input(delta, input_dir)
	
	
	# Magnat edit: I've putted this in process because without physic interpolation it look bad
	# handle_head_rotation()
	
	# The player is not able to stand up if the ceiling is too low
	low_ceiling = $CrouchCeilingDetection.is_colliding()
	
	handle_state(input_dir)
	if dynamic_fov: # This may be changed to an AnimationPlayer
		update_camera_fov()
	
	if view_bobbing:
		headbob_animation(input_dir)
	
	if jump_animation:
		if !was_on_floor and is_on_floor(): # The player just landed
			match randi() % 2: #TODO: Change this to detecting velocity direction
				0:
					JUMP_ANIMATION.play("land_left", 0.25)
				1:
					JUMP_ANIMATION.play("land_right", 0.25)
	
	const SANITY_FACTOR := 0.7
	sanity = minf(SANITY_MAX, sanity + (SANITY_RECOVER * (1.0 if sanity > SANITY_FACTOR else (1.0 + sqrt(4.0 * (SANITY_FACTOR - sanity/SANITY_MAX))))) * delta)
	health = minf(HEALTH_MAX, health + HEALTH_RECOVER * delta)
	was_on_floor = is_on_floor() # This must always be at the end of physics_process
	
	CAMERA.position = Vector3(0, 0, 0) + Vector3(1, 1, 1) * randf() * velocity.y * 0.002


func handle_jumping():
	if jumping_enabled:
		if continuous_jumping: # Hold down the jump button
			if Input.is_action_pressed(JUMP) and is_on_floor() and !low_ceiling:
				if jump_animation:
					JUMP_ANIMATION.play("jump", 0.25)
				velocity.y += jump_velocity # Adding instead of setting so jumping on slopes works properly
		else:
			if Input.is_action_just_pressed(JUMP) and is_on_floor() and !low_ceiling:
				if jump_animation:
					JUMP_ANIMATION.play("jump", 0.25)
				velocity.y += jump_velocity



func handle_movement_input(delta: float, input_dir: Vector2):
	var direction: Vector2 = input_dir.rotated(-HEAD.rotation.y)
	handle_movement(delta, direction)

class FootStep:
	var step: float
	var volume: float
	var pitch: float
	var stream: AudioStreamPlayer3D
	var _tween : Tween
	
	func _init(s: float, v: float, p: float, a: AudioStreamPlayer3D):
		step = s
		volume = v
		pitch = p
		stream = a
	
	func stop(): if _tween: _tween.kill()
	func update():
		_tween = stream.get_tree().create_tween()
		_tween.tween_property(stream, "volume_db", volume, 0.25)
		_tween.parallel().tween_property(stream, "pitch_scale", pitch, 0.25)

var footStepVolume : Tween
@onready var FOOTSTEP_WALK := FootStep.new(0.5, -25, 1.0, $StepsConcrete)
@onready var FOOTSTEP_CROUCH := FootStep.new(1.5, -35, 0.96, $StepsConcrete)
@onready var FOOTSTEP_RUN := FootStep.new(0.3, -16, 1.02, $StepsConcrete)

var footstep : FootStep
var lastFootstep := 0.0

func handle_movement(delta: float, dir: Vector2):
	var direction = Vector3(dir.x, 0, dir.y) if not locked else Vector3.ZERO
	
	lastFootstep += delta
	if is_on_floor() && direction.length() > 0.5 && lastFootstep > footstep.step:
		lastFootstep = 0.0
		footstep.stream.play()
	
	move_and_slide()
	
	if in_air_momentum:
		if is_on_floor():
			if motion_smoothing:
				velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
				velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
			else:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
	else:
		if motion_smoothing:
			velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
		else:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed

func handle_head_rotation():
	if not lockedCamera and not locked:
		HEAD.rotation_degrees.y -= mouseInput.x * mouse_sensitivity
		if invert_mouse_y:
			HEAD.rotation_degrees.x -= mouseInput.y * mouse_sensitivity * -1.0
		else:
			HEAD.rotation_degrees.x -= mouseInput.y * mouse_sensitivity
	
	# Uncomment for controller support
	#var controller_view_rotation = Input.get_vector(LOOK_DOWN, LOOK_UP, LOOK_RIGHT, LOOK_LEFT) * controller_sensitivity # These are inverted because of the nature of 3D rotation.
	#HEAD.rotation.x += controller_view_rotation.x
	#if invert_mouse_y:
		#HEAD.rotation.y += controller_view_rotation.y * -1.0
	#else:
		#HEAD.rotation.y += controller_view_rotation.y
	
	
	mouseInput = Vector2(0,0)
	HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func handle_state(moving):
	if sprint_enabled:
		if sprint_mode == 0:
			if (handled and handled_sprint) or (not handled and Input.is_action_pressed(SPRINT) and state != "crouching"):
				if moving && !closed_eyes:
					if state != "sprinting":
						enter_sprint_state()
				else:
					if state == "sprinting":
						enter_normal_state()
			elif state == "sprinting":
				enter_normal_state()
		elif sprint_mode == 1:
			if moving:
				# If the player is holding sprint before moving, handle that cenerio
				if Input.is_action_pressed(SPRINT) and state == "normal":
					enter_sprint_state()
				if Input.is_action_just_pressed(SPRINT):
					match state:
						"normal":
							enter_sprint_state()
						"sprinting":
							enter_normal_state()
			elif state == "sprinting":
				enter_normal_state()
	
	if crouch_enabled:
		if crouch_mode == 0:
			if Input.is_action_pressed(CROUCH) and state != "sprinting":
				if state != "crouching":
					enter_crouch_state()
			elif state == "crouching" and !$CrouchCeilingDetection.is_colliding():
				enter_normal_state()
		elif crouch_mode == 1:
			if Input.is_action_just_pressed(CROUCH):
				match state:
					"normal":
						enter_crouch_state()
					"crouching":
						if !$CrouchCeilingDetection.is_colliding():
							enter_normal_state()


# Any enter state function should only be called once when you want to enter that state, not every frame.

func set_footstep(f: FootStep):
	if footstep: footstep.stop()
	footstep = f
	footstep.update()

func enter_normal_state():
	#print("entering normal state")
	var prev_state = state
	if prev_state == "crouching":
		CROUCH_ANIMATION.play_backwards("crouch")
	state = "normal"
	speed = base_speed
	set_footstep(FOOTSTEP_WALK)

func enter_crouch_state():
	#print("entering crouch state")
	var prev_state = state
	state = "crouching"
	speed = crouch_speed
	set_footstep(FOOTSTEP_CROUCH)
	CROUCH_ANIMATION.play("crouch")

func enter_sprint_state():
	#print("entering sprint state")
	var prev_state = state
	if prev_state == "crouching":
		CROUCH_ANIMATION.play_backwards("crouch")
	state = "sprinting"
	speed = sprint_speed
	set_footstep(FOOTSTEP_RUN)


var wasFovTweenSprint: bool = false
var fovTween: Tween
func update_camera_fov():
	if state == "sprinting":
		if not wasFovTweenSprint:
			wasFovTweenSprint = true
			if fovTween: fovTween.kill()
			fovTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			fovTween.tween_property(CAMERA, "fov", 80.0, 0.2)
	else:
		if wasFovTweenSprint:
			wasFovTweenSprint = false
			if fovTween: fovTween.kill()
			fovTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			fovTween.tween_property(CAMERA, "fov", 70.0, 0.2)

func headbob_animation(moving):
	if moving and is_on_floor():
		var use_headbob_animation : String
		match state:
			"normal","crouching":
				use_headbob_animation = "walk"
			"sprinting":
				use_headbob_animation = "sprint"
		
		var was_playing : bool = false
		if HEADBOB_ANIMATION.current_animation == use_headbob_animation:
			was_playing = true
		
		HEADBOB_ANIMATION.play(use_headbob_animation, 0.25)
		HEADBOB_ANIMATION.speed_scale = (current_speed / base_speed) * 1.5
		
		if !was_playing:
			HEADBOB_ANIMATION.seek(float(randi() % 2)) # Randomize the initial headbob direction
			# Let me explain that piece of code because it looks like it does the opposite of what it actually does.
			# The headbob animation has two starting positions. One is at 0 and the other is at 1.
			# randi() % 2 returns either 0 or 1, and so the animation randomly starts at one of the starting positions.
			# This code is extremely performant but it makes no sense.
		
	else:
		if HEADBOB_ANIMATION.current_animation == "sprint" or HEADBOB_ANIMATION.current_animation == "walk":
			HEADBOB_ANIMATION.speed_scale = 1
			HEADBOB_ANIMATION.play("RESET", 1)

func noise(stream: AudioStreamPlayer, min_db: float, max_db: float, min_fact: float, max_fact: float, fact: float):
	stream.volume_db = min_db + (max_db - min_db) * minf(max_fact, fact - min_fact)/(max_fact - min_fact)


var sanity_display := sanity
var health_display := health
func _process(delta):
	$InterfaceLayer/UserInterface/DebugPanel.add_property("FPS", Performance.get_monitor(Performance.TIME_FPS), 0)
	var status : String = state
	if !is_on_floor():
		status += " in the air"
	$InterfaceLayer/UserInterface/DebugPanel.add_property("State", status, 4)
	
	handle_head_rotation()
	
	# Set the global shader parameters
	var pos = global_position
	
	sanity_display = clampf(sanity_display + (sanity - sanity_display) * minf(1.0, delta * 2.0), 0.0, SANITY_MAX)
	health_display = clampf(health_display + (health - health_display) * minf(1.0, delta * 4.0), 0.0, HEALTH_MAX)
	
	var sanity01 := (1.0 - (sanity_display/SANITY_MAX))
	
	noise($noise1, -70.0, -10.0, 0.0, 0.4, sanity01)
	noise($noise2, -70.0, -22.0, 0.2, 0.6, sanity01)
	noise($noise3, -70.0, -25.0, 0.0, 1.0, sanity01)
	
	var sanitySquare := sanity01 * sanity01
	environment.camera_attributes.dof_blur_near_distance = 8.0 * sanitySquare
	AudioServer.get_bus_effect(0, 1).pre_gain_db = 10.0 * sanitySquare
	AudioServer.get_bus_effect(0, 1).ceiling_db = -12.0 * sqrt(sanity01)
	RenderingServer.global_shader_parameter_set("player_pos", position)
	RenderingServer.global_shader_parameter_set("wall_distort", sqrt(sanity01))
	
	RenderingServer.global_shader_parameter_set("sanity", sanity01)
	Global.sanity = sanity01
	
	if Global.debug:
		$InterfaceLayer/UserInterface/DebugPanel.add_property("Sanity", sanity, 4)
		$InterfaceLayer/UserInterface/DebugPanel.add_property("sanity_display", sanity_display, 5)
		$InterfaceLayer/UserInterface/DebugPanel.add_property("Health", health, 6)
	
	$PostProcess/ColorRect.material.set_shader_parameter("distortion", sanity01 * 0.7)
	
	var dmg01 := 1.0 - health_display/HEALTH_MAX
	AudioServer.get_bus_effect(0, 4).cutoff_hz = 20500 - dmg01 * 19000.0
	AudioServer.get_bus_effect(0, 3).drive = dmg01 * dmg01 * 0.3
	
	noise($tintinnus, -70.0, -20.0, 0.1, 1.0, sqrt(dmg01))
	$PostProcess/ColorRect.material.set_shader_parameter("damage", dmg01)
	
	Ambience.set_ambience(sanity01)

var closed_eyes := false
var shouldOpen := false
var blink_tween: Tween
var fast_blink_tween: Tween
func blink(closing : bool):
	if not closing and (fast_blink_tween and fast_blink_tween.is_running()):
		shouldOpen = true
		return
	
	shouldOpen = false
	
	if blink_tween: blink_tween.kill()
	if fast_blink_tween: fast_blink_tween.kill()
	
	fast_blink_tween = create_tween()
	
	blink_tween = create_tween()
	blink_tween.set_ease(Tween.EASE_OUT)
	blink_tween.set_trans(Tween.TRANS_SINE)
	
	var time := 0.25 + (1.0 - sanity / SANITY_MAX) * 3.5 if closing and hypnotized else 0.25
	blink_tween.tween_method(func(x: float): $PostProcess/ColorRect.material.set_shader_parameter("blink", x), $PostProcess/ColorRect.material.get_shader_parameter("blink"), 1.0 if closing else 0.0, time)
	blink_tween.parallel().tween_method(func(x: float): AudioServer.get_bus_effect(0, 0).cutoff_hz = x, AudioServer.get_bus_effect(0, 0).cutoff_hz, 1000.0 if closing else 20050.0, time)
	fast_blink_tween.tween_interval(time * 0.9)
	
	if closing:
		fast_blink_tween.tween_callback(func(): closed_eyes = true)
		fast_blink_tween.parallel().tween_interval(time * 0.05)
		fast_blink_tween.tween_callback(func():
			if shouldOpen:
				shouldOpen = false
				blink.call_deferred(false)
		)
	else:
		closed_eyes = false

func _input(event: InputEvent):
	if !$RespawnTimer.is_stopped():
		return
	
	if event.is_action_pressed("Blink"):
		blink(true)
	elif event.is_action_released("Blink"):
		if dead:
			spawn()
			EventBus.playerRespawned.emit()
		
		blink(false)
	
	if event.is_action_pressed("debugSuicide"):
		suicide()
	
	if event.is_action_pressed("ui_end"): #debug
		damageSanity(10.0)
		print(sanity)
	if event.is_action_pressed("ui_home"):
		damageHealth(10.0)
		print(health)


func _unhandled_input(event : InputEvent):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouseInput.x += event.relative.x
		mouseInput.y += event.relative.y
	# Toggle debug menu
	elif event is InputEventKey:
		if event.is_released():
			# Where we're going, we don't need InputMap
			if event.keycode == 4194338: # F7
				$InterfaceLayer/UserInterface/DebugPanel.visible = !$InterfaceLayer/UserInterface/DebugPanel.visible

func suicide():
	die()
