extends Node2D
class_name HealthBar

# Barra vita "fluttuante" mostrata sopra le unita' da combattimento.
# Visibile solo quando l'unita' ha subito danno (vita < massimo).

@onready var fill: ColorRect = $Fill

var _full_width: float = 0.0


func _ready() -> void:
	visible = false
	_full_width = fill.size.x


func setup(health_component: HealthComponent) -> void:
	health_component.health_changed.connect(_on_health_changed)


func _on_health_changed(current_health: int, max_health: int) -> void:
	visible = current_health < max_health and current_health > 0
	var ratio: float = float(current_health) / float(max_health) if max_health > 0 else 0.0
	fill.size.x = _full_width * ratio
