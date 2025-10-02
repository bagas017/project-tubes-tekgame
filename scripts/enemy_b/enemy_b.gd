extends CharacterBody2D

# ==============================
# ===== Enemy State System =====
# ==============================
enum EnemyState { IDLE, PATROL, AIM, ATTACK, HURT, DEAD }
var current_state: EnemyState = EnemyState.IDLE
var aim_substate: String = ""   # substate tambahan untuk AIM (WINDUP / ATTACK)

# ==============================
# ===== Exported Variables =====
# ==============================
@export var hp: int = 80
@export var patrol_speed: float = 40.0
@export var gravity: float = 20.0
@export var projectile_scene: PackedScene   # Scene projectile (diassign di inspector)
@export var attack_cooldown_time: float = 1.5
@export var windup_time: float = 0.7
@export var projectile_damage: int = 5      # damage projectile
@export var knockback_decay: float = 300.0
@export var death_remove_time: float = 0.5

@export var can_patrol: bool = true   # toggle patrol

# ==============================
# ===== Node References ========
# ==============================
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_label: Label = $StateDebugLabel
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var attack_windup: Timer = $AttackWindup
@onready var spawn_point: Marker2D = $ProjectileSpawn
@onready var line_of_sight: RayCast2D = $LineOfSight
@onready var check_wall_left: RayCast2D = $CheckWallLeft
@onready var check_wall_right: RayCast2D = $CheckWallRight

# ==============================
# ===== Internal Variables =====
# ==============================
var target: Node2D = null
var facing_dir: int = -1   # -1 = kiri, 1 = kanan
var knockback: Vector2 = Vector2.ZERO

const STATE_NAMES = {
	EnemyState.IDLE: "IDLE",
	EnemyState.PATROL: "PATROL",
	EnemyState.AIM: "AIM",
	EnemyState.ATTACK: "ATTACK",
	EnemyState.HURT: "HURT",
	EnemyState.DEAD: "DEAD",
}

# ==============================
# ====== READY FUNCTION ========
# ==============================
func _ready() -> void:
	#print("[EnemyB] Ready. Projectile scene: ", projectile_scene)
	detection_area.body_entered.connect(_on_body_entered_detection)
	detection_area.body_exited.connect(_on_body_exited_detection)
	attack_windup.timeout.connect(_on_attack_windup_finished)
	attack_cooldown.timeout.connect(_on_attack_cooldown_finished)
	line_of_sight.enabled = true   # pastikan aktif

# ==============================
# ====== MAIN LOOP =============
# ==============================
func _physics_process(delta: float) -> void:
	# Tambahkan gravitasi
	velocity.y += gravity * delta

	# 🔧 Continuous check line of sight tiap frame
	if target and is_instance_valid(target):
		if _has_line_of_sight():
			if current_state in [EnemyState.IDLE, EnemyState.PATROL]:
				_change_state(EnemyState.AIM)
		else:
			if current_state == EnemyState.AIM:
				_change_state(EnemyState.IDLE)
				aim_substate = ""
	else:
		if current_state == EnemyState.AIM:
			_change_state(EnemyState.IDLE)
			aim_substate = ""

	# --- State Machine ---
	match current_state:
		EnemyState.IDLE:
			velocity.x = 0
			if can_patrol:
				_patrol_move(delta)
			else:
				anim.play("idle")

		EnemyState.PATROL:
			if can_patrol:
				_patrol_move(delta)
			else:
				_change_state(EnemyState.IDLE)

		EnemyState.AIM:
			velocity.x = 0
			look_at_target()
			anim.play("aim")

			if attack_cooldown.is_stopped() and attack_windup.is_stopped():
				#print("[EnemyB] Mulai windup...")
				anim.play("windup")
				attack_windup.start(windup_time)
				aim_substate = "WINDUP"

		EnemyState.ATTACK:
			velocity.x = 0

		EnemyState.HURT:
			anim.play("hurt")
			if knockback.length() > 0.1:
				velocity.x = knockback.x
				knockback = knockback.move_toward(Vector2.ZERO, knockback_decay * delta)
			else:
				if target and is_instance_valid(target) and _has_line_of_sight():
					_change_state(EnemyState.AIM)
				else:
					_change_state(EnemyState.IDLE)

		EnemyState.DEAD:
			velocity.x = 0
			anim.play("dead")
			await get_tree().create_timer(death_remove_time).timeout
			queue_free()

	move_and_slide()

	# Debug label
	if current_state == EnemyState.AIM and aim_substate != "":
		state_label.text = STATE_NAMES.get(current_state, "UNKNOWN") + "+" + aim_substate
	else:
		state_label.text = STATE_NAMES.get(current_state, "UNKNOWN")

# ==============================
# ===== Damage System ==========
# ==============================
func take_damage(amount: int) -> void:
	if current_state == EnemyState.DEAD:
		return
	hp -= amount
	#print("[EnemyB] Kena damage. HP sekarang: ", hp)
	if hp <= 0:
		_change_state(EnemyState.DEAD)
	else:
		_change_state(EnemyState.HURT)

func apply_knockback(force: Vector2) -> void:
	knockback = force

func get_projectile_damage() -> int:
	return projectile_damage

# ==============================
# ===== State Change ===========
# ==============================
func _change_state(new_state: EnemyState) -> void:
	#print("[EnemyB] State berubah: ", STATE_NAMES.get(new_state))
	current_state = new_state

# ==============================
# ===== Detection Area =========
# ==============================
func _on_body_entered_detection(body: Node2D) -> void:
	if body.is_in_group("player_body"):
		#print("[EnemyB] Player masuk detection area.")
		target = body
		# ❌ Tidak langsung AIM → biarkan dicek tiap frame

func _on_body_exited_detection(body: Node2D) -> void:
	if body == target:
		#print("[EnemyB] Player keluar dari detection area.")
		target = null
		aim_substate = ""
		_change_state(EnemyState.IDLE)

# ==============================
# ===== Facing Update ==========
# ==============================
func _update_facing() -> void:
	if facing_dir == 1:
		anim.flip_h = false
	elif facing_dir == -1:
		anim.flip_h = true

# ==============================
# ===== Patrol System ==========
# ==============================
func _patrol_move(delta: float) -> void:
	velocity.x = patrol_speed * facing_dir
	_update_facing()
	anim.play("run")

	if facing_dir == -1 and check_wall_left.is_colliding():
		#print("[EnemyB] Tabrak kiri, balik kanan.")
		facing_dir = 1
	elif facing_dir == 1 and check_wall_right.is_colliding():
		#print("[EnemyB] Tabrak kanan, balik kiri.")
		facing_dir = -1

# ==============================
# ===== Attack System ==========
# ==============================
func look_at_target() -> void:
	if not target: return
	var dir = sign(target.global_position.x - global_position.x)
	if dir != 0:
		facing_dir = dir
	_update_facing()

func _has_line_of_sight() -> bool:
	if not target or not is_instance_valid(target):
		return false
	line_of_sight.target_position = to_local(target.global_position)
	line_of_sight.force_raycast_update()
	if not line_of_sight.is_colliding():
		return false
	var col = line_of_sight.get_collider()
	var clear = col == target
	#print("[EnemyB] Line of sight:", clear, " Collider:", col)
	return clear

func _on_attack_windup_finished() -> void:
	if target and is_instance_valid(target) and _has_line_of_sight():
		#print("[EnemyB] Windup selesai, menembak projectile.")
		anim.play("attack")
		_spawn_projectile()
		attack_cooldown.start(attack_cooldown_time)
		aim_substate = "ATTACK"
		_change_state(EnemyState.AIM)
	else:
		aim_substate = ""
		_change_state(EnemyState.IDLE)

func _on_attack_cooldown_finished() -> void:
	aim_substate = ""
	if target and is_instance_valid(target) and _has_line_of_sight():
		_change_state(EnemyState.AIM)
	else:
		_change_state(EnemyState.IDLE)

func _spawn_projectile() -> void:
	if projectile_scene == null:
		#print("[EnemyB] ERROR: projectile_scene belum di-assign di Inspector!")
		return
	if not target or not is_instance_valid(target):
		return

	# default ke posisi player
	var aim_position = target.global_position

	# kalau player punya AimPointBody, pakai itu
	if target.has_node("AimPointBody"):
		aim_position = target.get_node("AimPointBody").global_position

	# spawn projectile
	var proj = projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_position = spawn_point.global_position

	var dir = (aim_position - spawn_point.global_position).normalized()
	proj.call("setup", dir, projectile_damage)

	#print("[EnemyB] Projectile ditembak ke AimPointBody. Damage:", projectile_damage, " Arah:", dir)
