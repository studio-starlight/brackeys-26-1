extends Camera2D

var rng = RandomNumberGenerator.new()

var shake_strength : float
var shake_fade : float

func apply_shake(strength : float, fade : float):
	shake_strength = strength
	shake_fade = fade

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))

func _ready() -> void:
	EventBus.connect("shake_camera", apply_shake)

func _process(delta: float) -> void:
	if shake_strength >= 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		offset = randomOffset()
