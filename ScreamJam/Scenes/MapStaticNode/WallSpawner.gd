extends Node3D


@export var zoneToTrigger: int

func _ready() -> void:
	GlobalZoneHandler.playerBestZoneChanged.connect(onZoneChanged)
	
func onZoneChanged(zone: int) -> void:
	if zone >= zoneToTrigger:
		triggerWall()

@onready var mesh: Node3D = $Mesh
func triggerWall() -> void:
	Global.map.setMapData(global_position)
	
	onMove = true
	initialPosition = position
	
	$StaticBody3D.position.y = 0.0
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(mesh, "position:y", 0.0, 2.0)
	tween.parallel().tween_property(self, "moveMu", 0.0, 2.0)
	tween.tween_property(self, "onMove", false, 0.0)
	tween.tween_property(self, "position", initialPosition, 0.0)
	
var onMove: bool = false
var moveMu: float = 1.0
var initialPosition: Vector3
func _process(delta: float) -> void:
	if onMove:
		position = initialPosition + Vector3(randf(), 0.0, randf()) * 0.3 * moveMu
