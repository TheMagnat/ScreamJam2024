class_name GridToken extends Node3D


var isFree: bool = false

# The entity should be aiming to this grid position
var goalPosition: Vector2i = Vector2i.ZERO:
	set(value):
		goalPosition = value
		goalWorldPosition = Vector3(goalPosition.x * Global.map.gridSpace, 0.0, goalPosition.y * Global.map.gridSpace)
	get():
		if not isFree:
			return goalPosition
		var temporary3iPosition: Vector3i = (global_position / Global.map.gridSpace).round()
		return Vector2i(temporary3iPosition.x, temporary3iPosition.z)

var goalWorldPosition: Vector3 = Vector3.ZERO

func setInitialPosition():
	var temporary3iPosition: Vector3i = (global_position / Global.map.gridSpace).round()
	goalPosition = Vector2i(temporary3iPosition.x, temporary3iPosition.z)
