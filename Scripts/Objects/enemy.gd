class_name EnemyRunner
extends CharacterBody2D

#=========================================
# the base enemy script
# ========================================
const HIT_PARTICLES = preload("uid://drgkhnopj5ci0")
const DEATH_PARTICLES = preload("uid://btalbe5bl7hqm")
@onready var take_damage_box: TakeDamageBox = $TakeDamageBox
@onready var attack_timer: Timer = $AttackTimer
@onready var hit_timer: Timer = $HitTimer
@onready var prepare_timer: Timer = $PrepareTimer
@onready var death_timer: Timer = $DeathTimer
@onready var animator: AnimationPlayer = $Animator
@onready var hit_animator: AnimationPlayer = $HitAnimator
@onready var detect_area: Area2D = $DetectArea
@onready var sprite: Sprite2D = $Sprite
@export var stats : Stats
var hit_time : float = 1.0
var attack_speed : float = 110
var attack_time : float = 0.2
var move_direction : Vector2
var knockback : Vector2
var knockback_time : float
var is_knockback : bool
var player : Player
var target_position : Vector2
var player_is_in_range : bool
var facing_right : bool
var is_attacking : bool
var is_preparing : bool
var prepare_time : float = 0.5

enum EnemyState {CHASE, PREPARE, ATTACK, HIT}
var current_state : EnemyState

func take_damage(damage_amount) -> void:
	stats.health -= damage_amount
	if stats.health <= 0:
		var delay_before_death : float = 0.3
		EventBus.emit_signal("enemy_defeated")
		death_timer.start(delay_before_death)
		await death_timer.timeout
		_die()

func apply_knockback(knockback_direction : Vector2) -> void:
	var force : float = 68
	velocity = knockback_direction * force

func get_circle_position() -> Vector2:
	var rng = RandomNumberGenerator.new()
	var random_number
	rng.randomize()
	random_number = rng.randf()
	var kill_circle_center : Vector2 = target_position
	var radius : int = 10
	var angle : float = random_number * PI * 2
	var x : float = kill_circle_center.x + cos(angle) * radius
	var y : float = kill_circle_center.y + sin(angle) * radius
	return Vector2(x,y)

func change_state(new_state : EnemyState) -> void:
	var previous_state = current_state
	current_state = new_state

func _ready() -> void:
	hit_timer.connect("timeout", _on_hit_finished)
	attack_timer.connect("timeout", _on_attack_finished)
	prepare_timer.connect("timeout", _on_prepare_finished)
	detect_area.connect("body_entered", _on_detection_entered)
	detect_area.connect("body_exited", _on_detection_exited)
	take_damage_box.connect("area_entered", _on_damage_box_entered)
	stats = stats.duplicate()
	stats.health = stats.max_health
	player = get_tree().get_first_node_in_group("player")
	target_position = get_circle_position()

func _physics_process(delta: float) -> void:
	match current_state:
		EnemyState.CHASE:
			_chase()
		EnemyState.PREPARE:
			_prepare()
		EnemyState.ATTACK:
			_attack()
		EnemyState.HIT:
			_hit(delta)
	_handle_animation()

func _die() -> void:
	var death_particles = DEATH_PARTICLES.instantiate()
	death_particles.global_position = global_position
	death_particles.emitting = true
	get_parent().add_child(death_particles)
	queue_free()

func _chase() -> void:
	var circle_position = get_circle_position()
	target_position = player.global_position
	move_direction = (circle_position - global_position).normalized()
	velocity = move_direction * stats.speed
	
	if player_is_in_range:
		current_state = EnemyState.PREPARE
	
	move_and_slide()

func _attack() -> void:
	if !is_attacking:
		is_attacking = true
		attack_timer.start(attack_time)
	animator.play("attack")
	move_direction = target_position - global_position
	move_direction = move_direction.normalized()
	velocity = move_direction * attack_speed
	move_and_slide()

func _prepare() -> void:
	animator.play("prepare_attack")
	if !is_preparing:
		is_preparing = true
		prepare_timer.start(prepare_time)
	target_position = player.global_position

func _hit(delta : float) -> void:
	var lerp_weight : float = 5.6
	velocity = lerp(velocity, Vector2.ZERO, lerp_weight * delta)
	move_and_slide()

func _handle_animation() -> void:
	if move_direction.x > 0 && !facing_right:
		facing_right = true
		sprite.flip_h = false
	elif move_direction.x < 0 && facing_right:
		facing_right = false
		sprite.flip_h = true
	match current_state:
		EnemyState.CHASE:
			animator.play("run")
		EnemyState.HIT:
			animator.play("hit")

func _on_hit_finished() -> void:
	change_state(EnemyState.CHASE)

func _on_attack_finished() -> void:
	is_attacking = false
	if current_state == EnemyState.ATTACK:
		change_state(EnemyState.CHASE)

func _on_prepare_finished() -> void:
	is_preparing = false
	if current_state == EnemyState.PREPARE:
		change_state(EnemyState.ATTACK)

func _on_detection_entered(body : Node2D) -> void:
	if body is Player:
		player_is_in_range = true

func _on_detection_exited(body : Node2D) -> void:
	if body is Player:
		player_is_in_range = false

func _on_damage_box_entered(area : DealDamageBox) -> void:
	var hit_particles = HIT_PARTICLES.instantiate()
	var damage_direction = (global_position - area.global_position).normalized()
	hit_particles.rotation = damage_direction.angle()
	hit_particles.emitting = true
	hit_animator.call_deferred("play", "hit")
	hit_timer.start(hit_time)
	change_state(EnemyState.HIT)
	take_damage(area.attack)
	apply_knockback(damage_direction)
	add_child(hit_particles)
