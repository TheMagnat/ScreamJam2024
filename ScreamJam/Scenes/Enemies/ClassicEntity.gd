class_name ClassicEntity extends Node3D


@export var SPEED = 6.0

@export var dmg: float = 10.0
@export var sanityDmg: float = 20.0
@export var health: float = 30.0:
	set(value):
		if dead: return
		health = value
		
		if not is_node_ready(): return
		
		if health <= 0:
			dead = true
			onDeath()
		else:
			onDmg(health - value)

var dead: bool = false

var dmgTween: Tween
func onDmg(_dmgValue: float):
	if dmgTween: dmgTween.kill()
	
	dmgTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	dmgTween.tween_property(self, "scale", Vector3.ONE * 1.25, 0.05)
	dmgTween.tween_property(self, "scale", Vector3.ONE, 0.25)

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
	attackTween.tween_callback(attackTarget.damageSanity.bind(sanityDmg))
	attackTween.tween_property(self, "global_position", originalPosition, 0.25)
	attackTween.tween_property(self, "inAttackAnimation", false, 0.0)

func stopAttackAnimation():
	if attackTween: attackTween.kill()
	inAttackAnimation = false
