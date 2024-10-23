class_name FreeEntity extends ClassicEntity

@onready var freeHandler: Node = $FreeHandler
@onready var model: FreeModel = $Model
func onDeath() -> void:
	freeHandler.dead = true
	model.die()

func onDmg(dmgs: float):
	model.takeHit()
