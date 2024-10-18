extends Node


var player: Character

var entities: Array[GridEntity]

func _ready() -> void:
	EventBus.playerGridStep.connect(onStep)
	
func newEntity(entity: GridEntity):
	entities.append(entity)

func entityDied(entityDied: GridEntity):
	entities.erase(entityDied)

func getEntityAt(gridPosition: Vector2i) -> GridEntity:
	for entity in entities: 
		if entity.gridToken.goalPosition == gridPosition:
			return entity
	return null

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
