class_name SpeedUpgrade
extends UpgradeData

func apply_upgrade(player : Player) -> void:
	player.stats.speed += player.stats.speed * 0.35
