extends Control
class_name SummonHandUI

# Contenitore della mano di carte evocazione. Gestisce il drag: tenendo
# premuta una carta e rilasciandola fuori dall'area della mano, la evocazione
# viene giocata (SummonHandComponent.play_card).

@export var card_scene: PackedScene
@onready var slot_container: HBoxContainer = $HBoxContainer

var _summon_hand: SummonHandComponent
var _card_nodes: Array[SummonCardUI] = []

var _dragging_index: int = -1
var _dragging_touch_index: int = -1
var _drag_start_position: Vector2
var _drag_grab_offset: Vector2

func _ready() -> void:
	await get_tree().process_frame
	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	_summon_hand = player.summon_hand
	_build_card_slots()
	_summon_hand.hand_changed.connect(_on_hand_changed)
	_on_hand_changed(_summon_hand.hand)


func _build_card_slots() -> void:
	for i in range(_summon_hand.hand_size):
		var card_node: SummonCardUI = card_scene.instantiate()
		slot_container.add_child(card_node)
		_card_nodes.append(card_node)


func _on_hand_changed(hand: Array) -> void:
	for i in range(hand.size()):
		_card_nodes[i].set_card(hand[i])


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag and event.index == _dragging_touch_index:
		_handle_drag_motion(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion and _dragging_touch_index == 0:
		_handle_drag_motion(event.position)


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_try_start_drag(event.position, event.index)
	elif event.index == _dragging_touch_index:
		_end_drag(event.position)


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.pressed:
		_try_start_drag(event.position, 0)
	elif _dragging_touch_index == 0:
		_end_drag(event.position)


func _try_start_drag(screen_position: Vector2, touch_index: int) -> void:
	if _dragging_touch_index != -1:
		return
	for i in range(_card_nodes.size()):
		var card_node: SummonCardUI = _card_nodes[i]
		if card_node.card != null and card_node.get_global_rect().has_point(screen_position):
			_dragging_index = i
			_dragging_touch_index = touch_index
			_drag_start_position = card_node.position
			_drag_grab_offset = screen_position - card_node.global_position
			card_node.top_level = true
			card_node.global_position = screen_position - _drag_grab_offset
			return


func _handle_drag_motion(screen_position: Vector2) -> void:
	if _dragging_index == -1:
		return
	var card_node: SummonCardUI = _card_nodes[_dragging_index]
	card_node.global_position = screen_position - _drag_grab_offset


func _end_drag(screen_position: Vector2) -> void:
	if _dragging_index == -1:
		return
	var card_node: SummonCardUI = _card_nodes[_dragging_index]
	var released_outside: bool = not slot_container.get_global_rect().has_point(screen_position)
	card_node.top_level = false
	card_node.position = _drag_start_position
	if released_outside:
		_summon_hand.play_card(_dragging_index)
	_dragging_index = -1
	_dragging_touch_index = -1
