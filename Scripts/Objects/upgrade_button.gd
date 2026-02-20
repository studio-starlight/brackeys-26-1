class_name UpgradeButton
extends Panel


@onready var upgrade_name_button: Button = $UpgradeContainer/UpgradeName
@onready var upgrade_description_label: RichTextLabel = $UpgradeContainer/UpgradeDescription
var upgrade_data_container : UpgradeData

func _ready() -> void:
	upgrade_name_button.pressed.connect(_on_upgrade_pressed)

func setup_upgrade_button(upgrade_data : UpgradeData) -> void:
	upgrade_name_button.text = upgrade_data.name
	upgrade_description_label.text = upgrade_data.description
	upgrade_data_container = upgrade_data

func _on_upgrade_pressed() -> void:
	EventBus.upgrade_selected.emit(upgrade_data_container)
