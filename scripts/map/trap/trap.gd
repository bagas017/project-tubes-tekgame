extends Node2D

# ==============================
# ===== Trap Type Enum =========
# ==============================
enum TrapType { STILL, HIDE, FALL }

@export var trap_type: TrapType = TrapType.STILL   # tipe trap
@export var hide_offset: Vector2 = Vector2(0, -5)  # offset untuk hide
@export var fall_gravity: float = 600.0            # gravitasi untuk fall
@export var active: bool = true                    # aktif / nonaktif
@export var damage: int = 10                       # damage yang diberikan

# ==============================
# ===== Node Reference =========
# ==============================
@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var detection: Area2D = $DetectionArea

# ===== Internal Var ===========
var default_position: Vector2
var is_triggered: bool = false
var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	default_position = global_position
	
	# Setup posisi awal
	if trap_type == TrapType.HIDE:
		global_position = default_position + hide_offset
	if trap_type == TrapType.FALL:
		velocity = Vector2.ZERO

	# masukin ke group biar gampang direset massal
	add_to_group("trap")
	hitbox.add_to_group("enemy_hitbox")

	# Connect signal
	detection.body_entered.connect(_on_detection_body_entered)

func _physics_process(delta: float) -> void:
	if not active:
		return

	match trap_type:
		TrapType.STILL:
			pass

		TrapType.HIDE:
			if is_triggered and global_position != default_position:
				global_position = default_position
				is_triggered = false

		TrapType.FALL:
			if is_triggered:
				velocity.y += fall_gravity * delta
				global_position.y += velocity.y * delta

func _on_detection_body_entered(body: Node) -> void:
	if not active:
		return
	if body.is_in_group("player"):
		is_triggered = true

# Getter damage
func get_damage() -> int:
	return damage

# Reset trap ke posisi default (dipanggil saat player respawn)
func reset_trap() -> void:
	is_triggered = false
	velocity = Vector2.ZERO

	match trap_type:
		TrapType.STILL:
			global_position = default_position
		
		TrapType.HIDE:
			# kembali sembunyi
			global_position = default_position + hide_offset
		
		TrapType.FALL:
			# kembali ke atas
			global_position = default_position
