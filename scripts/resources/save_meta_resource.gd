extends Resource
class_name SaveMetaResource

# Indice leggero letto dalla StartupScreen senza dover caricare i 3
# SaveData completi. Un valore per slot, allineato per indice (0,1,2).
# Aggiornato da GameState ad ogni save_game()/load_slot()/create_new_save().

@export var slot_occupied: Array[bool] = [false, false, false]
@export var highest_level_reached: Array[int] = [0, 0, 0]
@export var difficulty_mode: Array[int] = [-1, -1, -1]
@export var last_access_unix: Array[int] = [0, 0, 0]
@export var last_used_slot: int = -1
