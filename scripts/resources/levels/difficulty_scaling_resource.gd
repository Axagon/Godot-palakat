# difficulty_scaling_resource.gd
extends Resource
class_name DifficultyScalingResource

# Scaling difficolta' a due strati per nemici comuni (mai per Boss, esclusi
# esplicitamente in Enemy._compute_final_stats()). Crescita continua legata
# a level_number (mai resettata tra aree) moltiplicata per un fattore fisso
# per world_number, scritto a mano per esprimere l'accelerazione nelle aree
# avanzate senza dedurla da una formula. Dati puri di bilanciamento.

@export var hp_growth_per_level: float = 0.03
@export var damage_growth_per_level: float = 0.02

@export var hp_world_multipliers: Array[float] = [1.0]
@export var damage_world_multipliers: Array[float] = [1.0]


func get_hp_multiplier(level_number: int, world_number: int) -> float:
	var continuous: float = 1.0 + hp_growth_per_level * float(level_number - 1)
	return continuous * _get_world_multiplier(hp_world_multipliers, world_number)


func get_damage_multiplier(level_number: int, world_number: int) -> float:
	var continuous: float = 1.0 + damage_growth_per_level * float(level_number - 1)
	return continuous * _get_world_multiplier(damage_world_multipliers, world_number)


func _get_world_multiplier(multipliers: Array[float], world_number: int) -> float:
	if multipliers.is_empty():
		return 1.0
	var index: int = world_number - 1
	if index < 0:
		index = 0
	if index >= multipliers.size():
		push_warning("DifficultyScalingResource: nessun moltiplicatore per world_number %d, uso l'ultimo disponibile" % world_number)
		index = multipliers.size() - 1
	return multipliers[index]
