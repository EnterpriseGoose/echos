extends Path2D
class_name PassThroughPlatform

@export var speed: float = 1
@export_range(0, 1, .01) var offset: float = 0

func _ready() -> void:
	if !offset:
		offset = 0

func _process(delta: float) -> void:
	var c_len = curve.get_baked_length()
	$PathFollow2D.progress_ratio = sin((Time.get_unix_time_from_system() * speed) + 2 * PI * offset) / 2 + .5
