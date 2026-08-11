extends Enemy
class_name ExplodingEnemy

var _exploding_resource: ExplodingEnemyResource


func _apply_enemy_resource() -> void:
	super._apply_enemy_resource()
	_exploding_resource = enemy_resource as ExplodingEnemyResource
	if _exploding_resource == null:
		push_warning("ExplodingEnemy: enemy_resource assegnata non e' una ExplodingEnemyResource")


func _on_died() -> void:
	_perform_explosion()
	super._on_died()


func _perform_explosion() -> void:
	if _exploding_resource == null:
		return
	for body in get_tree().get_nodes_in_group("player_side"):
		if not is_instance_valid(body):
			continue
		if global_position.distance_to(body.global_position) <= _exploding_resource.explosion_radius:
			if body.has_method("apply_damage"):
				body.apply_damage(_exploding_resource.explosion_damage)
