extends Area2D

@export var damage: int = 10

func get_damage() -> int:
	return damage

func _ready() -> void:
	add_to_group("enemy_hitbox")
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		var player = area.get_parent()
		if player and player.has_method("take_damage"):
			player.take_damage(damage) # optional: enemy langsung panggil player
