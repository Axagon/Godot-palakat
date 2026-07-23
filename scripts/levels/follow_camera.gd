extends Camera2D
class_name FollowCamera

# Segue il player sull'asse orizzontale. Vive nella scena del livello (non nel
# player) cosi' i limiti di camera possono essere configurati per ogni livello.

@export var follow_group: String = "player"

var _target: Node2D = null


func _process(_delta: float) -> void:
	if _target == null:
		_target = get_tree().get_first_node_in_group(follow_group)
		return
	global_position = _target.global_position
