extends Control

@export var transitionScene: PackedScene

@export var splashDuration: float = 2.0

# Cache
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animationPlayer.play("SplashGlitchIn")
	animationPlayer.animation_finished.connect(animationFinished)

func animationFinished(event):
	get_tree().create_timer(splashDuration).timeout.connect(startOutAnimation)
	
func startOutAnimation():
	animationPlayer.play("SplashGlitchOut")
	animationPlayer.animation_finished.disconnect(animationFinished)
	animationPlayer.animation_finished.connect(loadNextScene)
	
func loadNextScene(event):
	get_tree().change_scene_to_packed(transitionScene)
