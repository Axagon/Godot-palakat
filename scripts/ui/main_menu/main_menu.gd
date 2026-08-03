extends Control
class_name MainMenu

const LEVEL_NUMBERS_TEXTURE := preload("res://sprites/ui/numbers_levels.png")
const LEVEL_NUMBER_REGIONS := [
	Rect2(14, 7, 6, 9),    # 1
	Rect2(46, 7, 6, 9),    # 2
	Rect2(78, 7, 6, 9),    # 3
	Rect2(109, 7, 6, 9),   # 4
	Rect2(142, 7, 6, 9),   # 5
	Rect2(174, 7, 6, 9),   # 6
	Rect2(206, 7, 6, 9),   # 7
	Rect2(238, 7, 6, 9),   # 8
	Rect2(270, 7, 6, 9),   # 9
	Rect2(11, 23, 11, 9),  # 10
	Rect2(43, 23, 11, 9),  # 11
]

@export var levels: Array[LevelResource] = []
@export var game_scene_path: String = "res://scenes/test_level.tscn"
@export var level_circle_unlocked: StyleBoxTexture
@export var level_circle_locked: StyleBoxTexture
@export var level_circle_hover: StyleBoxTexture


@onready var level_grid: GridContainer = $MarginContainer/VBoxContainer/LevelGrid


func _ready() -> void:
	GameState.all_levels = levels
	_build_level_buttons()


func _build_level_buttons() -> void:
	for i in range(levels.size()):
		var button := Button.new()
		var level_number: int = i + 1
		var is_unlocked: bool = GameState.is_level_unlocked(level_number)
		var circle_style: StyleBoxTexture = level_circle_unlocked if is_unlocked else level_circle_locked

		button.custom_minimum_size = Vector2(70, 70)
		button.disabled = not is_unlocked
		button.text = ""
		button.add_theme_stylebox_override("normal", circle_style)
		button.add_theme_stylebox_override("hover", circle_style)
		button.add_theme_stylebox_override("pressed", circle_style)
		button.add_theme_stylebox_override("disabled", circle_style)

		if is_unlocked:
			button.mouse_entered.connect(func(): button.modulate = Color(1.15, 1.15, 1.15))
			button.mouse_exited.connect(func(): button.modulate = Color(1, 1, 1))

		_add_level_number_visual(button, level_number)
		button.pressed.connect(_on_level_selected.bind(i))
		level_grid.add_child(button)


func _add_level_number_visual(button: Button, level_number: int) -> void:
	var index: int = level_number - 1
	if index < 0 or index >= LEVEL_NUMBER_REGIONS.size():
		return

	var number_icon := AtlasTexture.new()
	number_icon.atlas = LEVEL_NUMBERS_TEXTURE
	number_icon.region = LEVEL_NUMBER_REGIONS[index]

	var number_rect := TextureRect.new()
	number_rect.texture = number_icon
	number_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	number_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	number_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	number_rect.offset_left = 18
	number_rect.offset_top = 24
	number_rect.offset_right = -18
	number_rect.offset_bottom = -24
	button.add_child(number_rect)


func _on_level_selected(index: int) -> void:
	if index < 0 or index >= levels.size():
		return
	GameState.selected_level = levels[index]
	get_tree().change_scene_to_file("res://scenes/loadout_screen.tscn")
