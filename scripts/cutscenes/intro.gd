extends Control

@onready var video: VideoStreamPlayer = $VideoStreamPlayer

func _ready():
	# When video finishes → go to Main
	video.finished.connect(_on_video_finished)

func _process(delta):
	# Tekan SPACE untuk skip
	if Input.is_action_just_pressed("ui_accept"):  # SPACE / ENTER (default Godot)
		_on_video_finished()
		
func _on_video_finished():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
