extends Node2D

@export var light_level: float = 3:
	set(val):
		light_level = val
		$Lantern.fade_light(val)

@export var logger = false

signal lantern_lit

var lantern_time = 0

func _ready() -> void:
	$Lantern.light_level = light_level

func _process(delta: float) -> void:
	lantern_time += delta
	$Lantern.position.y = -67 + sin(lantern_time * 1) * 10
	$Lantern.position.x = 0
	
	if logger:
		print(position, ' ', $Lantern.position)



func _on_lantern_lantern_lit() -> void:
	lantern_lit.emit()
