extends Label

@export var float_distance: float = 6.0      # jarak naik/turun
@export var float_speed: float = 0.5         # durasi naik/turun
@export var auto_start: bool = true          # mulai otomatis saat ready

var float_tween: Tween
var base_position: Vector2

func _ready():
	base_position = position

	if auto_start:
		start_float()

func start_float():
	# Hentikan tween lama bila ada
	if float_tween:
		float_tween.kill()

	float_tween = create_tween()
	float_tween.set_loops()

	var up_y = base_position.y - float_distance

	float_tween.tween_property(self, "position:y", up_y, float_speed)
	float_tween.tween_property(self, "position:y", base_position.y, float_speed)

func stop_float():
	if float_tween:
		float_tween.kill()
		float_tween = null
		position = base_position   # reset ke posisi awal
