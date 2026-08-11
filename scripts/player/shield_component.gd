extends Node
class_name ShieldComponent

# Barra protettiva separata dagli HP. Assorbe danno prima dei Cuori e si
# rigenera passivamente nel tempo. add_shield() e' un aggancio pronto per
# future magie difensive che ricaricano lo scudo attivamente.

signal shield_changed(current_shield: float, max_shield: float)

@export var item_name: String = ""
@export var icon: Texture2D = null

@export var max_shield: float = 0.0
@export var regen_per_second: float = 0.0

var current_shield: float


func _ready() -> void:
	current_shield = max_shield
	shield_changed.emit(current_shield, max_shield)


func _process(delta: float) -> void:
	if current_shield < max_shield:
		current_shield = min(current_shield + regen_per_second * delta, max_shield)
		shield_changed.emit(current_shield, max_shield)


func absorb_damage(amount: int) -> int:
	if current_shield <= 0.0:
		return amount
	var absorbed: float = min(current_shield, float(amount))
	current_shield -= absorbed
	shield_changed.emit(current_shield, max_shield)
	return int(ceil(amount - absorbed))


func add_shield(amount: float) -> void:
	current_shield = min(current_shield + amount, max_shield)
	shield_changed.emit(current_shield, max_shield)
	
