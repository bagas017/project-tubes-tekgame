extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Tambahkan food ke PlayerHealth
		if body.has_node("PlayerHealth"):
			body.get_node("PlayerHealth").add_food(1)

		# Mainkan animasi pickup (hilang + suara sudah diatur di animasi)
		animation_player.play("pickup_animation")
