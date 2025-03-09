extends Node2D



func _on_death_zone_1_body_entered(body: Node2D) -> void:
	print('enter zone')
	if body is Player:
		print('die!')
		var temp_energy = body.lantern_energy
		body.lantern_energy = 0
		body.lantern.fade_light(0)
		body.lantern.light_range = 0
		body.global_position = $"1/RespawnPt".global_position
		await get_tree().create_timer(2).timeout
		body.lantern_energy = temp_energy
		body.lantern.light_range = 0.05
		body.lantern.fade_light(temp_energy)
