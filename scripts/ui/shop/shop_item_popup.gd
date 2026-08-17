extends Control
class_name ShopItemPopup

signal closed

@onready var name_label: Label = $Panel/NameLabel
@onready var rarity_label: Label = $Panel/RarityLabel
@onready var price_label: Label = $Panel/PriceLabel
@onready var buy_button: Button = $Panel/BuyButton
@onready var close_button: Button = $Panel/CloseButton

var _item: InventoryItemResource = null
var _slot_index: int = -1


func setup(item: InventoryItemResource, slot_index: int) -> void:
	_item = item
	_slot_index = slot_index
	name_label.text = item.get_display_name()
	rarity_label.text = item.rarity.rarity_name if item.rarity != null else "?"
	price_label.text = "%d Lische d'Oro" % GameState.get_buy_price(item)
	buy_button.disabled = not GameState.can_buy_shop_item(slot_index)
	buy_button.pressed.connect(_on_buy_pressed)
	close_button.pressed.connect(func(): closed.emit())


func _on_buy_pressed() -> void:
	GameState.buy_shop_item(_slot_index)
	closed.emit()
	
