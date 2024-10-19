extends CanvasLayer

@export var availableAnimations: Array[Control]

enum Type {
	None = -1,
	
	Shadow = 0,
	Spike = 1,
	SpikeBall = 2,
	Alpha = 3
}

func _ready() -> void:
	for animation in availableAnimations:
		animation.hide()

func start(callback: Callable, duration: float, animationInIndex: Type = Type.Shadow, animationOutIndex: Type = Type.None, animationParameters: Array = []):
	if animationInIndex >= availableAnimations.size():
		push_error("Transition - %d is out of range" % animationInIndex)
		return
	
	if animationOutIndex == Type.None or animationInIndex >= availableAnimations.size():
		if animationInIndex < 0:
			push_error("Should have at least one animation set")
			return
		
		animationOutIndex = animationInIndex
	
	var outAnimation: TransitionAnimation = availableAnimations[animationOutIndex]
	if animationOutIndex >= 0:
		var inAnimation: TransitionAnimation = availableAnimations[animationInIndex]
	
		# Set animation parameters
		if animationParameters:
			inAnimation.setParameters(animationParameters)
			if animationInIndex != animationOutIndex:
				outAnimation.setParameters(animationParameters)
		
		# Show before in phase
		inAnimation.show()
		
		# In phase
		if OS.is_debug_build(): print("Start in transition animation")
		inAnimation.playIn(duration)
		await inAnimation.finished
		
		# Hide in, show out
		inAnimation.hide()
	
	else:
		if animationParameters:
			outAnimation.setParameters(animationParameters)
	
	# Out phase
	if OS.is_debug_build(): print("Start out transition animation")
	callback.call()
	
	outAnimation.show()
	
	outAnimation.playOut(duration)
	await outAnimation.finished
	
	# Hide after out phase
	outAnimation.hide()
