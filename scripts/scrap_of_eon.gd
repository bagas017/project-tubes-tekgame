extends Area2D

# ==============================
# ===== VARIABEL EXPORT ========
# ==============================
@export var pickup_id: String = ""   # kalau kosong → pakai node.name

# ==============================
# ===== NODE REFERENCE =========
# ==============================
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# ==============================
# ===== READY ==================
# ==============================
func _ready() -> void:
	if pickup_id == "":
		pickup_id = name

	# Kalau scrap sudah diambil sebelumnya → langsung hilang
	if GameManager.is_item_picked(pickup_id):
		queue_free()

# ==============================
# ===== SIGNAL HANDLER =========
# ==============================
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Simpan status pickup
		GameManager.set_item_picked(pickup_id)

		# Tambahkan scrap
		GameManager.add_scrap()
		print("Scrap picked! Total scrap:", GameManager.scrap_count)

		# Mainkan animasi pickup
		if animation_player and animation_player.has_animation("pickup_animation"):
			animation_player.play("pickup_animation")
		else:
			queue_free()
