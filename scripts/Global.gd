#extends Node
#
## ===============================
## ===== VARIABEL GLOBAL =========
## ===============================
#
## Nama spawn point tujuan setelah pindah map
#var next_spawn: String = "spawn_default"
#
## Bisa juga tambahkan variabel lain (misalnya level, score, inventory, dsb)


extends Node

# Data player global
var max_hp: int = 100
var hp: int = 100
var food_count: int = 0

# Lokasi spawn terakhir (opsional)
var last_spawn_point: String = ""
