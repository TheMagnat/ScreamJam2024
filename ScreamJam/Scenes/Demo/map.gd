@tool
class_name Map extends Node3D

# Map parameters
@export var gridSpace: float = 1.0
@export var thickness: float = 1.0
@export var ceil: bool = false

# Map data 
var mapData := PackedInt32Array()
var mapSize: Vector2i

# Cache
@onready var wallMesh := BoxMesh.new()
@onready var wallShape := BoxShape3D.new()


func _ready() -> void:
	wallMesh.size = Vector3(gridSpace, thickness, gridSpace)
	wallShape.size = Vector3(gridSpace, thickness, gridSpace)
	
	loadMap("res://Scenes/Demo/map.txt")
	generateMapMesh()

# Side :  1
#        0 2
#         3
func createCellWall(elementPosition: Vector3, side: int):
	var positionOffset: Vector3
	var rotationX: float = 0
	var rotationZ: float = 0
	if side == 0:
		positionOffset = Vector3(-(gridSpace + thickness) / 2.0, gridSpace / 2.0, 0.0)
		rotationZ = PI / 2.0
	elif side == 1:
		positionOffset = Vector3(0.0, gridSpace / 2.0, -(gridSpace + thickness) / 2.0)
		rotationX = PI / 2.0
	elif side == 2:
		positionOffset = Vector3((gridSpace + thickness) / 2.0, gridSpace / 2.0, 0.0)
		rotationZ = PI / 2.0
	elif side == 3:
		positionOffset = Vector3(0.0, gridSpace / 2.0, (gridSpace + thickness) / 2.0)
		rotationX = PI / 2.0
	
	var newWallMesh := MeshInstance3D.new()
	newWallMesh.mesh = wallMesh
	newWallMesh.position = elementPosition + positionOffset
	newWallMesh.rotation.x = rotationX
	newWallMesh.rotation.z = rotationZ
	add_child(newWallMesh)
	
	# Create collision Shape
	var newCollisionShape := CollisionShape3D.new()
	newCollisionShape.shape = wallShape
	newCollisionShape.position = elementPosition + positionOffset
	newCollisionShape.rotation.x = rotationX
	newCollisionShape.rotation.z = rotationZ
	add_child(newCollisionShape)

func getMapData(x: int, y: int):
	return mapData[x + y * mapSize.x]

func createCell(x: int, y: int):
	var elementPosition := Vector3(x * gridSpace, 0.0, y * gridSpace)
	
	# Create ground Mesh
	var newGroundMesh := MeshInstance3D.new()
	newGroundMesh.mesh = wallMesh
	newGroundMesh.position = elementPosition
	add_child(newGroundMesh)
	
	# Create collision Shape
	var newCollisionShape := CollisionShape3D.new()
	newCollisionShape.shape = wallShape
	newCollisionShape.position = elementPosition
	add_child(newCollisionShape)
	
	
	if ceil:
		# Create ground Mesh
		var ceilPosition: Vector3 = elementPosition + Vector3(0.0, gridSpace, 0.0)
		var newCeilMesh := MeshInstance3D.new()
		newCeilMesh.mesh = wallMesh
		newCeilMesh.position = ceilPosition
		add_child(newCeilMesh)
		
		# Create collision Shape
		var newCeilShape := CollisionShape3D.new()
		newCeilShape.shape = wallShape
		newCeilShape.position = ceilPosition
		add_child(newCeilShape)
	
	# Create Wall Mesh
	if x == 0 or getMapData(x - 1, y) == 0:
		createCellWall(elementPosition, 0)
	
	if y == 0 or getMapData(x, y - 1) == 0:
		createCellWall(elementPosition, 1)
	
	if x == (mapSize.x - 1) or getMapData(x + 1, y) == 0:
		createCellWall(elementPosition, 2)
	
	if y == (mapSize.y - 1) or getMapData(x, y + 1) == 0:
		createCellWall(elementPosition, 3)
	
	


func generateMapMesh():
	var currentCol: int = 0
	var currentRow: int = 0
	
	for element in mapData:
		if element == 1:
			createCell(currentCol, currentRow)
		
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
