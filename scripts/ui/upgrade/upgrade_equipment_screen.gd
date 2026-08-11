extends Control
class_name UpgradeEquipmentScreen

@export var row_scene: PackedScene
@export var passive_item: PassiveItemResource
@export var shield_item: ShieldResource
@export var main_menu_path: String = "res://scripts/ui/main_menu/main_menu.tscn"
@onready var rows_container: VBoxContainer = $MarginContainer/VBoxContainer/RowsScroll/RowsContainer
@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton


func _ready() -> void:
	print("Summons screen ready - inizio")
	for summon in GameState.get_owned_summons():
		var row: UpgradeRowUI = row_scene.instantiate()
		rows_container.add_child(row)
		row.setup(summon, summon.upgrade_curve, summon.summon_name, summon.icon)
	back_button.pressed.connect(_on_back_pressed)
	print("Summons screen ready - fine, bottone connesso")

func _add_row(resource: Resource, curve: BaseUpgradeCurveResource, display_name: String, icon: Texture2D) -> void:
	var row: UpgradeRowUI = row_scene.instantiate()
	rows_container.add_child(row)
	row.setup(resource, curve, display_name, icon)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_path)
