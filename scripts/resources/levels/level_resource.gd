extends Resource
class_name LevelResource

# Definizione dati di un livello: nome e sequenza di ondate nemiche.
# Nessuna logica qui, solo configurazione.

@export var level_number: int = 1
@export var level_name: String = ""
@export var waves: Array[WaveResource] = []
