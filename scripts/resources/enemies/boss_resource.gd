extends EnemyResource
class_name BossResource

# Attacco AoE periodico: danno a tutte le unita' player_side entro il raggio,
# indipendentemente dallo stato MOVING/ATTACKING ereditato da CombatUnit.
@export var aoe_damage: int = 8
@export var aoe_radius: float = 160.0
@export var aoe_interval: float = 5.0

# Evocazione ciclica di rinforzi minori finche' il boss e' vivo.
# Riusa una EnemyResource gia' esistente (es. test_skeleton) per non
# introdurre nuovo contenuto solo per questo scopo.
@export var reinforcement_scene: PackedScene
@export var reinforcement_enemy_resource: EnemyResource
@export var reinforcement_interval: float = 8.0
