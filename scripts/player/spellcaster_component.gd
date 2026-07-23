extends Node
class_name SpellCaster

# Gestisce il tentativo di cast per i tre slot di magia (Base, Secondaria, Ultimate).
# Verifica mana disponibile e cooldown, e consuma la risorsa se il cast e' valido.

signal spell_cast(spell: SpellResource)
signal cast_failed(spell: SpellResource, reason: String)

@export var mana_component: ManaComponent

var _cooldown_timers: Dictionary = {}


func try_cast(spell: SpellResource) -> bool:
	if spell == null:
		return false

	if _is_on_cooldown(spell.slot):
		cast_failed.emit(spell, "cooldown")
		return false

	if not mana_component.has_enough_mana(spell.mana_cost):
		cast_failed.emit(spell, "mana")
		return false

	mana_component.consume_mana(spell.mana_cost)
	_start_cooldown(spell.slot, spell.cooldown)
	spell_cast.emit(spell)
	return true


func _is_on_cooldown(slot: SpellResource.SpellSlot) -> bool:
	return _cooldown_timers.has(slot) and _cooldown_timers[slot] > 0.0


func _start_cooldown(slot: SpellResource.SpellSlot, duration: float) -> void:
	_cooldown_timers[slot] = duration


func _process(delta: float) -> void:
	for slot in _cooldown_timers.keys():
		if _cooldown_timers[slot] > 0.0:
			_cooldown_timers[slot] = max(_cooldown_timers[slot] - delta, 0.0)
