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
	var final_stats: Dictionary = _compute_final_stats()
	setup(
		final_stats.max_health,
		final_stats.move_speed,
		final_stats.attack_damage,
		summon_resource.attack_cooldown,
		summon_resource.attack_range,
		summon_resource.category,
		summon_resource.attack_projectile_scene,
		summon_resource.target_priority,
		summon_resource.element,
		true)


# Applica i moltiplicatori di potenziamento (HP/danno/velocita') acquistati
# per questa specifica risorsa evocazione posseduta. Nessuna modifica a
# range/cooldown, stesso principio gia' applicato al Rango nemici.
func _compute_final_stats() -> Dictionary:
	var level: int = GameState.get_upgrade_level(summon_resource)
	# invariato da qui in poi — get_health_multiplier() ecc. restano sulla
	# sottoclasse specifica, non sulla base
	var curve: SummonUpgradeCurveResource = summon_resource.upgrade_curve
	var hp_mult: float = 1.0
	var damage_mult: float = 1.0
	var speed_mult: float = 1.0
	if curve != null:
		hp_mult = curve.get_health_multiplier(level)
		damage_mult = curve.get_damage_multiplier(level)
		speed_mult = curve.get_speed_multiplier(level)
	return {
		"max_health": int(round(summon_resource.max_health * hp_mult)),
		"move_speed": summon_resource.move_speed * speed_mult,
		"attack_damage": int(round(summon_resource.attack_damage * damage_mult)),
	}


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
		
