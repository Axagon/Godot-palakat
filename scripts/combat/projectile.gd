extends Area2D
class_name Projectile

@export var speed: float = 500.0
@export var damage: int = 0
@export var max_range: float = 400.0

var source_scene: PackedScene = null
var applies_burn: bool = false
var burn_damage: int = 0
var burn_duration: float = 0.0

var _direction: Vector2 = Vector2.RIGHT
var _distance_traveled: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func reset_state() -> void:
	_distance_traveled = 0.0
	visible = true
	set_deferred("monitoring", true)


func set_direction(facing: float) -> void:
	_direction = Vector2.RIGHT * facing
	scale.x = facing


func _physics_process(delta: float) -> void:
	var movement: Vector2 = _direction * speed * delta
	position += movement
	_distance_traveled += movement.length()
	if _distance_traveled >= max_range:
		_return_to_pool()


func _on_body_entered(body: Node2D) -> void:
	if applies_burn and body.has_method("apply_elemental_damage"):
		body.apply_elemental_damage(damage, SpellResource.Element.FIRE)
	elif body.has_method("apply_damage"):
		body.apply_damage(damage)
	if applies_burn and burn_damage > 0 and body.has_method("apply_burn"):
		body.apply_burn(burn_damage, burn_duration, SpellResource.Element.FIRE)
	_return_to_pool()


func _return_to_pool() -> void:
	visible = false
	set_deferred("monitoring", false)
	ObjectPool.return_instance(source_scene, self)
