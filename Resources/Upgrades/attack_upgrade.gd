class_name AttackUpgrade
extends UpgradeData

func apply_upgrade(player : Player) -> void:
	player.stats.attack += player.stats.attack * 0.25
