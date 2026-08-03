extends Resource
class_name EnemyResource

@export var enemy_name: String = ""
@export var tint_color: Color = Color(1, 1, 1, 1)
@export var sprite_frames: SpriteFrames = null
@export var invert_sprite_flip: bool = false
@export var category: CombatUnit.Category = CombatUnit.Category.MELEE

@export var attack_projectile_scene: PackedScene = null
@export var target_priority: Array[CombatUnit.Category] = []

@export var max_health: int = 10
@export var move_speed: float = 80.0

@export var attack_damage: int = 1
@export var attack_range: float = 40.0
@export var attack_cooldown: float = 1.0
