# progression_config.gd — dati puri di bilanciamento progressione, editabili in Inspector
extends Resource
class_name ProgressionConfig

@export var starting_catalysts: Array[CatalystResource] = []
@export var catalyst_unlock_queue: Array[CatalystResource] = []
@export var catalyst_unlock_first_level: int = 10
@export var catalyst_unlock_interval: int = 10

@export var starting_summons: Array[SummonResource] = []
@export var summon_unlock_queue: Array[SummonResource] = []
@export var summon_unlock_first_level: int = 5
@export var summon_unlock_interval: int = 10

@export var level_complete_base_gold: int = 20
@export var level_complete_bonus_per_heart: int = 10

@export var defeat_gold_fraction: float = 0.4

@export var fragment_reward_normal: int = 1
@export var fragment_reward_checkpoint: int = 3

@export var droppable_passive_items: Array[PassiveItemResource] = []
@export var droppable_shield_items: Array[ShieldResource] = []
