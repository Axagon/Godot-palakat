extends Resource
class_name SpellSlotScalingResource

# Moltiplicatori applicati alle statistiche di un Catalizzatore in base allo
# slot in cui viene equipaggiato. Dati puri di bilanciamento, nessuna logica.

@export var base_damage_mult: float = 1.0
@export var base_mana_mult: float = 1.0
@export var base_cooldown_mult: float = 1.0

@export var secondary_damage_mult: float = 2.2
@export var secondary_mana_mult: float = 2.5
@export var secondary_cooldown_mult: float = 2.5

@export var ultimate_damage_mult: float = 5.0
@export var ultimate_mana_mult: float = 6.0
@export var ultimate_cooldown_mult: float = 8.0
