extends Control
class_name SummonHandUI

# Contenitore della mano di carte evocazione.
#
# Layout: posizionamento manuale, ricalcolato ad ogni cambio mano in base al
# numero di carte effettivamente presenti (non allo slot fisso occupato).
# Due modalita' selezionabili da Impostazioni: ventaglio (nuova) o riga
# semplice (vecchia), stesso pattern reattivo di HealthBar/show_enemy_health.
#
# Gesto touch su una carta: macchina a stati IDLE -> PRESSED -> PEEK/DRAGGING.
# - Tocco breve senza movimento: nessuna azione.
# - Pressione prolungata senza movimento: Peek (carta ingrandita/sollevata,
#   contenuto esteso arriva nello step successivo). Rilascio da Peek senza
#   mai trascinare: nessuna azione, la carta torna in mano.
# - Movimento rilevato (da PRESSED o durante un Peek attivo): drag-to-play
#   esistente, invariato. La transizione Peek->Drag passa sempre da
#   _cancel_peek() per evitare stati visivi intermedi inconsistenti.

@export var card_scene: PackedScene
@onready var slot_container: Control = $CardContainer
@onready var next_card_label: Label = $NextCardLabel

# --- Tuning ventaglio ---
@export var fan_spread_degrees: float = 18.0
@export var fan_radius: float = 40.0
@export var fan_card_spacing: float = 90.0

# --- Tuning vista vecchia (riga semplice, nessuna rotazione) ---
@export var old_row_spacing: float = 130.0

# --- Comune a entrambe le modalita' ---
@export var hand_vertical_offset: float = -80.0
@export var card_scale: float = 1.15

# --- Countdown prossima carta ---
@export var next_card_warning_threshold: float = 5.0

# --- Tuning gesto (macchina a stati) ---
@export var drag_threshold_px: float = 12.0
@export var peek_hold_time_sec: float = 0.35
@export var peek_scale_multiplier: float = 1.25
@export var peek_vertical_lift: float = 60.0
@export var card_hit_margin_px: float = 30.0   # allarga l'area toccabile oltre i bordi visivi
const PEEK_Z_INDEX: int = 999

enum CardGestureState { IDLE, PRESSED, PEEK, DRAGGING }

var _summon_hand: SummonHandComponent
var _card_nodes: Array[SummonCardUI] = []

# Posizione/rotazione/z-index "di riposo" per slot, ricalcolati ad ogni
# reflow. Indicizzati per slot logico (0..hand_size-1).
var _fan_positions: Array[Vector2] = []
var _fan_rotations: Array[float] = []
var _fan_z_index: Array[int] = []

var _use_fan_layout: bool = true
var _show_next_card_timer: bool = true

# --- Stato del gesto attivo (uno alla volta, come prima) ---
var _gesture_state: CardGestureState = CardGestureState.IDLE
var _gesture_card_index: int = -1
var _gesture_touch_index: int = -1
var _gesture_start_screen_position: Vector2
var _gesture_start_time_msec: int = 0
var _drag_grab_offset: Vector2

const FAN_BOUNDS_MARGIN: float = 60.0


func _ready() -> void:
	await get_tree().process_frame
	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	_summon_hand = player.summon_hand

	_use_fan_layout = SettingsManager.get_value("hand_view_style", 1.0) >= 0.5
	_show_next_card_timer = SettingsManager.get_value("show_next_card_timer", 1.0) >= 0.5
	SettingsManager.setting_changed.connect(_on_setting_changed)

	_build_card_slots()
	_summon_hand.hand_changed.connect(_on_hand_changed)
	_on_hand_changed(_summon_hand.hand)

	next_card_label.visible = false


func _process(_delta: float) -> void:
	_update_next_card_label()
	_update_peek_hold_timer()


func _update_next_card_label() -> void:
	if _summon_hand == null or not _show_next_card_timer:
		return
	var seconds_left: float = _summon_hand.get_seconds_until_next_draw()
	if seconds_left < 0.0 or seconds_left > next_card_warning_threshold:
		next_card_label.visible = false
		return
	next_card_label.visible = true
	next_card_label.text = "Prossima carta in %s secondi" % _format_seconds_it(seconds_left)


func _format_seconds_it(seconds: float) -> String:
	return ("%.1f" % seconds).replace(".", ",")


# Controlla se la pressione ferma corrente ha superato la soglia di tempo
# per entrare in Peek. Il movimento viene gestito separatamente negli
# eventi di drag/motion (_handle_gesture_motion), non qui.
func _update_peek_hold_timer() -> void:
	if _gesture_state != CardGestureState.PRESSED:
		return
	var elapsed_msec: int = Time.get_ticks_msec() - _gesture_start_time_msec
	if elapsed_msec >= int(peek_hold_time_sec * 1000.0):
		_enter_peek()


func _build_card_slots() -> void:
	var hand_size: int = _summon_hand.hand_size
	_fan_positions.resize(hand_size)
	_fan_rotations.resize(hand_size)
	_fan_z_index.resize(hand_size)
	for i in range(hand_size):
		var card_node: SummonCardUI = card_scene.instantiate()
		slot_container.add_child(card_node)

		card_node.anchor_left = 0.0
		card_node.anchor_top = 0.0
		card_node.anchor_right = 0.0
		card_node.anchor_bottom = 0.0
		card_node.grow_horizontal = Control.GROW_DIRECTION_BOTH
		card_node.grow_vertical = Control.GROW_DIRECTION_BOTH
		card_node.offset_left = 0.0
		card_node.offset_top = 0.0
		card_node.offset_right = card_node.custom_minimum_size.x
		card_node.offset_bottom = card_node.custom_minimum_size.y
		card_node.pivot_offset = card_node.custom_minimum_size / 2.0
		card_node.scale = Vector2(card_scale, card_scale)

		_card_nodes.append(card_node)


func _on_hand_changed(hand: Array) -> void:
	for i in range(hand.size()):
		_card_nodes[i].set_card(hand[i])
	_reflow_layout(hand)


func _on_setting_changed(key: String, value: float) -> void:
	if key == "hand_view_style":
		_use_fan_layout = value >= 0.5
		if _summon_hand != null:
			_reflow_layout(_summon_hand.hand)
	elif key == "show_next_card_timer":
		_show_next_card_timer = value >= 0.5
		if not _show_next_card_timer:
			next_card_label.visible = false


func _reflow_layout(hand: Array) -> void:
	if _use_fan_layout:
		_reflow_fan(hand)
	else:
		_reflow_row(hand)


func _reflow_fan(hand: Array) -> void:
	var visible_slots: Array[int] = _get_visible_slots(hand)
	var total: int = visible_slots.size()
	var mid: float = (total - 1) / 2.0
	for j in range(total):
		var slot_index: int = visible_slots[j]
		var t: float = (j - mid) if total > 1 else 0.0
		var normalized_t: float = (t / mid) if mid > 0.0 else 0.0
		var x: float = t * fan_card_spacing
		var y: float = -fan_radius * (1.0 - normalized_t * normalized_t) + hand_vertical_offset
		_fan_positions[slot_index] = Vector2(x, y)
		_fan_rotations[slot_index] = normalized_t * fan_spread_degrees
		_fan_z_index[slot_index] = int(round(hand.size() - abs(t)))
		_apply_rest_transform(slot_index)


func _reflow_row(hand: Array) -> void:
	var visible_slots: Array[int] = _get_visible_slots(hand)
	var total: int = visible_slots.size()
	var mid: float = (total - 1) / 2.0
	for j in range(total):
		var slot_index: int = visible_slots[j]
		var t: float = (j - mid) if total > 1 else 0.0
		_fan_positions[slot_index] = Vector2(t * old_row_spacing, hand_vertical_offset)
		_fan_rotations[slot_index] = 0.0
		_fan_z_index[slot_index] = 0
		_apply_rest_transform(slot_index)


func _get_visible_slots(hand: Array) -> Array[int]:
	var visible_slots: Array[int] = []
	for i in range(hand.size()):
		if hand[i] != null:
			visible_slots.append(i)
	return visible_slots


# Non tocca la carta con un gesto attivo (PRESSED/PEEK/DRAGGING): la sua
# trasformazione e' sotto controllo del gesto in corso. I valori di riposo
# vengono comunque aggiornati sopra, cosi' risultano gia' corretti quando
# il gesto termina (drag) o viene annullato (peek).
func _apply_rest_transform(slot_index: int) -> void:
	if slot_index == _gesture_card_index and _gesture_state != CardGestureState.IDLE:
		return
	var card_node: SummonCardUI = _card_nodes[slot_index]
	card_node.position = _fan_positions[slot_index]
	card_node.rotation_degrees = _fan_rotations[slot_index]
	card_node.scale = Vector2(card_scale, card_scale)
	card_node.z_index = _fan_z_index[slot_index]


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_try_start_gesture(event.position, event.index)
		elif event.index == _gesture_touch_index:
			_end_gesture(event.position)
	elif event is InputEventScreenDrag and event.index == _gesture_touch_index:
		_handle_gesture_motion(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_try_start_gesture(event.position, 0)
		elif _gesture_touch_index == 0:
			_end_gesture(event.position)
	elif event is InputEventMouseMotion and _gesture_touch_index == 0:
		_handle_gesture_motion(event.position)


# Hit-test corretto per carte ruotate/scalate: proietta il punto in spazio
# locale della carta tramite la trasformazione inversa, invece di affidarsi
# a get_global_rect() (che ignora rotation e scale).
func _try_start_gesture(screen_position: Vector2, touch_index: int) -> void:
	if _gesture_state != CardGestureState.IDLE:
		return
	var hit_index: int = _find_topmost_card_at(screen_position)
	if hit_index == -1:
		return
	_gesture_state = CardGestureState.PRESSED
	_gesture_card_index = hit_index
	_gesture_touch_index = touch_index
	_gesture_start_screen_position = screen_position
	_gesture_start_time_msec = Time.get_ticks_msec()


# Tra tutte le carte il cui rettangolo (allargato di card_hit_margin_px
# oltre i bordi visivi, per rendere il tocco piu' tollerante quando molte
# carte si sovrappongono) contiene il punto toccato, sceglie quella con
# z_index piu' alto: e' la carta che l'utente vede effettivamente in cima
# in quel punto. Il margine e' espresso in pixel schermo ma il test avviene
# in spazio locale della carta (gia' scalato dalla trasformazione inversa),
# quindi va convertito dividendo per card_scale, altrimenti l'ingrandimento
# percepito cambierebbe con la dimensione della carta.
func _find_topmost_card_at(screen_position: Vector2) -> int:
	var local_margin: float = card_hit_margin_px / card_scale
	var best_index: int = -1
	var best_z: int = -99999
	for i in range(_card_nodes.size()):
		var card_node: SummonCardUI = _card_nodes[i]
		if card_node.card == null:
			continue
		var local_point: Vector2 = card_node.get_global_transform().affine_inverse() * screen_position
		var hit_rect: Rect2 = Rect2(Vector2.ZERO, card_node.size).grow(local_margin)
		if not hit_rect.has_point(local_point):
			continue
		if card_node.z_index > best_z:
			best_z = card_node.z_index
			best_index = i
	return best_index


func _handle_gesture_motion(screen_position: Vector2) -> void:
	match _gesture_state:
		CardGestureState.PRESSED:
			if screen_position.distance_to(_gesture_start_screen_position) >= drag_threshold_px:
				_start_drag(screen_position)
		CardGestureState.PEEK:
			if screen_position.distance_to(_gesture_start_screen_position) >= drag_threshold_px:
				_cancel_peek()
				_start_drag(screen_position)
		CardGestureState.DRAGGING:
			var card_node: SummonCardUI = _card_nodes[_gesture_card_index]
			card_node.global_position = screen_position - _drag_grab_offset


func _enter_peek() -> void:
	_gesture_state = CardGestureState.PEEK
	var card_node: SummonCardUI = _card_nodes[_gesture_card_index]
	var lifted_position: Vector2 = _fan_positions[_gesture_card_index] + Vector2(0.0, -peek_vertical_lift)
	card_node.position = lifted_position
	card_node.scale = Vector2(card_scale, card_scale) * peek_scale_multiplier
	card_node.z_index = PEEK_Z_INDEX
	card_node.set_peek_visible(true)
	# Contenuto esteso del Peek (statistiche, livello potenziamento, ruolo):
	# arriva nello step successivo, qui solo il comportamento visivo/gesto.


# Unico punto che riporta la carta dallo stato Peek al riposo: chiamato sia
# dal rilascio pulito sia dalla transizione Peek->Drag, cosi' il drag parte
# sempre da uno stato coerente indipendentemente da chi l'ha originato.
func _cancel_peek() -> void:
	var card_node: SummonCardUI = _card_nodes[_gesture_card_index]
	card_node.position = _fan_positions[_gesture_card_index]
	card_node.rotation_degrees = _fan_rotations[_gesture_card_index]
	card_node.scale = Vector2(card_scale, card_scale)
	card_node.z_index = _fan_z_index[_gesture_card_index]
	card_node.set_peek_visible(false)


func _start_drag(screen_position: Vector2) -> void:
	_gesture_state = CardGestureState.DRAGGING
	var card_node: SummonCardUI = _card_nodes[_gesture_card_index]
	_drag_grab_offset = screen_position - card_node.global_position
	card_node.top_level = true
	card_node.global_position = screen_position - _drag_grab_offset


func _end_gesture(screen_position: Vector2) -> void:
	match _gesture_state:
		CardGestureState.PRESSED:
			pass  # tocco breve senza movimento: nessuna azione
		CardGestureState.PEEK:
			_cancel_peek()
		CardGestureState.DRAGGING:
			_end_drag(screen_position)
	_gesture_state = CardGestureState.IDLE
	_gesture_card_index = -1
	_gesture_touch_index = -1


func _end_drag(screen_position: Vector2) -> void:
	var card_node: SummonCardUI = _card_nodes[_gesture_card_index]
	var released_outside: bool = not _get_fan_bounds_global_rect().has_point(screen_position)
	card_node.top_level = false
	card_node.position = _fan_positions[_gesture_card_index]
	card_node.rotation_degrees = _fan_rotations[_gesture_card_index]
	card_node.scale = Vector2(card_scale, card_scale)
	card_node.z_index = _fan_z_index[_gesture_card_index]
	if released_outside:
		_summon_hand.play_card(_gesture_card_index)


func _get_fan_bounds_global_rect() -> Rect2:
	var container_rect: Rect2 = slot_container.get_global_rect()
	return container_rect.grow(FAN_BOUNDS_MARGIN)
