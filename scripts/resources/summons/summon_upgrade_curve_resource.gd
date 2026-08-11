extends BaseUpgradeCurveResource
class_name SummonUpgradeCurveResource

@export var max_health_mult_per_level: Array[float] = []
@export var attack_damage_mult_per_level: Array[float] = []
@export var move_speed_mult_per_level: Array[float] = []


func get_health_multiplier(level: int) -> float:
	return _multiplier_for_level(max_health_mult_per_level, level)


func get_damage_multiplier(level: int) -> float:
	return _multiplier_for_level(attack_damage_mult_per_level, level)


func get_speed_multiplier(level: int) -> float:
	return _multiplier_for_level(move_speed_mult_per_level, level)


func _multiplier_for_level(multipliers: Array[float], level: int) -> float:
	if level <= 0 or multipliers.is_empty():
		return 1.0
	var index: int = min(level, multipliers.size()) - 1
	return multipliers[index]
