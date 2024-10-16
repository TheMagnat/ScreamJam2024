extends CanvasLayer

@export var availableAnimations: Array[Control]



func _ready() -> void:
	for animation in availableAnimations:
		animation.hide()

func start(callback: Callable, duration: float, animationInIndex: int = 0, animationOutIndex: int = -1, animationParameters: Array = []):
	if animationInIndex >= availableAnimations.size():
		push_error("Transition - %d is out of range" % animationInIndex)
		return
	
	if animationOutIndex < 0 or animationInIndex >= availableAnimations.size():
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
