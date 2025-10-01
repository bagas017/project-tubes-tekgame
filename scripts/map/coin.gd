extends Area2D

@onready var game_manager: Node = %"Game Manager"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Efek unique name (%) diatas tidak akan berfungsi jika berada di dalam scene yang berbeda (Seperti konsep game platform yang score nya terpisah tiap level)

func _on_body_entered(body: Node2D) -> void:
	game_manager.add_point()
	animation_player.play("pickup_animation")
