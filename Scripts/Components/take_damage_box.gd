class_name TakeDamageBox
extends Area2D

@export var parent : CharacterBody2D

func take_damage(damage_amount : float) -> void:
	print("Area entered!")
	parent.take_damage(damage_amount)
