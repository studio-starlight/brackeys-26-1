extends Node2D

@export var upgrades : Array[UpgradeData]
@onready var upgrades_container: HBoxContainer = $Upgrades

func setup_upgrades() -> void:
	var upgrades_duplicate := upgrades.duplicate()
	randomize()
	upgrades_duplicate.shuffle()
	for upgrade : UpgradeButton in upgrades_container.get_children():
		var upgrade_data : UpgradeData = upgrades_duplicate.back()
		upgrade.setup_upgrade_button(upgrade_data)
		upgrades_duplicate.pop_back()
