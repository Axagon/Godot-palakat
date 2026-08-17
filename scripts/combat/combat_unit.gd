extends CharacterBody2D
class_name CombatUnit

enum UnitState { MOVING, ATTACKING }
enum Category { TANK, MELEE, RANGED, SUPPORT, ASSASSIN, HEALER, SUMMONER }

const FIRE_BURN_DAMAGE_PERCENT: float = 0.30
const FIRE_BURN_DURATION: float = 3.0

var move_direction: float = -1.0
var target_group: String = "player"
var category: Category = Category.MELEE

@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_area: Area2D = $AttackArea
@onready var health_bar: HealthBar = $HealthBar
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

var _state: UnitState = UnitState.MOVING
var _attack_timer: float = 0.0
var _target: Node2D = null
var _bodies_in_range: Array[Node2D] = []
var _target_priority: Array[CombatUnit.Category] = []

var _move_speed: float = 0.0
var _attack_damage: int = 0
var _attack_cooldown: float = 0.0
var _attack_projectile_scene: PackedScene = null
var _attack_range: float = 40.0

var damage_buff_multiplier: float = 1.0
var _damage_buff_timer: float = 0.0

var _fire_resistance_percent: float = 0.0
var _element: SpellResource.Element = SpellResource.Element.FIRE
var _applies_elemental_effects: bool = false

var _last_known_health: int = -1

var _base_sprite_scale: Vector2 = Vector2.ONE
var _hurt_animation_active: bool = false

const ANIMATION_SCALE_CORRECTIONS: Dictionary = {
	"idle": 1.2,
	"walk": 1.2,
	"attack": 1.2,
	"hurt": 1.2,
	"dead": 1.2,
}

const FLYING_CAPABLE_CATEGORIES: Array[Category] = [Category.RANGED, Category.SUPPORT]


func _ready() -> void:
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_on_health_component_changed)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	health_bar.setup(health_component)
	if animated_sprite != null:
		animated_sprite.animation_finished.connect(_on_animation_finished)
		_base_sprite_scale = animated_sprite.scale
		

func _process(delta: float) -> void:
	if _damage_buff_timer > 0.0:
		_damage_buff_timer -= delta
		if _damage_buff_timer <= 0.0:
			damage_buff_multiplier = 1.0


func setup(max_health: int, move_speed: float, attack_damage: int, attack_cooldown: float, attack_range: float, unit_category: Category, projectile_scene: PackedScene = null, target_priority: Array[CombatUnit.Category] = [], unit_element: SpellResource.Element = SpellResource.Element.FIRE, applies_elemental_effects: bool = false) -> void:
	health_component.max_health = max_health
	health_component.current_health = max_health
	_last_known_health = max_health
	_move_speed = move_speed
	_attack_damage = attack_damage
	_attack_cooldown = attack_cooldown
	_attack_projectile_scene = projectile_scene
	_attack_range = attack_range
	category = unit_category
	_target_priority = target_priority
	_element = unit_element
	_applies_elemental_effects = applies_elemental_effects
	_apply_attack_range(attack_range)
	if animated_sprite != null:
		animated_sprite.flip_h = move_direction < 0


func reset_for_reuse() -> void:
	_state = UnitState.MOVING
	_target = null
	_bodies_in_range.clear()
	_attack_timer = 0.0
	damage_buff_multiplier = 1.0
	_damage_buff_timer = 0.0
	health_component.current_health = health_component.max_health
	health_component.clear_burn()
	_last_known_health = health_component.max_health
	health_component.health_changed.emit(health_component.current_health, health_component.max_health)
	health_bar.visible = false
	visible = true
	set_physics_process(true)
	attack_area.set_deferred("monitoring", true)
	if animated_sprite != null:
		animated_sprite.modulate.a = 1.0
		_play_animation("idle")


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
			if not _hurt_animation_active:
				_play_animation("walk")
		UnitState.ATTACKING:
			velocity = Vector2.ZERO
			_process_attack(delta)


func _can_target(body: Node2D) -> bool:
	if not body.is_in_group(target_group):
		return false
	if body is Enemy and body.enemy_resource != null and body.enemy_resource.is_flying:
		return category in FLYING_CAPABLE_CATEGORIES
	return true


func _process_attack(delta: float) -> void:
	_bodies_in_range = attack_area.get_overlapping_bodies().filter(_can_target)
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
	if not _hurt_animation_active:
		_play_attack_animation()
	if _attack_projectile_scene != null:
		_fire_projectile()
	elif _target.has_method("apply_damage"):
		var final_damage: int = int(round(_attack_damage * damage_buff_multiplier))
		if _applies_elemental_effects and _target.has_method("apply_elemental_damage"):
			_target.apply_elemental_damage(final_damage, _element)
		else:
			_target.apply_damage(final_damage)
		_try_apply_burn(_target, final_damage)


func _try_apply_burn(target: Node, base_damage: int) -> void:
	if not _applies_elemental_effects or _element != SpellResource.Element.FIRE:
		return
	if target.has_method("apply_burn"):
		var burn_total: int = int(round(base_damage * FIRE_BURN_DAMAGE_PERCENT))
		if burn_total > 0:
			target.apply_burn(burn_total, FIRE_BURN_DURATION)


func _fire_projectile() -> void:
	var projectile: Projectile = ObjectPool.get_instance(_attack_projectile_scene)
	projectile.source_scene = _attack_projectile_scene
	projectile.reset_state()
	var final_damage: int = int(round(_attack_damage * damage_buff_multiplier))
	projectile.damage = final_damage
	projectile.max_range = _attack_range
	projectile.applies_burn = _applies_elemental_effects and _element == SpellResource.Element.FIRE
	projectile.burn_damage = int(round(final_damage * FIRE_BURN_DAMAGE_PERCENT)) if projectile.applies_burn else 0
	projectile.burn_duration = FIRE_BURN_DURATION
	projectile.global_position = global_position
	projectile.collision_layer = 0
	projectile.collision_mask = _get_target_physics_mask()
	if projectile.get_parent() == null:
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


func apply_heal(amount: int) -> void:
	health_component.heal(amount)


func apply_elemental_damage(amount: int, source_element: SpellResource.Element) -> void:
	var final_amount: int = _apply_fire_resistance(amount, source_element)
	health_component.take_damage(final_amount)


func apply_burn(total_damage: int, duration: float, source_element: SpellResource.Element = SpellResource.Element.FIRE) -> void:
	var final_damage: int = _apply_fire_resistance(total_damage, source_element)
	health_component.apply_burn(final_damage, duration)


func set_fire_resistance(percent: float) -> void:
	_fire_resistance_percent = percent


func _apply_fire_resistance(amount: int, source_element: SpellResource.Element) -> int:
	if source_element != SpellResource.Element.FIRE or _fire_resistance_percent <= 0.0:
		return amount
	return int(round(amount * (1.0 - _fire_resistance_percent)))
		

func apply_damage_buff(multiplier: float, duration: float) -> void:
	damage_buff_multiplier = multiplier
	_damage_buff_timer = duration


func _on_attack_area_body_entered(body: Node2D) -> void:
	if not _can_target(body):
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


func _on_health_component_changed(current_health: int, _max_health: int) -> void:
	if _last_known_health != -1 and current_health < _last_known_health and current_health > 0:
		_trigger_hurt_animation()
	_last_known_health = current_health


func _trigger_hurt_animation() -> void:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return
	if not animated_sprite.sprite_frames.has_animation("hurt"):
		return
	_hurt_animation_active = true
	animated_sprite.play("hurt")
	_apply_animation_scale("hurt")


func _on_died() -> void:
	set_physics_process(false)
	attack_area.set_deferred("monitoring", false)
	if animated_sprite != null and animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation("dead"):
		_play_animation("dead")
	else:
		_finish_death()


func _on_animation_finished() -> void:
	if animated_sprite.animation == "hurt":
		_hurt_animation_active = false
		_play_animation("attack" if _state == UnitState.ATTACKING else "walk")
	elif animated_sprite.animation == "dead":
		_finish_death()


func _finish_death() -> void:
	queue_free()


func _play_animation(anim_name: String) -> void:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return
	if not animated_sprite.sprite_frames.has_animation(anim_name):
		return
	if animated_sprite.animation != anim_name or not animated_sprite.is_playing():
		animated_sprite.play(anim_name)
	_apply_animation_scale(anim_name)


func _play_attack_animation() -> void:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return
	if animated_sprite.sprite_frames.has_animation("attack"):
		animated_sprite.play("attack")
		_apply_animation_scale("attack")


func _apply_animation_scale(anim_name: String) -> void:
	if animated_sprite == null:
		return
	var correction: float = ANIMATION_SCALE_CORRECTIONS.get(anim_name, 1.0)
	animated_sprite.scale = _base_sprite_scale * correction
