extends RefCounted
class_name UpgradeDisplayUtil

# Traduce una risorsa potenziabile + la sua curva nelle righe da mostrare in
# UpgradeRowUI: etichetta, valore corrente (gia' scalato al livello attuale),
# flag se e' la stat che il prossimo potenziamento migliorera'. Nessuno stato
# proprio, sola formattazione — la logica di gioco reale resta in GameState/
# EquipmentComponent/Summon.

static func get_stat_rows(resource: Resource, curve: BaseUpgradeCurveResource) -> Array[Dictionary]:
	var current_level: int = GameState.get_upgrade_level(resource)
	if resource is CatalystResource:
		return _catalyst_rows(resource, curve as UpgradeCurveResource, current_level)
	elif resource is PassiveItemResource:
		return _passive_item_rows(resource, curve as UpgradeCurveResource, current_level)
	elif resource is ShieldResource:
		return _shield_rows(resource, curve as UpgradeCurveResource, current_level)
	elif resource is SummonResource:
		return _summon_rows(resource, curve as SummonUpgradeCurveResource, current_level)
	return []


static func _catalyst_rows(catalyst: CatalystResource, curve: UpgradeCurveResource, level: int) -> Array[Dictionary]:
	var mult: float = curve.get_multiplier_for_level(level) if curve != null else 1.0
	var rows: Array[Dictionary] = []
	if catalyst.base_damage > 0:
		rows.append({"label": "Danno", "value": str(int(round(catalyst.base_damage * mult))), "highlighted": true})
	if catalyst.base_heal_amount > 0:
		rows.append({"label": "Cura", "value": str(int(round(catalyst.base_heal_amount * mult))), "highlighted": true})
	if catalyst.base_shield_amount > 0.0:
		rows.append({"label": "Scudo", "value": "%.1f" % (catalyst.base_shield_amount * mult), "highlighted": true})
	return rows


static func _passive_item_rows(item: PassiveItemResource, curve: UpgradeCurveResource, level: int) -> Array[Dictionary]:
	var mult: float = curve.get_multiplier_for_level(level) if curve != null else 1.0
	var rows: Array[Dictionary] = []
	_add_passive_row(rows, item, PassiveItemResource.UpgradeStat.MAX_HEALTH, "Salute Max", item.max_health_flat, mult)
	_add_passive_row(rows, item, PassiveItemResource.UpgradeStat.MAX_MANA, "Mana Max", item.max_mana_flat, mult)
	_add_passive_row(rows, item, PassiveItemResource.UpgradeStat.MANA_REGEN, "Rigen. Mana", item.mana_regen_flat, mult)
	_add_passive_row(rows, item, PassiveItemResource.UpgradeStat.MAX_FOOD, "Cibo Max", item.max_food_flat, mult)
	_add_passive_row(rows, item, PassiveItemResource.UpgradeStat.FOOD_REGEN, "Rigen. Cibo", item.food_regen_flat, mult)
	_add_passive_row(rows, item, PassiveItemResource.UpgradeStat.MOVE_SPEED, "Velocita'", item.move_speed_percent, mult)
	_add_passive_row(rows, item, PassiveItemResource.UpgradeStat.SPELL_DAMAGE, "Danno Magie", item.spell_damage_percent, mult)
	_add_passive_row(rows, item, PassiveItemResource.UpgradeStat.SHIELD_REGEN, "Rigen. Scudo", item.shield_regen_percent, mult)
	return rows


static func _add_passive_row(rows: Array[Dictionary], item: PassiveItemResource, stat: PassiveItemResource.UpgradeStat, label: String, base_value: float, mult: float) -> void:
	if base_value == 0.0:
		return
	var is_target: bool = item.upgrade_target_stat == stat
	var final_value: float = base_value * mult if is_target else base_value
	rows.append({"label": label, "value": "%.2f" % final_value, "highlighted": is_target})


static func _shield_rows(shield: ShieldResource, curve: UpgradeCurveResource, level: int) -> Array[Dictionary]:
	var mult: float = curve.get_multiplier_for_level(level) if curve != null else 1.0
	var rows: Array[Dictionary] = []
	var max_is_target: bool = shield.upgrade_target_stat == ShieldResource.UpgradeStat.MAX_SHIELD
	var regen_is_target: bool = shield.upgrade_target_stat == ShieldResource.UpgradeStat.REGEN
	rows.append({"label": "Scudo Max", "value": "%.1f" % (shield.max_shield * (mult if max_is_target else 1.0)), "highlighted": max_is_target})
	rows.append({"label": "Rigenerazione", "value": "%.2f" % (shield.shield_regen_per_second * (mult if regen_is_target else 1.0)), "highlighted": regen_is_target})
	return rows


static func _summon_rows(summon: SummonResource, curve: SummonUpgradeCurveResource, level: int) -> Array[Dictionary]:
	var hp_mult: float = curve.get_health_multiplier(level) if curve != null else 1.0
	var dmg_mult: float = curve.get_damage_multiplier(level) if curve != null else 1.0
	var speed_mult: float = curve.get_speed_multiplier(level) if curve != null else 1.0
	var next_hp_mult: float = curve.get_health_multiplier(level + 1) if curve != null else hp_mult
	var next_dmg_mult: float = curve.get_damage_multiplier(level + 1) if curve != null else dmg_mult
	var next_speed_mult: float = curve.get_speed_multiplier(level + 1) if curve != null else speed_mult
	var rows: Array[Dictionary] = []
	rows.append({"label": "Salute", "value": str(int(round(summon.max_health * hp_mult))), "highlighted": next_hp_mult != hp_mult})
	rows.append({"label": "Danno", "value": str(int(round(summon.attack_damage * dmg_mult))), "highlighted": next_dmg_mult != dmg_mult})
	rows.append({"label": "Velocita'", "value": "%.0f" % (summon.move_speed * speed_mult), "highlighted": next_speed_mult != speed_mult})
	return rows
