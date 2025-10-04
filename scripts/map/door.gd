extends Area2D

@export var target_area: String = "res://scenes/world/area_2.tscn"  # Path scene tujuan
@export var target_spawn: String = "Spawn_Area2_From1"              # Nama spawn point tujuan

var entered := false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"): # pastikan hanya player
		entered = true 

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		entered = false
	
func _process(delta: float) -> void:
	if entered and Input.is_action_just_pressed("interaction"):
		var sm = get_tree().root.get_node("Main/SceneManager")
		if sm:
			sm.change_area(target_area, target_spawn)
