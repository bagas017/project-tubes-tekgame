extends Area2D

# ==============================
# ===== VARIABEL EXPORT ========
# ==============================
@export var pickup_id: String = ""   # kalau kosong → otomatis pakai node.name
@export var soul_value: int = 1

# ==============================
# ===== NODE REFERENCE =========
# ==============================
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# ==============================
# ===== READY ==================
# ==============================
func _ready() -> void:
	# Kalau ID kosong, gunakan nama node sebagai ID unik
	if pickup_id == "":
		pickup_id = name

	# Kalau item sudah pernah diambil → langsung hilang
	if GameManager.is_item_picked(pickup_id):
		queue_free()

# ==============================
# ===== SIGNAL HANDLER =========
# ==============================
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Simpan status bahwa item ini sudah diambil
		GameManager.set_item_picked(pickup_id)

		# Tambahkan soul ke GameManager
		GameManager.add_soul(soul_value)
		print("Soul picked! Total soul:", GameManager.soul_count)

		# Mainkan animasi pickup (kalau ada)
		if animation_player and animation_player.has_animation("pickup_animation"):
			animation_player.play("pickup_animation")
		else:
			queue_free()
