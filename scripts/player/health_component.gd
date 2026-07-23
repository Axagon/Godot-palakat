extends Node
class_name HealthComponent

# Componente riutilizzabile per la gestione della salute.
# Gestisce HP correnti/massimi e notifica variazioni tramite segnali.

signal health_changed(current_health: int, max_health: int)
signal died

@export var max_health: int = 3

var current_health: int


func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func take_damage(amount: int) -> void:
	if current_health <= 0:
		return
	current_health = max(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		died.emit()


func heal(amount: int) -> void:
	if current_health <= 0:
		return
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


func is_alive() -> bool:
	return current_health > 0
