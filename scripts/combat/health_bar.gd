extends Node2D
class_name HealthBar

# Barra vita "fluttuante" mostrata sopra le unita' da combattimento.
# Visibile solo quando l'unita' ha subito danno (vita < massimo) E,
# se il parent e' un Enemy (incluse sottoclassi Boss/Dragon), solo se
# l'impostazione "show_enemy_health" e' attiva.

@onready var fill: ColorRect = $Fill

var _full_width: float = 0.0
var _hide_for_enemies: bool = false
var _last_current_health: int = 0
var _last_max_health: int = 0


func _ready() -> void:
	visible = false
	_full_width = fill.size.x
	if get_parent() is Enemy:
		_hide_for_enemies = SettingsManager.get_value("show_enemy_health", 1.0) < 0.5
		SettingsManager.setting_changed.connect(_on_setting_changed)


func setup(health_component: HealthComponent) -> void:
	health_component.health_changed.connect(_on_health_changed)


func _on_health_changed(current_health: int, max_health: int) -> void:
	_last_current_health = current_health
	_last_max_health = max_health
	_apply_visibility()
	var ratio: float = float(current_health) / float(max_health) if max_health > 0 else 0.0
	fill.size.x = _full_width * ratio


func _on_setting_changed(key: String, value: float) -> void:
	if key != "show_enemy_health":
		return
	_hide_for_enemies = value < 0.5
	_apply_visibility()


func _apply_visibility() -> void:
	var should_show: bool = _last_current_health < _last_max_health and _last_current_health > 0
	visible = should_show and not _hide_for_enemies
