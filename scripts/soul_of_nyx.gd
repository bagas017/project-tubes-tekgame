extends Area2D

# ==============================
# ===== VARIABEL EXPORT ========
# ==============================
@export var soul_value: int = 1   # jumlah soul yang diberikan saat diambil

# ==============================
# ===== NODE REFERENCE =========
# ==============================
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# ==============================
# ===== SIGNAL HANDLER =========
# ==============================
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):   # pastikan player sudah di group "player"
		# Tambahkan soul lewat GameManager (autoload)
		GameManager.add_soul(soul_value)
		print("Soul picked! Total soul:", GameManager.soul_count)

		# Mainkan animasi pickup (yang sudah include sound di dalamnya)
		if animation_player and animation_player.has_animation("pickup_animation"):
			animation_player.play("pickup_animation")

		# Jangan langsung queue_free di sini,
		# biarkan AnimationPlayer yang mengeksekusi call_deferred("queue_free")
		# setelah animasi selesai (bisa ditambahkan via Track "Call Method" di timeline)
