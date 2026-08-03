# hud.gd — versione aggiornata
extends CanvasLayer
class_name HUD

@onready var base_button: Button = $Control/SpellButtons/BaseButton
@onready var secondary_button: Button = $Control/SpellButtons/SecondaryButton
@onready var ultimate_button: Button = $Control/SpellButtons/UltimateButton

@onready var player_health_fill: Panel = $Control/PlayerHealthBar/Fill
@onready var player_mana_fill: Panel = $Control/PlayerManaBar/Fill
@onready var player_food_fill: Panel = $Control/PlayerFoodBar/Fill
@onready var player_shield_fill: Panel = $Control/PlayerShieldBar/Fill

@onready var player_health_label: Label = $Control/PlayerHealthBar/Label
@onready var player_mana_label: Label = $Control/PlayerManaBar/Label
@onready var player_food_label: Label = $Control/PlayerFoodBar/Label
@onready var player_shield_label: Label = $Control/PlayerShieldBar/Label

@onready var level_name_label: Label = $Control/LevelNameLabel

@onready var summon_count_label: Label = $Control/SummonCountLabel

var _player_ref: Player = null
var _player_health_full_width: float = 0.0
var _player_mana_full_width: float = 0.0
var _player_food_full_width: float = 0.0
var _player_shield_full_width: float = 0.0

var _mana_regen: float = 0.0
var _food_regen: float = 0.0
var _shield_regen: float = 0.0


func _ready() -> void:
	await get_tree().process_frame
	var player: Player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	_player_ref = player
	base_button.pressed.connect(func(): player.spell_caster.try_cast(player.base_spell))
	secondary_button.pressed.connect(func(): player.spell_caster.try_cast(player.secondary_spell))
	ultimate_button.pressed.connect(func(): player.spell_caster.try_cast(player.ultimate_spell))

	_player_health_full_width = player_health_fill.size.x
	player.health_component.health_changed.connect(_on_player_health_changed)

	_player_mana_full_width = player_mana_fill.size.x
	_mana_regen = player.mana_component.regen_per_second
	player.mana_component.mana_changed.connect(_on_player_mana_changed)

	_player_food_full_width = player_food_fill.size.x
	_food_regen = player.food_component.regen_per_second
	player.food_component.food_changed.connect(_on_player_food_changed)

	_player_shield_full_width = player_shield_fill.size.x
	_shield_regen = player.shield_component.regen_per_second
	player.shield_component.shield_changed.connect(_on_player_shield_changed)

	var level_manager: LevelManager = get_tree().get_first_node_in_group("level_manager")
	if level_manager != null and level_manager.level != null:
		level_name_label.text = level_manager.level.get_display_name()


func _process(_delta: float) -> void:
	if _player_ref == null:
		return
	var active_count: int = get_tree().get_nodes_in_group("active_summons").size()
	summon_count_label.text = "Evocazioni: %d/%d" % [active_count, _player_ref.max_summons]


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	var ratio: float = float(current_health) / float(max_health) if max_health > 0 else 0.0
	player_health_fill.size.x = _player_health_full_width * ratio
	player_health_label.text = "%d/%d" % [current_health, max_health]


func _on_player_mana_changed(current_mana: float, max_mana: float) -> void:
	var ratio: float = current_mana / max_mana if max_mana > 0.0 else 0.0
	player_mana_fill.size.x = _player_mana_full_width * ratio
	player_mana_label.text = "%d/%d (+%.1f/s)" % [int(current_mana), int(max_mana), _mana_regen]


func _on_player_food_changed(current_food: float, max_food: float) -> void:
	var ratio: float = current_food / max_food if max_food > 0.0 else 0.0
	player_food_fill.size.x = _player_food_full_width * ratio
	player_food_label.text = "%d/%d (+%.1f/s)" % [int(current_food), int(max_food), _food_regen]


func _on_player_shield_changed(current_shield: float, max_shield: float) -> void:
	var ratio: float = current_shield / max_shield if max_shield > 0.0 else 0.0
	player_shield_fill.size.x = _player_shield_full_width * ratio
	player_shield_label.text = "%d/%d (+%.1f/s)" % [int(current_shield), int(max_shield), _shield_regen]
