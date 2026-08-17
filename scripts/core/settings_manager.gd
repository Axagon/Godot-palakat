extends Node
# Autoload: SettingsManager — preferenze utente persistite in un file
# separato dai salvataggi di gioco (user://settings.cfg), indipendente
# dagli slot SaveData: sono preferenze del dispositivo, non del profilo.

signal setting_changed(key: String, value: float)

const SETTINGS_PATH: String = "user://settings.cfg"
const SECTION: String = "settings"

var _values: Dictionary = {}
var _config: ConfigFile = ConfigFile.new()


func _ready() -> void:
	load_settings()


func load_settings() -> void:
	if _config.load(SETTINGS_PATH) != OK:
		_values = {}
		return
	_values = {}
	for key in _config.get_section_keys(SECTION):
		_values[key] = _config.get_value(SECTION, key)


func get_value(key: String, default_value: float) -> float:
	return _values.get(key, default_value)


func set_value(key: String, value: float) -> void:
	_values[key] = value
	_config.set_value(SECTION, key, value)
	_config.save(SETTINGS_PATH)
	setting_changed.emit(key, value)
