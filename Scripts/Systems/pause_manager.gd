extends Node2D

@export var player : Player
@onready var resume: Button = $PauseBox/PauseButtons/Resume
@onready var main_menu: Button = $"PauseBox/PauseButtons/Main Menu"
@onready var quit: Button = $PauseBox/PauseButtons/Quit

func _ready() -> void:
	resume.connect("pressed", _resume)
	main_menu.connect("pressed", _main_menu)
	quit.connect("pressed", _quit)
	resume.mouse_entered.connect(_button_hovered)
	main_menu.mouse_entered.connect(_button_hovered)
	quit.mouse_entered.connect(_button_hovered)
	if !player:
		get_tree().get_first_node_in_group("player")

func _button_hovered() -> void:
	AudioManager.play_sound(AudioManager.SOUND_BUTTON_HOVER)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape") && !player.disabled:
		_pause()

func _pause() -> void:
	AudioManager.play_sound(AudioManager.SOUND_BUTTON_CLICK)
	get_tree().paused = true
	visible = true

func _resume() -> void:
	AudioManager.play_sound(AudioManager.SOUND_BUTTON_CLICK)
	get_tree().paused = false
	visible = false

func _main_menu() -> void:
	resume.disabled = true
	main_menu.disabled = true
	quit.disabled = true
	AudioManager.play_sound(AudioManager.SOUND_BUTTON_CLICK)
	MusicManager.stop_music()
	TransitionManager.play_transition("slide_exit", "res://Scenes/Levels/main_menu.tscn")

func _quit() -> void:
	AudioManager.play_sound(AudioManager.SOUND_BUTTON_CLICK)
	get_tree().quit()
