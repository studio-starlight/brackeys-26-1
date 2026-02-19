class_name HUD
extends CanvasLayer

const HEART = preload("uid://bj415opnbr8pj")

@onready var health_bar: HBoxContainer = $HealthBar
@export var player : Player

var hearts_list : Array[TextureRect]

func _ready() -> void:
	if !player:
		player = get_tree().get_first_node_in_group("player")
	set_max_hearts(player.stats.max_health)

func _process(delta: float) -> void:
	update_hearts(player.stats.health)

func set_max_hearts(max_hearts : int) -> void:
	for child in health_bar.get_children():
		child.queue_free()
	for i in range(max_hearts):
		var heart = HEART.instantiate()
		health_bar.add_child(heart)

func update_hearts(current_health : int) -> void:
	var hearts : Array[Node] = health_bar.get_children()
	
	for i in range(current_health):
		hearts[i].update(true)
	
	for i in range(current_health, hearts.size()):
		hearts[i].update(false)
