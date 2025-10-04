extends Area2D

func _ready() -> void:
	add_to_group("enemy_hurtbox")
	print("EnemyHurtbox layer:", collision_layer, " mask:", collision_mask)
	print("Groups of EnemyDummy Hurtbox:", get_groups())
