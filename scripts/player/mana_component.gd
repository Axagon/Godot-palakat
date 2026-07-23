extends Node
class_name ManaComponent

# Componente riutilizzabile per la gestione del Mana.
# Gestisce pool corrente/massimo e rigenerazione nel tempo.

signal mana_changed(current_mana: float, max_mana: float)

@export var max_mana: float = 100.0
@export var regen_per_second: float = 1.0

var current_mana: float


func _ready() -> void:
	current_mana = max_mana
	mana_changed.emit(current_mana, max_mana)


func _process(delta: float) -> void:
	if current_mana < max_mana:
		current_mana = min(current_mana + regen_per_second * delta, max_mana)
		mana_changed.emit(current_mana, max_mana)


func has_enough_mana(amount: float) -> bool:
	return current_mana >= amount


func consume_mana(amount: float) -> void:
	current_mana = max(current_mana - amount, 0.0)
	mana_changed.emit(current_mana, max_mana)
