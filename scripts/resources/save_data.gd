extends Resource
class_name SaveData

@export var highest_level_unlocked: int = 1

@export var player_stat_levels: Dictionary = {}  # stat_key: String -> livello: int
@export var owned_catalysts: Array[CatalystResource] = []
@export var owned_summons: Array[SummonResource] = []

@export var gold: int = 0
@export var upgrade_levels: Dictionary = {}  # Resource -> int

@export var difficulty_mode: int = 1

@export var inventory: Array[InventoryItemResource] = []
@export var inventory_slot_upgrade_level: int = 0

@export var equipped_passive_item: InventoryItemResource = null
@export var equipped_shield_item: InventoryItemResource = null

@export var fragments: int = 0
@export var completed_levels: Array[int] = []  # per il drop one-time 1-4/6-9

@export var droppable_passive_items: Array[PassiveItemResource] = []
@export var droppable_shield_items: Array[ShieldResource] = []

@export var shop_rotation: Array[InventoryItemResource] = []
