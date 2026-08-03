extends Summon
class_name Summoner

# Comportamento periodico del Summoner, indipendente dallo stato
# MOVING/ATTACKING ereditato da CombatUnit tramite Summon. Il Totem continua
# a muoversi/attaccare a contatto come un Summon normale; questo timer
# aggiunge solo l'evocazione ciclica di rinforzi.

var _summoner_resource: SummonerResource
var _reinforcement_timer: float = 0.0
var _active_reinforcements: Array[Node] = []


func _ready() -> void:
	super._ready()
	_summoner_resource = summon_resource as SummonerResource
	if _summoner_resource == null:
		push_warning("Summoner: summon_resource assegnata non e' una SummonerResource")
		return
	_reinforcement_timer = _summoner_resource.reinforcement_interval


func _process(delta: float) -> void:
	super._process(delta)
	if _summoner_resource == null:
		return
	_update_reinforcements(delta)


func _update_reinforcements(delta: float) -> void:
	if _summoner_resource.reinforcement_scene == null or _summoner_resource.reinforcement_summon_resource == null:
		return
	_prune_dead_reinforcements()
	if _active_reinforcements.size() >= _summoner_resource.max_concurrent_reinforcements:
		return
	_reinforcement_timer -= delta
	if _reinforcement_timer <= 0.0:
		_spawn_reinforcement()
		_reinforcement_timer = _summoner_resource.reinforcement_interval


func _prune_dead_reinforcements() -> void:
	_active_reinforcements = _active_reinforcements.filter(func(r): return is_instance_valid(r))


func _spawn_reinforcement() -> void:
	var reinforcement: Summon = _summoner_resource.reinforcement_scene.instantiate()
	reinforcement.summon_resource = _summoner_resource.reinforcement_summon_resource
	reinforcement.counts_toward_summon_cap = false
	reinforcement.global_position = global_position
	get_tree().current_scene.add_child(reinforcement)
	_active_reinforcements.append(reinforcement)
	
