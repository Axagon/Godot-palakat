# save_data.gd — stato persistente del giocatore, serializzato su disco
extends Resource
class_name SaveData

@export var highest_level_unlocked: int = 1
@export var owned_catalysts: Array[CatalystResource] = []
@export var owned_summons: Array[SummonResource] = []
