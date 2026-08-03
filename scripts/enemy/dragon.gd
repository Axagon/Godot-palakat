extends Boss
class_name Dragon

signal wipe_warning_started(seconds_remaining: float)
signal wipe_executed

var _dragon_resource: DragonBossResource
var _wipe_timer: float = 0.0
var _warning_active: bool = false


func _ready() -> void:
	super._ready()
	_dragon_resource = enemy_resource as DragonBossResource
	if _dragon_resource == null:
		push_warning("Dragon: enemy_resource assegnata non e' una DragonBossResource")
		return
	_wipe_timer = _dragon_resource.summon_wipe_interval


func _process(delta: float) -> void:
	super._process(delta)
	if _dragon_resource == null:
		return
	_update_summon_wipe(delta)


func _update_summon_wipe(delta: float) -> void:
	_wipe_timer -= delta
	if not _warning_active and _wipe_timer <= _dragon_resource.summon_wipe_warning_time:
		_warning_active = true
		modulate = Color(1.6, 0.5, 0.5)
		wipe_warning_started.emit(_dragon_resource.summon_wipe_warning_time)
	if _wipe_timer <= 0.0:
		_perform_summon_wipe()
		_wipe_timer = _dragon_resource.summon_wipe_interval
		_warning_active = false


func _perform_summon_wipe() -> void:
	modulate = Color(1, 1, 1)
	for summon in get_tree().get_nodes_in_group("player_summons"):
		if not is_instance_valid(summon) or not summon.health_component.is_alive():
			continue
		if global_position.distance_to(summon.global_position) > _dragon_resource.summon_wipe_radius:
			continue
		var damage_amount: int = int(round(summon.health_component.max_health * _dragon_resource.summon_wipe_damage_percent))
		summon.apply_damage(damage_amount)
	wipe_executed.emit()


func reuse_with_resource(new_resource: EnemyResource) -> void:
	super.reuse_with_resource(new_resource)
	_dragon_resource = enemy_resource as DragonBossResource
	if _dragon_resource == null:
		push_warning("Dragon: enemy_resource assegnata non e' una DragonBossResource")
		return
	_wipe_timer = _dragon_resource.summon_wipe_interval
	_warning_active = false
	modulate = Color(1, 1, 1)
