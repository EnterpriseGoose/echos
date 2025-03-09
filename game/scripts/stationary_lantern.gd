extends Node2D

var lantern_time = 0

func _process(delta: float) -> void:
	lantern_time += delta
	$Lantern.position.y = -67 + sin(lantern_time * 1) * 10
