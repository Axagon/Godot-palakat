extends Control
class_name UpgradeSummonsScreen

@export var row_scene: PackedScene
@export var main_menu_path: String = "res://scripts/ui/main_menu/main_menu.tscn"

@onready var rows_container: VBoxContainer = $MarginContainer/VBoxContainer/RowsScroll/RowsContainer
@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton


func _ready() -> void:
	for summon in GameState.get_owned_summons():
		var row: UpgradeRowUI = row_scene.instantiate()
		rows_container.add_child(row)
		row.setup(summon, summon.upgrade_curve, summon.summon_name, summon.icon)
	back_button.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_path)
