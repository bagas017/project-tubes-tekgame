extends CharacterBody2D

# ==============================
# ===== STATE MACHINE ==========
# ==============================
enum PlayerState { IDLE, RUN, JUMP, FALL, WALL_SLIDE, ATTACK, HURT, ROLL, PARRY, DEAD, SPAWN }
var current_state: PlayerState = PlayerState.IDLE

# ==============================
# ===== NODE REFERENCE =========
# ==============================
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D  # Sprite animasi utama
@onready var state_label: Label = $StateDebugLabel                    # Label debug untuk cek state
@onready var hurtbox: Area2D = $Hurtbox                               # Area untuk menerima serangan
@onready var wall_check_left: RayCast2D = $WallCheckLeft              # RayCast untuk cek wall kiri
@onready var wall_check_right: RayCast2D = $WallCheckRight            # RayCast untuk cek wall kanan

# ==============================
# ===== SUB-SYSTEMS ============
# ==============================
# Sistem modular supaya rapi: movement, combat, health, animasi dipisah script
@onready var movement = $PlayerMovement
@onready var combat = $PlayerCombat
@onready var health = $PlayerHealth
@onready var anim = $PlayerAnimation
@onready var stamina = $PlayerStamina


# ==============================
# ===== RESPAWN SYSTEM =========
# ==============================
# Posisi checkpoint tempat respawn player
var respawn_position: Vector2

# ==============================
# ===== READY FUNCTION =========
# ==============================
func _ready() -> void:
	stamina.init(self)
	
	# Saat hurtbox kena serangan → panggil PlayerHealth
	hurtbox.area_entered.connect(health._on_hurtbox_entered)

	# Inisialisasi health dengan referensi ke player (sekali saja)
	health.init(self)

	# Jika animasi selesai → panggil callback (misalnya selesai hurt, dead, dll)
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)

	# Set respawn awal di posisi spawn scene
	respawn_position = global_position
	print("Respawn awal di:", respawn_position)


# ==============================
# ===== MAIN LOOP ==============
# ==============================
func _physics_process(delta: float) -> void:
	stamina.update(delta)
	
	# ========== Kondisi khusus DEAD ==========
	if current_state == PlayerState.DEAD:
		# Hentikan semua gerakan
		velocity = Vector2.ZERO

		# Optional: health masih bisa update timer Iframe / respawn counter
		# health.update(delta)

		# Penting: animasi tetap jalan agar anim "dead" dimainkan
		anim.update(self, delta)

		# Jalankan physics minimal (biar posisi sprite tetap benar)
		move_and_slide()

		# Update debug label
		update_debug()
		return

	# ========== Urutan update normal ==========
	# Update movement (jalan, lompat, wall slide, dll)
	movement.update(self, delta)

	# Update combat (attack, parry, roll)
	combat.update(self, delta)

	# Update health (hp, iframe, damage check)
	health.update(delta)

	# Update animasi sesuai state
	anim.update(self, delta)

	# Apply physics
	move_and_slide()

	# Debug info (state + HP)
	update_debug()


# ==============================
# ===== DEBUG INFO =============
# ==============================
func update_debug() -> void:
	# Tampilkan state sekarang, HP, dan Stamina player di label debug
	state_label.text = "State: %s | HP: %d | Stamina: %d" % [
		PlayerState.keys()[current_state],
		health.hp,
		stamina.stamina  # akses nilai stamina dari PlayerStamina.gd
	]



# ==============================
# ===== RESPAWN METHODS ========
# ==============================
# Dipanggil dari Checkpoint.gd ketika player menyentuh checkpoint
func set_respawn_position(pos: Vector2) -> void:
	respawn_position = pos
	print("Checkpoint aktif! Respawn position updated ke:", respawn_position)


# Respawn player ke checkpoint terakhir
func respawn() -> void:
	# Reset HP
	health.hp = health.max_hp

	# Spawn di atas checkpoint (biar jatuh)
	var spawn_offset := Vector2(0, -20)  # ✨ atur ketinggian sesuai selera
	global_position = respawn_position + spawn_offset

	# Reset velocity → biar player diam saat animasi spawn
	velocity = Vector2.ZERO

	# Set state ke SPAWN
	current_state = PlayerState.SPAWN
	print("Player respawn di checkpoint (melayang):", global_position)
	
	# Reset semua trap
	get_tree().call_group("trap", "reset_trap")





# ==============================
# ===== ANIMATION CALLBACK =====
# ==============================
func _on_animation_finished() -> void:
	# Jika animasi dead selesai → panggil respawn (ubah ke state SPAWN)
	if current_state == PlayerState.DEAD:
		respawn()
		return

	# Jika animasi spawn selesai → player kembali ke IDLE
	if current_state == PlayerState.SPAWN:
		current_state = PlayerState.IDLE
		return

	# Jika animasi hurt selesai
	if current_state == PlayerState.HURT:
		health.start_iframe()
		if is_on_floor():
			current_state = PlayerState.IDLE
		else:
			current_state = PlayerState.FALL
