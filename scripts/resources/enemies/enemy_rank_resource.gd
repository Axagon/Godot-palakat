extends Resource
class_name EnemyRankResource

enum Rank { NORMAL, ELITE, SUPER_ELITE }

@export var elite_tint: Color = Color(0.6, 0.6, 0.6, 1.0)
@export var elite_hp_mult: float = 1.5
@export var elite_damage_mult: float = 1.3
@export var elite_speed_mult: float = 1.1
@export var elite_gold_mult: float = 2.0

@export var super_elite_tint: Color = Color(1.0, 0.65, 0.0, 1.0)
@export var super_elite_hp_mult: float = 2.5
@export var super_elite_damage_mult: float = 1.8
@export var super_elite_speed_mult: float = 1.25
@export var super_elite_gold_mult: float = 4.0


func get_tint(rank: Rank) -> Color:
	match rank:
		Rank.ELITE: return elite_tint
		Rank.SUPER_ELITE: return super_elite_tint
		_: return Color(1, 1, 1, 1)


func get_hp_mult(rank: Rank) -> float:
	match rank:
		Rank.ELITE: return elite_hp_mult
		Rank.SUPER_ELITE: return super_elite_hp_mult
		_: return 1.0


func get_damage_mult(rank: Rank) -> float:
	match rank:
		Rank.ELITE: return elite_damage_mult
		Rank.SUPER_ELITE: return super_elite_damage_mult
		_: return 1.0


func get_speed_mult(rank: Rank) -> float:
	match rank:
		Rank.ELITE: return elite_speed_mult
		Rank.SUPER_ELITE: return super_elite_speed_mult
		_: return 1.0


func get_gold_mult(rank: Rank) -> float:
	match rank:
		Rank.ELITE: return elite_gold_mult
		Rank.SUPER_ELITE: return super_elite_gold_mult
		_: return 1.0
