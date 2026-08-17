extends StaticBody2D
class_name Outpost

signal destroyed

@export var max_health: int = 100
@export var gold_reward: int = 30

@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: HealthBar = $HealthBar

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("outpost")
	health_component.max_health = max_health
	health_component.current_health = max_health
	health_component.died.connect(_on_died)
	health_bar.setup(health_component)


func apply_damage(amount: int) -> void:
	health_component.take_damage(amount)


func apply_burn(total_damage: int, duration: float, _source_element: SpellResource.Element = SpellResource.Element.FIRE) -> void:
	health_component.apply_burn(total_damage, duration)
	

func _on_died() -> void:
	var reward: int = GameState.apply_reward_multiplier(gold_reward)
	GameState.add_gold(reward)
	RunStats.record_outpost_destroyed(reward)
	destroyed.emit()
	queue_free()
