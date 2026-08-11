extends Resource
class_name WaveResource

# Definizione dati di una singola ondata di nemici all'interno di un livello.
# Il pool puo' contenere piu' EnemyResource: ad ogni spawn ne viene scelto uno
# a caso, stesso principio della pesca casuale nel mazzo evocazioni. Ripetere
# la stessa risorsa piu' volte nell'array ne aumenta la probabilita' di
# estrazione (peso implicito, nessun campo di probabilita' dedicato).

@export var enemy_pool: Array[EnemyResource] = []
@export var enemy_count: int = 5
@export var spawn_interval: float = 2.0
@export var start_time: float = 0.0
@export var enemy_scene_override: PackedScene = null

# Probabilita' indipendente (0.0-1.0) che un singolo spawn di questa wave sia
# Elite o Super Elite. Estrazione fatta dal LevelManager al momento dello
# spawn, non qui: la risorsa resta dato puro. Super Elite ha priorita' se
# entrambi i tiri hanno successo (vedi LevelManager._roll_rank()).
@export_range(0.0, 1.0) var elite_chance: float = 0.0
@export_range(0.0, 1.0) var super_elite_chance: float = 0.0
