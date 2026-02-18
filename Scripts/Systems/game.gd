extends Node2D

@export var delay_between_cutscenes : float = 1.0
@onready var cutscene_manager: CutsceneManager = $CutsceneManager
@onready var wave_manager: WaveManager = $WaveManager
@onready var hud: HUD = $HUD
@onready var player: Player = $Player
@onready var cutscene_delay_timer: Timer = $CutsceneManager/CutsceneDelayTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.connect("wave_start", _start_wave)
	EventBus.connect("wave_end", _on_wave_end)
	EventBus.connect("cutscene_start", _start_cutscene)
	EventBus.connect("cutscene_end", _on_cutscene_end)
	_start_cutscene()

func _start_wave() -> void:
	wave_manager.start_wave(GameManager.current_story_event)
	hud.set_max_hearts(player.MAX_HEALTH)
	player.health = player.MAX_HEALTH
	await get_tree().process_frame
	hud.visible = true

func _start_cutscene() -> void:
	hud.visible = false
	cutscene_manager.start_cutscene(GameManager.current_story_event)

func _on_cutscene_end() -> void:
	GameManager.advance_story_event()
	cutscene_delay_timer.start(delay_between_cutscenes)
	await cutscene_delay_timer.timeout
	EventBus.emit_signal("wave_start")

func _on_wave_end() -> void:
	EventBus.emit_signal("cutscene_start")
