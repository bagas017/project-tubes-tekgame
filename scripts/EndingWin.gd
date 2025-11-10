extends CanvasLayer

func _ready():
	var gm = get_node("/root/GameManager")
	$Label2.text = "Soul: %d / Scrap: %d" % [gm.soul_count, gm.scrap_count]
	$Button.text = "Kembali ke Menu"
	$Button.pressed.connect(_on_back_to_menu)

func _on_back_to_menu():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
