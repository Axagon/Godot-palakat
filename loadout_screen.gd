extends Control
class_name LoadoutScreen

@export var game_scene_path: String = "res://scenes/test_level.tscn"
@export var deck_max_size: int = 6

@onready var base_row: HBoxContainer = $MarginContainer/VBoxContainer/CatalystSection/BaseRow
@onready var secondary_row: HBoxContainer = $MarginContainer/VBoxContainer/CatalystSection/SecondaryRow
@onready var ultimate_row: HBoxContainer = $MarginContainer/VBoxContainer/CatalystSection/UltimateRow
@onready var summon_grid: GridContainer = $MarginContainer/VBoxContainer/SummonSection/SummonGrid
@onready var start_button: Button = $MarginContainer/VBoxContainer/StartButton

var _selected_catalysts: Array[CatalystResource] = [null, null, null]
var _selected_summons: Array[SummonResource] = []

# Bottoni indicizzati per slot poi per catalizzatore: servono per
# deselezionare automaticamente un catalizzatore da un altro slot quando
# viene assegnato altrove (ogni catalizzatore attivo su UN solo slot).
var _catalyst_buttons: Array = [{}, {}, {}]


func _ready() -> void:
	var owned: Array[CatalystResource] = GameState.get_owned_catalysts()
	_build_catalyst_row(base_row, SpellResource.SpellSlot.BASE, owned)
	_build_catalyst_row(secondary_row, SpellResource.SpellSlot.SECONDARY, owned)
	_build_catalyst_row(ultimate_row, SpellResource.SpellSlot.ULTIMATE, owned)
	_apply_default_catalyst_selection(owned)
	_build_summon_grid()
	start_button.pressed.connect(_on_start_pressed)


func _build_catalyst_row(row: HBoxContainer, slot: SpellResource.SpellSlot, owned: Array[CatalystResource]) -> void:
	var group := ButtonGroup.new()
	for catalyst in owned:
		var button := Button.new()
		button.text = catalyst.catalyst_name
		button.toggle_mode = true
		button.button_group = group
		button.custom_minimum_size = Vector2(120, 50)
		button.pressed.connect(_on_catalyst_selected.bind(slot, catalyst))
		row.add_child(button)
		_catalyst_buttons[slot][catalyst] = button


func _apply_default_catalyst_selection(owned: Array[CatalystResource]) -> void:
	# Ogni catalizzatore posseduto viene assegnato di default ad UN solo
	# slot, nell'ordine in cui compare nell'elenco posseduto. Se i
	# catalizzatori posseduti sono meno di 3, gli slot restanti partono
	# vuoti (l'equipaggio esistente sul Player resta invariato per quello
	# slot, stesso fallback gia' usato altrove).
	for slot in range(3):
		if slot < owned.size():
			var catalyst: CatalystResource = owned[slot]
			_selected_catalysts[slot] = catalyst
			_catalyst_buttons[slot][catalyst].button_pressed = true


func _on_catalyst_selected(slot: SpellResource.SpellSlot, catalyst: CatalystResource) -> void:
	for other_slot in range(3):
		if other_slot == slot:
			continue
		if _selected_catalysts[other_slot] == catalyst:
			_selected_catalysts[other_slot] = null
			_catalyst_buttons[other_slot][catalyst].button_pressed = false
	_selected_catalysts[slot] = catalyst


func _build_summon_grid() -> void:
	var owned: Array[SummonResource] = GameState.get_owned_summons()
	for summon in owned:
		var button := Button.new()
		button.text = summon.summon_name
		button.toggle_mode = true
		button.custom_minimum_size = Vector2(120, 50)
		button.pressed.connect(_on_summon_toggled.bind(summon, button))
		summon_grid.add_child(button)
		if _selected_summons.size() < deck_max_size:
			_selected_summons.append(summon)
			button.button_pressed = true


func _on_summon_toggled(summon: SummonResource, button: Button) -> void:
	if button.button_pressed:
		if _selected_summons.size() >= deck_max_size:
			button.button_pressed = false
			return
		_selected_summons.append(summon)
	else:
		_selected_summons.erase(summon)


func _on_start_pressed() -> void:
	GameState.selected_catalysts = _selected_catalysts
	GameState.selected_deck = _selected_summons
	get_tree().change_scene_to_file(game_scene_path)
