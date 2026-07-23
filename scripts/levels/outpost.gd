extends StaticBody2D
class_name Outpost

# Struttura nemica di fine livello. Blocca fisicamente Player e Summon,
# puo' essere danneggiata da magie (Projectile) e attacchi delle evocazioni
# (riusa il sistema di combattimento esistente tramite il gruppo "enemies").

signal destroyed

@export var max_health: int = 100

@onready var health_component: HealthComponent = $HealthComponent


func _ready() -> void:
	add_to_group("enemies")
	add_to_group("outpost")
	health_component.max_health = max_health
	health_component.current_health = max_health
	health_component.died.connect(_on_died)


func apply_damage(amount: int) -> void:
	health_component.take_damage(amount)


func _on_died() -> void:
	destroyed.emit()
	queue_free()
