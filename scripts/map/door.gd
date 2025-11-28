extends Area2D

@export var target_area: String = ""
@export var target_spawn: String = ""

@export var label_hint_path: NodePath

@export var float_distance: float = 6.0     # jarak naik-turun
@export var float_speed: float = 0.5        # durasi gerakan naik & turun (semakin kecil = semakin cepat)

var entered := false
var label_hint: Label
var float_tween: Tween

func _ready():
	if label_hint_path:
		label_hint = get_node(label_hint_path)
		label_hint.visible = false
	else:
		label_hint = null
		push_warning("LabelHint path belum diisi!")

func start_float():
	if not label_hint:
		return

	if float_tween:
		float_tween.kill()

	float_tween = create_tween()
	float_tween.set_loops()

	var start_y = label_hint.position.y
	var up_y = start_y - float_distance

	# pakai float_speed sebagai durasi animasi
	float_tween.tween_property(label_hint, "position:y", up_y, float_speed)
	float_tween.tween_property(label_hint, "position:y", start_y, float_speed)

func stop_float():
	if float_tween:
		float_tween.kill()
		float_tween = null

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		entered = true
		if label_hint:
			label_hint.visible = true
			start_float()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		entered = false
		if label_hint:
			label_hint.visible = false
			stop_float()

func _process(delta: float) -> void:
	if entered and Input.is_action_just_pressed("interaction"):
		var sm = get_tree().root.get_node("Main/SceneManager")
		if sm:
			sm.change_area(target_area, target_spawn)
