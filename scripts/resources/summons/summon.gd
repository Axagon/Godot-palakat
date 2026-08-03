extends CombatUnit
class_name Summon

@export var summon_resource: SummonResource

var counts_toward_summon_cap: bool = true
var _regen_accumulator: float = 0.0


func _ready() -> void:
	move_direction = 1.0
	target_group = "enemies"
	add_to_group("player_side")
	add_to_group("player_summons")
	if counts_toward_summon_cap:
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
		summon_resource.target_priority,
		summon_resource.element,
		true)


func _process(delta: float) -> void:
	super._process(delta)
	_update_nature_regen(delta)


func _update_nature_regen(delta: float) -> void:
	if summon_resource == null or summon_resource.element != SpellResource.Element.NATURE:
		return
	if summon_resource.regen_per_second <= 0.0:
		return
	if health_component.current_health >= health_component.max_health:
		_regen_accumulator = 0.0
		return
	_regen_accumulator += summon_resource.regen_per_second * delta
	if _regen_accumulator >= 1.0:
		var whole: int = int(_regen_accumulator)
		_regen_accumulator -= whole
		health_component.heal(whole)
