extends Node

# ==========================
# Variabel dasar HP Player
# ==========================
var max_hp: int = 100      # HP maksimal
var hp: int = 100          # HP saat ini

# ==========================
# Post-hurt iframe (invulnerability frame)
# ==========================
var iframe_timer: float = 0.0
const IFRAME_TIME: float = 1.5  # durasi imun setelah terkena hit (dalam detik)

# ==========================
# Roll immunity (imun saat dash/roll)
# ==========================
var roll_immune_timer: float = 0.0

# ==========================
# Reference ke Player utama
# ==========================
var player   # nanti di-assign lewat init()


# Inisialisasi health system dengan player target
func init(_player):
	player = _player
	hp = max_hp


# Update rutin setiap frame (dipanggil dari Player.gd)
func update(delta: float):
	# ============ Handle Iframe (kedip ketika baru kena hit) ============
	if iframe_timer > 0.0:
		iframe_timer -= delta
		# bikin efek blinking: kedip tiap 0.1 detik
		var blink = (int(iframe_timer * 10) % 2) == 0
		var c = player.animated_sprite_2d.modulate
		c.a = 0.4 if blink else 1.0
		player.animated_sprite_2d.modulate = c
	else:
		# kalau sudah tidak dalam iframe, pastikan alpha balik normal
		var c = player.animated_sprite_2d.modulate
		if c.a != 1.0:
			c.a = 1.0
			player.animated_sprite_2d.modulate = c

	# ============ Handle Roll Immunity (tanpa kedip) ============
	if roll_immune_timer > 0.0:
		roll_immune_timer -= delta
		# selama roll immunity aktif -> pastikan alpha normal
		var c2 = player.animated_sprite_2d.modulate
		if c2.a != 1.0 and iframe_timer <= 0.0:
			c2.a = 1.0
			player.animated_sprite_2d.modulate = c2


# Triggered ketika hurtbox player kena serang enemy
func _on_hurtbox_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hitbox"):  # pastikan yang masuk hitbox musuh
		var dmg := 1
		# kalau enemy punya fungsi get_damage(), ambil damage dari sana
		if area.has_method("get_damage"):
			dmg = int(area.get_damage())
		take_damage(dmg)


# Proses damage masuk ke player
func take_damage(amount: int) -> void:
	# kalau masih iframe / roll immune / sedang animasi hurt -> abaikan
	if iframe_timer > 0.0 or roll_immune_timer > 0.0 or player.current_state == player.PlayerState.HURT:
		return

	# kurangi HP
	hp -= amount
	if hp < 0:
		hp = 0
	print("Player HP:", hp)

	# kalau HP habis -> state DEAD, stop gerakan
	if hp <= 0:
		player.current_state = player.PlayerState.DEAD
		player.velocity = Vector2.ZERO
		return  # keluar, jangan masuk HURT lagi

	# kalau masih hidup -> masuk state HURT
	player.current_state = player.PlayerState.HURT

	# kasih knockback kecil ke arah berlawanan dari facing
	var kb_x = -player.movement.facing_dir * 120
	player.velocity.x = kb_x
	player.velocity.y = -120  # knockback ke atas sedikit


# Dipanggil saat animasi hurt selesai -> mulai iframe
func start_iframe() -> void:
	iframe_timer = IFRAME_TIME


# Dipanggil saat player mulai roll/dash -> kasih immunity tanpa kedip
func start_roll_immunity(duration: float) -> void:
	roll_immune_timer = duration


# ==========================
# Instant Kill Method (baru)
# ==========================
# Fungsi ini dipakai oleh Killzone (lava, void, spike, dll.)
# Bypass semua sistem imun (iframe & roll immunity)
# Langsung set HP = 0 dan state = DEAD
func kill_instant() -> void:
	hp = 0
	player.current_state = player.PlayerState.DEAD
	player.velocity = Vector2.ZERO
	print("Player dibunuh instan (killzone / spike / void)")
