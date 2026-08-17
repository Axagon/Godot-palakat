extends HBoxContainer
class_name PlayerStatRowUI

@onready var name_label: Label = $NameLabel
@onready var value_label: Label = $ValueLabel
@onready var cost_label: Label = $CostLabel
@onready var upgrade_button: Button = $UpgradeButton

var _stat_key: String = ""


func setup(definition: PlayerStatDefinitionResource) -> void:
	_stat_key = definition.stat_key
	name_label.text = definition.stat_label
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	GameState.gold_changed.connect(func(_g): _refresh())
	_refresh()


func _refresh() -> void:
	var definition: PlayerStatDefinitionResource = GameState.get_player_stat_definition(_stat_key)
	var level: int = GameState.get_player_stat_level(_stat_key)
	var max_level: int = definition.get_max_level()
	value_label.text = "Liv. %d/%d - %s" % [level, max_level, _format_value(definition, definition.get_value_for_level(level))]

	if level >= max_level:
		cost_label.text = "MAX"
		upgrade_button.text = "MAX"
		upgrade_button.disabled = true
	else:
		cost_label.text = "%d Lische d'Oro" % definition.get_cost_for_level(level)
		upgrade_button.text = "Potenzia"
		upgrade_button.disabled = not GameState.can_upgrade_player_stat(_stat_key)


func _format_value(definition: PlayerStatDefinitionResource, value: float) -> String:
	if definition.display_as_percent:
		return "%d%%" % int(round(value * 100))
	return str(int(round(value)))


func _on_upgrade_pressed() -> void:
	GameState.try_upgrade_player_stat(_stat_key)
