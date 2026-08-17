extends HBoxContainer
class_name SettingRowUI

@onready var name_label: Label = $NameLabel
@onready var slider_control: HSlider = $SliderControl
@onready var toggle_control: CheckButton = $ToggleControl

var _definition: SettingDefinitionResource = null


func setup(definition: SettingDefinitionResource) -> void:
	_definition = definition
	name_label.text = definition.label
	var current_value: float = SettingsManager.get_value(definition.key, definition.default_value)

	match definition.control_type:
		SettingDefinitionResource.ControlType.SLIDER:
			slider_control.visible = true
			toggle_control.visible = false
			slider_control.min_value = definition.min_value
			slider_control.max_value = definition.max_value
			slider_control.step = definition.step
			slider_control.value = current_value
			slider_control.value_changed.connect(_on_slider_changed)
		SettingDefinitionResource.ControlType.TOGGLE:
			slider_control.visible = false
			toggle_control.visible = true
			toggle_control.button_pressed = current_value >= 0.5
			toggle_control.toggled.connect(_on_toggle_changed)


func _on_slider_changed(value: float) -> void:
	SettingsManager.set_value(_definition.key, value)


func _on_toggle_changed(pressed: bool) -> void:
	SettingsManager.set_value(_definition.key, 1.0 if pressed else 0.0)
