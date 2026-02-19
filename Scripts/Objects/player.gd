class_name Player
extends CharacterBody2D

## The Player Controller
##
## The Player Controller takes input, manages the player state, and
## executes certain behaviours depending on states and conditions

enum PlayerState {FREE, ATTACKING, HIT}
@export var stats : Stats
var current_state : PlayerState
var disabled : bool = false
var is_invincible : bool = false
var facing_right : bool = true
var move_direction : Vector2
var attack_time : float = 0.4
var invincibility_duration : float = 1.3
var knockback : Vector2
var knockback_time : float
@onready var attack_timer: Timer = $AttackTimer
@onready var attack_buffer_timer: Timer = $AttackBufferTimer
@onready var knockback_timer: Timer = $KnockbackTimer
@onready var invincibility_timer: Timer = $invincibilityTimer
@onready var take_damage_box: TakeDamageBox = $TakeDamageBox
@onready var pivot: Node2D = $Pivot
@onready var animator: AnimationPlayer = $Animator
@onready var hit_animator: AnimationPlayer = $HitAnimator

func take_damage(damage_amount : int) -> void:
	stats.health -= damage_amount
	if stats.health <= 0:
		_die()

func apply_knockback(direction: Vector2) -> void:
	var knockback_force : float = 10
	var knockback_deceleration : float = 0.7
	velocity = velocity.move_toward(direction * knockback_force, knockback_deceleration)

func change_state(new_state : PlayerState) -> void:
	var previous_state = current_state
	current_state = new_state

func _ready() -> void:
	attack_timer.connect("timeout", _on_attack_finished)
	knockback_timer.connect("timeout", _on_knockback_finished)
	invincibility_timer.connect("timeout", _on_invincibility_finished)
	take_damage_box.connect("area_entered", _on_damage_box_entered)
	stats.health = stats.max_health

func _physics_process(_delta: float) -> void:
	if disabled:
		animator.play("idle")
		return
	match current_state:
		PlayerState.FREE:
			_free_state()
		PlayerState.ATTACKING:
			_attacking_state()
		PlayerState.HIT:
			_hit_state()
	_handle_animation()

# State Logic

func _free_state() -> void:
	_handle_face_direction()
	_handle_movement()
	_handle_attack()

func _attacking_state() -> void:
	pass

func _hit_state() -> void:
	move_and_slide()

# Basic Logic

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
	if Input.is_action_pressed("attack"):
		animator.play("attack")
		change_state(PlayerState.ATTACKING)

func _handle_animation() -> void:
	if facing_right:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true
	match current_state:
		PlayerState.FREE:
			if move_direction != Vector2.ZERO:
				animator.play("run")
			else:
				animator.play("idle")
		PlayerState.ATTACKING:
			pass

func _spawn_attack() -> void:
	var new_attack = Attack.new_attack(pivot.global_position, stats.attack)
	attack_timer.start(attack_time)
	get_parent().add_child(new_attack)

func _die() -> void:
	get_tree().call_deferred("reload_current_scene")

func _calculate_speed() -> float:
	var speed : float = stats.speed
	return speed

func _on_attack_finished() -> void:
	change_state(PlayerState.FREE)

func _on_knockback_finished() -> void:
	knockback = Vector2.ZERO

func _on_invincibility_finished() -> void:
	is_invincible = false

func _on_damage_box_entered(area : DealDamageBox) -> void:
	if !is_invincible:
		var knockback_direction = global_position - area.global_position
		EventBus.emit_signal("shake_camera", 10, 5)
		EventBus.emit_signal("slow_time", 0.5, 0.25)
		is_invincible = true
		invincibility_timer.start(invincibility_duration)
		hit_animator.play("hit")
		take_damage(area.attack)
		apply_knockback(knockback_direction)
		
