extends Control
class_name DifficultyModeScreen

@export var main_menu_path: String = "res://scripts/ui/main_menu/main_menu.tscn"

@onready var buttons_container: VBoxContainer = $MarginContainer/VBoxContainer/ButtonsContainer  # mantieni il TUO path gia' corretto


func _ready() -> void:
	for i in range(GameState.difficulty_modes.size()):
		var mode: DifficultyModeResource = GameState.difficulty_modes[i]
		var button := Button.new()
		button.text = mode.mode_name
		button.pressed.connect(_on_difficulty_selected.bind(i))
		buttons_container.add_child(button)


func _on_difficulty_selected(difficulty_index: int) -> void:
	GameState.create_new_save(GameState.pending_new_save_slot, difficulty_index)
	get_tree().change_scene_to_file(main_menu_path)
