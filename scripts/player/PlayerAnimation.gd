extends Node

# Helper: play only when different (mencegah restart setiap frame)
func _play_if_not_playing(sprite: AnimatedSprite2D, name: String) -> void:
	if sprite.animation != name:
		sprite.play(name)

func update(player, delta: float) -> void:
	match player.current_state:
		player.PlayerState.IDLE:
			_play_if_not_playing(player.animated_sprite_2d, "default_idle")
		player.PlayerState.RUN:
			_play_if_not_playing(player.animated_sprite_2d, "run")
		player.PlayerState.JUMP, player.PlayerState.FALL:
			if player.movement.jump_count == 2:
				_play_if_not_playing(player.animated_sprite_2d, "double_jump")
			else:
				_play_if_not_playing(player.animated_sprite_2d, "jump")
		player.PlayerState.WALL_SLIDE:
			_play_if_not_playing(player.animated_sprite_2d, "wall_slide")
		player.PlayerState.ROLL:
			_play_if_not_playing(player.animated_sprite_2d, "dash")
		player.PlayerState.ATTACK:
			_play_if_not_playing(player.animated_sprite_2d, "attack")
		player.PlayerState.HURT:
			_play_if_not_playing(player.animated_sprite_2d, "hurt")
		player.PlayerState.DEAD:
			print("Switching to DEAD animation")
			_play_if_not_playing(player.animated_sprite_2d, "dead")
		player.PlayerState.SPAWN:
			print("Switching to SPAWN animation")
			_play_if_not_playing(player.animated_sprite_2d, "spawn")
		player.PlayerState.EAT:
			_play_if_not_playing(player.animated_sprite_2d, "eat")
