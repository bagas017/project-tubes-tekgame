extends CharacterBody2D

var hp: int = 30
var knockback: Vector2 = Vector2.ZERO
var knockback_decay: float = 400.0  # makin besar = knockback makin cepat berhenti

func _physics_process(delta: float) -> void:
	# gravitasi
	velocity.y += 20 * delta

	# overwrite X dengan knockback sementara
	if knockback.length() > 0.1:
		velocity.x = knockback.x
		knockback = knockback.move_toward(Vector2.ZERO, knockback_decay * delta)
	else:
		velocity.x = 0  # stop begitu knockback habis

	move_and_slide()

func take_damage(amount: int) -> void:
	hp -= amount
	print("Enemy HP:", hp)
	if hp <= 0:
		queue_free()

func apply_knockback(force: Vector2) -> void:
	knockback = force
