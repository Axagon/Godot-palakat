extends CharacterBody2D
class_name Player

@export var move_speed: float = 300.0
@export var projectile_scene: PackedScene
@export var summon_scene: PackedScene

@export var base_max_summons: int = 5
var max_summons: int = 5

@export var base_spell: SpellResource
@export var secondary_spell: SpellResource
@export var ultimate_spell: SpellResource

@onready var animated_sprite = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var mana_component: ManaComponent = $ManaComponent
@onready var spell_caster: SpellCaster = $SpellCaster
@onready var food_component: FoodComponent = $FoodComponent
@onready var summon_hand: SummonHandComponent = $SummonHandComponent

@onready var equipment: EquipmentComponent = $EquipmentComponent
@onready var shield_component: ShieldComponent = $ShieldComponent

var _virtual_joystick: SwVirtualJoystick = null
var facing_direction: float = 1.0


func _ready() -> void:
	add_to_group("player")
	add_to_group("player_side")
	spell_caster.spell_cast.connect(_on_spell_cast)
	summon_hand.card_played.connect(_on_card_played)


func _physics_process(_delta: float) -> void:
	if _virtual_joystick == null:
		_virtual_joystick = get_tree().get_first_node_in_group("virtual_joystick")

	var input_direction: float = Input.get_axis("ui_left", "ui_right")
	if _virtual_joystick != null and absf(_virtual_joystick.output.x) > 0.1:
		input_direction = _virtual_joystick.output.x

	velocity.x = input_direction * move_speed
	velocity.y = 0.0
	move_and_slide()

	if input_direction != 0.0:
		facing_direction = signf(input_direction)
		animated_sprite.flip_h = (facing_direction > 0)

	if velocity.length() > 10:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("default")


func apply_damage(amount: int) -> void:
	var remaining_damage: int = shield_component.absorb_damage(amount)
	if remaining_damage > 0:
		health_component.take_damage(remaining_damage)


func apply_heal(amount: int) -> void:
	health_component.heal(amount)


func _on_spell_cast(spell: SpellResource) -> void:
	var bonus_multiplier: float = 1.0 + equipment.spell_damage_percent
	match spell.spell_type:
		SpellResource.SpellType.OFFENSIVE:
			_cast_offensive(spell, bonus_multiplier)
		SpellResource.SpellType.HEAL:
			health_component.heal(int(round(spell.heal_amount * bonus_multiplier)))
		SpellResource.SpellType.SHIELD:
			shield_component.add_shield(spell.shield_amount * bonus_multiplier)


func _cast_offensive(spell: SpellResource, bonus_multiplier: float) -> void:
	if projectile_scene == null:
		return
	var projectile: Projectile = ObjectPool.get_instance(projectile_scene)
	projectile.source_scene = projectile_scene
	projectile.reset_state()
	var final_damage: int = int(round(spell.damage * bonus_multiplier))
	projectile.damage = final_damage
	projectile.max_range = spell.spell_range
	projectile.applies_burn = spell.element == SpellResource.Element.FIRE
	projectile.burn_damage = int(round(final_damage * CombatUnit.FIRE_BURN_DAMAGE_PERCENT)) if projectile.applies_burn else 0
	projectile.burn_duration = CombatUnit.FIRE_BURN_DURATION
	projectile.global_position = global_position
	projectile.collision_layer = 0
	projectile.collision_mask = 4
	if projectile.get_parent() == null:
		get_tree().current_scene.add_child(projectile)
	projectile.set_direction(facing_direction)


func _on_card_played(card: SummonResource) -> void:
	var scene_to_use: PackedScene = card.summon_scene_override if card.summon_scene_override != null else summon_scene
	if scene_to_use == null:
		return
	var summon: Summon = scene_to_use.instantiate()
	summon.summon_resource = card

	var spawn_point: Node2D = get_tree().get_first_node_in_group("summon_spawn_point")
	summon.global_position = spawn_point.global_position if spawn_point != null else global_position
	get_tree().current_scene.add_child(summon)
	
