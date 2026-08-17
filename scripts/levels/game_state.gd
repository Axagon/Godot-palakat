extends Node

# Autoload (game_state.tscn). Ponte dati tra Menu/Player e persistenza su
# disco. Supporta 3 slot di salvataggio indipendenti: SaveMetaResource e'
# l'indice leggero usato dalla StartupScreen per mostrare i 3 slot senza
# caricare i SaveData completi. debug_unlock_everything permette di
# testare contenuto futuro senza dover giocare la progressione reale.

signal gold_changed(current_gold: int)

const SAVE_SLOT_COUNT: int = 3
const SAVE_META_PATH: String = "user://save_meta.tres"
const SAVE_SLOT_PATH_FORMAT: String = "user://savegame_slot_%d.tres"

@export var progression_config: ProgressionConfig
@export var debug_unlock_everything: bool = false

@export var difficulty_modes: Array[DifficultyModeResource] = []

@export var item_rarities: Array[ItemRarityResource] = []  # ordine: Comune, Rara, Epica

@export var player_stat_definitions: Array[PlayerStatDefinitionResource] = []

var all_levels: Array[LevelResource] = []

var save_data: SaveData = null
var save_meta: SaveMetaResource = null
var current_slot: int = -1

var selected_level: LevelResource = null
var selected_deck: Array[SummonResource] = []
var selected_catalysts: Array[CatalystResource] = [null, null, null]  # indice = SpellResource.SpellSlot

enum SlotSelectMode { NEW, LOAD }
var pending_slot_select_mode: SlotSelectMode = SlotSelectMode.LOAD
var pending_new_save_slot: int = -1
var settings_return_path: String = "res://scripts/ui/main_menu/main_menu.tscn"

var _current_dropping_enemy_chance: float = 0.0


func _ready() -> void:
	_load_meta()


# --- Gestione slot / metadati (letta dalla StartupScreen) ---

func _load_meta() -> void:
	if ResourceLoader.exists(SAVE_META_PATH):
		save_meta = ResourceLoader.load(SAVE_META_PATH)
	else:
		save_meta = SaveMetaResource.new()


func _save_meta() -> void:
	ResourceSaver.save(save_meta, SAVE_META_PATH)


func _slot_path(slot: int) -> String:
	return SAVE_SLOT_PATH_FORMAT % slot


func has_any_save() -> bool:
	return save_meta.last_used_slot != -1


func is_slot_occupied(slot: int) -> bool:
	return save_meta.slot_occupied[slot]


func get_slot_summary(slot: int) -> Dictionary:
	return {
		"occupied": save_meta.slot_occupied[slot],
		"highest_level": save_meta.highest_level_reached[slot],
		"difficulty_mode": save_meta.difficulty_mode[slot],
		"last_access_unix": save_meta.last_access_unix[slot],
	}


func create_new_save(slot: int, difficulty_mode: int) -> void:
	current_slot = slot
	save_data = SaveData.new()
	save_data.difficulty_mode = difficulty_mode
	save_data.owned_catalysts = progression_config.starting_catalysts.duplicate()
	save_data.owned_summons = progression_config.starting_summons.duplicate()
	save_game()
	refresh_shop_rotation()


func load_slot(slot: int) -> bool:
	var path: String = _slot_path(slot)
	if not ResourceLoader.exists(path):
		push_warning("GameState: nessun salvataggio nello slot %d" % slot)
		return false
	current_slot = slot
	save_data = ResourceLoader.load(path)
	_touch_slot_meta(slot)
	return true


func continue_last_save() -> bool:
	if save_meta.last_used_slot == -1:
		return false
	return load_slot(save_meta.last_used_slot)


func _touch_slot_meta(slot: int) -> void:
	save_meta.slot_occupied[slot] = true
	save_meta.highest_level_reached[slot] = save_data.highest_level_unlocked
	save_meta.difficulty_mode[slot] = save_data.difficulty_mode
	save_meta.last_access_unix[slot] = int(Time.get_unix_time_from_system())
	save_meta.last_used_slot = slot
	_save_meta()


# --- Persistenza slot corrente ---

func save_game() -> void:
	if current_slot == -1:
		push_warning("GameState: save_game chiamato senza slot attivo")
		return
	ResourceSaver.save(save_data, _slot_path(current_slot))
	_touch_slot_meta(current_slot)


func _ensure_save_data() -> void:
	if save_data != null:
		return
	push_warning("GameState: save_data non inizializzato (scena testata senza passare dallo Startup) - creo un salvataggio di debug temporaneo, non persistito")
	save_data = SaveData.new()
	save_data.owned_catalysts = progression_config.starting_catalysts.duplicate()
	save_data.owned_summons = progression_config.starting_summons.duplicate()
	

# --- Metodi esistenti, logica interna invariata ---

func is_level_unlocked(level_number: int) -> bool:
	_ensure_save_data()
	return debug_unlock_everything or level_number <= save_data.highest_level_unlocked


func get_owned_catalysts() -> Array[CatalystResource]:
	_ensure_save_data()
	if debug_unlock_everything:
		return progression_config.starting_catalysts + progression_config.catalyst_unlock_queue
	return save_data.owned_catalysts


func get_owned_summons() -> Array[SummonResource]:
	_ensure_save_data()
	if debug_unlock_everything:
		return progression_config.starting_summons + progression_config.summon_unlock_queue
	return save_data.owned_summons


func _is_checkpoint_level(level_number: int) -> bool:
	@warning_ignore("integer_division")
	var local_index: int = ((level_number - 1) % 10) + 1
	return local_index == 5 or local_index == 10


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
	_ensure_save_data()
	if amount <= 0:
		return
	save_data.gold += amount
	save_game()
	gold_changed.emit(save_data.gold)


func spend_gold(amount: int) -> bool:
	_ensure_save_data()
	if amount <= 0 or save_data.gold < amount:
		return false
	save_data.gold -= amount
	save_game()
	gold_changed.emit(save_data.gold)
	return true


func get_gold() -> int:
	_ensure_save_data()
	return save_data.gold


func on_level_completed(completed_level_number: int, hearts_remaining: int) -> int:
	_ensure_save_data()
	var reward: int = _award_level_completion_gold(hearts_remaining)
	_award_level_completion_fragments(completed_level_number)
	refresh_shop_rotation()
	if completed_level_number + 1 > save_data.highest_level_unlocked:
		save_data.highest_level_unlocked = completed_level_number + 1
	_check_catalyst_unlock(completed_level_number)
	_check_summon_unlock(completed_level_number)
	save_game()
	return reward


func _award_level_completion_gold(hearts_remaining: int) -> int:
	var cfg := progression_config
	var base_reward: int = cfg.level_complete_base_gold + cfg.level_complete_bonus_per_heart * hearts_remaining
	var reward: int = apply_reward_multiplier(base_reward)
	save_data.gold += reward
	gold_changed.emit(save_data.gold)
	return reward


func award_defeat_gold(progress_ratio: float) -> int:
	_ensure_save_data()
	var cfg := progression_config
	var base_reward: int = int(round(cfg.level_complete_base_gold * cfg.defeat_gold_fraction * progress_ratio))
	var reward: int = apply_reward_multiplier(base_reward)
	save_data.gold += reward
	save_game()
	gold_changed.emit(save_data.gold)
	return reward


func get_upgrade_multiplier(resource: Resource, curve: UpgradeCurveResource) -> float:
	if curve == null or resource == null:
		return 1.0
	return curve.get_multiplier_for_level(get_upgrade_level(resource))


func get_upgrade_level(resource: Resource) -> int:
	_ensure_save_data()
	return save_data.upgrade_levels.get(resource, 0)


func get_fragments() -> int:
	_ensure_save_data()
	return save_data.fragments


func can_upgrade(resource: Resource, curve: BaseUpgradeCurveResource) -> bool:
	_ensure_save_data()
	if curve == null or resource == null:
		return false
	var current_level: int = get_upgrade_level(resource)
	if current_level >= curve.get_max_level():
		return false
	var cost: int = curve.get_cost_for_level(current_level)
	var fragment_cost: int = curve.get_fragment_cost_for_level(current_level)
	return cost >= 0 and save_data.gold >= cost and save_data.fragments >= fragment_cost


func try_upgrade(resource: Resource, curve: BaseUpgradeCurveResource) -> bool:
	_ensure_save_data()
	if not can_upgrade(resource, curve):
		return false
	var current_level: int = get_upgrade_level(resource)
	save_data.gold -= curve.get_cost_for_level(current_level)
	save_data.fragments -= curve.get_fragment_cost_for_level(current_level)
	save_data.upgrade_levels[resource] = current_level + 1
	save_game()
	gold_changed.emit(save_data.gold)
	return true


func get_current_difficulty_mode() -> DifficultyModeResource:
	_ensure_save_data()
	var index: int = save_data.difficulty_mode
	if index < 0 or index >= difficulty_modes.size():
		return null
	return difficulty_modes[index]


func apply_reward_multiplier(amount: int) -> int:
	var mode: DifficultyModeResource = get_current_difficulty_mode()
	if mode == null:
		return amount
	return int(round(amount * mode.reward_multiplier))


func _award_level_completion_fragments(completed_level_number: int) -> int:
	var cfg := progression_config
	var is_checkpoint: bool = _is_checkpoint_level(completed_level_number)
	var already_completed: bool = save_data.completed_levels.has(completed_level_number)

	var reward: int = 0
	if is_checkpoint:
		reward = cfg.fragment_reward_checkpoint
	elif not already_completed:
		reward = cfg.fragment_reward_normal

	if not already_completed:
		save_data.completed_levels.append(completed_level_number)

	save_data.fragments += reward
	return reward
	

func get_inventory_capacity() -> int:
	var definition: PlayerStatDefinitionResource = get_player_stat_definition("inventory_slots")
	return int(round(get_player_stat_value("inventory_slots"))) if definition != null else 10


func get_shop_slot_count() -> int:
	var definition: PlayerStatDefinitionResource = get_player_stat_definition("shop_slots")
	return int(round(get_player_stat_value("shop_slots"))) if definition != null else 3


func is_inventory_full() -> bool:
	_ensure_save_data()
	return save_data.inventory.size() >= get_inventory_capacity()


func add_inventory_item(item: InventoryItemResource) -> bool:
	_ensure_save_data()
	if is_inventory_full():
		return false
	save_data.inventory.append(item)
	save_game()
	return true


func roll_and_award_equipment_drop(rank: EnemyRankResource.Rank, rank_config: EnemyRankResource, guaranteed: bool) -> void:
	if item_rarities.is_empty() or progression_config == null:
		return
	if not guaranteed:
		var drop_mult: float = rank_config.get_drop_chance_mult(rank) if rank_config != null else 1.0
		if randf() >= _current_dropping_enemy_chance * drop_mult:
			return

	var item: InventoryItemResource = _build_rolled_item()
	if item == null:
		return
	if not add_inventory_item(item):
		RunStats.record_item_lost()


func _build_rolled_item() -> InventoryItemResource:
	var use_passive: bool = randf() < 0.5
	var pool: Array = []
	if use_passive:
		pool = progression_config.droppable_passive_items
	else:
		pool = progression_config.droppable_shield_items
	if pool.is_empty():
		return null
	var template: Resource = pool[randi() % pool.size()]
	var rarity: ItemRarityResource = _roll_rarity()
	var roll_percent: float = randf_range(rarity.roll_min_percent, rarity.roll_max_percent)
	var multiplier: float = 1.0 + roll_percent

	var rolled: Resource = template.duplicate()
	for field_name in rolled.get_rollable_field_names():
		var value = rolled.get(field_name)
		if typeof(value) == TYPE_INT:
			rolled.set(field_name, int(round(value * multiplier)))
		else:
			rolled.set(field_name, value * multiplier)

	var item := InventoryItemResource.new()
	item.item_type = InventoryItemResource.ItemType.PASSIVE if use_passive else InventoryItemResource.ItemType.SHIELD
	item.rarity = rarity
	item.rolled_resource = rolled
	item.base_template = template
	return item


func _roll_rarity() -> ItemRarityResource:
	var total_weight: float = 0.0
	for r in item_rarities:
		total_weight += r.drop_weight
	var roll: float = randf() * total_weight
	var accumulated: float = 0.0
	for r in item_rarities:
		accumulated += r.drop_weight
		if roll <= accumulated:
			return r
	return item_rarities[-1]


func equip_item(item: InventoryItemResource) -> void:
	_ensure_save_data()
	match item.item_type:
		InventoryItemResource.ItemType.PASSIVE:
			save_data.equipped_passive_item = item
		InventoryItemResource.ItemType.SHIELD:
			save_data.equipped_shield_item = item
	save_game()


func get_equipped_passive_item() -> PassiveItemResource:
	_ensure_save_data()
	return save_data.equipped_passive_item.rolled_resource if save_data.equipped_passive_item != null else null


func get_equipped_shield_item() -> ShieldResource:
	_ensure_save_data()
	return save_data.equipped_shield_item.rolled_resource if save_data.equipped_shield_item != null else null


func get_sell_percent() -> float:
	var definition: PlayerStatDefinitionResource = get_player_stat_definition("shop_sell_percent")
	return get_player_stat_value("shop_sell_percent") if definition != null else 0.30


func get_buy_percent() -> float:
	var definition: PlayerStatDefinitionResource = get_player_stat_definition("shop_buy_percent")
	return get_player_stat_value("shop_buy_percent") if definition != null else 1.0
	

func get_sell_value(item: InventoryItemResource) -> int:
	var base_value: int = item.base_template.base_value if item.base_template != null else 0
	var rarity_mult: float = item.rarity.sell_value_multiplier if item.rarity != null else 1.0
	return int(round(base_value * rarity_mult * get_sell_percent()))


func get_buy_price(item: InventoryItemResource) -> int:
	var base_value: int = item.base_template.base_value if item.base_template != null else 0
	var rarity_mult: float = item.rarity.sell_value_multiplier if item.rarity != null else 1.0
	return int(round(base_value * rarity_mult * get_buy_percent()))


func sell_item(item: InventoryItemResource) -> int:
	_ensure_save_data()
	if not save_data.inventory.has(item):
		return 0
	var value: int = get_sell_value(item)
	save_data.inventory.erase(item)
	_clear_if_equipped(item)
	add_gold(value)
	return value


func destroy_item(item: InventoryItemResource) -> int:
	_ensure_save_data()
	if not save_data.inventory.has(item):
		return 0
	var reward: int = item.rarity.fragment_destroy_reward if item.rarity != null else 1
	save_data.inventory.erase(item)
	_clear_if_equipped(item)
	save_data.fragments += reward
	save_game()
	return reward


func _clear_if_equipped(item: InventoryItemResource) -> void:
	if save_data.equipped_passive_item == item:
		save_data.equipped_passive_item = null
	if save_data.equipped_shield_item == item:
		save_data.equipped_shield_item = null


func refresh_shop_rotation() -> void:
	_ensure_save_data()
	save_data.shop_rotation.clear()
	for i in range(get_shop_slot_count()):
		var item: InventoryItemResource = _build_rolled_item()
		save_data.shop_rotation.append(item)
	save_game()


func can_buy_shop_item(index: int) -> bool:
	_ensure_save_data()
	if index < 0 or index >= save_data.shop_rotation.size():
		return false
	var item: InventoryItemResource = save_data.shop_rotation[index]
	if item == null or is_inventory_full():
		return false
	return save_data.gold >= get_buy_price(item)


func buy_shop_item(index: int) -> bool:
	if not can_buy_shop_item(index):
		return false
	var item: InventoryItemResource = save_data.shop_rotation[index]
	spend_gold(get_buy_price(item))
	add_inventory_item(item)
	save_data.shop_rotation[index] = null
	save_game()
	return true


func get_player_stat_definition(stat_key: String) -> PlayerStatDefinitionResource:
	for definition in player_stat_definitions:
		if definition.stat_key == stat_key:
			return definition
	return null


func get_player_stat_level(stat_key: String) -> int:
	_ensure_save_data()
	return save_data.player_stat_levels.get(stat_key, 0)


func get_player_stat_value(stat_key: String) -> float:
	var definition: PlayerStatDefinitionResource = get_player_stat_definition(stat_key)
	if definition == null:
		return 0.0
	return definition.get_value_for_level(get_player_stat_level(stat_key))


func can_upgrade_player_stat(stat_key: String) -> bool:
	_ensure_save_data()
	var definition: PlayerStatDefinitionResource = get_player_stat_definition(stat_key)
	if definition == null:
		return false
	var level: int = get_player_stat_level(stat_key)
	if level >= definition.get_max_level():
		return false
	var cost: int = definition.get_cost_for_level(level)
	return cost >= 0 and save_data.gold >= cost


func try_upgrade_player_stat(stat_key: String) -> bool:
	if not can_upgrade_player_stat(stat_key):
		return false
	var definition: PlayerStatDefinitionResource = get_player_stat_definition(stat_key)
	var level: int = get_player_stat_level(stat_key)
	save_data.gold -= definition.get_cost_for_level(level)
	save_data.player_stat_levels[stat_key] = level + 1
	save_game()
	gold_changed.emit(save_data.gold)
	return true
