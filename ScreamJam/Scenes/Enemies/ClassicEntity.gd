class_name ClassicEntity extends Node3D


@export var SPEED = 6.0

@export var dmg: float = 10.0
@export var health: float = 30.0:
	set(value):
		print("Mob took damages: ", health - value)
		health = value
		if health <= 0:
			print("LOL MOB DEAD")
			onDeath()

func onDeath():
	print("Should call parent onDeath")
	queue_free()

var inAttackAnimation: bool = false
var attackTween: Tween
func attack(attackTarget: Node3D, originalPosition: Vector3):
	inAttackAnimation = true
	
	if attackTween: attackTween.kill()
	attackTween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	attackTween.tween_property(self, "global_position", attackTarget.global_position, 0.25)
	attackTween.tween_callback(attackTarget.damageHealth.bind(dmg))
	attackTween.tween_property(self, "global_position", originalPosition, 0.25)
	attackTween.tween_property(self, "inAttackAnimation", false, 0.0)
