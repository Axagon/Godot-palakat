extends Control
class_name ItemActionPopup

signal closed

@onready var name_label: Label = $Panel/NameLabel

@onready var rarity_label: Label = $Panel/RarityLabel

@onready var stats_container: VBoxContainer = $Panel/StatsContainer

@onready var sell_confirm_dialog: ConfirmationDialog = $SellConfirmDialog
@onready var destroy_confirm_dialog: ConfirmationDialog = $DestroyConfirmDialog

@onready var equip_button: Button = $Panel/EquipButton
@onready var favorite_button: Button = $Panel/FavoriteButton
@onready var sell_button: Button = $Panel/SellButton
@onready var destroy_button: Button = $Panel/DestroyButton
@onready var close_button: Button = $Panel/CloseButton

var _item: InventoryItemResource = null


func _ready() -> void:
	equip_button.pressed.connect(_on_equip_pressed)
	favorite_button.pressed.connect(_on_favorite_pressed)
	sell_button.pressed.connect(func(): sell_confirm_dialog.popup_centered())
	destroy_button.pressed.connect(func(): destroy_confirm_dialog.popup_centered())
	close_button.pressed.connect(func(): closed.emit())
	sell_confirm_dialog.confirmed.connect(_on_sell_confirmed)
	destroy_confirm_dialog.confirmed.connect(_on_destroy_confirmed)


func setup(item: InventoryItemResource) -> void:
	_item = item
	name_label.text = item.get_display_name()
	rarity_label.text = item.rarity.rarity_name if item.rarity != null else "?"
	_refresh_stats()
	_refresh_favorite_label()
	sell_confirm_dialog.dialog_text = "Vendere %s per %d Lische d'Oro?" % [item.get_display_name(), GameState.get_sell_value(item)]
	destroy_confirm_dialog.dialog_text = "Distruggere %s per %d Frammenti?" % [item.get_display_name(), item.rarity.fragment_destroy_reward]


func _refresh_stats() -> void:
	for child in stats_container.get_children():
		child.queue_free()
	var resource: Resource = _item.rolled_resource
	for field_name in resource.get_rollable_field_names():
		var value = resource.get(field_name)
		if value == 0 or value == 0.0:
			continue
		var stat_label := Label.new()
		stat_label.text = "%s: %s" % [field_name, str(value)]
		stats_container.add_child(stat_label)


func _refresh_favorite_label() -> void:
	favorite_button.text = "Rimuovi Preferito" if _item.is_favorite else "Preferito"


func _on_favorite_pressed() -> void:
	_item.is_favorite = not _item.is_favorite
	GameState.save_game()
	_refresh_favorite_label()


func _on_equip_pressed() -> void:
	GameState.equip_item(_item)
	closed.emit()


func _on_sell_confirmed() -> void:
	GameState.sell_item(_item)
	closed.emit()


func _on_destroy_confirmed() -> void:
	GameState.destroy_item(_item)
	closed.emit()
