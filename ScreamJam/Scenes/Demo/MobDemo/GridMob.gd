class_name GridEntity extends CharacterBody3D


const SPEED = 500.0

@export var map: Map

# Cache
@onready var gridToken: GridToken = $GridToken
@onready var gridHandler: GridHandler = $GridHandler
var gridEntityManager: GridEntityManager

func _ready() -> void:
	# EventBus.playerGridStep.connect(step)
	
	# TODO: retirer et rendre dynamique
	gridHandler.target = $"../Character"
	
	EventBus.newGridEntity.emit(self)


func step():
	gridHandler.step()
