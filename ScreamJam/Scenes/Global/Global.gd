extends Node


var player: Character
var sanity: float # [0 - 1]
var map: Map
var inGame: bool = false
var inEnd: bool = false

var debug := false


func get_action_key(action: String) -> String:
	var events = InputMap.action_get_events(action)
	if events.size() > 0:
		return events[0].as_text().trim_suffix(" (Physical)")
	return ""
