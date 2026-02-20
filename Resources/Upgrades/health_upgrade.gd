class_name HealthUpgrade
extends UpgradeData

func apply_upgrade(player : Player) -> void:
	player.stats.max_health += 1
