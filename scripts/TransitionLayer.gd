extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

func _ready() -> void:
	rect.color = Color(0, 0, 0, 0)   # mulai transparan
	visible = false                  # tidak terlihat kalau tidak dipakai
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


# Fade in: layar jadi hitam
func fade_in(duration: float = 1.0) -> void:
	if not is_inside_tree():
		await ready  # pastikan sudah di scene tree
	visible = true
	var tween = create_tween()
	tween.tween_property(rect, "color:a", 1.0, duration)
	await tween.finished


# Fade out: layar jadi transparan
func fade_out(duration: float = 1.0) -> void:
	if not is_inside_tree():
		await ready
	var tween = create_tween()
	tween.tween_property(rect, "color:a", 0.0, duration)
	await tween.finished
	visible = false


# Fungsi praktis: transisi ke scene baru
func fade_to_scene(path: String, duration: float = 1.0) -> void:
	if not is_inside_tree():
		await ready  # tunggu node aktif sepenuhnya

	await fade_in(duration)                                  # gelapkan layar
	var tree := get_tree()
	if tree:
		tree.change_scene_to_file(path)                      # ganti scene
		await tree.process_frame                             # tunggu 1 frame
	else:
		push_error("SceneTree belum siap! TransitionLayer tidak ada di scene aktif.")
	await fade_out(duration)                                 # terangin lagi
