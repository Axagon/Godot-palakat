extends Control
class_name SummonCardUI

# Rappresentazione visiva di una singola carta nella mano evocazioni.

@onready var name_label: Label = $NameLabel
@onready var food_label: Label = $FoodLabel

var card: SummonResource = null


func set_card(new_card: SummonResource) -> void:
	card = new_card
	visible = card != null
	if card != null:
		name_label.text = card.summon_name
		food_label.text = str(card.food_cost)
