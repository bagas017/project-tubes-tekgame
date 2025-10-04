extends Node

var player_scene = preload("res://scenes/player.tscn")
var player: CharacterBody2D
@onready var current_area: Node = $"../CurrentArea"

func _ready():
	start_game()

func start_game():
	change_area("res://scenes/world/area_1.tscn", "Spawn_Area1_Start")

func change_area(area_path: String, spawn_name: String):
	# Keluarkan player sementara biar tidak ikut kehapus
	var old_player := player
	if old_player and old_player.get_parent():
		old_player.get_parent().remove_child(old_player)

	# Bersihkan area lama
	for child in current_area.get_children():
		child.queue_free()

	# Muat area baru ke CurrentArea
	var new_area = load(area_path).instantiate()
	current_area.add_child(new_area)

	# Kalau player belum pernah dibuat → spawn baru
	if player == null:
		player = player_scene.instantiate()

	# Masukkan player ke current_area lagi
	current_area.add_child(player)

	# Atur posisi player ke spawn
	var spawn = new_area.get_node_or_null(spawn_name)
	if spawn:
		player.global_position = spawn.global_position
	else:
		push_warning("Spawn point '%s' tidak ditemukan di %s" % [spawn_name, area_path])
