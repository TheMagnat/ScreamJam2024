@tool
class_name Map extends Node3D

const CubeMesh := preload("res://Assets/SimpleCube.obj")
#const DistoredWallMaterial := preload("res://Scenes/Map/DistortedWall.tres")
#const DistoredWallMaterial := preload("res://Scenes/Map/Wall.tres")
#const DistoredWallMaterial := preload("res://Scenes/Map/WallAndDist.tres")
const DistoredWallMaterial := preload("res://Scenes/Map/WallAndDistHight.tres")


const GroundMaterial := preload("res://Scenes/Map/Ground.tres")
const CeilMaterial := preload("res://Scenes/Map/Ceil.tres")

# Map parameters
@export var gridSpace: float = 1.0
@export var thickness: float = 1.0
@export var ceil: bool = false
@export_file("*.txt") var mapFilePath: String


# Map data 
var mapData : Array[CellType]
var mapSize: Vector2i

# Cache
@onready var groundMesh := PlaneMesh.new()
@onready var groundShape := BoxShape3D.new()

@onready var wallMesh := CubeMesh
@onready var wallShape := BoxShape3D.new()

@onready var fullWallMesh := CubeMesh
@onready var fullWallShape := BoxShape3D.new()

@onready var ceilMesh := BoxMesh.new()

# Cached generated map
@onready var wallMultimesh := MultiMesh.new()
var wallInstanceTransforms: Array[Transform3D]

@onready var groundMultimesh := MultiMesh.new()
var groundInstanceTransforms: Array[Transform3D]

@onready var ceilMultimesh := MultiMesh.new()
var ceilInstanceTransforms: Array[Transform3D]

@onready var fullCeilMultimesh := MultiMesh.new()
var fullCeilInstanceTransforms: Array[Transform3D]

# Utility functions
func isAvailable(goal2dPosition: Vector2i):
	return getMapData(goal2dPosition.x, goal2dPosition.y) != CellType.Empty


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

var availablePos: PackedVector3Array
func getRandomPos() -> Vector3:
	return availablePos[randi_range(0, availablePos.size() - 1)]

# Generation
func _ready() -> void:
	generateMap()
	
	Global.map = self

func generateMap() -> void:
	groundMesh.size = Vector2(gridSpace, gridSpace)
	groundMesh.subdivide_depth = 16.0
	groundMesh.subdivide_width = 16.0
	groundMesh.custom_aabb = AABB(Vector3(-gridSpace / 2.0, 0.0, -gridSpace / 2.0), Vector3(gridSpace, 3.0, gridSpace))
	
	
	groundShape.size = Vector3(gridSpace, thickness, gridSpace)
	ceilMesh.size = Vector3(gridSpace, thickness, gridSpace)
	
	wallShape.size = Vector3(gridSpace, gridSpace, thickness)
	fullWallShape.size = Vector3(gridSpace, gridSpace, gridSpace)
	
	loadMap(mapFilePath)
	generateMapMesh()
	
	# Wall MultiMesh
	wallMultimesh.mesh = wallMesh
	wallMultimesh.transform_format = MultiMesh.TRANSFORM_3D
	wallMultimesh.instance_count = wallInstanceTransforms.size()
	for i in wallInstanceTransforms.size():
		wallMultimesh.set_instance_transform(i, wallInstanceTransforms[i])
	
	var wallMultiMeshInstance := MultiMeshInstance3D.new()
	wallMultiMeshInstance.multimesh = wallMultimesh
	wallMultiMeshInstance.material_override = DistoredWallMaterial
	
	add_child(wallMultiMeshInstance)
	
	# Ground MultiMesh
	groundMultimesh.mesh = groundMesh
	groundMultimesh.transform_format = MultiMesh.TRANSFORM_3D
	groundMultimesh.instance_count = groundInstanceTransforms.size()
	
	for i in groundInstanceTransforms.size():
		groundMultimesh.set_instance_transform(i, groundInstanceTransforms[i])
	
	var groundMultiMeshInstance := MultiMeshInstance3D.new()
	groundMultiMeshInstance.multimesh = groundMultimesh
	groundMultiMeshInstance.material_override = GroundMaterial
	
	add_child(groundMultiMeshInstance)
	
	# Ceil MultiMesh
	ceilMultimesh.mesh = groundMesh
	ceilMultimesh.transform_format = MultiMesh.TRANSFORM_3D
	ceilMultimesh.instance_count = ceilInstanceTransforms.size()
	
	for i in ceilInstanceTransforms.size():
		ceilMultimesh.set_instance_transform(i, ceilInstanceTransforms[i])
	
	var ceilMultiMeshInstance := MultiMeshInstance3D.new()
	ceilMultiMeshInstance.multimesh = ceilMultimesh
	ceilMultiMeshInstance.material_override = CeilMaterial
	
	add_child(ceilMultiMeshInstance)
	
	# Full Ceil MultiMesh
	fullCeilMultimesh.mesh = ceilMesh
	fullCeilMultimesh.transform_format = MultiMesh.TRANSFORM_3D
	fullCeilMultimesh.instance_count = fullCeilInstanceTransforms.size()
	
	for i in fullCeilInstanceTransforms.size():
		fullCeilMultimesh.set_instance_transform(i, fullCeilInstanceTransforms[i])
	
	var fullCeilMultiMeshInstance := MultiMeshInstance3D.new()
	fullCeilMultiMeshInstance.multimesh = fullCeilMultimesh
	#fullCeilMultiMeshInstance.material_override = CeilMaterial
	
	add_child(fullCeilMultiMeshInstance)

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
	
	wallInstanceTransforms.push_back( Transform3D(Basis.from_euler(rot) * Basis.from_scale(Vector3(gridSpace, gridSpace, thickness)), elementPosition + positionOffset) )
	
	# Create collision Shape
	var newCollisionShape := CollisionShape3D.new()
	newCollisionShape.shape = wallShape
	newCollisionShape.position = elementPosition + positionOffset
	newCollisionShape.rotation = rot
	add_child(newCollisionShape)

func createSceneFullWall(elementPosition: Vector3):
	var positionOffset := Vector3(0.0, gridSpace / 2.0, 0.0)
	
	var newWallMesh := MeshInstance3D.new()
	newWallMesh.mesh = fullWallMesh
	newWallMesh.material_override = DistoredWallMaterial
	newWallMesh.position = elementPosition + positionOffset
	newWallMesh.scale = Vector3(gridSpace, gridSpace, gridSpace)
	#wallInstanceTransforms.push_back( Transform3D(Basis(), elementPosition + positionOffset) )
	add_child(newWallMesh)
	
	# Create collision Shape
	var newCollisionShape := CollisionShape3D.new()
	newCollisionShape.shape = fullWallShape
	newCollisionShape.position = elementPosition + positionOffset
	add_child(newCollisionShape)

enum CellType {
	Empty = 0,
	
	Normal = 1,
	Opening = 2,
	Spawn = 3
}

func getMapData(x: int, y: int) -> CellType:
	if x < 0 or y < 0 or x >= mapSize.x or y >= mapSize.y:
		return CellType.Empty
	return mapData[x + y * mapSize.x]

func getMapPos(x: int, y: int) -> Vector3:
	return Vector3(x * gridSpace, 0.0, y * gridSpace)

func drawWallCell(x: int, y: int, side: WallType) -> bool:
	var currentCellValue: CellType = getMapData(x, y)
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
	groundInstanceTransforms.push_back( Transform3D(Basis(), elementPosition) )
	
	# Create collision Shape
	var newCollisionShape := CollisionShape3D.new()
	newCollisionShape.shape = groundShape
	newCollisionShape.position = elementPosition - Vector3(0.0, thickness / 2.0, 0.0)
	add_child(newCollisionShape)
	
	if ceil:
		# Create ceil Mesh
		var ceilPosition: Vector3 = elementPosition + Vector3(0.0, gridSpace, 0.0)
		fullCeilInstanceTransforms.push_back( Transform3D(Basis(), ceilPosition) )
		ceilInstanceTransforms.push_back( Transform3D(Basis.from_euler(Vector3(PI, 0.0, 0.0)), ceilPosition + Vector3(0.0, -(0.01 + thickness / 2.0), 0.0)) )
		
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
		if element == CellType.Normal:
			createCell(currentCol, currentRow)
		elif element != CellType.Opening and !(drawWallCell(currentCol, currentRow, WallType.Left) || drawWallCell(currentCol, currentRow, WallType.Up)):
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
			mapData.append(element)
		
		for i in range(row.size(), rowLength):
			mapData.append(CellType.Empty)
	
	mapSize.x = rowLength
	mapSize.y = rowCount
