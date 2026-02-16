class_name Enemy
extends CharacterBody2D

#=========================================
# the base enemy script
# ========================================

@export var max_health : float
@export var attack : float
@export var defense : float
@export var speed : float
var health : float
var move_direction : Vector2

func take_damage(damage_amount : int) -> void:
	health -= damage_amount
	print("Enemy Damaged!")
	if health <= 0:
		queue_free()

func _ready() -> void:
	health = max_health

func _physics_process(delta: float) -> void:
	_handle_movement()

func _handle_movement() -> void:
	var player : Player = get_tree().get_first_node_in_group("player")
	move_direction = player.global_position - global_position
	move_direction = move_direction.normalized()
	velocity = move_direction * speed
	move_and_slide()
