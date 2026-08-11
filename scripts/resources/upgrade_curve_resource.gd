extends BaseUpgradeCurveResource
class_name UpgradeCurveResource

@export var stat_multiplier_per_level: Array[float] = []


func get_multiplier_for_level(level: int) -> float:
	if level <= 0 or stat_multiplier_per_level.is_empty():
		return 1.0
	var index: int = min(level, stat_multiplier_per_level.size()) - 1
	return stat_multiplier_per_level[index]
