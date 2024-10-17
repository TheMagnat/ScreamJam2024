@tool
class_name Map extends Node3D

const DistoredWallMaterial := preload("res://Scenes/Demo/DistortedWall.tres")
const GroundMaterial := preload("res://Scenes/Demo/Ground.tres")
@export var Player : BetterCharacterController

# Map parameters
@export var gridSpace: float = 1.0
@export var thickness: float = 1.0
@export var ceil: bool = false
@export_file("*.txt") var mapFilePath: String


# Map data 
var mapData := PackedInt32Array()
var mapSize: Vector2i

# Cache
@onready var groundMesh := PlaneMesh.new()
@onready var wallMesh := BoxMesh.new()
@onready var wallShape := BoxShape3D.new()
@onready var fullWallMesh := BoxMesh.new()
@onready var fullWallShape := BoxShape3D.new()

# Cached generated map
@onready var wallMultimesh := MultiMesh.new()
var wallInstanceTransforms: Array[Transform3D]

@onready var groundMultimesh := MultiMesh.new()
var groundInstanceTransforms: Array[Transform3D]

func _ready() -> void:
	generateMap()
	
func generateMap() -> void:
	groundMesh.size = Vector2(gridSpace, gridSpace)
	groundMesh.subdivide_depth = 16.0
	groundMesh.subdivide_width = 16.0
	groundMesh.custom_aabb = AABB(Vector3(-gridSpace / 2.0, 0.0, -gridSpace / 2.0), Vector3(gridSpace, 3.0, gridSpace))
	
	wallMesh.size = Vector3(gridSpace, thickness, gridSpace)
	wallShape.size = wallMesh.size
	
	fullWallMesh.size = Vector3(gridSpace, gridSpace, gridSpace)
	fullWallShape.size = fullWallMesh.size
	
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
	
	var groundInstanceTransforms := MultiMeshInstance3D.new()
	groundInstanceTransforms.multimesh = groundMultimesh
	groundInstanceTransforms.material_override = GroundMaterial
	
	add_child(groundInstanceTransforms)

enum WallType {
	Left, Up, Right, Down
}

func createCellWall(elementPosition: Vector3, side: WallType):
	var positionOffset: Vector3
	var rot := Vector3()
	if side == WallType.Left:
		positionOffset = Vector3(-(gridSpace + thickness) / 2.0, gridSpace / 2.0, 0.0)
		rot.z = PI / 2.0
		rot.x = -PI / 2.0
	elif side == WallType.Up:
		positionOffset = Vector3(0.0, gridSpace / 2.0, -(gridSpace + thickness) / 2.0)
		rot.x = PI / 2.0
	elif side == WallType.Right:
		positionOffset = Vector3((gridSpace + thickness) / 2.0, gridSpace / 2.0, 0.0)
		rot.z = PI / 2.0
		rot.x = -PI / 2.0
	elif side == WallType.Down:
		positionOffset = Vector3(0.0, gridSpace / 2.0, (gridSpace + thickness) / 2.0)
		rot.x = PI / 2.0
	
	wallInstanceTransforms.push_back( Transform3D(Basis.from_euler(rot), elementPosition + positionOffset) )
	
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
	#wallInstanceTransforms.push_back( Transform3D(Basis(), elementPosition + positionOffset) )
	add_child(newWallMesh)
	
	# Create collision Shape
	var newCollisionShape := CollisionShape3D.new()
	newCollisionShape.shape = fullWallShape
	newCollisionShape.position = elementPosition + positionOffset
	add_child(newCollisionShape)
	
func getMapData(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= mapSize.x or y >= mapSize.y:
		return 0
	return mapData[x + y * mapSize.x]

func getMapPos(x: int, y: int) -> Vector3:
	return Vector3(x * gridSpace, 0.0, y * gridSpace)

func drawWallCell(x: int, y: int, side: WallType) -> bool:
	var currentCellValue: int = getMapData(x, y)
	if currentCellValue != 0:
		return false
	var L := getMapData(x - 1, y) == 0
	var R := getMapData(x + 1, y) == 0
	var U := getMapData(x, y - 1) == 0
	var D := getMapData(x, y + 1) == 0
	return !((side == WallType.Left || side == WallType.Right) && !(U && D) || (side == WallType.Up || side == WallType.Down) && !(L && R))

func createCell(x: int, y: int):
	var elementPosition := getMapPos(x, y)
	
	# Create ground Mesh
	groundInstanceTransforms.push_back( Transform3D(Basis(), elementPosition) )
	
	# Create collision Shape
	var newCollisionShape := CollisionShape3D.new()
	newCollisionShape.shape = wallShape
	newCollisionShape.position = elementPosition
	add_child(newCollisionShape)
	
	if ceil:
		# Create ceil Mesh
		var ceilPosition: Vector3 = elementPosition + Vector3(0.0, gridSpace, 0.0)
		wallInstanceTransforms.push_back( Transform3D(Basis.from_euler(Vector3(PI, 0.0, 0.0)), ceilPosition) )
		groundInstanceTransforms.push_back( Transform3D(Basis.from_euler(Vector3(PI, 0.0, 0.0)), ceilPosition + Vector3(0.0, -(0.01 + thickness / 2.0), 0.0)) )
		
		# Create collision Shape
		var newCeilShape := CollisionShape3D.new()
		newCeilShape.shape = wallShape
		newCeilShape.position = ceilPosition
		add_child(newCeilShape)

	
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
		if element == 1:
			createCell(currentCol, currentRow)
		elif element != 2 and !(drawWallCell(currentCol, currentRow, WallType.Left) || drawWallCell(currentCol, currentRow, WallType.Up)):
			createSceneFullWall(getMapPos(currentCol, currentRow))
		
		currentCol += 1
		if currentCol == mapSize.x:
			currentCol = 0
			currentRow += 1
	

func loadMap(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var content: String = file.get_as_text()
	
	mapData.clear()
	var mapDataArray: Array[PackedInt32Array] = []
	
	var rows: PackedStringArray = content.split("\n")
	var rowLength: int = 0
	
	var rowCount: int = 0
	for row in rows:
		var rowArray := PackedInt32Array()
		
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
			mapData.append(0)
	
	print(rowCount)
	mapSize.x = rowLength
	mapSize.y = rowCount
