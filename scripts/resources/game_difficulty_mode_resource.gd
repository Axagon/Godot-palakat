extends Resource
class_name DifficultyModeResource

# Modalita' di difficolta' selezionata alla creazione dello slot,
# immutabile per tutta la sua vita. A differenza di DifficultyScalingResource
# (crescita continua per livello, esclude i Boss), questo moltiplicatore
# si applica anche ai Boss: e' una scelta esplicita del giocatore, non
# uno scaling automatico di progressione.

@export var mode_name: String = ""
@export var stat_multiplier: float = 1.0   # HP e danno nemici, Boss inclusi
@export var reward_multiplier: float = 1.0 # curva di compensazione, piu' dolce
