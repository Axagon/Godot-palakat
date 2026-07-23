extends Node
class_name FoodComponent

# Gestione della risorsa Cibo, gemella concettuale di ManaComponent.
# Usata esclusivamente per l'attivazione delle carte evocazione.

signal food_changed(current_food: float, max_food: float)

@export var max_food: float = 100.0
@export var regen_per_second: float = 2.0

var current_food: float


func _ready() -> void:
	current_food = max_food
	food_changed.emit(current_food, max_food)


func _process(delta: float) -> void:
	if current_food < max_food:
		current_food = min(current_food + regen_per_second * delta, max_food)
		food_changed.emit(current_food, max_food)


func has_enough_food(amount: float) -> bool:
	return current_food >= amount


func consume_food(amount: float) -> void:
	current_food = max(current_food - amount, 0.0)
	food_changed.emit(current_food, max_food)
