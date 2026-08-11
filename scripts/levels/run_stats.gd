extends Node
# Autoload: RunStats — dati transitori della run corrente, azzerati ad ogni
# tentativo di livello. Nessuna persistenza: a differenza di GameState/
# SaveData, qui vive solo cio' che serve per il pannello di fine livello.

var kills_normal: int = 0
var kills_elite: int = 0
var kills_super_elite: int = 0
var gold_from_normal: int = 0
var gold_from_elite: int = 0
var gold_from_super_elite: int = 0

var boss_defeated: bool = false
var gold_from_boss: int = 0

var outpost_destroyed: bool = false
var gold_from_outpost: int = 0

var total_enemies_planned: int = 0


func reset(planned_enemies: int) -> void:
	kills_normal = 0
	kills_elite = 0
	kills_super_elite = 0
	gold_from_normal = 0
	gold_from_elite = 0
	gold_from_super_elite = 0
	boss_defeated = false
	gold_from_boss = 0
	outpost_destroyed = false
	gold_from_outpost = 0
	total_enemies_planned = planned_enemies


func record_kill(rank: EnemyRankResource.Rank, gold: int) -> void:
	match rank:
		EnemyRankResource.Rank.NORMAL:
			kills_normal += 1
			gold_from_normal += gold
		EnemyRankResource.Rank.ELITE:
			kills_elite += 1
			gold_from_elite += gold
		EnemyRankResource.Rank.SUPER_ELITE:
			kills_super_elite += 1
			gold_from_super_elite += gold


func record_boss_kill(gold: int) -> void:
	boss_defeated = true
	gold_from_boss = gold


func record_outpost_destroyed(gold: int) -> void:
	outpost_destroyed = true
	gold_from_outpost = gold


func get_total_kills() -> int:
	return kills_normal + kills_elite + kills_super_elite + (1 if boss_defeated else 0)


func get_progress_ratio() -> float:
	if total_enemies_planned <= 0:
		return 0.0
	return clamp(float(get_total_kills()) / float(total_enemies_planned), 0.0, 1.0)


func get_kills_gold_total() -> int:
	return gold_from_normal + gold_from_elite + gold_from_super_elite
