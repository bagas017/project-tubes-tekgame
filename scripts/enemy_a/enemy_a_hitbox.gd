extends Area2D

# fallback value (masih boleh di-set di inspector kalau mau)
@export var damage: int = 10

func _ready() -> void:
	add_to_group("enemy_hitbox")
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		var player = area.get_parent()
		if player and player.has_method("take_damage"):
			var dmg := get_damage()
			player.take_damage(dmg)

# Cari ancestor (parent, parent's parent, dst) yang punya get_attack_damage()
func _find_enemy_parent_with_damage_method() -> Node:
	var node = get_parent()
	while node:
		# cek apakah node punya method getter damage di EnemyA
		if node.has_method("get_attack_damage") or node.has_method("get_damage"):
			return node
		node = node.get_parent()
	return null

# Dipanggil oleh systems lain (mis. playerhealth) atau internal
func get_damage() -> int:
	var enemy = _find_enemy_parent_with_damage_method()
	if enemy:
		# prioritas ke getter parent
		if enemy.has_method("get_attack_damage"):
			return int(enemy.get_attack_damage())
		if enemy.has_method("get_damage"):
			return int(enemy.get_damage())
	# fallback ke export var local
	return damage
