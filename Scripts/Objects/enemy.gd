class_name Enemy
extends CharacterBody2D

#=========================================
# the base enemy script
# ========================================
@onready var deal_damage_box: DealDamageBox = $DealDamageBox
@onready var knockback_timer: Timer = $KnockbackTimer
@onready var hit_particles: GPUParticles2D = $HitParticles
@onready var animator: AnimationPlayer = $Animator
@export var enemy_stats : Stats
var health : float
var move_direction : Vector2
var knockback : Vector2
var knockback_time : float
var is_knockback : bool

func take_damage(damage_amount : int) -> void:
	health -= damage_amount
	EventBus.emit_signal("shake_camera", 2, 5)
	
	print(health)
	
	if health <= 0:
		_die()
	else:
		animator.play("hit")

func apply_knockback(direction : Vector2, force: float, duraction : float) -> void:
	knockback = direction * force
	knockback_time = duraction
	knockback_timer.start(knockback_time)
	is_knockback = true
	hit_particles.rotation = get_angle_to(direction)

func _ready() -> void:
	deal_damage_box.connect("area_entered", _on_attack)
	knockback_timer.connect("timeout", _on_knockback_finished)
	health = enemy_stats.health

func _on_attack(area : Area2D) -> void:
	if area is TakeDamageBox:
		area.take_damage(enemy_stats.attack, global_position)

func _physics_process(delta: float) -> void:
	if is_knockback:
		_handle_knockback()
	else:
		_handle_movement()

func _handle_movement() -> void:
	var player : Player = get_tree().get_first_node_in_group("player")
	move_direction = player.global_position - global_position
	move_direction = move_direction.normalized()
	velocity = move_direction * enemy_stats.speed
	move_and_slide()

func _die() -> void:
	EventBus.emit_signal("enemy_defeated")
	queue_free()

func _handle_knockback() -> void:
	velocity = knockback
	move_and_slide()

func _on_knockback_finished() -> void:
	is_knockback = false
	knockback = Vector2.ZERO
