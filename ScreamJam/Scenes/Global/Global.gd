extends Node


var player: Character
var map: Map
var inGame: bool = false
var debug := true


func get_action_key(action: String) -> String:
	var events = InputMap.action_get_events(action)
	if events.size() > 0:
		return events[0].as_text().trim_suffix(" (Physical)")
	return ""
