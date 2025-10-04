extends Control

@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var exit_button: Button = $VBoxContainer/ExitButton

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS   # tetap bisa input meski game paused
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"): # ESC default
		toggle_pause()

func toggle_pause() -> void:
	visible = not visible
	get_tree().paused = visible

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_restart_pressed() -> void:
	get_tree().paused = false

	# Reset data player & item
	Global.reset()
	GameManager.reset()

	var transition = get_tree().root.get_node("Main/TransitionLayer")
	transition.fade_to_scene(get_tree().current_scene.scene_file_path, 1.0)  # restart scene dengan fade

func _on_exit_pressed() -> void:
	get_tree().paused = false

	# Reset data player & item
	Global.reset()
	GameManager.reset()

	var transition = get_tree().root.get_node("Main/TransitionLayer")
	transition.fade_to_scene("res://scenes/main_menu.tscn", 1.0)   # fade ke main menu
