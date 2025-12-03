extends Node

# ==============================
# ===== CONSTANTS ==============
# ==============================
const SPEED = 130.0              # Kecepatan gerakan horizontal normal
const JUMP_VELOCITY = -300.0     # Kecepatan awal saat melompat
const ROLL_SPEED = 250.0         # Kecepatan roll/dash
const ROLL_TIME = 0.35           # Durasi roll dalam detik

# ==============================
# ===== VARIABLES ==============
# ==============================
var roll_timer: float = 0.0      # Timer sisa roll
var facing_dir: int = 1          # Arah hadap player (1 = kanan, -1 = kiri)

# Jump system
var max_jumps: int = 2           # Maksimal jumlah lompatan (double jump = 2)
var jump_count: int = 0          # Jumlah lompatan yang sudah dipakai
var from_wall_jump: bool = false # True kalau lompatan berasal dari wall jump

# Wall system
var is_on_wall: bool = false     # True kalau player nempel di dinding
var wall_dir: int = 0            # Arah dinding yang ditempel (-1 = kiri, 1 = kanan)
var last_wall_dir: int = 0       # Untuk mencegah spam wall jump bolak-balik
var can_wall_jump: bool = true   # Apakah bisa wall jump lagi


# ==============================
# ===== UPDATE LOOP ============
# ==============================
func update(player, delta: float) -> void:
	# 🚫 Jangan proses input/movement kalau player DEAD atau SPAWN
	if player.current_state in [player.PlayerState.DEAD, player.PlayerState.SPAWN]:
		return


	# Terapkan gravitasi, cek wall, handle input, update state
	apply_gravity(player, delta)
	check_wall(player)
	handle_input(player, delta)
	update_state(player, delta)

	# Reset lompatan kalau menyentuh lantai
	if player.is_on_floor():
		jump_count = 0
		last_wall_dir = 0
		can_wall_jump = true
		from_wall_jump = false

	# Kalau tidak lagi di wall → izinkan wall jump lagi
	if not is_on_wall:
		can_wall_jump = true


# ==============================
# ===== MOVEMENT LOGIC =========
# ==============================
func apply_gravity(player, delta: float) -> void:
	# Tambahkan gravitasi kalau tidak di lantai
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta


func check_wall(player) -> void:
	# Reset flag wall
	is_on_wall = false
	wall_dir = 0
	
	# Cek RayCast kiri/kanan → hanya aktif kalau tidak di lantai
	if player.wall_check_left.is_colliding() and not player.is_on_floor():
		is_on_wall = true
		wall_dir = -1
	elif player.wall_check_right.is_colliding() and not player.is_on_floor():
		is_on_wall = true
		wall_dir = 1


func handle_input(player, delta: float) -> void:
	# ====== ROLL / DASH ======
	if Input.is_action_just_pressed("dash") \
	and player.current_state not in [player.PlayerState.ROLL, player.PlayerState.HURT, player.PlayerState.DEAD]:
		start_roll(player)
	
	# Kalau sedang roll → hitung timer & gerakkan
	if player.current_state == player.PlayerState.ROLL:
		roll_timer -= delta
		if roll_timer > 0:
			player.velocity.x = facing_dir * ROLL_SPEED
		else:
			end_roll(player)
		return  # 🚫 Selama roll, input lain diabaikan

	# 🚫 Saat ATTACK, HURT, DEAD → input gerakan diabaikan
	if player.current_state in [player.PlayerState.ATTACK, player.PlayerState.HURT, player.PlayerState.DEAD]:
		return

	# ====== INPUT GERAKAN HORIZONTAL ======
	var direction := Input.get_axis("move_left", "move_right")

	# ====== WALL SLIDE ======
	if is_on_wall and player.velocity.y > 0 and direction == wall_dir:
		# Batasin kecepatan jatuh supaya sliding pelan
		player.velocity.y = min(player.velocity.y, 30)
		player.current_state = player.PlayerState.WALL_SLIDE

	# ====== JUMP ======
	if Input.is_action_just_pressed("jump"):
		if player.is_on_floor():
			# Normal jump
			player.velocity.y = JUMP_VELOCITY
			jump_count = 1
			from_wall_jump = false
			
			player.sfx_jump.play()

		elif is_on_wall and can_wall_jump and wall_dir != last_wall_dir:
			# Wall jump
			player.velocity.y = JUMP_VELOCITY
			player.velocity.x = -wall_dir * SPEED * 1.2
			facing_dir = -wall_dir
			player.animated_sprite_2d.flip_h = (facing_dir < 0)

			last_wall_dir = wall_dir
			can_wall_jump = false
			from_wall_jump = true
			jump_count = 1
			
			player.sfx_wall_jump.play()

		elif not is_on_wall and jump_count < max_jumps and not from_wall_jump:
			if player.stamina.has_stamina(player.stamina.COST_DOUBLE_JUMP):
				player.velocity.y = JUMP_VELOCITY
				jump_count = 2
				player.stamina.consume(player.stamina.COST_DOUBLE_JUMP)
				
				player.sfx_double_jump.play()


	# ====== GERAKAN KIRI / KANAN ======
	if direction != 0:
		facing_dir = direction
		player.animated_sprite_2d.flip_h = (direction < 0)
		player.velocity.x = direction * SPEED
	elif not is_on_wall:
		# Perlahan berhenti kalau tidak ada input
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)


# ==============================
# ===== STATE UPDATE ===========
# ==============================
func update_state(player, delta: float) -> void:
	# 🚫 Jangan ubah state kalau sedang roll, attack, hurt, atau dead
	if player.current_state in [player.PlayerState.ROLL, player.PlayerState.ATTACK, player.PlayerState.HURT, player.PlayerState.DEAD, player.PlayerState.SPAWN, player.PlayerState.EAT]:
		return

	# Wall slide → balik ke fall kalau lepas wall atau menyentuh lantai
	if player.current_state == player.PlayerState.WALL_SLIDE:
		if not is_on_wall or player.is_on_floor():
			player.current_state = player.PlayerState.FALL
		return

	# Cek kondisi untuk state lain
	if not player.is_on_floor():
		if player.velocity.y < 0:
			player.current_state = player.PlayerState.JUMP
		else:
			player.current_state = player.PlayerState.FALL
	elif abs(player.velocity.x) > 0.1:
		player.current_state = player.PlayerState.RUN
	else:
		player.current_state = player.PlayerState.IDLE


# ==============================
# ===== ROLL SYSTEM ============
# ==============================
func start_roll(player):
	if not player.stamina.has_stamina(player.stamina.COST_ROLL):
		return  # 🚫 Batal roll kalau stamina kurang

	player.stamina.consume(player.stamina.COST_ROLL)

	player.current_state = player.PlayerState.ROLL
	roll_timer = ROLL_TIME

	# Aktifkan roll immunity (invincible frame saat roll)
	if player.has_node("PlayerHealth"):
		player.health.start_roll_immunity(ROLL_TIME)

	# Mainkan animasi dash (diatur PlayerAnimation agar tidak restart tiap frame)
	player.animated_sprite_2d.play("dash")
	player.sfx_dash.play()


func end_roll(player):
	roll_timer = 0.0

	# Setelah roll selesai, tentukan state kembali
	if player.is_on_floor():
		player.current_state = player.PlayerState.IDLE
	else:
		player.current_state = player.PlayerState.FALL
