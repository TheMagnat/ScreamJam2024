class_name LightSource extends Node3D


var isOn: bool = true

@export var omniLight: OmniLight3D
@export var torch: TorchSprite

@onready var originalColor: Color = omniLight.light_color
@export var crazyColor: Color

var noise := FastNoiseLite.new()
@onready var originalEnergy: float = omniLight.light_energy
@export var energyRange: float = 0.5

func _ready() -> void:
	GlobalZoneHandler.blow.connect(blowTorch)
	noise.seed = randi()

var t: float
func _process(delta: float) -> void:
	if not isOn: return
	
	t += delta * 150
	
	var sampled_noise = noise.get_noise_1d(t)
	sampled_noise = sampled_noise
	
	omniLight.light_energy = (sampled_noise * energyRange) + originalEnergy 
	t += (sampled_noise + 1) * 0.5 * delta
	
	omniLight.light_color = lerp(originalColor, crazyColor, Global.sanity)


var blowTween: Tween
func blowTorch():
	if blowTween: blowTween.kill()
	blowTween = create_tween().set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_BOUNCE)
	blowTween.tween_property(omniLight, "light_energy", 0.0, 1.5)
	blowTween.tween_property(self, "isOn", false, 0.0)
	
	torch.blow()
