extends BaseUpgradeCurveResource
class_name PlayerStatDefinitionResource

# Definizione dati di UNA singola capacita' potenziabile del player.
# Ogni nuova capacita' futura = un nuovo .tres di questo tipo, aggiunto
# all'array GameState.player_stat_definitions. Nessun codice da toccare.

@export var stat_key: String = ""          # identificatore univoco, letto da GameState/UI
@export var stat_label: String = ""        # etichetta mostrata in UI
@export var display_as_percent: bool = false

@export var base_value: float = 0.0        # valore a livello 0 (non potenziato)
@export var value_per_level: float = 0.0   # incremento per livello, puo' essere negativo
@export var clamp_min: float = -1000000.0
@export var clamp_max: float = 1000000.0


func get_value_for_level(level: int) -> float:
	var raw: float = base_value + float(level) * value_per_level
	return clamp(raw, clamp_min, clamp_max)
