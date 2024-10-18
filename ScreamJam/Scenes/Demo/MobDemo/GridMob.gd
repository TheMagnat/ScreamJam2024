class_name GridEntity extends Node3D


const SPEED = 6.0

@export var dmg: float = 10.0
@export var health: float = 30.0:
	set(value):
		print("Mob took damages: ", health - value)
		health = value
		if health <= 0:
			print("LOL MOB DEAD")
			onDeath()


# Cache
@onready var gridToken: GridToken = $GridToken
@onready var gridHandler: GridHandler = $GridHandler

func _ready() -> void:
	# EventBus.playerGridStep.connect(step)
	
	# TODO: retirer et rendre dynamique
	gridHandler.target = $"../Character"
	
	GridEntityManager.newEntity(self)


func onDeath() -> void:
	GridEntityManager.entityDied(self)
	queue_free()

func step():
	gridHandler.step()
