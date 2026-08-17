extends Control
class_name SlotSelectScreen

@export var startup_screen_path: String = "res://scenes/startup_screen.tscn"
@export var main_menu_path: String = "res://scripts/ui/main_menu/main_menu.tscn"
@export var difficulty_mode_path: String = "res://scenes/difficulty_mode_screen.tscn"

@onready var slot_buttons: Array[Button] = []
@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton
@onready var overwrite_dialog: ConfirmationDialog = $OverwriteDialog

var _pending_overwrite_slot: int = -1


func _ready() -> void:
	slot_buttons = [
		$MarginContainer/VBoxContainer/SlotButton0,
		$MarginContainer/VBoxContainer/SlotButton1,
		$MarginContainer/VBoxContainer/SlotButton2,
	]
	for i in range(slot_buttons.size()):
		_refresh_slot_button(i)
		slot_buttons[i].pressed.connect(_on_slot_pressed.bind(i))
	back_button.pressed.connect(func(): get_tree().change_scene_to_file(startup_screen_path))
	overwrite_dialog.confirmed.connect(_on_overwrite_confirmed)


func _refresh_slot_button(slot: int) -> void:
	var summary: Dictionary = GameState.get_slot_summary(slot)
	var button: Button = slot_buttons[slot]
	if summary.occupied:
		var date_string: String = Time.get_datetime_string_from_unix_time(summary.last_access_unix, true)
		var mode_name: String = GameState.difficulty_modes[summary.difficulty_mode].mode_name if summary.difficulty_mode >= 0 and summary.difficulty_mode < GameState.difficulty_modes.size() else "?"
		button.text = "Slot %d\nLivello %d - %s\n%s" % [slot + 1, summary.highest_level, mode_name, date_string]
		button.disabled = false
	else:
		button.text = "Slot %d\nVuoto" % (slot + 1)
		button.disabled = GameState.pending_slot_select_mode == GameState.SlotSelectMode.LOAD


func _on_slot_pressed(slot: int) -> void:
	var occupied: bool = GameState.is_slot_occupied(slot)
	if GameState.pending_slot_select_mode == GameState.SlotSelectMode.LOAD:
		if occupied:
			GameState.load_slot(slot)
			get_tree().change_scene_to_file(main_menu_path)
		return

	if occupied:
		_pending_overwrite_slot = slot
		overwrite_dialog.popup_centered()
	else:
		_proceed_to_difficulty_selection(slot)


func _on_overwrite_confirmed() -> void:
	_proceed_to_difficulty_selection(_pending_overwrite_slot)


func _proceed_to_difficulty_selection(slot: int) -> void:
	GameState.pending_new_save_slot = slot
	get_tree().change_scene_to_file(difficulty_mode_path)
