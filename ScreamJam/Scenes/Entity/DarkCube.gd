extends Node3D


const sanityDmgPerSec: float = 50.0

var playerBody: Character
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Character:
		playerBody = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Character:
		playerBody = null

func _physics_process(delta: float) -> void:
	if playerBody:
		# If player got a torch that is on, don't dmg the sanity
		if playerBody.lootComponent.leftHandTool is LightSource and playerBody.lootComponent.leftHandTool.isOn:
			return
		
		playerBody.damageSanity(sanityDmgPerSec * delta, 1.0, 4.0)
