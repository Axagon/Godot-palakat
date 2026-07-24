extends Resource
class_name SpellResource

enum SpellSlot { BASE, SECONDARY, ULTIMATE }
enum Element { FIRE, NATURE }
enum SpellType { OFFENSIVE, HEAL, SHIELD }

@export var spell_name: String = ""
@export var slot: SpellSlot = SpellSlot.BASE
@export var element: Element = Element.FIRE
@export var spell_type: SpellType = SpellType.OFFENSIVE
@export var spell_range: float = 700.0

@export var mana_cost: int = 10
@export var cooldown: float = 1.5

@export var damage: int = 0
@export var heal_amount: int = 0
@export var shield_amount: float = 0.0
