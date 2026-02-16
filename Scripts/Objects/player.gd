class_name Player
extends CharacterBody2D

#=========================================
# The main player controller that controls
# player input and action
# ========================================

const BASE_SPEED : float = 80
const MAX_HEALTH : int = 30
var health : int 
var disabled : bool = false
var can_attack : bool = true
var facing_right : bool = true
var move_direction : Vector2
var base_damage : float
var attack_time : float = 0.5
@onready var attack_timer: Timer = $AttackTimer

func get_health() -> int:
	return health

func take_damage(damage_amount : int) -> void:
	health -= damage_amount

func _ready() -> void:
	#connect signals
	attack_timer.connect("timeout", _on_attack_finished)
	health = MAX_HEALTH

func _physics_process(_delta: float) -> void:
	if disabled:
		return
	_handle_movement()
	_handle_face_direction()
	_handle_attack()

func _handle_movement() -> void:
	move_direction = Input.get_vector("left", "right", "up", "down")
	move_direction = move_direction.normalized()
	velocity = move_direction * _calculate_speed()
	move_and_slide()

func _handle_face_direction() -> void:
	if facing_right && get_global_mouse_position().x < global_position.x:
		facing_right = false
	elif !facing_right && get_global_mouse_position().x > global_position.x:
		facing_right = true

func _handle_attack() -> void:
	if Input.is_action_pressed("attack") && can_attack:
		_attack()

func _attack() -> void:
	var new_attack = Attack.new_attack(global_position, base_damage)
	can_attack = false
	attack_timer.start(attack_time)
	get_parent().add_child(new_attack)
	

func _calculate_speed() -> float:
	var speed : float = BASE_SPEED
	return speed

func _on_attack_finished() -> void:
	can_attack = true
