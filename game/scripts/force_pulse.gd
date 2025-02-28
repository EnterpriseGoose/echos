extends PointLight2D
class_name ForcePulse

func _ready() -> void:
	texture_scale = 0
	$Area2D.scale = Vector2.ZERO


func _process(delta: float) -> void:
	if (Global.player_view != Global.VIEW.ECHO):
		energy = max(0, energy - delta * 3)
	
	if texture_scale < 3:
		texture_scale += delta * 4
		$Area2D.scale += Vector2(delta * 4, delta * 4)
	
	if texture_scale >= 3:
		energy = max(0, (energy - delta * 4))
		
	if energy == 0:
		queue_free()
	
	for body: PhysicsBody2D in $Area2D.get_overlapping_bodies():
		var parent_node = body.get_parent()
		if parent_node is Enemy:
			parent_node.add_force = (parent_node.global_position - global_position).normalized() * delta * 300
			if parent_node.type == Enemy.ENEMY_TYPE.MAD:
				parent_node.speed = 0
