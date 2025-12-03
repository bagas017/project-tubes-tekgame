extends Control

@export var tween_intensity: float
@export var tween_duration: float 

@onready var play_button: Button = $PlayButton
@onready var setting_button: Button = $SettingButton
@onready var exit_button: Button = $ExitButton
@onready var transition: Node = $TransitionLayer

# Setting panel references
@onready var settings_panel: Control = $SettingsPanel
@onready var audio_toggle: CheckBox = $SettingsPanel/AudioToggle
@onready var close_button: Button = $SettingsPanel/CloseButton



func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	setting_button.pressed.connect(_on_setting_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	close_button.pressed.connect(_on_close_pressed)
	audio_toggle.toggled.connect(_on_audio_toggled)

	# Sync toggle dengan AudioManager
	audio_toggle.button_pressed = AudioManager.master_enabled


# ======================
# BUTTON — PLAY
# ======================
func _on_play_pressed() -> void:
	Global.reset()
	GameManager.reset()

	if transition and transition.is_inside_tree():
		await transition.fade_to_scene("res://scenes/cutscenes/intro.tscn", 1.0)
	else:
		push_warning("TransitionLayer belum siap saat menekan Play")


# ======================
# BUTTON — EXIT
# ======================
func _on_exit_pressed() -> void:
	get_tree().quit()


# ======================
# BUTTON — SETTINGS
# ======================
func _on_setting_pressed() -> void:
	settings_panel.visible = true


func _on_close_pressed() -> void:
	settings_panel.visible = false


# ======================
# AUDIO ON / OFF
# ======================
func _on_audio_toggled(pressed: bool) -> void:
	AudioManager.set_master_audio(pressed)

	if pressed:
		audio_toggle.text = "Audio ON"
	else:
		audio_toggle.text = "Audio OFF"
