extends Control
class_name SettingsScreen

@export var row_scene: PackedScene
@export var setting_definitions: Array[SettingDefinitionResource] = []

@onready var rows_container: VBoxContainer = $MarginContainer/VBoxContainer/RowsScroll/RowsContainer
@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton


func _ready() -> void:
	for definition in setting_definitions:
		var row: SettingRowUI = row_scene.instantiate()
		rows_container.add_child(row)
		row.setup(definition)
	back_button.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(GameState.settings_return_path)
	
