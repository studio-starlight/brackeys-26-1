extends Node2D

@onready var play: Button = $CanvasLayer/PauseButtons/Play
@onready var controls: Button = $CanvasLayer/PauseButtons/Controls
@onready var quit: Button = $CanvasLayer/PauseButtons/Quit
@onready var animator: AnimationPlayer = $Animator

func _ready() -> void:
	TransitionManager.play_transition("slide_enter")
	play.mouse_entered.connect(_button_hovered)
	play.pressed.connect(_play_pressed)
	controls.mouse_entered.connect(_button_hovered)
	controls.pressed.connect(_controls_pressed)
	quit.mouse_entered.connect(_button_hovered)
	quit.pressed.connect(_quit_pressed)
	animator.play("title")
	if get_tree().paused == true:
		get_tree().paused = false

func _button_hovered() -> void:
	AudioManager.play_sound(AudioManager.SOUND_BUTTON_HOVER)

func _play_pressed() -> void:
	AudioManager.play_sound(AudioManager.SOUND_BUTTON_CLICK)
	GameManager.reset_story()
	TransitionManager.play_transition("slide_exit", "res://Scenes/Levels/game.tscn")

func _controls_pressed() -> void:
	pass

func _quit_pressed() -> void:
	get_tree().quit()
