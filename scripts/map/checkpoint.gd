extends Area2D

@export var active: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	print("Checkpoint: body masuk =", body.name)

	if body.is_in_group("player"):
		print("Body ada di group player")
		body.set_respawn_position(global_position)
		active = true
		print("Checkpoint tersimpan di: ", global_position)
