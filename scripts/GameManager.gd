extends Node

# ==============================
# ===== VARIABEL GLOBAL ========
# ==============================
var soul_count: int = 0
var scrap_count: int = 0
var picked_items: Dictionary = {}   # menyimpan ID item yang sudah diambil

const MAX_SOUL: int = 100
const REQUIRED_SOUL: int = 70
const REQUIRED_SCRAP: int = 3
const DEATH_PENALTY: float = 0.05   # 5% soul hilang saat mati

# ==============================
# ===== RESET GAME =============
# ==============================
func reset() -> void:
	soul_count = 0
	scrap_count = 0
	picked_items.clear()

# ==============================
# ===== SOUL SYSTEM ============
# ==============================
func add_soul(amount: int = 1) -> void:
	soul_count = clamp(soul_count + amount, 0, MAX_SOUL)

func lose_soul_on_death() -> void:
	var lost = int(soul_count * DEATH_PENALTY)
	soul_count = max(0, soul_count - lost)

# ==============================
# ===== SCRAP SYSTEM ===========
# ==============================
func add_scrap() -> void:
	if scrap_count < REQUIRED_SCRAP:
		scrap_count += 1

# ==============================
# ===== ITEM SAVE SYSTEM =======
# ==============================
func is_item_picked(id: String) -> bool:
	return picked_items.has(id)

func set_item_picked(id: String) -> void:
	picked_items[id] = true

# ==============================
# ===== ENDING CHECK ===========
# ==============================
func check_ending() -> String:
	if scrap_count < REQUIRED_SCRAP:
		return "Game Over: Scrap tidak lengkap"
	if soul_count < REQUIRED_SOUL:
		return "Game Over: Soul terlalu sedikit"
	return "Win: Kamu berhasil kembali ke dunia asal!"
