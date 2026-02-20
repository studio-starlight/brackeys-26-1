extends Node2D

@onready var upgrades: HBoxContainer = $Upgrades
@onready var upgrade_1: Button = $Upgrades/Upgrade1
@onready var upgrade_2: Button = $Upgrades/Upgrade2
@onready var upgrade_3: Button = $Upgrades/Upgrade3

@export var upgrade_resouces : Array

func _ready() -> void:
	for upgrade : Button in upgrades:
		upgrade.pressed.connect(_upgrade_pressed)

func _upgrade_pressed() -> void:
	pass
