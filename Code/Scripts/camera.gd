extends Camera2D

@export var random_strength: float = 30.0
@export var fade: float = 5.0
@export var bomb_shake_length : float = 0.2

var rng = RandomNumberGenerator.new()

var shake_strength = 0

var shaking = false

func apply_shake():
	shake_strength = random_strength

func _process(delta: float) -> void:
	if shaking:
		apply_shake()
	
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, fade * delta)
		offset = randomOffset()


func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))

func shakeTimed(time : float):
	$Timer.start(time)
	shaking = true

func _on_timer_timeout() -> void:
	shaking = false
