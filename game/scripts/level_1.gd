extends Node2D
class_name Level1

@export_group("Section 1")
@export var enemies_1: Array[Enemy]

@export_group("Section 2")
@export var respawn_pt_2: Node2D

func _on_enemy_trigger_1_body_entered(body: Node2D) -> void:
	if body is Player:
		for enemy in enemies_1:
			if is_instance_valid(enemy):
				enemy.frozen = false

func _on_die_zone_2_body_entered(body: Node2D) -> void:
	print(body)
	if body is Player:
		print('die!')
		var temp_energy = body.lantern_energy
		body.lantern_energy = 0
		body.lantern.fade_light(0)
		body.lantern.light_range = 0
		body.global_position = respawn_pt_2.global_position
		await get_tree().create_timer(2).timeout
		body.lantern_energy = temp_energy
		body.lantern.light_range = 0.05
		body.lantern.fade_light(temp_energy)
		
