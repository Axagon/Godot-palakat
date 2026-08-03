extends Summon
class_name Support

var _support_resource: SupportResource
var _buff_timer: float = 0.0


func _ready() -> void:
	super._ready()
	_support_resource = summon_resource as SupportResource
	if _support_resource == null:
		push_warning("Support: summon_resource assegnata non e' una SupportResource")
		return
	_buff_timer = _support_resource.buff_interval


func _process(delta: float) -> void:
	super._process(delta)
	if _support_resource == null:
		return
	_update_buff_pulse(delta)


func _update_buff_pulse(delta: float) -> void:
	_buff_timer -= delta
	if _buff_timer <= 0.0:
		_perform_buff_pulse()
		_buff_timer = _support_resource.buff_interval


func _perform_buff_pulse() -> void:
	for body in get_tree().get_nodes_in_group("player_side"):
		if not is_instance_valid(body):
			continue
		if global_position.distance_to(body.global_position) <= _support_resource.buff_radius:
			if body.has_method("apply_damage_buff"):
				body.apply_damage_buff(_support_resource.buff_multiplier, _support_resource.buff_duration)
