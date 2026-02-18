@tool
@abstract
class_name BaseEnemy
extends CharacterBody2D

## Base Enemy Class that other enemies inherit

enum EnemyState {CHASE, ATTACK, HIT}
const HIT_PARTICLES = preload("uid://drgkhnopj5ci0")
const DEATH_PARTICLES = preload("uid://btalbe5bl7hqm")
@export var enemy_stats : Stats
var current_state : EnemyState = EnemyState.CHASE
var health : float = enemy_stats.health
var is_dead : bool = false
@onready var deal_damage_box: DealDamageBox = $DealDamageBox
@onready var knockback_timer: Timer = $KnockbackTimer

func _get_configuration_warnings() -> PackedStringArray:
	for child in get_children():
		if child is DealDamageBox:
			return []
	return ["Enemy needs DealDamageBox as a child"]

# Overridden Functions

func _physics_process(delta: float) -> void:
	match current_state:
		EnemyState.CHASE:
			_chase()
		EnemyState.ATTACK:
			_attack()
		EnemyState.HIT:
			_hit()
	_handle_animation()

# Custom Functions

# Public

func take_damage(damage_amount : float) -> void:
	if health >= 0:
		health -= damage_amount
	else:
		_die()

# Private

func _handle_animation() -> void:
	pass

func _chase() -> void:
	pass

func _attack() -> void:
	pass

func _hit() -> void:
	pass

func _die() -> void:
	pass
