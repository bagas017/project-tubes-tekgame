extends CharacterBody2D

# ====== KONSTANTA ======
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const ROLL_SPEED = 250.0
const ROLL_TIME = 0.35
const IFRAME_TIME = 0.25

# ====== STATE MACHINE ======
enum PlayerState { IDLE, RUN, JUMP, FALL, WALL_SLIDE, ATTACK, HURT, ROLL, PARRY, DEAD }
var current_state: PlayerState = PlayerState.IDLE

# ====== PLAYER STATUS ======
var max_hp: int = 5
var hp: int = 5
var roll_timer: float = 0.0
var iframe_timer: float = 0.0
var facing_dir: int = 1

# ====== JUMP SYSTEM ======
var max_jumps: int = 2
var jump_count: int = 0
var from_wall_jump: bool = false

# ====== WALL JUMP ======
var is_on_wall: bool = false
var wall_dir: int = 0        # -1 = kiri, 1 = kanan
var last_wall_dir: int = 0   # sisi wall terakhir dipakai lompat
var can_wall_jump: bool = true

# ====== NODE REFERENCE ======
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_label: Label = $StateDebugLabel
@onready var hurtbox: Area2D = $Hurtbox
@onready var wall_check_left: RayCast2D = $WallCheckLeft
@onready var wall_check_right: RayCast2D = $WallCheckRight

func _ready() -> void:
	hurtbox.area_entered.connect(_on_hurtbox_entered)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	check_wall()
	handle_input(delta)
	update_state(delta)
	apply_animation()
	update_debug()
	move_and_slide()

	# reset jump kalau di lantai
	if is_on_floor():
		jump_count = 0
		last_wall_dir = 0
		can_wall_jump = true
		from_wall_jump = false

	# reset wall jump saat lepas dari wall
	if not is_on_wall:
		can_wall_jump = true

# ====== INPUT & MOVEMENT ======
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
# === Detect Wall ===
func check_wall() -> void:
	is_on_wall = false
	wall_dir = 0
	
	if wall_check_left.is_colliding() and not is_on_floor():
		is_on_wall = true
		wall_dir = -1
	elif wall_check_right.is_colliding() and not is_on_floor():
		is_on_wall = true
		wall_dir = 1

func handle_input(delta: float) -> void:
	# dash / roll
	if Input.is_action_just_pressed("dash") and current_state != PlayerState.ROLL:
		start_roll()
	
	if current_state == PlayerState.ROLL:
		roll_timer -= delta
		if roll_timer > 0:
			velocity.x = facing_dir * ROLL_SPEED
			if iframe_timer > 0:
				iframe_timer -= delta
		else:
			end_roll()
		return

	# arah gerakan
	var direction := Input.get_axis("move_left", "move_right")

	# ====== WALL SLIDE ======
	if is_on_wall and velocity.y > 0 and direction == wall_dir:
		velocity.y = min(velocity.y, 60)
		current_state = PlayerState.WALL_SLIDE

	# ====== JUMP ======
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			# Normal Jump
			velocity.y = JUMP_VELOCITY
			jump_count = 1
			from_wall_jump = false

		elif is_on_wall and can_wall_jump and wall_dir != last_wall_dir:
			# Wall Jump valid
			velocity.y = JUMP_VELOCITY
			velocity.x = -wall_dir * SPEED * 1.2
			facing_dir = -wall_dir
			animated_sprite_2d.flip_h = (facing_dir < 0)

			# setup flag wall jump
			last_wall_dir = wall_dir
			can_wall_jump = false
			from_wall_jump = true
			jump_count = 1  # setelah wall jump, anggap sudah 1x lompat

		elif not is_on_wall and jump_count < max_jumps:
			# Double jump hanya aktif kalau BUKAN di wall
			velocity.y = JUMP_VELOCITY
			jump_count += 1
			from_wall_jump = false

		elif from_wall_jump and jump_count < max_jumps:
			# Allow double jump setelah wall jump
			velocity.y = JUMP_VELOCITY
			jump_count += 1
			from_wall_jump = false

	# ====== MOVE LEFT/RIGHT ======
	if direction != 0:
		facing_dir = direction
		animated_sprite_2d.flip_h = (direction < 0)
		velocity.x = direction * SPEED
	elif not is_on_wall:
		velocity.x = move_toward(velocity.x, 0, SPEED)

# ====== STATE ======
func update_state(delta: float) -> void:
	if current_state == PlayerState.ROLL:
		return
	
	if current_state == PlayerState.WALL_SLIDE:
		if not is_on_wall or is_on_floor():
			current_state = PlayerState.FALL
		return
	
	if not is_on_floor():
		if velocity.y < 0:
			current_state = PlayerState.JUMP
		else:
			current_state = PlayerState.FALL
	elif abs(velocity.x) > 0.1:
		current_state = PlayerState.RUN
	else:
		current_state = PlayerState.IDLE

func start_roll():
	current_state = PlayerState.ROLL
	roll_timer = ROLL_TIME
	iframe_timer = IFRAME_TIME
	animated_sprite_2d.play("dash")

func end_roll():
	if is_on_floor():
		current_state = PlayerState.IDLE
	else:
		current_state = PlayerState.FALL

# ====== DAMAGE SYSTEM ======
func _on_hurtbox_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hitbox"):
		take_damage(1)

func take_damage(amount: int) -> void:
	if iframe_timer > 0 or current_state == PlayerState.ROLL:
		return
	
	hp -= amount
	print("Player HP:", hp)
	
	if hp <= 0:
		current_state = PlayerState.DEAD
	else:
		current_state = PlayerState.HURT

# ====== ANIMATION ======
func apply_animation() -> void:
	match current_state:
		PlayerState.IDLE:
			animated_sprite_2d.play("default_idle")
		PlayerState.RUN:
			animated_sprite_2d.play("run")
		PlayerState.JUMP, PlayerState.FALL:
			if jump_count == 2:
				animated_sprite_2d.play("double_jump")
			else:
				animated_sprite_2d.play("jump")
		PlayerState.WALL_SLIDE:
			animated_sprite_2d.play("wall_slide")
		PlayerState.ROLL:
			animated_sprite_2d.play("dash")
		PlayerState.HURT:
			animated_sprite_2d.play("hurt")
		PlayerState.DEAD:
			animated_sprite_2d.play("dead")

# ====== DEBUG ======
func update_debug() -> void:
	var inv = "ON" if iframe_timer > 0 else "OFF"
	state_label.text = "HP: %d | State: %s | IFrame: %s | Jumps: %d/%d | WallDir: %d | LastWall: %d | CanWall: %s | FromWall: %s" % [
		hp,
		PlayerState.keys()[current_state],
		inv,
		jump_count,
		max_jumps,
		wall_dir,
		last_wall_dir,
		str(can_wall_jump),
		str(from_wall_jump)
	]
