extends Control
class_name StartupScreen

@export var main_menu_path: String = "res://scripts/ui/main_menu/main_menu.tscn"
@export var slot_select_path: String = "res://scenes/slot_select_screen.tscn"
@export var settings_path: String = "res://scenes/settings_screen.tscn"

@onready var continue_button: Button = $MarginContainer/VBoxContainer/ContinueButton
@onready var new_game_button: Button = $MarginContainer/VBoxContainer/NewGameButton
@onready var load_game_button: Button = $MarginContainer/VBoxContainer/LoadGameButton
@onready var settings_button: Button = $MarginContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $MarginContainer/VBoxContainer/QuitButton


func _ready() -> void:
	continue_button.disabled = not GameState.has_any_save()
	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_continue_pressed() -> void:
	if GameState.continue_last_save():
		get_tree().change_scene_to_file(main_menu_path)


func _on_new_game_pressed() -> void:
	GameState.pending_slot_select_mode = GameState.SlotSelectMode.NEW
	get_tree().change_scene_to_file(slot_select_path)


func _on_load_game_pressed() -> void:
	GameState.pending_slot_select_mode = GameState.SlotSelectMode.LOAD
	get_tree().change_scene_to_file(slot_select_path)


func _on_settings_pressed() -> void:
	GameState.settings_return_path = "res://scenes/startup_screen.tscn"
	get_tree().change_scene_to_file(settings_path)


func _on_quit_pressed() -> void:
	get_tree().quit()
