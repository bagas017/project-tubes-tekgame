extends Control

# ==============================
# ===== NODE REFERENCE =========
# ==============================
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var stamina_bar: TextureProgressBar = $StaminaBar
@onready var state_label: Label = $StateLabel
@onready var health_text: Label = $HealthText
@onready var soul_label: Label = $SoulLabel
@onready var scrap_label: Label = $ScrapLabel
@onready var food_label: Label = $FoodLabel

# ==============================
# ===== READY ==================
# ==============================
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.register_hud(self)
		print("HUD registered ke GameManager")
	else:
		print("⚠️ GameManager tidak ditemukan!")

	# Inisialisasi awal
	health_bar.max_value = 100
	health_bar.value = 100
	stamina_bar.max_value = 100
	stamina_bar.value = 100
	state_label.text = "Idle"

	_update_health_text()
	_update_soul_label(GameManager.soul_count)
	_update_scrap_label(GameManager.scrap_count)
	_update_food_label(GameManager.food_count)

# ==============================
# ===== UPDATE FUNGSI ==========
# ==============================
func update_health(value: int) -> void:
	health_bar.value = clamp(value, 0, health_bar.max_value)
	_update_health_text()

func update_health_max(value: int) -> void:
	health_bar.max_value = value
	_update_health_text()

func update_stamina(value: int) -> void:
	stamina_bar.value = clamp(value, 0, stamina_bar.max_value)

func update_state(state: String) -> void:
	state_label.text = state

func update_soul(value: int) -> void:
	_update_soul_label(value)

func update_scrap(value: int) -> void:
	_update_scrap_label(value)

func update_food(value: int) -> void:
	_update_food_label(value)

# ==============================
# ===== INTERNAL UPDATE ========
# ==============================
func _update_health_text() -> void:
	health_text.text = str(int(health_bar.value)) + " / " + str(int(health_bar.max_value))

func _update_soul_label(value: int) -> void:
	soul_label.text = "Soul of Nyx: " + str(value)

func _update_scrap_label(value: int) -> void:
	scrap_label.text = "Scrap of Eon: " + str(value)

func _update_food_label(value: int) -> void:
	food_label.text = "Food Collected: " + str(value)
