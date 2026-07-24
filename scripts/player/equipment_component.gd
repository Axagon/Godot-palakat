extends Node
class_name EquipmentComponent

# Gestisce i 3 slot Catalizzatore del player: costruisce le SpellResource
# finali applicando lo scaling per slot e le assegna al Player. Se uno slot
# non ha catalizzatore equipaggiato, la magia esistente sul Player (fallback
# manuale) resta invariata.

@export var base_catalyst: CatalystResource
@export var secondary_catalyst: CatalystResource
@export var ultimate_catalyst: CatalystResource
@export var slot_scaling: SpellSlotScalingResource
@export var passive_item: PassiveItemResource
@export var shield_item: ShieldResource

@onready var _player: Player = get_parent()
@onready var _health_component: HealthComponent = get_parent().get_node("HealthComponent")
@onready var _mana_component: ManaComponent = get_parent().get_node("ManaComponent")
@onready var _food_component: FoodComponent = get_parent().get_node("FoodComponent")
@onready var _shield_component: ShieldComponent = get_parent().get_node("ShieldComponent")

var spell_damage_percent: float = 0.0


func _ready() -> void:
	if slot_scaling == null:
		push_warning("EquipmentComponent: slot_scaling non assegnato, uso valori di default 1.0")
		slot_scaling = SpellSlotScalingResource.new()

	_apply_loadout_selection()

	_equip_slot(base_catalyst, SpellResource.SpellSlot.BASE)
	_equip_slot(secondary_catalyst, SpellResource.SpellSlot.SECONDARY)
	_equip_slot(ultimate_catalyst, SpellResource.SpellSlot.ULTIMATE)

	_apply_passive_item()
	_apply_shield_item()
	_player.max_summons = _player.base_max_summons + (passive_item.max_summons_bonus if passive_item != null else 0)


func _apply_loadout_selection() -> void:
	if GameState.selected_catalysts[SpellResource.SpellSlot.BASE] != null:
		base_catalyst = GameState.selected_catalysts[SpellResource.SpellSlot.BASE]
	if GameState.selected_catalysts[SpellResource.SpellSlot.SECONDARY] != null:
		secondary_catalyst = GameState.selected_catalysts[SpellResource.SpellSlot.SECONDARY]
	if GameState.selected_catalysts[SpellResource.SpellSlot.ULTIMATE] != null:
		ultimate_catalyst = GameState.selected_catalysts[SpellResource.SpellSlot.ULTIMATE]
	

func _equip_slot(catalyst: CatalystResource, slot: SpellResource.SpellSlot) -> void:
	var built_spell: SpellResource = _build_spell(catalyst, slot)
	if built_spell == null:
		return
	match slot:
		SpellResource.SpellSlot.BASE:
			_player.base_spell = built_spell
		SpellResource.SpellSlot.SECONDARY:
			_player.secondary_spell = built_spell
		SpellResource.SpellSlot.ULTIMATE:
			_player.ultimate_spell = built_spell


func _apply_passive_item() -> void:
	if passive_item == null:
		return

	_health_component.max_health += passive_item.max_health_flat
	_health_component.current_health = _health_component.max_health

	_mana_component.max_mana += passive_item.max_mana_flat
	_mana_component.regen_per_second += passive_item.mana_regen_flat
	_mana_component.current_mana = _mana_component.max_mana

	_food_component.max_food += passive_item.max_food_flat
	_food_component.regen_per_second += passive_item.food_regen_flat
	_food_component.current_food = _food_component.max_food

	_player.move_speed *= (1.0 + passive_item.move_speed_percent)

	spell_damage_percent = passive_item.spell_damage_percent
	

func _apply_shield_item() -> void:
	if shield_item == null:
		return

	var regen_bonus_mult: float = 1.0
	if passive_item != null:
		regen_bonus_mult += passive_item.shield_regen_percent

	_shield_component.max_shield += shield_item.max_shield
	_shield_component.regen_per_second += shield_item.shield_regen_per_second * regen_bonus_mult
	_shield_component.current_shield = _shield_component.max_shield


func _build_spell(catalyst: CatalystResource, slot: SpellResource.SpellSlot) -> SpellResource:
	if catalyst == null:
		return null

	var damage_mult: float
	var mana_mult: float
	var cooldown_mult: float
	match slot:
		SpellResource.SpellSlot.BASE:
			damage_mult = slot_scaling.base_damage_mult
			mana_mult = slot_scaling.base_mana_mult
			cooldown_mult = slot_scaling.base_cooldown_mult
		SpellResource.SpellSlot.SECONDARY:
			damage_mult = slot_scaling.secondary_damage_mult
			mana_mult = slot_scaling.secondary_mana_mult
			cooldown_mult = slot_scaling.secondary_cooldown_mult
		SpellResource.SpellSlot.ULTIMATE:
			damage_mult = slot_scaling.ultimate_damage_mult
			mana_mult = slot_scaling.ultimate_mana_mult
			cooldown_mult = slot_scaling.ultimate_cooldown_mult

	var spell: SpellResource = SpellResource.new()
	spell.spell_name = catalyst.catalyst_name
	spell.slot = slot
	spell.element = catalyst.element
	spell.spell_type = catalyst.spell_type
	spell.damage = int(round(catalyst.base_damage * damage_mult))
	spell.heal_amount = int(round(catalyst.base_heal_amount * damage_mult))
	spell.shield_amount = catalyst.base_shield_amount * damage_mult
	spell.mana_cost = int(round(catalyst.base_mana_cost * mana_mult))
	spell.cooldown = catalyst.base_cooldown * cooldown_mult
	spell.spell_range = catalyst.base_range
	return spell
