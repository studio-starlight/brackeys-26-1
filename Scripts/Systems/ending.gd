extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.animation_finished.connect(_on_ending_finished)

func _on_ending_finished(animation_name : String) -> void:
	TransitionManager.play_transition("slide_exit", "res://Scenes/Levels/main_menu.tscn")
