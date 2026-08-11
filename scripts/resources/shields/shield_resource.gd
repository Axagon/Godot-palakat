extends Resource
class_name ShieldResource

# Definizione dati dello Scudo. Nessuna logica qui, solo statistiche.

enum UpgradeStat { MAX_SHIELD, REGEN }

@export var item_name: String = ""
@export var max_shield: float = 0.0
@export var shield_regen_per_second: float = 0.0

@export var upgrade_curve: UpgradeCurveResource = null
@export var upgrade_target_stat: UpgradeStat = UpgradeStat.MAX_SHIELD
