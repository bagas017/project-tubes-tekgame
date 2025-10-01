extends CharacterBody2D

# ==============================
# ===== Enemy State System =====
# ==============================
enum EnemyState { IDLE, CHASE, ATTACK, HURT, DEAD }
var current_state: EnemyState = EnemyState.IDLE

# ==============================
# ===== Exported Variables =====
# ==============================
@export var hp: int = 100                 # Darah musuh
@export var move_speed: float = 80.0      # Kecepatan saat chase
@export var attack_range: float = 23.0    # Jarak serang
@export var gravity: float = 20.0         # Gravitasi musuh

# 🔹 Toggle patrol (true = jalan bolak balik otomatis, false = diam)
@export var can_patrol: bool = true       

# 🔹 Damage serangan melee (bisa diatur per EnemyA di Inspector)
@export var attack_damage: int = 10    
   

# ==============================
# ===== Node References ========
# ==============================
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_label: Label = $StateDebugLabel
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var attack_windup: Timer = $AttackWindup
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var hitbox_timer: Timer = $HitboxTimer

# ==============================
# ===== Internal Variables =====
# ==============================
var target: Node2D = null                     # Target (player)
var knockback: Vector2 = Vector2.ZERO         # Knockback vector
var knockback_decay: float = 300.0            # Seberapa cepat knockback habis
var facing_dir: int = 1                       # -1 = kiri, 1 = kanan

# Untuk debug label (biar angka state = tulisan)
const STATE_NAMES = {
	EnemyState.IDLE: "IDLE",
	EnemyState.CHASE: "CHASE",
	EnemyState.ATTACK: "ATTACK",
	EnemyState.HURT: "HURT",
	EnemyState.DEAD: "DEAD",
}

# ==============================
# ====== READY FUNCTION ========
# ==============================
func _ready() -> void:
	# Hubungkan detection area → chase/idle
	detection_area.body_entered.connect(_on_body_entered_detection)
	detection_area.body_exited.connect(_on_body_exited_detection)

	# Hubungkan timer attack
	attack_windup.timeout.connect(_on_attack_windup_finished)
	attack_cooldown.timeout.connect(_on_attack_cooldown_finished)
	hitbox_timer.timeout.connect(_on_hitbox_timeout)

	# Hubungkan hitbox serangan → damage ke player
	attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)

	# Awal hitbox serangan non-aktif
	attack_hitbox.monitoring = false
	attack_hitbox.set_deferred("monitoring", false)

# ==============================
# ====== MAIN LOOP =============
# ==============================
func _physics_process(delta: float) -> void:
	# Terapkan gravitasi
	velocity.y += gravity * delta

	match current_state:
		EnemyState.IDLE:
			velocity.x = 0

			# Patrol aktif kalau toggle on
			if can_patrol:
				_patrol_move(delta)
			else:
				anim.play("idle")

		EnemyState.CHASE:
			if target and is_instance_valid(target):
				# Tentukan arah ke player
				var dir = sign(target.global_position.x - global_position.x)
				facing_dir = dir if dir != 0 else facing_dir
				_update_facing()

				# Bergerak ke arah player
				velocity.x = dir * move_speed
				anim.play("run")

				# Kalau sudah cukup dekat → ganti state ke ATTACK
				if global_position.distance_to(target.global_position) <= attack_range:
					_change_state(EnemyState.ATTACK)
			else:
				_change_state(EnemyState.IDLE)

		EnemyState.ATTACK:
			velocity.x = 0
			# Mulai animasi attack hanya jika cooldown & windup selesai
			if attack_cooldown.is_stopped() and attack_windup.is_stopped():
				anim.play("attack_windup")
				attack_windup.start()

		EnemyState.HURT:
			anim.play("hurt")

			# Apply knockback
			if knockback.length() > 0.1:
				velocity.x = knockback.x
				knockback = knockback.move_toward(Vector2.ZERO, knockback_decay * delta)
			else:
				# Kalau masih ada target → balik chase
				if target and is_instance_valid(target):
					_change_state(EnemyState.CHASE)
				else:
					_change_state(EnemyState.IDLE)

		EnemyState.DEAD:
			velocity.x = 0
			anim.play("dead")
			queue_free()  # hapus musuh dari scene

	move_and_slide()
	state_label.text = STATE_NAMES.get(current_state, "UNKNOWN")

# ==============================
# ===== Damage System ==========
# ==============================
func take_damage(amount: int) -> void:
	if current_state == EnemyState.DEAD:
		return
	hp -= amount
	if hp <= 0:
		_change_state(EnemyState.DEAD)
	else:
		_change_state(EnemyState.HURT)

func apply_knockback(force: Vector2) -> void:
	knockback = force
	
# === Public getter supaya anak (hitbox) bisa minta damage ini ===
func get_attack_damage() -> int:
	return attack_damage

# ==============================
# ===== State Change ===========
# ==============================
func _change_state(new_state: EnemyState) -> void:
	current_state = new_state

# ==============================
# ===== Detection Area =========
# ==============================
func _on_body_entered_detection(body: Node2D) -> void:
	if body.is_in_group("player_body"):
		target = body
		_change_state(EnemyState.CHASE)

func _on_body_exited_detection(body: Node2D) -> void:
	if body == target:
		target = null
		_change_state(EnemyState.IDLE)

# ==============================
# ===== Facing Update ==========
# ==============================
func _update_facing() -> void:
	if facing_dir == 1:
		anim.flip_h = false
		attack_hitbox.position = Vector2(6, 3)
	elif facing_dir == -1:
		anim.flip_h = true
		attack_hitbox.position = Vector2(-6, 3)

# ==============================
# ===== Hitbox Control =========
# ==============================
func enable_hitbox() -> void:
	attack_hitbox.monitoring = true
	hitbox_timer.start(0.2)  # aktif 0.2 detik

func _on_hitbox_timeout() -> void:
	attack_hitbox.monitoring = false

# Ketika hitbox mengenai player → berikan damage
func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_body") and body.has_method("take_damage"):
		print("[EnemyA] Hit Player, damage:", attack_damage)
		body.take_damage(attack_damage)

# ==============================
# ===== Attack Timers ==========
# ==============================
func _on_attack_windup_finished() -> void:
	anim.play("attack")
	enable_hitbox()
	attack_cooldown.start(1.0) # jeda sebelum serang lagi

func _on_attack_cooldown_finished() -> void:
	if target and is_instance_valid(target):
		if global_position.distance_to(target.global_position) <= attack_range:
			_change_state(EnemyState.ATTACK)
		else:
			_change_state(EnemyState.CHASE)
	else:
		_change_state(EnemyState.IDLE)

# ============================================
# ======== Otomatis Check Wall System ========
# ============================================
@onready var check_wall_left: RayCast2D = $CheckWallLeft
@onready var check_wall_right: RayCast2D = $CheckWallRight

var patrol_speed: float = 40.0
var patrol_direction: int = -1   # -1 = kiri, 1 = kanan

func _patrol_move(delta: float) -> void:
	# Gerak sesuai arah patrol
	velocity.x = patrol_direction * patrol_speed

	# Update facing_dir supaya sprite & hitbox flip
	facing_dir = patrol_direction
	_update_facing()

	# Mainkan animasi run
	anim.play("run")

	# Kalau nabrak wall → putar balik
	if patrol_direction == -1 and check_wall_left.is_colliding():
		patrol_direction = 1
	elif patrol_direction == 1 and check_wall_right.is_colliding():
		patrol_direction = -1
# ============================================
# ======== End Otomatis Check Wall System =====
# ============================================
