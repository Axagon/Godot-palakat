extends Summon
class_name Healer

var _healer_resource: HealerResource
var _heal_timer: float = 0.0


func _ready() -> void:
	super._ready()
	_healer_resource = summon_resource as HealerResource
	if _healer_resource == null:
		push_warning("Healer: summon_resource assegnata non e' una HealerResource")
		return
	_heal_timer = _healer_resource.heal_interval


func _process(delta: float) -> void:
	super._process(delta)
	if _healer_resource == null:
		return
	_update_healing(delta)


func _update_healing(delta: float) -> void:
	_heal_timer -= delta
	if _heal_timer <= 0.0:
		_perform_heal_pulse()
		_heal_timer = _healer_resource.heal_interval


func _perform_heal_pulse() -> void:
	for body in get_tree().get_nodes_in_group("player_side"):
		if not is_instance_valid(body):
			continue
		if body.is_in_group("player"):
			continue
		if global_position.distance_to(body.global_position) <= _healer_resource.heal_radius:
			if body.has_method("apply_heal"):
				body.apply_heal(_healer_resource.heal_amount)
				
