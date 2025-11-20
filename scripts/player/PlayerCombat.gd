extends Node

# ====== KONSTANTA ======
const ATTACK_DAMAGE: int = 10   # besar damage serangan

# Posisi relatif hitbox terhadap player (bisa diset via Inspector)
@export var attack_offset_right: float = 0.0   # offset saat hadap kanan
@export var attack_offset_left: float = -16.0  # offset saat hadap kiri

# Ukuran fallback (kalau CollisionShape2D tidak ada)
@export var attack_range_x: float = 16.0
@export var attack_range_y: float = 12.0

# ====== NODE REFERENCE ======
@onready var attack_hitbox: Area2D = get_parent().get_node("AttackHitbox")
@onready var active_timer: Timer = attack_hitbox.get_node("ActiveTimer")     # durasi aktif (damage window)
@onready var cooldown_timer: Timer = attack_hitbox.get_node("CooldownTimer") # durasi cooldown sebelum bisa menyerang lagi
@onready var animated_sprite: AnimatedSprite2D = get_parent().get_node("AnimatedSprite2D")

# Flag apakah boleh menyerang
var can_attack: bool = true


func _ready() -> void:
	# === Koneksi signal dari hitbox dan timer ===
	attack_hitbox.area_entered.connect(_on_attack_area_entered)
	attack_hitbox.area_exited.connect(_on_attack_area_exited) 
	active_timer.timeout.connect(_on_active_timeout)
	cooldown_timer.timeout.connect(_on_cooldown_timeout)

	# koneksi animasi
	animated_sprite.animation_finished.connect(_on_animation_finished)

	# debug print supaya tahu setting layer/mask dari hitbox
	print("AttackHitbox layer:", attack_hitbox.collision_layer, 
		  " mask:", attack_hitbox.collision_mask)

	# default: hitbox nonaktif
	attack_hitbox.monitoring = false


func update(player, delta: float) -> void:
	# Selalu sync posisi hitbox dengan arah hadap player
	update_hitbox_position(player)

	# Jika tombol attack ditekan dan bisa menyerang
	if Input.is_action_just_pressed("attack") and can_attack \
	and player.current_state != player.PlayerState.ROLL \
	and player.current_state != player.PlayerState.HURT \
	and player.current_state != player.PlayerState.DEAD:
		_start_attack(player)


# ====== HITBOX POSITIONING ======
func update_hitbox_position(player) -> void:
	# Geser hitbox sesuai arah player
	if player.movement.facing_dir == 1: # hadap kanan
		attack_hitbox.position.x = attack_offset_right
	else: # hadap kiri
		attack_hitbox.position.x = attack_offset_left


# ====== ATTACK START ======
func _start_attack(player) -> void:
	can_attack = false   # kunci dulu
	player.current_state = player.PlayerState.ATTACK

	# aktifkan hitbox untuk damage window singkat
	attack_hitbox.monitoring = true
	active_timer.start()     # kapan hitbox mati
	cooldown_timer.start()   # kapan boleh attack lagi

	# mainkan animasi attack
	animated_sprite.play("attack")
	
	# === MAIN SFX DI SINI ===
	player.sfx_attack.play()


# ====== DAMAGE HANDLING ======
func _on_attack_area_entered(area: Area2D) -> void:
	print(">>> AttackHitbox detect:", area.name, "Groups:", area.get_groups())

	# hanya musuh yang punya hurtbox (group "enemy_hurtbox") yang kena
	if area.is_in_group("enemy_hurtbox"):
		var enemy_root = area.get_parent()

		# kalau musuh punya method take_damage() -> panggil
		if enemy_root and enemy_root.has_method("take_damage"):
			enemy_root.take_damage(ATTACK_DAMAGE)
			_apply_enemy_knockback(enemy_root)

			# optional: hentikan player agar tidak "meluncur"
			var player = get_parent()
			if player:
				player.velocity.x = 0
		else:
			print("Enemy has no take_damage() method")


func _on_attack_area_exited(area: Area2D) -> void:
	# tidak perlu apa-apa (opsional kalau mau buat logika combo)
	pass


# ====== KNOCKBACK ENEMY ======
func _apply_enemy_knockback(enemy_root: Node) -> void:
	var player = get_parent()
	if not player or not enemy_root:
		return

	# arah knockback berdasarkan posisi relatif player <-> musuh
	var dir = sign(enemy_root.global_position.x - player.global_position.x)
	var knockback_force: float = 120.0

	# kalau musuh punya fungsi apply_knockback() gunakan itu
	if enemy_root.has_method("apply_knockback"):
		enemy_root.apply_knockback(Vector2(dir * knockback_force, 0))
	# fallback: kalau musuh adalah CharacterBody2D langsung set velocity
	elif enemy_root is CharacterBody2D:
		enemy_root.velocity.x = dir * knockback_force
	# fallback terakhir: geser paksa posisi
	else:
		enemy_root.global_position.x += dir * 4


# ====== TIMER CALLBACK ======
func _on_active_timeout() -> void:
	# matikan hitbox setelah damage window selesai
	attack_hitbox.monitoring = false

func _on_cooldown_timeout() -> void:
	# reset boleh attack lagi
	can_attack = true


# ====== ANIMATION CALLBACK ======
func _on_animation_finished() -> void:
	# setelah attack anim selesai → kembalikan state ke idle/fall
	if animated_sprite.animation == "attack":
		var player = get_parent()
		if player.is_on_floor():
			player.current_state = player.PlayerState.IDLE
		else:
			player.current_state = player.PlayerState.FALL
