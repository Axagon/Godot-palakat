extends Node2D
class_name LevelManager

signal level_completed
signal wave_started(wave_index: int)

@export var level: LevelResource
@export var enemy_scene: PackedScene

var _elapsed_time: float = 0.0
var _wave_started_flags: Array[bool] = []
var _wave_spawned_counts: Array[int] = []
var _wave_timers: Array[float] = []


func _ready() -> void:
	add_to_group("level_manager")
	if GameState.selected_level != null:
		level = GameState.selected_level
	if level == null:
		return
	var wave_count: int = level.waves.size()
	_wave_started_flags.resize(wave_count)
	_wave_started_flags.fill(false)
	_wave_spawned_counts.resize(wave_count)
	_wave_spawned_counts.fill(0)
	_wave_timers.resize(wave_count)
	_wave_timers.fill(0.0)

	await get_tree().process_frame
	var outpost: Node = get_tree().get_first_node_in_group("outpost")
	if outpost != null:
		outpost.destroyed.connect(_on_outpost_destroyed)


func _process(delta: float) -> void:
	if level == null:
		return
	_elapsed_time += delta
	for i in range(level.waves.size()):
		_update_wave(i, delta)


func _update_wave(index: int, delta: float) -> void:
	var wave: WaveResource = level.waves[index]
	if _wave_spawned_counts[index] >= wave.enemy_count:
		return
	if _elapsed_time < wave.start_time:
		return

	if not _wave_started_flags[index]:
		_wave_started_flags[index] = true
		wave_started.emit(index)
		_spawn_wave_enemy(index, wave)
		return

	_wave_timers[index] -= delta
	if _wave_timers[index] <= 0.0:
		_spawn_wave_enemy(index, wave)


func _spawn_wave_enemy(index: int, wave: WaveResource) -> void:
	_wave_spawned_counts[index] += 1
	_wave_timers[index] = wave.spawn_interval
	var enemy_resource: EnemyResource = _pick_from_pool(wave)
	var scene_to_use: PackedScene = wave.enemy_scene_override if wave.enemy_scene_override != null else enemy_scene
	_spawn_enemy(enemy_resource, scene_to_use)


func _pick_from_pool(wave: WaveResource) -> EnemyResource:
	if wave.enemy_pool.is_empty():
		push_warning("WaveResource senza enemy_pool: nessun nemico generato")
		return null
	return wave.enemy_pool[randi() % wave.enemy_pool.size()]


func _spawn_enemy(enemy_resource: EnemyResource, scene: PackedScene) -> void:
	if enemy_resource == null or scene == null:
		return
	var enemy: Enemy = scene.instantiate()
	enemy.enemy_resource = enemy_resource
	enemy.global_position = global_position
	get_tree().current_scene.add_child(enemy)


func _on_outpost_destroyed() -> void:
	if level != null:
		GameState.on_level_completed(level.level_number)
	level_completed.emit()
