class_name GridEntity extends ClassicEntity


# Cache
@onready var gridToken: GridToken = $GridToken
@onready var gridHandler: GridHandler = $GridHandler

func _ready() -> void:
	#var vp = get_viewport()
	#vp.debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	
	GridEntityManager.newEntity(self)

@onready var mobModel: GridModel = $MobModel
func onDeath() -> void:
	GridEntityManager.entityDied(self)
	gridHandler.process_mode = Node.PROCESS_MODE_DISABLED
	mobModel.die()

func onDmg(dmgs: float):
	mobModel.takeHit()

func step():
	gridHandler.step()
