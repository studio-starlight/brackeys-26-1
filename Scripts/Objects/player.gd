class_name Player
extends CharacterBody2D

## The Player Controller
##
## The Player Controller takes input, manages the player state, and
## executes certain behaviours depending on states and conditions

enum PlayerState {FREE, ATTACKING, HIT, DEATH}
@export var stats : Stats
const RUN_PARTICLES = preload("uid://bjb870yd5o3nw")
var current_state : PlayerState
var disabled : bool = false
var is_invincible : bool = false
var facing_right : bool = true
var move_direction : Vector2
var attack_time : float = 0.4
var invincibility_duration : float = 1.3
var knockback : Vector2
@onready var attack_timer: Timer = $AttackTimer
@onready var attack_buffer_timer: Timer = $AttackBufferTimer
@onready var invincibility_timer: Timer = $invincibilityTimer
@onready var take_damage_box: TakeDamageBox = $TakeDamageBox
@onready var pivot: Node2D = $Pivot
@onready var animator: AnimationPlayer = $Animator
@onready var hit_animator: AnimationPlayer = $HitAnimator

func play_animation(animation_name : String, face_right : bool) -> void:
	animator.play(animation_name)
	$Sprite.flip_h = !face_right

func take_damage(damage_amount : int) -> void:
	stats.health -= damage_amount
	if stats.health <= 0:
		_die()

func apply_knockback(direction: Vector2) -> void:
	var knockback_force : float = 10
	velocity = direction * knockback_force

func play_footstep() -> void:
	var run_particles := RUN_PARTICLES.instantiate()
	run_particles.global_position = global_position
	run_particles.emitting = true
	get_tree().current_scene.add_child(run_particles)
	AudioManager.play_sound(AudioManager.SOUND_FOOTSTEP, 0.04)

func change_state(new_state : PlayerState) -> void:
	var previous_state = current_state
	current_state = new_state

func _ready() -> void:
	attack_timer.connect("timeout", _on_attack_finished)
	invincibility_timer.connect("timeout", _on_invincibility_finished)
	take_damage_box.connect("area_entered", _on_damage_box_entered)
	stats.health = stats.max_health

func _physics_process(_delta: float) -> void:
	if disabled:
		if facing_right:
			$Sprite.flip_h = false
		else:
			$Sprite.flip_h = true
		return
	match current_state:
		PlayerState.FREE:
			_free_state()
		PlayerState.ATTACKING:
			_attacking_state(_delta)
		PlayerState.HIT:
			_hit_state()
	_handle_animation()

# State Logic

func _free_state() -> void:
	_handle_face_direction()
	_handle_movement()
	_handle_attack()

func _attacking_state(delta : float) -> void:
	var lerp_weight : float = 6.7
	velocity = velocity.lerp(Vector2.ZERO, lerp_weight * delta)
	move_and_slide()

func _hit_state() -> void:
	move_and_slide()

# Basic Logic

func _handle_movement() -> void:
	move_direction = Input.get_vector("left", "right", "up", "down")
	move_direction = move_direction.normalized()
	velocity = move_direction * stats.speed
	move_and_slide()

func _handle_face_direction() -> void:
	if facing_right && get_global_mouse_position().x < global_position.x:
		facing_right = false
	elif !facing_right && get_global_mouse_position().x > global_position.x:
		facing_right = true

func _handle_attack() -> void:
	if Input.is_action_pressed("attack"):
		var lunge_direction : Vector2 = (get_global_mouse_position() - global_position).normalized()
		var lunge_strength : float = 30
		velocity = lunge_direction * lunge_strength
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
	AudioManager.play_sound(AudioManager.SOUND_SWING)
	attack_timer.start(attack_time)
	get_parent().add_child(new_attack)

func _die() -> void:
	change_state(PlayerState.DEATH)
	animator.call_deferred("play", "death")
	await animator.animation_finished
	TransitionManager.play_transition("slide_exit", "res://Scenes/Levels/game.tscn")

func _on_attack_finished() -> void:
	change_state(PlayerState.FREE)

func _on_invincibility_finished() -> void:
	is_invincible = false

func _on_damage_box_entered(area : DealDamageBox) -> void:
	if !is_invincible:
		var knockback_direction = global_position - area.global_position
		AudioManager.play_sound(AudioManager.SOUND_PLAYER_HURT)
		EventBus.emit_signal("shake_camera", 10, 5)
		EventBus.emit_signal("slow_time", 0.5, 0.25)
		is_invincible = true
		invincibility_timer.start(invincibility_duration)
		hit_animator.call_deferred("play", "hit")
		take_damage(area.attack)
		apply_knockback(knockback_direction)
		
