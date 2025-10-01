extends Area2D

# backup damage (kalau parent tidak punya)
@export var damage: int = 1

func get_damage() -> int:
	# Ambil damage dari parent (Trap.gd) kalau ada
	if owner and owner.has_method("get_damage"):
		return owner.get_damage()
	return damage
