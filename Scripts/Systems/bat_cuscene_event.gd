extends Node2D

@onready var upgrade_name: Button = $BatUpgrade/UpgradeContainer/UpgradeName

func _ready() -> void:
	upgrade_name.pressed.connect(_on_bat_upgrade_pressed)

func _on_bat_upgrade_pressed() -> void:
	var default_upgrade_data := UpgradeData.new()
	EventBus.upgrade_selected.emit(default_upgrade_data)
