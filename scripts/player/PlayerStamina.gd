extends Node

# ==============================
# ===== VARIABEL STAMINA =======
# ==============================
@export var max_stamina: float = 100.0   # Stamina maksimal
var stamina: float = 100.0               # Stamina saat ini

@export var regen_rate: float = 5.0     # Berapa stamina regen per detik

# Cost stamina untuk action
const COST_DOUBLE_JUMP: float = 5.0
const COST_ROLL: float = 15.0

# Reference ke player
var player

# ==============================
# ===== INIT ===================
# ==============================
func init(_player):
	player = _player
	stamina = max_stamina


# ==============================
# ===== UPDATE LOOP ============
# ==============================
func update(delta: float) -> void:
	# Regen stamina perlahan
	if stamina < max_stamina:
		stamina = min(max_stamina, stamina + regen_rate * delta)


# ==============================
# ===== STAMINA CONTROL ========
# ==============================
func has_stamina(cost: float) -> bool:
	return stamina >= cost

func consume(cost: float) -> void:
	stamina = max(0, stamina - cost)
	
func reset():
	stamina = max_stamina
