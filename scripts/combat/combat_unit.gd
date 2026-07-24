extends CharacterBody2D
class_name CombatUnit

enum UnitState { MOVING, ATTACKING }
enum Category { TANK, MELEE, RANGED, SUPPORT, ASSASSIN, HEALER, SUMMONER }

var move_direction: float = -1.0
var target_group: String = "player"
var category: Category = Category.MELEE

@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_area: Area2D = $AttackArea
@onready var health_bar: HealthBar = $HealthBar

var _state: UnitState = UnitState.MOVING
var _attack_timer: float = 0.0
var _target: Node2D = null
var _bodies_in_range: Array[Node2D] = []
var _target_priority: Array[CombatUnit.Category] = []

var _move_speed: float = 0.0
var _attack_damage: int = 0
var _attack_cooldown: float = 0.0
var _attack_projectile_scene: PackedScene = null
var _attack_range: float = 40.0  # nuova, accanto alle altre _attack_* esistenti


func _ready() -> void:
	health_component.died.connect(_on_died)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	health_bar.setup(health_component)
	

func setup(max_health: int, move_speed: float, attack_damage: int, attack_cooldown: float, attack_range: float, unit_category: Category, projectile_scene: PackedScene = null, target_priority: Array[CombatUnit.Category] = []) -> void:
	health_component.max_health = max_health
	health_component.current_health = max_health
	_move_speed = move_speed
	_attack_damage = attack_damage
	_attack_cooldown = attack_cooldown
	_attack_projectile_scene = projectile_scene
	_attack_range = attack_range
	category = unit_category
	_target_priority = target_priority
	_apply_attack_range(attack_range)


func _apply_attack_range(range_value: float) -> void:
	var collision_shape: CollisionShape2D = attack_area.get_node("CollisionShape2D")
	var shape: CircleShape2D = collision_shape.shape.duplicate()
	shape.radius = range_value
	collision_shape.shape = shape


func _physics_process(delta: float) -> void:
	match _state:
		UnitState.MOVING:
			velocity.x = move_direction * _move_speed
			velocity.y = 0.0
			move_and_slide()
		UnitState.ATTACKING:
			velocity = Vector2.ZERO
			_process_attack(delta)


func _process_attack(delta: float) -> void:
	_bodies_in_range = attack_area.get_overlapping_bodies().filter(
		func(b): return b.is_in_group(target_group)
	)
	if _bodies_in_range.is_empty():
		_target = null
		_state = UnitState.MOVING
		return
	if _target == null or not is_instance_valid(_target) or not _bodies_in_range.has(_target):
		_choose_target()
	_attack_timer -= delta
	if _attack_timer <= 0.0:
		_perform_attack()
		_attack_timer = _attack_cooldown


func _perform_attack() -> void:
	if _attack_projectile_scene != null:
		_fire_projectile()
	elif _target.has_method("apply_damage"):
		_target.apply_damage(_attack_damage)


func _fire_projectile() -> void:
	var projectile: Projectile = _attack_projectile_scene.instantiate()
	projectile.damage = _attack_damage
	projectile.max_range = _attack_range
	projectile.global_position = global_position
	projectile.collision_layer = 0
	projectile.collision_mask = _get_target_physics_mask()
	get_tree().current_scene.add_child(projectile)
	projectile.set_direction(move_direction)


func _get_target_physics_mask() -> int:
	match target_group:
		"enemies":
			return 4
		"player_side":
			return 9
		_:
			return 0


func apply_damage(amount: int) -> void:
	health_component.take_damage(amount)


func _on_attack_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group(target_group):
		return
	_bodies_in_range.append(body)
	_choose_target()
	_state = UnitState.ATTACKING
	

func _on_attack_area_body_exited(body: Node2D) -> void:
	_bodies_in_range.erase(body)
	if body == _target:
		_target = null
		if _bodies_in_range.is_empty():
			_state = UnitState.MOVING
		else:
			_choose_target()
			_attack_timer = 0.00


func _choose_target() -> void:
	if _target_priority.is_empty() or _bodies_in_range.size() <= 1:
		if _target == null and not _bodies_in_range.is_empty():
			_target = _bodies_in_range[0]
			_attack_timer = 0.0
		return

	var best_body: Node2D = null
	var best_rank: int = _target_priority.size()

	for body in _bodies_in_range:
		var rank: int = _get_priority_rank(body)
		if rank < best_rank:
			best_rank = rank
			best_body = body

	if best_body != null and best_body != _target:
		_target = best_body
		_attack_timer = 0.0
	elif _target == null and not _bodies_in_range.is_empty():
		_target = _bodies_in_range[0]
		_attack_timer = 0.0


func _get_priority_rank(body: Node2D) -> int:
	if body is CombatUnit:
		var index: int = _target_priority.find(body.category)
		return index if index != -1 else _target_priority.size()
	return -1


func _on_died() -> void:
	queue_free()
