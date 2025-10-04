extends Node

# Data player global
var max_hp: int = 100
var hp: int = 100
var food_count: int = 0

# Lokasi spawn terakhir (opsional)
var last_spawn_point: String = ""

func reset() -> void:
	max_hp = 100
	hp = 100
	food_count = 0
	last_spawn_point = ""
