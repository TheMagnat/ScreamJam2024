extends Node3D


@export var zoneToTrigger: int
@export var inverse: bool = false

# Cache
@onready var audioStramPlayer: AudioStreamPlayer3D = $AudioStreamPlayer3D
var goalY: float = 0.0

func _ready() -> void:
	GlobalZoneHandler.playerBestZoneChanged.connect(onZoneChanged)
	if inverse:
		goalY = mesh.position.y
		mesh.position.y = 0.0
		$StaticBody3D.position.y = 0.0
		Global.map.setMapData(global_position, 0)
	else:
		goalY = 0.0

func onZoneChanged(zone: int) -> void:
	if zone >= zoneToTrigger:
		triggerWall()

@onready var mesh: Node3D = $Mesh
func triggerWall() -> void:
	if inverse:
		Global.map.setMapData(global_position,  Map.CellType.Normal + Map.CellType.AvailableFlag)
	else:
		Global.map.setMapData(global_position, 0)
	
	onMove = true
	initialPosition = position
	
	audioStramPlayer.play()
	
	$StaticBody3D.position.y = goalY
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(mesh, "position:y", goalY, 3.0)
	tween.parallel().tween_property(self, "moveMu", 0.0, 3.0)
	tween.tween_property(self, "onMove", false, 0.0)
	#tween.tween_property(self, "position", initialPosition, 0.0)
	
var onMove: bool = false
var moveMu: float = 1.0
var initialPosition: Vector3
func _process(delta: float) -> void:
	if onMove:
		position = initialPosition + Vector3(randf(), 0.0, randf()) * 0.3 * moveMu
