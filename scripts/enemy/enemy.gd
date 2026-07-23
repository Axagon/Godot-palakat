extends CombatUnit
class_name Enemy

@export var enemy_resource: EnemyResource

func _ready() -> void:
	move_direction = -1.0
	target_group = "player_side"
	add_to_group("enemies")
	super._ready()
	setup(
		enemy_resource.max_health, 
		enemy_resource.move_speed,
		enemy_resource.attack_damage, 
		enemy_resource.attack_cooldown, 
		enemy_resource.attack_range, 
		enemy_resource.category, 
		enemy_resource.attack_projectile_scene, 
		enemy_resource.target_priority)
