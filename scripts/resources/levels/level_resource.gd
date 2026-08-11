extends Resource
class_name LevelResource

# Definizione dati di un livello: nome e sequenza di ondate nemiche.
# Nessuna logica qui, solo configurazione.

@export var level_number: int = 1
@export var level_name: String = ""
@export var waves: Array[WaveResource] = []
@export var world_number: int = 1
@export var display_level_in_world: int = 1

func get_display_name() -> String:
	return "Livello %d-%d" % [world_number, display_level_in_world]
