class_name ActionComponent extends Node3D


@export var lootComponent: LootComponent
@export var attackComponent: AttackComponent


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Action"):
		var didLoot: bool = lootComponent.tryLoot(false)
		if not didLoot:
			attackComponent.tryAttack()
	
	if event.is_action_pressed("ActionLeft"):
		var didLoot: bool = lootComponent.tryLoot(true)
		if not didLoot:
			attackComponent.tryAttack()
