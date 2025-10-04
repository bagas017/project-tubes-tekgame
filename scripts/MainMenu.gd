extends Control

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var exit_button: Button = $VBoxContainer/ExitButton
@onready var transition: Node = $TransitionLayer  # ambil node TransitionLayer langsung

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_play_pressed() -> void:
	# Reset data player & item
	Global.reset()
	GameManager.reset()

	if transition and transition.is_inside_tree():
		await transition.fade_to_scene("res://scenes/main.tscn", 1.0)
	else:
		push_warning("TransitionLayer belum siap saat menekan Play")

func _on_exit_pressed() -> void:
	get_tree().quit()
