extends Control
class_name InventorySlotUI

signal slot_clicked(item: InventoryItemResource)

@onready var icon_texture: TextureRect = $IconTexture
@onready var favorite_label: Label = $FavoriteLabel

var item: InventoryItemResource = null


func set_item(new_item: InventoryItemResource) -> void:
	item = new_item
	if item == null:
		icon_texture.texture = null
		icon_texture.modulate = Color(1, 1, 1, 0.15)  # slot vuoto, leggermente visibile
		favorite_label.visible = false
		return

	icon_texture.texture = item.base_template.icon if item.base_template != null else null
	icon_texture.modulate = item.rarity.tint_color if item.rarity != null else Color(1, 1, 1, 1)
	favorite_label.visible = item.is_favorite


func _gui_input(event: InputEvent) -> void:
	if item == null:
		return
	if event is InputEventScreenTouch and event.pressed:
		slot_clicked.emit(item)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_clicked.emit(item)
