extends Node

# ==============================
# ===== VARIABEL GLOBAL ========
# ==============================
var soul_count: int = 0
var scrap_count: int = 0
var food_count: int = 0
var picked_items: Dictionary = {}

const MAX_SOUL: int = 100
const REQUIRED_SOUL: int = 10
const REQUIRED_SCRAP: int = 3
const DEATH_PENALTY: float = 0.1   # 10% soul hilang saat mati

#d @onready var transition_layer: CanvasLayer = $"../TransitionLayer"

# ==============================
# ===== NODE REFERENCE =========
# ==============================
var hud: Node = null

# ==============================
# ===== REGISTER HUD ===========
# ==============================
func register_hud(node: Node) -> void:
	hud = node
	print("HUD registered ke GameManager")

# ==============================
# ===== RESET GAME =============
# ==============================
func reset() -> void:
	soul_count = 0
	scrap_count = 0
	food_count = 0
	picked_items.clear()

# ==============================
# ===== SOUL SYSTEM ============
# ==============================
func add_soul(amount: int = 1) -> void:
	soul_count = clamp(soul_count + amount, 0, MAX_SOUL)
	print("Soul picked! Total soul:", soul_count)

func lose_soul_on_death() -> void:
	if soul_count > 0:
		var lost = int(soul_count * DEATH_PENALTY)
		if lost < 1:
			lost = 1
		soul_count = max(0, soul_count - lost)
		print("Player mati! Soul berkurang:", lost, "-> sisa:", soul_count)

# ==============================
# ===== SCRAP SYSTEM ===========
# ==============================
func add_scrap() -> void:
	if scrap_count < REQUIRED_SCRAP:
		scrap_count += 1
		print("Scrap dikumpulkan:", scrap_count)

# ==============================
# ===== FOOD SYSTEM ============
# ==============================
func add_food(amount: int = 1) -> void:
	food_count += amount
	print("Food dikumpulkan:", food_count)

func reset_food() -> void:
	food_count = 0

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
