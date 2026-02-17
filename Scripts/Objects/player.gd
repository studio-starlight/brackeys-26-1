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
var is_knockback : bool = false
var is_attacking : bool = false
var can_attack : bool = true
var facing_right : bool = true
var move_direction : Vector2
var base_damage : float = 5.0
var attack_time : float = 0.5
var knockback : Vector2
var knockback_time : float
@onready var attack_timer: Timer = $AttackTimer
@onready var knockback_timer: Timer = $KnockbackTimer
@onready var hit_animator: AnimationPlayer = $HitAnimator
@onready var pivot: Node2D = $Pivot
@onready var animator: AnimationPlayer = $Animator

func get_health() -> int:
	return health

func take_damage(damage_amount : int) -> void:
	health -= damage_amount
	EventBus.emit_signal("shake_camera", 8, 3)
	
	if health <= 0:
		_die()
	else:
		hit_animator.call_deferred("play", "hit")

func apply_knockback(direction : Vector2, force: float, duraction : float) -> void:
	knockback = direction * force
	knockback_time = duraction
	knockback_timer.start(knockback_time)
	is_knockback = true

func _ready() -> void:
	# connect signals
	attack_timer.connect("timeout", _on_attack_finished)
	knockback_timer.connect("timeout", _on_knockback_finished)
	health = MAX_HEALTH

func _physics_process(_delta: float) -> void:
	if disabled:
		animator.play("idle")
		return
	if is_knockback:
		_handle_knockback()
	else:
		_handle_movement()
	_handle_face_direction()
	_handle_attack()
	_handle_animation()

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
	if Input.is_action_pressed("attack") && can_attack && !is_attacking:
		print("Clicked Attack!")
		animator.play("attack")
		can_attack = false
		is_attacking = true

func _handle_knockback() -> void:
	velocity = knockback
	move_and_slide()

func _handle_animation() -> void:
	if facing_right:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true
	if is_knockback:
		animator.play("hit")
		return
	elif is_attacking:
		return
	
	if move_direction != Vector2.ZERO:
		animator.play("run")
	else:
		animator.play("idle")

func _attack() -> void:
	print("_attack() called!")
	var new_attack = Attack.new_attack(pivot.global_position, base_damage)
	attack_timer.start(attack_time)
	get_parent().add_child(new_attack)

func _die() -> void:
	get_tree().call_deferred("reload_current_scene")

func _calculate_speed() -> float:
	var speed : float = BASE_SPEED
	return speed

func _on_attack_finished() -> void:
	can_attack = true
	is_attacking = false

func _on_knockback_finished() -> void:
	is_knockback = false
	knockback = Vector2.ZERO
