extends Area2D
class_name LeakZone

# Nemici non uccisi che superano il bordo sinistro vengono rimossi qui:
# tolgono 1 cuore fisso al player e contano ai fini della barra di
# progresso senza generare oro (vedi Enemy.leak()/RunStats.record_leak()).

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.leak()
