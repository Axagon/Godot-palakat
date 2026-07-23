extends Resource
class_name EnemyResource

# Definizione dati di un nemico. Nessuna logica qui, solo statistiche.

@export var enemy_name: String = ""
@export var category: CombatUnit.Category = CombatUnit.Category.MELEE

@export var attack_projectile_scene: PackedScene = null
@export var target_priority: Array[CombatUnit.Category] = []

@export var max_health: int = 10
@export var move_speed: float = 80.0

@export var attack_damage: int = 1
@export var attack_range: float = 40.0
@export var attack_cooldown: float = 1.0
