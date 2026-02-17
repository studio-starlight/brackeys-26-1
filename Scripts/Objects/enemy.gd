class_name Enemy
extends CharacterBody2D

#=========================================
# the base enemy script
# ========================================
@onready var deal_damage_box: DealDamageBox = $DealDamageBox
@onready var knockback_timer: Timer = $KnockbackTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var hit_timer: Timer = $HitTimer
@onready var prepare_timer: Timer = $PrepareTimer
@onready var hit_particles: GPUParticles2D = $HitParticles
@onready var animator: AnimationPlayer = $Animator
@onready var hit_animator: AnimationPlayer = $HitAnimator
@onready var detect_area: Area2D = $DetectArea
@onready var sprite: Sprite2D = $Sprite
@export var enemy_stats : Stats
var hit_time : float = 0.8
var attack_speed : float = 110
var attack_time : float = 0.2
var health : float
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

var rng = RandomNumberGenerator.new()
var random_number

func take_damage(damage_amount : int) -> void:
	health -= damage_amount
	EventBus.emit_signal("shake_camera", 2, 5)
	
	current_state = EnemyState.HIT
	hit_timer.start(hit_time)
	if health <= 0:
		_die()
	else:
		hit_animator.play("hit")

func apply_knockback(direction : Vector2, force: float, duraction : float) -> void:
	knockback = direction * force
	knockback_time = duraction
	knockback_timer.start(knockback_time)
	is_knockback = true
	hit_particles.rotation = get_angle_to(direction)

func get_circle_position(random : float) -> Vector2:
	var kill_circle_center : Vector2 = target_position
	var radius : int = 10
	var angle = random * PI * 2
	var x = kill_circle_center.x + cos(angle) * radius
	var y = kill_circle_center.y + sin(angle) * radius
	
	return Vector2(x,y)

func _ready() -> void:
	deal_damage_box.connect("area_entered", _on_attack)
	knockback_timer.connect("timeout", _on_knockback_finished)
	hit_timer.connect("timeout", _on_hit_finished)
	attack_timer.connect("timeout", _on_attack_finished)
	prepare_timer.connect("timeout", _on_prepare_finished)
	detect_area.connect("body_entered", _on_detection_entered)
	detect_area.connect("body_exited", _on_detection_exited)
	health = enemy_stats.health
	player = get_tree().get_first_node_in_group("player")
	
	rng.randomize()
	
	random_number = rng.randf()
	target_position = get_circle_position(random_number)

func _on_attack(area : Area2D) -> void:
	if area is TakeDamageBox:
		area.take_damage(enemy_stats.attack, global_position)

func _physics_process(delta: float) -> void:
	match current_state:
		EnemyState.CHASE:
			_chase()
		EnemyState.PREPARE:
			_prepare()
		EnemyState.ATTACK:
			_attack()
		EnemyState.HIT:
			_hit()
	if player_is_in_range && current_state == EnemyState.CHASE:
		current_state = EnemyState.PREPARE
	_handle_animation()

func _die() -> void:
	EventBus.emit_signal("enemy_defeated")
	queue_free()

func _chase() -> void:
	target_position = player.global_position
	var circle_position = get_circle_position(random_number)
	move_direction = circle_position - global_position
	move_direction = move_direction.normalized()
	velocity = move_direction * enemy_stats.speed
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

func _hit() -> void:
	_handle_knockback()

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

func _handle_knockback() -> void:
	velocity = knockback
	move_and_slide()

func _on_knockback_finished() -> void:
	is_knockback = false
	knockback = Vector2.ZERO

func _on_hit_finished() -> void:
	current_state = EnemyState.CHASE

func _on_attack_finished() -> void:
	is_attacking = false
	current_state = EnemyState.CHASE

func _on_prepare_finished() -> void:
	is_preparing = false
	current_state = EnemyState.ATTACK

func _on_detection_entered(body : Node2D) -> void:
	if body is Player:
		player_is_in_range = true

func _on_detection_exited(body : Node2D) -> void:
	if body is Player:
		player_is_in_range = false
