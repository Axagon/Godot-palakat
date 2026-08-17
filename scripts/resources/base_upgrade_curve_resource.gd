extends Resource
class_name BaseUpgradeCurveResource

# Base comune per qualunque curva di potenziamento (Catalizzatori/Equip a
# singola stat, Evocazioni multi-stat, future categorie). Definisce solo il
# contratto costo/livello, condiviso da GameState.can_upgrade()/try_upgrade().
# I moltiplicatori per statistica restano specifici di ogni sottoclasse,
# dato che "quali stat" e "quante" variano per categoria.

@export var gold_cost_per_level: Array[int] = []
@export var fragment_cost_per_level: Array[int] = []  # indice = livello (0-based), vuoto/0 = nessun costo Frammenti a quel livello

func get_max_level() -> int:
	return gold_cost_per_level.size()


func get_cost_for_level(level: int) -> int:
	if level < 0 or level >= gold_cost_per_level.size():
		return -1
	return gold_cost_per_level[level]


func get_fragment_cost_for_level(level: int) -> int:
	if level < 0 or level >= fragment_cost_per_level.size():
		return 0
	return fragment_cost_per_level[level]
