extends Resource
class_name CatalystResource

@export var catalyst_name: String = ""
@export var element: SpellResource.Element = SpellResource.Element.FIRE
@export var spell_type: SpellResource.SpellType = SpellResource.SpellType.OFFENSIVE

@export var base_damage: int = 0
@export var base_heal_amount: int = 0
@export var base_shield_amount: float = 0.0
@export var base_mana_cost: int = 10
@export var base_cooldown: float = 1.5
