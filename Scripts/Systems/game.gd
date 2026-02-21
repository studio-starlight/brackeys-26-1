extends Node2D

@export var delay_between_cutscenes : float = 1.0
@onready var cutscene_manager: CutsceneManager = $CutsceneManager
@onready var wave_manager: WaveManager = $WaveManager
@onready var upgrade_manager: Node2D = $UpgradeManager
@onready var bat_cuscene_event: Node2D = $BatCusceneEvent
@onready var hud: HUD = $HUD
@onready var player: Player = $Player
@onready var cutscene_delay_timer: Timer = $CutsceneManager/CutsceneDelayTimer
@onready var slow_mo_timer: Timer = $WaveManager/SlowMoTimer
@onready var player_cutsene_marker: Node2D = $CutsceneManager/PlayerCutseneMarker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TransitionManager.play_transition("slide_enter")
	EventBus.connect("wave_start", _start_wave)
	EventBus.connect("wave_end", _on_wave_end)
	EventBus.connect("cutscene_start", _start_cutscene)
	EventBus.connect("cutscene_end", _on_cutscene_end)
	EventBus.connect("upgrade_selected", _on_selected_upgrade)
	EventBus.connect("slow_time", _on_slow_time)
	Engine.time_scale = 1.0
	hud.visible = false
	upgrade_manager.setup_upgrades()
	if GameManager.current_story_event == GameManager.StoryEvent.START:
		_start_cutscene()
	else:
		cutscene_delay_timer.start(delay_between_cutscenes)
		await cutscene_delay_timer.timeout
		EventBus.emit_signal("wave_start")

func _start_wave() -> void:
	if GameManager.get_story_event() < GameManager.StoryEvent.WAVE8:
		MusicManager.play_music(MusicManager.MUSIC_BATTLE)
	elif GameManager.get_story_event() < GameManager.StoryEvent.WAVE9:
		MusicManager.play_music(MusicManager.MUSIC_BATTLE, 0.50)
	else:
		MusicManager.play_music(MusicManager.MUSIC_BATTLE,0.25)
	wave_manager.start_wave(GameManager.current_story_event)
	hud.set_max_hearts(player.stats.max_health)
	player.stats.health = player.stats.max_health
	await get_tree().process_frame
	hud.visible = true

func _start_cutscene() -> void:
	hud.visible = false
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(player, "global_position", player_cutsene_marker.global_position, 1.0)
	player.play_animation("idle", true)
	cutscene_manager.start_cutscene(GameManager.current_story_event)

func end_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/ending.tscn")

func _on_cutscene_end() -> void:
	GameManager.advance_story_event()
	if GameManager.get_story_event() == GameManager.StoryEvent.ENDING:
		return
	cutscene_delay_timer.start(delay_between_cutscenes)
	player.disabled = false
	await cutscene_delay_timer.timeout
	EventBus.emit_signal("wave_start")

func _on_wave_end() -> void:
	player.disabled = true
	hud.visible = false
	if GameManager.get_story_event() != GameManager.StoryEvent.WAVE10:
		upgrade_manager.visible = true
		upgrade_manager.setup_upgrades()
	else:
		MusicManager.play_music(MusicManager.MUSIC_SPOOKY)
		bat_cuscene_event.visible = true

func _on_selected_upgrade(upgrade_data : UpgradeData) -> void:
	upgrade_manager.visible = false
	bat_cuscene_event.visible = false
	upgrade_data.apply_upgrade(player)
	EventBus.emit_signal("cutscene_start")

func _on_slow_time(slow_time : float, duration : float) -> void:
	Engine.time_scale = slow_time
	slow_mo_timer.start(duration)
	await slow_mo_timer.timeout
	Engine.time_scale = 1.0
