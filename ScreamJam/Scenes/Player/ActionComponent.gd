class_name ActionComponent extends Node3D


@export var lootComponent: LootComponent
@export var attackComponent: AttackComponent


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Action"):
		var didLoot: bool = lootComponent.tryLoot()
		if not didLoot:
			attackComponent.tryAttack()
