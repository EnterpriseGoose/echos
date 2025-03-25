extends Node2D



func _on_death_zone_1_body_entered(body: Node2D) -> void:
	print('enter zone')
	if body is Player:
		body.die()
