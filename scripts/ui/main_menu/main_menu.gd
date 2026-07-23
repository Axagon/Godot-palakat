extends Control
class_name MainMenu

# Menu minimo di selezione livelli. Tutti i livelli sono sbloccati per
# adesso (nessuna persistenza/progressione, vedi roadmap punto 5-6).
# I pulsanti sono generati a runtime dall'array 'levels' cosi' l'aggiunta
# di sblocco/punteggio in futuro tocchera' solo lo script, non la scena.

@export var levels: Array[LevelResource] = []
@export var game_scene_path: String = "res://scenes/test_level.tscn"

@onready var level_grid: GridContainer = $MarginContainer/VBoxContainer/LevelGrid


func _ready() -> void:
	_build_level_buttons()


func _build_level_buttons() -> void:
	for i in range(levels.size()):
		var button := Button.new()
		var level_number: int = i + 1
		button.text = str(level_number)
		button.custom_minimum_size = Vector2(70, 70)
		button.disabled = not GameState.is_level_unlocked(level_number)
		button.pressed.connect(_on_level_selected.bind(i))
		level_grid.add_child(button)


func _on_level_selected(index: int) -> void:
	if index < 0 or index >= levels.size():
		return
	GameState.selected_level = levels[index]
	get_tree().change_scene_to_file(game_scene_path)
