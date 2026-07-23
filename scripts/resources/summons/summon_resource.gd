extends Resource
class_name SummonResource

# Definizione dati di un'evocazione. Nessuna logica qui, solo statistiche.

@export var summon_name: String = ""
@export var category: CombatUnit.Category = CombatUnit.Category.MELEE
@export var element: SpellResource.Element = SpellResource.Element.FIRE

@export var attack_projectile_scene: PackedScene = null
@export var target_priority: Array[CombatUnit.Category] = []

@export var food_cost: int = 15

@export var max_health: int = 20
@export var move_speed: float = 60.0

@export var attack_damage: int = 2
@export var attack_range: float = 40.0
@export var attack_cooldown: float = 1.0
