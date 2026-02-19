class_name DealDamageBox
extends Area2D

@export var parent : Node2D

var attack : float

func _ready() -> void:
	if parent != null:
		attack = parent.stats.attack
