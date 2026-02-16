class_name TakeDamageBox
extends Area2D

@export var parent : CharacterBody2D

func take_damage(damage_amount : float, attack_position : Vector2) -> void:
	var attack_direction = parent.global_position - attack_position
	attack_direction = attack_position.normalized()
	parent.take_damage(damage_amount)
	parent.apply_knockback(attack_direction, 100, 0.12)
