extends CombatUnit
class_name Summon

@export var summon_resource: SummonResource


func _ready() -> void:
	move_direction = 1.0
	target_group = "enemies"
	add_to_group("player_side")
	add_to_group("active_summons")
	super._ready()
	setup(
		summon_resource.max_health,
		summon_resource.move_speed,
		summon_resource.attack_damage,
		summon_resource.attack_cooldown,
		summon_resource.attack_range,
		summon_resource.category,
		summon_resource.attack_projectile_scene,
		summon_resource.target_priority)
