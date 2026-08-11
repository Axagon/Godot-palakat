extends EnemyResource
class_name ExplodingEnemyResource

# Dati per un nemico che esplode alla morte, infliggendo danno ad area alle
# unita' player_side vicine. Riusa il pattern AoE gia' presente in
# BossResource, applicato pero' al trigger "morte" invece che a un timer.

@export var explosion_damage: int = 8
@export var explosion_radius: float = 100.0
