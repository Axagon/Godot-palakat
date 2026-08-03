extends Node
class_name ObjectPoolManager

var _pools: Dictionary = {}  # PackedScene -> Array[Node]


func get_instance(scene: PackedScene) -> Node:
	if not _pools.has(scene):
		_pools[scene] = []
	var pool: Array = _pools[scene]
	while not pool.is_empty():
		var candidate: Node = pool.pop_back()
		if is_instance_valid(candidate):
			return candidate
	return scene.instantiate()


func return_instance(scene: PackedScene, instance: Node) -> void:
	call_deferred("_do_return_instance", scene, instance)


func _do_return_instance(scene: PackedScene, instance: Node) -> void:
	if not _pools.has(scene):
		_pools[scene] = []
	if instance.get_parent() != null:
		instance.get_parent().remove_child(instance)
	_pools[scene].append(instance)
