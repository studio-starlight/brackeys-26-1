class_name HUD
extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar

@export var player : Player

func _ready() -> void:
	if !player:
		player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	health_bar.max_value = player.MAX_HEALTH
	health_bar.value = player.get_health()
	
