extends Node2D

@export var player : Player
@onready var resume: Button = $PauseBox/PauseButtons/Resume
@onready var main_menu: Button = $"PauseBox/PauseButtons/Main Menu"
@onready var quit: Button = $PauseBox/PauseButtons/Quit

func _ready() -> void:
	resume.connect("pressed", _resume)
	main_menu.connect("pressed", _main_menu)
	quit.connect("pressed", _quit)
	if !player:
		get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape") && !player.disabled:
		_pause()

func _pause() -> void:
	get_tree().paused = true
	visible = true

func _resume() -> void:
	get_tree().paused = false
	visible = false

func _main_menu() -> void:
	pass

func _quit() -> void:
	get_tree().quit()
