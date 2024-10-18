class_name GridEntity extends ClassicEntity


@export var map: Map


# Cache
@onready var gridToken: GridToken = $GridToken
@onready var gridHandler: GridHandler = $GridHandler

func _ready() -> void:
	#DEBUG
	#RenderingServer.set_debug_generate_wireframes(true)
	#get_viewport().debug_draw = 4
	
	# EventBus.playerGridStep.connect(step)
	
	# TODO: retirer et rendre dynamique
	gridHandler.target = $"../Character"
	
	GridEntityManager.newEntity(self)


func onDeath() -> void:
	GridEntityManager.entityDied(self)
	queue_free()

func step():
	gridHandler.step()
