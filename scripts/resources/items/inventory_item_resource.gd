extends Resource
class_name InventoryItemResource

enum ItemType { PASSIVE, SHIELD }

@export var item_type: ItemType
@export var rarity: ItemRarityResource
@export var rolled_resource: Resource   # PassiveItemResource o ShieldResource, copia unica
@export var base_template: Resource     # riferimento al .tres originale (nome/icona)
@export var is_favorite: bool = false


func get_display_name() -> String:
	return base_template.item_name if base_template != null else "???"
