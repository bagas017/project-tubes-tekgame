extends Area2D
#Ini projectile terbaru banget 2025

# ==============================
# == Projectile Variables ======
# ==============================
var speed: float = 400.0               # kecepatan projectile
var direction: Vector2 = Vector2.ZERO  # arah tembak
var damage: int = 1                    # damage ke target

# ==============================
# == Node References ===========
# ==============================
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# ==============================
# == Setup Projectile ==========
# ==============================
func setup(_direction: Vector2, _damage: int) -> void:
	# Normalisasi arah agar kecepatan konsisten
	direction = _direction.normalized()
	damage = _damage
	rotation = direction.angle()  # 🔧 supaya sprite ikut arah
	print("[DEBUG] Projectile setup -> Direction:", direction, ", Damage:", damage)

func _ready() -> void:
	# Pastikan sinyal area_entered/body_entered terhubung
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	# Masukkan ke grup enemy_hitbox biar PlayerHealth bisa detect
	add_to_group("enemy_hitbox")

# ==============================
# == Update Loop ===============
# ==============================
func _process(delta: float) -> void:
	# Gerak lurus sesuai arah tanpa gravitasi
	position += direction * speed * delta

# ==============================
# == Collision (Area) ==========
# ==============================
func _on_area_entered(area: Area2D) -> void:
	print("[DEBUG] Projectile hit area:", area.name)

	# Jika nabrak hurtbox player, biarkan PlayerHealth yg proses damage
	if area.is_in_group("player_hurtbox"):
		call_deferred("queue_free")
	else:
		queue_free()

# ==============================
# == Collision (Body) ==========
# ==============================
func _on_body_entered(body: Node) -> void:
	print("[DEBUG] Projectile hit body:", body.name)

	# Kalau body bisa langsung kena damage
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
	elif body.get_parent() and body.get_parent().has_method("take_damage"):
		body.get_parent().take_damage(damage)
		queue_free()
	# 🔧 Kalau nabrak dinding/tembok/StaticBody → langsung hancur
	elif body is StaticBody2D or body is TileMap or body is TileMapLayer or body.is_in_group("wall"):
		print("[DEBUG] Projectile kena tembok → hancur")

		# aman: cek dulu sebelum akses
		if body.has_method("get_collision_layer"):
			print("[DEBUG] body:", body.name, 
				" type:", body.get_class(),
				" layer:", body.collision_layer, 
				" mask:", body.collision_mask)
		else:
			print("[DEBUG] body:", body.name, 
				" type:", body.get_class(),
				" (no collision_layer property)")

		queue_free()



# ==============================
# == Damage Getter =============
# ==============================
func get_damage() -> int:
	return damage
