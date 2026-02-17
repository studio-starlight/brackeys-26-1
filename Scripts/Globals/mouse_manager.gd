extends Node2D

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func _process(delta: float) -> void:
	sprite.global_position = get_global_mouse_position()
