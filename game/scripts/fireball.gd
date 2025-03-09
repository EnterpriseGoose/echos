extends Node2D
class_name Fireball

var fading = false
var used = false
var speed = 1

func _ready() -> void:
	$Fireball.play("default")

func _process(delta: float) -> void:
	position += Vector2.from_angle(rotation) * delta * 300 * speed
	
	
	if fading:
		$PointLight2D.energy = max($PointLight2D.energy - 1.5 * delta, 0)
		$Fireball.modulate.a = max($Fireball.modulate.a - 1.5 * delta, 0)
		if $PointLight2D.energy <= 0 or $Fireball.modulate.a <= 0:
			queue_free()
	
	else:
		$PointLight2D.energy = min($PointLight2D.energy + 5 * delta, 2)
		$Fireball.modulate.a = min($Fireball.modulate.a + 5 * delta, 2)
		if $PointLight2D.energy >= 2:
			fading = true
			
	for body: PhysicsBody2D in $Area2D.get_overlapping_bodies():
		var parent_node = body.get_parent()
		if parent_node is Door or parent_node is Level1:
			print($PointLight2D.energy)
			$PointLight2D.energy = max($PointLight2D.energy - 5 * delta, 0)
			$Fireball.modulate.a = max($Fireball.modulate.a - 5 * delta, 0)
			speed = 0.1
			fading = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	var enemy_node = body.get_parent()
	if enemy_node is Enemy and $PointLight2D.energy > .25 and not used and enemy_node.type != Enemy.ENEMY_TYPE.MAD:
		enemy_node.kill()
		$PointLight2D.energy = max($PointLight2D.energy - 1, 0)
		$Fireball.modulate.a = max($Fireball.modulate.a - 1, 0)
		used = true
		speed = 0.1
