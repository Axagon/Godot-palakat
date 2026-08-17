extends Enemy
class_name Boss

# Comportamenti periodici del Mini Boss, indipendenti dallo stato
# MOVING/ATTACKING ereditato da CombatUnit tramite Enemy. Il boss continua
# a muoversi/attaccare a contatto come un Enemy normale; questi timer
# aggiungono solo le due meccaniche extra concordate.

var _boss_resource: BossResource
var _aoe_timer: float = 0.0
var _reinforcement_timer: float = 0.0


func _ready() -> void:
	super._ready()
	_boss_resource = enemy_resource as BossResource
	if _boss_resource == null:
		push_warning("Boss: enemy_resource assegnata non e' una BossResource")
		return
	_aoe_timer = _boss_resource.aoe_interval
	_reinforcement_timer = _boss_resource.reinforcement_interval


func _process(delta: float) -> void:
	super._process(delta)
	if _boss_resource == null:
		return
	_update_aoe(delta)
	_update_reinforcements(delta)


func _update_aoe(delta: float) -> void:
	_aoe_timer -= delta
	if _aoe_timer <= 0.0:
		_perform_aoe_attack()
		_aoe_timer = _boss_resource.aoe_interval


func _perform_aoe_attack() -> void:
	for body in get_tree().get_nodes_in_group("player_side"):
		if not is_instance_valid(body):
			continue
		if global_position.distance_to(body.global_position) <= _boss_resource.aoe_radius:
			if body.has_method("apply_damage"):
				body.apply_damage(_boss_resource.aoe_damage)


func _update_reinforcements(delta: float) -> void:
	if _boss_resource.reinforcement_scene == null or _boss_resource.reinforcement_enemy_resource == null:
		return
	_reinforcement_timer -= delta
	if _reinforcement_timer <= 0.0:
		_spawn_reinforcement()
		_reinforcement_timer = _boss_resource.reinforcement_interval


func _spawn_reinforcement() -> void:
	Enemy.spawn_or_reuse(_boss_resource.reinforcement_scene, _boss_resource.reinforcement_enemy_resource, global_position, get_tree().current_scene)


func reuse_with_resource(new_resource: EnemyResource) -> void:
	super.reuse_with_resource(new_resource)
	_boss_resource = enemy_resource as BossResource
	if _boss_resource == null:
		push_warning("Boss: enemy_resource assegnata non e' una BossResource")
		return
	_aoe_timer = _boss_resource.aoe_interval
	_reinforcement_timer = _boss_resource.reinforcement_interval

# Override: un Boss che raggiunge la LeakZone non e' un leak recuperabile
# come i nemici comuni, ma fallimento diretto del livello (il completamento
# richiede sempre la sconfitta del boss, mai il suo aggiramento).
func leak() -> void:
	var level_manager: LevelManager = get_tree().get_first_node_in_group("level_manager")
	if level_manager != null:
		level_manager.fail_level()
	set_physics_process(false)
	attack_area.set_deferred("monitoring", false)
	_finish_death()
