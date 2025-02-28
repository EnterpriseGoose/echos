extends CharacterBody2D
class_name CameraFollower

@export var player: Player
@export var frozen = false

func _process(delta: float) -> void:
	if not frozen:
		velocity = ((player.position - position)) * 100 * delta
	else:
		velocity = Vector2(0, 0)
		
	move_and_slide()
