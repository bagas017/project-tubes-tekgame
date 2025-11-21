extends Control

@onready var video: VideoStreamPlayer = $VideoStreamPlayer

func _ready():
	# When video finishes → go to Main
	video.finished.connect(_on_video_finished)

func _on_video_finished():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
