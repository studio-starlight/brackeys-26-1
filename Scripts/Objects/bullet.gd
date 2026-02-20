class_name Bullet
extends Node2D

@export var bullet_lifespan : float = 1.0
const BULLET = preload("uid://cmdm3upt1sk6t")
const BULLET_PARTICLES = preload("uid://b4c8mesmi7k0f")
var damage : float = -1
var speed : float = 100
var move_direction : Vector2
var is_destroyed : bool = false
@onready var deal_damage_box: DealDamageBox = $DealDamageBox
@onready var destroy_timer: Timer = $DestroyTimer
@onready var detect_area: Area2D = $DetectArea

func _ready() -> void:
	deal_damage_box.attack = damage
	destroy_timer.timeout.connect(_on_lifespan_finished)
	detect_area.area_entered.connect(_on_detect)

func _physics_process(delta: float) -> void:
	position += move_direction * speed * delta

static func new_bullet(from : Vector2, to : Vector2, damage : float) -> Bullet:
	var new_bullet : Bullet = BULLET.instantiate()
	new_bullet.move_direction = (to - from).normalized()
	new_bullet.global_position = from
	new_bullet.damage = damage
	return new_bullet

func _on_lifespan_finished() -> void:
	print("Bullet _on_lifespan_finished() called")
	if is_destroyed:
		return
	is_destroyed = true
	queue_free()

func _on_detect(body : Node2D) -> void:
	if is_destroyed:
		return
	var new_particles := BULLET_PARTICLES.instantiate()
	new_particles.global_position = global_position
	new_particles.emitting = true
	is_destroyed = true
	AudioManager.play_sound(AudioManager.SOUND_BULLET_DESTROY)
	get_tree().current_scene.add_child(new_particles)
	queue_free()
