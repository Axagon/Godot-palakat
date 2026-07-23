extends CanvasLayer
class_name GameOverlay

# Gestisce le schermate di fine livello (sconfitta/vittoria) e la pausa
# associata. Le stelle/cuori mostrati derivano direttamente dagli HP residui
# del player nel momento dell'evento: 0 alla sconfitta (la morte scatta
# proprio a 0 HP), fino al massimo se il livello viene vinto senza danni.

@onready var game_over_panel: Control = $Control/GameOverPanel
@onready var victory_panel: Control = $Control/VictoryPanel
@onready var game_over_result_label: Label = $Control/GameOverPanel/ResultLabel
@onready var victory_result_label: Label = $Control/VictoryPanel/ResultLabel
@onready var game_over_retry_button: Button = $Control/GameOverPanel/RetryButton
@onready var victory_retry_button: Button = $Control/VictoryPanel/RetryButton
@onready var victory_next_button: Button = $Control/VictoryPanel/NextButton

var _player_health_component: HealthComponent = null


func _ready() -> void:
	await get_tree().process_frame

	var player: Player = get_tree().get_first_node_in_group("player")
	if player != null:
		_player_health_component = player.health_component
		_player_health_component.died.connect(_on_player_died)

	var level_manager: LevelManager = get_tree().get_first_node_in_group("level_manager")
	if level_manager != null:
		level_manager.level_completed.connect(_on_level_completed)

	game_over_retry_button.pressed.connect(_on_retry_pressed)
	victory_retry_button.pressed.connect(_on_retry_pressed)
	victory_next_button.pressed.connect(_on_next_pressed)


func _on_player_died() -> void:
	var max_hearts: int = _player_health_component.max_health
	game_over_result_label.text = "0/%d" % max_hearts
	_show_panel(game_over_panel)


func _on_level_completed() -> void:
	if _player_health_component == null:
		return
	var hearts_remaining: int = _player_health_component.current_health
	var max_hearts: int = _player_health_component.max_health
	victory_result_label.text = "%d/%d" % [hearts_remaining, max_hearts]
	_show_panel(victory_panel)


func _show_panel(panel: Control) -> void:
	panel.visible = true
	get_tree().paused = true


func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_next_pressed() -> void:
	# Placeholder: non esiste ancora un sistema di progressione tra livelli
	# (roadmap punto 4). Per ora si comporta come Riprova.
	_on_retry_pressed()
