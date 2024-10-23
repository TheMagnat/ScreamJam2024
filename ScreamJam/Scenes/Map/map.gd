@tool
class_name Map extends StaticBody3D

const CubeMesh := preload("res://Assets/SimpleCube.obj")
#const DistoredWallMaterial := preload("res://Scenes/Map/DistortedWall.tres")
#const DistoredWallMaterial := preload("res://Scenes/Map/Wall.tres")
#const DistoredWallMaterial := preload("res://Scenes/Map/WallAndDist.tres")
const DistoredWallMaterial := preload("res://Scenes/Map/WallAndDistHight.tres")


const GroundMaterial := preload("res://Scenes/Map/Ground.tres")
const CeilMaterial := preload("res://Scenes/Map/Ceil.tres")

const CellTypeFilter := 0b1111

# Map parameters
@export var gridSpace: float = 1.0
@export var thickness: float = 1.0
@export var ceil: bool = false
@export_file("*.txt") var mapFilePath: String


# Map data 
var mapData : Array[CellType]
var mapSize: Vector2i
@export var availableSpawns : Array[Array]

# Cache
@onready var groundMesh := PlaneMesh.new()
@onready var groundShape := BoxShape3D.new()

@onready var wallMesh := CubeMesh
@onready var wallShape := BoxShape3D.new()

@onready var fullWallMesh := CubeMesh
@onready var fullWallShape := BoxShape3D.new()

@onready var ceilMesh := BoxMesh.new()

# Cached generated map
@export var cached: bool = false
@export var cachedFile: String = ""

# Utility functions
func isWorldPosAvailable(worldPosition: Vector3) -> bool:
	return isAvailable(Vector2i(round(worldPosition.x / gridSpace), round(worldPosition.z / gridSpace)))

func isAvailable(goal2dPosition: Vector2i):
	#spawns are walkable
	var cellType = getMapData(goal2dPosition.x, goal2dPosition.y)
	return cellType & CellType.AvailableFlag

func setMapData(worldPosition: Vector3, newValue: int = 0) -> void:
	var x: int = round(worldPosition.x / gridSpace)
	var y: int = round(worldPosition.z / gridSpace)
	
	if x < 0 or y < 0 or x >= mapSize.x or y >= mapSize.y:
		return
	
	mapData[x + y * mapSize.x] = newValue

func getNeighbors(centerCel: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i]
	
	var left  := centerCel + Vector2i(-1, 0)
	var right := centerCel + Vector2i(1, 0)
	var up    := centerCel + Vector2i(0, 1)
	var down  := centerCel + Vector2i(0, -1)
	
	if isAvailable(left):
		neighbors.push_back(left)
	if isAvailable(right):
		neighbors.push_back(right)
	if isAvailable(up):
		neighbors.push_back(up)
	if isAvailable(down):
		neighbors.push_back(down)
	
	return neighbors

@export_storage var availablePos: PackedVector3Array
func getRandomPos() -> Vector3:
	return availablePos[randi_range(0, availablePos.size() - 1)]

func _exit_tree() -> void:
	GridEntityManager.entities.clear()
	EventBus.noGridModeTriggered = false

# Generation
func _ready() -> void:
	generateMap()
	
	if not Engine.is_editor_hint():
		Global.map = self

func generateMap() -> void:
	groundMesh.size = Vector2(gridSpace, gridSpace)
	groundMesh.subdivide_depth = 16
	groundMesh.subdivide_width = 16
	groundMesh.custom_aabb = AABB(Vector3(-gridSpace / 2.0, 0.0, -gridSpace / 2.0), Vector3(gridSpace, 3.0, gridSpace))
	
	
	groundShape.size = Vector3(gridSpace, thickness, gridSpace)
	ceilMesh.size = Vector3(gridSpace, thickness, gridSpace)
	
	wallShape.size = Vector3(gridSpace, gridSpace, thickness)
	fullWallShape.size = Vector3(gridSpace, gridSpace, gridSpace)
	
	loadMap(mapFilePath)
	
	if cached:
		return
	
	for child in get_children():
		child.free()
	
	availablePos.clear()
	availableSpawns.clear()
	
	availableSpawns = [[], [], [], [], []]
	
	generateMapMesh()
	
	cached = true

enum WallType {
	Left, Up, Right, Down
}

func createCellWall(elementPosition: Vector3, side: WallType):
	var positionOffset: Vector3
	var rot := Vector3()
	if side == WallType.Left:
		positionOffset = Vector3(-(gridSpace + thickness) / 2.0, gridSpace / 2.0, 0.0)
		#rot.z = PI / 2.0
		rot.y = -PI / 2.0
	elif side == WallType.Up:
		positionOffset = Vector3(0.0, gridSpace / 2.0, -(gridSpace + thickness) / 2.0)
		#rot.x = PI / 2.0
	elif side == WallType.Right:
		positionOffset = Vector3((gridSpace + thickness) / 2.0, gridSpace / 2.0, 0.0)
		#rot.z = PI / 2.0
		rot.y = -PI / 2.0
	elif side == WallType.Down:
		positionOffset = Vector3(0.0, gridSpace / 2.0, (gridSpace + thickness) / 2.0)
		#rot.x = PI / 2.0
	
	var newWallMeshInstance := MeshInstance3D.new()
	newWallMeshInstance.mesh = wallMesh
	newWallMeshInstance.position = elementPosition + positionOffset
	newWallMeshInstance.rotation = rot
	newWallMeshInstance.scale = Vector3(gridSpace, gridSpace, thickness)
	newWallMeshInstance.material_override = DistoredWallMaterial
	add_child(newWallMeshInstance)
	newWallMeshInstance.owner = self
	
	# Create collision Shape
	var newCollisionShape := CollisionShape3D.new()
	newCollisionShape.shape = wallShape
	newCollisionShape.position = elementPosition + positionOffset
	newCollisionShape.rotation = rot
	
	add_child(newCollisionShape)
	newCollisionShape.owner = self

func createSceneFullWall(elementPosition: Vector3):
	var positionOffset := Vector3(0.0, gridSpace / 2.0, 0.0)
	
	var newWallMesh := MeshInstance3D.new()
	newWallMesh.mesh = fullWallMesh
	newWallMesh.material_override = DistoredWallMaterial
	newWallMesh.position = elementPosition + positionOffset
	newWallMesh.scale = Vector3(gridSpace, gridSpace, gridSpace)
	
	add_child(newWallMesh)
	newWallMesh.owner = self
	
	# Create collision Shape
	var newCollisionShape := CollisionShape3D.new()
	newCollisionShape.shape = fullWallShape
	newCollisionShape.position = elementPosition + positionOffset
	
	add_child(newCollisionShape)
	newCollisionShape.owner = self

enum CellType {
	Empty = 0,
	Normal = 1,
	Opening = 2,
	Hole = 3,
	MobSpawn = 4,
	#player spawns must be contiguous
	SpawnPointZ0 = 6,
	SpawnPointZ1 = 7,
	SpawnPointZ2 = 8,
	SpawnPointZ3 = 9,
	SpawnPointZ4 = 10,
	AvailableFlag = 16,
	DrawableFlag = 32
}

func getMapData(x: int, y: int) -> CellType:
	if x < 0 or y < 0 or x >= mapSize.x or y >= mapSize.y:
		return CellType.Empty
	return mapData[x + y * mapSize.x]

func getMapPos(x: int, y: int) -> Vector3:
	return Vector3(x * gridSpace, 0.0, y * gridSpace)

func drawWallCell(x: int, y: int, side: WallType) -> bool:
	var currentCellValue: CellType = getType(getMapData(x, y))
	if currentCellValue != CellType.Empty:
		return false
	var L := getMapData(x - 1, y) == CellType.Empty
	var R := getMapData(x + 1, y) == CellType.Empty
	var U := getMapData(x, y - 1) == CellType.Empty
	var D := getMapData(x, y + 1) == CellType.Empty
	return !((side == WallType.Left || side == WallType.Right) && !(U && D) || (side == WallType.Up || side == WallType.Down) && !(L && R))

func createCell(x: int, y: int):
	var elementPosition: Vector3 = getMapPos(x, y)
	availablePos.push_back( elementPosition )
	
	# Create ground Mesh
	var newGroundMeshInstance := MeshInstance3D.new()
	newGroundMeshInstance.mesh = groundMesh
	newGroundMeshInstance.position = elementPosition
	newGroundMeshInstance.material_override = GroundMaterial
	add_child(newGroundMeshInstance)
	newGroundMeshInstance.owner = self
	
	# Create collision Shape
	var newCollisionShape := CollisionShape3D.new()
	newCollisionShape.shape = groundShape
	newCollisionShape.position = elementPosition - Vector3(0.0, thickness / 2.0, 0.0)
	
	add_child(newCollisionShape)
	newCollisionShape.owner = self
	
	if ceil:
		# Create ceil Mesh
		var ceilPosition: Vector3 = elementPosition + Vector3(0.0, gridSpace, 0.0)
		
		var newCeilMeshInstance := MeshInstance3D.new()
		newCeilMeshInstance.mesh = groundMesh
		newCeilMeshInstance.position = ceilPosition + Vector3(0.0, -(0.01 + thickness / 2.0), 0.0)
		newCeilMeshInstance.rotation = Vector3(PI, 0.0, 0.0)
		newCeilMeshInstance.material_override = CeilMaterial
		add_child(newCeilMeshInstance)
		newCeilMeshInstance.owner = self
		
		var newFullCeilMeshInstance := MeshInstance3D.new()
		newFullCeilMeshInstance.mesh = ceilMesh
		newFullCeilMeshInstance.position = ceilPosition
		newFullCeilMeshInstance.rotation = Vector3(PI, 0.0, 0.0)
		add_child(newFullCeilMeshInstance)
		newFullCeilMeshInstance.owner = self
		
		# Create collision Shape
		#var newCeilShape := CollisionShape3D.new()
		#newCeilShape.shape = groundShape
		#newCeilShape.position = ceilPosition
		#add_child(newCeilShape)

	
	# Create Wall Mesh
	if drawWallCell(x - 1, y, WallType.Left):
		createCellWall(elementPosition, WallType.Left)
	
	if drawWallCell(x, y - 1, WallType.Up):
		createCellWall(elementPosition, WallType.Up)
	
	if drawWallCell(x + 1, y, WallType.Right):
		createCellWall(elementPosition, WallType.Right)
	
	if drawWallCell(x, y + 1, WallType.Down):
		createCellWall(elementPosition, WallType.Down)

func generateMapMesh():
	var currentCol: int = 0
	var currentRow: int = 0
	
	for element in mapData:
		var type = getType(element)
		if element & CellType.DrawableFlag:
			createCell(currentCol, currentRow)
			if type >= CellType.SpawnPointZ0 && type <= CellType.SpawnPointZ4:
				availableSpawns[type - CellType.SpawnPointZ0].append(Vector3(currentCol * gridSpace, 1.0, currentRow * gridSpace))

		elif type != CellType.Opening and !(drawWallCell(currentCol, currentRow, WallType.Left) || drawWallCell(currentCol, currentRow, WallType.Up)):
			createSceneFullWall(getMapPos(currentCol, currentRow))
		
		currentCol += 1
		if currentCol == mapSize.x:
			currentCol = 0
			currentRow += 1

func loadMap(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var content: String = file.get_as_text()
	
	mapData.clear()
	var mapDataArray: Array = []
	
	var rows: PackedStringArray = content.split("\n")
	var rowLength: int = 0
	
	var rowCount: int = 0
	for row in rows:
		var rowArray : Array[CellType]
		
		var columns: PackedStringArray = row.split(" ")
		if columns.is_empty() or columns[0].is_empty():
			continue
		
		rowCount += 1
		
		rowLength = max(rowLength, columns.size())
		for column in columns:
			rowArray.append(int(column))
		
		mapDataArray.append(rowArray)
	
	# Now concat every array together
	for row in mapDataArray:
		for element in row:
			if(element == CellType.Normal || element == CellType.MobSpawn || element == CellType.SpawnPointZ0 || element == CellType.SpawnPointZ1 || element == CellType.SpawnPointZ2 || element == CellType.SpawnPointZ3 || element == CellType.SpawnPointZ4):
				element ^= CellType.AvailableFlag
				element ^= CellType.DrawableFlag
			if(element == CellType.Hole):
				element ^= CellType.DrawableFlag
			mapData.append(element)
		
		for i in range(row.size(), rowLength):
			mapData.append(CellType.Empty)
	
	mapSize.x = rowLength
	mapSize.y = rowCount

func getType(cell:CellType):
	return cell & CellTypeFilter
