class_name Attack
extends Node2D

var damage : float = -1
var player_position : Vector2

@onready var animator: AnimationPlayer = $Animator
@onready var deal_damage_box: Area2D = $DealDamageBox

const ATTACK = preload("uid://uvlprrl46njq")

static func new_attack(starting_position : Vector2, new_damage : float) -> Attack:
	var new_attack : Attack = ATTACK.instantiate()
	new_attack.global_position = starting_position
	new_attack.damage = new_damage
	new_attack.player_position = starting_position
	return new_attack

func _ready() -> void:
	animator.connect("animation_finished", _on_attack_finished)
	deal_damage_box.connect("area_entered", _on_attack)
	look_at(get_global_mouse_position())
	animator.play("attack")

func _on_attack_finished(animation_name : String) -> void:
	queue_free()

func _on_attack(area : Area2D) -> void:
	if area is TakeDamageBox:
		area.take_damage(damage, player_position)
		
