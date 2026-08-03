extends Node
class_name HealthComponent

signal health_changed(current_health: int, max_health: int)
signal died

@export var max_health: int = 3

var current_health: int

var _burn_dps: float = 0.0
var _burn_timer: float = 0.0
var _burn_accumulator: float = 0.0


func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func _process(delta: float) -> void:
	if _burn_timer <= 0.0 or current_health <= 0:
		return
	_burn_timer -= delta
	_burn_accumulator += _burn_dps * delta
	if _burn_accumulator >= 1.0:
		var whole: int = int(_burn_accumulator)
		_burn_accumulator -= whole
		take_damage(whole)


func take_damage(amount: int) -> void:
	if current_health <= 0:
		return
	current_health = max(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		died.emit()


func heal(amount: int) -> void:
	if current_health <= 0:
		return
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


func apply_burn(total_damage: int, duration: float) -> void:
	if duration <= 0.0:
		return
	_burn_dps = float(total_damage) / duration
	_burn_timer = duration


func clear_burn() -> void:
	_burn_timer = 0.0
	_burn_accumulator = 0.0


func is_alive() -> bool:
	return current_health > 0
