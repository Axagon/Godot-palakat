extends Control
class_name UpgradeRowUI

@onready var icon_texture: TextureRect = $IconTexture
@onready var name_label: Label = $InfoContainer/NameLabel
@onready var level_label: Label = $InfoContainer/LevelLabel
@onready var stats_container: VBoxContainer = $InfoContainer/StatsContainer
@onready var cost_label: Label = $CostLabel
@onready var upgrade_button: Button = $UpgradeButton

var _resource: Resource = null
var _curve: BaseUpgradeCurveResource = null


func setup(resource: Resource, curve: BaseUpgradeCurveResource, display_name: String, icon: Texture2D) -> void:
	_resource = resource
	_curve = curve
	name_label.text = display_name
	icon_texture.texture = icon
	icon_texture.visible = icon != null
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	GameState.gold_changed.connect(_on_gold_changed)
	_refresh()


func _on_upgrade_pressed() -> void:
	GameState.try_upgrade(_resource, _curve)


func _on_gold_changed(_current_gold: int) -> void:
	_refresh()


func _refresh() -> void:
	var current_level: int = GameState.get_upgrade_level(_resource)
	var max_level: int = _curve.get_max_level() if _curve != null else 0
	level_label.text = "Livello %d/%d" % [current_level, max_level]

	for child in stats_container.get_children():
		child.queue_free()
	for row in UpgradeDisplayUtil.get_stat_rows(_resource, _curve):
		var stat_label := Label.new()
		stat_label.text = "%s: %s" % [row.label, row.value]
		if row.highlighted:
			stat_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		stats_container.add_child(stat_label)

	var is_maxed: bool = current_level >= max_level
	if is_maxed:
		cost_label.text = "Potenziamento massimo"
		upgrade_button.text = "MAX"
		upgrade_button.disabled = true
	else:
		var cost: int = _curve.get_cost_for_level(current_level)
		cost_label.text = "Costo: %d Lische d'Oro" % cost
		upgrade_button.text = "Potenzia"
		upgrade_button.disabled = not GameState.can_upgrade(_resource, _curve)
	
