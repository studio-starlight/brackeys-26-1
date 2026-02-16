extends Node2D

@onready var cutscene_manager: CutsceneManager = $CutsceneManager
@onready var wave_manager: WaveManager = $WaveManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.connect("wave_start", _start_wave)
	EventBus.connect("wave_end", _on_wave_end)
	EventBus.connect("cutscene_start", _start_cutscene)
	EventBus.connect("cutscene_end", _on_cutscene_end)
	_start_cutscene()

func _start_wave() -> void:
	wave_manager.start_wave(GameManager.current_story_event)

func _start_cutscene() -> void:
	cutscene_manager.start_cutscene(GameManager.current_story_event)

func _on_cutscene_end() -> void:
	EventBus.emit_signal("wave_start")

func _on_wave_end() -> void:
	GameManager.advance_story_event()
	EventBus.emit_signal("cutscene_start")
