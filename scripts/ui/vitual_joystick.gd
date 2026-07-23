extends Control
class_name SwVirtualJoystick

# Joystick virtuale a doppio livello: base fissa e maniglia mobile.
# Espone "output" (Vector2 normalizzato -1..1) letto ogni frame dal Player.

@export var joystick_radius: float = 80.0

@onready var base: Control = $Base
@onready var knob: Control = $Base/Knob

var output: Vector2 = Vector2.ZERO

var _touch_index: int = -1
var _base_center: Vector2


func _ready() -> void:
	add_to_group("virtual_joystick")
	_base_center = base.position + base.size / 2.0
	_reset_knob()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_knob(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion and _touch_index == 0:
		_update_knob(event.position)


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed and _touch_index == -1:
		_touch_index = event.index
		_update_knob(event.position)
	elif not event.pressed and event.index == _touch_index:
		_touch_index = -1
		_reset_knob()


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.pressed and _touch_index == -1:
		_touch_index = 0
		_update_knob(event.position)
	elif not event.pressed and _touch_index == 0:
		_touch_index = -1
		_reset_knob()


func _update_knob(local_position: Vector2) -> void:
	var offset: Vector2 = (local_position - _base_center).limit_length(joystick_radius)
	knob.position = _base_center + offset - knob.size / 2.0
	output = offset / joystick_radius


func _reset_knob() -> void:
	knob.position = _base_center - knob.size / 2.0
	output = Vector2.ZERO
