@abstract
class_name BaseEnemy
extends CharacterBody2D

## Base Enemy Class that other enemies inherit
##
## Enemies share certain traits and behaviours from which they
## take from this class, no meant to be used directly.

enum EnemyState {CHASE, ATTACK, HIT}
const HIT_PARTICLES = preload("uid://drgkhnopj5ci0")
const DEATH_PARTICLES = preload("uid://btalbe5bl7hqm")
@export var stats : Stats
@export var hit_animator: AnimationPlayer
@export var deal_damage_box: DealDamageBox
@export var death_timer: Timer
@export var stun_timer: Timer
var current_state : EnemyState = EnemyState.CHASE
var player : Player
var is_dead : bool = false

# Overridden Functions

func _ready() -> void:
	deal_damage_box.area_entered.connect(_on_damage_box_entered)
	stun_timer.timeout.connect(_on_stun_finished)
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if is_dead:
		_hit(delta)
		return
	match current_state:
		EnemyState.CHASE:
			_chase()
		EnemyState.ATTACK:
			_attack()
		EnemyState.HIT:
			_hit(delta)
	_handle_animation()

# Custom Functions

# Public

## Function to take damage, calls the _die() function when healthh is
## less than or equal to zero
func take_damage(damage_amount : float) -> void:
	if stats.health >= 0:
		stats.health -= damage_amount
	else:
		var delay_before_death : float = 0.5
		EventBus.emit_signal("enemy_defeated")
		is_dead = true
		death_timer.start(delay_before_death)
		await death_timer.timeout
		_die()

func apply_knockback(knockback_direction : Vector2) -> void:
	var force : float = 71
	velocity = knockback_direction * force

func change_state(new_state : EnemyState) -> void:
	var previous_state = current_state
	current_state = new_state

# Private

func _handle_animation() -> void:
	pass

func _chase() -> void:
	pass

func _attack() -> void:
	pass

func _hit(delta : float) -> void:
	var lerp_weight : float = 5.6
	velocity = lerp(velocity, Vector2.ZERO, lerp_weight * delta)
	move_and_slide()

func _die() -> void:
	var death_particles = DEATH_PARTICLES.instantiate()
	death_particles.global_position = global_position
	death_particles.emitting = true
	get_parent().add_child(death_particles)
	queue_free()

func _on_damage_box_entered(area : DealDamageBox) -> void:
	var stun_time = 1.2
	var hit_particles = HIT_PARTICLES.instantiate()
	var damage_direction = (global_position - area.global_position).normalized()
	hit_particles.rotation = get_angle_to(damage_direction) + PI
	hit_particles.emitting = true
	hit_animator.call_deferred("play", "hit")
	stun_timer.start(stun_time)
	change_state(EnemyState.HIT)
	take_damage(area.attack)
	apply_knockback(damage_direction)
	add_child(hit_particles)

func _on_stun_finished() -> void:
	change_state(EnemyState.CHASE)
