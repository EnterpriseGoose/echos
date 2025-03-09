extends PointLight2D
class_name EchoPulse

func _ready() -> void:
	texture_scale = 0


func _process(delta: float) -> void:
	if (Global.player_view != Global.VIEW.ECHO):
		energy = max(0, energy - delta * 3)
	
	if texture_scale < 4:
		texture_scale += delta * 7
	
	if texture_scale >= 4:
		energy = max(0, (energy - delta * 1))
		
	if energy == 0:
		queue_free()
