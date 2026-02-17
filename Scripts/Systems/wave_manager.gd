class_name WaveManager
extends Node2D

const SPAWN_PARTICLES = preload("uid://bckujjmcy28jy")

@export var waves : Array[WaveData]
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
@onready var slow_mo_timer: Timer = $SlowMoTimer
@onready var spawn_area_ratio: PathFollow2D = $SpawnArea/SpawnAreaRatio
@onready var spawn_point: Node2D = $SpawnArea/SpawnAreaRatio/SpawnPoint

var in_wave : bool
var current_wave : int
var enemy_count : int
var slow_mo_scale : float = 0.2
var slow_mo_time : float = 0.5

func _ready() -> void:
	EventBus.connect("enemy_defeated", _enemy_defeated)

func start_wave(current_story_event : GameManager.StoryEvent) -> void:
	in_wave = true
	
	match current_story_event:
		GameManager.StoryEvent.WAVE1:
			current_wave = 1
		GameManager.StoryEvent.WAVE2:
			current_wave = 2
		GameManager.StoryEvent.WAVE3:
			current_wave = 3
	var current_wave_data = waves[current_wave]
	enemy_count = current_wave_data.enemy_count
	
	for i in current_wave_data.enemy_count:
		var new_enemy = current_wave_data.enemy_types.pick_random().instantiate()
		var new_spawn_particles = SPAWN_PARTICLES.instantiate()
		spawn_area_ratio.progress_ratio = randf()
		new_enemy.global_position = spawn_point.global_position
		new_spawn_particles.global_position = spawn_point.global_position
		new_spawn_particles.emitting = true
		get_parent().add_child(new_enemy)
		get_parent().add_child(new_spawn_particles)
		enemy_spawn_timer.start(current_wave_data.enemy_delay)
		await enemy_spawn_timer.timeout

func end_wave() -> void:
	Engine.time_scale = slow_mo_scale
	slow_mo_timer.start(slow_mo_time)
	await slow_mo_timer.timeout
	Engine.time_scale = 1.0
	EventBus.emit_signal("wave_end")

func _process(delta: float) -> void:
	if !in_wave:
		return

func _enemy_defeated() -> void:
	enemy_count -= 1
	if enemy_count <= 0:
		end_wave()
