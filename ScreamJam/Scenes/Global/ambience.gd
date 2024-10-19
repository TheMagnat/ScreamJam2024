extends Node

const MIN_DB := 60.0
@onready var peaceful := $Peaceful.get_children()
@onready var AMBIENCE_PEACEFUL := AudioServer.get_bus_index("AmbiencePeaceful")


func set_ambience(scary01: float):
	AudioServer.set_bus_volume_db(AMBIENCE_PEACEFUL, -40.0 * scary01)
	$SpookyDookie.pitch_scale = 1.0 - scary01 * scary01 * 0.4
	$SpookyDookie.volume_db = -80 + 60.0 * sqrt(clampf((scary01 - 0.3) * 3.0, 0.0, 1.0))

func _ready():
	set_ambience(0.0)
	
	for ambience in peaceful:
		ambience.bus = "AmbiencePeaceful"
		ambience.finished.connect(next_ambience)

var previous_ambience: AudioStreamPlayer
func next_ambience():
	get_tree().create_timer(randf_range(20.0, 40.0)).timeout.connect(start_ambience)

func start_ambience():
	if previous_ambience == null:
		previous_ambience = peaceful.pick_random()
	else:
		var peaceful2 := peaceful.duplicate()
		peaceful2.shuffle()
		if peaceful2[0] == previous_ambience and peaceful2.size() > 1:
			previous_ambience = peaceful2[1]
	previous_ambience.play()
