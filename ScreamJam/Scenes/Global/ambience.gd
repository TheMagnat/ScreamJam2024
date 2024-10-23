extends Node

const MIN_DB := 60.0
@onready var peaceful := $Peaceful.get_children()
@onready var AMBIENCE_PEACEFUL := AudioServer.get_bus_index("AmbiencePeaceful")

func set_ambience(scary01: float):
	AudioServer.set_bus_volume_db(AMBIENCE_PEACEFUL, -40.0 * scary01)
	$SpookyDookie.pitch_scale = 1.0 - scary01 * scary01 * 0.4
	$SpookyDookie.volume_db = -80 + 58.0 * sqrt(clampf((scary01 - 0.15) * 2.0, 0.0, 1.0))

var VOLUMES := {}
func _ready():
	set_ambience(0.0)
	
	for ambience in peaceful:
		ambience.bus = "AmbiencePeaceful"
		VOLUMES[ambience] = ambience.volume_db
	
	next_ambience()

var current_ambience: AudioStreamPlayer
var next_ambience_timer : SceneTreeTimer
func next_ambience():
	next_ambience_timer = get_tree().create_timer(randf_range(20.0, 40.0))
	next_ambience_timer.timeout.connect(start_ambience)

func start_ambience():
	if stop_ambience_tween and stop_ambience_tween.is_running():
		stop_ambience_tween.kill()
	
	if current_ambience == null:
		current_ambience = peaceful.pick_random()
	else:
		var peaceful2 := peaceful.duplicate()
		peaceful2.shuffle()
		if peaceful2[0] == current_ambience and peaceful2.size() > 1:
			current_ambience = peaceful2[1]
	
	current_ambience.volume_db = VOLUMES[current_ambience]
	current_ambience.play()
	if !current_ambience.finished.is_connected(next_ambience):
		current_ambience.finished.connect(next_ambience)

var stop_ambience_tween: Tween
func stop_ambience():
	if current_ambience != null:
		current_ambience.finished.disconnect(next_ambience)
		stop_ambience_tween = create_tween()
		stop_ambience_tween.tween_property(current_ambience, "volume_db", VOLUMES[current_ambience] - 40.0, 2.0)
		current_ambience = null
	
	if next_ambience_timer and next_ambience_timer.time_left > 0.0:
		next_ambience_timer.timeout.disconnect(start_ambience)
		next_ambience_timer = null
