extends Area2D

func _ready() -> void:
	# Sambungkan sinyal body_entered ke fungsi handler
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Cek apakah yang masuk area adalah Player
	if body.is_in_group("player"):
		# Akses node health di dalam Player
		if body.has_node("PlayerHealth"):
			var health = body.get_node("PlayerHealth")
			# Panggil fungsi instant kill (bypass immunity)
			if health.has_method("kill_instant"):
				health.kill_instant()
