extends Area2D

# ===============================
# ===== VARIABEL EXPORT =========
# ===============================
@export var target_scene: String        # Path scene tujuan (contoh: "res://scenes/area2.tscn")
@export var spawn_point_name: String    # Nama spawn point di scene tujuan (contoh: "spawn_from_area1")

# ===============================
# ===== SIGNAL ENTER =============
# ===============================
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):  # hanya player yang bisa trigger
		# Simpan info spawn point ke Global
		Global.next_spawn = spawn_point_name
		
		# Ganti scene ke target
		get_tree().change_scene_to_file(target_scene)
