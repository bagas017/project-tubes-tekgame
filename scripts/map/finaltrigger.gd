extends Area2D
@onready var transition: Node = $TransitionLayer 
var entered: bool = false

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		entered = true
		print("🟩 Player memasuki area final")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		entered = false
		print("⬜ Player keluar dari area final")

func _process(delta: float) -> void:
	if entered and Input.is_action_just_pressed("interaction"):
		var gm = GameManager  # ✅ pakai autoload
		var result = gm.check_ending()
		print("🔹 Final Trigger result:", result)
		
		if result.begins_with("Win"):
			_show_ending(true, result)
		else:
			_show_ending(false, result)

func _show_ending(is_win: bool, message: String) -> void:
	if is_win:
		
		get_tree().change_scene_to_file("res://scenes/cutscenes/GoodEnd.tscn")
		print("🏆 Kamu MENANG! ->", message)
	else:
		get_tree().change_scene_to_file("res://scenes/cutscenes/BadEnd.tscn")
		print("💀 Kamu KALAH! ->", message)
