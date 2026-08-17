extends Resource
class_name SettingDefinitionResource

# Definizione dati di una singola voce in Impostazioni. Lista generica
# cosi' da poter aggiungere nuove voci senza toccare la struttura della
# schermata (vedi SettingsScreen).

enum ControlType { SLIDER, TOGGLE }

@export var key: String = ""
@export var label: String = ""
@export var control_type: ControlType = ControlType.TOGGLE
@export var default_value: float = 0.0
@export var min_value: float = 0.0
@export var max_value: float = 1.0
@export var step: float = 0.05
