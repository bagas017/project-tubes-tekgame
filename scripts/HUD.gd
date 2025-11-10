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

# ==============================
# ===== INTERNAL UPDATE ========
# ==============================
func _update_health_text() -> void:
	health_text.text = str(int(health_bar.value)) + " / " + str(int(health_bar.max_value))

func sync_from_player(player: Node) -> void:
	if not player.has_node("StateDebugLabel"):
		return
	
	var player_label = player.get_node("StateDebugLabel")
	var lines = player_label.text.split("\n")
	
	for line in lines:
		if line.begins_with("Soul"):
			soul_label.text = line
		elif line.begins_with("Scrap"):
			scrap_label.text = line
		elif line.begins_with("Food"):
			food_label.text = line
