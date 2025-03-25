extends Node2D
class_name Forceball

var fading = false
var used = false
var speed = 1

func _ready() -> void:
	$Forceball.play("default")

func _process(delta: float) -> void:
	position += Vector2.from_angle(rotation) * delta * 300 * speed
	
	
	if fading:
		$PointLight2D.energy = max($PointLight2D.energy - 1 * delta, 0)
		$Forceball.modulate.a = max($Forceball.modulate.a - 1 * delta, 0)
		if $PointLight2D.energy <= 0 or $Forceball.modulate.a <= 0:
			queue_free()
	
	else:
		$PointLight2D.energy = min($PointLight2D.energy + 5 * delta, 2)
		$Forceball.modulate.a = min($Forceball.modulate.a + 5 * delta, 2)
		if $PointLight2D.energy >= 2:
			fading = true
	
	for body: PhysicsBody2D in $Area2D.get_overlapping_bodies():
		var parent_node = body.get_parent()
		if body is Enemy:
			body.add_force = Vector2.from_angle(rotation) * delta * 500
			speed = 0.9
			if body.type == Enemy.ENEMY_TYPE.MAD:
				body.speed = 0
		var chain_elem = body.find_parent("Chain")
		if chain_elem:
			var hanging_elem = chain_elem.get_parent()
			if hanging_elem is HangingPlatform:
				hanging_elem.push(Vector2.from_angle(rotation) / 2, global_position)
			if hanging_elem is HangingLantern:
				hanging_elem.push(Vector2.from_angle(rotation) * 7, global_position)
		if parent_node is Door or body.is_in_group("LevelCollider"):
			$PointLight2D.energy = max($PointLight2D.energy - 5 * delta, 0)
			$Forceball.modulate.a = max($Forceball.modulate.a - 5 * delta, 0)
			speed = 0.1
			fading = true
