extends Node2D
class_name EnemySpawner

@export var enemy_scene: PackedScene
@export var enemy_resource: EnemyResource
@export var spawn_interval: float = 3.0

var _timer: float = 0.0


func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_spawn_enemy()
		_timer = spawn_interval


func _spawn_enemy() -> void:
	Enemy.spawn_or_reuse(enemy_scene, enemy_resource, global_position, get_tree().current_scene)
