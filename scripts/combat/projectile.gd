extends Area2D
class_name Projectile

# Proiettile generico per magie a distanza. Si muove in linea retta nella
# direzione impostata da set_direction() e infligge danno al primo bersaglio
# valido che colpisce, poi si distrugge.

@export var speed: float = 500.0
@export var damage: int = 0

var _direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func set_direction(facing: float) -> void:
	_direction = Vector2.RIGHT * facing
	scale.x = facing


func _physics_process(delta: float) -> void:
	position += _direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("apply_damage"):
		body.apply_damage(damage)
	queue_free()
