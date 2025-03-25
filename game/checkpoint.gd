extends Area2D
class_name Checkpoint

@onready var respawn_pt = $RespawnPt


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.last_checkpoint = self
