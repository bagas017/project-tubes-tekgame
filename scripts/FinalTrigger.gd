extends Area2D

@onready var interact_label = $Label

var player_in_area: bool = false

func _ready():
	interact_label.visible = false

func _on_body_entered(body):
	if body.name == "Player":
		print("HALLO")
		player_in_area = true
		interact_label.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		interact_label.visible = false

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		_check_ending()

func _check_ending():
	var gm = get_node("/root/GameManager")
	var enough_soul = gm.soul_count >= gm.REQUIRED_SOUL
	var enough_scrap = gm.scrap_count >= gm.REQUIRED_SCRAP
	
	if enough_soul and enough_scrap:
		get_tree().change_scene_to_file("res://scenes/final/EndingWin.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/final/EndingLose.tscn")
