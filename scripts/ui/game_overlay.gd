extends CanvasLayer
class_name GameOverlay

@onready var game_over_panel: Control = $Control/GameOverPanel
@onready var victory_panel: Control = $Control/VictoryPanel
@onready var game_over_result_label: Label = $Control/GameOverPanel/ResultLabel
@onready var victory_result_label: Label = $Control/VictoryPanel/ResultLabel
@onready var game_over_reward_label: Label = $Control/GameOverPanel/RewardDetailLabel
@onready var victory_reward_label: Label = $Control/VictoryPanel/RewardDetailLabel
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
		level_manager.level_failed.connect(_on_level_failed)

	game_over_retry_button.pressed.connect(_on_retry_pressed)
	victory_retry_button.pressed.connect(_on_retry_pressed)
	victory_next_button.pressed.connect(_on_next_pressed)


func _on_player_died() -> void:
	var max_hearts: int = _player_health_component.max_health
	game_over_result_label.text = "0/%d" % max_hearts
	var progress_ratio: float = RunStats.get_progress_ratio()
	var reward: int = GameState.award_defeat_gold(progress_ratio)
	game_over_reward_label.text = _build_defeat_reward_text(reward)
	_show_panel(game_over_panel)


func _on_level_completed() -> void:
	if _player_health_component == null:
		return
	var hearts_remaining: int = _player_health_component.current_health
	var max_hearts: int = _player_health_component.max_health
	victory_result_label.text = "%d/%d" % [hearts_remaining, max_hearts]
	var current_level: LevelResource = GameState.selected_level
	var completion_reward: int = 0
	if current_level != null:
		completion_reward = GameState.on_level_completed(current_level.level_number, hearts_remaining)
	victory_reward_label.text = _build_victory_reward_text(completion_reward)
	_show_panel(victory_panel)


func _on_level_failed() -> void:
	var hearts_remaining: int = _player_health_component.current_health if _player_health_component != null else 0
	var max_hearts: int = _player_health_component.max_health if _player_health_component != null else 0
	game_over_result_label.text = "%d/%d" % [hearts_remaining, max_hearts]
	var progress_ratio: float = RunStats.get_progress_ratio()
	var reward: int = GameState.award_defeat_gold(progress_ratio)
	game_over_reward_label.text = _build_defeat_reward_text(reward)
	_show_panel(game_over_panel)


func _build_victory_reward_text(completion_reward: int) -> String:
	var lines: Array[String] = []
	lines.append("Nemici Normali sconfitti  x%d  = %d" % [RunStats.kills_normal, RunStats.gold_from_normal])
	lines.append("Elite sconfitti  x%d  = %d" % [RunStats.kills_elite, RunStats.gold_from_elite])
	lines.append("Super Elite sconfitti  x%d  = %d" % [RunStats.kills_super_elite, RunStats.gold_from_super_elite])
	if RunStats.boss_defeated:
		lines.append("Boss sconfitto  = %d" % RunStats.gold_from_boss)
	elif RunStats.outpost_destroyed:
		lines.append("Avamposto distrutto  = %d" % RunStats.gold_from_outpost)
	lines.append("Bonus completamento  = %d" % completion_reward)
	var total: int = RunStats.get_kills_gold_total() + RunStats.gold_from_boss + RunStats.gold_from_outpost + completion_reward
	lines.append("Totale  = %d" % total)
	if RunStats.items_lost_to_full_inventory > 0:
		lines.append("Oggetti persi (inventario pieno)  x%d" % RunStats.items_lost_to_full_inventory)
	return "\n".join(lines)


func _build_defeat_reward_text(reward: int) -> String:
	var lines: Array[String] = []
	lines.append("Nemici Normali sconfitti  x%d  = %d" % [RunStats.kills_normal, RunStats.gold_from_normal])
	lines.append("Elite sconfitti  x%d  = %d" % [RunStats.kills_elite, RunStats.gold_from_elite])
	lines.append("Super Elite sconfitti  x%d  = %d" % [RunStats.kills_super_elite, RunStats.gold_from_super_elite])
	lines.append("Bonus progressi  = %d" % reward)
	var total: int = RunStats.get_kills_gold_total() + reward
	lines.append("Totale  = %d" % total)
	if RunStats.items_lost_to_full_inventory > 0:
		lines.append("Oggetti persi (inventario pieno)  x%d" % RunStats.items_lost_to_full_inventory)
	return "\n".join(lines)


func _show_panel(panel: Control) -> void:
	panel.visible = true
	get_tree().paused = true


func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_next_pressed() -> void:
	get_tree().paused = false
	var current_level: LevelResource = GameState.selected_level
	var next_index: int = -1
	if current_level != null:
		next_index = GameState.all_levels.find(current_level) + 1
	if next_index >= 0 and next_index < GameState.all_levels.size():
		var next_level: LevelResource = GameState.all_levels[next_index]
		if GameState.is_level_unlocked(next_level.level_number):
			GameState.selected_level = next_level
			get_tree().change_scene_to_file("res://scenes/loadout_screen.tscn")
			return
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
