class_name HeartGUI
extends Control

@onready var sprite: Sprite2D = $Sprite

func update(whole : bool) -> void:
	if whole:
		sprite.frame = 0
	else:
		sprite.frame = 1
