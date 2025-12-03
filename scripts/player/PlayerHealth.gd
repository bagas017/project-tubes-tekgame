extends Node

# ==========================
# Variabel dasar HP dan Food Player
# ==========================
var max_hp: int = 10
var hp: int = 10
var food_count: int = 0

# ==========================
# Post-hurt iframe (invulnerability frame)
# ==========================
var iframe_timer: float = 0.0
const IFRAME_TIME: float = 1.5  # detik imun setelah kena hit

# ==========================
# Roll immunity (imun saat dash/roll)
# ==========================
var roll_immune_timer: float = 0.0

# ==========================
# Reference ke Player utama
# ==========================
var player

# ==========================
# Inisialisasi
# ==========================
func init(_player):
	player = _player
	hp = max_hp


# ==========================
# Update rutin
# ==========================
func update(delta: float):
	# ====== Handle Iframe ======
	if iframe_timer > 0.0:
		iframe_timer -= delta
		var blink = (int(iframe_timer * 10) % 2) == 0
		var c = player.animated_sprite_2d.modulate
		c.a = 0.4 if blink else 1.0
		player.animated_sprite_2d.modulate = c
	else:
		var c = player.animated_sprite_2d.modulate
		if c.a != 1.0:
			c.a = 1.0
			player.animated_sprite_2d.modulate = c

	# ====== Handle Roll Immunity ======
	if roll_immune_timer > 0.0:
		roll_immune_timer -= delta
		var c2 = player.animated_sprite_2d.modulate
		if c2.a != 1.0 and iframe_timer <= 0.0:
			c2.a = 1.0
			player.animated_sprite_2d.modulate = c2

	# ====== Input makan ======
	if Input.is_action_just_pressed("eat"):
		if try_eat():
			player.current_state = player.PlayerState.EAT


# ==========================
# Fungsi makan
# ==========================
func try_eat() -> bool:
	if food_count < 5:
		print("Belum cukup makanan.")
		return false

	food_count -= 5
	Global.food_count = food_count

	if hp < max_hp:
		hp = min(hp + 10, max_hp)
		Global.hp = hp
		
		# 🔊 MAIN SFX HEAL
		if player and player.sfx_heal:
			player.sfx_heal.play()
		
		print("Regen +10 HP:", hp, "/", max_hp)
	else:
		max_hp += 5
		hp = max_hp
		Global.hp = hp
		
		# 🔊 MAIN SFX HEAL
		if player and player.sfx_heal:
			player.sfx_heal.play()
		
		print("Max HP naik +5:", max_hp)
	return true


# ==========================
# Trigger damage
# ==========================
func _on_hurtbox_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hitbox"):
		var dmg := 1
		if area.has_method("get_damage"):
			dmg = int(area.get_damage())
		take_damage(dmg)


# ==========================
# Damage processing
# ==========================
func take_damage(amount: int) -> void:
	if iframe_timer > 0.0 or roll_immune_timer > 0.0 or player.current_state == player.PlayerState.HURT:
		return

	hp -= amount
	# 🔊 MAIN SFX HURT
	if player and player.sfx_hurt:
		player.sfx_hurt.play()
	
	if hp < 0:
		hp = 0
	Global.hp = hp

	if hp <= 0:
		player.current_state = player.PlayerState.DEAD
		player.velocity = Vector2.ZERO
		return

	player.current_state = player.PlayerState.HURT
	var kb_x = -player.movement.facing_dir * 120
	player.velocity.x = kb_x
	player.velocity.y = -120


# ==========================
# Immunity
# ==========================
func start_iframe() -> void:
	iframe_timer = IFRAME_TIME

func start_roll_immunity(duration: float) -> void:
	roll_immune_timer = 0.7 * duration


# ==========================
# Tambah makanan
# ==========================
func add_food(amount: int) -> void:
	food_count += amount
	Global.food_count = food_count
	GameManager.add_food(amount)
	print("Food dikumpulkan:", food_count)


# ==========================
# Instant Kill
# ==========================
func kill_instant() -> void:
	hp = 0
	player.current_state = player.PlayerState.DEAD
	player.velocity = Vector2.ZERO
	print("Player dibunuh instan (killzone / spike / void)")
