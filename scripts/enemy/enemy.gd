extends CombatUnit
class_name Enemy

@export var enemy_resource: EnemyResource

var _source_scene: PackedScene = null
var _initialized: bool = false


func _ready() -> void:
	move_direction = -1.0
	target_group = "player_side"
	add_to_group("enemies")
	super._ready()
	_apply_enemy_resource()
	_initialized = true


func _apply_enemy_resource() -> void:
	setup(
		enemy_resource.max_health, 
		enemy_resource.move_speed,
		enemy_resource.attack_damage, 
		enemy_resource.attack_cooldown, 
		enemy_resource.attack_range, 
		enemy_resource.category, 
		enemy_resource.attack_projectile_scene, 
		enemy_resource.target_priority)
	modulate = enemy_resource.tint_color
	if animated_sprite != null and enemy_resource.sprite_frames != null:
		animated_sprite.sprite_frames = enemy_resource.sprite_frames
		animated_sprite.play("idle")
	if animated_sprite != null and enemy_resource.invert_sprite_flip:
		animated_sprite.flip_h = not animated_sprite.flip_h


func reuse_with_resource(new_resource: EnemyResource) -> void:
	enemy_resource = new_resource
	reset_for_reuse()
	_apply_enemy_resource()


func _finish_death() -> void:
	if _source_scene != null:
		ObjectPool.return_instance(_source_scene, self)
	else:
		queue_free()


static func spawn_or_reuse(scene: PackedScene, resource: EnemyResource, spawn_position: Vector2, parent: Node) -> Enemy:
	var enemy: Enemy = ObjectPool.get_instance(scene) as Enemy
	enemy._source_scene = scene
	if enemy._initialized:
		enemy.reuse_with_resource(resource)
	else:
		enemy.enemy_resource = resource
	enemy.global_position = spawn_position
	parent.add_child(enemy)
	return enemy
