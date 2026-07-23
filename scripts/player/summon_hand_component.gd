extends Node
class_name SummonHandComponent

# Gestisce la mano di carte evocazione (dimensione fissa, pescate casualmente
# dal mazzo selezionato pre-livello) e la logica di attivazione carta.

signal hand_changed(hand: Array)
signal card_played(card: SummonResource)
signal card_play_failed(card: SummonResource, reason: String)

@export var deck: Array[SummonResource] = []
@export var food_component: FoodComponent
@export var hand_size: int = 5
@export var min_draw_interval: float = 5.0
@export var max_draw_interval: float = 15.0

var hand: Array = []

var _draw_timer: float = 0.0


func _ready() -> void:
	hand.resize(hand_size)
	hand.fill(null)
	_draw_random_card()
	_reset_draw_timer()


func _process(delta: float) -> void:
	_draw_timer -= delta
	if _draw_timer <= 0.0:
		_draw_random_card()
		_reset_draw_timer()


func play_card(slot_index: int) -> SummonResource:
	if slot_index < 0 or slot_index >= hand.size():
		return null
	var card: SummonResource = hand[slot_index]
	if card == null:
		return null
	if not food_component.has_enough_food(card.food_cost):
		card_play_failed.emit(card, "food")
		return null
	food_component.consume_food(card.food_cost)
	hand[slot_index] = null
	hand_changed.emit(hand)
	card_played.emit(card)
	return card


func _reset_draw_timer() -> void:
	_draw_timer = randf_range(min_draw_interval, max_draw_interval)


func _draw_random_card() -> void:
	if deck.is_empty():
		return
	var empty_slot: int = hand.find(null)
	if empty_slot == -1:
		return
	hand[empty_slot] = deck[randi() % deck.size()]
	hand_changed.emit(hand)
