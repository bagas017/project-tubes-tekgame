extends Control

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var stamina_bar: TextureProgressBar = $StaminaBar
@onready var state_label: Label = $StateLabel

func _ready() -> void:
	health_bar.max_value = 100
	health_bar.value = 100
	stamina_bar.max_value = 100
	stamina_bar.value = 100
	state_label.text = "Idle"

func update_health(value: int) -> void:
	health_bar.value = clamp(value, 0, health_bar.max_value)

func update_stamina(value: int) -> void:
	stamina_bar.value = clamp(value, 0, stamina_bar.max_value)

func update_state(state: String) -> void:
	state_label.text = state
