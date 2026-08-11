extends CombatUnit
class_name Enemy

@export var enemy_resource: EnemyResource

var _source_scene: PackedScene = null
var _initialized: bool = false

var _rank: EnemyRankResource.Rank = EnemyRankResource.Rank.NORMAL
var _rank_config: EnemyRankResource = null

var _difficulty_config: DifficultyScalingResource = null
var _level_number: int = 1
var _world_number: int = 1


func _ready() -> void:
	move_direction = -1.0
	target_group = "player_side"
	add_to_group("enemies")
	super._ready()
	_apply_enemy_resource()
	_initialized = true


func _apply_enemy_resource() -> void:
	var final_stats: Dictionary = _compute_final_stats(enemy_resource)
	setup(
		final_stats.max_health,
		final_stats.move_speed,
		final_stats.attack_damage,
		enemy_resource.attack_cooldown,
		enemy_resource.attack_range,
		enemy_resource.category,
		enemy_resource.attack_projectile_scene,
		enemy_resource.target_priority,
		enemy_resource.element,
		enemy_resource.applies_elemental_effects)
	set_fire_resistance(enemy_resource.fire_resistance_percent)
	modulate = enemy_resource.tint_color * _get_rank_tint()
	if animated_sprite != null and enemy_resource.sprite_frames != null:
		animated_sprite.sprite_frames = enemy_resource.sprite_frames
		animated_sprite.play("idle")
	if animated_sprite != null and enemy_resource.invert_sprite_flip:
		animated_sprite.flip_h = not animated_sprite.flip_h
		

# Applica i moltiplicatori di rango (HP/danno/velocita') alle statistiche
# base della risorsa. Nessuna modifica a range/cooldown per design (vedi
# istruzioni di progetto: il rango non altera il pattern di attacco).
func _compute_final_stats(resource: EnemyResource) -> Dictionary:
	if resource is BossResource:
		return {
			"max_health": resource.max_health,
			"move_speed": resource.move_speed,
			"attack_damage": resource.attack_damage,
		}

	var hp_mult: float = 1.0
	var damage_mult: float = 1.0
	var speed_mult: float = 1.0
	if _rank_config != null:
		hp_mult *= _rank_config.get_hp_mult(_rank)
		damage_mult *= _rank_config.get_damage_mult(_rank)
		speed_mult *= _rank_config.get_speed_mult(_rank)
	if _difficulty_config != null:
		hp_mult *= _difficulty_config.get_hp_multiplier(_level_number, _world_number)
		damage_mult *= _difficulty_config.get_damage_multiplier(_level_number, _world_number)
	return {
		"max_health": int(round(resource.max_health * hp_mult)),
		"move_speed": resource.move_speed * speed_mult,
		"attack_damage": int(round(resource.attack_damage * damage_mult)),
	}


func _get_rank_tint() -> Color:
	if _rank_config == null:
		return Color(1, 1, 1, 1)
	return _rank_config.get_tint(_rank)


func set_difficulty_context(config: DifficultyScalingResource, level_number: int, world_number: int) -> void:
	_difficulty_config = config
	_level_number = level_number
	_world_number = world_number
	if _initialized:
		_apply_enemy_resource()


func reuse_with_resource(new_resource: EnemyResource) -> void:
	enemy_resource = new_resource
	reset_for_reuse()
	_apply_enemy_resource()


func _finish_death() -> void:
	if _source_scene != null:
		ObjectPool.return_instance(_source_scene, self)
	else:
		queue_free()


static func spawn_or_reuse(scene: PackedScene, resource: EnemyResource, spawn_position: Vector2, parent: Node, rank: EnemyRankResource.Rank = EnemyRankResource.Rank.NORMAL, rank_config: EnemyRankResource = null) -> Enemy:
	var enemy: Enemy = ObjectPool.get_instance(scene) as Enemy
	enemy._source_scene = scene
	enemy._rank = rank
	enemy._rank_config = rank_config
	if enemy._initialized:
		enemy.reuse_with_resource(resource)
	else:
		enemy.enemy_resource = resource
	enemy.global_position = spawn_position
	parent.add_child(enemy)
	return enemy


func _on_died() -> void:
	super._on_died()
	_award_gold()


func _award_gold() -> void:
	if enemy_resource == null:
		return
	var gold_mult: float = 1.0
	if _rank_config != null and not (enemy_resource is BossResource):
		gold_mult = _rank_config.get_gold_mult(_rank)
	var reward: int = int(round(enemy_resource.gold_reward * gold_mult))
	GameState.add_gold(reward)
	if enemy_resource is BossResource:
		RunStats.record_boss_kill(reward)
	else:
		RunStats.record_kill(_rank, reward)
	
