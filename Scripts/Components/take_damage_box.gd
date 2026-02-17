class_name TakeDamageBox
extends Area2D

@export var parent : CharacterBody2D

func take_damage(damage_amount : float, attack_position : Vector2) -> void:
	parent.take_damage(damage_amount, attack_position)
	parent.apply_knockback(attack_position)
