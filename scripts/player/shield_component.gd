extends Node
class_name ShieldComponent

# Barra protettiva separata dagli HP. Assorbe danno prima dei Cuori e si
# rigenera passivamente nel tempo, MA si ferma permanentemente a 0 finche'
# non viene ricaricata esplicitamente (add_shield, es. magie scudo).
# L'overflow di un colpo che supera lo scudo residuo viene scartato: non
# raggiunge mai i punti ferita tramite questo componente.

signal shield_changed(current_shield: float, max_shield: float)

@export var item_name: String = ""
@export var icon: Texture2D = null

@export var max_shield: float = 0.0
@export var regen_per_second: float = 0.0

@export var base_value: int = 0

var current_shield: float


func _ready() -> void:
	current_shield = max_shield
	shield_changed.emit(current_shield, max_shield)


func _process(delta: float) -> void:
	if current_shield > 0.0 and current_shield < max_shield:
		current_shield = min(current_shield + regen_per_second * delta, max_shield)
		shield_changed.emit(current_shield, max_shield)


# Ritorna true SOLO se lo scudo era gia' a 0 (il danno raggiunge la vita).
# In ogni altro caso il colpo viene assorbito e l'eventuale eccedenza
# scartata, anche se rompe lo scudo in questo stesso colpo.
func absorb_damage(amount: int) -> bool:
	if current_shield <= 0.0:
		return true
	current_shield = max(current_shield - float(amount), 0.0)
	shield_changed.emit(current_shield, max_shield)
	return false


func add_shield(amount: float) -> void:
	current_shield = min(current_shield + amount, max_shield)
	shield_changed.emit(current_shield, max_shield)


func get_rollable_field_names() -> Array[String]:
	return ["max_shield", "shield_regen_per_second"]
