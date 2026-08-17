extends Control
class_name UpgradePlayerStatsScreen

@export var row_scene: PackedScene
@export var main_menu_path: String = "res://scripts/ui/main_menu/main_menu.tscn"

@onready var rows_container: VBoxContainer = $MarginContainer/VBoxContainer/RowsScroll/RowsContainer
@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton


func _ready() -> void:
	for definition in GameState.player_stat_definitions:
		var row: PlayerStatRowUI = row_scene.instantiate()
		rows_container.add_child(row)
		row.setup(definition)
	back_button.pressed.connect(func(): get_tree().change_scene_to_file(main_menu_path))
	
