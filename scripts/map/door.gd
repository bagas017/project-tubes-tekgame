extends Area2D

@export var target_area: String = ""
@export var target_spawn: String = ""

@export var label_hint_path: NodePath   # <= kamu isi dari editor

var entered := false
var label_hint: Label

func _ready():
	if label_hint_path:
		label_hint = get_node(label_hint_path)
		label_hint.visible = false
	else:
		label_hint = null
		push_warning("LabelHint path belum diisi!")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		entered = true
		if label_hint:
			label_hint.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		entered = false
		if label_hint:
			label_hint.visible = false

func _process(delta: float) -> void:
	if entered and Input.is_action_just_pressed("interaction"):
		var sm = get_tree().root.get_node("Main/SceneManager")
		if sm:
			sm.change_area(target_area, target_spawn)
