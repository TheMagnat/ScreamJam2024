extends Control

@export var transitionScene: PackedScene

@export var splashDuration: float = 2.0

# Cache
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	PauseMenu.enable(false)
	Ambience.stop_ambience()
	
	animationPlayer.play("SplashGlitchIn")
	animationPlayer.animation_finished.connect(animationFinished)

func _exit_tree():
	PauseMenu.enable(true)

func animationFinished(event):
	get_tree().create_timer(splashDuration).timeout.connect(startOutAnimation)

func startOutAnimation():
	animationPlayer.play("SplashGlitchOut")
	animationPlayer.animation_finished.disconnect(animationFinished)
	animationPlayer.animation_finished.connect(loadNextScene)
	
func loadNextScene(event):
	Transition.start(get_tree().change_scene_to_packed.bind(transitionScene), 1.0, Transition.Type.Alpha, Transition.Type.Alpha)
	
