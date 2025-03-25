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
		#var parent_node = body.get_parent()
		if body.name == "CameraBarrier" or body.is_in_group("LevelCollider"):
			$PointLight2D.energy = max($PointLight2D.energy - 2 * delta, 0)
			$Fireball.modulate.a = max($Fireball.modulate.a - 2 * delta, 0)
			speed = 0.05
			fading = true
		if body is Enemy and $PointLight2D.energy > .25 and not used and body.type != Enemy.ENEMY_TYPE.MAD:
			body.kill()
			$PointLight2D.energy = max($PointLight2D.energy - 1, 0)
			$Fireball.modulate.a = max($Fireball.modulate.a - 1, 0)
			used = true
			speed = 0.1
