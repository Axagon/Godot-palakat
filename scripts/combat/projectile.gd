# projectile.gd
extends Area2D
class_name Projectile

@export var speed: float = 500.0
@export var damage: int = 0
@export var max_range: float = 400.0

var _direction: Vector2 = Vector2.RIGHT
var _distance_traveled: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func set_direction(facing: float) -> void:
	_direction = Vector2.RIGHT * facing
	scale.x = facing


func _physics_process(delta: float) -> void:
	var movement: Vector2 = _direction * speed * delta
	position += movement
	_distance_traveled += movement.length()
	if _distance_traveled >= max_range:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("apply_damage"):
		body.apply_damage(damage)
	queue_free()
