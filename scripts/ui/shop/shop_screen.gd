extends Control
class_name ShopScreen

@export var slot_scene: PackedScene
@export var popup_scene: PackedScene
@export var main_menu_path: String = "res://scripts/ui/main_menu/main_menu.tscn"

@onready var slot_row: HBoxContainer = $MarginContainer/VBoxContainer/SlotRow
@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton

var _slots: Array[InventorySlotUI] = []
var _current_popup: ShopItemPopup = null


func _ready() -> void:
	for i in range(GameState.get_shop_slot_count()):
		var slot: InventorySlotUI = slot_scene.instantiate()
		slot_row.add_child(slot)
		_slots.append(slot)
		slot.slot_clicked.connect(_on_slot_clicked.bind(i))
	_refresh_slots()
	back_button.pressed.connect(func(): get_tree().change_scene_to_file(main_menu_path))

func _refresh_slots() -> void:
	var rotation: Array = GameState.save_data.shop_rotation
	for i in range(_slots.size()):
		_slots[i].set_item(rotation[i] if i < rotation.size() else null)


func _on_slot_clicked(item: InventoryItemResource, index: int) -> void:
	if _current_popup != null:
		return
	_current_popup = popup_scene.instantiate()
	add_child(_current_popup)
	_current_popup.setup(item, index)
	_current_popup.closed.connect(_on_popup_closed)


func _on_popup_closed() -> void:
	_current_popup.queue_free()
	_current_popup = null
	_refresh_slots()
