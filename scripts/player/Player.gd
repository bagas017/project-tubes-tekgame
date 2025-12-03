extends CharacterBody2D

# ==============================
# ===== STATE MACHINE ==========
# ==============================
enum PlayerState { IDLE, RUN, JUMP, FALL, WALL_SLIDE, ATTACK, HURT, ROLL, PARRY, DEAD, SPAWN, EAT }
var current_state: PlayerState = PlayerState.IDLE

# ==============================
# ===== NODE REFERENCE =========
# ==============================
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_label: Label = $StateDebugLabel
@onready var hurtbox: Area2D = $Hurtbox
@onready var wall_check_left: RayCast2D = $WallCheckLeft
@onready var wall_check_right: RayCast2D = $WallCheckRight

@onready var sfx_jump: AudioStreamPlayer2D = $sfx_jump
@onready var sfx_double_jump: AudioStreamPlayer2D = $sfx_double_jump
@onready var sfx_wall_jump: AudioStreamPlayer2D = $sfx_wall_jump
@onready var sfx_dash: AudioStreamPlayer2D = $sfx_dash
@onready var sfx_attack: AudioStreamPlayer2D = $sfx_attack
@onready var sfx_hurt: AudioStreamPlayer2D = $sfx_hurt
@onready var sfx_heal: AudioStreamPlayer2D = $sfx_heal
@onready var sfx_death: AudioStreamPlayer2D = $sfx_death



# ==============================
# ===== SUB-SYSTEMS ============
# ==============================
@onready var movement = $PlayerMovement
@onready var combat = $PlayerCombat
@onready var health = $PlayerHealth
@onready var anim = $PlayerAnimation
@onready var stamina = $PlayerStamina

# ==============================
# ===== RESPAWN SYSTEM =========
# ==============================
var respawn_position: Vector2

# ==============================
# ===== READY FUNCTION =========
# ==============================
func _ready() -> void:
	stamina.init(self)
	hurtbox.area_entered.connect(health._on_hurtbox_entered)
	health.init(self)

	health.max_hp = Global.max_hp
	health.hp = Global.hp
	health.food_count = Global.food_count

	animated_sprite_2d.animation_finished.connect(_on_animation_finished)

	respawn_position = global_position
	print("Respawn awal di:", respawn_position)

# ==============================
# ===== MAIN LOOP ==============
# ==============================
func _physics_process(delta: float) -> void:
	stamina.update(delta)

	if current_state == PlayerState.DEAD:
		velocity = Vector2.ZERO
		anim.update(self, delta)
		move_and_slide()
		update_debug()
		return

	movement.update(self, delta)
	combat.update(self, delta)
	health.update(delta)
	anim.update(self, delta)
	move_and_slide()
	update_debug()
	_sync_hud()


# ==============================
# ===== DEBUG INFO =============
# ==============================
func update_debug() -> void:
	state_label.text = (
		"Soul of Pongo: %d\nScrap of Abelii: %d\nFood: %d"
		% [
			GameManager.soul_count,
			GameManager.scrap_count,
			health.food_count
		]
	)
	
func _sync_hud() -> void:
	if has_node("/root/Main/UI/HUD"):
		var hud = get_node("/root/Main/UI/HUD")
		if hud.has_method("sync_from_player"):
			hud.sync_from_player(self)



	if has_node("/root/Main/UI/HUD"):
		var hud = get_node("/root/Main/UI/HUD")
		hud.update_health(health.hp)
		hud.health_bar.max_value = health.max_hp
		hud.update_stamina(stamina.stamina)
		hud.update_state(PlayerState.keys()[current_state])
		if hud.has_method("update_soul"):
			hud.update_soul(GameManager.soul_count)
		if hud.has_method("update_scrap"):
			hud.update_scrap(GameManager.scrap_count)
		if hud.has_method("update_food"):
			hud.update_food(GameManager.food_count)


# ==============================
# ===== RESPAWN METHODS ========
# ==============================
func set_respawn_position(pos: Vector2) -> void:
	respawn_position = pos
	print("Checkpoint aktif! Respawn position updated ke:", respawn_position)

func respawn() -> void:
	health.hp = health.max_hp
	stamina.reset()  # ⬅ ini reset stamina jadi penuh
	global_position = respawn_position + Vector2(0, -20)
	velocity = Vector2.ZERO
	current_state = PlayerState.SPAWN
	print("Player respawn di checkpoint:", global_position)
	get_tree().call_group("trap", "reset_trap")
	update_debug()


# ==============================
# ===== ANIMATION CALLBACK =====
# ==============================
func _on_animation_finished() -> void:
	if current_state == PlayerState.EAT:
		current_state = PlayerState.IDLE
		return

	if current_state == PlayerState.DEAD:
		# 🔥 Hanya Soul yang hilang saat mati (Scrap tetap aman)
		GameManager.lose_soul_on_death()
		respawn()
		update_debug()
		return

	if current_state == PlayerState.SPAWN:
		current_state = PlayerState.IDLE
		return

	if current_state == PlayerState.HURT:
		health.start_iframe()
		if is_on_floor():
			current_state = PlayerState.IDLE
		else:
			current_state = PlayerState.FALL
