extends CharacterBody2D
class_name CameraFollower

@export var player: Player
@export var frozen = false

var fast_mode = false

func _process(delta: float) -> void:
	if not frozen:
		velocity.x = ((player.position.x - position.x)) * 200 * delta
		velocity.y = ((player.position.y - position.y)) * 200 * delta
	else:
		velocity = Vector2(0, 0)
	
	fast_mode = player.velocity.length_squared() > 500 ** 2
	
	if not fast_mode:
		velocity = velocity.clamp(Vector2(-500, -500), Vector2(500, 500))
		
	move_and_slide()
