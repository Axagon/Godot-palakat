extends Node

# Autoload (game_state.tscn). Ponte dati tra Menu/Player e persistenza su
# disco. debug_unlock_everything permette di testare contenuto futuro senza
# dover giocare la progressione reale ogni volta.

signal gold_changed(current_gold: int)

@export var progression_config: ProgressionConfig
@export var debug_unlock_everything: bool = false

var all_levels: Array[LevelResource] = []

var save_data: SaveData
var selected_level: LevelResource = null
var selected_deck: Array[SummonResource] = []
var selected_catalysts: Array[CatalystResource] = [null, null, null]  # indice = SpellResource.SpellSlot

const SAVE_PATH: String = "user://savegame.tres"


func _ready() -> void:
	load_game()


func load_game() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		save_data = ResourceLoader.load(SAVE_PATH)
	else:
		save_data = SaveData.new()
		save_data.owned_catalysts = progression_config.starting_catalysts.duplicate()
		save_data.owned_summons = progression_config.starting_summons.duplicate()
		save_game()


func save_game() -> void:
	ResourceSaver.save(save_data, SAVE_PATH)


func is_level_unlocked(level_number: int) -> bool:
	return debug_unlock_everything or level_number <= save_data.highest_level_unlocked


func get_owned_catalysts() -> Array[CatalystResource]:
	if debug_unlock_everything:
		return progression_config.starting_catalysts + progression_config.catalyst_unlock_queue
	return save_data.owned_catalysts


func get_owned_summons() -> Array[SummonResource]:
	if debug_unlock_everything:
		return progression_config.starting_summons + progression_config.summon_unlock_queue
	return save_data.owned_summons


func _check_catalyst_unlock(level_number: int) -> void:
	var cfg := progression_config
	if level_number < cfg.catalyst_unlock_first_level:
		return
	var offset: int = level_number - cfg.catalyst_unlock_first_level
	if offset % cfg.catalyst_unlock_interval != 0:
		return
	@warning_ignore("integer_division")
	var queue_index: int = offset / cfg.catalyst_unlock_interval
	if queue_index < cfg.catalyst_unlock_queue.size():
		var unlocked: CatalystResource = cfg.catalyst_unlock_queue[queue_index]
		if not save_data.owned_catalysts.has(unlocked):
			save_data.owned_catalysts.append(unlocked)


func _check_summon_unlock(level_number: int) -> void:
	var cfg := progression_config
	if level_number < cfg.summon_unlock_first_level:
		return
	var offset: int = level_number - cfg.summon_unlock_first_level
	if offset % cfg.summon_unlock_interval != 0:
		return
	@warning_ignore("integer_division")
	var queue_index: int = offset / cfg.summon_unlock_interval
	if queue_index < cfg.summon_unlock_queue.size():
		var unlocked: SummonResource = cfg.summon_unlock_queue[queue_index]
		if not save_data.owned_summons.has(unlocked):
			save_data.owned_summons.append(unlocked)


func add_gold(amount: int) -> void:
	if amount <= 0:
		return
	save_data.gold += amount
	save_game()
	gold_changed.emit(save_data.gold)


func spend_gold(amount: int) -> bool:
	if amount <= 0 or save_data.gold < amount:
		return false
	save_data.gold -= amount
	save_game()
	gold_changed.emit(save_data.gold)
	return true


func get_gold() -> int:
	return save_data.gold


func award_defeat_gold(progress_ratio: float) -> int:
	var cfg := progression_config
	var reward: int = int(round(cfg.level_complete_base_gold * cfg.defeat_gold_fraction * progress_ratio))
	save_data.gold += reward
	save_game()
	gold_changed.emit(save_data.gold)
	return reward


func on_level_completed(completed_level_number: int, hearts_remaining: int) -> int:
	var reward: int = _award_level_completion_gold(hearts_remaining)
	if completed_level_number + 1 > save_data.highest_level_unlocked:
		save_data.highest_level_unlocked = completed_level_number + 1
	_check_catalyst_unlock(completed_level_number)
	_check_summon_unlock(completed_level_number)
	save_game()
	return reward


func _award_level_completion_gold(hearts_remaining: int) -> int:
	var cfg := progression_config
	var reward: int = cfg.level_complete_base_gold + cfg.level_complete_bonus_per_heart * hearts_remaining
	save_data.gold += reward
	gold_changed.emit(save_data.gold)
	return reward


func get_upgrade_multiplier(resource: Resource, curve: UpgradeCurveResource) -> float:
	if curve == null or resource == null:
		return 1.0
	return curve.get_multiplier_for_level(get_upgrade_level(resource))


func get_upgrade_level(resource: Resource) -> int:
	return save_data.upgrade_levels.get(resource, 0)


func can_upgrade(resource: Resource, curve: BaseUpgradeCurveResource) -> bool:
	if curve == null or resource == null:
		return false
	var current_level: int = get_upgrade_level(resource)
	if current_level >= curve.get_max_level():
		return false
	var cost: int = curve.get_cost_for_level(current_level)
	return cost >= 0 and save_data.gold >= cost


func try_upgrade(resource: Resource, curve: BaseUpgradeCurveResource) -> bool:
	if not can_upgrade(resource, curve):
		return false
	var current_level: int = get_upgrade_level(resource)
	save_data.gold -= curve.get_cost_for_level(current_level)
	save_data.upgrade_levels[resource] = current_level + 1
	save_game()
	gold_changed.emit(save_data.gold)
	return true
