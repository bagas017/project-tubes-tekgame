extends CanvasLayer

func _ready():
	var gm = get_node("/root/GameManager")
	$Label.text = "YOU LOSE"
	$Label2.text = "Soul: %d / Scrap: %d\nKumpulkan lebih banyak untuk menang!" % [gm.soul_count, gm.scrap_count]
	$Button.text = "Coba Lagi"
	$Button.pressed.connect(_on_retry)

func _on_retry():
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")  # ganti ke scene awalmu
