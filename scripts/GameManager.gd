extends Node

# ==============================
# ====== GAME STATE ============
# ==============================
var soul_count: int = 0
var scrap_count: int = 0

const MAX_SOUL: int = 100
const REQUIRED_SOUL: int = 70
const REQUIRED_SCRAP: int = 3
const DEATH_PENALTY: float = 0.05

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
# ===== ENDING CHECK ===========
# ==============================
func check_ending() -> String:
	if scrap_count < REQUIRED_SCRAP:
		return "Game Over: Scrap tidak lengkap"
	if soul_count < REQUIRED_SOUL:
		return "Game Over: Soul terlalu sedikit"
	return "Win: Kamu berhasil kembali ke dunia asal!"
