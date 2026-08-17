extends Control
class_name InventoryScreen

@export var slot_scene: PackedScene
@export var popup_scene: PackedScene
@export var main_menu_path: String = "res://scripts/ui/main_menu/main_menu.tscn"

@onready var slot_grid: GridContainer = $MarginContainer/VBoxContainer/RowsScroll/SlotGrid
@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton

var _current_popup: ItemActionPopup = null


func _ready() -> void:
	_build_slots()
	back_button.pressed.connect(func(): get_tree().change_scene_to_file(main_menu_path))


func _build_slots() -> void:
	var inventory: Array = GameState.save_data.inventory
	var capacity: int = GameState.get_inventory_capacity()
	for i in range(capacity):
		var slot: InventorySlotUI = slot_scene.instantiate()
		slot_grid.add_child(slot)
		slot.set_item(inventory[i] if i < inventory.size() else null)
		slot.slot_clicked.connect(_on_slot_clicked)


func _on_slot_clicked(item: InventoryItemResource) -> void:
	if _current_popup != null:
		return
	_current_popup = popup_scene.instantiate()
	add_child(_current_popup)
	_current_popup.setup(item)
	_current_popup.closed.connect(_on_popup_closed)


func _on_popup_closed() -> void:
	_current_popup.queue_free()
	_current_popup = null
	_refresh_all_slots()  # riflette eventuale toggle Preferito


func _refresh_all_slots() -> void:
	var inventory: Array = GameState.save_data.inventory
	var index: int = 0
	for slot in slot_grid.get_children():
		slot.set_item(inventory[index] if index < inventory.size() else null)
		index += 1
