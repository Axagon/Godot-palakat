extends CanvasLayer
class_name HUD

@onready var base_button: Button = $Control/SpellButtons/BaseButton
@onready var secondary_button: Button = $Control/SpellButtons/SecondaryButton
@onready var ultimate_button: Button = $Control/SpellButtons/UltimateButton
@onready var player_health_fill: ColorRect = $Control/PlayerHealthBar/Fill
@onready var player_mana_fill: ColorRect = $Control/PlayerManaBar/Fill
@onready var player_food_fill: ColorRect = $Control/PlayerFoodBar/Fill
@onready var player_shield_fill: ColorRect = $Control/PlayerShieldBar/Fill

var _player_health_full_width: float = 0.0
var _player_mana_full_width: float = 0.0
var _player_food_full_width: float = 0.0
var _player_shield_full_width: float = 0.0


func _ready() -> void:
	await get_tree().process_frame
	var player: Player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	base_button.pressed.connect(func(): player.spell_caster.try_cast(player.base_spell))
	secondary_button.pressed.connect(func(): player.spell_caster.try_cast(player.secondary_spell))
	ultimate_button.pressed.connect(func(): player.spell_caster.try_cast(player.ultimate_spell))

	_player_health_full_width = player_health_fill.size.x
	player.health_component.health_changed.connect(_on_player_health_changed)

	_player_mana_full_width = player_mana_fill.size.x
	player.mana_component.mana_changed.connect(_on_player_mana_changed)

	_player_food_full_width = player_food_fill.size.x
	player.food_component.food_changed.connect(_on_player_food_changed)

	_player_shield_full_width = player_shield_fill.size.x
	player.shield_component.shield_changed.connect(_on_player_shield_changed)


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	var ratio: float = float(current_health) / float(max_health) if max_health > 0 else 0.0
	player_health_fill.size.x = _player_health_full_width * ratio


func _on_player_mana_changed(current_mana: float, max_mana: float) -> void:
	var ratio: float = current_mana / max_mana if max_mana > 0.0 else 0.0
	player_mana_fill.size.x = _player_mana_full_width * ratio


func _on_player_food_changed(current_food: float, max_food: float) -> void:
	var ratio: float = current_food / max_food if max_food > 0.0 else 0.0
	player_food_fill.size.x = _player_food_full_width * ratio


func _on_player_shield_changed(current_shield: float, max_shield: float) -> void:
	var ratio: float = current_shield / max_shield if max_shield > 0.0 else 0.0
	player_shield_fill.size.x = _player_shield_full_width * ratio
	
