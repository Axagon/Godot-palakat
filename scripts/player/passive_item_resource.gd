extends Resource
class_name PassiveItemResource

# Definizione dati di un accessorio passivo (Monile/Mantello/Armatura).
# Bonus fissi sommati direttamente ai valori base, bonus percentuali
# applicati come moltiplicatore. Nessuna logica qui, solo statistiche.

@export var item_name: String = ""

@export var max_health_flat: int = 0
@export var max_mana_flat: float = 0.0
@export var mana_regen_flat: float = 0.0
@export var max_food_flat: float = 0.0
@export var food_regen_flat: float = 0.0

@export var move_speed_percent: float = 0.0
@export var spell_damage_percent: float = 0.0
@export var shield_regen_percent: float = 0.0

@export var max_summons_bonus: int = 0
