extends Control
class_name SummonCardUI

@onready var name_label: Label = $NameLabel
@onready var food_label: Label = $FoodLabel
@onready var icon_texture: TextureRect = $IconTexture
@onready var upgrade_indicator_label: Label = $UpgradeIndicatorLabel
@onready var category_icon_texture: TextureRect = $CategoryIconTexture
@onready var element_icon_texture: TextureRect = $ElementIconTexture

@onready var peek_panel: Control = $PeekPanel
@onready var peek_role_element_label: Label = $PeekPanel/RoleElementLabel
@onready var peek_upgrade_label: Label = $PeekPanel/UpgradeLevelLabel
@onready var peek_stats_container: VBoxContainer = $PeekPanel/StatsContainer

# Icone placeholder indicizzate per valore enum (CombatUnit.Category e
# SpellResource.Element). Trascinare le texture direttamente in Inspector
# su questa scena; ordine array = ordine di dichiarazione dell'enum.
# Sostituibili con arte definitiva senza toccare questo script.
@export var category_icons: Array[Texture2D] = []   # indice = CombatUnit.Category
@export var element_icons: Array[Texture2D] = []    # indice = SpellResource.Element

const CATEGORY_NAMES: Dictionary = {
	CombatUnit.Category.TANK: "Tank",
	CombatUnit.Category.MELEE: "Mischia",
	CombatUnit.Category.RANGED: "Distanza",
	CombatUnit.Category.SUPPORT: "Supporto",
	CombatUnit.Category.ASSASSIN: "Assassino",
	CombatUnit.Category.HEALER: "Curatore",
	CombatUnit.Category.SUMMONER: "Evocatore",
}

const ELEMENT_NAMES: Dictionary = {
	SpellResource.Element.FIRE: "Fuoco",
	SpellResource.Element.NATURE: "Natura",
}

const HIGHLIGHTED_STAT_COLOR: Color = Color(1.0, 0.85, 0.2)
const NORMAL_STAT_COLOR: Color = Color(1, 1, 1)

var card: SummonResource = null


func _ready() -> void:
	peek_panel.visible = false
	upgrade_indicator_label.visible = false


func set_card(new_card: SummonResource) -> void:
	card = new_card
	visible = card != null
	if card != null:
		name_label.text = card.summon_name
		food_label.text = str(card.food_cost)
		icon_texture.texture = card.icon
		icon_texture.visible = card.icon != null
		_apply_category_element_icons()
	_refresh_upgrade_indicator()
	_refresh_peek_content()


func _apply_category_element_icons() -> void:
	var category_texture: Texture2D = _get_indexed(category_icons, card.category)
	category_icon_texture.texture = category_texture
	category_icon_texture.visible = category_texture != null

	var element_texture: Texture2D = _get_indexed(element_icons, card.element)
	element_icon_texture.texture = element_texture
	element_icon_texture.visible = element_texture != null


func _get_indexed(array: Array[Texture2D], index: int) -> Texture2D:
	if index < 0 or index >= array.size():
		return null
	return array[index]


func _refresh_upgrade_indicator() -> void:
	if card == null:
		upgrade_indicator_label.visible = false
		return
	var level: int = GameState.get_upgrade_level(card)
	upgrade_indicator_label.visible = true
	upgrade_indicator_label.text = "★%d" % (level + 1)


func set_peek_visible(peek_visible: bool) -> void:
	if peek_visible:
		_refresh_peek_content()
	peek_panel.visible = peek_visible and card != null


func _refresh_peek_content() -> void:
	if card == null:
		return

	var role_text: String = CATEGORY_NAMES.get(card.category, "?")
	var element_text: String = ELEMENT_NAMES.get(card.element, "?")
	peek_role_element_label.text = "%s - %s" % [role_text, element_text]

	var upgrade_level: int = GameState.get_upgrade_level(card)
	peek_upgrade_label.visible = upgrade_level > 0
	if upgrade_level > 0:
		peek_upgrade_label.text = "Potenziamento: livello %d" % upgrade_level

	for child in peek_stats_container.get_children():
		child.queue_free()
	for row in UpgradeDisplayUtil.get_stat_rows(card, card.upgrade_curve):
		var stat_label := Label.new()
		stat_label.text = "%s: %s" % [row.label, row.value]
		stat_label.add_theme_color_override("font_color", HIGHLIGHTED_STAT_COLOR if row.highlighted else NORMAL_STAT_COLOR)
		peek_stats_container.add_child(stat_label)
