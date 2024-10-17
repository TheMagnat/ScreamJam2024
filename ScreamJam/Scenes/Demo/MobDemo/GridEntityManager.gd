class_name GridEntityManager extends Node

@onready var player: BetterCharacterController = $"../Character"

var entities: Array[GridEntity]

func _init() -> void:
	EventBus.newGridEntity.connect(newEntity)

func _ready() -> void:
	EventBus.playerGridStep.connect(onStep)
	
func newEntity(entity: GridEntity):
	entity.gridEntityManager = self
	entities.append(entity)

func onStep():
	entities.sort_custom(func(entityA: GridEntity, entityB: GridEntity):
		return entityA.global_position.distance_squared_to(player.global_position) < entityB.global_position.distance_squared_to(player.global_position)
	)
	
	for entity in entities:
		entity.step()

func isAvailable(gridPosition: Vector2i):
	for entity in entities: 
		if entity.gridToken.goalPosition == gridPosition:
			return false
	
	return true
